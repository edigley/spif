# makefile for fireSim, a sample fire behavior simulator using fireLib
# Collin D. Bevins, October 1996

# The following rules work for UnixWare 2.0.
CC = mpicc
CFLAGS = -fopenmp -g 
PATH_PROY = ./
LIBS = -lm
FILES = $(PATH_PROY)main.c $(PATH_PROY)master.c $(PATH_PROY)worker.c $(PATH_PROY)dictionary.c $(PATH_PROY)iniparser.c $(PATH_PROY)strlib.c $(PATH_PROY)population.c $(PATH_PROY)farsite.c $(PATH_PROY)MPIWrapper.c $(PATH_PROY)fitness.c $(PATH_PROY)myutils.c $(PATH_PROY)windninja.c $(PATH_PROY)genetic.c

# Business default variable's values
SCENARIO=jonquera # arkadia | jonquera | ashley | hinckley
PLAYPEN=playpen/${SCENARIO}

genetic:
	$(CC) $(CFLAGS) $(FILES) -o genetic $(LIBS)

all:
	$(CC) $(CFLAGS) $(FILES) -o genetic $(LIBS)
	$(CC) $(CFLAGS) $(FILES) -o genPopulation $(LIBS)
	$(CC) $(CFLAGS) $(FILES) -o fireSimulator $(LIBS)

fire: #61 seconds timeout
	mpicc -g -pg -DNDEBUG fireSimulator.c farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o fireSimulator -lm
fire300: #300 seconds timeout (5m)
	mpicc -g -pg -DNDEBUG fireSimulator.c farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o fireSimulator300 -lm
fire3600: #3600 seconds timeout (1h)
	mpicc -g -pg -DNDEBUG fireSimulator.c farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o fireSimulator3600 -lm

gchar:
	mpicc -g -pg -DNDEBUG gchar.c   strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o gchar   -lm

clean:
	rm -rf $(PATH_PROY)*.o $(PATH_PROY)genetic $(PATH_PROY)genPopulation $(PATH_PROY)gchar $(PATH_PROY)fireSimulator $(PATH_PROY)fireSimulator3600

clean-and-compile:

	make clean
	make all
	make fire
	make fire300
	make fire3600

generate-random-individuals:
	cd ~/git/spif/
	nOfIndividuals=1000
	individuals=farsite_individuals_${nOfIndividuals}.txt
	individualsBoxPlot=farsite_individuals_${nOfIndividuals}.png
	~/git/spif/scripts/generate_random_individuals.sh ${nOfIndividuals} ${individuals}
	~/git/spif/scripts/random_individuals_box_plot.sh ${individuals} ${individualsBoxPlot}
	eog ${individualsBoxPlot} &
set-up-scenario:
	cd ~/git/spif/
	scenario=${SCENARIO}
	playpen=${PLAYPEN}
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
	cp ~/dropbox/farsite-scenarios-results/farsite_individuals.txt ${playpen}/${individuals}
	cd ~/git/spif/${playpen}/
run-scenario:
	# Input Files: individuals.txt, ignition_area.*, landscape.lcp
	cd ~/git/spif/${playpen}/
	for i in `seq 513 1000`; do time ~/git/spif/fireSimulator ${scenarioFile} ${individuals} run ${i} >> ${outputFile} 2>&1 ; done
	#~/git/farsite/farsite4P -i output/settings_0_1.txt -f 2
	~/git/spif/scripts/concatenate_all_individuals_results.sh . ${runtimeOutput}
	~/git/spif/scripts/random_individuals_histogram.sh ${runtimeOutput} ${runtimeHistogram}
	eog ${runtimeHistogram} &
	wc -l ${runtimeOutput}
	mkdir timed_outputs && mv timed_output_0_* timed_outputs/
identify-long-running-individuals:
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
filter-out-failed-individuals:
	awk 'NR==FNR {id[$1]; next} !($2 in id)' ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE} ${RUNTIME_FILE} > ${RUNTIME_SUCCESS_FILE}
	awk 'NR==FNR {id[$1]; next}  ($2 in id)' ${IDS_OF_THOSE_KILLED_BY_TIME_OUT_FILE} ${RUNTIME_FILE} > ${RUNTIME_FAILED_FILE}
re-run-long-running-failed-individuals:
	# How to run again all individuals that failed?
    COL=${COL_EXIT_STATUS}; tail -n +3 ${RUNTIME_FILE} | awk -v col1=${COL} '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 | xargs -n1 -t -P1 time ~/git/spif/fireSimulator3600 ${scenarioFile} ${individuals} run
    ~/git/spif/scripts/concatenate_all_individuals_results.sh . ${RERUNTIME_FILE}
	~/git/spif/scripts/random_individuals_histogram.sh ${RERUNTIME_FILE} ${RERUNTIME_HISTOGRAM_FILE}
	eog ${RERUNTIME_HISTOGRAM_FILE} &
merge-two-run-results:
	tempFile=`mktemp`
	tail -n +3 ${RUNTIME_SUCCESS_FILE} | awk -v col1=29 '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 >> ${tempFile}
	tail -n +3 ${RERUNTIME_FILE}       | awk -v col1=29 '$col1 != 0' | sort -g -k 2 | cut -d' ' -f2-2 >> ${tempFile} 
	sort -u -g -k 2 ${tempFile} > ${RUNTIME_FILE}
	~/git/spif/scripts/random_individuals_histogram.sh ${RUNTIME_FILE} ${runtimeHistogram}
	eog ${runtimeHistogram} &
copy-scenario-results:
	cp ${individuals}        ~/dropbox/farsite-scenarios-results/
	cp ${individualsBoxPlot} ~/dropbox/farsite-scenarios-results/
	cp ${runtimeOutput}      ~/dropbox/farsite-scenarios-results/
	cp ${runtimeHistogram}   ~/dropbox/farsite-scenarios-results/
	cp ${outputFile}         ~/dropbox/farsite-scenarios-results/
clean-up-scenario:
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
#----------------------------------------------------------------------------------------------------------------------	
# time /home/edigley/Dropbox/doutorado_uab/scripts/shell/run-all-cases-in-range.sh 6 10
test----------------------------:
generate-central-point-from-landscape:
	~/Forest-Fire-Cases/JRC_UAB_TAV/zip_file_full/TOPTEN/Data/Resultados/CASE_2/METEO
test-checar:
	individuals <- read.table("~/git/spif/test/farsite_individuals.txt", skip=1)
	names(individuals) <- c("p0", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17", "p18", "p19", "p20")
	p <- ggplot(individuals, aes(x=z,y=y)) + geom_boxplot()

	#inputFile<-"~/git/spif/test_running_ashley_5000_individuals/timed_output_ashley_prediction_for_30_hours.txt"
	#inputFile<-"~/git/spif/test/timed_output_arkadia_30_horas.txt"
	#dat=read.csv("contacts.csv", skip=16, nrows=5, header=TRUE)
	grep "Command exited with non-zero status" timed_output_0_*
	Command exited with non-zero status 124
	"Command exited with non-zero status" 124 -> 841
	~/git/spif/test_running_ashley_5000_individuals/timed_output_ashley_prediction_for_30_hours.txt

	ds<-read.table("~/git/spif/test_running_ashley_5000_individuals/timed_output_ashley_prediction_for_30_hours.txt", header=T)
	hist(ds$runtime)
	library(ggplot2)
	ggplot(data=ds, aes(ds$runtime)) + geom_histogram(breaks=seq(0, 225, by=2), col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "green", high = "red")

	ds <- subset(ds, runtime < 3600);
	ggplot(ds, aes(runtime)) + stat_ecdf(geom="step") + labs(title="Empirical Cumulative Density Function", y="F(runtime)", x="Runtime in seconds") + theme_classic()

	individual=841
	time /home/sgeadmin/tspf/farsite/farsite4P -i output/settings_0_${individual}.txt -f 1 -t 1 -g 0 -n ${individual}
test-analysis-arkadia:
	/usr/bin/time --format "%e %M %O %P %c %x" --output=timed_output_manual.txt timeout --signal=SIGXCPU 30.0 ~/git/farsite/farsite4P -i output/settings_0_1.txt -f 1 -t 1 -g 1 -n 0 -w 0 -p 100
test-nao-pode-ser-1:
	# time /home/edigley/Dropbox/doutorado_uab/scripts/shell/run-all-cases-in-range.sh 6 10
	# ~/git/farsite/farsite4P -i output/settings_0_2.txt -f 1
	# edigley@cariri:~/doutorado_uab/git/spif/playpen/jonquera$ ~/git/farsite/farsite4P -i output/settings_0_2.txt -f 1
	# Update File GEN_0_IND_2.FMS before continuing   Fuel Model 1 Has No Initial Fuel Moisture
	# edigley@cariri:~/doutorado_uab/git/spif/jonquera$ 
	# ~/git/spif/playpen/jonquera/input/gen_0_ind_2.fms

# para formatar os individuals depois de já gerado o arquivo
	header <- paste("p",0:20,sep="")
	inputFile <- "/home/edigley/dropbox/farsite-scenarios-results/farsite_individuals_1000.txt"
	formattedIndividualsFile <- "/home/edigley/dropbox/farsite-scenarios-results/farsite_individuals_1000_formatted.txt"
	individuals <- read.table(inputFile, skip=1, col.names=header)
	individuals <- within(individuals, p0 <- ifelse(p0 < 2, 2, p0))
	individuals <- within(individuals, p1 <- ifelse(p1 < 2, 2, p1))
	integerValues <- format(subset(individuals, select=paste("p",  0:8, sep="")), format="d", digits=0, scientific = FALSE)
	decimalValues <- format(subset(individuals, select=paste("p", 9:20, sep="")), format="d", digits=2, scientific = FALSE)
	formattedIndividuals <- cbind(integerValues, decimalValues)
	write.table(formattedIndividuals, formattedIndividualsFile, col.names=F, row.names=F, quote=F)
test-run-genetic:
	cd ${playpen} && sh scripts/clean_input_outputs.sh && time mpirun -np 2 ../genetic 99 scenario_arkadia.ini > scenario_arkadia.txt ; (cat timed_output_*_*.txt | paste -d "" - - | sort > timed_output.txt)
histogram_all_cases:
	sh /home/edigley/Dropbox/doutorado_uab/scripts/shell/histogram_all_cases.sh
	/usr/bin/time --format "%e %M %O %P %c %x" --output=timed_output_manual.txt timeout --signal=SIGXCPU 30.0 ~/git/farsite/farsite4P -i output/settings_0_1.txt -f 1 -t 1 -g 1 -n 0 -w 0 -p 100
	~/git/farsite/farsite4P -i output/settings_0_1.txt -f 2
run-all-individuals-in-range:
	time /home/edigley/Dropbox/doutorado_uab/scripts/shell/run-all-individuals-in-range.sh ${scenarioFile} ${individuals} 1 1000 ${outputFile}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/concatenate_all_individuals_results.sh . ${runtimeOutput}


Shell: how to show an specific line from a file
sed '9!d' farsite_individuals.txt
awk 'NR==5' farsite_individuals.txt


edigley@cariri:~/doutorado_uab/git/spif/playpen/jonquera$ tail -n +2 farsite_individuals.txt | cat -n | sed '654!d'
   654   2 11  5 54 67 10 150 46 45 1.086875 0 0 0 0 0 0 0 0 0 0 0
edigley@cariri:~/doutorado_uab/git/spif/playpen/jonquera$ tail -n +2 farsite_individuals.txt | cat -n | sed '655!d'
   655  10 12  7 62 62 10 259 41 71 0.151670 0 0 0 0 0 0 0 0 0 0 0
edigley@cariri:~/doutorado_uab/git/spif/playpen/jonquera$ tail -n +2 farsite_individuals.txt | cat -n | sed '656!d'
   656   2  9  0 64 62  3  58 48 39 1.096527 0 0 0 0 0 0 0 0 0 0 0
edigley@cariri:~/doutorado_uab/git/spif/playpen/jonquera$ tail -n +2 farsite_individuals.txt | cat -n | sed '657!d'
   657  12 12 13 36 61 17 214 50 54 0.843798 0 0 0 0 0 0 0 0 0 0 0
edigley@cariri:~/doutorado_uab/git/spif/playpen/jonquera$

head -n 1000 ${runtimeOutput} | sed 's/.000000//g' | sort -g -k3,3 -k4,4 -k5,5 -k6,6 -k7,7 -k 8,8 -k9,9 -k10,10 -k11,11 | head -n 1000 | cut -d' ' -f3-12,24

tempFile=`mktemp`
sort -g -k2,2 ${runtimeOutput} > ${tempFile} 
sed -i 's/.000000//g' ${tempFile}
cp ${tempFile} > ${runtimeOutput}



grep -w "landscapeFile" scenario_jonquera.ini
grep -w "ignitionFile" scenario_jonquera.ini
grep -w "perimeterResolution" scenario_jonquera.ini
grep -w "distanceResolution" scenario_jonquera.ini

grep -w "StartMonth" scenario_jonquera.ini
grep -w "StartDay" scenario_jonquera.ini
grep -w "StartHour" scenario_jonquera.ini
grep -w "StartMin" scenario_jonquera.ini

grep -w "EndMonth" scenario_jonquera.ini
grep -w "EndDay" scenario_jonquera.ini
grep -w "EndHour" scenario_jonquera.ini
grep -w "EndMin" scenario_jonquera.ini

egrep -w "(StartMonth|StartDay|StartHour|StartMin)" scenario_jonquera.ini
egrep -w "(EndMonth|EndDay|EndHour|EndMin)" scenario_jonquera.ini


# extract all the essential information from scenario.ini file, concatenating in the same line, separated by comma and trimming all the spaces out
egrep -w "(landscapeFile|ignitionFile|perimeterResolution|distanceResolution|StartMonth|StartDay|StartHour|StartMin|EndMonth|EndDay|EndHour|EndMin)" scenario_jonquera.ini | tr -s " " | tr -d " " | paste -sd ";" -