# Wersja publikacyjna raportu e-commerce

Od 2026-09-16 StoryLab jest miejscem dalszej edycji narracji, struktury,
prezentacji i materiałów publikacyjnych tego raportu.

Źródło kopii: `marketing_data_app_gitea/analysis`.
Commit źródłowy: `dd4006d4f7ccc8d153cafe1e6dcf89690b9469b1`.
Katalog źródłowy pozostawiono bez zmian. `migration-manifest.json` zawiera
sumy SHA-256 wszystkich 108 plików źródłowych poza cache i wynikiem renderowania.

## Podział odpowiedzialności

- **StoryLab / stories/ecommerce_segmentation**: publikacyjna wersja raportu,
  wszystkie rozdziały, prezentacja, tabele, wykresy, zrzuty aplikacji i notatnik.
- **marketing_data_app_gitea**: aplikacja Streamlit, modele, środowisko obliczeń,
  dane surowe, pipeline i generowanie nowych artefaktów analitycznych.
- Kolejne poprawki tekstu wprowadzać tutaj. Nie synchronizować całego `analysis`
  automatycznie, ponieważ nadpisałoby to redakcję publikacyjną.
- Po przeliczeniu analizy w repozytorium źródłowym kopiować świadomie tylko
  zaktualizowane artefakty do `full_tables`, `full_figures`, `tables` i `figures`,
  sprawdzić ich zgodność z narracją, a następnie wyrenderować StoryLab.

## Renderowanie

Z katalogu głównego StoryLab: `quarto render`. Wynik znajduje się w `_site`.
Nie jest potrzebna instalacja Streamlit, modeli ani pełnego zbioru e-commerce.
Pozostałe raporty StoryLab nadal korzystają z własnych danych i zależności Python.
Główny `_quarto.yml` odpowiada za wspólną nawigację, render i sidebar projektu.
Lokalny `_metadata.yml` zachowuje ustawienia raportu. `slides.qmd` zachowuje
format revealjs i własny CSS.

Notatnik zachowuje wszystkie 21 komórek kodu i całą narrację. Render publikacyjny
ma `eval: false` i włącza zapisane wyniki z `notebooks/_outputs` oraz 24 obrazy
w `notebooks/notebook-assets`. Wyniki pobrano ze źródłowego renderu HTML po
sprawdzeniu zgodności kodu każdej komórki z QMD. To zapis wyników, nie ponowne
przeliczenie danych. Po zmianie kodu trzeba odtworzyć wyniki w środowisku źródłowym
i uaktualnić odpowiadające im pliki publikacyjne. Nie włączać obliczeń przy
pozostawionych include wyników, ponieważ dałoby to podwójne outputy.

Archiwalny `ecommerce_customer_segmentation.html` zachowano jako materiał źródłowy;
bieżącym punktem wejścia jest `index.qmd`.

Polecenia uruchomienia aplikacji i generowania danych w oryginalnych rozdziałach
dotyczą repozytorium `marketing_data_app_gitea`. Nie ma publicznego adresu demo.

## Kontrola integracji

Po renderowaniu, z głównego katalogu StoryLab:

```powershell
.\.venv\Scripts\python.exe stories\ecommerce_segmentation\verify_integration.py
```

Skrypt wymaga `beautifulsoup4` oraz lokalnej kopii źródłowego `analysis/_site`
do porównania treści. Sprawdza komplet plików, zachowanie narracji notatnika,
liczby tabel i obrazów, wspólną nawigację oraz lokalne odsyłacze i zasoby HTML.
Nie uruchamia aplikacji ani pipeline i nie publikuje wyników.
