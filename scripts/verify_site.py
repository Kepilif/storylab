from pathlib import Path
from urllib.parse import urlsplit, unquote
from bs4 import BeautifulSoup
import json
import posixpath

root = Path(__file__).resolve().parents[1]
site = root/'_site'
files = {p.relative_to(site).as_posix(): p for p in site.rglob('*') if p.is_file()}
errors = set()
links = images = 0
parsed = {}
for name, path in files.items():
    if path.suffix != '.html' or name.startswith('site_libs/'):
        continue
    soup = BeautifulSoup(path.read_text(encoding='utf-8'), 'html.parser')
    parsed[name] = soup
    for tag in soup.find_all(['a', 'img', 'script', 'link', 'iframe']):
        url = tag.get('href') if tag.name in ('a', 'link') else tag.get('src')
        if not url:
            continue
        parts = urlsplit(url)
        if parts.scheme or parts.netloc or not parts.path:
            continue
        links += 1
        images += tag.name == 'img'
        target = unquote(parts.path)
        if target.startswith('/storylab/'):
            target = target[len('/storylab/'):]
        elif target.startswith('/'):
            errors.add(f'{name}: absolute URL outside /storylab/: {url}')
            continue
        else:
            target = posixpath.normpath(posixpath.join(posixpath.dirname(name), target))
        if target.endswith('/'):
            target += 'index.html'
        if target not in files:
            errors.add(f'{name}: missing or wrong case: {url}')
        elif parts.fragment and files[target].suffix == '.html' and not parts.fragment.startswith('/'):
            destination = parsed.get(target)
            if destination is None:
                destination = BeautifulSoup(files[target].read_text(encoding='utf-8'), 'html.parser')
                parsed[target] = destination
            if not destination.find(id=unquote(parts.fragment)):
                errors.add(f'{name}: missing anchor: {url}')
    if 'quarto-search' not in str(soup) and name != 'stories/ecommerce_segmentation/ecommerce_customer_segmentation.html':
        # Reveal slides intentionally have separate navigation.
        if not name.endswith('/slides.html'):
            errors.add(f'{name}: search unavailable')
search = json.loads((site/'search.json').read_text(encoding='utf-8'))
if not search:
    errors.add('Empty search index')
retired = ['factcheck_case_report', 'actors_macro_narratives', 'narrative_debt_gold', 'rhetoric_brief', 'gold_storytelling', 'nbp-macro']
for name in files:
    if any(old in name for old in retired):
        errors.add(f'Retired publication: {name}')
report = {'html_pages': sum(p.suffix == '.html' for p in files.values()), 'local_references': links, 'images': images, 'search_entries': len(search), 'errors': sorted(errors)}
(root/'docs').mkdir(exist_ok=True)
(root/'docs/site-validation.json').write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
print(json.dumps(report, ensure_ascii=False, indent=2))
raise SystemExit(bool(errors))
