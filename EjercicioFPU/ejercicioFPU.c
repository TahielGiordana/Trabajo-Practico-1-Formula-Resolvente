#include <stdio.h>

float sum_vf(float *vector, int cantidad);

int main(){
    float a[5] = {5.4, 3.3, 2.2, 4.7, 3.2};

    int cantidad = sizeof(a)/sizeof(a[0]);

    float *b = &a[0];

    printf("La suma de los numeros del vector es: %f\n",sum_vf(b,cantidad));

}