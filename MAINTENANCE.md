# Budowanie i aktualizowanie StoryLab

Docelowa witryna: https://kepilif.github.io/storylab/. Autor: Jacek Filipek.

## Środowisko

Sprawdzana konfiguracja: Windows, Python 3.11.14, Quarto 1.8.27. Zamrożone zależności w `requirements.txt` obejmują również zależności przechodnie. Kernel jest rejestrowany w `.venv`, bez zmieniania globalnego kernela autora.

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m ipykernel install --prefix .venv --name storylab --display-name StoryLab
.\scripts\build.ps1
```

Podgląd po ustawieniu środowiska:

```powershell
$env:QUARTO_PYTHON = (Resolve-Path .venv\Scripts\python.exe).Path
$env:JUPYTER_PATH = (Resolve-Path .venv\share\jupyter).Path
quarto preview
```

Dokładny podgląd gotowego artefaktu z prefiksem GitHub Pages:

```powershell
.\.venv\Scripts\python.exe scripts/preview.py
```

Otwórz http://127.0.0.1:8766/storylab/. Zatrzymaj serwer przez Ctrl+C.

## Cykl aktualizacji

1. Edytuj źródła `.qmd`, katalogi `portfolio/*.yml` i style. Sprawdź okres danych oraz źródła przy zmienianych wnioskach.
2. Odśwież dane tylko wtedy, gdy zadanie tego wymaga. Dług: `scripts/build.ps1 -RefreshDebt`, na podstawie aktualnego, udokumentowanego XLSX. World Bank nie ma wartości liczbowych dla Polski w zachowanej serii; nie publikujemy pustego wykresu ani zer.
3. NBP: raporty są niegotowe i wyłączone z publikacji oraz tego repozytorium. Nie przywracaj ich bez decyzji autora.
4. Klimat: standardowy build sprawdza integralność, odczytuje zachowane wyniki i wykonuje komórki prezentacyjne. Nie uruchamiaj eksportów `frequency_*.py`, `temperature_backtest.py` ani `faostat_vintage_audit.py` w celu zwykłej publikacji. Nowe badanie wymaga osobnego katalogu eksperymentu; nie aktualizuj manifestu, aby obejść błąd integralności.
5. Uruchom `scripts/build.ps1`. Każdy build tworzy świeży wynik i kontroluje lokalne odsyłacze, obrazy, nazwy plików oraz indeks wyszukiwania. Raport: `docs/site-validation.json`.
6. Obejrzyj Start, Projekty, Blog, galerie oraz każdą zmienioną historię na komputerze i w wąskim widoku telefonu. Sprawdź menu, wyszukiwanie frazy, wykresy oraz pobranie CSV/PDF/Tableau. Odsyłacze zewnętrzne i Tableau wymagają internetu.
7. Sprawdź `git status --short`, `git diff --check`, różnice danych i `public/`. Po `git add .` uruchom `.venv/Scripts/python.exe scripts/check_release.py`: sprawdza kompletność i bajty plików publikacji w indeksie Git. Commituj źródła oraz gotowy `public/` razem. Nie commituj `.venv` ani `_site`.
8. Po uzyskaniu zgody na pierwszą publikację wyślij commit do `main`. W GitHub Settings → Pages wybierz GitHub Actions. W Actions uruchom ręcznie workflow „Publish reviewed portfolio”. Sprawdź zakończenie wdrożenia i publiczny adres. Sam push nie uruchamia wdrożenia.

## Sposób publikacji

Quarto budujemy lokalnie, a `public/` jest sprawdzonym artefaktem danego commitu. GitHub Actions jedynie wdraża ten katalog, zgodnie z [dokumentacją GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages). Nie wymaga drugiego środowiska Python ani zmiany zamrożonych manifestów zapisanych ze ścieżkami Windows. Workflow wdrożenia należy zweryfikować po pierwszym autoryzowanym wysłaniu; lokalny test nie potwierdza konfiguracji konta GitHub.

## Co wersjonować

Zostaw źródła, surowe dane używane przez raporty, tabele i obrazy e-commerce/NBA, dane i wyniki klimatu z manifestami, odtworzone tabele i wykresy długu. Zostaw dokumentację pochodzenia i ograniczeń. `public/` zawiera gotową witrynę, `.nojekyll` wyłącza przetwarzanie Jekyll.

Ignoruj środowiska, `.quarto`, `_site`, katalogi `*_files`, checkpointy, logi, pliki tymczasowe oraz robocze publikacje pipeline'u NBP. Wycofane strony nie należą do listy renderowania ani świeżego wyniku.

Nowa historia Git zaczyna się jednym commitem. Pochodzenie źródeł (`f6ca19c`) jest dokumentowane, bez importowania starej historii i remote. Dane zewnętrzne zachowują warunki dostawców; nie nadawaj zbiorom automatycznie licencji kodu.
