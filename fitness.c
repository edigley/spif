/************************************************************************************************************/
/* ACLARACION: esta funcion retorna el error, tiene un margen de error de como estan representados          */
/* los mapas: si t2 == 4.00 y en el mapa simulado tengo 4.001 ya no lo toma como celda quemada, en          */
/* cambio, si en el mapa real esta 4.00 si lo incluye como quemado, de aqui que podamos encontrar           */
/* diferencias entre sumIni y sumReal que no esperabamos encontrar. REPRESENTACION INTERNA DE LOS MAPAS.....*/

/*MODIFICACIONES ANDRES
Celdas no quemadas en Farsite se representan con -001.000, por eso cambio
>>>>> mapaReal[cell] = (mapaReal[cell] == 0.0)?INFINITY:mapaReal[cell];
por
>>>>>	if(mapaReal[cell] == -1.0)
>>>>>		mapaReal[cell]=INFINITY;
*/

/************************************************************************************************************/


#include <stdio.h>

#define INFINITY 999999999.

double fitnessYError(double * mapaReal, double * mapaSim, int Rows, int Cols, double t1, double t2, double * error);
double errorXor(double * mapaReal, double * mapaSim, int Rows, int Cols, double t1, double t2, double * error);

double
fitnessYError(double * mapaReal, double * mapaSim, int Rows, int Cols, double t1, double t2, double * error)
{
    int Cells = Rows * Cols, cell;
    int sumI=0, sumU=0, sumIni=0, sumReal = 0;
    int a,b;
    double fit;


    for(cell = 0; cell < Cells ; cell ++)
    {
        // paso el mapa real a infinity las celdas no quemadas
        //mapaReal[cell] = (mapaReal[cell] == 0.0)?INFINITY:mapaReal[cell];
        if(mapaReal[cell] <= -1.0)
            mapaReal[cell]=INFINITY;

        if(mapaSim[cell] <= -1.0)
            mapaSim[cell]=INFINITY;


        a = mapaSim[cell] <= t2 ? 1 : 0;
        b = mapaReal[cell] <= t2 ? 1 : 0;

        sumIni += mapaReal[cell] <= t1 ? 1 : 0;
        sumReal += mapaReal[cell] <= t2 ? 1: 0;

        sumI += ((a==1) && (b==1)) ? 1 : 0;
        sumU += ((a==1) || (b==1)) ? 1 : 0;
    }
    //printf("\n>>>> t1:%f\tt2:%f\ta:%d\tb:%d\tsumIni:%d\tsumReal:%d\tsumI:%d\tsumU:%d<<<<\n", t1, t2, a, b, sumIni, sumReal, sumI, sumU);

    if (sumU != sumIni)
        fit = ((float)(sumI - sumIni)) / ((float)(sumU - sumIni));
    else
        fit = 0.0;

    if (sumReal != sumIni)
        * error = (((float)(sumU - sumIni)) - ((float)(sumI - sumIni))) / ((float)(sumReal - sumIni));
    else
        * error = 9999.0;

//   printf("sumU= %d sumI= %d sumIni= %d sumReal=%d  fitness:%f error:%f t1:%f t2:%f \n", sumU, sumI, sumIni, sumReal, fit, * error, t1, t2);
    fit=1234.0;
    return (double)fit;

}


double errorXor(double * mapaReal, double * mapaSim, int Rows, int Cols, double t1, double t2, double * error)
{
    int Cells = Rows * Cols, cell;
    int sumI=0, sumU=0, sumIni=0;
    float sumReal=0, sumXOR=0;
    int a,b;
    double fit;


    for(cell = 0; cell < Cells ; cell ++)
    {
        // paso el mapa real a infinity las celdas no quemadas
        if(mapaReal[cell] == -1.0)
            mapaReal[cell]=INFINITY;

        if(mapaSim[cell] == -1.0)
            mapaSim[cell]=INFINITY;

        a = mapaSim[cell] <= t2 ? 1 : 0;
        b = mapaReal[cell] <= t2 ? 1 : 0;

        if ( a^b )
            sumXOR++;

        sumIni += mapaReal[cell] <= t1 ? 1 : 0;
        sumReal += mapaReal[cell] <= t2 ? 1: 0;

        sumI += ((a==1) && (b==1)) ? 1 : 0;
        sumU += ((a==1) || (b==1)) ? 1 : 0;
    }
    //printf("\n>>>> t1:%f\tt2:%f\ta:%d\tb:%d\tsumIni:%d\tsumReal:%d\tsumI:%d\tsumU:%d<<<<\n", t1, t2, a, b, sumIni, sumReal, sumI, sumU);

    /******
       if (sumU != sumIni)
          fit = ((float)(sumI - sumIni)) / ((float)(sumU - sumIni));
       else
          fit = 0.0;

       if (sumReal != sumIni)
         * error = (((float)(sumU - sumIni)) - ((float)(sumI - sumIni))) / ((float)(sumReal - sumIni));
       else
         * error = 99999.9;
    ******/


    * error =  (float) (sumXOR / sumReal);


//   printf("sumU= %d sumI= %d sumIni= %d sumReal=%d  fitness:%f error:%f t1:%f t2:%f \n", sumU, sumI, sumIni, sumReal, fit, * error, t1, t2);

    return (double)fit;

}

