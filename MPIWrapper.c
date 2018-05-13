#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>
#include <mpi.h>
#include "population.h"
#include "MPIWrapper.h"

void SendMPI_Finish_Signal(int DEST)
{
    char  buffer[TAM_BUFFER];
    int posicion = 0;
    int signal = FINISH_SIGNAL;

    //printf("MASTER ENVIA FINISH SIGNAL TO %d\n", DEST);
    MPI_Pack(&signal, 1, MPI_INT,buffer,TAM_BUFFER,&posicion,MPI_COMM_WORLD);
    MPI_Send(buffer, TAM_BUFFER, MPI_PACKED, DEST, TAG, MPI_COMM_WORLD);
}

void Master_SendMPI_SetOfIndividualTask(int DEST, int chunkSize, int nroBloque, int num_generation, int num_individuals, INDVTYPE_FARSITE * poblacion)
{
    //printf("Master Send to %d with chunkSize:%d nroBloque:%d num_generation:%d num_individuals:%d\n", DEST, chunkSize, nroBloque, num_generation, num_individuals);
    
    char  buffer[TAM_BUFFER];
    int posicion = 0;
    int signal = 0;
  
    
    MPI_Pack(&signal, 1, MPI_INT, buffer, TAM_BUFFER, &posicion, MPI_COMM_WORLD);   
    MPI_Pack(&nroBloque, 1, MPI_INT, buffer, TAM_BUFFER, &posicion, MPI_COMM_WORLD);
    MPI_Pack(&num_generation, 1, MPI_INT, buffer, TAM_BUFFER, &posicion, MPI_COMM_WORLD);

    
    MPI_Send(buffer, TAM_BUFFER, MPI_PACKED, DEST, TAG, MPI_COMM_WORLD);
    
/*
    printf("Tamaño de la estructura:%d\n", sizeof(INDVTYPE_FARSITE));
    
    printf("POBLACIÓN MASTER\n");
*/
    int pos = nroBloque*chunkSize;
/*
      int i;
      for(i=0;i<chunkSize;i++)
      {
        printf("Ind.%d m1:%1.3f m10:%1.3f m100:%1.3f mherb:%1.3f ws:%1.0f wd:%1.0f temp:%1.0f hum:%1.0f error:%1.1f\n", poblacion[pos+i].id, poblacion[pos+i].m1,poblacion[pos+i].m10,poblacion[pos+i].m100,poblacion[pos+i].mherb,poblacion[pos+i].wndvel,poblacion[pos+i].wnddir, poblacion[pos+i].temp,poblacion[pos+i].hum,poblacion[pos+i].error);
      }
*/
      
    MPI_Send((char*)(poblacion+(nroBloque*chunkSize)), sizeof(INDVTYPE_FARSITE) * chunkSize, MPI_UNSIGNED_CHAR, DEST, TAG, MPI_COMM_WORLD);
}

INDVTYPE_FARSITE * Worker_ReceivedMPI_SetOfIndividualTask(int chunkSize, int * nroBloque, int * num_generation, int num_individuals, int * signal)
{
    char  buffer[TAM_BUFFER];
    INDVTYPE_FARSITE * poblacion = NULL;
    
    int posicion = 0;

    unsigned char *msgGrupo;
    MPI_Status  status;
    int sig_value;
    
    int myid;
    MPI_Comm_rank(MPI_COMM_WORLD, &myid);
    
    MPI_Recv(buffer, TAM_BUFFER,MPI_PACKED,0,TAG,MPI_COMM_WORLD, &status);
    MPI_Unpack(buffer, TAM_BUFFER, &posicion, &sig_value, 1, MPI_INT, MPI_COMM_WORLD);
    
    *signal = sig_value;
    
    if (!(sig_value == FINISH_SIGNAL))
    {
      MPI_Unpack(buffer, TAM_BUFFER, &posicion, nroBloque, 1, MPI_INT, MPI_COMM_WORLD);
      MPI_Unpack(buffer, TAM_BUFFER, &posicion, num_generation, 1, MPI_INT, MPI_COMM_WORLD);

      poblacion = (INDVTYPE_FARSITE*)malloc(chunkSize * sizeof(INDVTYPE_FARSITE));
      msgGrupo = (unsigned char *)malloc(sizeof(INDVTYPE_FARSITE) * chunkSize);
      
      MPI_Recv(msgGrupo, sizeof(INDVTYPE_FARSITE) * chunkSize, MPI_UNSIGNED_CHAR, 0, TAG, MPI_COMM_WORLD, &status);
      poblacion = (INDVTYPE_FARSITE*) msgGrupo;
      
      printf("From Master TO Worker:%d with chunkSize:%d nroBloque:%d Num_gen:%d num_individuals:%d\n", myid, chunkSize, *nroBloque, *num_generation, num_individuals);
    }
    
    return poblacion;
}

void Worker_SendMPI_IndividualError(INDVTYPE_FARSITE * poblacion, int chunk_size)
{
    MPI_Send((char*)poblacion, sizeof(INDVTYPE_FARSITE) * chunk_size, MPI_UNSIGNED_CHAR, 0, TAG, MPI_COMM_WORLD);
}

int Master_ReceiveMPI_IndividualError(int block_count, INDVTYPE_FARSITE * poblacion, int num_individuals, int chunkSize)
{
    int i;
    //printf("Comienzo a recibir de un worker\n");
    MPI_Status  status;
    
     
    unsigned char *msgGrupo;
    msgGrupo = (unsigned char *)malloc(sizeof(INDVTYPE_FARSITE) * chunkSize);
    
    MPI_Recv(msgGrupo, sizeof(INDVTYPE_FARSITE) * chunkSize, MPI_UNSIGNED_CHAR, MPI_ANY_SOURCE, TAG, MPI_COMM_WORLD, &status);
    INDVTYPE_FARSITE* temp = (INDVTYPE_FARSITE*)msgGrupo;
    for(i = 0; i < chunkSize; i++)
    {
      //poblacion[block_count*chunkSize + i].error = temp[i].error;
      //printf("Recibido ind:%d del worker:%d con error:%1.4f\n", temp[i].id, status.MPI_SOURCE, temp[i].error);
      poblacion[temp[i].id].error = temp[i].error;
    }  
    
    //(poblacion+(block_count*chunkSize)) = (INDVTYPE_FARSITE*) msgGrupo;
    
    //MPI_Recv(poblacion+(block_count*chunkSize), sizeof(INDVTYPE_FARSITE) * chunkSize, MPI_UNSIGNED_CHAR, MPI_ANY_SOURCE, TAG, MPI_COMM_WORLD, &status);
    //printf("Recibo del worker %d\n", status.MPI_SOURCE);
    
    return status.MPI_SOURCE;
    
}
