import unittest
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import numpy as np
from temperature.forecasting import evaluate,forecast,representation

class ForecastTests(unittest.TestCase):
    def test_future_values_do_not_change_forecasts(self):
        blocks=np.arange(40*12,dtype=float).reshape(40,12)
        a=evaluate(blocks,[1990])
        altered=blocks.copy();altered[29:]+=10000
        b=evaluate(altered,[1990])
        np.testing.assert_allclose(a.forecast,b.forecast)
        self.assertFalse(np.allclose(a.actual,b.actual))

    def test_aggregation_equivalence(self):
        blocks=np.random.default_rng(42).normal(size=(30,12))
        for model in ['Seasonal naive','Trend + period']:
            reference=forecast(representation(blocks,'annual'),1,6,model)
            for freq,m in [('seasonal',4),('monthly',12)]:
                np.testing.assert_allclose(forecast(representation(blocks,freq),m,6,model),reference,atol=1e-12)

    def test_last_month_naive_is_not_annual_naive(self):
        blocks=np.tile(np.arange(12),(5,1))
        self.assertEqual(forecast(representation(blocks,'monthly'),12,1,'Naive')[0],11)
        self.assertEqual(forecast(representation(blocks,'annual'),1,1,'Naive')[0],5.5)

if __name__=='__main__':unittest.main()
