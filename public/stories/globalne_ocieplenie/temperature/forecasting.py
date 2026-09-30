"""Fixed benchmarks evaluated against a shared meteorological-year target."""
import numpy as np
import pandas as pd
from .series import monthly_series

FREQUENCIES={'annual':1,'seasonal':4,'monthly':12}
MODELS=('Naive','Drift','Seasonal naive','Trend + period')

def annual_blocks(wide,start=1962,end=2019):
    months=monthly_series(wide)
    selected=months.loc[f'{start-1}-12':f'{end}-11']
    expected=pd.period_range(f'{start-1}-12',f'{end}-11',freq='M')
    if not selected.index.equals(expected) or not np.isfinite(selected).all():
        raise ValueError('Incomplete meteorological years')
    return selected.to_numpy().reshape(end-start+1,12)

def representation(blocks,frequency):
    m=FREQUENCIES[frequency]
    return blocks.reshape(len(blocks),m,12//m).mean(axis=2).ravel()

def forecast(values,m,horizon,model):
    y=np.asarray(values,dtype=float)
    n=len(y); steps=np.arange(1,horizon*m+1)
    if n % m or n<2*m or not np.isfinite(y).all():
        raise ValueError('Expected complete finite cycles')
    if model=='Naive':
        result=np.repeat(y[-1],len(steps))
    elif model=='Drift':
        result=y[-1]+steps*(y[-1]-y[0])/(n-1)
    elif model=='Seasonal naive':
        result=np.tile(y[-m:],horizon)
    elif model=='Trend + period':
        # Shared linear trend plus fixed within-year intercepts, fitted on training only.
        def design(t):
            return np.column_stack([t/m,np.eye(m)[t % m]])
        beta=np.linalg.lstsq(design(np.arange(n)),y,rcond=None)[0]
        result=design(np.arange(n,n+len(steps)))@beta
    else:
        raise ValueError(model)
    return result.reshape(horizon,m).mean(axis=1)

def evaluate(blocks,origins,start=1962,horizon=6,stage='cv',targets=None):
    rows=[]
    targets=blocks if targets is None else targets
    for origin in origins:
        n=origin-start+1
        train=blocks[:n]
        actual=targets[n:n+horizon].mean(axis=1)
        if len(train)!=n or len(actual)!=horizon:
            raise ValueError('Origin outside data coverage')
        for freq,m in FREQUENCIES.items():
            y=representation(train,freq)
            for model in MODELS:
                pred=forecast(y,m,horizon,model)
                for h,(p,a) in enumerate(zip(pred,actual),1):
                    rows.append(dict(stage=stage,origin=origin,frequency=freq,model=model,horizon=h,year=origin+h,forecast=p,actual=a,error=p-a,training_values=len(y)))
    return pd.DataFrame(rows)

def metrics(predictions,groups):
    return predictions.groupby(groups,sort=False).error.agg(n='count',MAE=lambda s:s.abs().mean(),RMSE=lambda s:np.sqrt(np.mean(s*s)),bias='mean').reset_index()
