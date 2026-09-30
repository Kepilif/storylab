# Weryfikacja integracji — 2026-09-16

- Źródło: `marketing_data_app_gitea`, commit `dd4006d4f7ccc8d153cafe1e6dcf89690b9469b1`.
- Skopiowano 108 plików źródłowych (konfigurację samodzielnego projektu zastąpiono
  konfiguracją główną i lokalnymi metadanymi). Zachowano wszystkie 21 stron QMD,
  20 slajdów prezentacji, tabele, wykresy, zrzuty Streamlit i archiwalny HTML.
- Z oryginalnego renderu notatnika przeniesiono komplet wyników 21 komórek i
  24 wykresy. Sprawdzono zgodność kodu każdej komórki. Kod i narracja pozostały
  niezmienione; dodano wyłącznie wyłączenie wykonania i include wyników.
- Zmiany pozostałych QMD ograniczają się do ustawień prezentacji, linków powrotu
  i objaśnień miejsc uruchamiania poleceń w rozdziałach aplikacji/reprodukcji.
- `quarto render` zakończyło się powodzeniem: 33 strony StoryLab. Po końcowej
  korekcie dziedziczonego spisu treści ponownie wyrenderowano prezentację.
- Kontrola HTML: **1313 lokalnych odwołań, 0 brakujących celów**, komplet navbarów
  i menu projektu. Raport zawiera **56 wystąpień obrazów i 50 tabel** zgodnie ze
  źródłowym renderem. Oryginalne akapity, nagłówki i zawartość komórek tabel
  pozostają obecne.
- Kontrola w przeglądarce: otwarto wszystkie 21 stron projektu, sprawdzono
  ładowanie obrazów, brak poziomego przepełnienia oraz przejścia z Projects i
  Dashboards do raportu. Obejrzano układ strony startowej, EDA, notatnika i
  prezentacji. Sprawdzono wszystkie 20 slajdów i ich osiem obrazów. Prezentacja
  pozostaje pełnoekranowym revealjs z linkami powrotu, pozostałe strony mają
  wspólną górną nawigację i menu boczne.
- Pełny render wymagał dodatkowo drobnej poprawki istniejącego raportu NBP:
  `to_numpy(copy=True)` zapobiega modyfikacji tablicy tylko do odczytu przy
  wyznaczaniu przerw na wykresie. Nie zmieniono danych ani narracji NBP.
- Przywrócono trzy historyczne, śledzone pliki HTML, które Quarto przenosi
  podczas renderowania; aktualnym wynikiem publikacyjnym jest `_site/`.
- Potwierdzono sumami SHA-256, że źródłowe `analysis` nie zostało zmienione.
  Zastane `stories/brudnopis/`, źródłowe `.agents/` i `skills-lock.json`
  pozostawiono bez zmian. Nie wykonano publikacji, commit ani push.

## Zakres i ograniczenia

Nie przeliczano pełnego zbioru e-commerce ani nie uruchamiano Streamlit.
Notatnik publikacyjny pokazuje zapisane wyniki; odświeżanie obliczeń, modele
i pipeline pozostają w repozytorium źródłowym. Nie dodano adresu demo.
Test odsyłaczy obejmuje lokalne cele, nie dostępność zewnętrznych serwisów.
Kontrola wizualna dotyczyła lokalnego widoku desktopowego, nie wdrożenia na serwer.

Powtarzalna kontrola: `verify_integration.py`; zasady dalszej edycji: `README.md`.
