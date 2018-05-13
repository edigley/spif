#include "mpi.h"
#include "worker.h"
#include <stdio.h>
#include "population.h"
#include <stdlib.h>
#include "iniparser.h"
#include <sys/types.h>
#include <sys/stat.h>
#include "farsite.h"
#include "MPIWrapper.h"
#include "windninja.h"

#define INFINITY 999999999.
#define PRINTRESULTS 1
#define PRINTDATOSREALES 1

char *  simulator;
int 	numind;
float 	elitism;
float 	pMutation;
float 	pCrossover;
int	numGenerations;
int 	chunkSize;
int     doWindFields;
int     doMeteoSim;
char    *alg;
int     myid;

char    *elevfilename;
char    *prjfilename;
char    *elevfilepath;
char    *wn_output_path;
char    *baseAtmFile, *atmFileNew, *atmFile;
char    *resolution;
char    *VGeneral;
char    *VGrid;
char    *windinit;
char    *vegetation;
int     wn_num_theads;
char    *wn_path;
char    *atm_file;

// poblacion
char * 	pobini;
char * final_popu;
char * bests_indv;

// mapas, ficheros que contienen las lineas de fuego
char * start_line;
char * real_line;
char * simulated_line;

// mapas
static double * real_map_t1; 
static double * init_map_t0; 
static double * ign_map;

// dimensiones de los mapas
static int Rows;
static int Cols;
static double CellWd;  // son cuadradas por el momento, leo solo 1 dimension
static double CellHt; 

// tiempos t0 y t1
static double start_time;
static double final_time;

// analisis del mapa real, lo realiza cada worker y evito enviarlo por msg
static double direccion, velocidad, dist,fit, elapsedTime;
static double noIgnValue,distFeets, error;
static int p1x, p1y, p2x, p2y; // puntos de max propagacion del mapa real para enviar a runsim

// estas sirven para los metodos analitico y computacional propagacion real!!
static double dirPropagacionReal;
static double distanciaRealFeets;
static double velocidadRealFeets;
// especifico del computacional
static int doComputacional;
static char * fTabla;
static int armarTabla;  // 0: NO ARMAR  1:ARMAR NUEVA  2: AGREGAR EN TABLA YA CREADA
// esto lo necesito para el COMPUTACIONAL para armar las tablas
static int Model;
static double Slope;

double comm_time = 0;


//prototipos (si cal)
int  getFinalFireLine(char * real_line, int Rows, int Cols, double * realMap);
static int PrintMap (double * map, char *fileName, int Rows, int Cols);


/*************************************************************************************/
// ninicializa los datos del worker, mapas y tiempos
/*************************************************************************************/
int initWorker(char * datafile)
{
    dictionary * datos;
    datos 	= iniparser_load(datafile);

  // fichero y size de individuos (conj de parametros)
    pobini  	= iniparser_getstr(datos, "main:initial_population");
    final_popu 	= iniparser_getstr(datos, "main:final_population");
    bests_indv 	= iniparser_getstr(datos, "main:bests_indv");
    simulator   = iniparser_getstr(datos, "main:simulator");
    chunkSize   = iniparser_getint(datos, "main:chunkSize",1);
    numind          = iniparser_getint(datos, "main:numind",1);
    doWindFields    = iniparser_getint(datos, "main:doWindFields", 0);
    doMeteoSim    = iniparser_getint(datos, "main:doMeteoSim", 0);
    
    elitism         = iniparser_getint(datos, "genetic:elitism",1);
    pMutation       = iniparser_getdouble(datos, "genetic:pMutation",1.0);
    pCrossover      = iniparser_getdouble(datos, "genetic:pCrossover",1.0);
    numGenerations  = iniparser_getint(datos, "genetic:numGenerations", 1);

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
    
   // windninja 
    elevfilename    = iniparser_getstr(datos, "windninja:elevfilename");
	 prjfilename    = iniparser_getstr(datos, "windninja:prjfilename");
    wn_output_path  = iniparser_getstr(datos, "windninja:wn_output_path");
    elevfilepath   = iniparser_getstr(datos, "windninja:elevfilepath");
    atm_file   = iniparser_getstr(datos, "windninja:atmFile");
    
   return (0);
}

//solo se lee el mapa real en t1 xq  el otro se lee en runsim
int getMaps()
{
  
  // aloco memoria para los mapas
  if ( (real_map_t1 = (double *)calloc(Rows*Cols, sizeof(double))) == NULL 
     || (init_map_t0 = (double *)calloc(Rows*Cols, sizeof(double))) == NULL 
     || ((ign_map = (double *)calloc(Rows*Cols, sizeof(double)))) == NULL )
     {
       printf("No aloca lugar para real_map, init_map o ign_map \n");
       return -1;
     }

// el mapa inicial se lee en fireSim, aca solo mapa real
    //printf("Leyendo el mapa real en t1 desde %s \n", real_line);
    getFinalFireLine(real_line, Rows, Cols, real_map_t1);

   PrintMap(real_map_t1, "mapaT1", Rows, Cols);

    return 1;
}



/**************************************************************************/
// PROCESAMIENTO DE UN INDIVIDUO llamado desde procesarBloque
/**************************************************************************/
int procesarIndividuo(INDVTYPE *individuo, char * nombre_init_map_t0, double start_time, double *  real_map_t1, double final_time, int Rows, int Cols)
{
  
  double wnddir, wndvel;
  int p1x, p1y, p2x, p2y;
  int p1xAux, p1yAux, p2xAux, p2yAux;
  double fit, error;

   print_indv_default(*individuo);
    
   // llamo al simulador con el individuo y

   // Carlos B. & Abel C
   // system(command); to call a external synchronous process

   //Carlos B.*****runsim(*individuo, ign_map, dirPropagacionReal, distanciaRealFeets, elapsedTime, p1x, p1y, p2x, p2y, &wnddir, &wndvel);
  // PrintMap(ign_map, "simulado.map", Rows, Cols);


 // valor de celdas no quemadas en ignMap==INFINITY
     noIgnValue = 999999999.;
  // faltan declarar todas estas variables
     //Carlos B.*****dist = distanciaMaxPropagacionReal(ign_map, Rows, Cols, start_time, final_time, &direccion, &velocidad, noIgnValue, &elapsedTime, CellHt, &p1xAux, &p1yAux, &p2xAux, &p2yAux);
     //Carlos B.*****fit = fitnessYError(real_map_t1, ign_map, Rows, Cols, start_time, final_time, &error);
#if PRINTRESULTS
     printf("****************************** RESULTS ********************************** \n");
     printf("Distancia: %f feets  (%f metros) \n ", dist, (dist / 3.28083));
     printf("Direccion: %f \n ", direccion);
     printf("Velocidad: %f (feets/min) %f (metros/min)\n ", velocidad, (velocidad)/3.28083 );
     printf("Fitness mapas: real: %s, time: %f y  time: %f \n", real_line, start_time, final_time);
     printf("Fitness: %f -- Error: %f \n", fit, error);
     printf("*********************************************************************** \n");
#endif

      individuo->fit = fit;
      individuo->dir = direccion;
      individuo->dist = dist;
      individuo->vel = velocidad;
      individuo->error = error;
      individuo->wnddir = wnddir;
      individuo->wndvel = wndvel;

   return 1;
}

/**************************************************************************/
// PROCESAMIENTO DEL BLOQUE ENVIADO 
/**************************************************************************/
void procesarBloque(INDVTYPE * individuos, int dimBloque)
{
   int i;

   for (i=0; i<dimBloque; i++)
   {
       procesarIndividuo(&individuos[i], start_line, start_time, real_map_t1, final_time, Rows, Cols);
    //   individuos[i].error = 1.0;
   }

}

void procesarBloqueFarsite(INDVTYPE_FARSITE * individuos, int numgen, char * datos)
{
   int i;
   float v,d;
   double err;
   struct stat st;
   char * path_output;
   char * atmPath;
   char * buffer = (char*)malloc(sizeof(char) * 10);
   
   //printf("procesarBloqueFarsite::El chunksize es %d\n",chunkSize);
   for (i=0; i<chunkSize; i++)
   {        
        //print_indv_farsite(individuos[i]);
        if (doWindFields == 1 && doMeteoSim == 0)
        {
            sprintf(buffer,"%d", individuos[i].id);
            path_output = str_replace(wn_output_path,"$1", buffer);

            if(stat(path_output, &st) == 0)
              deleteFilesFromFolder(path_output,"*");
            else
              createFolder(path_output);
              // link a elevfilename
            createLinkToFile(elevfilename, elevfilepath, path_output);
				createLinkToFile(prjfilename, elevfilepath, path_output);
            
            v = individuos[i].wndvel;
            d = individuos[i].wnddir;
            int idInd = individuos[i].id;

            atmPath = runWindNinja(path_output, v, d, idInd, datos);
        }
        if(doMeteoSim == 0)
        		runSimFarsite(individuos[i], "FARSITE", &err, numgen, atmPath, datos);
		  else
			runSimFarsite(individuos[i], "FARSITE", &err, numgen, atm_file, datos);
        individuos[i].error = err;
        
        //printf("Worker:%d Error Individuo(%d): %1.4f\n", myid, individuos[i].id, individuos[i].error);
        
   }

}


/******************************************************************************/
// lee el mapa de fuego inicial desde fichero de COORDENADAS
/******************************************************************************/
int getInitFireLine(char * start_line, int Rows, int Cols, double * ignMap, double start_time)
{

   int cell=0, size;
   int x,y;

   FILE * fiche;

   if ((fiche = fopen(start_line, "r")) == NULL)
   {
      printf("getInitFireLine:: error al abrir el fichero %s \n ", start_line);
      return -1;
   }
  // leo la cant de celdas quemadas del fichero
   fscanf(fiche, "%d \n", &size);

  // leo la celda y le pongo el tiempo de inicio de fuego
   for (cell = 0; cell < size; cell ++)
   {
      fscanf(fiche, "%d %d \n", &x, &y);        //.coo = (x,y) por lo tanto, x==columna y==fila
      ignMap[(y-1) * Cols + (x-1)] = start_time;
   }
  fclose(fiche);
}


/******************************************************************************/
// lee el mapa de fuego final para comparar con la simulacion 
/******************************************************************************/
int  getFinalFireLine(char * real_line, int Rows, int Cols, double * realMap)
{

   FILE * fil;
   int cell;

   if ((fil = fopen(real_line, "r")) == NULL)
   {
       printf("No se puede abrir el fichero de la linea de fuego real %s \n ", real_line);
       return 0;
   }

   for (cell = 0; cell < Rows*Cols; cell ++)
      fscanf(fil, "%lf", &realMap[cell]);

// PrintMap(realMap, "sale1", Rows, Cols);
   fclose(fil);
   return 1;
}


/******************************************************************************/
// imprime el mapa pasado como parametro map en fileName  
/******************************************************************************/
static int PrintMap (double * map, char *fileName, int Rows, int Cols)
{
    FILE *fPtr;
    int cell, col, row;

    if ( (fPtr = fopen(fileName, "w")) == NULL )
    {
        printf("Unable to open output map \"%s\".\n", fileName);
        return (-1);
    }

 //   fprintf(fPtr, "north: %1.0f\nsouth: %1.0f\neast: %1.0f\nwest: %1.0f\nrows: %d\ncols: %d\n",
 //       (Rows*CellHt), 0., (Cols*CellWd), 0., Rows, Cols);
    for ( row = 0; row < Rows; row++ )
    {
        for ( cell = row*Cols, col=0; col<Cols; col++, cell++ )
        {
            fprintf(fPtr, " %1.2f", (map[cell]==INFINITY) ? 0.0 : map[cell]);
        }
        fprintf(fPtr, "\n");
    }
    fclose(fPtr);
    return (1);
}


/***************************************************************************/
// PROCESAMIENTO PRINCIPAL DEL WORKER
/***************************************************************************/
void old_worker(int taskid, char * datafile)
{

   int dimBloque, nroBloque;
   INDVTYPE *individuos;
   int i, seguir, myid;   


   initWorker(datafile);
   getMaps();
   //Carlos B.*****analizarMapaReal();

   unsigned char *msgGrupo;
   INDVTYPE *grupoIndvs;
   MPI_Status status;
   

// METODO COMPUTACIONAL solo el worker==1 envia al master los datos del mapa real
   MPI_Comm_rank(MPI_COMM_WORLD, &myid);
   
   if ((doComputacional) && (myid == 1))
   {
       double vec[3];

       vec[0] = dirPropagacionReal;
       vec[1] = velocidadRealFeets;
       vec[2] = distanciaRealFeets;
      
       MPI_Send(vec, 3, MPI_DOUBLE, MASTER_ID, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD);
   }


   // seguir flag para seguir procesando o no.... si recibo dimBloque = -1 es que tengo que parar
  seguir = 1;
  while (seguir)
  {
    // recibo la dimension del bloque (si es = -1 es el flag de fin
     MPI_Recv(&dimBloque, 1, MPI_INT, MASTER_ID, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD, &status);
     if (dimBloque < 0)
        seguir = 0;
     
     if (seguir)
     {
       // recibo el nro de bloque (dentro de la poblacion original)   
        MPI_Recv(&nroBloque, 1, MPI_INT, MASTER_ID, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD, &status);
      // aloco memoria para el bloque y la subpoblacion  
       msgGrupo = (unsigned char *)malloc(sizeof(INDVTYPE) * dimBloque);
       individuos = (INDVTYPE *)malloc(sizeof(INDVTYPE) * dimBloque);
       // recibo bloque  
       MPI_Recv(msgGrupo, sizeof(INDVTYPE)*dimBloque, MPI_UNSIGNED_CHAR, MASTER_ID, MASTER_TO_WORKER_OK_TAG, MPI_COMM_WORLD, &status);

       individuos = (INDVTYPE*) msgGrupo;

       //printf("soy el worker id:%d y recibi dimBloque: %d y nroBloque:%d \n", taskid, dimBloque, nroBloque);
  
      // PROCESAMIENTO!!!!!!!!!!!!!! 
    //   for (i=0; i<dimBloque; i++)
    //     individuos[i].error = 1.0;
       procesarBloque(individuos,dimBloque);


       msgGrupo = (unsigned char *) individuos;
      // envio los datos al MASTER
       MPI_Send(&dimBloque, 1, MPI_INT, MASTER_ID, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD);
       MPI_Send(&nroBloque, 1, MPI_INT, MASTER_ID, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD);
       MPI_Send(msgGrupo, sizeof(INDVTYPE) * dimBloque,MPI_UNSIGNED_CHAR, MASTER_ID, WORKER_TO_MASTER_OK_TAG, MPI_COMM_WORLD);
     } // if seguir
  } // while seguir

  free(real_map_t1);
  free(init_map_t0);
  free(ign_map);

}

void worker(int taskid, char * datosIni)
{
    int stop = 0; 
    int nroBloque;
    int num_generation;
    double t1,t2, t3, t4;
    
    INDVTYPE_FARSITE * poblacion = (INDVTYPE_FARSITE*)malloc(chunkSize * sizeof(INDVTYPE_FARSITE));
    
    initWorker(datosIni);

    MPI_Comm_rank(MPI_COMM_WORLD, &myid);
    
    do
    {
	   comm_time = 0;
      t1 = MPI_Wtime();
      t3 = t1;
      //printf("WORKER JUSTO ANTES DE RECEPCIÓN\n");
      poblacion = Worker_ReceivedMPI_SetOfIndividualTask(chunkSize, &nroBloque, &num_generation, numind, &stop);
      t4 = MPI_Wtime();
      comm_time = comm_time + (t4 - t3);
      //printf("WORKER(%d) RECEIVED SIGNAL: %d\n", myid, stop);
      //printf("num_generation: %d\n", num_generation);
      if (stop != FINISH_SIGNAL)
      {
        procesarBloqueFarsite(poblacion,num_generation,datosIni);
        
        //printf("WORKER JUSTO ANTES DE ENVIO\n");
        t3 = MPI_Wtime();
        Worker_SendMPI_IndividualError(poblacion, chunkSize);
        t4 = MPI_Wtime();
        comm_time = comm_time + (t4 - t3);

 		  //t2 = MPI_Wtime();
        printf("Worker(%d) Total Time: %1.2f Comm Time: %1.9f\n",myid, t4-t1, comm_time);
        //printf("WORKER ENVIO BLOQUE\n");
      }
    }
    while(stop != FINISH_SIGNAL);
    
    //printf("LA SIMULACIÓN DE FARSITE %d HA TERMINADO!\n",taskid);

    
}
