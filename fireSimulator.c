#include "mpi.h"
#include <stdio.h>
#include "population.h"
#include <stdlib.h>
#include "iniparser.h"
#include <sys/types.h>
#include "fitness.h"
#include "myutils.h"
#include "farsite.h"

char * baseWndFile, * baseWtrFile, * baseFmsFile, * baseAdjFile;
char * adjFile, * fmsFile, * wndFile, * wtrFile;

char * FuelsToCalibrateFileName;

int CalibrateAdjustments;

int doMeteoSim;

float TEMP_VARIATION, HUM_VARIATION;

int FuelsUs[256];

void readConfiguration(char * configurationFile);
void createFarsiteInputFiles(INDVTYPE_FARSITE individual, int generation);

void readConfiguration(char * configurationFile) {
    dictionary * configuration = iniparser_load(configurationFile);

    FuelsToCalibrateFileName = iniparser_getstr(configuration, "main:FuelsToCalibrate");

    adjFile          = iniparser_getstr(configuration, "farsite:adjFile");
    fmsFile          = iniparser_getstr(configuration, "farsite:fmsFile");
    wndFile          = iniparser_getstr(configuration, "farsite:wndFile");
    wtrFile          = iniparser_getstr(configuration, "farsite:wtrFile");

    baseAdjFile	     = iniparser_getstr(configuration, "farsite:baseAdjFile");
    baseFmsFile      = iniparser_getstr(configuration, "farsite:baseFmsFile");
    baseWndFile      = iniparser_getstr(configuration, "farsite:baseWndFile");
    baseWtrFile      = iniparser_getstr(configuration, "farsite:baseWtrFile");

    TEMP_VARIATION       = iniparser_getdouble(configuration, "farsite:TEMP_VARIATION",1.0);
    HUM_VARIATION        = iniparser_getdouble(configuration, "farsite:HUM_VARIATION",1.0);

    FILE *FuelsToCalibrateFILE;
    int i, nFuel;

    for (i=0; i<256; i++) {
        FuelsUs[i]=0;
    }
    if ((FuelsToCalibrateFILE = fopen(FuelsToCalibrateFileName, "r"))==NULL) {
        printf("ERROR: FireSimulator.initFarsiteVariables -> Opening fuels used file.\n");
    } else {
        while(fscanf(FuelsToCalibrateFILE,"%d",&nFuel)!=EOF) {
            FuelsUs[nFuel-1]=1;
        }
    }

}

void createWeatherFile(char *baseWtrFile, char * wtrFileNew, INDVTYPE_FARSITE individual, int temperatureVariation, int humidityVariation) {
    // create weather file for the individual
    FILE *fWTR, *fWTRnew;

    if ( ((fWTR = fopen(baseWtrFile, "r"))   == NULL) ) {
        printf("ERROR: FireSimulator.createWeatherFile -> Unable to open WTR file. \n");
        return;
    }
    if ( ((fWTRnew = fopen(wtrFileNew, "w")) == NULL) ) {
        printf("ERROR: FireSimulator.createWeatherFile -> Unable to create WTR temp file. \n");
        return;
    }

    char * line = (char*)malloc(sizeof(char) * 200);
    char * newline = (char*)malloc(sizeof(char) * 200);
    char * buffer = (char*)malloc(sizeof(char) * 200);

    fgets( line, 100, fWTR );
    fprintf(fWTRnew, "%s", line);
    float tl = individual.parameters[7] - temperatureVariation;
    float hl = individual.parameters[8] - humidityVariation;

    while(fgets( line, 100, fWTR ) != NULL) {
        sprintf(buffer, "%1.0f", tl);
        newline = str_replace(line, "tl", buffer);

        sprintf(buffer, "%1.0f", individual.parameters[7]);
        newline = str_replace(newline, "th", buffer);

        sprintf(buffer, "%1.0f", individual.parameters[8]);
        newline = str_replace(newline, "hh", buffer);

        sprintf(buffer,"%1.0f", hl);
        newline = str_replace(newline, "hl", buffer);

        fprintf(fWTRnew, "%s", newline);
    }
    
    fclose(fWTR);
    fclose(fWTRnew);
}

void createWindFile(char *baseWndFile, char *wndFileNew, INDVTYPE_FARSITE individual) {
    // create wind file for the individual

    FILE *fWND, *fWNDnew;

    if ( ((fWND = fopen(baseWndFile, "r"))   == NULL) ) {
        printf("ERROR: FireSimulator.createWindFile -> Unable to open WND file. \n");
        return;
    }
    if ( ((fWNDnew = fopen(wndFileNew, "w")) == NULL) ) {
        printf("ERROR: FireSimulator.createWindFile -> Unable to create WND temp file. \n");
        return;
    }

    char * line = (char*)malloc(sizeof(char) * 200);
    char * newline = (char*)malloc(sizeof(char) * 200);
    char * buffer = (char*)malloc(sizeof(char) * 200);

    fgets( line, 100, fWND );
    fprintf(fWNDnew, "%s", line);
    while(fgets( line, 100, fWND ) != NULL) {

        sprintf(buffer, "%1.0f", individual.parameters[5]);
        newline = str_replace(line, "ws", buffer);

        sprintf(buffer, "%1.0f", individual.parameters[6]);
        newline = str_replace(newline, "wd", buffer);

        sprintf(buffer, "%d", 0);
        newline = str_replace(newline, "wc", buffer);

        fprintf(fWNDnew, "%s", newline);
    }

    fclose(fWND);
    fclose(fWNDnew);
}

void createFuelMoistureFile(char *baseFmsFile, char *fmsFileNew, INDVTYPE_FARSITE individual) {

    FILE * fFMS, *fFMSnew;

    if ( ((fFMS = fopen(baseFmsFile, "r"))   == NULL) ) {
        printf("ERROR: FireSimulator.createFuelMoistureFile -> Unable to open FMS file. \n");
        return;
    }
    if ( ((fFMSnew = fopen(fmsFileNew, "w")) == NULL) ) {
        printf("ERROR: FireSimulator.createFuelMoistureFile -> Unable to create FMS temp file. \n");
        return;
    }

    char * line = (char*)malloc(sizeof(char) * 200);
    char * newline = (char*)malloc(sizeof(char) * 200);
    char * buffer = (char*)malloc(sizeof(char) * 200);

        // create fuel moisture file for the individual
    while( fgets( line, 100, fFMS ) != NULL ) {

        sprintf(buffer, "%1.0f", individual.parameters[0]);
        newline = str_replace(line, "1h", buffer);

        sprintf(buffer, "%1.0f", individual.parameters[1]);
        newline = str_replace(newline, "10h", buffer);

        sprintf(buffer, "%1.0f", individual.parameters[2]);
        newline = str_replace(newline, "100h", buffer);

        sprintf(buffer, "%1.0f", individual.parameters[3]);
        newline = str_replace(newline, "herb", buffer);

        fprintf(fFMSnew,"%s", newline);
    }

    fclose(fFMS);
    fclose(fFMSnew);
}

void createAdjustmentFile(char *baseAdjFile, char *adjFileNew, INDVTYPE_FARSITE individual, int *FuelsUs) {
    FILE *fADJ, *fADJnew;

    if ( ((fADJ    = fopen(baseAdjFile, "r")) == NULL) ) {
        printf("ERROR: FireSimulator.createAdjustmentFile -> Unable to open ADJ file. \n");
        return;
    }
    if ( ((fADJnew =  fopen(adjFileNew, "w")) == NULL) ) {
        printf("ERROR: FireSimulator.createAdjustmentFile -> Unable to create ADJ temp file. \n");
        return;
    }

    // create fuel moisture file for the individual
    int nfuel, param = 9;
    float adjust = 0.0f;
    while(fscanf(fADJ, "%d %f", &nfuel, &adjust) != EOF ) {
        if (FuelsUs[nfuel-1]) {
            fprintf(fADJnew, "%d %1.6f\n", nfuel, individual.parameters[param]);
            param++;
        } else {
            fprintf(fADJnew, "%d 1.000000\n", nfuel);
        }
    }

    fclose(fADJnew);
    fclose(fADJ);
}

/**
 * Create input files to be used in farsite simulation (fms, adj, wnd, wtr).
 * - individual
 * - configurationFile
 */
void createFarsiteInputFiles(INDVTYPE_FARSITE individual, int generation) {
    printf("INFO: FireSimulator.createFarsiteInputFiles -> Going to create input files for individual (%d,%d) \n", generation, individual.id);

    char * adjFileNew, * fmsFileNew, * wndFileNew, * wtrFileNew;

    fmsFileNew = (char*)malloc(sizeof(char) * 200);
    adjFileNew = (char*)malloc(sizeof(char) * 200);
    wndFileNew = (char*)malloc(sizeof(char) * 200);
    wtrFileNew = (char*)malloc(sizeof(char) * 200);

    char * generationAsString = (char*)malloc(sizeof(char) * 400);
    sprintf(generationAsString, "%d", generation);
    char * individualIdAsString = (char*)malloc(sizeof(char) * 400);
    sprintf(individualIdAsString, "%d", individual.id);

    // Create corresponding fms, wnd & wtr filename for each individual

    adjFileNew = str_replace(adjFile, "$1", generationAsString);
    adjFileNew = str_replace(adjFileNew, "$2", individualIdAsString);
    createAdjustmentFile(baseAdjFile, adjFileNew, individual, FuelsUs);

    fmsFileNew = str_replace(fmsFile, "$1", generationAsString);
    fmsFileNew = str_replace(fmsFileNew, "$2", individualIdAsString);
    createFuelMoistureFile(baseFmsFile, fmsFileNew, individual);

    wndFileNew = str_replace(wndFile, "$1", generationAsString);
    wndFileNew = str_replace(wndFileNew, "$2", individualIdAsString);
    createWindFile(baseWndFile, wndFileNew, individual);
    
    wtrFileNew = str_replace(wtrFile, "$1", generationAsString);
    wtrFileNew = str_replace(wtrFileNew, "$2", individualIdAsString);
    createWeatherFile(baseWtrFile, wtrFileNew, individual, TEMP_VARIATION, HUM_VARIATION);

}

/**
 * - argv[1] file path: spif configuration file
 * - argv[2] file path: population file
 * - argv[3] string [ run | generateFarsiteInputFiles ]: "run" if should run farsite or "generateFarsiteInputFiles" if should only generate farsite input files
 * - argv[4] int [optional]: identifier of the individual to be simulated. It should range between 0 to (population_size - 1).
 */
int main(int argc, char *argv[]) {

    if (argc < 3 ) {
        printf("ERROR: FireSimulator.main -> number of args invalid. Please inform at least a configuration and a population files. ");
        printf("You can optionally inform the individual to be executed.\n");
    }

    POPULATIONTYPE population;
    readPopulation(&population, argv[2]);
    //print_population_farsite(population);
    //print_individuo(0, population.popu_fs[0]);

    double adjustmentError;
    char * configurationFile = argv[1];
    char * atmPath;
    int generation = 0;
    int individuoId;
    int begin, end;
    char individualAsString[256]; // 256 bytes allocated here on the stack.
    char * adjustmentErrorsFileName = "output_individuals_adjustment_result.txt";
    FILE * adjustmentErrors;

    if (argc == 5) { //run only the specified individual
        individuoId = atoi(argv[4]);
        begin = individuoId;
        end = individuoId + 1;
    } else if (argc == 4){ //run all individuals
        begin = 0;
        end = population.popuSize;
    } else {
        printf("ERROR: FireSimulator.main -> Provide the right arguments to the program \n");
        printf(" * - argv[1] file path: spif configuration file \n");
        printf(" * - argv[2] file path: population file \n");
        printf(" * - argv[3] string [ run | generateFarsiteInputFiles ]: \"run\" if should run farsite or \"generateFarsiteInputFiles\" if should only generate farsite input files \n");
        printf(" * - argv[4] int [optional]: identifier of the individual to be simulated. It should range between 0 to (population_size - 1) \n");
        return;
    }

    if ((adjustmentErrors = fopen(adjustmentErrorsFileName, "w")) == NULL) {
        printf("ERROR: FireSimulator.main -> Error opening output adjustment errors file 'w' %s\n", adjustmentErrorsFileName);
        return;
    } else {
        int i;
        for (i=begin; i < end; i++) {
            printf("INFO: FireSimulator.main -> Going to start for individual (%d,%d)...\n", generation, i);

            individualToString(generation, population.popu_fs[i], individualAsString, sizeof(individualAsString));
            printf("INFO: FireSimulator.main -> %s\n", individualAsString); 

            if (strcmp(argv[3], "gen") == 0) {
                printf("INFO: FireSimulator.main -> Gonna generate all farsite input files.\n"); 
                initFarsiteVariables(configurationFile, generation);
                createFarsiteInputFiles(population.popu_fs[i], generation);
            } else if (strcmp(argv[3], "run") == 0) {
                printf("INFO: FireSimulator.main -> Gonna run farsite.\n");
                runSimFarsite(population.popu_fs[i], "FARSITE", &adjustmentError, generation, atmPath, configurationFile, 99, 1, "/tmp/", 199, 7, 2, 1, 1, 24, 3600);//61);//300);//3600);
                printf("INFO: FireSimulator.main -> Finished for individual (%d,%d).\n", generation, i);
                printf("INFO: FireSimulator.main -> adjustmentError: (%d,%d): %f\n", generation, i, adjustmentError);
                printf("INFO: FireSimulator.main -> &adjustmentError: (%d,%d): %f\n", generation, i, &adjustmentError);
                fprintf(adjustmentErrors, "%s %f\n", individualAsString, adjustmentError);
            } else {
                printf("ERROR: FireSimulator.main -> %s is not a valid action. Please specify what to do: [ run | generateFarsiteInputFiles ] \n", argv[3]);
                return;
            }

        }   
        fclose(adjustmentErrors);
    }

}