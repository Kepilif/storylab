from pathlib import Path
import hashlib
import json
import sys
root = Path(__file__).resolve().parents[1]
manifest = json.loads((root/'scripts/climate-migration-sha256.json').read_text())
errors = [name for name, sha in manifest.items() if not (root/name).is_file() or hashlib.sha256((root/name).read_bytes()).hexdigest() != sha]
if errors:
    raise SystemExit('Changed frozen climate files: '+', '.join(errors))
sys.path.insert(0, str(root/'stories/globalne_ocieplenie'))
from frequency_stability import verify_freeze
verify_freeze()
print(f'Climate integrity: {len(manifest)} files unchanged')
