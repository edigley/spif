
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


edigley@cariri:~/doutorado_uab/git/spif/playpen/2019/2019_1000/case_3$ grep "Has No Initial Fuel Moisture" scenario_case_3.out | sed "s/Update File GEN_0_IND_//g" | sed "s/.FMS before continuing   Fuel Model 1 Has No Initial Fuel Moisture//g" > /home/edigley/Dropbox/farsite-scenarios-results/aggregated/ids_of_failed.txt

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


edigley@cariri:~/git/spif/playpen/jonquera$ du -sh output/*_0_1.*
	4,0K	output/raster_0_1.LGR
	18M	output/raster_0_1.toa
	4,0K	output/settings_0_1.txt
	16K	output/shape_0_1.dbf
	4,0K	output/shape_0_1.LGS
	1,3M	output/shape_0_1.shp
	4,0K	output/shape_0_1.shx
edigley@cariri:~/git/spif/playpen/jonquera$ 

edigley@cariri:~/git/spif/playpen/jonquera$ du -sh output/raster_0_*.toa
	18M	output/raster_0_100.toa
	18M	output/raster_0_101.toa
	18M	output/raster_0_102.toa
	18M	output/raster_0_103.toa
	18M	output/raster_0_104.toa
	18M	output/raster_0_105.toa
	18M	output/raster_0_106.toa
	18M	output/raster_0_107.toa
	18M	output/raster_0_108.toa
	18M	output/raster_0_109.toa
	18M	output/raster_0_10.toa
	18M	output/raster_0_110.toa
	18M	output/raster_0_111.toa
	18M	output/raster_0_112.toa
	18M	output/raster_0_113.toa
	18M	output/raster_0_114.toa
	18M	output/raster_0_115.toa
	18M	output/raster_0_116.toa
	18M	output/raster_0_117.toa
	18M	output/raster_0_119.toa
	18M	output/raster_0_11.toa
	18M	output/raster_0_120.toa
	18M	output/raster_0_121.toa
	18M	output/raster_0_122.toa
	18M	output/raster_0_123.toa
	18M	output/raster_0_124.toa
	18M	output/raster_0_125.toa
	18M	output/raster_0_126.toa
	18M	output/raster_0_127.toa
	18M	output/raster_0_128.toa
	18M	output/raster_0_129.toa
	18M	output/raster_0_12.toa
	18M	output/raster_0_130.toa
	18M	output/raster_0_131.toa
	18M	output/raster_0_132.toa
	18M	output/raster_0_133.toa
	18M	output/raster_0_134.toa
	18M	output/raster_0_135.toa
	18M	output/raster_0_136.toa
	18M	output/raster_0_138.toa
	18M	output/raster_0_139.toa
	18M	output/raster_0_13.toa
	18M	output/raster_0_140.toa
	18M	output/raster_0_141.toa
	18M	output/raster_0_142.toa
	18M	output/raster_0_143.toa
	18M	output/raster_0_14.toa
	18M	output/raster_0_15.toa
	18M	output/raster_0_16.toa
	18M	output/raster_0_17.toa
	18M	output/raster_0_18.toa
	18M	output/raster_0_19.toa
	18M	output/raster_0_1.toa
	18M	output/raster_0_20.toa
	18M	output/raster_0_21.toa
	18M	output/raster_0_22.toa
	18M	output/raster_0_23.toa
	18M	output/raster_0_24.toa
	18M	output/raster_0_25.toa
	18M	output/raster_0_26.toa
	18M	output/raster_0_27.toa
	18M	output/raster_0_28.toa
	18M	output/raster_0_29.toa
	18M	output/raster_0_2.toa
	18M	output/raster_0_30.toa
	18M	output/raster_0_31.toa
	18M	output/raster_0_32.toa
	18M	output/raster_0_33.toa
	18M	output/raster_0_34.toa
	18M	output/raster_0_35.toa
	18M	output/raster_0_36.toa
	18M	output/raster_0_37.toa
	18M	output/raster_0_38.toa
	18M	output/raster_0_39.toa
	18M	output/raster_0_3.toa
	18M	output/raster_0_40.toa
	18M	output/raster_0_41.toa
	18M	output/raster_0_42.toa
	18M	output/raster_0_43.toa
	18M	output/raster_0_44.toa
	18M	output/raster_0_45.toa
	18M	output/raster_0_46.toa
	18M	output/raster_0_47.toa
	18M	output/raster_0_48.toa
	18M	output/raster_0_49.toa
	18M	output/raster_0_4.toa
	18M	output/raster_0_50.toa
	18M	output/raster_0_51.toa
	18M	output/raster_0_52.toa
	18M	output/raster_0_53.toa
	18M	output/raster_0_54.toa
	18M	output/raster_0_55.toa
	18M	output/raster_0_56.toa
	18M	output/raster_0_57.toa
	18M	output/raster_0_58.toa
	18M	output/raster_0_59.toa
	18M	output/raster_0_5.toa
	18M	output/raster_0_60.toa
	18M	output/raster_0_61.toa
	18M	output/raster_0_62.toa
	18M	output/raster_0_63.toa
	18M	output/raster_0_64.toa
	18M	output/raster_0_65.toa
	18M	output/raster_0_66.toa
	18M	output/raster_0_67.toa
	18M	output/raster_0_68.toa
	18M	output/raster_0_69.toa
	18M	output/raster_0_6.toa
	18M	output/raster_0_70.toa
	18M	output/raster_0_71.toa
	18M	output/raster_0_72.toa
	18M	output/raster_0_73.toa
	18M	output/raster_0_74.toa
	18M	output/raster_0_75.toa
	18M	output/raster_0_76.toa
	18M	output/raster_0_77.toa
	18M	output/raster_0_78.toa
	18M	output/raster_0_79.toa
	18M	output/raster_0_7.toa
	18M	output/raster_0_80.toa
	18M	output/raster_0_81.toa
	18M	output/raster_0_82.toa
	18M	output/raster_0_83.toa
	18M	output/raster_0_84.toa
	18M	output/raster_0_85.toa
	18M	output/raster_0_86.toa
	18M	output/raster_0_87.toa
	18M	output/raster_0_88.toa
	18M	output/raster_0_89.toa
	18M	output/raster_0_8.toa
	18M	output/raster_0_90.toa
	18M	output/raster_0_91.toa
	18M	output/raster_0_92.toa
	18M	output/raster_0_93.toa
	18M	output/raster_0_94.toa
	18M	output/raster_0_95.toa
	18M	output/raster_0_96.toa
	18M	output/raster_0_97.toa
	18M	output/raster_0_98.toa
	18M	output/raster_0_99.toa
	18M	output/raster_0_9.toa
edigley@cariri:~/git/spif/playpen/jonquera$ 

edigley@cariri:~/git/spif/playpen/jonquera$ du -sh output/shape_0_*.shp
	664K	output/shape_0_100.shp
	1,2M	output/shape_0_101.shp
	1,2M	output/shape_0_102.shp
	312K	output/shape_0_103.shp
	148K	output/shape_0_104.shp
	1,3M	output/shape_0_105.shp
	1,4M	output/shape_0_106.shp
	604K	output/shape_0_107.shp
	468K	output/shape_0_108.shp
	1,3M	output/shape_0_109.shp
	1,5M	output/shape_0_10.shp
	1,6M	output/shape_0_110.shp
	1,4M	output/shape_0_111.shp
	1,5M	output/shape_0_112.shp
	168K	output/shape_0_113.shp
	1,6M	output/shape_0_114.shp
	808K	output/shape_0_115.shp
	1,4M	output/shape_0_116.shp
	780K	output/shape_0_117.shp
	1,1M	output/shape_0_119.shp
	752K	output/shape_0_11.shp
	468K	output/shape_0_120.shp
	628K	output/shape_0_121.shp
	336K	output/shape_0_122.shp
	788K	output/shape_0_123.shp
	2,1M	output/shape_0_124.shp
	724K	output/shape_0_125.shp
	1,3M	output/shape_0_126.shp
	836K	output/shape_0_127.shp
	168K	output/shape_0_128.shp
	436K	output/shape_0_129.shp
	264K	output/shape_0_12.shp
	448K	output/shape_0_130.shp
	392K	output/shape_0_131.shp
	1,3M	output/shape_0_132.shp
	1,3M	output/shape_0_133.shp
	1,5M	output/shape_0_134.shp
	980K	output/shape_0_135.shp
	792K	output/shape_0_136.shp
	1,9M	output/shape_0_137.shp
	1,7M	output/shape_0_138.shp
	1,2M	output/shape_0_139.shp
	504K	output/shape_0_13.shp
	1,2M	output/shape_0_140.shp
	956K	output/shape_0_141.shp
	880K	output/shape_0_142.shp
	260K	output/shape_0_143.shp
	808K	output/shape_0_144.shp
	852K	output/shape_0_14.shp
	728K	output/shape_0_15.shp
	580K	output/shape_0_16.shp
	1,3M	output/shape_0_17.shp
	128K	output/shape_0_18.shp
	2,0M	output/shape_0_19.shp
	1,3M	output/shape_0_1.shp
	376K	output/shape_0_20.shp
	1,4M	output/shape_0_21.shp
	272K	output/shape_0_22.shp
	536K	output/shape_0_23.shp
	1,2M	output/shape_0_24.shp
	1,3M	output/shape_0_25.shp
	1,7M	output/shape_0_26.shp
	572K	output/shape_0_27.shp
	1,8M	output/shape_0_28.shp
	2,0M	output/shape_0_29.shp
	1,6M	output/shape_0_2.shp
	816K	output/shape_0_30.shp
	1,1M	output/shape_0_31.shp
	408K	output/shape_0_32.shp
	1,6M	output/shape_0_33.shp
	2,0M	output/shape_0_34.shp
	308K	output/shape_0_35.shp
	1,4M	output/shape_0_36.shp
	740K	output/shape_0_37.shp
	224K	output/shape_0_38.shp
	580K	output/shape_0_39.shp
	508K	output/shape_0_3.shp
	468K	output/shape_0_40.shp
	1,6M	output/shape_0_41.shp
	272K	output/shape_0_42.shp
	128K	output/shape_0_43.shp
	1,5M	output/shape_0_44.shp
	684K	output/shape_0_45.shp
	1,6M	output/shape_0_46.shp
	1012K	output/shape_0_47.shp
	1,2M	output/shape_0_48.shp
	1,5M	output/shape_0_49.shp
	876K	output/shape_0_4.shp
	732K	output/shape_0_50.shp
	1,6M	output/shape_0_51.shp
	1,4M	output/shape_0_52.shp
	180K	output/shape_0_53.shp
	324K	output/shape_0_54.shp
	1,2M	output/shape_0_55.shp
	776K	output/shape_0_56.shp
	1,8M	output/shape_0_57.shp
	784K	output/shape_0_58.shp
	140K	output/shape_0_59.shp
	300K	output/shape_0_5.shp
	280K	output/shape_0_60.shp
	1,3M	output/shape_0_61.shp
	292K	output/shape_0_62.shp
	1,6M	output/shape_0_63.shp
	1,2M	output/shape_0_64.shp
	1,4M	output/shape_0_65.shp
	224K	output/shape_0_66.shp
	140K	output/shape_0_67.shp
	1,7M	output/shape_0_68.shp
	548K	output/shape_0_69.shp
	372K	output/shape_0_6.shp
	1,2M	output/shape_0_70.shp
	1,1M	output/shape_0_71.shp
	1,3M	output/shape_0_72.shp
	616K	output/shape_0_73.shp
	648K	output/shape_0_74.shp
	228K	output/shape_0_75.shp
	1,3M	output/shape_0_76.shp
	572K	output/shape_0_77.shp
	792K	output/shape_0_78.shp
	764K	output/shape_0_79.shp
	392K	output/shape_0_7.shp
	1,4M	output/shape_0_80.shp
	864K	output/shape_0_81.shp
	172K	output/shape_0_82.shp
	956K	output/shape_0_83.shp
	1,1M	output/shape_0_84.shp
	564K	output/shape_0_85.shp
	848K	output/shape_0_86.shp
	332K	output/shape_0_87.shp
	612K	output/shape_0_88.shp
	184K	output/shape_0_89.shp
	1,3M	output/shape_0_8.shp
	1,3M	output/shape_0_90.shp
	992K	output/shape_0_91.shp
	1,1M	output/shape_0_92.shp
	1,6M	output/shape_0_93.shp
	644K	output/shape_0_94.shp
	1,4M	output/shape_0_95.shp
	504K	output/shape_0_96.shp
	276K	output/shape_0_97.shp
	340K	output/shape_0_98.shp
	2,2M	output/shape_0_99.shp
	488K	output/shape_0_9.shp
edigley@cariri:~/git/spif/playpen/jonquera$ 

