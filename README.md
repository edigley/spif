# SPIF (Sistema para Prevenção de Incêndios Florestais)
Two Stage Data-Driven Framework for Fire Spread Prediction

## Linear and Polynomial Regression models:

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/edigley/spif/master?filepath=notebooks%2Fquality_of_prediction.ipynb)

## Multivariate Adaptive Regression Spline (MARS) models:

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/edigley/spif/master?filepath=notebooks%2Fmars_models.ipynb)

## Scenarios to be considered:

1. Ignition perimeter:
    - Use the central point of the map or
    - Use an irregular polygon whose centered in the map central polygon
2. Use the same map resolution in all scenarios
3. Use the entire wind direction search space
4. Define the wind velocity range
5. Define the prediction period [8, 12, 18, 24, 30] horas

## Scenarios to be considered:

1. Uses qGis in order to see the results
    - We can overlay a feature with land borders in order to help locate the map