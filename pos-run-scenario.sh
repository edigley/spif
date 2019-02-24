
# Set up of all variables regarding the case
	aggregationDir=/home/edigley/dropbox/farsite-scenarios-results/
	case=10
	nOfIndividuals=1000
	scenario="case_${case}"
	scenario="jonquera"
	scenarioFile="scenario_${scenario}.ini"
	outputFile="scenario_${scenario}.out"
	individuals=farsite_individuals_${nOfIndividuals}.txt
	individualsBoxPlot=farsite_individuals_${nOfIndividuals}_bloxplot.png
	runtimeOutput=farsite_individuals_runtime_${scenario}_${nOfIndividuals}.txt
	runtimeHistogram=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram.png
	cd /home/edigley/doutorado_uab/git/spif/
    playpen=${scenario}
	cd /home/edigley/doutorado_uab/git/spif/${playpen}
	##cd /home/edigley/doutorado_uab/git/spif/2019_${nOfIndividuals}/${playpen}
	##cp ${aggregationDir}/${individuals} .
    ##cp ${aggregationDir}/${runtimeOutput} .

# How to identify all individuals whose execution has failed (lines excluding headers whose status is different than 0 (zero))?

# Define variables for the merging activities
    COL_RUNTIME=24
    COL_EXIT_STATUS=29
    RUNTIME_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}.txt
    RERUNTIME_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_rerun.txt
    RERUNTIME_HISTOGRAM_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram.png
    RUNTIME_FINAL_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_final.txt
    RUNTIME_HISTOGRAM_FINAL_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram_final.png
    RUNTIME_AGGREGATED_FILE=farsite_individuals_runtime_${scenario}_aggregated.txt
    RUNTIME_HISTOGRAM_AGGREGATED_FILE=farsite_individuals_runtime_${scenario}_histogram_aggregated.png

# How many individuals finished succesfully?
    COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 == 0' | wc -l

# How many individuals do not finished succesfully?
    COL=${COL_EXIT_STATUS}; cat ${RUNTIME_FILE} | sort -g -k ${COL} | egrep -v "(0 9999.|exit error)" | wc -l
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

# For the cases when all individuals finished succesfully
	COL=${COL_EXIT_STATUS}; cp ${RUNTIME_FILE} ${RUNTIME_FINAL_FILE}
    /home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${RUNTIME_FINAL_FILE} ${RUNTIME_HISTOGRAM_FINAL_FILE}
    eog ${RUNTIME_HISTOGRAM_FINAL_FILE} &

# For the cases when there were killed individuals

# How to run again all individuals that failed?
    COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 | xargs -n1 -t -P1 time /home/edigley/doutorado_uab/git/spif/fireSimulator3600 ${scenarioFile} ${individuals} run
    /home/edigley/Dropbox/doutorado_uab/scripts/shell/concatenate_all_individuals_results.sh . ${RERUNTIME_FILE}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${RERUNTIME_FILE} ${RERUNTIME_HISTOGRAM_FILE}
	eog ${RERUNTIME_HISTOGRAM_FILE} &

# How to merge all the succesfull running individuals?
    cat ${RERUNTIME_FILE} > ${RUNTIME_FINAL_FILE}
    COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 == 0' | sort -g -k 2 >> ${RUNTIME_FINAL_FILE}
    /home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${RUNTIME_FINAL_FILE} ${RUNTIME_HISTOGRAM_FINAL_FILE}
    eog ${RUNTIME_HISTOGRAM_FINAL_FILE} &


# For both cases

# Copy results to aggregation folder
	cp -i ${RUNTIME_FINAL_FILE} ${aggregationDir}
	cp -i ${RUNTIME_HISTOGRAM_FINAL_FILE} ${aggregationDir}

# Aggregate all the results
	cd ${aggregationDir}
	ls farsite_individuals_runtime_${scenario}_????_final.txt
	head -n2 farsite_individuals_runtime_${scenario}_1000_final.txt > farsite_individuals_runtime_${scenario}_final.txt
	tail -q -n +3 farsite_individuals_runtime_${scenario}_????_final.txt | sort -u -g -k 2 >> farsite_individuals_runtime_${scenario}_final.txt
	wc -l farsite_individuals_runtime_${scenario}_final.txt

# Generate final histogram
	cd ${aggregationDir}
	ls farsite_individuals_runtime_${scenario}_????_final.txt
	head -n2 farsite_individuals_runtime_${scenario}_1000_final.txt > ${RUNTIME_AGGREGATED_FILE}
	tail -q -n +3 farsite_individuals_runtime_${scenario}_????_final.txt | sort -u -g -k 2 >> ${RUNTIME_AGGREGATED_FILE}
	wc -l ${RUNTIME_AGGREGATED_FILE}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${RUNTIME_AGGREGATED_FILE} ${RUNTIME_HISTOGRAM_AGGREGATED_FILE}
    eog ${RUNTIME_HISTOGRAM_AGGREGATED_FILE} &

