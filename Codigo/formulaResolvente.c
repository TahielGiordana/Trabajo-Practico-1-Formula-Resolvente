#include <stdio.h>

extern int formulaResolvente(int, int, int);

int main(){
    int a = 1;
    int b = 5;
    int c = 3;

    int n;

    n = formulaResolvente(15,20,30);
    printf("El numero es: %i\n",n);
/*
    if(formulaResolvente(a,b,c) == 1){
        printf("Existen raices");
    }
    else{
        printf("No existen raices dentro de los numeros reales");
    }
 */
    
}

