from __future__ import annotations

from pathlib import Path
from typing import Iterable

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
PROCESSED_DIR = ROOT / "data" / "processed"
FIGURES_DIR = ROOT / "figures"


def load_debt_table(path: Path) -> pd.DataFrame:
    df = pd.read_excel(path)
    rename_map = {
        "Data/ Date": "date",
        "Dlug EDP (mld zl)/EDP debt (PLN bn)": "edp_bn",
        "Dlug EDP (%PKB)/ EDP debt (% of GDP)": "edp_pct_gdp",
        "Panstwowy dlug publiczny (mld zl)/ Public debt (PLN bn)": "pdp_bn",
        "Panstwowy dlug publiczny (%PKB)/ Public debt (% of GDP)": "pdp_pct_gdp",
        "Dług EDP (mld zł)/EDP debt (PLN bn)": "edp_bn",
        "Dług EDP (%PKB)/ EDP debt (% of GDP)": "edp_pct_gdp",
        "Państwowy dług publiczny (mld zł)/ Public debt (PLN bn)": "pdp_bn",
        "Państwowy dług publiczny (%PKB)/ Public debt (% of GDP)": "pdp_pct_gdp",
    }
    df = df.rename(columns=rename_map)
    required = ["date", "edp_bn", "pdp_bn", "edp_pct_gdp", "pdp_pct_gdp"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    df = df[required].copy()
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    for col in [c for c in required if c != "date"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df.dropna(subset=["date"]).sort_values("date").reset_index(drop=True)
    df["diff_pdp_minus_edp_bn"] = df["pdp_bn"] - df["edp_bn"]
    df["diff_pdp_minus_edp_pct_gdp"] = df["pdp_pct_gdp"] - df["edp_pct_gdp"]
    return df


def assign_government(date_value: pd.Timestamp) -> str:
    periods = [
        ("2001-10-19", "2004-05-02", "SLD"),
        ("2005-10-31", "2007-11-16", "PiS I"),
        ("2007-11-16", "2015-11-16", "PO-PSL"),
        ("2015-11-16", "2023-12-13", "PiS II"),
        ("2023-12-13", "2100-01-01", "Koalicja 2023"),
    ]
    for start, end, label in periods:
        if pd.Timestamp(start) <= date_value <= pd.Timestamp(end):
            return label
    return "Poza okresami"


def build_growth_table(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for government, group in df.groupby("government"):
        group = group.sort_values("date")
        if len(group) < 2:
            continue
        start_date = group["date"].iloc[0]
        end_date = group["date"].iloc[-1]
        years = max((end_date - start_date).days / 365.25, 0.01)
        start_edp = group["edp_bn"].iloc[0]
        end_edp = group["edp_bn"].iloc[-1]
        rows.append(
            {
                "government": government,
                "start_date": start_date,
                "end_date": end_date,
                "start_edp_bn": start_edp,
                "end_edp_bn": end_edp,
                "change_edp_bn": end_edp - start_edp,
                "avg_growth_edp_bn_per_year": (end_edp - start_edp) / years,
            }
        )
    return pd.DataFrame(rows).sort_values("start_date")


def slope_in_window(df: pd.DataFrame, start: pd.Timestamp, end: pd.Timestamp) -> float | None:
    part = df[(df["date"] >= start) & (df["date"] <= end)].sort_values("date")
    if len(part) < 2:
        return None
    dy = part["edp_bn"].iloc[-1] - part["edp_bn"].iloc[0]
    dt = (part["date"].iloc[-1] - part["date"].iloc[0]).days / 365.25
    if dt <= 0:
        return None
    return dy / dt


def build_event_slopes(df: pd.DataFrame, events: Iterable[tuple[str, str]]) -> pd.DataFrame:
    rows = []
    for label, date_value in events:
        d = pd.Timestamp(date_value)
        rows.append(
            {
                "event": label,
                "event_date": d,
                "slope_before_bn_per_year": slope_in_window(df, d - pd.DateOffset(years=2), d - pd.Timedelta(days=1)),
                "slope_after_bn_per_year": slope_in_window(df, d + pd.Timedelta(days=1), d + pd.DateOffset(years=2)),
            }
        )
    return pd.DataFrame(rows)


def build_figures(df: pd.DataFrame) -> None:
    gov_periods = [
        ("2001-10-19", "2004-05-02", "SLD"),
        ("2005-10-31", "2007-11-16", "PiS I"),
        ("2007-11-16", "2015-11-16", "PO-PSL"),
        ("2015-11-16", "2023-12-13", "PiS II"),
        ("2023-12-13", str(df["date"].max().date()), "Koalicja 2023"),
    ]
    events = [("Reforma OFE", "2014-02-01"), ("Fundusze COVID", "2020-04-01"), ("FWSZ", "2022-03-01")]

    fig, ax = plt.subplots(figsize=(11, 6))
    ax.plot(df["date"], df["edp_bn"], label="EDP", linewidth=2.0, color="#1f77b4")
    ax.plot(df["date"], df["pdp_bn"], label="PDP", linewidth=2.0, color="#ff7f0e")
    span_colors = ["#eef5ff", "#dbe9ff"]
    for i, (start, end, label) in enumerate(gov_periods):
        s = pd.Timestamp(start)
        e = pd.Timestamp(end)
        ax.axvspan(s, e, color=span_colors[i % 2], alpha=0.35)
        ax.axvline(s, color="gray", linewidth=1.0, linestyle="--", alpha=0.7)
        ax.text(s + pd.DateOffset(months=4), ax.get_ylim()[1] * 0.94, label, rotation=90, va="top", ha="left", fontsize=8)
    for label, date_value in events:
        d = pd.Timestamp(date_value)
        ax.axvline(d, color="#c00000", linewidth=1.5, linestyle=":")
        ax.text(d + pd.DateOffset(months=1), ax.get_ylim()[1] * 0.82, label, rotation=90, color="#c00000", fontsize=8, va="top")
    ax.set_title("Polska: EDP vs PDP (mld PLN) z oznaczeniem rzadow i zdarzen fiskalnych")
    ax.set_xlabel("Data")
    ax.set_ylabel("mld PLN")
    ax.legend(loc="lower right")
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / "01_edp_pdp_governments.png", dpi=160)
    plt.close(fig)

    fig, ax = plt.subplots(figsize=(11, 5))
    ax.plot(df["date"], df["diff_pdp_minus_edp_bn"], color="steelblue", linewidth=2.0)
    ax.axvspan(pd.Timestamp("2020-03-01"), pd.Timestamp("2024-12-31"), color="purple", alpha=0.08)
    ax.axvspan(pd.Timestamp("2025-01-01"), df["date"].max() + pd.DateOffset(months=18), color="green", alpha=0.08)
    ax.set_title("Roznica PDP - EDP (mld PLN)")
    ax.set_xlabel("Data")
    ax.set_ylabel("mld PLN")
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / "02_pdp_edp_gap_regimes.png", dpi=160)
    plt.close(fig)


def main() -> None:
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)

    df = load_debt_table(RAW_DIR / "dlug_publiczny.xlsx")
    df["government"] = df["date"].apply(assign_government)

    growth_df = build_growth_table(df)
    events_df = build_event_slopes(
        df,
        events=[("Reforma OFE", "2014-02-01"), ("Fundusze COVID", "2020-04-01"), ("FWSZ", "2022-03-01")],
    )

    latest = df.iloc[-1]
    latest_df = pd.DataFrame(
        [
            {
                "date": latest["date"],
                "edp_bn": latest["edp_bn"],
                "pdp_bn": latest["pdp_bn"],
                "edp_pct_gdp": latest["edp_pct_gdp"],
                "pdp_pct_gdp": latest["pdp_pct_gdp"],
                "diff_pdp_minus_edp_bn": latest["diff_pdp_minus_edp_bn"],
                "diff_pdp_minus_edp_pct_gdp": latest["diff_pdp_minus_edp_pct_gdp"],
            }
        ]
    )

    df.to_csv(PROCESSED_DIR / "debt_quarterly.csv", index=False, encoding="utf-8-sig")
    growth_df.to_csv(PROCESSED_DIR / "debt_growth_by_government.csv", index=False, encoding="utf-8-sig")
    events_df.to_csv(PROCESSED_DIR / "debt_event_slopes.csv", index=False, encoding="utf-8-sig")
    latest_df.to_csv(PROCESSED_DIR / "debt_latest_snapshot.csv", index=False, encoding="utf-8-sig")

    build_figures(df)
    print("Saved processed debt files and figures.")


if __name__ == "__main__":
    main()
