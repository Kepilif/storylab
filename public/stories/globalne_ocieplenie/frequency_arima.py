"""Run expensive nested selection once; export results and provenance for QMD."""
import hashlib
import json
import numpy as np
import pandas as pd
import statsmodels
from temperature.series import ROOT,load_world
from temperature.forecasting import annual_blocks,metrics,FREQUENCIES
from temperature.arima_selection import NestedSelector,CANDIDATES
from frequency_backtest import analyze as benchmarks

def run():
    baseline=benchmarks()
    old,_=load_world('historical');new,_=load_world('updated')
    blocks=annual_blocks(old);targets=annual_blocks(new,1962,2025)
    selector=NestedSelector(blocks)
    rows=[]
    for origin in [*range(1990,2014),2019]:
        stage='cv' if origin<2019 else 'retrospective'
        source=blocks if stage=='cv' else targets
        offset=origin-1962+1
        actual=source[offset:offset+6].mean(axis=1)
        for frequency in FREQUENCIES:
            pred,chosen=selector.predict(frequency,origin)
            for h,(p,a) in enumerate(zip(pred,actual),1):
                rows.append(dict(stage=stage,origin=origin,frequency=frequency,model='Selected ARIMA/SARIMA',
                                 candidate=chosen,horizon=h,year=origin+h,forecast=p,actual=a,error=p-a))
        print(f'Completed origin {origin}; {len(selector.fits)} unique fits',flush=True)
    predictions=pd.DataFrame(rows)
    assert len(predictions)==25*3*6 and np.isfinite(predictions[['forecast','actual','error']]).all().all()
    all_predictions=pd.concat([baseline['cv'],baseline['final'],predictions],ignore_index=True)
    scores=metrics(all_predictions,['stage','frequency','model'])
    by_horizon=metrics(all_predictions,['stage','frequency','model','horizon'])
    metadata=baseline['metadata'].copy()
    metadata.pop('selection',None)
    metadata.pop('selection_rule',None)
    metadata.update(candidates=CANDIDATES,statsmodels=statsmodels.__version__,
                    inner_protocol='three expanding origins: outer-8, outer-7, outer-6; six-year annual MAE',
                    failure_policy='exclude candidates failing any inner fit; refit in inner-MAE order; abort if none succeeds',
                    selection_scope='per frequency and outer origin; no outer targets passed to selector')
    scores_cv=scores.query("stage=='cv'").sort_values(['MAE','frequency','model'])
    metadata['outer_cv_descriptive_best']=scores_cv.iloc[0][['frequency','model','MAE']].to_dict()
    out=ROOT/'results/frequency_arima';out.mkdir(parents=True,exist_ok=True)
    frames={'predictions':predictions,'scores':scores,'by_horizon':by_horizon,
            'fits':pd.DataFrame(selector.fits),'selections':pd.DataFrame(selector.selections)}
    for name,frame in frames.items():frame.to_csv(out/f'{name}.csv',index=False)
    paths=[ROOT/'frequency_arima.py',ROOT/'temperature/arima_selection.py',ROOT/'temperature/forecasting.py',ROOT/'temperature/series.py',ROOT/'frequency_backtest.py']
    metadata['code_sha256']={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    metadata['outputs_sha256']={f'{name}.csv':hashlib.sha256((out/f'{name}.csv').read_bytes()).hexdigest() for name in frames}
    (out/'provenance.json').write_text(json.dumps(metadata,indent=2,ensure_ascii=False),encoding='utf-8')
    print(scores.to_string(index=False))

if __name__=='__main__':run()
