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


# Define default variable's values

~~~~
SCENARIO=jonquera # arkadia | jonquera | ashley | hinckley
PLAYPEN=playpen/cloud/${SCENARIO}
~~~~

## How to generate random individuals:

~~~~
cd ~/git/spif/
nOfIndividuals=1000
individuals=farsite_individuals_${nOfIndividuals}.txt
individualsBoxPlot=farsite_individuals_${nOfIndividuals}.png
~/git/spif/scripts/generate_random_individuals.sh ${nOfIndividuals} ${individuals}
~/git/spif/scripts/random_individuals_box_plot.sh ${individuals} ${individualsBoxPlot}
eog ${individualsBoxPlot} &
~~~~

## How to prepare real scenarios to run the predictions:

~~~~
scenario=jonquera
playpen=playpen
mkdir ~/git
cd ~/git
git clone https://github.com/edigley/spif.git
git clone https://github.com/edigley/fire-scenarios.git
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

## How to run a group of individuals:

~~~~
# Input Files: individuals.txt, ignition_area.*, landscape.lcp
cd ~/git/${playpen}/
for i in `seq 0 1000`; do time ~/git/spif/fireSimulator ${scenarioFile} ${individuals} run ${i} >> ${outputFile} 2>&1; rm output/raster_0_$i.toa ; done
#~/git/farsite/farsite4P -i output/settings_0_1.txt -f 2
~/git/spif/scripts/concatenate_all_individuals_results.sh . ${runtimeOutput}
~/git/spif/scripts/random_individuals_histogram.sh ${runtimeOutput} ${runtimeHistogram}
eog ${runtimeHistogram} &
tempFile=`mktemp`
~/git/spif/scripts/generate_summary_for_scenario_specification.sh ${scenarioFile} ${tempFile}
tail -n +2 ${runtimeOutput} >> ${tempFile}
sed -i 's/.000000//g' ${tempFile}
cp ${tempFile} ${runtimeOutput}
wc -l ${runtimeOutput}
mkdir timed_outputs && mv timed_output_0_* timed_outputs/
~~~~

## How to identify long running individuals

~~~~
# How many individuals finished succesfully?
COL_RUNTIME=24
COL_EXIT_STATUS=29
RUNTIME_FILE=${runtimeOutput}
RUNTIME_SUCCESS_FILE="${runtimeOutput}_success.txt"
RUNTIME_FAILED_FILE="${runtimeOutput}_failed.txt"
RERUNTIME_FILE=farsite_individuals_runtime_${scenario}_rerun_killed_by_timed_out.txt
RERUNTIME_HISTOGRAM_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}rerun_killed_by_timed_out_histogram.png
IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE="${runtimeOutput}_killed_by_timeout.txt"
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 == 0' | wc -l
# How many individuals did not finish succesfully?
#COL=${COL_EXIT_STATUS}; cat ${RUNTIME_FILE} | sort -g -k ${COL} | egrep -v "(0 9999.|exit error)" | wc -l
COL=${COL_EXIT_STATUS}; cat ${RUNTIME_FILE} | sort -g -k ${COL} | awk -v col1=${COL} '$col1 == 124' | wc -l
#COL=${COL_EXIT_STATUS}; cat ${RUNTIME_FILE} | sort -g -k ${COL} | awk -v col1=${COL} '$col1 != 0' | wc -l
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | wc -l
# What was the error codes in the failing individuasl?
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | awk -v col1=${COL} '{print $col1}' | sort -u
# Which individuals did not finish succesfully?
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | cut -d' ' -f1-12,24,25,29
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | cut -d' ' -f1-12,24,25,29 | sort -g -k 2
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | sort -g -k 2 | cut -d' ' -f3-23
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | sort -g -k 2 | cut -d' ' -f1,2,24,25,29
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2 > ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE}
tail -n +3 ${RUNTIME_FILE} | sort -g -k 24 | cut -d' ' -f1,2,24,25,29
~~~~

## How to filter out failed individuals:

~~~~
awk 'NR==FNR {id[$1]; next} !($2 in id)' ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE} ${RUNTIME_FILE} > ${RUNTIME_SUCCESS_FILE}
awk 'NR==FNR {id[$1]; next}  ($2 in id)' ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE} ${RUNTIME_FILE} > ${RUNTIME_FAILED_FILE}
~~~~

## How to re-run failed individuals:

~~~~
# How to run again all individuals that failed?
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 | xargs -n1 -t -P1 time ~/git/spif/fireSimulator86400 ${scenarioFile} ${individuals} run
~/git/spif/scripts/concatenate_all_individuals_results.sh . ${RERUNTIME_FILE}
~/git/spif/scripts/random_individuals_histogram.sh ${RERUNTIME_FILE} ${RERUNTIME_HISTOGRAM_FILE}
eog ${RERUNTIME_HISTOGRAM_FILE} &
~~~~

## How to merge results:

~~~~
tempFile=`mktemp`
tail -n +3 ${RUNTIME_SUCCESS_FILE} | awk -v col1=29 '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 >> ${tempFile}
tail -n +3 ${RERUNTIME_FILE}       | awk -v col1=29 '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 >> ${tempFile} 
sort -u -g -k 2 ${tempFile} > ${RUNTIME_FILE}
~/git/spif/scripts/random_individuals_histogram.sh ${RUNTIME_FILE} ${runtimeHistogram}
eog ${runtimeHistogram} &
~~~~

## How to copy important scenario results

~~~~
cp ${individuals}        ~/dropbox/farsite-scenarios-results/
cp ${individualsBoxPlot} ~/dropbox/farsite-scenarios-results/
cp ${runtimeOutput}      ~/dropbox/farsite-scenarios-results/
cp ${runtimeHistogram}   ~/dropbox/farsite-scenarios-results/
cp ${outputFile}         ~/dropbox/farsite-scenarios-results/
~~~~

## How to clean up the scenario:

~~~~
rm output/raster_0_*
rm output/shape_0_*
rm output/settings_0_*
rm input/gen_0_ind_*.fms
rm input/gen_0_ind_*.wnd
rm input/gen_0_ind_*.wtr
rm input/gen_0_ind_*.adj
rm gmon.out
rm output_individuals_adjustment_result.txt
rm Settings.txt
#for i in `seq 1 1000`; do pkill -kill fireSimulator; done
~~~~

## How to visualize the results:

1. Uses qGis in order to see the results
    - We can overlay a feature with land borders in order to help locate the map