"""Nested rolling-origin selection with a fixed, small ARIMA/SARIMA menu."""
from functools import lru_cache
import warnings
import time
import numpy as np
from statsmodels.tsa.arima.model import ARIMA
from .forecasting import FREQUENCIES,representation

CANDIDATES={
    'ar1_trend':((1,0,0),(0,0,0),'ct'),
    'arima011':((0,1,1),(0,0,0),'n'),
    'arima011_drift':((0,1,1),(0,0,0),'t'),
    'arima110_drift':((1,1,0),(0,0,0),'t'),
    'arima212_original':((2,1,2),(0,0,0),'n'),
    'sarima011_100':((0,1,1),(1,0,0),'t'),
    'sarima010_011':((0,1,0),(0,1,1),'n'),
}

def inner_origins(origin):
    # All six-year validation targets end on or before the outer origin.
    return [origin-8,origin-7,origin-6]

def candidates(frequency):
    return [k for k in CANDIDATES if frequency!='annual' or not k.startswith('sarima')]

class NestedSelector:
    def __init__(self,blocks,start=1962,horizon=6):
        self.blocks=blocks
        self.start=start
        self.horizon=horizon
        self.fits=[]
        self.selections=[]

    @lru_cache(maxsize=None)
    def fit(self,frequency,origin,candidate):
        n=origin-self.start+1
        if n<20 or n>len(self.blocks):raise ValueError('Training bounds')
        m=FREQUENCIES[frequency]
        y=representation(self.blocks[:n],frequency)
        order,season,trend=CANDIDATES[candidate]
        seasonal_order=(*season,m) if any(season) else (0,0,0,0)
        began=time.perf_counter(); messages=[];error=''; result=None
        try:
            with warnings.catch_warnings(record=True) as caught:
                warnings.simplefilter('always')
                model=ARIMA(y,order=order,seasonal_order=seasonal_order,trend=trend)
                fit=model.fit(method_kwargs={'maxiter':150})
                pred=np.asarray(fit.forecast(self.horizon*m))
            messages=sorted({str(w.message) for w in caught})
            if not fit.mle_retvals.get('converged',False):raise ValueError('Optimizer did not converge')
            if not np.isfinite(pred).all():raise ValueError('Nonfinite prediction')
            result=pred.reshape(self.horizon,m).mean(axis=1)
        except (ValueError,np.linalg.LinAlgError) as exc:
            error=str(exc)
        self.fits.append(dict(frequency=frequency,origin=origin,candidate=candidate,
                              success=result is not None,error=error,warnings=' | '.join(messages),
                              seconds=time.perf_counter()-began,training_values=len(y)))
        return result

    def predict(self,frequency,origin):
        ranking=[]
        for candidate in candidates(frequency):
            errors=[]
            for inner in inner_origins(origin):
                prediction=self.fit(frequency,inner,candidate)
                if prediction is None:break
                offset=inner-self.start+1
                actual=self.blocks[offset:offset+self.horizon].mean(axis=1)
                if len(actual)!=self.horizon or inner+self.horizon>origin:raise ValueError('Inner leakage')
                errors.extend(prediction-actual)
            valid=len(errors)==3*self.horizon
            score=float(np.mean(np.abs(errors))) if valid else np.inf
            ranking.append((score,candidate))
        ranking.sort()
        chosen=None;prediction=None
        # Defined fallback: next eligible inner-CV candidate, never chosen by outer error.
        for score,candidate in ranking:
            if not np.isfinite(score):continue
            prediction=self.fit(frequency,origin,candidate)
            if prediction is not None:
                chosen=candidate;break
        for score,candidate in ranking:
            self.selections.append(dict(frequency=frequency,origin=origin,candidate=candidate,
                                        inner_MAE=score if np.isfinite(score) else None,
                                        selected=candidate==chosen,inner_origins=','.join(map(str,inner_origins(origin)))))
        if chosen is None:raise RuntimeError(f'No eligible candidate for {frequency}/{origin}')
        return prediction,chosen
