#include <stdio.h>
#include <string.h>
#include "mpi.h"
#include "strlib.h"
#include "master.h"
#include "worker.h"
#include "population.h"
#include "genetic.h"
#include <time.h>


#define MASTER_ID 0

//Carlos B.
//NOTE: Define your own simulator ID and custom functions & structs

//Carlos B.
//argv[1] --> Archivo de parámetros de la simulación

int simID;

//Carlos B.
int main(int argc,char *argv[])
{
    char *      dataIniFile;
    int  	myID, ntasks;
    int  	namelen;
    char 	processor_name[MPI_MAX_PROCESSOR_NAME];
    double t1,t2;
    time_t start, end;
    double duration = 0;

    int provided;
    time(&start);
    MPI_Init_thread(&argc,&argv, MPI_THREAD_MULTIPLE, &provided);

    MPI_Comm_size(MPI_COMM_WORLD,&ntasks);
    MPI_Comm_rank(MPI_COMM_WORLD,&myID);

    dataIniFile = argv[1];
    t1 = MPI_Wtime();

    if(myID == MASTER_ID)
    {
        printf("Soy el master\n");
        if (argc == 2)
        {
            switch(provided)
            {
            case MPI_THREAD_SINGLE:
                printf("MPI_THREAD_SINGLE\n");
                break;
            case MPI_THREAD_FUNNELED:
                printf("MPI_THREAD_FUNNELED\n");
                break;
            case MPI_THREAD_SERIALIZED:
                printf("MPI_THREAD_SERIALIZED\n");
                break;
            case MPI_THREAD_MULTIPLE:
                printf("MPI_THREAD_MULTIPLE\n");
                break;
            }
            master(dataIniFile, ntasks);
            /*          INDVTYPE_FARSITE pin1;
                        INDVTYPE_FARSITE pin2;
                        INDVTYPE_FARSITE c1;
                        INDVTYPE_FARSITE c2;

                        pin1.id = 1;
                        pin1.m1 = 0;
                        pin1.m10 = 0;
                        pin1.m100 = 0;
                        pin1.mherb = 0;
                        pin1.wnddir = 0;
                        pin1.wndvel = 0;
                        pin1.temp = 0;
                        pin1.hum = 0;
                        pin1.error = 0;
                        pin1.errorc = 0;

                        pin2.id = 2;
                        pin2.m1 = 1;
                        pin2.m10 = 1;
                        pin2.m100 = 1;
                        pin2.mherb = 1;
                        pin2.wnddir = 1;
                        pin2.wndvel = 1;
                        pin2.temp = 1;
                        pin2.hum = 1;
                        pin2.error = 1;
                        pin2.errorc = 1;

                        GENETIC_Crossover_Farsite(pin1, pin2, &c1, &c2);

                        printf("PADRES:\n");
                        print_indv_farsite(pin1);
                        print_indv_farsite(pin2);
                        printf("HIJOS:\n");
                        print_indv_farsite(c1);
                        print_indv_farsite(c2);   */
        }
        else
        {
            printf("program <initial_data_filename>");
        }
    }
    else // worker
    {
        printf("Soy el worker %d\n", myID);
        worker(myID, dataIniFile);
    }
    t2 = MPI_Wtime();
    printf("*************SPIF total time: %1.2f**************\n",t2-t1);
    MPI_Finalize();
    time(&end);
    duration = difftime(end, start);
    printf("*************SPIF total time in C: %1.2f**************\n",duration);

    return 0;
}

