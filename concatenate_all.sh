#!/bin/bash

scriptConcatenateAllIndividuals="/home/edigley/Dropbox/doutorado_uab/scripts/shell/concatenate_all_individuals_results.sh"

for scenario in `seq 1 10`; do 
    scenarioDir="/home/edigley/doutorado_uab/git/spif/test_case_"${scenario}
    timedOutputsDir=${scenarioDir}/timed_outputs/
    cd ${scenarioDir} && \
    mv -f ${scenarioDir}/timed_output_0_* ${timedOutputsDir} 
    cd ${timedOutputsDir} && \
    ${scriptConcatenateAllIndividuals} ${timedOutputsDir} ${scenarioDir}/output.txt; 
done
