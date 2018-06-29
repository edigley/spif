#include "mpi.h"
#include <stdio.h>
#include "population.h"
#include <stdlib.h>
#include "iniparser.h"
#include <sys/types.h>
#include "fitness.h"
#include "myutils.h"
#include "farsite.h"

/**
 * - argv[1] file path: spif configuration file
 * - argv[2] file path: population file
 * - argv[3] int: identifier of the individual to be simulated. It should range between 0 to (population_size - 1).
 */
int main(int argc, char *argv[]) {

    if (argc < 3 ) {
        printf("ERROR: FireSimulator.main -> number of args invalid. Please inform at least a configuration and a population files. ");
        printf("You can optionally inform the individual to be executed.\n");
    }

    POPULATIONTYPE population;
    readPopulation(&population, argv[2]);
    //print_population_farsite(population);
    //print_individuo(0,population.popu_fs[0]);

    double adjustmentError;
    char * configurationFile = argv[1];
    char * atmPath;
    int generation = 0;
    int individuoId;
    int begin, end;
    char individualAsString[256]; // 256 bytes allocated here on the stack.
    char * adjustmentErrorsFileName = "output_individuals_adjustment_result.txt";
    FILE * adjustmentErrors;

    if (argc == 4 ) {
        individuoId = atoi(argv[3]);
        begin = individuoId;
        end = individuoId + 1;
    } else {
        begin = 0;
        end = population.popuSize;
    }

    if ((adjustmentErrors = fopen(adjustmentErrorsFileName, "w")) == NULL) {
        printf("ERROR: FireSimulator.main -> Error opening output adjustment errors file 'w' %s\n", adjustmentErrorsFileName);
    } else {
        int i;
        for (i=begin; i < end; i++) {
            printf("INFO: FireSimulator.main -> Going to start for individual (%d,%d)...\n", generation, i);

            //individualToString(generation, population.popu_fs[i], individualAsString, sizeof(individualAsString));
            //printf("INFO: FireSimulator.main -> %s\n", individualAsString); 

            runSimFarsite(population.popu_fs[i], "FARSITE", &adjustmentError, generation, atmPath, configurationFile, 99, 1, "/tmp/", 199, 7, 2, 1, 1,24,3600);

            printf("INFO: FireSimulator.main -> Finished for individual (%d,%d).\n", generation, i);

            printf("INFO: FireSimulator.main -> adjustmentError: (%d,%d): %f\n", generation, i, adjustmentError);
            printf("INFO: FireSimulator.main -> &adjustmentError: (%d,%d): %f\n", generation, i, &adjustmentError);

            fprintf(adjustmentErrors,"%s %f\n", individualAsString, adjustmentError);
        }   
        fclose(adjustmentErrors);
    }

}