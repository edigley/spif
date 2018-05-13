#include "master.h"
#include <stdio.h>
#include "mpi.h"
#include "iniparser.h"
#include "population.h"
#include "mpi.h"
#include "MPIWrapper.h"
#include "myutils.h"
#include "genetic.h"

#define SIM_DEFAULT 0
#define SIM_FARSITE 1
#define SIM_SIM2 2
#define SIM_SIM3 3

// variables 

char *  simulator;
char *  range_file;
int 	numind;
float 	elitism;
float 	pMutation;
float 	pCrossover;
int     numGenerations;
int 	chunkSize;
int     ntasks;
int     cantGrupos;
int     rest;
int     numgen;
int 	crossMethod;


// mapas, ficheros que contienen las lineas de fuego
char * start_line;
char * real_line;
char * simulated_line;

// dimensiones de los mapas
int Rows;
int Cols;
double CellWd;  // son cuadradas por el momento, leo solo 1 dimension
double CellHt; 

// poblacion
char * 	pobini;
char * population_error;
char * final_popu;
char * bests_indv;

POPULATIONTYPE p;

static int guidedEllitism;
static int guidedMutation;

// METODO COMPUTACIONAL: 0:NO ARMO TABLAS, 1: ARMO NUEVAS  2: AGREGO EN TABLA EXISTENTE
int armarTabla;
char * fTabla ;
double valorDireccion;  // valores utilizados como amplitud del nuevo subrango
double valorVelocidad;
int doComputacional;
char *alg; // tipo de algoritmo de optimizacion, hasta hoy solo genetico

/********************************************************************/
  // determino como se repartira la poblacion entre los workers
/********************************************************************/

int defineBlockSize()
{

    if (chunkSize == 0){
            chunkSize = (int)(numind / (ntasks - 1));
            cantGrupos = (ntasks - 1);
    }
    else 
            cantGrupos = (int)(numind / chunkSize);
    
    rest = numind % (ntasks - 1);
    //if (rest > 0)
    //        cantGrupos = cantGrupos + 1;

    return (0);

}

/********************************************************************/
// MASTER MAIN FUNCTION
/********************************************************************/
int master(char * datosIni, int ntareas)
{
   char gen_str[3];
   char new_gen_str[3];
   char *pob_str = (char*)malloc(sizeof(char) * 100);
   char *pob_str_errors = (char*)malloc(sizeof(char) * 100);
   char *new_pob_str = (char*)malloc(sizeof(char) * 100);
   numgen = 0;
   double t1,t2;
   int nextgen = 0;

   ntasks = ntareas;

   int nworkers = ntasks -1;
	
   initMaster(datosIni);

   defineBlockSize();
   
   while(numgen < numGenerations)
   {
      t1 = MPI_Wtime();
      sprintf(gen_str,"%d",numgen);
      nextgen = numgen + 1;
      sprintf(new_gen_str,"%d",nextgen);
      pob_str = str_replace(pobini, "$1", &gen_str);
      new_pob_str = str_replace(pobini, "$1", &new_gen_str);
      pob_str_errors = str_replace(population_error, "$1", &gen_str);
      //printf(("Fichero:%s\n", pob_str);
      
      get_population_farsite(&p, pob_str);

      //printf(("INIT:Num ind:%d  Workers:%d  Grupos:%d  Rest:%d  ChunkSize:%d\n",numind, nworkers, cantGrupos, rest, chunkSize);
      
      repartirPoblacionFarsite(&p, nworkers);
      
      sortPopulationByErrorFarsite(&p);

      //print_population_farsite(p);
      
      save_population_farsite(p, pob_str_errors);

        t2 = MPI_Wtime();
      //printf(("Master Total Time: %1.2f\n",t2-t1);
      //printf(("popuSize: %d\n",p.popuSize); 
      //evolucionarPoblacionInicial(&p, numind, numGenerations, nworkers, chunkSize);
      //evolve_population_farsite (&p, elitism, pCrossover, pMutation, range_file, bests_indv, new_pob_str);
      
      // EVOLVE POPULATION
      //printf(("GENETIC_Init_Farsite: BEGIN\n");
      
      if(GENETIC_Init_Farsite(elitism,pCrossover,pMutation,range_file,bests_indv,1,0,crossMethod)<1){
          printf("\nERROR Initializing Genetic Algorithm! Exiting...\n");
	  return -1;
      }
      //printf(("GENETIC_Init_Farsite: END\n");
      
      //printf(("GENETIC_Algorithm_Farsite: BEGIN\n");

      if(GENETIC_Algorithm_Farsite(&p, new_pob_str)<1){
          printf("\nERROR Running Genetic Algorithm! Exiting...\n");
          return -1;
      }

      //printf(("GENETIC_Algorithm_Farsite: END\n");

      numgen++;
      ////printf(("master: ntask:%d nworkers: %d popu_size:%d  \n", ntasks, nworkers, p.popuSize);
      //printf("Elitismo: %1.2f mutación: %1.2f cruzamiento: %1.2f Generaciones:%d  \n", elitism, pMutation, pCrossover,numGenerations);
   }
   
   fin_workers(nworkers);
}

int initMaster(char * filename)
{
    dictionary * datos;
    datos 	= iniparser_load(filename);

  // fichero y size de individuos (conj de parametros)
    pobini              = iniparser_getstr(datos, "main:initial_population");
    population_error    = iniparser_getstr(datos, "main:population_error");
    range_file          = iniparser_getstr(datos, "main:range_file");
    final_popu          = iniparser_getstr(datos, "main:final_population");
    bests_indv          = iniparser_getstr(datos, "main:bests_indv");
    simulator           = iniparser_getstr(datos, "main:simulator");
    chunkSize           = iniparser_getint(datos, "main:chunkSize",1);
    numind              = iniparser_getint(datos, "main:numind",1);
    
    elitism         = iniparser_getint(datos, "genetic:elitism",1);
    pMutation       = iniparser_getdouble(datos, "genetic:pMutation",1.0);
    pCrossover      = iniparser_getdouble(datos, "genetic:pCrossover",1.0);
    numGenerations  = iniparser_getint(datos, "genetic:numGenerations", 1);
	 crossMethod 	  = iniparser_getint(datos, "genetic:crossover_method", 1);

    //lee todo lo que necesita del diccionario datos.ini
   real_line = iniparser_getstr(datos, "maps:real_fire_line");
   start_line = iniparser_getstr(datos, "maps:start_fire_line");
   simulated_line = iniparser_getstr(datos, "maps:sim_fire_line");

   // dimensiones mapas
   Rows = iniparser_getint(datos, "mapssize:rows", 100);
   Cols = iniparser_getint(datos, "mapssize:cols", 100);
   CellWd = iniparser_getdouble(datos, "mapssize:CellWd", 1.0);
   CellHt = iniparser_getdouble(datos, "mapssize:CellHt", 1.0);

   // number of iterations (to evolve the population)
    alg     = iniparser_getstr(datos, "main:algorithm");
   return (0);
}

/********************************************************************/
// END workers
/********************************************************************/
void fin_workers(int nworkers)
{
   int worker_counter = 1;

   for (worker_counter = 1; worker_counter <= nworkers; worker_counter++)
     SendMPI_Finish_Signal(worker_counter);
   
   //MPI_Send(&flag, 1, MPI_INT, worker, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD);
}

int getAvailWorker(int * worker_busy, int size)
{
  int pos = -1;
  int i = 0;
  while ((i < size) && (pos == -1))
  {
    if (worker_busy[i] == 0)
      pos = i;
    else
      i++;
  }
  return pos;
}

int repartirPoblacionFarsite(POPULATIONTYPE *p, int  nworkers)
{
  int ind_counter = 0;
  int * worker_busy = (int*)calloc(nworkers, sizeof(int));
  int pos = 0, i;
  int block_sended = 0;
  int block_received = 0;
  int restSend = numind;
  int restReceive = numind;

  INDVTYPE_FARSITE * poblacion = NULL;

  poblacion = p->popu_fs;

    while ((pos = getAvailWorker(worker_busy, nworkers)) != -1)
    {
        if(restSend >= chunkSize){
           Master_SendMPI_SetOfIndividualTask(pos + 1, chunkSize, block_sended, numgen, numind, poblacion);
           restSend -= chunkSize;
        }
        else{
           Master_SendMPI_SetOfIndividualTask(pos + 1, restSend, block_sended, numgen, numind, poblacion);
           restSend = 0;
        }
        worker_busy[pos] = 1;
        block_sended++;
    }
    while(block_sended < cantGrupos)
    {
        if(restReceive >= chunkSize){
           pos = Master_ReceiveMPI_IndividualError(block_received, p->popu_fs, numind, chunkSize);
           restReceive -= chunkSize;
        }
        else{
           pos = Master_ReceiveMPI_IndividualError(block_received, p->popu_fs, numind, restReceive);
           restReceive = 0;
        }
        worker_busy[pos - 1] = 0;
        block_received++;

        if(restSend >= chunkSize){
           Master_SendMPI_SetOfIndividualTask(pos, chunkSize, block_sended, numgen, numind, poblacion);
           restSend -= chunkSize;
        }
        else{
           Master_SendMPI_SetOfIndividualTask(pos, restSend, block_sended, numgen, numind, poblacion);
           restSend = 0;
        }
        block_sended++;
    }
    while (block_received < cantGrupos)
    {
        if(restReceive >= chunkSize){
           pos = Master_ReceiveMPI_IndividualError(block_received, p->popu_fs, numind, chunkSize);
           restReceive -= chunkSize;
        }
        else{
           pos = Master_ReceiveMPI_IndividualError(block_received, p->popu_fs, numind, restReceive);
           restReceive = 0;
        }
        worker_busy[pos - 1] = 0;
        block_received++;
    }
   printf("TERMINO MASTER\n"); 
}
/********************************************************************/
// Distribute individuals in workers
/********************************************************************/
int repartirPoblacion(POPULATIONTYPE *p, int numind, int  nworkers, int cantBloques, int rest, int chunkSize)
{
   
  double a=1.0;
  int worker,j; 
  int nroBloque, bloquesRecibidos, bloquesEnviados;
  int dimBloqueR, nroBloqueR;

  MPI_Status status;
 
  INDVTYPE *poblacion, *poblacionProcesada;

  poblacion = (INDVTYPE *)malloc(sizeof(INDVTYPE)*numind);
 // para almacenar los bloques que recibo desde los workers
  poblacionProcesada = (INDVTYPE *)malloc(sizeof(INDVTYPE)*numind);

 // poblacion sin procesar
  poblacion = p->popu;


 // primer bucle = todos los nodos libres, asigno 1 grupo por nodo de forma secuencial
  nroBloque=0;
  bloquesEnviados = 0;
  worker = 1; // comienzo desde el primer worker
// mientras haya workers o bloques para distribuir
  while((worker <= nworkers) && (nroBloque < cantBloques))
  { 
     MPI_Send(&chunkSize, 1, MPI_INT, worker, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD);
     MPI_Send(&nroBloque, 1, MPI_INT, worker, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD);
     MPI_Send((char *)(poblacion+(nroBloque*chunkSize)), sizeof(struct indvtype)*chunkSize, MPI_UNSIGNED_CHAR, worker, 1, MPI_COMM_WORLD);
     nroBloque++;
     worker++;
     bloquesEnviados ++;
  }
    
  // el siguiente while es para un futuro, donde cantBloques > nworkers y los sigo repartiendo "bajo demanda"
  bloquesRecibidos = 0;
  while (bloquesRecibidos < cantBloques)
  {
    // recibo un bloque procesado desde cualquier worker 
     MPI_Recv(&dimBloqueR, 1, MPI_INT, MPI_ANY_SOURCE, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD, &status);
     MPI_Recv(&nroBloqueR, 1, MPI_INT, MPI_ANY_SOURCE, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD, &status);
     MPI_Recv((poblacionProcesada+(bloquesRecibidos*chunkSize)), sizeof(struct indvtype)*dimBloqueR, MPI_UNSIGNED_CHAR, status.MPI_SOURCE, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD, &status);
     bloquesRecibidos++;

     //printf("MASTER recibi desde worker %d el bloque %d con dimension %d \n", status.MPI_SOURCE, nroBloqueR, dimBloqueR);

// si quedan bloques por enviar...
    if (bloquesEnviados < cantBloques)
    {
      MPI_Send(&chunkSize, 1, MPI_INT, worker, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD);
      MPI_Send(&nroBloque, 1, MPI_INT, worker, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD);
		// Carlos B. & Abel C. (worker<-->status.MPI_SOURCE)
      MPI_Send((char *)(poblacion+(nroBloque*chunkSize)), sizeof(struct indvtype)*chunkSize, MPI_UNSIGNED_CHAR, status.MPI_SOURCE, 1, MPI_COMM_WORLD);
      nroBloque++;
      //worker++;
      bloquesEnviados ++;
    }

  } //while bloquesRecibidos < cantBloques == queden bloques por recibir desde los workers


  //printf("fin procesamiento de la generacion numero....\n");

  p->popu = poblacionProcesada;
 
  free(poblacion);
  free(poblacionProcesada);

}


/*******************************************************************************/
// aplica algoritmo evolutivo sobre la poblacion  por si agrego mas algoritmos
/*******************************************************************************/
int apply_EVOLUTE(POPULATIONTYPE * P)
{

    if (strcmp(alg, "GA") == 0)
    {
       printf("Aplicando GENETICO\n");
       //GENETIC_Algorithm(&p);
    }
}

  // me comunico con el worker 0 para que retorne los datos del mapa real
void obtenerValoresPropagacionReal(double * direccionReal, double * velocidadReal, double * distanciaReal)
{
  
  MPI_Status status;
  int idPrimerWorker = 1; // pues los ids van de 0 a n-1 hence worker0 tiene id=1 
  
   double vec[3];
// me comunico con el worker 0 para que me devuelva los datos de la propagacion real
   MPI_Recv(vec, 3, MPI_DOUBLE, idPrimerWorker, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD, &status);
   * direccionReal = vec[0];
   * velocidadReal = vec[1];
   * distanciaReal = vec[2];
}

/*****************************************************************************************/
// evoluciono la poblacion tantas veces como se quiera
/*****************************************************************************************/
int evolucionarPoblacionInicial(POPULATIONTYPE *p, int numind, int numGeneraciones, int nworkers, int chunkSize)
{
   int rest, cantBloques;
   int geneActual;

  // determino como se repartira la poblacion entre los workers
    defineBlockSize(nworkers, numind, &rest, &cantBloques, &chunkSize);
 
 // evoluciono la poblacion
   geneActual = 0;
   while (geneActual < numGeneraciones)
   {  
      // en GENETIC_Algorithm escribo la poblacion en generacion.txt luego
      // de realizar la evolucion (seleccin, crossover, mutacion)
      if (geneActual != 0)
        get_population_farsite(p, "generacion.txt");
      
      repartirPoblacion( p, numind, nworkers, cantBloques, rest, chunkSize);
      save_bestIndv(p,bests_indv);

    // esto lo tendria que hacer pero no en la ultima vuelta??
      apply_EVOLUTE(p);

    // incremento el numero de generacion actual QUE NO IRIA ACA!!!
      p->currentGen = p->currentGen + 1;

      geneActual ++;
   }

//printf("desde evolucionarPoblacionInicial \n");
//   print_populationScreen(*p);
    fin_workers(nworkers);

}

