#include <stdio.h>
#include <stdlib.h>
#include "population.h"
#include "time.h"

/****************************************************************************/
/* EVOLUTE:                                                                 */
/* operaciones correspondientes al algoritmo evoolutivo                     */
/****************************************************************************/
#define PRINTRANGES 0

static int elitism;            // number of individuals that are selected by elitism
static double crossoverP;
static double mutationP;
static INDVTYPE min;           // individuos con los limites minimos
static INDVTYPE max;           // y maximos de cada parametro
static INDVTYPE_FARSITE minFS; // individuos con los limites minimos
static INDVTYPE_FARSITE maxFS; // y maximos de cada parametro
static int gMutation;          // 1 si hay que guiar la mutacion 0 cc
static int gEllitism;          // 1 si hay que guiar el elitismo 0 cc
static int doComputacional;    // 1 si hay que guiar la mutacion con metodo computacional
static double dirVtoComp;      // direccion del viento propuesta por el metodo computacional
static double velVtoComp;      // velocidad del viento propuesta por el metodo computacional
static double valorDireccion;  // valor que se hara +/- a dirVtoComp para guiar la mutacion con el metodo computacional (datos.ini)
static double valorVelocidad;  // valor que se hara +/- a velVtoComp para guiar la mutacion con el metodo computacional (datos.ini)

char * bests;

int GENETIC_Init(int eli,double crossP, double mutaP, char * fRange, char * fBests, int guidedMutation, int guidedEllitism, int doCompu);
int GENETIC_Init_Farsite(int eli,double crossP, double mutaP, char * fRange, char * fBests, int guidedMutation, int guidedEllitism, int doCompu, int nFuels);
int GENETIC_InitComputacional(double wndDirComp, double wndSpdComp, double valorD, double valorV);
int GENETIC_ElitismCopy(INDVTYPE pa, INDVTYPE * ch, int guided);
int GENETIC_ElitismCopy_Farsite(INDVTYPE_FARSITE pa, INDVTYPE_FARSITE * ch);
int GENETIC_Algorithm(POPULATIONTYPE * p, char* outputFilename,int nFuels);
int GENETIC_Algorithm_Farsite(POPULATIONTYPE * p, char* outputFilename,int nFuels,int pend);
int GENETIC_Select(POPULATIONTYPE p, double sumFit);
double GENETIC_GetSumFitness(POPULATIONTYPE p);
int GENETIC_Crossover(INDVTYPE p1, INDVTYPE p2, INDVTYPE * c1, INDVTYPE * c2);
int GENETIC_Crossover_Farsite(INDVTYPE_FARSITE pin1, INDVTYPE_FARSITE pin2, INDVTYPE_FARSITE * c1, INDVTYPE_FARSITE * c2);
int GENETIC_Mutation(INDVTYPE * indv, int guidedMutaFlag, double wnddir, double wndvel);
int GENETIC_Mutation_Farsite(INDVTYPE_FARSITE * child);
void GENETIC_ControlarValoresValidos(INDVTYPE_FARSITE * c);
int GENETIC_InsertKnowledge(INDVTYPE * indv);

int GENETIC_Init(int eli, double crossP, double mutaP, char * fRange, char * fBests, int guidedMutation, int guidedEllitism, int doCompu) {
    printf("TRACE: Genetic.GENETIC_Init -> starting...\n");
    int i;
    FILE * fichero9;

    elitism = eli;
    crossoverP = crossP;
    mutationP = mutaP;
    doComputacional = doCompu;

    // mutacion y elitismo guiado
    gMutation = guidedMutation;
    gEllitism = guidedEllitism;
    // velVtoComp = wndSpdComp;

    // leo del fichero de rangos los rangos validso para cada parametro
    // los guardo en 2 individuos: max y min
    if ((fichero9 = fopen(fRange, "r")) == NULL) {
        printf("ERROR: Genetic.GENETIC_Init -> no se puede abrir fichero de rangos %s \n", fRange);
        return -1;
    }

    // leo min - the first number of the first line is the number of limits for min
    fscanf(fichero9, "%d ", &min.n);
    for (i = 0; i < min.n; i++) {
        fscanf(fichero9, "%f ", &min.p[i]);
    }

    // leo max - the first number of the first line is the number of limits for max
    fscanf(fichero9, "%d ", &max.n);
    for (i = 0; i < max.n; i++) {
        fscanf(fichero9, "%f ", &max.p[i]);
    }

    // inicializo el resto de las vbles, aunque no haga mucha falta...
    max.fit = min.fit = 0.0;
    max.dist = min.dist = 0.0;
    max.dir = min.dir = 0.0;
    max.vel = min.vel = 0.0;
    max.error = min.error = 0.0;

    bests = fBests; // nombre del fichero donde se guardaran el mejor indv de cada poblacion

    #if PRINTRANGES
    printf("INFO: Genetic.GENETIC_Init -> init, min:  \n");
    print_indv_default(min);
    printf("INFO: Genetic.GENETIC_Init -> init, max:  \n");
    print_indv_default(max);
    #endif

    // random init
    srand48((unsigned)time(NULL));
    srand((unsigned)time(NULL));

    fclose(fichero9);

    return 1;
}

int GENETIC_Init_Farsite(int eli, double crossP, double mutaP, char * fRange, char * fBests, int guidedMutation, int guidedEllitism, int doCompu, int nFuels) {
    printf("TRACE: Genetic.GENETIC_Init_Farsite.\n");
    int i;
    FILE * fichero9;

    elitism = eli;
    crossoverP = crossP;
    mutationP = mutaP;
    doComputacional = doCompu;
    int nparams = FarsiteFixVariables + nFuels;
    int tmp;
    printf("INFO: Genetic.GENETIC_Init_Farsite -> params: %d\n", nparams);

    // mutacion y elitismo guiado
    gMutation = guidedMutation;
    gEllitism = guidedEllitism;
    // velVtoComp = wndSpdComp;

    // leo del fichero de rangos los rangos validos para cada parametro
    // los guardo en 2 individuos: max y min
    if ((fichero9 = fopen(fRange, "r")) == NULL) {
        printf("INFO: Genetic.GENETIC_Init_Farsite -> no se puede abrir fichero de rangos %s \n", fRange);
        return -1;
    }

    // leo min
    fscanf(fichero9, "%d ", &nparams);
    float *minrange = (float*) malloc(sizeof(float) * nparams);
    float *maxrange = (float*) malloc(sizeof(float) * nparams);

    for (i = 0; i < (nparams); i++) {
        fscanf(fichero9, "%d ", &tmp);
        minrange[i]=(float)tmp;
    }

    // leo max
    fscanf(fichero9, "%d ", &tmp);
    for (i = 0; i < ((nparams)); i++) {
        fscanf(fichero9, "%d ", &tmp);
        maxrange[i]=(float)tmp;
    }

    minFS.nparams_farsite=nparams-2;
    maxFS.nparams_farsite=nparams-2;
    arrayToIndFarsite (minrange, &minFS);
    arrayToIndFarsite (maxrange, &maxFS);

    bests = fBests; // nombre del fichero donde se guardaran el mejor indv de cada poblacion

    // random init
    srand48((unsigned)time(NULL));
    srand((unsigned)time(NULL));

    fclose(fichero9);

    return 1;
}

// setea los valores del viento para el metodo computacional (es llamado sii doComputacional == 1)
int GENETIC_InitComputacional(double wndDirComp, double wndSpdComp, double valorD, double valorV) {
    printf("TRACE: Genetic.GENETIC_InitComputacional -> starting...\n");
    dirVtoComp = wndDirComp;
    velVtoComp = wndSpdComp;
    valorDireccion = valorD;
    valorVelocidad = valorV;
    printf("INFO: Genetic.GENETIC_InitComputacional -> Computacional:: dirVtoIdeal:%f velVtoIdeal:%f sumaDire:%f sumaVel:%f \n", dirVtoComp, velVtoComp, valorDireccion, valorVelocidad);
}

// copia el individuo pa (parent) en ch (child)
// lo llamo tantas veces como el parametro elitism lo diga
int GENETIC_ElitismCopy(INDVTYPE pa, INDVTYPE * ch, int guidedE) {
    int i;

    ch->n = pa.n;
    ch->executed = pa.executed;
    ch->error = pa.error;
    ch->errorc = pa.errorc;

    // copio los parametros
    for(i = 0; i < pa.n; i ++) {
        ch->p[i] = pa.p[i];
    }

    // pongo los atributos en 0.0
    ch->fit = ch->dist = ch->dir = ch->vel = 0.;

    return 1;

}

int GENETIC_ElitismCopy_Farsite(INDVTYPE_FARSITE pa, INDVTYPE_FARSITE * ch) {
    //float m1, m10, m100, mherb, wnddir, wndvel, temp, hum, error;

    int i;

    ch->m1 = pa.m1;
    ch->m10 = pa.m10;
    ch->m100 = pa.m100;
    ch->mherb = pa.mherb;
    ch->wnddir = pa.wnddir;
    ch->wndvel = pa.wndvel;
    ch->temp = pa.temp;
    ch->hum = pa.hum;
    ch->error = pa.error;
    ch->errorc = pa.errorc;
    ch->executed = pa.executed;
    if(pa.executed==2) {
        ch->generation = pa.generation;
        ch->oldid = pa.oldid;
    }

    for (i=0; i<ch->maxparams; i++) {
        ch->parameters[i] = pa.parameters[i];
    }

    return 1;

}

// busca el error maximo y lo retorna
double GENETIC_CalcularMaxError(POPULATIONTYPE * p) {
    double maxE = -1.0;
    int i;

    // recorro todos los individuos de la poblacion y me guardo el maximo error
    for (i=0; i < p->popuSize; i++) {
        if(p->popu[i].executed == 1 ) {
            if (p->popu[i].error > maxE) {
                maxE = p->popu[i].error;
            }
        }
    }
    return maxE;
}

// calcula el complemento del error. El complemento es relativo
// al maximo error de la poblacion... (esto no se si va bien...)
void GENETIC_CalcularErrorC(POPULATIONTYPE * p, double maxError) {
    int i;

    for (i=0; i < p->popuSize; i++) {
        p->popu[i].errorc = maxError - p->popu[i].error;
    }

}

void GENETIC_CalcularErrorCFarsite(POPULATIONTYPE * p, double maxError) {
    int i;

    for (i=0; i < p->popuSize; i++) {
        if(p->popu_fs[i].executed == 1 ) {
            p->popu_fs[i].errorc = maxError - p->popu_fs[i].error;
        }
    }

}

// calculo la suma de todos los errorc para la seleccion
double GENETIC_GetSumErrorC(POPULATIONTYPE * p) {
    int i;
    double sumErrorc = 0.0;

    for (i=0; i < p->popuSize; i++) {
        sumErrorc += p->popu[i].errorc;
    }

    return sumErrorc;
}

double GENETIC_GetSumErrorCFarsite(POPULATIONTYPE * p) {
    int i;
    double sumErrorc = 0.0;

    for (i=0; i < p->popuSize; i++) {
        if(p->popu_fs[i].executed == 1 ) {
            sumErrorc += p->popu_fs[i].errorc;
        }
    }

    return sumErrorc;
}

// seleccion de los mejores individuos
// numElite dice cuantos individuos elijo de la poblacion
// anterior y los pongo en la nueva
int GENETIC_Algorithm(POPULATIONTYPE * p, char* outputFilename, int nFuels) {
    printf("TRACE: Genetic.GENETIC_Algorithm.\n");
    int i, p1, p2; //p1 y p2 son los padres
    double sumFit, maxError, sumErrorc;
    POPULATIONTYPE newPopu;

    maxError = GENETIC_CalcularMaxError(p);

    GENETIC_CalcularErrorC(p, maxError);

    // ordeno para realizar la seleccion de mayor a menor fitness
    // sortPopulationByFitness(p);

    // ordeno para realizar la seleccion de mayor a menor errorc
    sortPopulationByErrorC(p);

    init_population(&newPopu, p->popuSize, nFuels);
    newPopu.popuSize = p->popuSize;

    //printf("generacion: %d poblacion Ordenada pero no evolucionada \n", p->currentGen);
    //print_populationScreen(*p);

    // ELITISMO
    // si numElite > 0 elijo esa cantidad de individuos para la nueva poblacion
    if (elitism) {
        // poner los mejores numElite en la nueva poblacion
        for (i = 0; i < elitism; i++) {
            GENETIC_ElitismCopy(p->popu[i], &newPopu.popu[i], gEllitism);
        }
        i = elitism;
    } else {
        i = 0;
    }

    // print_population(*p, "./generacionNueva.txt");
    //printf("vuelta: %d \n ", p->currentGen);

    sumErrorc = GENETIC_GetSumErrorC(p);
    // sumFit = GENETIC_GetSumFitness(*p);

    // EVOLUTION
    // evoluciono la poblacion: selection, crossover, mutation
    while ((i < p->popuSize) && (i != p->popuSize - 1)) {
        p1 = GENETIC_Select(*p, sumErrorc);         // antes enviaba sumFit
        p2 = GENETIC_Select(*p, sumErrorc);

        //printf("GENETIC p1:%d p2:%d \n", p1, p2);

        newPopu.popu[i].n = p->popu[p1].n;
        newPopu.popu[i+1].n = p->popu[p2].n;

        GENETIC_Crossover(p->popu[p1], p->popu[p2], &newPopu.popu[i], &newPopu.popu[i+1]);

        // tengo que enviar los ultimos 2 parametros porque son de los padres a los hijos
        GENETIC_Mutation(&newPopu.popu[i], gMutation, p->popu[p1].wnddir, p->popu[p1].wndvel);
        GENETIC_Mutation(&newPopu.popu[i+1], gMutation, p->popu[p2].wnddir, p->popu[p2].wndvel);


        //GENETIC_ControlarValoresValidos(&newPopu.popu[i], min, max);
        //GENETIC_ControlarValoresValidos(&newPopu.popu[i+1], min, max);
        // proximos 2 hijos
        i += 2;
    }

    // esto es por si elitism es impar, la ultima vuelta me quedo con 1 solo individuo
    // entonces, selecciono 1 padre no hago crossover pero si lo muto.
    if (i == p->popuSize -1) {
        p1 =  GENETIC_Select(*p, sumFit);
        // pero que no guie!!!
        GENETIC_ElitismCopy(p->popu[p1], &newPopu.popu[i], 0); // sirve este metodo, pues esta copiando el individuo...

        GENETIC_Mutation(&newPopu.popu[i], gMutation, p->popu[p1].wnddir, p->popu[p1].wndvel);
    }

    for (i=0; i<p->popuSize; i++){
        //GENETIC_ControlarValoresValidos(&newPopu.popu[i], min, max);
    }
    newPopu.currentGen = p->currentGen + 1;

    // printf("despues de las operaciones, escribo en generacion.txt: i por pantalla generacion: %d (esto es newPopu) \n", newPopu.currentGen);

    return 1;
}

int GENETIC_Algorithm_Farsite(POPULATIONTYPE * p, char* outputFilename, int nFuels, int pend) {
    printf("TRACE: Genetic.GENETIC_Algorithm_Farsite.\n");
    int i, p1,p2; //p1 y p2 son los padres
    double sumFit, maxError, sumErrorc;
    POPULATIONTYPE newPopu;
    int lastInd = (p->popuSize) - 1;

    for (i=0; i<p->popuSize; i++) {
        if(p->popu_fs[i].executed==1) {
            maxError = p->popu_fs[i].error;
        }
    }

    init_population(&newPopu, p->popuSize, nFuels);
    newPopu.popuSize = p->popuSize;

    // ELITISMO
    // si numElite > 0 elijo esa cantidad de individuos para la nueva poblacion
    if (elitism) {
        // poner los mejores numElite en la nueva poblacion
        for (i = 0; i < elitism; i++) {
            GENETIC_ElitismCopy_Farsite(p->popu_fs[i], &newPopu.popu_fs[i]);
        }
        i = elitism;
    }
    else {
        i = 0;
    }

    GENETIC_CalcularErrorCFarsite(p, maxError);

    sumErrorc = GENETIC_GetSumErrorCFarsite(p);
    //printf("sumErrorC:%1.4f",sumErrorc);
    // EVOLUTION
    // evoluciono la poblacion: selection, crossover, mutation
    while ((i < (p->popuSize-pend)) && (i != ((p->popuSize- pend)-1))) {

        p1 = GENETIC_Select_Farsite(*p, sumErrorc);         // antes enviaba sumFit
        p2 = GENETIC_Select_Farsite(*p, sumErrorc);

        GENETIC_Crossover_Farsite(p->popu_fs[p1], p->popu_fs[p2], &newPopu.popu_fs[i], &newPopu.popu_fs[i+1]);

        // tengo que enviar los ultimos 2 parametros porque son de los padres a los hijos
        GENETIC_Mutation_Farsite(&newPopu.popu_fs[i]);
        GENETIC_Mutation_Farsite(&newPopu.popu_fs[i+1]);

        newPopu.popu_fs[i].executed=0;
        newPopu.popu_fs[i].generation=p->currentGen + 1;
        newPopu.popu_fs[i].oldid=i;
        newPopu.popu_fs[i+1].executed=0;
        newPopu.popu_fs[i+1].generation=p->currentGen + 1;
        newPopu.popu_fs[i+1].oldid=i;

        // proximos 2 hijos
        i += 2;
    }

    // esto es por si elitism es impar, la ultima vuelta me quedo con 1 solo individuo
    // entonces, selecciono 1 padre no hago crossover pero si lo muto.
    if (i == ( (p->popuSize-pend)-1)) {
        p1 =  GENETIC_Select_Farsite(*p, sumErrorc);
        // pero que no guie!!!
        GENETIC_ElitismCopy_Farsite(p->popu_fs[p1], &newPopu.popu_fs[i]);
        GENETIC_Mutation_Farsite(&newPopu.popu_fs[i]);
        newPopu.popu_fs[i].executed=0;
        newPopu.popu_fs[i].generation=p->currentGen + 1;
        newPopu.popu_fs[i].oldid=i;

        printf("INFO: Genetic.GENETIC_Algorithm_Farsite -> Posicion %d impar executed a 0\n",i);
        i++;
    }
    while (i<p->popuSize) {
        GENETIC_ElitismCopy_Farsite(p->popu_fs[i], &newPopu.popu_fs[i]);
        i++;
    }

    newPopu.currentGen = p->currentGen + 1;
    newPopu.nParams = p->nParams;
    newPopu.maxparams = p->maxparams;
    newPopu.nparams_farsite = p->nparams_farsite;
    printf("INFO: Genetic.GENETIC_Algorithm_Farsite -> Params: nParams(%d) maxParams(%d) nParamsFarsite(%d)\n", p->nParams, p->maxparams, p->nparams_farsite);
    save_population_farsite(newPopu, outputFilename);
    return 1;
}

// calculo el fitness total de toda la poblacion
double GENETIC_GetSumFitness(POPULATIONTYPE p) {
    double total = 0.0;
    int i;

    for (i = 0; i < p.popuSize; i++) {
        total += p.popu[i].fit;
    }

    return total;

}

// selection: individuals are sorted by fitness (maximum.. minimum)
// best individuals have more likelihood for being chosen
int GENETIC_Select(POPULATIONTYPE p, double sumErrorc) {
    srand48((unsigned)time(NULL));
    double r, sum=0.0;
    int i=0;

    r = drand48() * sumErrorc;  // drand48 retorna un valor de 0..1 por lo que r es menor o = a sumErrorc.

    while ((sum <= r) && (i < p.popuSize))
    {
        sum += p.popu[i].errorc;   // antes era p.pupu[i].fit
        i++;
    }
    //printf("Select: sum:%f r:%f sumErrorc:%f i:%d\n ", sum, r, sumErrorc, (i-1));
    i--;
    if (i < 0) i=0;
    return i;
}

int GENETIC_Select_Farsite(POPULATIONTYPE p, double sumErrorc) {

    double r, sum=0.0;
    int i=0;

    double random = drand48();
    r = random * sumErrorc;  // drand48 retorna un valor de 0..1 por lo que r es menor o = a sumErrorc.

    while ((sum <= r) && (i < p.popuSize)) {
        sum += p.popu_fs[i].errorc;   // antes era p.pupu[i].fit
        i++;
    }
    i--;
    if (i < 0) {
        i=0;
    }

    //printf("Valor random: %1.4f, sumErrorc: %1.4f, individuo seleccionado:%d\n", random, sumErrorc, i);
    return i;
}

// CROSSOVER: the crossover operation is made between pin1 and pin2
// c1 and c2 are obtained from this operation
int GENETIC_Crossover(INDVTYPE pin1, INDVTYPE pin2, INDVTYPE * c1, INDVTYPE * c2) {
    int i, crossPoint;
    double r,x;

    // asigno la cantidad de paramatros a cada hijo nuevo
    c1->n = pin1.n;
    c2->n = pin2.n;

    // printf("crossover antes de todo:: pin1.n:%d pin2.n:%d \n", pin1.n, pin2.n);
    // si supero la probabilidad realizo crossover sobre el individuo
    r = (rand() % 10) / 10.;
    if (r <= crossoverP) { // se realiza la operacion
        // elijo random el crosspoint
        crossPoint = (int) rand() % pin1.n;

        // baker arma una de las partes como el promedio de los parametros!!
        for (i = 0; i < crossPoint; i++) {
            c1->p[i] = pin1.p[i];
            c2->p[i] = (pin1.p[i] + pin2.p[i]) / 2;
        }

        for (i = crossPoint; i < pin1.n; i++) {
            c1->p[i] = (pin2.p[i] + pin1.p[i]) / 2;
            c2->p[i] = pin1.p[i];
        }
    }
    else {// no hay crossover, copio los individuos igual a los padres.
        for (i = 0; i < pin1.n; i++) {
            c1->p[i] = pin1.p[i];
            c2->p[i] = pin2.p[i];
        }
    }

    // atributos en 0.0 para los individuos nuevos
    c1->fit = c2->fit = 0.0;
    c1->dist = c2->dist = 0.0;
    c1->dir = c2->dir = 0.0;
    c1->vel = c2->vel = 0.0;
    c1->error = c2->error = 0.0;
    c1->errorc = c2->errorc = 0.0;

    return 1;
}

int GENETIC_Crossover_Farsite(INDVTYPE_FARSITE pin1, INDVTYPE_FARSITE pin2, INDVTYPE_FARSITE * c1, INDVTYPE_FARSITE * c2) {
    //crossoverP = 1;
    //srand((unsigned)time(NULL));   // ?
    //GENETIC_Init_Farsite(1, 1, 1, "range.txt", "fbests", 0, 0, 0);
    int nParams = pin1.nparams_farsite;
    float *p1 = (float*) malloc(sizeof(float) * nParams);
    float *p2 = (float*) malloc(sizeof(float) * nParams);
    float *h1 = (float*) malloc(sizeof(float) * nParams);
    float *h2 = (float*) malloc(sizeof(float) * nParams);

    indFarsiteToArray (&pin1, p1);
    indFarsiteToArray (&pin2, p2);

    indFarsiteToArray (c1,h1);
    indFarsiteToArray (c2,h2);

    int i, crossPoint;
    double r,x;

    // si supero la probabilidad realizo crossover sobre el individuo
    r = (rand() % 10) / 10.;
    if (r <= crossoverP)  {// se realiza la operacion
        // elijo random el crosspoint
        crossPoint = (int) rand() % nParams;
        // baker arma una de las partes como el promedio de los parametros!!
        for (i = 0; i < crossPoint; i++) {
            h1[i] = p1[i];
            h2[i] = p2[i];  //ORIGINAL
        }

        for (i = crossPoint; i < nParams; i++) {
            h1[i] = p2[i];  //ORIGINAL
            h2[i] = p1[i];
        }
    } else {
        // no hay crossover, copio los individuos igual a los padres.
        for (i = 0; i < nParams; i++) {
            h1[i] = p1[i];
            h2[i] = p2[i];
        }
    } 
    arrayToIndFarsite (h1, c1);
    arrayToIndFarsite (h2, c2);
    GENETIC_ControlarValoresValidos(c2);
    GENETIC_ControlarValoresValidos(c1);
    // atributos en 0.0 para los individuos nuevos
    c1->error = c2->error = 0.0;
    c1->errorc = c2->errorc = 0.0;

    return 1;
}

// por cada parametro del individuo evalua si debe mutarlo o no
// si lo muta obtiene un valor random dentro del rango especifico
int GENETIC_Mutation(INDVTYPE * child, int guidedMutaFlag, double wnddir, double wndvel) {
    int i;
    double mut;
    int limit;

    if (doComputacional) {
        limit = 8;
    } else {
        limit = child->n;
    }

    for(i = 0; i < limit; i++ ) {
        mut = randLim(0,1);
        if (mut < mutationP) {
            child->p[i] = randLim(min.p[i], max.p[i]);
        }
    }

    // mutacion guiada con METODO COMPUTACIONAL
    if (doComputacional) {

        // si no es graduada, threshold es == 1 por lo que guio si o si!!!
        // only guide mutation if probability says so. do not guide always. do not depend on gradual guide or threshold
        mut = randLim(0,1);

        if (mut < mutationP) {

            // printf("THRESHOLD GUIO: %f ran: %f ran < threshold --> muto! () \n ", threshold, ran);
            // acoto los rangos por donde pueden variar velicidad y direccion del viento
            double limiteSupDir, limiteInfDir, limiteSupVel, limiteInfVel;

            limiteSupDir = dirVtoComp + valorDireccion;
            if (limiteSupDir > max.p[9]) {
                limiteSupDir = max.p[9];
            }

            limiteInfDir = dirVtoComp - valorDireccion;
            if (limiteInfDir < min.p[9]) {
                limiteInfDir = min.p[9];
            }

            limiteSupVel = velVtoComp + valorVelocidad;
            if (limiteSupVel > max.p[8]) {
                limiteSupVel = max.p[8];
            }

            limiteInfVel = velVtoComp - valorVelocidad;
            if (limiteSupVel < min.p[8]) {
                limiteSupVel = min.p[8];
            }

            child->p[9] = randLim(limiteInfDir, limiteSupDir); //min.p[i], max.p[i]);
            child->p[8] = randLim(limiteInfVel, limiteSupVel); //min.p[i], max.p[i]);

            // vuelvo a controlar los 2 valores correctos...
            if (child->p[9] > max.p[9]) {
                child->p[9] = max.p[9];
            }

            if (child->p[9] < min.p[9]) {
                child->p[9] = min.p[9];
            }

            if (child->p[8] > max.p[8]){
                child->p[8] = max.p[8];
            }

            if (child->p[8] < min.p[8]) {
                child->p[8] = min.p[8];
            }
        }
    }

    return 1;
}

int GENETIC_Mutation_Farsite(INDVTYPE_FARSITE * child) {
    int i;
    double mut;
    int limit = child->nparams_farsite;
    //GENETIC_Init_Farsite(1, 1, 1, "range.txt", "fbests", 0, 0, 0);
    printf("INFO: Genetic.GENETIC_Mutation_Farsite -> Se muta a individuo %d limit %d\n", child->id, limit);
    float *h1 = (float*) malloc(sizeof(float) * limit);
    float *minrange = (float*) malloc(sizeof(float) * maxFS.nparams_farsite);
    float *maxrange = (float*) malloc(sizeof(float) * maxFS.nparams_farsite);
    indFarsiteToArray (child,h1);
    indFarsiteToArray (&minFS,minrange);
    indFarsiteToArray (&maxFS,maxrange);
    for(i = 0; i < limit; i++ ) {
        mut = randLim(0,1);
        if (mut < mutationP) {
            h1[i] = randLim((int)minrange[i], (int)maxrange[i]);
            // printf("Muto gen %d con %1.6f min:%f max:%f limit:%d\n",i, h1[i],minrange[i], maxrange[i],limit);
        }
    }

    arrayToIndFarsite (h1, child);

    // atributos en 0.0 para los individuos nuevos
    child->error = 0.0;
    child->errorc = 0.0;

    return 1;
}

// used to insert knowledge in individual, e.g. when initialising population
int GENETIC_InsertKnowledge(INDVTYPE * child) {
    printf("TRACE: Genetic.GENETIC_InsertKnowledge\n");
    if (doComputacional) {
        int i;
        double limiteSupDir, limiteInfDir, limiteSupVel, limiteInfVel;

        limiteSupDir = dirVtoComp + valorDireccion;
        if (limiteSupDir > max.p[9])
            limiteSupDir = max.p[9];

        limiteInfDir = dirVtoComp - valorDireccion;
        if (limiteInfDir < min.p[9])
            limiteInfDir = min.p[9];

        limiteSupVel = velVtoComp + valorVelocidad;
        if (limiteSupVel > max.p[8])
            limiteSupVel = max.p[8];

        limiteInfVel = velVtoComp - valorVelocidad;
        if (limiteSupVel < min.p[8])
            limiteSupVel = min.p[8];


        child->p[9] = randLim(limiteInfDir, limiteSupDir); //min.p[i], max.p[i]);
        child->p[8] = randLim(limiteInfVel, limiteSupVel); //min.p[i], max.p[i]);

        // vuelvo a controlar los 2 valores correctos...
        if (child->p[9] > max.p[9]) {
            child->p[9] = max.p[9];
        }

        if (child->p[9] < min.p[9]) {
            child->p[9] = min.p[9];
        }

        if (child->p[8] > max.p[8]) {
            child->p[8] = max.p[8];
        }

        if (child->p[8] < min.p[8]) {
            child->p[8] = min.p[8];
        }

        return 1;
    }
}

//pongo los valores de los parametros dentro de los rangos validos
void GENETIC_ControlarValoresValidos(INDVTYPE_FARSITE * c) {
    printf("TRACE: Genetic.GENETIC_ControlarValoresValidos\n");
    int i;
    for (i = 0; i < c->nparams_farsite; i++) {
        if (c->parameters[i] > maxFS.parameters[i]) {
            c->parameters[i] = maxFS.parameters[i];
        }
        if (c->parameters[i] < minFS.parameters[i]) {
            c->parameters[i] = minFS.parameters[i];
        }
    }
}
