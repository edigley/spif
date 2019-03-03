
# Set up of all variables regarding the case
	aggregationDir=/home/edigley/dropbox/farsite-scenarios-results/aggregated
	case=10
	scenario="case_${case}"
	nOfIndividuals=1000
	scenarioFile="scenario_${scenario}.ini"
	outputFile="scenario_${scenario}.out"
	individuals=farsite_individuals_${nOfIndividuals}_formatted.txt
	individualsBoxPlot=farsite_individuals_${nOfIndividuals}_bloxplot.png
	runtimeOutput=farsite_individuals_runtime_${scenario}_${nOfIndividuals}.txt
	runtimeHistogram=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram.png
	playpen="/home/edigley/doutorado_uab/git/spif/playpen/"
	cd "${playpen}/${scenario}"
	cd "${playpen}/2019/2019_${nOfIndividuals}/${scenario}"
	##cd /home/edigley/doutorado_uab/git/spif/2019_${nOfIndividuals}/${playpen}
	##cp ${aggregationDir}/${individuals} .
    ##cp ${aggregationDir}/${runtimeOutput} .

# How to identify all individuals whose execution has failed (lines excluding headers whose status is different than 0 (zero))?

# Define variables for the merging activities
    COL_RUNTIME=24
    COL_EXIT_STATUS=29
    RUNTIME_FILE=farsite_individuals_runtime_${scenario}_aggregated.txt
    #RERUNTIME_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_rerun_killed_by_timed_out.txt
	RERUNTIME_FILE=farsite_individuals_runtime_${scenario}_rerun_killed_by_timed_out.txt
    RERUNTIME_HISTOGRAM_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}rerun_killed_by_timed_out_histogram.png
    RUNTIME_FINAL_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_final.txt
    RUNTIME_HISTOGRAM_FINAL_FILE=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram_final.png
    RUNTIME_AGGREGATED_FILE=farsite_individuals_runtime_${scenario}_aggregated.txt
    RUNTIME_HISTOGRAM_AGGREGATED_FILE=farsite_individuals_runtime_${scenario}_histogram_aggregated.png
	IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/ids_of_failed_${scenario}.txt"

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


awk 'NR==FNR {id[$1]; next} $2 in id' ids_of_failed.txt farsite_individuals_runtime_case_3_aggregated.txt
awk 'NR==FNR {id[$1]; next} !($2 in id)' ids_of_failed.txt farsite_individuals_runtime_case_3_aggregated.txt

awk 'NR==FNR {id[$1]; next} !($2 in id)' ids_of_failed.txt farsite_individuals_runtime_case_3_aggregated.txt > farsite_individuals_runtime_case_3_aggregated_success.txt

edigley@cariri:~/Dropbox/farsite-scenarios-results/aggregated$ awk 'NR==FNR {id[$1]; next} $2 in id' ids_of_failed.txt farsite_individuals_runtime_case_3_aggregated.txt

edigley@cariri:~/doutorado_uab/git/spif/playpen/2019/2019_1000/case_3$ grep "Has No Initial Fuel Moisture" scenario_case_3.out | sed "s/Update File GEN_0_IND_//g" | sed "s/.FMS before continuing   Fuel Model 1 Has No Initial Fuel Moisture//g" > /home/edigley/Dropbox/farsite-scenarios-results/aggregated/ids_of_failed.txt

cd ~/doutorado_uab/git/spif/playpen/2019/
for k in `seq 1 10`; do
	scenario="case_${k}"
	scenarioFile="scenario_${scenario}.out"
	outputFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/ids_of_failed_${scenario}.txt"
	runtimeAggregatedFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/farsite_individuals_runtime_${scenario}_aggregated.txt"
	runtimeAggregatedSuccessFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/farsite_individuals_runtime_${scenario}_aggregated_success.txt"
	runtimeAggregatedSuccessHistogramFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/farsite_individuals_runtime_${scenario}_aggregated_success.png"
	tempFile=`mktemp`
	rm ${outputFile}
	for i in 1000 2000 3000 4000 5000; do grep "Has No Initial Fuel Moisture" 2019_${i}/${scenario}/${scenarioFile} | sed "s/Update File GEN_0_IND_//g" | sed "s/.FMS before continuing   Fuel Model 1 Has No Initial Fuel Moisture//g" >> ${tempFile}; done
	cat     ${tempFile} | wc -l
	sort -u ${tempFile} | wc -l
	sort -u ${tempFile} > ${outputFile}
	sort -u ${outputFile} | wc -l
	rm -rf ${tempFile}
	awk 'NR==FNR {id[$1]; next} !($2 in id)' ${outputFile} ${runtimeAggregatedFile} > ${runtimeAggregatedSuccessFile}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${runtimeAggregatedSuccessFile} ${runtimeAggregatedSuccessHistogramFile}
done;



	scenario="jonquera"
	cd ~/doutorado_uab/git/spif/playpen/${scenario}/
	scenarioFile="scenario_${scenario}.out"
	outputFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/ids_of_failed_${scenario}.txt"
	runtimeAggregatedFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/farsite_individuals_runtime_${scenario}_aggregated.txt"
	runtimeAggregatedSuccessFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/farsite_individuals_runtime_${scenario}_aggregated_success.txt"
	runtimeAggregatedSuccessHistogramFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/farsite_individuals_runtime_${scenario}_aggregated_success.png"
	tempFile=`mktemp`
	rm ${outputFile}
	grep "Has No Initial Fuel Moisture" ${scenarioFile} | sed "s/Update File GEN_0_IND_//g" | sed "s/.FMS before continuing   Fuel Model 1 Has No Initial Fuel Moisture//g" >> ${tempFile}
	cat        ${tempFile} | wc -l
	sort -u -g ${tempFile} | wc -l
	#it shouldn't consider the individuals who was killed by time out'
	tail -n +3 ${runtimeAggregatedFile} | awk -v col1=29 '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 >> ${tempFile}
	sort -u -g ${tempFile} > ${outputFile}
	sort -u -g ${outputFile} | wc -l
	cp ${outputFile} ${tempFile}
	sort -u -g ${tempFile} > ${outputFile}
	rm -rf ${tempFile}
	awk 'NR==FNR {id[$1]; next} !($2 in id)' ${outputFile} ${runtimeAggregatedFile} > ${runtimeAggregatedSuccessFile}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${runtimeAggregatedSuccessFile} ${runtimeAggregatedSuccessHistogramFile}
	eog ${runtimeAggregatedSuccessHistogramFile}


	cp /home/edigley/Dropbox/farsite-scenarios-results/${individuals} .
	outputFile="/home/edigley/Dropbox/farsite-scenarios-results/aggregated/ids_of_failed_${scenario}.txt"
	head ${outputFile} | xargs -n1 -t -P1 time /home/edigley/doutorado_uab/git/spif/fireSimulator3600 ${scenarioFile} ${individuals} run


	


tail ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE}
wc -l ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE}
tempFile=`mktemp`
cp ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE} ${tempFile}
sort -u -g ${tempFile} > ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE}
tail ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE}
wc -l ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE}

cp /home/edigley/Dropbox/farsite-scenarios-results/${individuals} .
cat ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE} | xargs -n1 -t -P1 time /home/edigley/doutorado_uab/git/spif/fireSimulator3600 ${scenarioFile} ${individuals} run > scenario_case_${case}.out_rerun_killed_ones 2>&1
rm outputs/*



/home/edigley/Dropbox/doutorado_uab/scripts/shell/concatenate_all_individuals_results.sh . ${RERUNTIME_FILE}
cp ${RERUNTIME_FILE} ${aggregationDir}
mkdir time_outputs
mv timed_output_0_*.txt time_outputs
cd ${aggregationDir}




case=10
# all the cases that have not failed
awk 'NR==FNR {id[$1]; next} !($2 in id)' ids_of_failed_case_${case}.txt farsite_individuals_runtime_case_${case}_aggregated.txt > farsite_individuals_runtime_case_${case}.txt
# all the cases that have being re-run
tail -n +3 farsite_individuals_runtime_case_${case}_rerun_killed_by_timed_out.txt >> farsite_individuals_runtime_case_${case}.txt
wc -l farsite_individuals_runtime_case_${case}.txt
/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh farsite_individuals_runtime_case_${case}.txt farsite_individuals_runtime_case_${case}.png
eog farsite_individuals_runtime_case_${case}.png &





/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${RERUNTIME_FILE} ${RERUNTIME_HISTOGRAM_FILE}
eog ${RERUNTIME_HISTOGRAM_FILE} &
cp ${RERUNTIME_FILE} ${aggregationDir}
COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 == 0' | sort -g -k 2 >> ${RUNTIME_FINAL_FILE}
/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${RUNTIME_FINAL_FILE} ${RUNTIME_HISTOGRAM_FINAL_FILE}
eog ${RUNTIME_HISTOGRAM_FINAL_FILE} &
