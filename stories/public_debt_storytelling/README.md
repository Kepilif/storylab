# Public Debt Storytelling

Historia „Ile naprawdę wynosi polski dług publiczny?” oparta na notebooku `AN_dlug_publiczny.ipynb` i zapisanych danych z `dlug_publiczny.xlsx`. Zakres: 96 kwartałów, od 31.12.2001 do 30.09.2025. Raport porównuje PDP i EDP; nie przedstawia bieżącego stanu zadłużenia.

Audyt zapisanego CSV World Bank (`DT.DOD.DECT.CD`) potwierdził wiersz `POL`, ale 0 wartości liczbowych w 65 kolumnach rocznych. Pusta tabela i obraz z komunikatem zostały wycofane z raportu. Pliki pipeline WB pozostają materiałem technicznym; brak danych nie oznacza zerowego długu. Dług zewnętrzny nie jest zamienną miarą PDP/EDP.

## Struktura

- `data/raw/` - surowe pliki zrodlowe
- `data/processed/` - tabele wyjsciowe do analizy
- `figures/` - wykresy PNG generowane przez pipeline
- `scripts/` - pipeline danych
- `article/` - raport Quarto
- `notebooks/` - kopie notebookow zrodlowych

## Uruchomienie pipeline

```powershell
.\stories\public_debt_storytelling\scripts\run_pipeline.ps1
```

## Render raportu

```powershell
quarto render stories/public_debt_storytelling/article/polski_dlug_publiczny_story.qmd
```

## Kluczowe pliki wynikowe

- `data/processed/debt_quarterly.csv`
- `data/processed/debt_growth_by_government.csv`
- `data/processed/debt_event_slopes.csv`
- `data/processed/debt_latest_snapshot.csv`
- `data/processed/worldbank_external_debt_poland.csv`
- `data/processed/worldbank_external_debt_poland_latest.csv`
- `figures/01_edp_pdp_governments.png`
- `figures/02_pdp_edp_gap_regimes.png`
- `figures/03_worldbank_external_debt_poland.png`
