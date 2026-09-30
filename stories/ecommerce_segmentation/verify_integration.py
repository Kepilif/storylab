"""Portable publication checks; historical import hashes remain in migration-manifest.json."""
from pathlib import Path
import runpy
runpy.run_path(str(Path(__file__).resolve().parents[2] / 'scripts/verify_site.py'), run_name='__main__')
