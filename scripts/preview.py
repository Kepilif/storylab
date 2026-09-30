"""Preview the reviewed artifact with the same /storylab/ prefix as Pages."""
from pathlib import Path
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

root = Path(__file__).resolve().parents[1] / 'public'

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(root), **kwargs)

    def do_GET(self):
        if not self.path.startswith('/storylab/'):
            self.send_response(302)
            self.send_header('Location', '/storylab/')
            self.end_headers()
            return
        super().do_GET()

    def translate_path(self, path):
        return super().translate_path(path.removeprefix('/storylab'))

print('Review: http://127.0.0.1:8766/storylab/', flush=True)
ThreadingHTTPServer(('127.0.0.1', 8766), Handler).serve_forever()
