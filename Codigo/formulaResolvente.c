#include <stdio.h>

int formulaResolvente(float a, float b, float c, float *raiz1, float *raiz2);

int main(){
    float a = 2.0;
    float b = 0.0;
    float c = -32.0;

    float raiz1;
    float raiz2;

    int tieneSolucion;

    tieneSolucion = formulaResolvente(a,b,c,&raiz1,&raiz2);

    if(tieneSolucion == 1){
        printf("Las raices son: %f y %f\n",raiz1,raiz2);
    }
    else{
        printf("No existen raices dentro de los numeros reales\n");
    }
    
}

