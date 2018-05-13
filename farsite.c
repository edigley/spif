/* 
 * File:   farsite.c
 * Author: Carlos Brun
 *
 * Created on 16 de abril de 2012, 14:09
 */

#include "mpi.h"
#include "worker.h"
#include <stdio.h>
#include "population.h"
#include <stdlib.h>
#include "iniparser.h"
#include <sys/types.h>
#include "fitness.h"
#include "myutils.h"

int FireSimLimit;
char * farsite_path, *windninja_path, *input_path, *output_path, * real_fire_map_t0, * real_fire_map_t1;
char * landscapeFile, *ignitionFile, *ignitionFileType, *wndFile, *wtrFile, *adjustmentFile, *fmsFile;
char * baseWndFile, *baseWtrFile, *baseFmsFile;
char * RasterFileName, *shapefile, *VectorFileName, *doRaster, *doShape, *doVector;
char * ConditMonth, *ConditDay, *StartMonth, *StartDay, *StartHour, *StartMin, *EndMonth, *EndDay, *EndHour, *EndMin;
char * timestep, *visibleStep, *secondaryVisibleStep, *perimeterResolution,*distanceResolution;
char * fmsFileNew, * wndFileNew, * wtrFileNew, * atmPath;
char * RasterFileNameNew;
float m1, m10, m100, mherb, wnddir, wndvel, temp, hum, error;
int numgen=1, num_threads;
int start_time, end_time;
int     doWindFields;
int     doMeteoSim;
int seguir = 1;
float TEMP_VARIATION, HUM_VARIATION;

int runSimFarsite(INDVTYPE_FARSITE individuo, char * simID, double * err, int numgen, char * atm, char * datos);
void initFarsiteVariables(char * filename);
void createInputFiles(INDVTYPE_FARSITE individuo, char * dataFile);
void createSettingsFile(char * filename, int idInd);
double getSimulationError(char * simulatedMap);

int main(int argc,char *argv[])
{
    INDVTYPE_FARSITE individuo;
    //2.90 8.45 9.07 11.00 20 21 55 97 1.0355 0.0000
    individuo.id = 99;
    individuo.m1 = atof(argv[2]);
    individuo.m10 = atof(argv[3]);
    individuo.m100 = atof(argv[4]);
    individuo.mherb = atof(argv[5]);
    individuo.wnddir = atoi(argv[6]);
    individuo.wndvel = atoi(argv[7]);
    individuo.temp = atoi(argv[8]);
    individuo.hum = atoi(argv[9]);

/*
    individuo.id = 99;
    individuo.m1 = 2.90 ;
    individuo.m10 = 8.45 ;
    individuo.m100 = 9.07 ;
    individuo.mherb = 11.00 ;
    individuo.wnddir = 20 ;
    individuo.wndvel = 21 ;
    individuo.temp = 55 ;
    individuo.hum = 97 ;
*/
    double err;
    int numgen;
    char * datos;
    datos = argv[1];
    char * atmPath;

    int i = 0;

    printf("Vai começar...\n");
    printf("argv[1] %s ...\n", argv[1]);

    printf(" i: %d \n", ++i);

    print_indv_farsite(individuo);

    printf(" i: %d \n", ++i);

    runSimFarsite(individuo, "FARSITE", &err, numgen, atmPath, datos);

    printf(" i: %d \n", ++i);
    printf(" error: %d \n", err);
}

int runSimFarsite(INDVTYPE_FARSITE individuo, char * simID, double * err, int numgene, char * atm, char * datos) 
{

   // printf("\n\nIndividuo que llega a FARSITE:\n");
    //printf("Ind.%d m1:%1.3f m10:%1.3f m100:%1.3f mherb:%1.3f ws:%1.0f wd:%1.0f temp:%1.0f hum:%1.0f error:%1.1f\n", individuo.id, individuo.m1,individuo.m10,individuo.m100,individuo.mherb,individuo.wndvel,individuo.wnddir, individuo.temp,individuo.hum,individuo.error);
    double error = 0;
    numgen = numgene;
    //printf("---Inicio función: farsite.c::runSimFarsite\n");
    //Init variables
    if(doWindFields == 1)
    {
      atmPath = atm;
      //printf("ATM PATH: %s\n",atmPath);
    }
    
    m1      = individuo.m1;
    m10     = individuo.m10;
    m100    = individuo.m100;
    mherb   = individuo.mherb;
    wnddir  = individuo.wnddir;
    wndvel  = individuo.wndvel;
    temp    = individuo.temp;
    hum     = individuo.hum;
    char settings_filename[200]; 
    char nt[100];
    char syscall[1000];
    
    initFarsiteVariables(datos);

    sprintf(settings_filename,"%ssettings_%d_%d.txt",output_path,numgen,individuo.id);

    createInputFiles(individuo, datos);

    createSettingsFile(settings_filename, individuo.id);  

    //./farsite4 settings_filename
    //sprintf(syscall, "%d", num_threads);
    setEnvironmentVariable("OMP_NUM_THREADS", syscall);
    
    sprintf(nt,"OMP_NUM_THREADS=%d",num_threads);

    putenv(nt);
    
    /*********** LLAMADA FARSITE PARALELO TOMÀS ***********/
    printf("%sfarsite4P_serial -i %s -l %d -f %d -t 1 -g %d -n %d\n",farsite_path,settings_filename,FireSimLimit,num_threads,numgen,individuo.id);
    sprintf(syscall,"%sfarsite4P_serial -i %s -l %d -f %d -t 1 -g %d -n %d",farsite_path,settings_filename,FireSimLimit,num_threads,numgen,individuo.id);
    /*********** LLAMADA FARSITE ORIGINAL ***********/
    //sprintf(syscall,"%sfarsite4 %s",farsite_path,settings_filename);
    
    //printf("%s\n", syscall);
    
    int err_syscall = system(syscall);
    
    //Compare maps and get error
    char sim_fire_line[200];
    sprintf(sim_fire_line,"%s%s.toa", output_path, RasterFileNameNew);
    
    //printf("ANTES Cálculo del error: mapa real -> %s mapa sim-> %s t1->%d t2->%d\n", real_fire_map_t0, sim_fire_line, start_time, end_time);
    //printf("ID=%d\n",individuo.id);
    error = getSimulationError(sim_fire_line);
    *err = error;
    
    return (EXIT_SUCCESS);
}

void initFarsiteVariables(char * filename)
{

    int i = 0;

    dictionary * datos;
    datos = iniparser_load(filename);

    int num_threads      = iniparser_getint(datos, "main:num_threads",1);
    doWindFields    	 = iniparser_getint(datos, "main:doWindFields", 0);
	doMeteoSim    	     = iniparser_getint(datos, "main:doMeteoSim", 0);

    real_fire_map_t0     = iniparser_getstr(datos, "farsite:real_fire_map_t0");
    real_fire_map_t1     = iniparser_getstr(datos, "farsite:real_fire_map_t1");

    farsite_path         = iniparser_getstr(datos, "farsite:farsite_path");
    input_path           = iniparser_getstr(datos, "farsite:input_path");
    output_path          = iniparser_getstr(datos, "farsite:output_path");
    landscapeFile        = iniparser_getstr(datos, "farsite:landscapeFile");
    adjustmentFile       = iniparser_getstr(datos, "farsite:adjustmentFile");
    ignitionFile         = iniparser_getstr(datos, "farsite:ignitionFile");
    ignitionFileType     = iniparser_getstr(datos, "farsite:ignitionFileType");
    wndFile              = iniparser_getstr(datos, "farsite:wndFile");
    wtrFile              = iniparser_getstr(datos, "farsite:wtrFile");
    fmsFile              = iniparser_getstr(datos, "farsite:fmsFile");
    baseWndFile          = iniparser_getstr(datos, "farsite:baseWndFile");
    baseWtrFile          = iniparser_getstr(datos, "farsite:baseWtrFile");
    baseFmsFile          = iniparser_getstr(datos, "farsite:baseFmsFile");
    RasterFileName       = iniparser_getstr(datos, "farsite:RasterFileName");
    shapefile            = iniparser_getstr(datos, "farsite:shapefile");
    VectorFileName       = iniparser_getstr(datos, "farsite:VectorFileName");
    doRaster             = iniparser_getstr(datos, "farsite:doRaster");
    doShape              = iniparser_getstr(datos, "farsite:doShape");
    doVector             = iniparser_getstr(datos, "farsite:doVector");
    ConditMonth          = iniparser_getstr(datos, "farsite:ConditMonth");
    ConditDay            = iniparser_getstr(datos, "farsite:ConditDay");
    StartMonth           = iniparser_getstr(datos, "farsite:StartMonth");
    StartDay             = iniparser_getstr(datos, "farsite:StartDay");
    StartHour            = iniparser_getstr(datos, "farsite:StartHour");
    StartMin             = iniparser_getstr(datos, "farsite:StartMin");
    EndMonth             = iniparser_getstr(datos, "farsite:EndMonth");
    EndDay               = iniparser_getstr(datos, "farsite:EndDay");
    EndHour              = iniparser_getstr(datos, "farsite:EndHour");
    EndMin               = iniparser_getstr(datos, "farsite:EndMin");
    timestep             = iniparser_getstr(datos, "farsite:timestep");
    visibleStep          = iniparser_getstr(datos, "farsite:visibleStep");
    secondaryVisibleStep = iniparser_getstr(datos, "farsite:secondaryVisibleStep");
    perimeterResolution  = iniparser_getstr(datos, "farsite:perimeterResolution");
    distanceResolution   = iniparser_getstr(datos, "farsite:distanceResolution");
    TEMP_VARIATION       = iniparser_getdouble(datos, "farsite:TEMP_VARIATION",1.0);
    HUM_VARIATION        = iniparser_getdouble(datos, "farsite:HUM_VARIATION",1.0);
    start_time           = iniparser_getint(datos, "farsite:start_time",1);
    end_time             = iniparser_getint(datos, "farsite:end_time",1);
    FireSimLimit         = iniparser_getint(datos, "farsite:ExecutionLimit", 1);
    printf("FireSimLimit:%d\n",FireSimLimit);
    
}

void createInputFiles(INDVTYPE_FARSITE individuo, char * dataFile)
{
    //printf("---Inicio función: farsite.c::createInputFiles\n");
    initFarsiteVariables(dataFile);

    char * line = (char*)malloc(sizeof(char) * 100);
    char * newline= (char*)malloc(sizeof(char) * 100);
    char * buffer= (char*)malloc(sizeof(char) * 100);
    //char buffer[100];
    
    fmsFileNew = (char*)malloc(sizeof(char) * 100);
	 if(doMeteoSim == 0){
	 	wndFileNew = (char*)malloc(sizeof(char) * 100);
    	wtrFileNew = (char*)malloc(sizeof(char) * 100);
    }
    FILE * fFMS, *fWND, *fWTR, *fFMSnew, *fWNDnew, *fWTRnew;
    char * tmp = (char*)malloc(sizeof(char) * 10);
    // Create corresponding fms,wnd & wtr filename for each individual
    sprintf(tmp,"%d",numgen);
    
    //printf("Número de generaciones:%d\n", numgen);
    
    fmsFileNew = str_replace(fmsFile, "$1", tmp);
    if(doMeteoSim == 0){
	 	wndFileNew = str_replace(wndFile,"$1", tmp);
    	wtrFileNew = str_replace(wtrFile,"$1", tmp);
	 }
    sprintf(tmp,"%d",individuo.id);
    fmsFileNew = str_replace(fmsFileNew, "$2", tmp);
    if(doMeteoSim == 0){
		wndFileNew = str_replace(wndFileNew,"$2", tmp);
    	wtrFileNew = str_replace(wtrFileNew,"$2", tmp);
    }
    //printf("FMS: %s-\n", fmsFileNew);
    //printf("WND: %s-\n", wndFileNew);
    //printf("WTR: %s-\n", wtrFileNew);

    if ((fFMS = fopen(baseFmsFile, "r")) == NULL)
    {
        	 printf("Unable to open FMS file");
			 seguir = 0;
			 
    }
	 if(doMeteoSim == 0){
			if(((fWND = fopen(baseWndFile, "r")) == NULL) || ((fWTR = fopen(baseWtrFile, "r")) == NULL) )
			{
				printf("Unable to open WND or WTR files\n");
				seguir = 0;
			}
	 }
	 if(seguir == 1)
	 {
            if((fFMSnew = fopen(fmsFileNew, "w")) == NULL)
            {
                    printf("Unable to create FMS temp file\n");
						  seguir = 0;
            }
				if(doMeteoSim == 0){
					if(((fWNDnew = fopen(wndFileNew, "w")) == NULL) || ((fWTRnew = fopen(wtrFileNew, "w")) == NULL) )
					{
						printf("Unable to create WND or WTR temp files\n");
						seguir = 0;
					}
			   }
            if(seguir == 1)
            {         
                    //printf("VALORES DE LAS HUMEDADES: m1:%1.3f m10:%1.3f m100:%1.3f mherb:%1.3f\n", individuo.m1, individuo.m10, individuo.m100, individuo.mherb);
                    while(fgets( line, 100, fFMS ) != NULL)
                    {                     
                        sprintf(buffer,"%1.0f",individuo.m1);                      
                        newline = str_replace(line, "1h", buffer);
                        sprintf(buffer,"%1.0f",individuo.m10);
                        newline = str_replace(newline, "10h", buffer);
                        sprintf(buffer,"%1.0f",individuo.m100);
                        newline = str_replace(newline, "100h", buffer);
                        sprintf(buffer,"%1.0f",individuo.mherb);
                        newline = str_replace(newline, "herb", buffer);
                        fprintf(fFMSnew,"%s", newline);
                    }
                    fclose(fFMSnew);

                    if(doMeteoSim == 0)
						  {
							  fgets( line, 100, fWND );
		                 fprintf(fWNDnew,"%s", line);
		                 while(fgets( line, 100, fWND ) != NULL)
		                 {                      
		                     sprintf(buffer,"%1.0f",individuo.wndvel);
		                     newline = str_replace(line, "ws", buffer);
		                     sprintf(buffer,"%1.0f",individuo.wnddir);
		                     newline = str_replace(newline, "wd", buffer);
		                     sprintf(buffer,"%d",0);
		                     newline = str_replace(newline, "wc", buffer);
		                     fprintf(fWNDnew,"%s", newline);
		                 }
		                 if(doMeteoSim == 0) fclose(fWNDnew);

		                 fgets( line, 100, fWTR );
		                 fprintf(fWTRnew,"%s", line);
		                 float tl = individuo.temp - TEMP_VARIATION;
		                 float hl = individuo.hum - HUM_VARIATION;
		                 
		                 while(fgets( line, 100, fWTR ) != NULL)
		                 {                                                                    
		                     sprintf(buffer,"%1.0f",tl);
		                     newline = str_replace(line, "tl", buffer);
		                     
		                     sprintf(buffer,"%1.0f",individuo.temp);
		                     newline = str_replace(newline, "th", buffer);
		                     
		                     sprintf(buffer,"%1.0f", individuo.hum);
		                     newline = str_replace(newline, "hh", buffer);
		                     
		                     sprintf(buffer,"%1.0f",hl);
		                     newline = str_replace(newline, "hl", buffer);
		                     
		                     fprintf(fWTRnew,"%s", newline);
		                 }
		                 if(doMeteoSim == 0) fclose(fWTRnew);
						 }
            }
            fclose(fFMS);
				if(doMeteoSim == 0){
            	fclose(fWND);
            	fclose(fWTR);
				}
    }     
    free(line);
    free(newline);
    free(buffer);
}

void createSettingsFile(char * filename, int idInd)
{
    char * shapefileNew = (char*)malloc(sizeof(char) * 100);
    RasterFileNameNew = (char*)malloc(sizeof(char) * 100);
    char * VectorFileNameNew = (char*)malloc(sizeof(char) * 100);
    char * tmp = (char*)malloc(sizeof(char) * 10);
    
    FILE * file;

    if ( (file = fopen(filename, "w")) == NULL )
    {
        printf("Unable to open settings file");
    }
    else{
        sprintf(tmp,"%d",numgen);
        shapefileNew = str_replace(shapefile, "$1", tmp);
        RasterFileNameNew = str_replace(RasterFileName,"$1", tmp);
        VectorFileNameNew = str_replace(VectorFileName,"$1", tmp);
        sprintf(tmp,"%d",idInd);
        shapefileNew = str_replace(shapefileNew, "$2", tmp);
        RasterFileNameNew = str_replace(RasterFileNameNew,"$2", tmp);
        VectorFileNameNew = str_replace(VectorFileNameNew,"$2", tmp);

        fprintf(file,"version = 42\n");
        // FILES
        fprintf(file,"landscapeFile = %s\n", landscapeFile);
        fprintf(file,"FUELMOISTUREFILE =  %s\n", fmsFileNew);
        if(doWindFields == 0)
		  {
				if(doMeteoSim == 0)            
					fprintf(file,"windFile0 =  %s\n", wndFileNew);
				else
					fprintf(file,"windFile0 =  %s\n", wndFile);
        }
		  else
		  {
            if(doMeteoSim == 0)
					fprintf(file,"windFile0 =  %s\n", atmPath);
				if(doMeteoSim == 1)
					fprintf(file,"windFile0 =  %s\n", wndFile);
		  }
        fprintf(file,"adjustmentFile = %s\n", adjustmentFile);
        if(doMeteoSim == 0)
		  {
		  		fprintf(file,"weatherFile0 = %s\n", wtrFileNew);
		  } else {
				fprintf(file,"weatherFile0 = %s\n", wtrFile);
		  }
        // OUTPUTS CREATION
        fprintf(file,"vectMake = %s\n", doVector);
        fprintf(file,"rastMake = %s\n", doRaster);
        fprintf(file,"shapeMake = %s\n", doShape);
        // RESOLUTION
        fprintf(file,"timestep = %s\n", timestep);
        fprintf(file,"visibleStep = %s\n", visibleStep);
        fprintf(file,"secondaryVisibleStep = %s\n", secondaryVisibleStep);
        fprintf(file,"perimeterResolution = %s\n", perimeterResolution);
        fprintf(file,"distanceResolution = %s\n", distanceResolution);
        // IGNITION DATA & TYPE
        fprintf(file,"ignitionFile = %s\n", ignitionFile);
        fprintf(file,"ignitionFileType = %s\n", ignitionFileType);
        if(strcmp(doShape,"true") == 0)
            fprintf(file,"shapefile=%s%s.shp\n", output_path, shapefileNew);	
        if(strcmp(doRaster,"true") == 0)
            fprintf(file,"RasterFileName=%s%s\n", output_path, RasterFileNameNew);
        if(strcmp(doVector,"true") == 0)
            fprintf(file,"VectorFileName=%s%s\n", output_path, VectorFileNameNew);

        fprintf(file,"enableCrownfire = false\n");
        fprintf(file,"linkCrownDensityAndCover = false\n");
        fprintf(file,"embersFromTorchingTrees = false\n");
        fprintf(file,"enableSpotFireGrowth = false\n");
        fprintf(file,"nwnsBackingROS = false\n");
        fprintf(file,"distanceChecking = fireLevel\n");
        fprintf(file,"simulatePostFrontalCombustion = false\n");
        fprintf(file,"fuelInputOption = absent\n");
        fprintf(file,"calculationPrecision = normal\n");

        fprintf(file,"useConditioningPeriod = true\n");
        fprintf(file,"ConditMonth = %s\n",ConditMonth);
        fprintf(file,"ConditDay = %s\n", ConditDay);
        fprintf(file,"StartMonth = %s\n", StartMonth);
        fprintf(file,"StartDay = %s\n", StartDay);
        fprintf(file,"StartHour = %s\n", StartHour);
        fprintf(file,"StartMin = %s\n", StartMin);
        fprintf(file,"EndMonth = %s\n", EndMonth);
        fprintf(file,"EndDay = %s\n", EndDay);
        fprintf(file,"EndHour = %s\n", EndHour);
        fprintf(file,"EndMin = %s\n", EndMin);

        fprintf(file,"rast_arrivaltime = true\n");
        fprintf(file,"rast_fireIntensity = false\n");
        fprintf(file,"rast_spreadRate = false\n");
        fprintf(file,"rast_flameLength = false\n");
        fprintf(file,"rast_heatPerArea = false\n");
        fprintf(file,"rast_crownFire = false\n");
        fprintf(file,"rast_fireDirection = false\n");
        fprintf(file,"rast_reactionIntensity = false\n");

	fclose(file);
    }
}

double getSimulationError(char * simulatedMap)
{
  //Args: mode mapaRealFileName mapaSimFileName t1 t2
		//ambos mapas -> rutas absolutas al fichero .toa tal cual sale del farsite
        FILE *fd;
        char tmp[32];
        int i,n,srows,scols,rrows=0,rcols=0;
        double *mapaReal, *mapaSim, fitness, error = 9999.0;
        
        if((fd = fopen(real_fire_map_t0, "r")) == NULL) 
            {
                    printf("Unable to open real map file");
            }
            else
            {
                fscanf(fd,"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s%d\n",&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&rrows);
                //printf("\n>>>>>>>> %s %d <<<<<<<<<<\n",tmp,rrows);
                fscanf(fd,"%s\n%d\n",&tmp,&rcols);
                //printf("\n>>>>>>>> %s %d <<<<<<<<<<\n",tmp,rcols);
                mapaReal=(double *)calloc(rrows*rcols,sizeof(double));

                for(i=0;i<rrows*rcols;i++)
                    fscanf(fd,"%lf\n",&mapaReal[i]);

                fclose(fd);
                if((fd=fopen(simulatedMap,"r")) == NULL) 
                {
                    printf("Unable to open simulated map file");
                }
                else
                {
                  fscanf(fd,"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s%d\n",&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&tmp,&srows);
                  fscanf(fd,"%s\n%d\n",&tmp,&scols);
                  mapaSim=(double *)calloc(srows*scols,sizeof(double));

                  if( (srows!=rrows) || (scols!=rcols) ){
                      printf("\nERROR: Different map dimensions!! Real: %dx%d Simulated: %dx%d\n",rrows,rcols,srows,scols);		
                  }
                  else
                  {
                      for(i=0;i<srows*scols;i++)
                          fscanf(fd,"%lf\n",&mapaSim[i]);

                      fclose(fd);

                      //printf("Cálculo del error: mapa real -> %s mapa sim-> %s rows->%d cols->%d t1->%d t2->%d error->%1.2f\n",real_fire_map_t0,simulatedMap, rrows, rcols, start_time, end_time, error);

                      fitness=fitnessYError(mapaReal,mapaSim,rrows,rcols,start_time,end_time,&error);

                      free(mapaReal);
                      free(mapaSim);
                      //printf("ERROR ENTRE MAPAS: %f\n",error);          
                  }
                }                                
            }
        return error;
}
