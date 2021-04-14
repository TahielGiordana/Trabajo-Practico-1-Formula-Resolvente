#include <stdio.h>

int formulaResolvente(float a, float b, float c, float *raiz1, float *raiz2);

int main(){
    float a;
    float b;
    float c;

    float raiz1;
    float raiz2;

    int tieneSolucion;

    printf("\nIngrese el valor de a: ");
    scanf("%f",&a);
    printf("\nIngrese el valor de b: ");
    scanf("%f",&b);
    printf("\nIngrese el valor de c: ");
    scanf("%f",&c);

    tieneSolucion = formulaResolvente(a,b,c,&raiz1,&raiz2);

    if(tieneSolucion == 1){
        if(raiz1 == raiz2){
            printf("\nEl conjunto de raices es: {%f}\n",raiz1);
        }
        else{
            printf("\nEl conjunto de raices es: {%f, %f}\n",raiz1,raiz2);
        }
              
    }
    else{
        printf("\nNo existen raices dentro de los numeros reales\n");
    }
    
}

