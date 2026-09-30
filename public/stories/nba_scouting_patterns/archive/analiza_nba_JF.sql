/*
Analiza graczy NBA

Dane: https://www.kaggle.com/datasets/justinas/nba-players-data
Cel: zbadanie tendencji w rozwoju kariery koszykarzy w odniesieniu do ich cech fizycznych oraz miejsca urodzenia
Stakeholder: członek zespołu scoutingowego w jednym z klubów NBA, który szuka wzorców na potrzeby nadchodzącego draftu

autor: Jacek Filipek

Miniprojekt znajduje się w dwóch plikach:
* analiza_nba_JF.pdf - zawiera wizualizacje oraz analizę
* analiza_nba_JF.sql - zawiera fragmenty danych, analizę oraz stukturę zapytań sql
* interaktywna wizualizacja pod linkiem: https://public.tableau.com/views/NBA_JF/Rozkadpunktw
*/

-- Podstawowe informacje o kolumnach i typach danych
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'all_seasons';

/*
column_name      |data_type        |
-----------------+-----------------+
Column1          |integer          |
player_name      |character varying|
team_abbreviation|character varying|
age              |real             |
player_height    |real             |
player_weight    |real             |
college          |character varying|
country          |character varying|
draft_year       |character varying|
draft_round      |character varying|
draft_number     |character varying|
gp               |integer          |
pts              |real             |
reb              |real             |
ast              |real             |
net_rating       |real             |
oreb_pct         |real             |
dreb_pct         |real             |
usg_pct          |real             |
ts_pct           |real             |
ast_pct          |real             |
season           |character varying|
*/

/*
Odszyfrowanie skrótów używanych w statystykach NBA:

1. draft_year: Oznacza rok, w którym zawodnik został wybrany w drafcie NBA.
2. draft_round: Określa rundę, w której zawodnik został wybrany. Pierwsza runda to zazwyczaj wybór graczy o większym potencjale, a druga runda to wybór późniejszych talentów.
3. draft_number: Numer wyboru w drafcie. Im niższy numer, tym zawodnik został wybrany wcześniej.
4. gp: Oznacza liczbę rozegranych przez zawodnika meczów (ang. games played).
5. pts: Punkty zdobyte przez zawodnika na mecz (ang. points per game).
6. reb: Średnia liczba zbiórek na mecz (ang. rebounds per game).
7. ast: Średnia liczba asyst na mecz (ang. assists per game).
8. net_rating: Ocenia efektywność zawodnika w kontekście wyników drużyny podczas jego obecności na boisku.
9. oreb_pct: Procent ofensywnych zbiórek (ang. offensive rebound percentage).
10. dreb_pct: Procent defensywnych zbiórek (ang. defensive rebound percentage).
11. usg_pct: Procent wykorzystania zawodnika w ataku (ang. usage percentage).
12. ts_pct: Procent efektywności rzutów (ang. true shooting percentage).
13. ast_pct: Procent udziału zawodnika w asystach (ang. assist percentage).
14. season: Oznacza sezon, w którym dane statystyki były zbierane.
*/

-- Pierwsze dziesięć wierszy
SELECT * FROM all_seasons LIMIT 10;

/*
Column1|player_name     |team_abbreviation|age |player_height|player_weight|college              |country|draft_year|draft_round|draft_number|gp|pts |reb|ast|net_rating|oreb_pct|dreb_pct|usg_pct|ts_pct|ast_pct|season |
-------+----------------+-----------------+----+-------------+-------------+---------------------+-------+----------+-----------+------------+--+----+---+---+----------+--------+--------+-------+------+-------+-------+
      0|Randy Livingston|HOU              |22.0|       193.04|     94.80073|Louisiana State      |USA    |1996      |2          |42          |64| 3.9|1.5|2.4|       0.3|   0.042|   0.071|  0.169| 0.487|  0.248|1996-97|
      1|Gaylon Nickerson|WAS              |28.0|        190.5|     86.18248|Northwestern Oklahoma|USA    |1994      |2          |34          | 4| 3.8|1.3|0.3|       8.9|    0.03|   0.111|  0.174| 0.497|  0.043|1996-97|
      2|George Lynch    |VAN              |26.0|        203.2|   103.418976|North Carolina       |USA    |1993      |1          |12          |41| 8.3|6.4|1.9|      -8.2|   0.106|   0.185|  0.175| 0.512|  0.125|1996-97|
      3|George McCloud  |LAL              |30.0|        203.2|     102.0582|Florida State        |USA    |1989      |1          |7           |64|10.2|2.8|1.7|      -2.7|   0.027|   0.111|  0.206| 0.527|  0.125|1996-97|
      4|George Zidek    |DEN              |23.0|       213.36|    119.74829|UCLA                 |USA    |1995      |1          |22          |52| 2.8|1.7|0.3|     -14.1|   0.102|   0.169|  0.195|   0.5|  0.064|1996-97|
      5|Gerald Wilkins  |ORL              |33.0|       198.12|     102.0582|Tennessee-Chattanooga|USA    |1985      |2          |47          |80|10.6|2.2|2.2|      -5.8|   0.031|   0.064|  0.203| 0.503|  0.143|1996-97|
      6|Gheorghe Muresan|WAS              |26.0|       231.14|    137.43837|None                 |USA    |1993      |2          |30          |73|10.6|6.6|0.4|       6.9|   0.098|   0.217|  0.185| 0.618|  0.024|1996-97|
      7|Glen Rice       |CHH              |30.0|        203.2|     99.79024|Michigan             |USA    |1989      |1          |4           |79|26.8|4.0|2.0|       3.2|   0.025|   0.087|  0.272| 0.605|  0.088|1996-97|
      8|Glenn Robinson  |MIL              |24.0|       200.66|    106.59412|Purdue               |USA    |1994      |1          |1           |80|21.1|6.3|3.1|      -2.9|   0.051|   0.144|  0.278| 0.528|  0.146|1996-97|
      9|Grant Hill      |DET              |24.0|        203.2|     102.0582|Duke                 |USA    |1994      |1          |3           |80|21.4|9.0|7.3|       6.9|   0.049|   0.232|  0.283| 0.556|  0.356|1996-97|
*/

-- Ostatnie dziesięć wierszy
SELECT * FROM all_seasons ORDER BY "Column1" DESC LIMIT 10;

/*
Column1|player_name    |team_abbreviation|age |player_height|player_weight|college      |country  |draft_year|draft_round|draft_number|gp|pts |reb |ast|net_rating|oreb_pct|dreb_pct|usg_pct|ts_pct|ast_pct|season |
-------+---------------+-----------------+----+-------------+-------------+-------------+---------+----------+-----------+------------+--+----+----+---+----------+--------+--------+-------+------+-------+-------+
  12843|JaMychal Green |GSW              |33.0|       205.74|   102.965385|Alabama      |USA      |Undrafted |Undrafted  |Undrafted   |57| 6.4| 3.6|0.9|      -8.2|   0.087|   0.164|  0.169|  0.65|  0.094|2022-23|
  12842|Jericho Sims   |NYK              |24.0|       208.28|      113.398|Texas        |USA      |2021      |2          |58          |52| 3.4| 4.7|0.5|      -6.7|   0.117|   0.175|  0.074|  0.78|  0.044|2022-23|
  12841|John Collins   |ATL              |25.0|       205.74|   102.511795|Wake Forest  |USA      |2017      |1          |19          |71|13.1| 6.5|1.2|      -0.2|   0.035|    0.18|  0.168| 0.593|  0.052|2022-23|
  12840|John Butler Jr.|POR              |20.0|       213.36|     86.18248|Florida State|USA      |Undrafted |Undrafted  |Undrafted   |19| 2.4| 0.9|0.6|     -16.1|   0.012|   0.065|  0.102| 0.411|  0.066|2022-23|
  12839|Joel Embiid    |PHI              |29.0|       213.36|    127.00576|Kansas       |Cameroon |2014      |1          |3           |66|33.1|10.2|4.2|       8.8|   0.057|   0.243|   0.37| 0.655|  0.233|2022-23|
  12838|Joe Wieskamp   |TOR              |23.0|       198.12|     92.98636|Iowa         |USA      |2021      |2          |41          | 9| 1.0| 0.4|0.3|       1.0|     0.0|   0.068|  0.115| 0.321|  0.083|2022-23|
  12837|Joe Ingles     |MIL              |35.0|       205.74|     99.79024|None         |Australia|Undrafted |Undrafted  |Undrafted   |46| 6.9| 2.8|3.3|       2.5|   0.012|   0.102|  0.122| 0.616|  0.181|2022-23|
  12836|Joe Harris     |BKN              |31.0|       198.12|     99.79024|Virginia     |USA      |2014      |2          |33          |74| 7.6| 2.2|1.4|      -1.0|   0.016|   0.089|  0.141| 0.621|  0.091|2022-23|
  12835|Jock Landale   |PHX              |27.0|       210.82|    115.66596|St. Mary's   |Australia|Undrafted |Undrafted  |Undrafted   |69| 6.6| 4.1|1.0|       7.9|   0.114|   0.164|  0.182| 0.595|  0.101|2022-23|
  12834|Jimmy Butler   |MIA              |33.0|       200.66|    104.32616|Marquette    |USA      |2011      |1          |30          |64|22.9| 5.9|5.3|       1.2|   0.068|   0.121|  0.248| 0.647|  0.264|2022-23|
*/

-- Policz liczbę rekordów
SELECT COUNT(*) player_name FROM all_seasons;

/*
player_name|
-----------+
      12844|
*/

-- Policz unikalnych graczy z kolumny player_name
SELECT COUNT(DISTINCT player_name) FROM all_seasons;

/*
count|
-----+
 2551|
*/

-- Policz unikalne drużyny z kolumny team_abbreviation
SELECT COUNT(DISTINCT team_abbreviation) FROM all_seasons;

/*
count|
-----+
   36|
*/

-- Policz unikalne uczelnie z kolumny college
SELECT COUNT(DISTINCT college) FROM all_seasons;
/*
count|
-----+
  357|
*/


-- Policz unikalne kraje z kolumny country
SELECT COUNT(DISTINCT country) FROM all_seasons;

/*
count|
-----+
   82|
*/

-- Policz liczbę sezonów
SELECT COUNT(DISTINCT season) FROM all_seasons;

/*
count|
-----+
   27|
*/

/*

1.1 Podstawowa analiza i wnioski:
Dane zawierają informacje o 12,844 rekordach zawodników z różnych sezonów NBA. Te rekordy reprezentują 2551 unikalnych zawodników, co oznacza, że wielu zawodników występuje w więcej niż jednym sezonie.
W danych znajduje się 36 unikalnych drużyn. To wskazuje, że niektóre drużyny mogły zmieniać nazwy lub lokalizacje w trakcie lat.
Dane obejmują 357 unikalnych uczelni, co pokazuje szerokie spektrum miejsc, z których pochodzą zawodnicy NBA.
Dane obejmują zawodników z 82 różnych krajów, co wskazuje na międzynarodowy charakter NBA i różnorodność pochodzenia zawodników.
Dane obejmują 27 unikalnych sezonów, co daje możliwość analizy zmian i trendów na przestrzeni czasu.

1.2. Potencjalne analizy
Trendy czasowe:
- Trendy demograficzne, takie jak wiek, wzrost lub waga
- Trendy wydajności zawodników na przestrzeni lat
- Trendy wydajności w zależności od wieku
Wpływ uczelni:
- Analiza, które uczelnie trenują najbardziej wydajnych zawodników NBA
Międzynarodowy wpływ:
- Analiza wydajności zawodników z różnych krajów i ich wpływ na NBA
Trendy statystyczne:
- Korelacja wskaźników wydajności
- Analiza trendów statystycznych
- Analiza poszczególnych drużyn
*/
/*

1.3 Trendy czasowe
1.3.1 Trendy demograficzne zawodników
Zmiany w demografii zawodników, takie jak wiek, wzrost średniej wagi lub wzrostu
*/

-- Oblicz średni wiek, wzrost i wagę zawodników dla każdego sezonu.

SELECT
    season,
    AVG(age) AS avg_age,
    AVG(player_height) AS avg_height,
    AVG(player_weight) AS avg_weight
FROM
    all_seasons
GROUP BY
    season
ORDER BY
    season;

/*
season |avg_age           |avg_height        |avg_weight        |
-------+------------------+------------------+------------------+
1996-97| 27.96371882086168|200.99483104195454| 100.5262701938482|
1997-98|28.084282460136674| 200.6194996757768|100.26552978897963|
1998-99|28.002277904328018|200.90300769849355|100.63956228095469|
1999-00| 28.10730593607306|200.92095999521752|100.73574093161108|
2000-01| 28.09750566893424|200.75215526070454|100.84244989754121|
2001-02|27.672727272727272|201.01791017705744|101.28812451796098|
2002-03|  27.5303738317757|201.52051512103213|102.03276498741079|
2003-04|27.457013574660632|201.31511436220748|101.63539487743809|
2004-05| 27.29741379310345|201.24573368861758|101.69747697895971|
2005-06|26.890829694323145|200.92065606263006|101.34017762763011|
2006-07|26.858078602620086| 200.7043678916698|101.32928338529761|
2007-08| 27.19290465631929|200.85148671355321|100.94182028421541|
2008-09|  26.9438202247191| 201.1965405067701|101.39361119645365|
2009-10|27.079185520361992|200.87339468563303|101.14034076190103|
2010-11|27.134955752212388|201.21783288601225| 101.6340219784627|
2011-12|27.089958158995817|200.83234408709794|101.05508649498847|
2012-13|27.066098081023455| 200.7697662809002|100.87277821945483|
2013-14| 26.96265560165975|200.77294690777157|100.54959103279589|
2014-15| 26.98170731707317|200.83845603756788|100.43821302274378|
2015-16| 27.05252100840336| 200.9490342981675|100.41402206100335|
2016-17|26.847736625514404|200.91679071497035| 99.83093040372118|
2017-18|26.524074074074075|200.45774100974754|  98.8116569519043|
2018-19|26.350943396226416|200.53539644637198| 98.57067629256339|
2019-20|26.005671077504726|198.94105875920258| 98.53150050085749|
2020-21|25.994444444444444| 198.9149260626899|  98.2404670715332|
2021-22| 26.16694214876033|198.35090917161673| 97.33634449351918|
2022-23|26.150278293135436| 199.2651207522249| 97.82860156114114|
*/

/*
   
Średni wzrost zawodników (avg_height): - Średni wzrost zawodników utrzymywał się na stabilnym poziomie z lekkim trendem spadkowym w ostatnich sezonach. W sezonie 1996-97 wynosił około 201 cm, a w sezonie 2022-23 wynosił około 199 cm. - Może to sugerować zmianę preferencji na nieco niższych, ale bardziej wszechstronnych zawodników.

Średnia waga zawodników (avg_weight): - Średnia waga zawodników wykazuje trend spadkowy, zwłaszcza w ostatnich sezonach. W sezonie 1996-97 wynosiła około 100.53 kg, a w sezonie 2022-23 wynosiła około 97.83 kg. - Może to wskazywać na większy nacisk na zwinność i szybkość kosztem masy ciała.

Średni wiek zawodników (avg_age): - Średni wiek zawodników utrzymuje się na stabilnym poziomie, z lekkim spadkiem w ostatnich sezonach. W sezonie 1996-97 wynosił około 27.96 lat, a w sezonie 2022-23 wynosił około 26.15 lat. - Może to sugerować wprowadzenie większej liczby młodszych zawodników do ligi, co może wpływać na dynamikę gry.

Ogólne wnioski
• Wzrost wydajności ofensywnej: Średnia liczba punktów i asyst na grę wzrasta, co może sugerować, że gra staje się bardziej ofensywna i zespołowa.
• Zmiany w profilu fizycznym zawodników: Obserwujemy lekki spadek średniego wzrostu i wagi, co może wskazywać na zmiany w preferencjach fizycznych zawodników, z większym naciskiem na szybkość i zwinność.
• Młodsze zespoły: Lekki spadek średniego wieku zawodników może sugerować, że liga wprowadza więcej młodszych graczy, co może wpływać na tempo i styl gry.

Dalsze potencjalne analizy
• Analiza przyczyn zmian: Warto przeanalizować przyczyny wzrostu wydajności ofensywnej i zmiany demograficzne. Czy są one wynikiem zmian w strategii gry, treningu, czy może innowacji technologicznych?
• Dalsze badania: Można przeprowadzić bardziej szczegółowe analizy, np. jak te zmiany wpływają na wyniki zespołów lub jak różnią się trendy w różnych pozycjach zawodników (np.porównanie centrów z rozgrywającymi).
*/

/*
1.3.2 Trendy w wydajności zawodników
Analiza jak zmieniała się wydajność zawodników na przestrzeni lat.
*/

SELECT
    season,
    AVG(pts) AS avg_pts,
    AVG(reb) AS avg_reb,
    AVG(ast) AS avg_ast
FROM
    all_seasons
GROUP BY
    season
ORDER BY
    season;

/*   
season |avg_pts           |avg_reb           |avg_ast           |
-------+------------------+------------------+------------------+
1996-97| 8.026077116917726|3.5464852654339234|1.8210884356140549|
1997-98|  7.94760820928087| 3.516400918534242|1.8198177661229102|
1998-99| 7.358542145282913|  3.42141229958021|1.6537585419545413|
1999-00|7.9858447654878715|3.6520548027570117|1.8513698652046455|
2000-01| 7.811337893647131| 3.619047618540777|1.8235827699945628|
2001-02| 7.982727280123667| 3.633636366779154|1.8411363633010875|
2002-03| 7.849299068762877| 3.593691588335923|1.7829439244363632|
2003-04|7.7454751290852935| 3.583484161999161|1.7585972855668262|
2004-05| 8.088146565771051| 3.577801716192786| 1.774137932903551|
2005-06| 7.982532767489487|3.4834061169988724|  1.68908296797148|
2006-07| 8.208733612012654| 3.503056766343299|1.7661572096942555|
2007-08| 8.267184041622208|3.5780487709622952|1.8188470130220484|
2008-09|   8.5038202028596|3.6200000014532816|1.7719101108359487|
2009-10| 8.571719473505992| 3.657692302406104|1.8049773768062505|
2010-11| 8.206194688096247|3.5539822960519687| 1.767699112209071|
2011-12| 7.928870309362476|  3.56255230080009|1.7462343101596234|
2012-13| 7.957995738842086|3.5223880589548457|1.8085287840985287|
2013-14| 8.090248972733981|3.5238589195233163| 1.780497929460033|
2014-15| 8.122560970666932| 3.543292677378267|1.8195121908575538|
2015-16| 8.349369751680799|3.6205882344927107|1.8262605033345332|
2016-17| 8.426748973750529| 3.565226340214166|1.8302469127830654|
2017-18| 8.160370386805798| 3.377592593845394|1.8175925961523145|
2018-19| 8.613584903051269| 3.613207543767848| 1.921509435294934|
2019-20| 8.726465043983298| 3.632703210334584|1.9236294898452742|
2020-21|  8.94240740078191|3.6350000024807674|1.9875925931803606|
2021-22| 8.240000007172261|3.4469421496938084|1.8682644617212705|
2022-23| 9.121335803633055|  3.54322820130549| 2.068831167783388|*/

/*

Średnia liczba punktów na grę (avg_pts): - Wzrost średniej liczby punktów na grę na przestrzeni lat, zwłaszcza w ostatnich sezonach. Wartość ta rośnie od 1996-97, osiągając najwyższą wartość w sezonie 2022-23 (9.12 punktów).1 - Może to sugerować, że gra staje się bardziej ofensywna, z większym naciskiem na zdobywanie punktów.

Średnia liczba zbiórek na grę (avg_reb): - Względna stabilność średniej liczby zbiórek na grę na przestrzeni lat, z lekkimi wahaniami. Najniższą wartość odnotowano w sezonie 2017-18 (3.38), a najwyższą w sezonie 2020-21 (3.64). - To może wskazywać na stałe znaczenie zbiórek w grze, mimo zmian w innych aspektach gry.

Średnia liczba asyst na grę (avg_ast): - Również wzrost średniej liczby asyst na grę, szczególnie widoczny w ostatnich sezonach. Najwyższa wartość w sezonie 2022-23 (2.07 asysty). - Może to sugerować większy nacisk na grę zespołową i rozgrywanie piłki.

1.3.3 Trendy wydajności w zależności od wieku
Analiza jak zmienia się wydajność zawodników z upływem lat
*/

-- Trendy wydajności w zależności od wieku
SELECT
    CASE 
        WHEN age BETWEEN 18 AND 19 THEN '18-19'
        WHEN age BETWEEN 20 AND 21 THEN '20-21'
        WHEN age BETWEEN 22 AND 23 THEN '22-23'
        WHEN age BETWEEN 24 AND 25 THEN '24-25'
        WHEN age BETWEEN 26 AND 27 THEN '26-27'
        WHEN age BETWEEN 28 AND 29 THEN '28-29'
        WHEN age BETWEEN 30 AND 31 THEN '30-31'
        WHEN age BETWEEN 32 AND 33 THEN '32-33'
        WHEN age BETWEEN 34 AND 35 THEN '34-35'
        WHEN age BETWEEN 36 AND 37 THEN '36-37'
        WHEN age BETWEEN 38 AND 39 THEN '38-39'
        WHEN age BETWEEN 40 AND 41 THEN '40-41'
        WHEN age BETWEEN 42 AND 43 THEN '42-43'
        WHEN age BETWEEN 44 AND 45 THEN '44-45'
    END AS age_group,
    AVG(ast) AS avg_ast,
    AVG(pts) AS avg_pts,
    AVG(reb) AS avg_reb
FROM
    all_seasons
WHERE
    age BETWEEN 18 AND 44
GROUP BY
    age_group
ORDER BY
    age_group;

/*
age_group|avg_ast            |avg_pts           |avg_reb           |
---------+-------------------+------------------+------------------+
18-19    | 1.2341772204712977| 6.553164525877071|3.1126582237738596|
20-21    | 1.5659624441513713| 7.705516431340729|  3.42476525628161|
22-23    | 1.5167567573359615| 7.474938586676443|3.2321375912069104|
24-25    | 1.6513053820044086| 7.873931978708369|3.3952136069176646|
26-27    | 1.9417068479455137| 9.008244944170563|3.7698167784205974|
28-29    |  2.062089201010449| 9.288908457899458|3.9120892045031272|
30-31    |  2.075144505811952| 8.861994223658405| 3.801806359298829|
32-33    |  2.054995149128305| 8.102521822636968|3.5719689583237835|
34-35    | 2.0001602582394695| 7.520192296005403|3.5360576923793325|
36-37    | 1.9205797099332877| 6.957971006135145| 3.390724636376768|
38-39    | 1.6879432610374816| 5.917021258185941|3.2156028398808014|
40-41    | 1.5736842012326968| 5.068421046984823|2.5973684176018366|
42-43    | 0.3875000076368451| 3.787500023841858|2.7124999463558197|
44-45    |0.20000000298023224|2.4000000953674316| 1.600000023841858|
*/
/*

1. **Średnie asysty**: Widać, że średnia liczba asyst zwiększa się stopniowo od wieku 18 do około 34 lat, po czym utrzymuje się na stałym poziomie do wieku 30 lat, a następnie maleje.
2. **Średnie punkty**: Średnia liczba punktów również rośnie od wieku 18 do około 30 lat, osiągając szczyt w wieku 28 lat, po czym zaczyna spadać.
3. **Średnie zbiórki**: Średnia liczba zbiórek ma podobny trend do punktów, rosnąc do wieku 28 lat, po czym pozostaje na stałym poziomie do wieku 32 lat, a następnie maleje.

Te trendy wskazują, że zawodnicy osiągają swoją maksymalną wydajność w zakresie wiekowym 28-32 lat, po czym ich wydajność stopniowo spada. Może to być związane z doświadczeniem, kondycją fizyczną oraz innymi czynnikami wpływającymi na ich grę.
*/
   
/*
1.4 Wpływ uczelni
Analiza, które uczelnie trenują najbardziej wydajnych zawodników NBA
*/

-- Liczba graczy z uczelni
WITH college_stats AS (
    SELECT 
        college,
        COUNT(*) AS player_count,
        AVG(pts) AS avg_pts,
        AVG(reb) AS avg_reb,
        AVG(ast) AS avg_ast
    FROM 
        all_seasons
    WHERE 
        college IS NOT NULL AND college != ''
    GROUP BY 
        college
)
SELECT 
    college,
    player_count,
    avg_pts,
    avg_reb,
    avg_ast
FROM 
    college_stats
WHERE 
    player_count >= 10
ORDER BY 
    avg_pts DESC, avg_reb DESC, avg_ast DESC
LIMIT 10;  -- Limit 10 dla najbardziej wydajnych uczelni
   
/*
college                 |player_count|avg_pts           |avg_reb           |avg_ast           |
------------------------+------------+------------------+------------------+------------------+
Davidson                |          17|20.199999781215894|4.0588235504486985| 5.294117664589601|
Lehigh                  |          10|18.660000038146972|3.4400000095367433| 3.589999979734421|
Western Carolina        |          13| 16.05384643261249| 3.053846139174241|  1.83076922251628|
Weber State             |          22| 14.12727273052389| 2.640909093347463|3.9590909243984655|
Butler Community College|          14| 13.58571445941925|3.5857142891202654|2.7928571105003357|
Louisiana Tech          |          38|13.263157963752747| 7.318421076787145|2.2736842020561823|
Santa Clara             |          20|12.979999959468842|2.8899999856948853| 7.550000002980232|
Rhode Island            |          31|12.103225915662703| 5.209677403492313| 2.851612888997601|
Saint Louis             |          15|12.073333342870077|3.9600000301996867|2.6466666718324023|
Hartford                |          10|11.660000157356261|  5.70999995470047|1.3300000101327896|
*/

/*
Najbardziej Punktujący Zawodnicy
• Davidson: Średnia punktów na mecz (20.2) jest najwyższa spośród wszystkich wymienionych uczelni, co może wskazywać, że Davidson trenuje zawodników, którzy są skuteczni w zdobywaniu punktów. Stephen Curry, znany zawodnik NBA, pochodzi właśnie z Davidson.
• Lehigh: Średnia punktów na mecz (18.66) jest również bardzo wysoka, co sugeruje, że zawodnicy z Lehigh są także bardzo skuteczni w ofensywie.

Wszechstronność Zawodników
• Santa Clara: Zawodnicy z Santa Clara mają najwyższą średnią asyst na mecz (7.55), co wskazuje na dobrą grę zespołową i zdolności do kreowania sytuacji punktowych dla innych zawodników. Steve Nash, dwukrotny MVP NBA, pochodzi z Santa Clara, co może wpływać
na wysoką średnią asyst.
• Davidson: Oprócz najwyższej średniej punktów, Davidson ma również wysoką średnią asyst (5.29), co sugeruje, że zawodnicy z tej uczelni są wszechstronni i potrafią zarówno zdobywać punkty, jak i wspierać swoich kolegów z drużyny.

Dominujący na Zbiórkach
• Louisiana Tech: Średnia zbiórek na mecz (7.32) jest najwyższa, co sugeruje, że zawodnicy z tej uczelni są skuteczni w defensywie i potrafią dominować pod tablicami.
• Rhode Island: Średnia zbiórek na mecz (5.21) jest również wysoka, co wskazuje na dobrą zdolność do zbierania piłek zarówno w defensywie, jak i ofensywie.

Ogólne Wnioski
1. Davidson i Lehigh wyróżniają się jako uczelnie trenujące bardzo skutecznych strzelców. Wysokie średnie punkty na mecz sugerują, że zawodnicy z tych uczelni są dobrze przygotowani do ofensywnej gry w NBA.
2. Santa Clara trenuje zawodników, którzy są bardzo wszechstronni i potrafią dobrze rozgrywać, co jest istotne dla pozycji rozgrywającego.
3. Louisiana Tech i Rhode Island wyróżniają się w kontekście zbiórek, co może wskazywać na dobrą grę defensywną i siłę fizyczną zawodników z tych uczelni.
4. Weber State i Butler Community College mają zawodników, którzy są wszechstronni, ale nie dominują w żadnej z pojedynczych kategorii tak mocno jak najlepsze uczelnie w każdej z nich.

Dalsza Analiza Można przeprowadzić bardziej szczegółową analizę, aby uwzględnić inne ważne metryki, takie jak skuteczność rzutów z gry, liczba przechwytów, bloków, itp., co może dostarczyć pełniejszego obrazu dotyczącego tego, które uczelnie trenują najbardziej wszechstronnych i
wydajnych zawodników w NBA.

*/
/*

1.5 Międzynarodowy wpływ
Analiza wydajności zawodników z różnych krajów i ich wpływ na NBA
*/

SELECT 
    country,
    COUNT(DISTINCT player_name) AS player_count,
    AVG(pts) AS avg_pts,
    AVG(reb) AS avg_reb,
    AVG(ast) AS avg_ast
FROM 
    all_seasons
GROUP BY 
    country
ORDER BY 
    avg_pts DESC;

/*
   country                         |player_count|avg_pts           |avg_reb           |avg_ast            |
--------------------------------+------------+------------------+------------------+-------------------+
US Virgin Islands               |           1|18.889473563746403|10.768420972322163| 3.0105263433958354|
Bahamas                         |           3|14.392857313156128|6.1785714115415304| 1.9142856949142046|
Cameroon                        |           4|14.070370241447732| 6.240740809175703|  2.125925921731525|
Finland                         |           2|13.975000202655792| 6.012500077486038| 1.1374999955296516|
Serbia and Montenegro           |           5|11.969696994983789| 5.157575792435444|  1.827272746599082|
United Kingdom                  |           4|11.916666636864344| 4.783333366115888|  1.804166667163372|
Germany                         |          13|11.881818147319736|4.5939393576347465| 2.0757575832081563|
Italy                           |           7| 11.60952387537275|3.4095238028537658| 1.5261904767581396|
Bosnia and Herzegovina          |           3|11.255555682712131| 7.111111177338494|  2.266666685541471|
Republic of the Congo           |           1|11.100000063578287|  6.49999984105428| 1.3666666348775227|
Montenegro                      |           5|10.954285723822457| 5.999999954019274| 1.5142857142857142|
Lithuania                       |          12|10.069230760060824| 5.967692337586329| 1.4153846098826481|
Spain                           |          14|10.033333347689721|4.8397849458520135|  3.432258057418049|
China                           |           4|  9.92222218712171| 4.738888816701041| 0.8166666680739986|
Saint Lucia                     |           1|  9.74999988079071| 5.724999904632568|  0.550000011920929|
Dominican Republic              |           6| 9.657142857142857| 4.868571392127445|  2.079999996295997|
Greece                          |           9|  9.58437499590218| 4.628125024959445| 1.8312500165775418|
U.S. Virgin Islands             |           1| 9.199999928474426|2.6000000002483525| 1.5749999930461247|
Turkey                          |          12| 9.146052638166829|  5.11052632723984| 1.4736842094479423|
Latvia                          |           6| 8.990000065167745| 5.006666666269302|  1.073333336909612|
Australia                       |          22| 8.950000004172326|3.7620000185072424| 2.7359999903291463|
Canada                          |          45| 8.729268328736469| 3.602926824041983|  2.150731712034563|
Jamaica                         |           5| 8.673333235581715| 5.086666631698608| 0.7600000058611234|
Slovenia                        |          10| 8.590789451410895|3.0671052619030603| 2.4657894929772928|
Serbia                          |          15| 8.447142883709498| 4.142857142857143| 2.2014285757073333|
Bosnia & Herzegovina            |           1| 8.433333237965902| 6.299999872843425| 1.3333333134651184|
USA                             |        2140|   8.2003917605131|3.4405745729142443|  1.847719429298664|
Switzerland                     |           2| 8.004347832306571| 6.234782633574112| 1.1478260891593022|
Croatia                         |          15| 8.004166725609037| 3.441666655242443| 1.4652777690854337|
Japan                           |           3| 7.981818242506548|3.2000000151720913| 0.9818181829019026|
Austria                         |           1| 7.957142898014614|6.4571429661342075| 1.6142857096024923|
Argentina                       |          14| 7.944776094226695| 3.356716425227585| 1.9716417868413143|
England                         |           2| 7.755555470784505| 2.888888862397936| 0.8111111157470279|
France                          |          37| 7.511578951383892|  3.53210525355841|  1.881578951603488|
Democratic Republic of the Congo|           4| 7.312903302331125| 4.732258112199845| 0.9967742021526059|
Poland                          |           4| 7.255555492722326| 5.655555498682791| 0.9055555582874351|
Haiti                           |           2| 7.052941210129681| 6.629411753486185| 0.6176470618914155|
Congo                           |           2| 7.046666669845581| 7.793333371480306| 0.6666666651765506|
DRC                             |           3| 7.000000068119594| 4.142857210976737| 1.2142856972558158|
Venezuela                       |           2| 6.955555465486315|               2.0| 3.4333333522081375|
Israel                          |           3| 6.839999993642171|  3.75333335796992| 1.4666666666666666|
Brazil                          |          13| 6.833720984847047| 3.796511607807736| 1.3209302338749864|
USSR                            |           1| 6.700000047683716| 1.550000011920929|  2.850000023841858|
Russia                          |           9| 6.697297298827687|3.6513513689105577| 1.4135135210849143|
Puerto Rico                     |           6| 6.613333328564962|1.8666666666666667|  2.783333331098159|
Nigeria                         |          12| 6.388372110766034| 4.493023265239804|  0.753488376216833|
Macedonia                       |           1| 6.349999904632568|3.5999999046325684| 1.0000000298023224|
Sweden                          |           2| 6.225000003973643| 3.458333343267441| 0.8166666626930237|
Yugoslavia                      |           4| 6.072727225043557| 2.781818227334456| 0.5181818252260034|
Panama                          |           1|5.8999998569488525|1.9499999284744263| 0.9500000178813934|
Bosnia                          |           2| 5.885714318071093| 2.657142860548837| 0.6714285835623741|
New Zealand                     |           2| 5.671428524312519| 4.899999965159666| 0.8428571476113229|
Czech Republic                  |           4| 5.319999893506368| 2.680000038941701| 2.2466666638851165|
Georgia                         |           6|5.0852941169458274| 4.158823528710534| 0.9147058867794626|
Ukraine                         |           8| 4.906666662957933| 3.153333336777157|  0.602222231692738|
Sudan                           |           1| 4.850000083446503|2.6750000566244125| 0.6249999962747097|
Belize                          |           1| 4.657142877578735|1.7285714490073067|  2.457142846924918|
Egypt                           |           1| 4.480000019073486|1.9399999618530273| 0.5600000023841858|
Mexico                          |           3| 4.233333335982429| 3.205555558204651| 0.9611111134290695|
South Sudan                     |           3| 4.040000009536743| 2.649999976158142| 0.5000000029802323|
Mali                            |           2|  3.92857141154153| 3.399999976158142| 0.2714285744088037|
St. Vincent & Grenadines        |           1|3.7833333710829415| 4.474999984105428|0.44166667200624943|
Netherlands                     |           2| 3.505263173266461| 3.473684214447674| 0.4000000043919212|
Tunisia                         |           1|3.5000000596046448|3.8499999046325684| 0.5250000096857548|
Ireland                         |           1| 3.433333396911621|2.0333333810170493| 0.3333333383003871|
Guinea                          |           1|3.3333333333333335|2.7666666905085244| 0.4000000109275182|
Denmark                         |           1| 3.299999952316284|1.7999999523162842|  2.799999952316284|
Senegal                         |          10|3.1952381070171083|3.0619047504095804| 0.5095238135684104|
Angola                          |           1|3.1500000953674316| 2.800000011920929| 0.5500000007450581|
Cabo Verde                      |           1| 3.149999976158142| 3.699999988079071| 0.4000000059604645|
Great Britain                   |           1|3.1333332856496177|3.4333333174387612| 0.4333333373069763|
Gabon                           |           2|2.9799999237060546|2.3199999809265135|0.35999999940395355|
Portugal                        |           1| 2.700000047683716| 2.149999976158142|0.30000000447034836|
Iran                            |           1| 2.280000019073486|               2.5| 0.3000000059604645|
Tanzania                        |           1|1.9200000047683716| 2.399999976158142|0.10000000149011612|
Uruguay                         |           1| 1.649999976158142| 2.399999976158142|0.20000000670552254|
South Korea                     |           1|               1.5|1.3499999642372131|0.05000000074505806|
Scotland                        |           1| 1.300000011920929|               1.5| 0.3500000089406967|
Trinidad and Tobago             |           1|               1.0|0.6000000238418579| 0.8999999761581421|
Ghana                           |           1|               0.0| 0.699999988079071|                0.0|
Colombia                        |           1|               0.0|               0.0|                0.0|
Sudan (UK)                      |           1|               0.0|               0.0|                0.0|
*/
/*
   
Kluczowe Wnioski

1. **Najwyższa Średnia Punktów**:
   - **US Virgin Islands**: Mają najwyższą średnią punktów (18.89) oraz najwyższą średnią zbiórek (10.77) i asyst (3.01) wśród pojedynczych graczy.
   - **Bahamas**: Drugie miejsce pod względem średniej punktów (14.39), co sugeruje, że zawodnicy z Bahamów są bardzo wydajni w ofensywie.
   - **Cameroon**: Również wysokie średnie punkty (14.07), co może wskazywać na obecność kilku silnych zawodników.

2. **Wszechstronność Zawodników**:
   - **Spain**: Zawodnicy ze Hiszpanii mają stosunkowo wysoką średnią asyst (3.43), co wskazuje na silne umiejętności w kreowaniu gry.
   - **Bosnia and Herzegovina**: Zawodnicy mają wysoką średnią zbiórek (7.11) oraz solidne średnie asyst (2.27), co świadczy o ich wszechstronności.

3. **Wydajność Zawodników z Popularnych Krajów**:
   - **USA**: Mimo największej liczby zawodników (2140), średnie punkty (8.20), zbiórki (3.44) i asysty (1.85) są niższe niż w przypadku niektórych innych krajów, co może wynikać z szerokiej bazy talentów i różnorodności poziomów umiejętności.
   - **Canada**: Posiadają wysoką liczbę zawodników (45) z solidnymi średnimi punktami (8.73) i asystami (2.15).

4. **Małe Krajów z Wyjątkowymi Zawodnikami**:
   - **US Virgin Islands** i **Bahamas** mają wyjątkowo wysokie średnie statystyki mimo niewielkiej liczby zawodników.
   - **Finland**: Zawodnicy z Finlandii również wykazują wysokie średnie punkty (13.98) i zbiórki (6.01).

### Szczegółowa Analiza

#### Wydajność w Punktach:
- **US Virgin Islands** mają znacząco wyższą średnią punktów w porównaniu do innych krajów.
- **Bahamas** i **Cameroon** również wyróżniają się wysoką średnią punktów.
- Kraje takie jak **Serbia and Montenegro** i **Germany** mają solidne średnie punkty, co wskazuje na obecność kilku kluczowych graczy.

#### Wydajność w Zbiórkach:
- **US Virgin Islands** i **Bosnia and Herzegovina** wyróżniają się wysokimi średnimi zbiórkami.
- **Germany** i **Spain** mają solidne średnie zbiórki, co wskazuje na silną obecność pod koszem.

#### Wydajność w Asystach:
- **Spain** i **US Virgin Islands** mają wysokie średnie asysty, co świadczy o zdolności do kreowania gry.
- **Canada** i **Australia** również wykazują solidne umiejętności w rozgrywaniu.

### Wnioski Ogólne

1. **Zawodnicy z małych krajów**: Tacy jak US Virgin Islands i Bahamas, pokazują wyjątkowo wysokie statystyki, co sugeruje, że te kraje trenują kilku wyjątkowo utalentowanych graczy.

2. **Wszechstronność**: Zawodnicy z krajów takich jak Hiszpania, Niemcy i Bośnia i Hercegowina wykazują wszechstronność w grze, co czyni ich cennymi graczami w NBA.

3. **Duża Baza Talentów**: Kraje z dużą liczbą zawodników, takie jak USA i Kanada, mają szeroką bazę talentów, ale ich średnie statystyki mogą być rozmyte przez dużą liczbę graczy o różnym poziomie umiejętności.

4. Średnia graczy: średnia liczba graczy z USA w drużynach wynosi około 297.81, podczas gdy średnia liczba graczy z innych krajów wynosi około 58.97.

5. Dominacja graczy z USA: Gracze z USA stanowią znaczną większość w drużynach, co może wynikać z popularności koszykówki w Stanach Zjednoczonych i silnego systemu rozwoju talentów.

6. Różnorodność: Mimo dominacji graczy z USA, obecność graczy z innych krajów pokazuje, że koszykówka jest naprawdę globalnym sportem. Gracze z różnych krajów mogą wnosić do drużyny różne style gry i doświadczenia, co może być cenne.

7. Potencjał do zwiększenia różnorodności: Chociaż gracze z innych krajów stanowią mniejszość, ich obecność pokazuje, że jest miejsce na zwiększenie różnorodności w koszykówce. Może to stworzyć więcej możliwości dla graczy z różnych części świata.

Dane te mogą być użyte do identyfikacji krajów, które trenują najbardziej wydajnych zawodników, oraz do zrozumienia, jak zawodnicy z różnych regionów przyczyniają się do dynamiki NBA.
*/

   /*

1.6 Trendy statystyczne
1.6.1 Korelacja wskaźników wydajności zawodników
*/

-- Analiza korelacji
SELECT 
    CORR(pts, reb) AS corr_pts_reb,
    CORR(pts, ast) AS corr_pts_ast,
    CORR(pts, net_rating) AS corr_pts_net_rating,
    CORR(pts, oreb_pct) AS corr_pts_oreb_pct,
    CORR(pts, dreb_pct) AS corr_pts_dreb_pct,
    CORR(pts, usg_pct) AS corr_pts_usg_pct,
    CORR(pts, ts_pct) AS corr_pts_ts_pct,
    CORR(pts, ast_pct) AS corr_pts_ast_pct
FROM 
    all_seasons;
/*

corr_pts_reb      |corr_pts_ast      |corr_pts_net_rating|corr_pts_oreb_pct   |corr_pts_dreb_pct |corr_pts_usg_pct |corr_pts_ts_pct    |corr_pts_ast_pct   |
------------------+------------------+-------------------+--------------------+------------------+-----------------+-------------------+-------------------+
0.6245090695459163|0.6643198676648243|0.21519932939383296|-0.12516417199909685|0.0556687481249602|0.641468855772284|0.37343851040744475|0.33733903037552077|
*/
   
/*   1. **`corr_pts_reb` = 0.6245**
   - **Interpretacja**: Istnieje dość silna dodatnia korelacja między punktami (`pts`) a zbiórkami (`reb`). Oznacza to, że gracze, którzy zdobywają więcej punktów, mają tendencję do zbierania większej liczby piłek.

2. **`corr_pts_ast` = 0.6643**
   - **Interpretacja**: Istnieje silna dodatnia korelacja między punktami (`pts`) a asystami (`ast`). To sugeruje, że gracze, którzy zdobywają więcej punktów, również częściej asystują.

3. **`corr_pts_net_rating` = 0.2152**
   - **Interpretacja**: Istnieje słaba dodatnia korelacja między punktami (`pts`) a net ratingiem (`net_rating`). Oznacza to, że wyższe zdobycze punktowe mogą mieć pewien pozytywny wpływ na ogólną efektywność gracza, ale nie jest to silna zależność.

4. **`corr_pts_oreb_pct` = -0.1252**
   - **Interpretacja**: Istnieje bardzo słaba ujemna korelacja między punktami (`pts`) a procentem ofensywnych zbiórek (`oreb_pct`). Oznacza to, że gracze zdobywający więcej punktów mają nieznacznie mniejszy udział w ofensywnych zbiórkach.

5. **`corr_pts_dreb_pct` = 0.0557**
   - **Interpretacja**: Istnieje bardzo słaba dodatnia korelacja między punktami (`pts`) a procentem defensywnych zbiórek (`dreb_pct`). Oznacza to, że zdobywanie większej liczby punktów nie ma znaczącego wpływu na udział gracza w defensywnych zbiórkach.

6. **`corr_pts_usg_pct` = 0.6415**
   - **Interpretacja**: Istnieje silna dodatnia korelacja między punktami (`pts`) a procentem użycia (`usg_pct`). Oznacza to, że gracze, którzy zdobywają więcej punktów, częściej angażują się w grę, co jest logiczne, ponieważ większe zaangażowanie w grę zazwyczaj prowadzi do większej liczby zdobytych punktów.

7. **`corr_pts_ts_pct` = 0.3734**
   - **Interpretacja**: Istnieje umiarkowana dodatnia korelacja między punktami (`pts`) a true shooting percentage (`ts_pct`). Oznacza to, że gracze, którzy zdobywają więcej punktów, mają tendencję do lepszej efektywności strzeleckiej.

8. **`corr_pts_ast_pct` = 0.3373**
   - **Interpretacja**: Istnieje umiarkowana dodatnia korelacja między punktami (`pts`) a procentem asyst (`ast_pct`). Oznacza to, że gracze zdobywający więcej punktów mają tendencję do większego udziału w asystach, ale ta zależność nie jest tak silna jak między punktami a liczbą asyst (`ast`).

### Wnioski

- Najsilniejsza korelacja występuje pomiędzy punktami (`pts`) a asystami (`ast`) oraz procentem użycia (`usg_pct`), co sugeruje, że gracze bardziej zaangażowani w grę zdobywają więcej punktów i mają więcej asyst.
- Istnieje umiarkowana korelacja pomiędzy punktami a efektywnością strzelecką (`ts_pct`), co oznacza, że skuteczniejsi strzelcy mają tendencję do zdobywania większej liczby punktów.
- Korelacja między punktami a zbiórkami jest również dość wysoka, co sugeruje, że bardziej wszechstronni gracze, którzy są aktywni zarówno w zdobywaniu punktów, jak i zbiórkach, mają większą wartość dla drużyny.
- Słaba korelacja między punktami a net ratingiem sugeruje, że punktowanie samo w sobie nie zawsze przekłada się na ogólną efektywność drużyny.
- Ujemna korelacja między punktami a procentem ofensywnych zbiórek może wskazywać, że gracze, którzy skupiają się na zdobywaniu punktów, mogą mniej angażować się w walkę o ofensywne zbiórki.

### Analiza Trendów statystycznych Punkty, Asysty, Zbiórki, Net Rating

#### 1. **Ast (Asysty) vs. Pts (Punkty)**

**Model**: `ast = 0,167659 * pts + 0,945379`

- **Liczba obserwacji**: 5568
- **Sum of Squared Errors (SSE)**: 17977,1
- **Mean Squared Error (MSE)**: 3,22981
- **R-Squared**: 0,275223
- **Standard Error**: 1,79717
- **P-value**: < 0,0001

**Coefficients**:
- **Punkty (pts)**: 0,167659 (każdy dodatkowy punkt jest skorelowany z 0,167659 dodatkowych asyst)
- **Intercept (stała)**: 0,945379

**Interpretacja**: Asysty (ast) mają umiarkowaną korelację z punktami (pts). Model wyjaśnia około 27,5% wariancji w liczbie asyst. P-value jest bardzo niskie, co oznacza, że związek między punktami a asystami jest statystycznie istotny.

#### 2. **Net Rating vs. Pts (Punkty)**

**Model**: `net_rating = 0,456674 * pts - 6,0955`

- **Liczba obserwacji**: 11178
- **Sum of Squared Errors (SSE)**: 1,8485e+06
- **Mean Squared Error (MSE)**: 165,399
- **R-Squared**: 0,0466378
- **Standard Error**: 12,8607
- **P-value**: < 0,0001

**Coefficients**:
- **Punkty (pts)**: 0,456674 (każdy dodatkowy punkt jest skorelowany z wzrostem net rating o 0,456674)
- **Intercept (stała)**: -6,0955

**Interpretacja**: Net rating ma bardzo słabą korelację z punktami (pts). Model wyjaśnia tylko około 4,7% wariancji w net rating. Mimo że P-value jest bardzo niskie, co wskazuje na statystycznie istotny związek, R-Squared sugeruje, że punkty nie są dobrym predyktorem net rating.

#### 3. **Reb (Zbiórki) vs. Pts (Punkty)**

**Model**: `reb = 0,215178 * pts + 2,23066`

- **Liczba obserwacji**: 7066
- **Sum of Squared Errors (SSE)**: 37839,7
- **Mean Squared Error (MSE)**: 5,35669
- **R-Squared**: 0,265899
- **Standard Error**: 2,31445
- **P-value**: < 0,0001

**Coefficients**:
- **Punkty (pts)**: 0,215178 (każdy dodatkowy punkt jest skorelowany z 0,215178 dodatkowych zbiórek)
- **Intercept (stała)**: 2,23066

**Interpretacja**: Zbiórki (reb) mają umiarkowaną korelację z punktami (pts). Model wyjaśnia około 26,6% wariancji w liczbie zbiórek. P-value jest bardzo niskie, co oznacza, że związek między punktami a zbiórkami jest statystycznie istotny.

### Ogólna Interpretacja

- **Ast (Asysty) vs. Pts (Punkty)**: Istnieje umiarkowana, statystycznie istotna korelacja między punktami a asystami. Zawodnicy, którzy zdobywają więcej punktów, mają tendencję do większej liczby asyst.
- **Net Rating vs. Pts (Punkty)**: Korelacja między punktami a net rating jest bardzo słaba, mimo że jest statystycznie istotna. To sugeruje, że punkty same w sobie nie są dobrym wskaźnikiem ogólnej efektywności zawodnika.
- **Reb (Zbiórki) vs. Pts (Punkty)**: Istnieje umiarkowana, statystycznie istotna korelacja między punktami a zbiórkami. Zawodnicy, którzy zdobywają więcej punktów, mają tendencję do większej liczby zbiórek.*/


   
-- Rozkład punktów ze względu na sezony
SELECT
    Team,
    COUNT(*) AS TotalSeasons,
    SUM(TotalPoints) AS TotalPoints,
    AVG(TotalPoints) AS AveragePoints,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TotalPoints) AS MedianPoints,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TotalPoints) AS UpperWhisker,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TotalPoints) AS LowerWhisker,
    MAX(TotalPoints) AS MaxPoints,
    MIN(TotalPoints) AS MinPoints
FROM
    TeamSeasonPoints
GROUP BY
    Team
ORDER BY
    TotalPoints DESC;

/*
team|totalseasons|totalpoints|averagepoints     |medianpoints      |upperwhisker      |lowerwhisker      |maxpoints|minpoints |
----+------------+-----------+------------------+------------------+------------------+------------------+---------+----------+
LAC |          27|     3713.0|137.51851738823785| 132.6999969482422|151.14999389648438|121.05000305175781|187.09999|     108.9|
LAL |          27|     3701.7|137.09999960440177|127.10000610351562|154.79999542236328|121.15000534057617|181.59999|115.100006|
GSW |          27|  3696.4998|136.90740882025824|132.20001220703125|             151.5|121.30000686645508|185.29999|  97.90001|
HOU |          27|     3665.5| 135.7592589766891| 127.9000015258789| 145.6999969482422|123.14999771118164|    216.5|     104.0|
MIA |          27|  3654.4004|135.34815074779368|128.79998779296875|            147.25|122.59999465942383|176.40001|     108.8|
WAS |          27|  3610.3003|133.71481464527272|             128.5|142.50000762939453|118.89999389648438|    178.7|     110.7|
DEN |          27|  3610.1003|133.70740735089336|132.59999084472656| 141.0999984741211|125.04999923706055|    165.6|102.799995|
MIL |          27|  3605.9998|133.55555640326605|126.50000762939453|144.74999237060547|119.85000610351562|172.20001|107.200005|
DAL |          27|  3597.5996|133.24444467050057|128.89999389648438| 138.9499969482422|124.60000610351562|173.00002|     115.2|
PHX |          27|     3569.3|132.19629556161385|             127.5| 141.0999984741211|120.44998931884766|    172.8|     105.8|
IND |          27|  3561.3003| 131.9000015258789|127.59999084472656|             139.5|117.50000381469727|    178.3|     103.8|
CLE |          27|  3556.3997| 131.7185197053132|131.40000915527344|144.40000915527344| 118.1500015258789|180.20003|  96.89999|
SAC |          27|  3551.5002|131.53703873245806| 125.0999984741211|140.20001220703125|118.69999694824219|    173.9|114.200005|
TOR |          27|  3525.5005|130.57407661720558| 126.0999984741211|             140.5| 119.5000114440918|    168.4|      99.9|
PHI |          27|  3519.2998|130.34444484004268|124.69998931884766|138.20000457763672|            115.25|    187.4|      99.6|
MIN |          27|  3508.8003| 129.9555567988643|125.30000305175781|140.40000915527344| 118.4000015258789|    165.5| 107.79999|
NYK |          27|  3503.7996| 129.7703699182581|130.59999084472656|137.84999084472656|123.20000839233398|156.90001|      99.7|
BOS |          27|  3484.4998|129.05555301242404|124.59999084472656|145.84999084472656|114.64999389648438|    163.7|107.600006|
POR |          27|  3470.7004|128.54444546169705|123.79999542236328|129.20000457763672| 112.4000015258789|    203.4| 104.20001|
ORL |          27|     3452.1|127.85555578161168|122.39999389648438| 132.4000015258789|117.10000228881836|174.30002|     101.6|
ATL |          27|  3450.5996|127.80000135633681| 121.5999984741211| 136.5999984741211|112.35000991821289|169.29999|  99.40001|
CHI |          27|     3443.7| 127.5444423534252| 124.0999984741211|134.79999542236328|115.89999771118164|171.70001|     100.4|
SAS |          27|  3429.3994| 127.0148171318902|124.79999542236328|137.65000915527344|116.65000534057617|    174.6| 98.200005|
DET |          27|     3348.4|124.01481656674986|117.30000305175781|124.60000228881836|113.65000534057617|181.80002| 104.59999|
UTA |          27|     3316.8|122.84444484004268|119.70000457763672|            131.25|114.85000610351562|160.20001| 100.09999|
MEM |          22|  2966.5999|134.84545378251508| 130.5999984741211|150.14999771118164|118.10000038146973|186.10002|      97.9|
CHA |          19|  2477.6997|130.40526380037008|127.69999694824219|            136.25|120.49999618530273|163.10002|106.700005|
OKC |          15|     2137.0|142.46666412353517|134.60000610351562|147.34999084472656|126.95000076293945|223.79999|     116.6|
NJN |          16|     2003.7|125.23124933242798|            122.25|133.92499923706055|114.10000419616699|    169.6|     106.5|
BKN |          11|  1712.7999|155.70908979936078|153.89999389648438| 174.8499984741211|139.29998779296875|200.79999| 113.40001|
NOP |          10|  1586.9001|158.69000396728515| 158.8000030517578|166.82501602172852|155.14999389648438|    170.9| 133.70001|
SEA |          12|  1417.7001|118.14167086283366|118.55000686645508| 121.8499927520752|114.27500343322754|130.20001| 103.90001|
NOH |           9|     1123.0|124.77777608235677| 121.0999984741211| 128.6999969482422|             116.0|    160.7|     111.8|
CHH |           6|  701.60004|116.93333689371745| 117.1500015258789|119.22499465942383|112.37500381469727|    128.1|108.500015|
VAN |           5|      542.9|108.57999725341797|             106.5| 111.9000015258789|105.69999694824219|    113.4| 105.39999|
NOK |           2|      265.3|132.64999771118164|132.64999771118164| 135.9749927520752| 129.3250026702881|139.29999| 126.00001|
*/

Analiza wyników drużyn NBA, skupiająca się na kluczowych statystykach, takich jak liczba sezonów, średnia liczba punktów, mediana, percentyle oraz minimalna i maksymalna liczba punktów uzyskanych w sezonie.

### Ogólna analiza wyników:

1. **Najwyższa średnia liczba punktów (AVG)**:
   - **BKN (Brooklyn Nets)**: 155.71 punktów.
   - **NOP (New Orleans Pelicans)**: 158.69 punktów.

2. **Najniższa średnia liczba punktów (AVG)**:
   - **VAN (Vancouver Grizzlies)**: 108.58 punktów.
   - **CHH (Charlotte Hornets)**: 116.93 punktów.

3. **Najwyższa maksymalna liczba punktów (MAX)**:
   - **OKC (Oklahoma City Thunder)**: 223.8 punktów.
   - **HOU (Houston Rockets)**: 216.5 punktów.

4. **Najniższa maksymalna liczba punktów (MAX)**:
   - **VAN (Vancouver Grizzlies)**: 113.4 punktów.
   - **CHH (Charlotte Hornets)**: 128.1 punktów.

5. **Najwyższa minimalna liczba punktów (MIN)**:
   - **NOP (New Orleans Pelicans)**: 133.7 punktów.
   - **OKC (Oklahoma City Thunder)**: 116.6 punktów.

6. **Najniższa minimalna liczba punktów (MIN)**:
   - **SAS (San Antonio Spurs)**: 98.2 punktów.
   - **MEM (Memphis Grizzlies)**: 97.9 punktów.

7. **Drużyny o największej liczbie rozegranych sezonów**:
   - **LAC, LAL, GSW, HOU, MIA, WAS, DEN, MIL, DAL, PHX, IND, CLE, SAC, TOR, PHI, MIN, NYK, BOS, POR, ORL, ATL, CHI, SAS, DET, UTA**: po 27 sezonów.
   
8. **Drużyny o najmniejszej liczbie rozegranych sezonów**:
   - **NOK (New Orleans/Oklahoma City Hornets)**: 2 sezony.
   - **VAN (Vancouver Grizzlies)**: 5 sezonów.

### Analiza poszczególnych drużyn:

- **LAC (Los Angeles Clippers)**:
  - Rozegrało 27 sezonów, z sumą punktów 3713.
  - Średnia punktów: 137.52.
  - Mediana punktów: 132.7.
  - Górny percentyl (75%): 151.15.
  - Dolny percentyl (25%): 121.05.
  - Maksymalna liczba punktów: 187.1.
  - Minimalna liczba punktów: 108.9.

- **GSW (Golden State Warriors)**:
  - Rozegrało 27 sezonów, z sumą punktów 3696.5.
  - Średnia punktów: 136.91.
  - Mediana punktów: 132.2.
  - Górny percentyl (75%): 151.5.
  - Dolny percentyl (25%): 121.3.
  - Maksymalna liczba punktów: 185.3.
  - Minimalna liczba punktów: 97.9.

- **HOU (Houston Rockets)**:
  - Rozegrało 27 sezonów, z sumą punktów 3665.5.
  - Średnia punktów: 135.76.
  - Mediana punktów: 127.9.
  - Górny percentyl (75%): 145.7.
  - Dolny percentyl (25%): 123.15.
  - Maksymalna liczba punktów: 216.5.
  - Minimalna liczba punktów: 104.

- **NOP (New Orleans Pelicans)**:
  - Rozegrało 10 sezonów, z sumą punktów 1586.9.
  - Średnia punktów: 158.69.
  - Mediana punktów: 158.8.
  - Górny percentyl (75%): 166.83.
  - Dolny percentyl (25%): 155.15.
  - Maksymalna liczba punktów: 170.9.
  - Minimalna liczba punktów: 133.7.

- **OKC (Oklahoma City Thunder)**:
  - Rozegrało 15 sezonów, z sumą punktów 2137.
  - Średnia punktów: 142.47.
  - Mediana punktów: 134.6.
  - Górny percentyl (75%): 147.35.
  - Dolny percentyl (25%): 126.95.
  - Maksymalna liczba punktów: 223.8.
  - Minimalna liczba punktów: 116.6.

### Podsumowanie:

- **Najbardziej punktujące drużyny**: Brooklyn Nets (BKN) i New Orleans Pelicans (NOP) mają najwyższe średnie punktów na sezon, co wskazuje na ich silne ofensywne osiągi w analizowanych sezonach.
  
- **Drużyny z największym zakresem wyników**: Oklahoma City Thunder (OKC) mają największą maksymalną liczbę punktów (223.8), co pokazuje ich zdolność do osiągania bardzo wysokich wyników w niektórych sezonach.

- **Drużyny o stabilnych wynikach**: Drużyny takie jak Milwaukee Bucks (MIL) i Phoenix Suns (PHX) mają mniejsze rozpiętości między percentylami, co sugeruje większą stabilność w ich wynikach punktowych w sezonach.

Analiza ta pozwala na zrozumienie zarówno średnich osiągnięć drużyn, jak i ich zdolności do osiągania wysokich wyników w poszczególnych sezonach.

1.7 Wnioski końcowe
Analiza danych dotyczących zawodników NBA może dostarczyć ciekawych informacji na temat różnorodności i zmian w tej prestiżowej lidze. Dane obejmują rekordy 12,844 zawodników z różnych sezonów, reprezentujących 2551 unikalnych graczy, oraz 36 drużyn, odzwierciedlając ewolucję ligi na przestrzeni lat. Ponadto, informacje o uczelniach i krajach pochodzenia zawodników wskazują na międzynarodowy charakter NBA. Te dane pozwalają na analizę trendów i wskaźników wydajności zawodników przez 27 sezonów, otwierając możliwość poznania fascynujących faktów na temat tej dynamicznej ligi.

Zmiany w demografii zawodników oraz ich fizycznym profilu wskazują na potencjalne ewolucje w grze koszykarskiej. Spadek średniego wzrostu i wagi sugeruje zmiany w preferencjach fizycznych, skupiając się bardziej na szybkości i zwinności. Dodatkowo, wprowadzenie większej liczby młodszych zawodników może wpływać na dynamikę i tempo gry. Wzrost wydajności ofensywnej wskazuje na bardziej zespołową grę. Te trendy mogą przewidywać ciekawe zmiany w koszykówce w najbliższych sezonach.

Trendy wskazują, że zawodnicy osiągają swoją maksymalną wydajność w zakresie wiekowym 28-32 lat, po czym ich wydajność stopniowo spada. Może to być związane z doświadczeniem, kondycją fizyczną oraz innymi czynnikami wpływającymi na ich grę.

Analiza wydajności zawodników wskazuje na wzrost średniej liczby punktów i asyst na grę, co może świadczyć o bardziej ofensywnej grze z większym naciskiem na zdobywanie punktów i grę zespołową. Jednocześnie średnia liczba zbiórek pozostaje stosunkowo stabilna, co sugeruje ich stałe znaczenie w grze, pomimo zmian w innych aspektach. Trendy te mogą odzwierciedlać ewolucję strategii i taktyki w koszykówce na przestrzeni lat.

Na podstawie analizy wyników wydaje się, że uczelnie takie jak Davidson, Lehigh, Santa Clara, Louisiana Tech i Rhode Island wyróżniają się pod względem trenowania wszechstronnych i wydajnych zawodników NBA. Istnieje jednak potrzeba przeprowadzenia bardziej szczegółowej analizy, uwzględniającej dodatkowe metryki, aby uzyskać pełniejszy obraz sytuacji.

Analiza zawodników z różnych krajów pozwala zauważyć interesujące trendy. Wysoka średnia punktów, zbiórek i asyst w przypadku takich krajów jak Wyspy Dziewicze i Bahamy wskazuje na obecność wyjątkowo zdolnych zawodników. Jednakże, również zawodnicy z mniej popularnych krajów, takich jak Finlandia, prezentują imponujące statystyki. To dowodzi, że talent w koszykówce nie zawsze idzie w parze z liczbą zawodników. Analiza ta może być cennym narzędziem dla skautów poszukujących nowych talentów na arenie międzynarodowej.

Analiza danych dotyczących reprezentacji krajów w NBA pozwala zidentyfikować różnice w występowaniu zawodników z różnych regionów. Widzimy wyraźną dominację graczy z USA w ligach

NBA, ale również zauważamy wysoką wydajność i wszechstronność graczy z małych krajów, co sugeruje istnienie wyjątkowych talentów. Obecność graczy z różnych krajów otwiera też możliwość zwiększenia różnorodności w koszykówce, co może przyczynić się do dalszego rozwoju sportu na arenie międzynarodowej. Analiza ta dostarcza istotnych informacji na temat roli różnych regionów w kształtowaniu dynamiki NBA.

Analiza korelacji wykazała, że punktujący gracze często również są aktywni w grze zespołowej, co przekłada się na większą wartość dla drużyny. Skuteczność strzelecka oraz udział w asystach są również ważnymi czynnikami dla zdobywania punktów. Warto zauważyć, że same zdobycze punktowe nie zawsze odzwierciedlają ogólną efektywność drużyny, co sugeruje, że inne elementy gry również mają istotne znaczenie.

W związku z powyższymi danymi, można wywnioskować, że Brooklyn Nets i New Orleans Pelicans są drużynami o imponujących osiągnięciach ofensywnych, podczas gdy Oklahoma City Thunder potrafią osiągać bardzo wysokie wyniki. Z kolei Milwaukee Bucks i Phoenix Suns charakteryzują się większą stabilnością w swoich wynikach punktowych. Te informacje mogą być przydatne dla osób analizujących osiągnięcia poszczególnych drużyn w analizowanych sezonach.