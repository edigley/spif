# makefile for fireSim, a sample fire behavior simulator using fireLib
# Collin D. Bevins, October 1996

# The following rules work for UnixWare 2.0.
CC = mpicc
CFLAGS = -fopenmp -g 
PATH_PROY = ./
LIBS = -lm
FILES = $(PATH_PROY)main.c $(PATH_PROY)master.c $(PATH_PROY)worker.c $(PATH_PROY)dictionary.c $(PATH_PROY)iniparser.c $(PATH_PROY)strlib.c $(PATH_PROY)population.c $(PATH_PROY)farsite.c $(PATH_PROY)MPIWrapper.c $(PATH_PROY)fitness.c $(PATH_PROY)myutils.c $(PATH_PROY)windninja.c $(PATH_PROY)genetic.c

genetic:
	$(CC) $(CFLAGS) $(FILES) -o genetic $(LIBS)

all:
	$(CC) $(CFLAGS) $(FILES) -o genetic $(LIBS)
	$(CC) $(CFLAGS) $(FILES) -o genPopulation $(LIBS)
	$(CC) $(CFLAGS) $(FILES) -o fireSimulator $(LIBS)

fire: #61 seconds timeout
	mpicc -g -pg -DNDEBUG fireSimulator.c farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o fireSimulator -lm
fire300: #3600 seconds timeout (1h)
	mpicc -g -pg -DNDEBUG fireSimulator.c farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o fireSimulator300 -lm
fire3600: #3600 seconds timeout (1h)
	mpicc -g -pg -DNDEBUG fireSimulator.c farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o fireSimulator3600 -lm

gchar:
	mpicc -g -pg -DNDEBUG gchar.c   strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o gchar   -lm

clean:
	rm -rf $(PATH_PROY)*.o $(PATH_PROY)genetic $(PATH_PROY)genPopulation $(PATH_PROY)gchar $(PATH_PROY)fireSimulator

clean-and-compile:
	make clean
	make all

set-up-scenario:
	cd /home/edigley/doutorado_uab/git/spif/
	scenario="arkadia"
	scenario="ashley"
	scenario="jonquera"
	playpen=${scenario}
	mkdir -p ${playpen}/input ${playpen}/output ${playpen}/trace
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/landscape/  ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/perimetres/ ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/qgis/${scenario}_central_point* ${playpen}/perimetres/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/aux_files/  ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/bases/      ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/scripts/    ${playpen}/
	cp ~/doutorado_uab/git/fire-scenarios/${scenario}/scenario_template_for_histogram.ini ${playpen}/scenario_${scenario}.ini
	cp ~/doutorado_uab/git/fire-scenarios/${scenario}/input/pob_0.txt ${playpen}/input/

set-up-scenario-top-ten:
	rm -rf /home/edigley/doutorado_uab/git/spif/test
	cd /home/edigley/doutorado_uab/git/spif/
	mkdir -p test/input
	mkdir test/input test/output test/trace
	scenario=2
	ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/landscape/  test/
	ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/perimetres/ test/
	ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/qgis/case_${scenario}_central_point* test/perimetres/
	ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/aux_files/  test/
	ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/bases/      test/
	ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/scripts/    test/
	cp ~/doutorado_uab/git/fire-scenarios/case_${scenario}/scenario_template_for_histogram.ini test/scenario_case_${scenario}.ini
	cp ~/doutorado_uab/git/fire-scenarios/case_${scenario}/input/pob_0.txt test/input/
	cd test
	cp ../farsite_individuals.txt .
	#/home/edigley/doutorado_uab/git/spif/fireSimulator scenario_case_${scenario}.ini farsite_individuals.txt run 1
	for i in `seq 2001 3000`; do time /home/edigley/doutorado_uab/git/spif/fireSimulator scenario_case_${scenario}.ini farsite_10000_individuals.txt run $i; done
	rm -rf output/*
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh scenario_case_${scenario}.txt runtime_histogram_${scenario}.png
	eog  runtime_histogram_${scenario}.png
	cd /home/edigley/doutorado_uab/git/spif/
	mv test test_case_${scenario}

test-run-genetic:
	cd ${playpen} && sh scripts/clean_input_outputs.sh && time mpirun -np 2 ../genetic 99 scenario_arkadia.ini > scenario_arkadia.txt ; (cat timed_output_*_*.txt | paste -d "" - - | sort > timed_output.txt)

test-clean:
	rm -rf test

test-analysis-arkadia:
	# Input Files: individuals.txt, ignition_area.*, landscape.lcp
	cd /home/edigley/doutorado_uab/git/spif
	make test-arkadia
	make clean
	make fire
	scenario=arkadia
	scenarioFile=scenario_${scenario}.ini
	nOfIndividuals=10000
	individuals=farsite_individuals_${nOfIndividuals}.txt
	individualsBoxPlot=farsite_individuals_${nOfIndividuals}_bloxplot.png
	runtimeOutput=farsite_individuals_runtime_${scenario}_${nOfIndividuals}.txt
	runtimeHistogram=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram.png
	mkdir ${scenario}
	cd ${scenario}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/generate_random_individuals.sh ${nOfIndividuals} ${individuals}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_box_plot.sh ${individuals} ${individualsBoxPlot}
	eog ${individualsBoxPlot}
	for i in `seq 1 ${nOfIndividuals}`; do time /home/edigley/doutorado_uab/git/spif/fireSimulator ${scenarioFile} ${individuals} run ${i} ; done
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/concatenate_all_individuals_results.sh . ${runtimeOutput}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${runtimeOutput} ${runtimeHistogram}
	eog ${runtimeHistogram} &
	cp ${individuals}        ~/dropbox/farsite-scenarios-results/
	cp ${individualsBoxPlot} ~/dropbox/farsite-scenarios-results/
	cp ${runtimeOutput}      ~/dropbox/farsite-scenarios-results/
	cp ${runtimeHistogram}   ~/dropbox/farsite-scenarios-results/
	rm output/raster_0_*
	rm output/shape_0_*
	rm output/settings_0_*
	rm input/gen_0_ind_*.fms
	rm input/gen_0_ind_*.wnd
	rm input/gen_0_ind_*.wtr
	rm input/gen_0_ind_*.adj
	sh /home/edigley/Dropbox/doutorado_uab/scripts/shell/histogram_all_cases.sh
	/home/edigley/doutorado_uab/git/spif/fireSimulator scenario_arkadia.ini farsite_individuals_${nOfIndividuals}.txt gen 1
	/home/edigley/doutorado_uab/git/spif/fireSimulator scenario_arkadia.ini farsite_individuals_${nOfIndividuals}.txt run 1
	/usr/bin/time --format "%e %M %O %P %c %x" --output=timed_output_manual.txt timeout --signal=SIGXCPU 30.0 /home/edigley/doutorado_uab/git/farsite/farsite4P -i output/settings_0_1.txt -f 1 -t 1 -g 1 -n 0 -w 0 -p 100
	/home/edigley/doutorado_uab/git/farsite/farsite4P -i output/settings_0_1.txt -f 2


test-analysis-jonquera:
	# Input Files: individuals.txt, ignition_area.*, landscape.lcp
	cd /home/edigley/doutorado_uab/git/spif
	scenario=jonquera
	scenarioFile=scenario_${scenario}.ini
	nOfIndividuals=1000
	individuals=farsite_individuals_${nOfIndividuals}.txt
	individualsBoxPlot=farsite_individuals_${nOfIndividuals}_bloxplot.png
	runtimeOutput=farsite_individuals_runtime_${scenario}_${nOfIndividuals}.txt
	runtimeHistogram=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram.png
	mkdir ${scenario}
	cd ${scenario}
	#/home/edigley/Dropbox/doutorado_uab/scripts/shell/generate_random_individuals.sh ${nOfIndividuals} ${individuals}
	#/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_box_plot.sh ${individuals} ${individualsBoxPlot}
	#eog ${individualsBoxPlot}
	cp ${aggregationDir}/${individuals} .
	for i in `seq 1 ${nOfIndividuals}`; do time /home/edigley/doutorado_uab/git/spif/fireSimulator300 ${scenarioFile} ${individuals} run ${i} ; done
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/concatenate_all_individuals_results.sh . ${runtimeOutput}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${runtimeOutput} ${runtimeHistogram}
	eog ${runtimeHistogram} &
	cp ${individuals}        ~/dropbox/farsite-scenarios-results/
	cp ${individualsBoxPlot} ~/dropbox/farsite-scenarios-results/
	cp ${runtimeOutput}      ~/dropbox/farsite-scenarios-results/
	cp ${runtimeHistogram}   ~/dropbox/farsite-scenarios-results/
	rm output/raster_0_*
	rm output/shape_0_*
	rm output/settings_0_*
	rm input/gen_0_ind_*.fms
	rm input/gen_0_ind_*.wnd
	rm input/gen_0_ind_*.wtr
	rm input/gen_0_ind_*.adj
	sh /home/edigley/Dropbox/doutorado_uab/scripts/shell/histogram_all_cases.sh
	/home/edigley/doutorado_uab/git/spif/fireSimulator scenario_arkadia.ini farsite_individuals_${nOfIndividuals}.txt gen 1
	/home/edigley/doutorado_uab/git/spif/fireSimulator scenario_arkadia.ini farsite_individuals_${nOfIndividuals}.txt run 1
	/usr/bin/time --format "%e %M %O %P %c %x" --output=timed_output_manual.txt timeout --signal=SIGXCPU 30.0 /home/edigley/doutorado_uab/git/farsite/farsite4P -i output/settings_0_1.txt -f 1 -t 1 -g 1 -n 0 -w 0 -p 100
	/home/edigley/doutorado_uab/git/farsite/farsite4P -i output/settings_0_1.txt -f 2




	cd /home/edigley/doutorado_uab/git/spif
	make test-arkadia
	make clean
	make fire
	cd test
	cp ../test-arkadia/farsite_individuals.txt .
	/home/edigley/doutorado_uab/git/spif/fireSimulator scenario_jonquera.ini farsite_individuals.txt run 1
	for i in `seq 1 1000`; do time /home/edigley/doutorado_uab/git/spif/fireSimulator scenario_jonquera.ini farsite_individuals.txt run $i ; done




test-checar:
	individuals <- read.table("/home/edigley/doutorado_uab/git/spif/test/farsite_individuals.txt", skip=1)
	names(individuals) <- c("p0", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13", "p14", "p15", "p16", "p17", "p18", "p19", "p20")
	p <- ggplot(individuals, aes(x=z,y=y)) + geom_boxplot()

	#inputFile<-"/home/edigley/doutorado_uab/git/spif/test_running_ashley_5000_individuals/timed_output_ashley_prediction_for_30_hours.txt"
	#inputFile<-"/home/edigley/doutorado_uab/git/spif/test/timed_output_arkadia_30_horas.txt"
	#dat=read.csv("contacts.csv", skip=16, nrows=5, header=TRUE)
	grep "Command exited with non-zero status" timed_output_0_*
	Command exited with non-zero status 124
	"Command exited with non-zero status" 124 -> 841
	/home/edigley/doutorado_uab/git/spif/test_running_ashley_5000_individuals/timed_output_ashley_prediction_for_30_hours.txt

	ds<-read.table("/home/edigley/doutorado_uab/git/spif/test_running_ashley_5000_individuals/timed_output_ashley_prediction_for_30_hours.txt", header=T)
	hist(ds$runtime)
	library(ggplot2)
	ggplot(data=ds, aes(ds$runtime)) + geom_histogram(breaks=seq(0, 225, by=2), col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "green", high = "red")

	ds <- subset(ds, runtime < 3600);
	ggplot(ds, aes(runtime)) + stat_ecdf(geom="step") + labs(title="Empirical Cumulative Density Function", y="F(runtime)", x="Runtime in seconds") + theme_classic()

	individual=841
	time /home/sgeadmin/tspf/farsite/farsite4P -i output/settings_0_${individual}.txt -f 1 -t 1 -g 0 -n ${individual}

generate-central-point-from-landscape:
	/home/edigley/doutorado_uab/git/spif
	/home/edigley/doutorado_uab/git/fire-scenarios/case_2
	/home/edigley/doutorado_uab/git/fire-scenarios/arkadia
	/home/edigley/doutorado_uab/Forest-Fire-Cases/JRC_UAB_TAV/zip_file_full/TOPTEN/Data/Resultados/CASE_2/METEO







test-top-ten-scenario-set-up:
	playpen="top-ten"
	case=5
	scenario="case_${case}"
	scenarioFile="scenario_${scenario}.ini"
	outputFile="scenario_${scenario}.out"
	nOfIndividuals=1000
	individuals=farsite_individuals_${nOfIndividuals}.txt
	individualsBoxPlot=farsite_individuals_${nOfIndividuals}_bloxplot.png
	runtimeOutput=farsite_individuals_runtime_${scenario}_${nOfIndividuals}.txt
	runtimeHistogram=farsite_individuals_runtime_${scenario}_${nOfIndividuals}_histogram.png
	cd /home/edigley/doutorado_uab/git/spif
	mkdir -p ${playpen}/input
	mkdir ${playpen}/input ${playpen}/output ${playpen}/trace
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/landscape/  ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/perimetres/ ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/qgis/${scenario}_central_point* ${playpen}/perimetres/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/aux_files/  ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/bases/      ${playpen}/
	ln -s ~/doutorado_uab/git/fire-scenarios/${scenario}/scripts/    ${playpen}/
	cp ~/doutorado_uab/git/fire-scenarios/${scenario}/scenario_template_for_histogram.ini ${playpen}/${scenarioFile}
	cp ~/doutorado_uab/git/fire-scenarios/${scenario}/input/pob_0.txt ${playpen}/input/
	cd ${playpen}
	#/home/edigley/Dropbox/doutorado_uab/scripts/shell/generate_random_individuals.sh ${nOfIndividuals} ${individuals}
	#/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_box_plot.sh ${individuals} ${individualsBoxPlot}
	#eog ${individualsBoxPlot}
test-top-ten-scenario-run:
	cd /home/edigley/doutorado_uab/git/spif/${playpen}/
	cp ~/dropbox/farsite-scenarios-results/${individuals} .
	#for i in `seq 1 ${nOfIndividuals}`; do time /home/edigley/doutorado_uab/git/spif/fireSimulator ${scenarioFile} ${individuals} run ${i} ; done
	time /home/edigley/Dropbox/doutorado_uab/scripts/shell/run-all-individuals-in-range.sh ${scenarioFile} ${individuals} 1 1000 ${outputFile}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/concatenate_all_individuals_results.sh . ${runtimeOutput}
	/home/edigley/Dropbox/doutorado_uab/scripts/shell/random_individuals_histogram.sh ${runtimeOutput} ${runtimeHistogram}
	eog ${runtimeHistogram} &
test-top-ten-scenario-clean-up:
	cp ${individuals}        ~/dropbox/farsite-scenarios-results/
	cp ${individualsBoxPlot} ~/dropbox/farsite-scenarios-results/
	cp ${runtimeOutput}      ~/dropbox/farsite-scenarios-results/
	cp ${runtimeHistogram}   ~/dropbox/farsite-scenarios-results/
	cp ${outputFile}         ~/dropbox/farsite-scenarios-results/
	rm gmon.out
	rm timed_output_0_*.txt
	rm output/raster_0_*
	rm output/shape_0_*
	rm output/settings_0_*
	rm input/gen_0_ind_*.fms
	rm input/gen_0_ind_*.wnd
	rm input/gen_0_ind_*.wtr
	rm input/gen_0_ind_*.adj
	cd /home/edigley/doutorado_uab/git/spif/
	mv top-ten/ ${scenario}
	#for i in `seq 1 1000`; do pkill -kill fireSimulator; done
	#/home/edigley/doutorado_uab/git/spif/top-ten/landscape
	#~/dropbox/farsite-scenarios-results/


# time /home/edigley/Dropbox/doutorado_uab/scripts/shell/run-all-cases-in-range.sh 6 10
# /home/edigley/doutorado_uab/git/farsite/farsite4P -i output/settings_0_2.txt -f 1
# edigley@cariri:~/doutorado_uab/git/spif/jonquera$ /home/edigley/doutorado_uab/git/farsite/farsite4P -i output/settings_0_2.txt -f 1
# Update File GEN_0_IND_2.FMS before continuing   Fuel Model 1 Has No Initial Fuel Moisture
# edigley@cariri:~/doutorado_uab/git/spif/jonquera$ 


