"""Frozen benchmark protocol: origins 1990–2013; horizons 1–6 years."""
import json
import numpy as np
from temperature.series import ROOT,load_world
from temperature.forecasting import annual_blocks,evaluate,metrics,MODELS

def analyze():
    old,oldmeta=load_world('historical'); new,newmeta=load_world('updated')
    train=annual_blocks(old,1962,2019)
    targets=annual_blocks(new,1962,2025)
    cv=evaluate(train,range(1990,2014))
    final=evaluate(train,[2019],stage='retrospective',targets=targets)
    scores=metrics(cv,['frequency','model'])
    by_horizon=metrics(cv,['frequency','model','horizon'])
    final_scores=metrics(final,['frequency','model'])
    # These methods commute with equal-weight temporal aggregation on complete cycles.
    for model in ['Seasonal naive','Trend + period']:
        matrix=cv[cv.model.eq(model)].pivot(index=['origin','horizon'],columns='frequency',values='forecast')
        assert np.allclose(matrix.to_numpy(),matrix[['annual']].to_numpy(),atol=1e-10)
    assert len(cv)==24*3*4*6 and np.isfinite(cv[['forecast','actual','error']]).all().all()
    tied=scores[scores.MAE<=scores.MAE.min()+1e-10].copy()
    tied['priority']=tied.frequency.map({'annual':0,'seasonal':1,'monthly':2})
    selection=tied.sort_values(['priority','model']).iloc[0][['frequency','model']].to_dict()
    metadata={'sources':[oldmeta,newmeta],'start_meteorological_year':1962,'cutoff':'2019-11-30',
              'origins':list(range(1990,2014)),'horizons':list(range(1,7)),
              'models':list(MODELS),'aggregation':'equal monthly weights, December(previous year)–November',
              'target':'derived annual mean of World monthly anomalies; NOT official Meteorological year',
              'cv_vintage':'historical, including validation targets','final_training_vintage':'historical',
              'final_target_vintage':'updated; includes revised December 2019 in target 2020',
              'selection':selection,'selection_rule':'smallest pooled CV MAE; descriptive selection score, not unbiased assessment',
              'limitations':['overlapping validation horizons','retrospective, not real-time vintages','2020–2025 already inspected in earlier project','no inferential significance claims']}
    return dict(cv=cv,final=final,scores=scores,by_horizon=by_horizon,final_scores=final_scores,metadata=metadata)

if __name__=='__main__':
    r=analyze(); out=ROOT/'results/frequency_backtest';out.mkdir(parents=True,exist_ok=True)
    for k in ['cv','final','scores','by_horizon','final_scores']:r[k].to_csv(out/f'{k}.csv',index=False)
    (out/'provenance.json').write_text(json.dumps(r['metadata'],ensure_ascii=False,indent=2),encoding='utf-8')
    print(r['scores'].sort_values('MAE').to_string(index=False))
    print(r['final_scores'].sort_values('MAE').to_string(index=False))
