"""Compare a preserved FAOSTAT vintage with the downloaded 1961–2025 release."""
from pathlib import Path
import hashlib
import json
import zipfile
import numpy as np
import pandas as pd
from temperature_backtest import analyze

ROOT = Path(__file__).resolve().parent
URL = 'https://bulks-faostat.fao.org/production/Environment_Temperature_change_E_All_Data_(Normalized).zip'

def audit():
    archive = ROOT / 'data/faostat_latest.zip'
    with zipfile.ZipFile(archive) as z:
        member = 'Environment_Temperature_change_E_All_Data_(Normalized).csv'
        data = pd.read_csv(z.open(member), encoding='utf-8-sig', low_memory=False)
    selected = data.loc[data.Area.eq('World') & data.Months.eq('Meteorological year') & data.Element.eq('Temperature change')].sort_values('Year')
    assert not selected.Year.duplicated().any()
    assert selected.Year.tolist() == list(range(1961, 2026))
    assert np.isfinite(selected.Value).all()
    assert selected.Unit.eq('°C').all()
    r = analyze()
    old_row = r['raw'].loc[r['raw'].Area.eq('World') & r['raw'].Months.eq('Meteorological year') & r['raw'].Element.eq('Temperature change')].iloc[0]
    for key in ['Area Code', 'Months Code', 'Element Code']:
        assert selected[key].eq(old_row[key]).all(), key
    latest = selected[['Year', 'Value']].rename(columns={'Year':'year', 'Value':'latest'})
    history = r['faostat_series'].rename('original').rename_axis('year').reset_index().merge(latest, on='year', validate='one_to_one')
    history['revision'] = history.latest - history.original
    comparison = r['faostat_forecast'].merge(latest.query('year >= 2020'), on='year', validate='one_to_one')
    comparison['error'] = comparison.forecast - comparison.latest
    comparison['covered95'] = comparison.latest.between(comparison.lower95, comparison.upper95)
    stats = {'download_date':'2026-09-22', 'url':URL, 'rows_in_archive':len(data),
        'definition':'World / Meteorological year / Temperature change; °C; 1951–1980 baseline',
        'methodology_status':'Same series codes and published conceptual definition; full vintage-to-vintage algorithm equivalence not established.',
        'revised_years':int((history.revision.abs() > 1e-10).sum()),
        'mean_revision':float(history.revision.mean()), 'max_absolute_revision':float(history.revision.abs().max()),
        'MAE':float(comparison.error.abs().mean()), 'RMSE':float(np.sqrt((comparison.error**2).mean())),
        'bias':float(comparison.error.mean()), 'coverage95':int(comparison.covered95.sum()),
        'sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [archive, ROOT/'data/Environment_Temperature_change_E_All_Data_NOFLAG.csv']}}
    return latest, history, comparison, stats

if __name__ == '__main__':
    latest, history, comparison, stats = audit()
    out = ROOT/'results'
    out.mkdir(exist_ok=True)
    for name, frame in [('faostat_latest_annual',latest),('faostat_revisions',history),('faostat_validation',comparison)]:
        frame.to_csv(out/f'{name}.csv',index=False)
    (out/'faostat_audit.json').write_text(json.dumps(stats,indent=2,ensure_ascii=False),encoding='utf-8')
    print(comparison.to_string(index=False))
    print(json.dumps(stats,indent=2,ensure_ascii=False))
