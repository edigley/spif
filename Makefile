# makefile for fireSim, a sample fire behavior simulator using fireLib
# Collin D. Bevins, October 1996

# The following rules work for UnixWare 2.0.
CC = mpicc
CFLAGS = -fopenmp -g 
PATH_PROY = ./
LIBS = -lm
FILES = $(PATH_PROY)main.c $(PATH_PROY)master.c $(PATH_PROY)worker.c $(PATH_PROY)dictionary.c $(PATH_PROY)iniparser.c $(PATH_PROY)strlib.c $(PATH_PROY)population.c $(PATH_PROY)farsite.c $(PATH_PROY)MPIWrapper.c $(PATH_PROY)fitness.c $(PATH_PROY)myutils.c $(PATH_PROY)windninja.c $(PATH_PROY)genetic.c

normal:
	$(CC) $(CFLAGS) $(FILES) -o genetic $(LIBS)

all:
	$(CC) $(CFLAGS) $(FILES) -o genetic $(LIBS)
	$(CC) $(CFLAGS) $(FILES) -o genPopulation $(LIBS)
	$(CC) $(CFLAGS) $(FILES) -o farsiteWraper $(LIBS)

farsite:
	mpicc -g -pg -DNDEBUG farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o farsite -lm

clean:
	rm -rf $(PATH_PROY)*.o $(PATH_PROY)genetic $(PATH_PROY)genPopulation $(PATH_PROY)farsiteWraper
# End of makefile

# Vai começar...
#FARSITE: vai executar...
# ---> getSimulationError.simulatedMap /home/edigley/doutorado_uab/so_oh_leite/two_stage_prediction_framework/jonquera/output/raster_1_85.toa
# ---> getSimulationError.real_fire_map_t1 /home/edigley/doutorado_uab/so_oh_leite/two_stage_prediction_framework/jonquera/perimetres/per2.asc
# ---> getSimulationError.real_fire_map_tINI /home/edigley/doutorado_uab/so_oh_leite/two_stage_prediction_framework/jonquera/perimetres/per1.asc
# ---> getSimulationError.real_fire_map_t1.fd name(xllcorn) val(0.000000) rrows(0) rcols(0)
# ---> getSimulationError.real_fire_map_tINI.fd2 name(xllcorn) val(0.000000) aux(-680573732)
# ---> getSimulationError.simulatedMap /home/edigley/doutorado_uab/so_oh_leite/two_stage_prediction_framework/jonquera/output/raster_1_85.toa
# ---> getSimulationError.simulatedMap.fd name(  cols:) val(0.000000) srows(1125) scols(1612)
#FARSITE: Execução concluída.
# error: 0.994937
# &error: 0.994937
#
# make farsite
# ./farsite scenario.ini pob_0_1.txt 0
