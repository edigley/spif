#define MASTER_TO_WORKER_OK_TAG 1
#define WORKER_TO_MASTER_OK_TAG 1
#define MASTER_TO_WORKER_FAILED_TAG 0
#define WORKER_TO_MASTER_FAILED_TAG 0
#define MASTER_ID 0

#include "population.h"

int master(char * datosIni, int ntasks);
int defineBlockSize();
int initMaster();
void fin_workers(int nworkers);
int repartirPoblacion(POPULATIONTYPE *p, int numind, int  nworkers, int cantBloques, int rest, int chunkSize);
int get_population_farsite(POPULATIONTYPE * pobla, char * nombreInitSet);
int get_population_default(POPULATIONTYPE * pobla, char * nombreInitSet);
int evolucionarPoblacionInicial(POPULATIONTYPE *p, int numind, int numGeneraciones, int nworkers, int chunkSize);
