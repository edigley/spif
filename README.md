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

## How to prepare real scenarios to run the predictions:

~~~~
	mkdir ~/git
	cd ~/git
	git clone https://github.com/edigley/spif.git
	git clone https://github.com/edigley/fire-scenarios.git
	scenario=jonquera
	playpen=playpen
	scenarioFile=scenario_${scenario}.ini
	outputFile=scenario_${scenario}.out
	individuals=farsite_individuals.txt
	runtimeOutput=farsite_individuals_runtime_${scenario}.txt
	runtimeHistogram=farsite_individuals_runtime_${scenario}_histogram.png
	mkdir -p ${playpen}/input ${playpen}/output ${playpen}/trace
	ln -s ~/git/fire-scenarios/${scenario}/landscape/  ${playpen}/
	ln -s ~/git/fire-scenarios/${scenario}/perimetres/ ${playpen}/
	ln -s ~/git/fire-scenarios/${scenario}/qgis/${scenario}_central_point.{shp,shx} ${playpen}/perimetres/
	ln -s ~/git/fire-scenarios/${scenario}/qgis/${scenario}_central_polygon.{shp,shx} ${playpen}/perimetres/
	ln -s ~/git/fire-scenarios/${scenario}/aux_files/  ${playpen}/
	ln -s ~/git/fire-scenarios/${scenario}/bases/      ${playpen}/
	ln -s ~/git/fire-scenarios/${scenario}/scripts/    ${playpen}/
	cp ~/git/fire-scenarios/${scenario}/scenario_template_for_histogram.ini ${playpen}/scenario_${scenario}.ini
	sed -i "s/${scenario}_central_point/${scenario}_central_polygon_2/g" ${playpen}/scenario_${scenario}.ini
	cp ~/git/fire-scenarios/${scenario}/input/pob_0.txt ${playpen}/input/
	cp ~/git/spif/results/farsite_individuals.txt ${playpen}/${individuals}
	cd ~/git/${playpen}/
~~~~

## How to visualize the results:

1. Uses qGis in order to see the results
    - We can overlay a feature with land borders in order to help locate the map