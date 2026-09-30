"""Reproducible retrospective experiment; run directly to export evidence tables."""
from pathlib import Path
import hashlib
import json
import warnings
import numpy as np
import pandas as pd
import statsmodels
from statsmodels.tsa.arima.model import ARIMA

ROOT = Path(__file__).resolve().parent

def fit_arima(values):
    with warnings.catch_warnings(record=True) as caught:
        warnings.simplefilter("always")
        fit = ARIMA(np.asarray(values), order=(2, 1, 2)).fit()
    if not fit.mle_retvals.get("converged", False):
        raise RuntimeError("ARIMA optimization did not converge")
    return fit, sorted({str(w.message) for w in caught})

def analyze():
    fao_path = ROOT / "data/Environment_Temperature_change_E_All_Data_NOFLAG.csv"
    era_path = ROOT / "data/copernicus/annual/GCH_time_series_of_annual_global_temperatures_1850-2024_wrt_1991-2020.csv"
    raw = pd.read_csv(fao_path, encoding="latin-1")
    cols = [c for c in raw if c.startswith("Y") and c[1:].isdigit()]
    annual_world = raw.loc[raw.Element.eq("Temperature change") & raw.Months.eq("Meteorological year") & raw.Area.eq("World")]
    assert len(annual_world) == 1
    faostat_values = annual_world.iloc[0][cols].to_numpy(dtype=float)
    assert np.isfinite(faostat_values).all()
    assert [int(c[1:]) for c in cols] == list(range(1961, 2020))
    faostat_series = pd.Series(faostat_values, index=range(1961, 2020))
    faostat_fit, faostat_warnings = fit_arima(faostat_values)
    faostat_pred = faostat_fit.get_forecast(10)
    faostat_interval = np.asarray(faostat_pred.conf_int())
    faostat_forecast = pd.DataFrame({"year": range(2020, 2030), "forecast": faostat_pred.predicted_mean,
        "lower95": faostat_interval[:, 0], "upper95": faostat_interval[:, 1]})
    era = pd.read_csv(era_path, skiprows=2, index_col=False)
    era.columns = era.columns.str.strip()
    world = era[["Year", "ERA5"]].rename(columns={"Year":"year", "ERA5":"actual"})
    world = world.replace(-999, np.nan).dropna().sort_values("year").reset_index(drop=True)
    world["year"] = world.year.astype(int)
    assert world.year.tolist() == list(range(1940, 2025)), "Unexpected ERA5 time coverage"
    train = world.loc[world.year.le(2019)].copy()
    test = world.loc[world.year.between(2020, 2024)].copy()
    assert len(train) == 80 and len(test) == 5
    y = train.actual.to_numpy()
    steps = np.arange(1, 6)
    fit, model_warnings = fit_arima(y)
    pred = fit.get_forecast(5)
    slope, intercept = np.polyfit(train.year - 1940, y, 1)
    predictions = {"Naive": np.repeat(y[-1], 5),
        "Drift": y[-1] + steps * (y[-1] - y[0]) / (len(y)-1),
        "Trend liniowy": intercept + slope * (test.year.to_numpy()-1940),
        "ARIMA(2,1,2)": np.asarray(pred.predicted_mean)}
    comparison = pd.concat([test.assign(model=name, forecast=values) for name, values in predictions.items()], ignore_index=True)
    comparison["error"] = comparison.forecast - comparison.actual
    comparison["absolute_error"] = comparison.error.abs()
    scores = pd.DataFrame([{"model": name, "MAE": g.error.abs().mean(),
        "RMSE": np.sqrt(np.mean(g.error**2)), "bias": g.error.mean()}
        for name, g in comparison.groupby("model", sort=False)]).sort_values("MAE").reset_index(drop=True)
    interval = np.asarray(pred.conf_int(alpha=.05))
    arima = comparison.loc[comparison.model.eq("ARIMA(2,1,2)")].copy()
    arima["lower95"], arima["upper95"] = interval[:,0], interval[:,1]
    arima["covered"] = arima.actual.between(arima.lower95, arima.upper95)
    annual = raw.loc[raw.Element.eq("Temperature change") & raw.Months.eq("Meteorological year")]
    regions = annual.loc[annual.Area.isin(["Africa","Americas","Asia","Europe","Oceania","World"])].melt(id_vars="Area", value_vars=cols, var_name="year", value_name="anomaly").dropna()
    regions["year"] = regions.year.str[1:].astype(int)
    assert not regions.duplicated(["Area", "year"]).any()
    assert np.isfinite(comparison[["actual","forecast","error"]]).all().all()
    metadata = {"training": [1940,2019], "test": [2020,2024], "statsmodels":statsmodels.__version__,
        "arima_order":[2,1,2], "arima_trend":"none (default for d=1)",
        "warnings":model_warnings, "faostat_warnings":faostat_warnings,
        "faostat_definition": "World / Temperature change / Meteorological year; no imputation",
        "sources":{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [fao_path,era_path]}}
    return dict(raw=raw, faostat_series=faostat_series, faostat_forecast=faostat_forecast, world=world, train=train, test=test,
        comparison=comparison, scores=scores, arima=arima, regions=regions, metadata=metadata)

if __name__ == "__main__":
    results = analyze()
    out = ROOT / "results"
    out.mkdir(exist_ok=True)
    for key in ["faostat_forecast", "comparison", "scores", "arima"]:
        results[key].to_csv(out / f"{key}.csv", index=False)
    (out / "provenance.json").write_text(json.dumps(results["metadata"], indent=2, ensure_ascii=False), encoding="utf-8")
    print(results["scores"].to_string(index=False))
    print(json.dumps(results["metadata"], indent=2))
