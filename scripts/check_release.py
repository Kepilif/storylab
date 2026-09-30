"""Run after git add: ensure Git contains every byte needed by the reviewed site."""
from pathlib import Path
import subprocess
import hashlib
import json
root = Path(__file__).resolve().parents[1]
git = ['git', '-c', f'safe.directory={root.as_posix()}']
tracked = set(subprocess.check_output(git+['ls-files', 'public'], cwd=root, text=True).splitlines())
local = {p.relative_to(root).as_posix() for p in (root/'public').rglob('*') if p.is_file()}
errors = sorted(local ^ tracked)
paths = dict(json.loads((root/'scripts/climate-migration-sha256.json').read_text()))
paths.update({name: hashlib.sha256((root/name).read_bytes()).hexdigest() for name in local})
for name, sha in paths.items():
    try:
        staged = subprocess.check_output(git+['show', ':'+name], cwd=root, stderr=subprocess.DEVNULL)
        if hashlib.sha256(staged).hexdigest() != sha:
            errors.append(name)
    except subprocess.CalledProcessError:
        errors.append(name)
if errors:
    raise SystemExit('Missing or different staged release files: '+', '.join(sorted(set(errors))))
print(f'Release index verified: {len(local)} publication files; 54 unchanged climate files')
