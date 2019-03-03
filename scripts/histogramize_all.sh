#!/bin/bash

scriptHistogramAllIndividuals="/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh"

for scenario in `seq 1 10`; do 
	scenarioDir="/home/edigley/doutorado_uab/git/spif/test_case_"${scenario}
	echo "Going to generate histogram for scenario: "${scenarioDir}
	pngHistogram=${scenarioDir}"/runtime_histogram_case_"${scenario}".png"
	cd ${scenarioDir} && \
	${scriptHistogramAllIndividuals} ${scenarioDir}/output.txt ${pngHistogram} && \
	cp ${pngHistogram} /home/edigley/doutorado_uab/git/spif/histograms/
done
