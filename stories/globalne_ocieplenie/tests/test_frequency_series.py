"""Boundary tests: December ownership and no fabricated first-year winter."""
import unittest
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import pandas as pd
import numpy as np
from temperature.series import LABELS,aggregation_audit,monthly_series

class CalendarTests(unittest.TestCase):
    def test_winter_uses_previous_december(self):
        w=pd.DataFrame(0.,index=[2018,2019],columns=list(LABELS))
        w.loc[2018,7012]=9
        w.loc[2019,7012]=90
        a=aggregation_audit(w)
        winter=a.query("target=='DJF' and rule=='equal_months'")
        self.assertEqual(winter.year.tolist(),[2019])
        self.assertAlmostEqual(winter.iloc[0].reconstructed,3.)
        annual=a.query("target=='Rok' and rule=='equal_months'")
        self.assertAlmostEqual(annual.iloc[0].reconstructed,.75)
        monthly=monthly_series(w)
        train=monthly[monthly.index<=pd.Period('2019-11',freq='M')]
        self.assertEqual(len(train),23)
        self.assertNotIn(90,train.values)

    def test_constant_series_reconstructs_exactly(self):
        w=pd.DataFrame(2.,index=[2019,2020],columns=list(LABELS))
        self.assertTrue(np.allclose(aggregation_audit(w).error,0))

if __name__=='__main__':
    unittest.main()
