import sys
from pathlib import Path
import json
import tempfile
import unittest
from unittest.mock import patch
import numpy as np
import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import frequency_stability as fs


class StabilityTests(unittest.TestCase):
    def test_pairing_is_by_target_not_row_order(self):
        rows = []
        for h in [1, 2]:
            for model, forecast in [('Trend + period', h+1), ('Other', h+0.5)]:
                rows.append(dict(stage='cv', origin=2000, horizon=h, year=2000+h,
                                 frequency='annual', model=model, forecast=forecast,
                                 actual=h, error=forecast-h))
        frame = pd.DataFrame(rows).sample(frac=1, random_state=1)
        paired = fs.paired_errors(frame)
        np.testing.assert_allclose(paired.query("model=='Other'").delta_abs_error, -0.5)
        frame.loc[frame.model=='Other', 'actual'] += 1
        frame['error'] = frame.forecast-frame.actual
        with self.assertRaisesRegex(AssertionError, 'Different targets'):
            fs.paired_errors(frame)

    def test_blocks_preserve_constant_difference(self):
        for block in [3, 6, 8]:
            np.testing.assert_allclose(fs.block_range(np.full(24, -0.25), block), [-0.25, -0.25])

    def test_freeze_detects_modified_input(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root/'input.csv'
            source.write_text('original')
            (root/'evaluation_lock.json').write_text(json.dumps({'sha256': {'input.csv': fs.digest(source)}}))
            with patch.object(fs, 'ROOT', root), patch.object(fs, 'OUT', root):
                fs.verify_freeze()
                source.write_text('changed')
                with self.assertRaisesRegex(ValueError, 'input.csv'):
                    fs.verify_freeze()


if __name__ == '__main__':
    unittest.main()
