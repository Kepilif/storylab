# StoryLab

**Portfolio analiz danych i data storytellingu.**

StoryLab łączy przygotowanie danych, analizę i wizualizację z narracją prowadzącą od pytania do wniosków. Raporty przedstawiają wyniki, zastosowane metody oraz ograniczenia interpretacji.

🌐 **[Zobacz portfolio](https://kepilif.github.io/storylab/)**

## Projekty i historie

- **Segmentacja klientów e-commerce** — zachowania zakupowe, RFM, analiza koszykowa i segmentacja klientów.
- **NBA Scouting Patterns** — eksploracja profili zawodników, wieku i ścieżek pochodzenia.
- **Temperatura — prognoza i rzeczywistość** — trendy temperatury, szeregi czasowe i ocena prognoz.
- **Polski dług publiczny** — porównanie PDP i EDP oraz interpretacja zmian zadłużenia.

Galeria wizualizacji zawiera również wybrane publikacje Tableau Public.

Poszczególne materiały mają różny zakres i etap rozwoju. Raporty wskazują okres danych, źródła i ograniczenia; nie wszystkie opisują bieżący stan analizowanego zjawiska.

## Technologie

Python · pandas · NumPy · statsmodels · SQL · Matplotlib · Plotly · Tableau · Jupyter · Quarto · Git

## Struktura repozytorium

- `_quarto.yml` — konfiguracja witryny i lista publikowanych stron.
- Główne pliki `.qmd` — Start, Projekty, Blog, Wizualizacje i O mnie.
- `portfolio/` — katalogi projektów, historii i wizualizacji.
- `stories/` — źródła raportów, dane, skrypty, notebooki i dokumentacja.
- `assets/` — style oraz grafiki wspólne dla witryny.
- `_site/` — wygenerowana witryna HTML.
- `public/` — sprawdzona witryna przeznaczona do wdrożenia.
- `scripts/` — budowanie i kontrola integralności oraz odsyłaczy.

## Praca lokalna

Witryna jest budowana w Quarto. Raporty wykonujące kod Python wymagają środowiska z zależnościami projektu oraz kernela Jupyter `storylab`.

Niektóre raporty korzystają z tabel i wykresów przygotowanych wcześniej przez pipeline danej historii. Szczegółowe instrukcje znajdują się w jej katalogu.

Sprawdzone środowisko: **Python 3.11.14**, **Quarto 1.8.27**, Windows. Zależności są przypięte w `requirements.txt`. Instalacja i pełne budowanie:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m ipykernel install --prefix .venv --name storylab --display-name StoryLab
.\scripts\build.ps1
```

Podgląd lokalny:

```powershell
$env:QUARTO_PYTHON = (Resolve-Path .venv\Scripts\python.exe).Path
$env:JUPYTER_PATH = (Resolve-Path .venv\share\jupyter).Path
quarto preview
```

Wynik renderowania trafia do `_site/`.

## Publikacja

Budowanie jest lokalne. Ręcznie uruchamiany workflow GitHub Actions wdraża sprawdzony katalog `public/`. Sam push nie publikuje witryny. Przed pierwszym wysłaniem i wdrożeniem wymagana jest zgoda autora. Konfiguracja Pages oraz cykl aktualizacji są opisane w [instrukcji utrzymania](MAINTENANCE.md).

## Dane i odtwarzalność

Źródła, definicje wskaźników i zakres czasowy opisano w poszczególnych raportach. Dane zewnętrzne podlegają zasadom ich dostawców; obecność pliku w repozytorium nie nadaje mu odrębnej licencji.

Klimat korzysta z FAOSTAT i Copernicus; dług z zapisanych danych Ministerstwa Finansów; NBA i e-commerce dokumentują pochodzenie w swoich raportach. Wyniki i manifesty klimatyczne są kontrolowane przez SHA-256. Publikacja nie uruchamia eksportów eksperymentów.

Porównania między wydaniami danych lub wersjami bibliotek mogą wymagać ponownej weryfikacji wyników. Braki danych nie są interpretowane jako wartości zerowe.

## Kontakt

- E-mail: [jacek.filipek@gmail.com](mailto:jacek.filipek@gmail.com)
- [GitHub](https://github.com/Kepilif/)
- [LinkedIn](https://www.linkedin.com/in/kepilif/)
- [Tableau Public](https://public.tableau.com/app/profile/jacek.filipek/)
- [GitLab](https://gitlab.com/kepilif/)
