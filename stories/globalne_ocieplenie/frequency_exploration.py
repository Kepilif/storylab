"""Export the first frequency extension without fitting forecasting models."""
import json
from temperature.series import ROOT,load_world,aggregation_audit,describe_periods,monthly_series
import pandas as pd

def analyze():
    old,old_meta=load_world('historical')
    new,new_meta=load_world('updated')
    audit=pd.concat([aggregation_audit(w).assign(vintage=v) for v,w in [('historical',old),('updated',new)]],ignore_index=True)
    summary=audit.groupby(['vintage','target','rule'],sort=False).error.agg(n='count',bias='mean',max_abs=lambda s:s.abs().max(),mae=lambda s:s.abs().mean()).reset_index()
    trends,variability=describe_periods(old)
    revisions=(new.loc[old.index]-old).rename_axis(columns='code').stack().rename('revision').reset_index()
    months=monthly_series(old)
    assert str(months.index.min())=='1961-01' and str(months.index.max())=='2019-12'
    return dict(old=old,new=new,audit=audit,summary=summary,trends=trends,variability=variability,revisions=revisions,
                metadata={'sources':[old_meta,new_meta],'analysis_years':[1961,2019],
                          'aggregation_status':'Candidate rules only; no source equivalence established',
                          'common_complete_meteorological_years':[1962,2019],
                          'forecast_cutoff':'2019-11-30; exclude December 2019',
                          'variability_windows':[[1961,1979],[1981,1999],[2001,2019]],
                          'inference':'Descriptive; no significance claims or model selection'})

if __name__=='__main__':
    r=analyze(); out=ROOT/'results/frequency_exploration'; out.mkdir(parents=True,exist_ok=True)
    for key in ['audit','summary','trends','variability','revisions']:
        r[key].to_csv(out/f'{key}.csv',index=False)
    (out/'provenance.json').write_text(json.dumps(r['metadata'],ensure_ascii=False,indent=2),encoding='utf-8')
    print(r['summary'].to_string(index=False))
    print(r['trends'].to_string(index=False))
