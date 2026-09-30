from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "data" / "raw"
PROCESSED_DIR = ROOT / "data" / "processed"
FIGURES_DIR = ROOT / "figures"


def main() -> None:
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)

    source = RAW_DIR / "API_DT.DOD.DECT.CD_DS2_en_csv_v2_976.csv"
    df = pd.read_csv(source)

    year_cols = [c for c in df.columns if str(c).isdigit()]
    pol = df[df["Country Code"] == "POL"].copy()

    if pol.empty:
        empty = pd.DataFrame(columns=["Country Name", "Country Code", "Indicator Name", "Indicator Code", "year", "external_debt_usd", "yoy_change_usd", "yoy_change_pct"])
        empty.to_csv(PROCESSED_DIR / "worldbank_external_debt_poland.csv", index=False, encoding="utf-8-sig")
        pd.DataFrame(columns=["year", "external_debt_usd", "yoy_change_usd", "yoy_change_pct"]).to_csv(
            PROCESSED_DIR / "worldbank_external_debt_poland_latest.csv", index=False, encoding="utf-8-sig"
        )
        (PROCESSED_DIR / "worldbank_external_debt_note.txt").write_text(
            "Country Code POL not found in source file.", encoding="utf-8"
        )
        fig, ax = plt.subplots(figsize=(10, 5))
        ax.axis("off")
        ax.text(0.5, 0.5, "Brak danych WB dla POL\nw tym pliku wskaźnika", ha="center", va="center")
        fig.tight_layout()
        fig.savefig(FIGURES_DIR / "03_worldbank_external_debt_poland.png", dpi=160)
        plt.close(fig)
        print("Saved empty World Bank outputs (POL missing).")
        return

    long_df = pol.melt(
        id_vars=["Country Name", "Country Code", "Indicator Name", "Indicator Code"],
        value_vars=year_cols,
        var_name="year",
        value_name="external_debt_usd",
    )
    long_df["year"] = pd.to_numeric(long_df["year"], errors="coerce")
    long_df["external_debt_usd"] = pd.to_numeric(long_df["external_debt_usd"], errors="coerce")
    long_df = long_df.dropna(subset=["year", "external_debt_usd"]).sort_values("year").reset_index(drop=True)

    if long_df.empty:
        long_df.to_csv(PROCESSED_DIR / "worldbank_external_debt_poland.csv", index=False, encoding="utf-8-sig")
        pd.DataFrame(columns=["year", "external_debt_usd", "yoy_change_usd", "yoy_change_pct"]).to_csv(
            PROCESSED_DIR / "worldbank_external_debt_poland_latest.csv", index=False, encoding="utf-8-sig"
        )
        (PROCESSED_DIR / "worldbank_external_debt_note.txt").write_text(
            "POL exists in file but has no non-null values for year columns.", encoding="utf-8"
        )
        fig, ax = plt.subplots(figsize=(10, 5))
        ax.axis("off")
        ax.text(0.5, 0.5, "Brak wartosci liczbowych WB dla POL", ha="center", va="center")
        fig.tight_layout()
        fig.savefig(FIGURES_DIR / "03_worldbank_external_debt_poland.png", dpi=160)
        plt.close(fig)
        print("Saved empty World Bank outputs (POL has no values).")
        return

    long_df["yoy_change_usd"] = long_df["external_debt_usd"].diff()
    long_df["yoy_change_pct"] = long_df["external_debt_usd"].pct_change() * 100

    latest = long_df.iloc[-1]
    latest_df = pd.DataFrame(
        [
            {
                "year": int(latest["year"]),
                "external_debt_usd": latest["external_debt_usd"],
                "yoy_change_usd": latest["yoy_change_usd"],
                "yoy_change_pct": latest["yoy_change_pct"],
            }
        ]
    )

    long_df.to_csv(PROCESSED_DIR / "worldbank_external_debt_poland.csv", index=False, encoding="utf-8-sig")
    latest_df.to_csv(PROCESSED_DIR / "worldbank_external_debt_poland_latest.csv", index=False, encoding="utf-8-sig")

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(long_df["year"], long_df["external_debt_usd"] / 1e9, color="#2b8cbe", linewidth=2)
    ax.set_title("Poland external debt stock (World Bank, DT.DOD.DECT.CD)")
    ax.set_xlabel("Year")
    ax.set_ylabel("USD bn")
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / "03_worldbank_external_debt_poland.png", dpi=160)
    plt.close(fig)

    print("Saved World Bank Poland external debt outputs.")


if __name__ == "__main__":
    main()
