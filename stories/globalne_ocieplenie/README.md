# Prognoza kontra rzeczywistość

## Etapy 6–7: stabilność i zamrożona ocena

`frequency_stability.py` analizuje zapisane prognozy bez ponownego dopasowywania modeli. Porównuje sparowane błędy z rocznym trendem, według 24 początków i sześciu horyzontów. Ruchome bloki 3, 6 i 8 kolejnych początków (10 000 losowań, ziarno 20260924) zachowują razem sześć horyzontów i pary model–benchmark. Kwantyle 2,5% i 97,5% to opisowa analiza niepewności, nie formalny test istotności ani przedziały predykcji temperatury. Przy 24 początkach, wspólnych treningach i możliwej niestacjonarności interpretacja pozostaje ostrożna.

Wyniki znajdują się w `results/frequency_stability/`, a wykresy i wnioski w `notebooks/04_arima_frequency.qmd`. `evaluation_lock.json` utrwala źródła, kod, konfiguracje, prognozy i tabele przy pomocy SHA-256. Zamrożenie nastąpiło 2026-09-24 po obejrzeniu okresu 2020–2025; nie jest prerejestracją. Cel stanowi rekonstruowana średnia miesięcy grudzień–listopad, więc wyników nie łączymy z audytem dawnej prognozy na opublikowanym `Meteorological year`.

Odtworzenie: `.\.venv\Scripts\python.exe stories/globalne_ocieplenie/frequency_stability.py`. Istniejący manifest jest weryfikowany przed obliczeniami i nie jest automatycznie nadpisywany. Zmienione wejścia wymagają osobnej wersji eksperymentu z zachowaniem obecnych plików i manifestu. Notebooki 03 i 04 sprawdzają zamrożenie podczas renderowania. Testy obejmują parowanie celów, zachowanie stałej różnicy w losowaniu blokowym oraz wykrywanie zmiany zamrożonego pliku.

## Rozszerzenie częstotliwości — etap 3: ARIMA/SARIMA

`notebooks/04_arima_frequency.qmd` prezentuje zagnieżdżony dobór modeli. Uruchom `.\.venv\Scripts\python.exe stories/globalne_ocieplenie/frequency_arima.py`, następnie renderuj notebook. Wyniki, rejestr dopasowań i wybory znajdują się w `results/frequency_arima/`. Notebook weryfikuje SHA-256 kodu, źródeł i tabel przed ich użyciem.

Zewnętrzne początki 1990–2013 i 2019; wewnętrzne początki T−8, T−7, T−6; każdy oceniany na sześciu rocznych celach. Pięć konfiguracji ARIMA, dodatkowo dwie SARIMA dla częstotliwości 4 i 12. Nieudane dopasowania są jawnie odrzucane, a ponowne dopasowanie używa kolejności wewnętrznego MAE. Brak dopuszczalnej konfiguracji przerywa wykonanie. Lista kandydatów jest w `temperature/arima_selection.py`. Testy kontrolują dostępne daty i niezależność wyboru od przyszłych celów. Wnioski są opisowe; nie przeprowadzono testu istotności przewagi.

## Rozszerzenie częstotliwości — etap 2: benchmarki

`notebooks/03_frequency_forecasting.qmd` porównuje trzy częstotliwości skonstruowane z identycznych miesięcznych danych. Cel: średnia grudzień–listopad z równymi wagami miesięcy, nie źródłowy agregat roczny. `temperature/forecasting.py` zawiera konstrukcję reprezentacji, cztery benchmarki, walidację i metryki. Eksport: `.\.venv\Scripts\python.exe stories/globalne_ocieplenie/frequency_backtest.py`; wyniki w `results/frequency_backtest/`.

Protokół: początek 1962, rolling-origin 1990–2013, horyzonty 1–6 lat; późniejsza ocena 2020–2025 z nowego wydania przy treningu ze starego. Wybór wyłącznie na podstawie historycznego MAE, przy numerycznym remisie preferencja annual. Zapisano także wyniki wszystkich konfiguracji i ograniczenia w provenance.json. Testy obejmują brak przecieku przyszłości i równoważność agregacji dla seasonal naive oraz trendu z efektami okresu. ARIMA/SARIMA i zagnieżdżony dobór ich parametrów są zaimplementowane w etapie 3.

## Rozszerzenie częstotliwości — etap 1

Notebook `notebooks/02_monthly_seasonal_exploration.qmd` opisuje trendy miesięczne i sezonowe, zmienność reszt w trzech oknach po 19 lat i audyt agregacji obu zapisanych wydań FAOSTAT. Moduł `temperature/series.py` zawiera wspólny odczyt, walidację i kandydackie reguły agregacji. Dotychczasowe eksperymenty zachowują swoje obliczenia; migracja do wspólnych funkcji jest kolejnym etapem.

Odtworzenie: `.\.venv\Scripts\python.exe stories/globalne_ocieplenie/frequency_exploration.py`. Wyniki i SHA-256: `results/frequency_exploration/`. Testy granicy grudzień–listopad: `.\.venv\Scripts\python.exe -m unittest discover -s stories/globalne_ocieplenie/tests`.

Zakończone: kontrola pokrycia, jawny indeks miesięczny, rekonstrukcje equal-month/day-weight/equal-season, eksport trendów, zmienności i rewizji, rolling-origin oraz modele częstotliwości. Nadal otwarte: wyjaśnienie źródłowych rozbieżności agregacji i formalna ocena różnic trendów. Rekonstrukcje nie są deklaracją metodologii FAOSTAT. W porównaniu wspólny pierwszy pełny rok meteorologiczny to 1962, a granica treningu to listopad 2019. Grudzień 2019 należy do prognozowanego okresu 2020.

Raport: `globalne_ocieplenie_story.qmd`. Notebook `notebooks/01_temperature_change_analysis.qmd` jest analizą bazową: roczna seria FAOSTAT World bez imputacji. Obie podstrony są dostępne w projekcie „Temperatura — prognoza i rzeczywistość” z galerii Projektów. Data notebooka (2024-09-29) nie potwierdza wykonania prognozy w 2019 roku.

## Odtworzenie w StoryLab (PowerShell, katalog główny repozytorium)

```powershell
.\.venv\Scripts\python.exe stories/globalne_ocieplenie/temperature_backtest.py
$env:QUARTO_PYTHON = (Resolve-Path .venv/Scripts/python.exe).Path
quarto render stories/globalne_ocieplenie/globalne_ocieplenie_story.qmd
```

Quarto korzysta z istniejącego kernela `storylab`. Sprawdzone środowisko: pandas 3.0.1, numpy 2.4.2, matplotlib 3.10.8, statsmodels 0.14.6. Inne wersje optymalizatora mogą nieznacznie zmienić estymację ARIMA.

Skrypt zapisuje tabele w `results/` i sumy SHA-256 plików wejściowych w `results/provenance.json`. Raport oblicza wyniki ponownie; po zmianie danych należy uruchomić zarówno skrypt eksportujący, jak i renderowanie.

## Zakres eksperymentu

- Prognoza FAOSTAT odtwarza poprawny szereg z notebooka: World / Temperature change / Meteorological year, lata 1961–2019, ARIMA(2,1,2) bez drift. Eksport: `results/faostat_forecast.csv`.

- Właściwy test: jeden pakiet ERA5, trening 1940–2019, pięć prognoz bez aktualizacji, test 2020–2024. Porównanie naive, drift, regresji liniowej i ARIMA(2,1,2) bez trendu deterministycznego.
- Nie odejmujemy prognozy FAOSTAT z notebooka od ERA5 w celu oceny skuteczności: to różne zmienne. Nie twierdzimy, że holdout odtwarza informacje rzeczywiście dostępne w 2019 roku.
- Skrypt sprawdza ciągłość i długość szeregu ERA5, brak duplikatów region–rok, skończoność wyników oraz zbieżność estymacji. Nie zastępuje ARIMA innym modelem po błędzie.
- Pięcioletni test nie ustala trwałej przewagi metod. Wynik: MAE drift 0,141°C, naive 0,155°C, ARIMA 0,160°C, trend liniowy 0,298°C.

Test ERA5 zachowuje koniec w 2024 roku. Osobny audyt FAOSTAT obejmuje obserwacje 2020–2025 z pakietu pobranego 2026-09-22. Uruchom `python stories/globalne_ocieplenie/faostat_vintage_audit.py`, aby odtworzyć tabele rewizji i błędów w `results/faostat_*.csv` oraz metadane `results/faostat_audit.json`. Archiwum źródłowe: `data/faostat_latest.zip`; adres i SHA-256 zapisano w metadanych. Stary plik treningowy pozostaje niezmieniony. Zgodność kodów i definicji jest potwierdzona; pełna identyczność algorytmu między wydaniami nie została ustalona.
