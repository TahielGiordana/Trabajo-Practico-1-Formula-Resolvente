#include <stdio.h>

extern int formulaResolvente(float, float, float);

int main(){
    float a;
    float b;
    float c;

    int tieneSolucion;

    tieneSolucion = formulaResolvente(15,20,20.5);

    if(tieneSolucion == 1){
        printf("Existen raices");
    }
    else{
        printf("No existen raices dentro de los numeros reales");
    }
    
}

