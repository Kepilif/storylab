"""Read frozen FAOSTAT World vintages; preserve source period definitions."""
from pathlib import Path
import hashlib
import zipfile
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
LABELS = dict(zip(range(7001, 7013), ['Sty','Lut','Mar','Kwi','Maj','Cze','Lip','Sie','Wrz','Paź','Lis','Gru']))
LABELS.update({7016:'DJF',7017:'MAM',7018:'JJA',7019:'SON',7020:'Rok'})

def load_world(vintage='historical'):
    if vintage == 'historical':
        path = ROOT/'data/Environment_Temperature_change_E_All_Data_NOFLAG.csv'
        raw = pd.read_csv(path, encoding='latin-1')
        raw = raw.loc[raw.Area.eq('World') & raw.Element.eq('Temperature change')]
        cols = [c for c in raw if c.startswith('Y') and c[1:].isdigit()]
        data = raw.melt(id_vars=['Months Code'],value_vars=cols,var_name='year',value_name='value')
        data['year'] = data.year.str[1:].astype(int)
        data = data.rename(columns={'Months Code':'code'})
        expected = range(1961,2020)
    elif vintage == 'updated':
        path = ROOT/'data/faostat_latest.zip'
        with zipfile.ZipFile(path) as z:
            raw = pd.read_csv(z.open('Environment_Temperature_change_E_All_Data_(Normalized).csv'),low_memory=False)
        raw = raw.loc[raw.Area.eq('World') & raw.Element.eq('Temperature change')]
        if not raw.Unit.eq('°C').all():
            raise ValueError('Unexpected unit')
        data = raw[['Months Code','Year','Value']].rename(columns={'Months Code':'code','Year':'year','Value':'value'})
        expected = range(1961,2026)
    else:
        raise ValueError(vintage)
    if data.duplicated(['year','code']).any() or not np.isfinite(data.value).all():
        raise ValueError('Duplicate or missing source values')
    wide = data.pivot(index='year',columns='code',values='value').sort_index()
    if wide.index.tolist()!=list(expected) or set(wide.columns)!=set(LABELS) or wide.isna().any().any():
        raise ValueError('Unexpected coverage or categories')
    return wide, {'path':str(path.relative_to(ROOT)), 'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                  'vintage':vintage, 'years':[min(expected),max(expected)], 'definition':'World / Temperature change; °C versus 1951–1980'}

def monthly_series(wide):
    """Calendar months only; December stays in its calendar year."""
    values = wide[list(range(7001,7013))].to_numpy().ravel()
    return pd.Series(values,index=pd.period_range(f'{wide.index.min()}-01',periods=len(values),freq='M'),name='anomaly')

def aggregation_audit(wide):
    """Candidate reconstructions, not assertions of source methodology."""
    records=[]
    for year,row in wide.iterrows():
        for code,months in {7016:[12,1,2],7017:[3,4,5],7018:[6,7,8],7019:[9,10,11],7020:[12,*range(1,12)]}.items():
            source_years=[year-1 if m==12 else year for m in months]
            if any(y not in wide.index for y in source_years):
                continue  # December 1960 is unavailable; never impute it.
            values=np.array([wide.loc[y,7000+m] for y,m in zip(source_years,months)])
            days=np.array([pd.Period(f'{y}-{m:02d}',freq='M').days_in_month for y,m in zip(source_years,months)])
            for rule,estimate in [('equal_months',values.mean()),('day_weights',np.average(values,weights=days))]:
                records.append(dict(year=year,target=LABELS[code],rule=rule,source=row[code],reconstructed=estimate,error=estimate-row[code]))
        estimate=row[[7016,7017,7018,7019]].mean()
        records.append(dict(year=year,target='Rok',rule='equal_seasons',source=row[7020],reconstructed=estimate,error=estimate-row[7020]))
    return pd.DataFrame(records)

def describe_periods(wide,start=1961,end=2019):
    """Descriptive OLS trends; residual variability in equal-length windows."""
    frame=wide.loc[start:end]
    rows=[]
    for code in frame:
        x=frame.index.to_numpy()-start
        y=frame[code].to_numpy()
        slope,intercept=np.polyfit(x,y,1)
        rows.append(dict(code=code,period=LABELS[code],trend_decade=slope*10,
                         lag1_residual=pd.Series(y-(intercept+slope*x)).autocorr()))
    windows=[]
    for first,last in [(1961,1979),(1981,1999),(2001,2019)]:
        part=wide.loc[first:last]
        for code in part:
            x=part.index.to_numpy()-first; y=part[code].to_numpy()
            slope,intercept=np.polyfit(x,y,1)
            windows.append(dict(code=code,period=LABELS[code],window=f'{first}–{last}',
                                residual_sd=np.sqrt(np.sum((y-intercept-slope*x)**2)/(len(y)-2))))
    return pd.DataFrame(rows),pd.DataFrame(windows)
