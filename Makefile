# makefile for fireSim, a sample fire behavior simulator using fireLib
# Collin D. Bevins, October 1996

# The following rules work for UnixWare 2.0.
CC = "/home/edigley/.openmpi/bin/mpicc"
CFLAGS = -g -pg -DNDEBUG
PATH_PROY = "/home/edigley/doutorado_uab/two_stage_framework/"
LIBS = -lm
FILES = $(PATH_PROY)main.c $(PATH_PROY)master.c $(PATH_PROY)worker.c $(PATH_PROY)dictionary.c $(PATH_PROY)iniparser.c $(PATH_PROY)strlib.c $(PATH_PROY)population.c $(PATH_PROY)farsite.c $(PATH_PROY)MPIWrapper.c $(PATH_PROY)fitness.c $(PATH_PROY)myutils.c $(PATH_PROY)windninja.c $(PATH_PROY)genetic.c

all:
	$(CC) $(CFLAGS) $(FILES) -o $(PATH_PROY)genetic $(LIBS)

clean:
	rm -rf $(PATH_PROY)*.o $(PATH_PROY)genetic
# End of makefile

# cd /home/edigley/doutorado_uab/two_stage_framework
# sh -x CAL_1/input/clean_input_output.sh
# rm farsite ; mpicc -g -pg -DNDEBUG farsite.c strlib.c dictionary.c population.c fitness.c myutils.c iniparser.c genetic.c -o farsite -lm && ./farsite /home/edigley/doutorado_uab/resultados/128_cluster_size_8_c1.xlarge/Datos_CASE_7_BASIC_1.ini
