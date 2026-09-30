"""Paired, descriptive stability analysis; no refitting or holdout selection."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'results/frequency_stability'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def paired_errors(predictions):
    keys = ['stage', 'origin', 'horizon', 'year']
    ids = keys + ['frequency', 'model']
    assert not predictions.duplicated(ids).any(), 'Duplicate prediction'
    assert np.isfinite(predictions[['forecast', 'actual', 'error']]).all().all()
    assert np.allclose(predictions.error, predictions.forecast - predictions.actual)
    assert (predictions.year == predictions.origin + predictions.horizon).all()
    base = predictions.query("frequency=='annual' and model=='Trend + period'")
    paired = predictions.merge(base[keys + ['actual', 'error']], on=keys,
                               suffixes=('', '_baseline'), validate='many_to_one')
    assert len(paired) == len(predictions), 'Missing reference prediction'
    assert np.allclose(paired.actual, paired.actual_baseline), 'Different targets'
    paired['delta_abs_error'] = paired.error.abs() - paired.error_baseline.abs()
    return paired


def block_range(values, block, repetitions=10000):
    """Moving blocks of consecutive origins, preserving all six horizons together."""
    values = np.asarray(values)
    rng = np.random.default_rng(20260924)
    starts = rng.integers(0, len(values)-block+1,
                         size=(repetitions, int(np.ceil(len(values)/block))))
    indices = (starts[..., None] + np.arange(block)).reshape(repetitions, -1)
    means = values[indices[:, :len(values)]].mean(axis=1)
    return np.quantile(means, [.025, .975])


def verify_freeze():
    manifest = json.loads((OUT / 'evaluation_lock.json').read_text(encoding='utf-8'))
    for name, expected in manifest['sha256'].items():
        if digest(ROOT / name) != expected:
            raise ValueError(f'Zamrożona ocena zmieniona: {name}. Utwórz osobną wersję eksperymentu.')
    return manifest


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    lock = OUT / 'evaluation_lock.json'
    if lock.exists():
        verify_freeze()
    arima_dir = ROOT / 'results/frequency_arima'
    meta = json.loads((arima_dir / 'provenance.json').read_text(encoding='utf-8'))
    paths = set()
    for name, expected in meta['code_sha256'].items():
        assert digest(ROOT/name) == expected, name
        paths.add(name)
    for source in meta['sources']:
        assert digest(ROOT/source['path']) == source['sha256']
        paths.add(source['path'])
    for name, expected in meta['outputs_sha256'].items():
        assert digest(arima_dir/name) == expected, name
        paths.add(str((arima_dir/name).relative_to(ROOT)))
    paths.add('results/frequency_arima/provenance.json')
    frames = [pd.read_csv(arima_dir/'predictions.csv')]
    for name in ['cv.csv', 'final.csv']:
        relative = 'results/frequency_backtest/' + name
        paths.add(relative)
        frames.append(pd.read_csv(ROOT/relative))
    predictions = pd.concat(frames, ignore_index=True)
    # ARIMA export contains dynamic predictions only; benchmarks are separate.
    paired = paired_errors(predictions)
    for (stage, freq, model), group in paired.groupby(['stage', 'frequency', 'model']):
        origins = list(range(1990, 2014)) if stage == 'cv' else [2019]
        assert set(zip(group.origin, group.horizon)) == {(o,h) for o in origins for h in range(1,7)}
    paired.to_csv(OUT/'paired_errors.csv', index=False)
    cv = paired.query("stage=='cv'")
    origin = cv.groupby(['frequency','model','origin']).delta_abs_error.mean().reset_index()
    origin.to_csv(OUT/'by_origin.csv', index=False)
    cv.groupby(['frequency','model','horizon']).delta_abs_error.mean().reset_index().to_csv(OUT/'by_horizon.csv', index=False)
    rows = []
    for (freq, model), group in origin.groupby(['frequency','model']):
        values = group.sort_values('origin').delta_abs_error.to_numpy()
        for block in [3,6,8]:
            low, high = block_range(values, block)
            rows.append(dict(frequency=freq, model=model, block=block,
                             delta_MAE=values.mean(), wins=int((values < -1e-10).sum()),
                             ties=int((np.abs(values) <= 1e-10).sum()), origins=len(values),
                             low=low, high=high))
    pd.DataFrame(rows).to_csv(OUT/'stability.csv', index=False)
    final = paired.query("stage=='retrospective'").copy()
    final.to_csv(OUT/'evaluation_2020_2025.csv', index=False)
    paths.update(['frequency_stability.py', 'results/frequency_backtest/provenance.json',
                  'results/frequency_stability/evaluation_2020_2025.csv'])
    if not lock.exists():
        manifest = dict(frozen_at_utc=datetime.now(timezone.utc).isoformat(),
                        status='retrospective freeze after outcomes were inspected; not preregistered',
                        cutoff='2019-11-30', target_years=list(range(2020,2026)),
                        target='World monthly anomalies, equal weights December–November',
                        selection='Historical CV only; nested ARIMA selection; no test-period updates',
                        separate_from='Original ARIMA(2,1,2) audit on official Meteorological year',
                        sha256={name:digest(ROOT/name) for name in sorted(paths)})
        lock.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding='utf-8')
    verify_freeze()
    print(pd.DataFrame(rows).query("block==6 and model=='Selected ARIMA/SARIMA'").to_string(index=False))


if __name__ == '__main__':
    main()
