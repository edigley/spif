#ifndef _POPULATION_H_
#define _POPULATION_H_

#include <stdio.h>
#define maxparams 10
#define nparams_farsite 8
#define nattributes_farsite 3

struct indvtype_farsite {
  int id;  
  float m1, m10, m100, mherb, wnddir, wndvel, temp, hum, error, errorc;
};
typedef struct indvtype_farsite INDVTYPE_FARSITE;

struct indvtype {
  float fit, dist, dir, vel, error, errorc, wnddir, wndvel;			// attributes: fitness, distancy, direction, velocity
  float p[maxparams];				                // parameters's value
  int n;
};
typedef struct indvtype INDVTYPE;

struct populationtype{
    INDVTYPE_FARSITE * popu_fs; 	// set of individuals of FARSITE
  	INDVTYPE * popu;        		// set of individuals
  	int popuSize;						// number of individuals in the population
  	int maxGen; 						// maximum number of iterations in the evolution
  	int currentGen;					// current iteration in the evolution
  	int totfit;
  	float maxError;					// population's total fitness
	int nParams;				  		// number of parameters of each individual
};
typedef struct populationtype POPULATIONTYPE;


void print_indv_default(INDVTYPE indv);
void print_indv_farsite(INDVTYPE_FARSITE indv);
int get_population_farsite(POPULATIONTYPE * pobla, char * nombreInitSet);
int get_population_default(POPULATIONTYPE * pobla, char * nombreInitSet);
int save_population_farsite(POPULATIONTYPE pobla, char * nombreSet);
int save_population_default(POPULATIONTYPE pobla, char * nombreSet);
void print_population_farsite(POPULATIONTYPE p);
int get_indv(POPULATIONTYPE * p, int indi, INDVTYPE * indv);
int sortPopulationByFitness(POPULATIONTYPE * p);
int sortPopulationByErrorC(POPULATIONTYPE * p);
void init_population(POPULATIONTYPE * p, int popuSize);
double randLim(double l, double u);
int print_populationScreen(POPULATIONTYPE pobla);
int save_bestIndv(POPULATIONTYPE * p, char * fBest);
int evolve_population_farsite (POPULATIONTYPE * p, int eli, double cross, double mut, char * range, char * bestind, char * newpob);
void indFarsiteToArray (INDVTYPE_FARSITE * pin1,float * p1);
void arrayToIndFarsite (float * p1, INDVTYPE_FARSITE * pin1);

#endif //_POPULATION_H_
