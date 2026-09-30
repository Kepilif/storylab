import unittest
import sys
from pathlib import Path
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import numpy as np
from temperature.arima_selection import NestedSelector,inner_origins,candidates

class NestedTests(unittest.TestCase):
    def test_inner_targets_stop_before_outer_test(self):
        for origin in [*range(1990,2014),2019]:
            self.assertTrue(all(i+6<=origin for i in inner_origins(origin)))
            self.assertGreaterEqual(min(inner_origins(origin))-1962+1,20)

    def test_outer_future_cannot_change_selection(self):
        blocks=np.arange(58*12,dtype=float).reshape(58,12)/100
        changed=blocks.copy(); changed[29:]+=1000
        def fake_fit(selector,freq,origin,candidate):
            n=origin-selector.start+1
            return np.repeat(selector.blocks[:n].mean(),6)
        with patch.object(NestedSelector,'fit',fake_fit):
            a=NestedSelector(blocks);b=NestedSelector(changed)
            pa,ca=a.predict('annual',1990);pb,cb=b.predict('annual',1990)
        np.testing.assert_allclose(pa,pb)
        self.assertEqual(ca,cb)
        self.assertEqual(a.selections,b.selections)

    def test_no_seasonal_models_for_annual(self):
        self.assertFalse(any(c.startswith('sarima') for c in candidates('annual')))

if __name__=='__main__':unittest.main()
