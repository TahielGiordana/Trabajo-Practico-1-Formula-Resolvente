# Trabajo Práctico 1: Formula Resolvente
#### Organización del Computador 2
#### UNGS 1er Semestre 2021

##### Alumno: Giordana, Tahiel

## Índice
   - [Descripción](#descripción)
   - [Requisitos](#requisitos)
   - [Función Cuadrática](#función-cuadrática)
      - [Código C](#código-c)
      - [Código Assembler IA32](#código-assembler-ia32)
      - [Compilación](#compilación)
      - [Ejecución](#ejecución)
      - [Capturas](#capturas)
   - [Ejercicios](#ejercicios)
      - [Gestión de Memoria](#gestión-de-memoria)
         - [Memoria Ejercicio 4](#memoria-ejercicio-4)
         - [Memoria Ejercicio 6](#memoria-ejercicio-6)
         - [Memoria Ejercicio 7](#memoria-ejercicio-7)
      - [FPU](#fpu)
         - [FPU Ejercicio 4](#fpu-ejercicio-4)
  
   

## Descripción

El objetivo del trabajo es realizar un programa en assembler IA32 que calcule las raíces de una función cuadrática a través de la fórmula resolvente.
Los coeficientes a, b y c son recibidos por parámetro, teniendo en cuenta que estos pueden tomar valores de punto flotante.
La función es invocada desde un programa en C, el cual permite al usuario ingresar los valores de a, b y c. 
Además, se debe compilar y linkear los archivos objeto de manera separada, obteniendo un ejecutable que muestra por consola las raíces obtenidas.
Por último, se presenta la resolución de ejercicios relacionados a la gestión de memoria y al uso de la FPU.

## Requisitos

Se requieren distintas herramientas para la compilación del código, para el código assembler se utiliza [NASM](https://www.nasm.us) y para C se utiliza [gcc](https://gcc.gnu.org). Además se puede utilizar [DDD](https://www.gnu.org/software/ddd/) durante la depuración.

## Función Cuadrática

### Código C

Comienzo importando las librerías y declarando la función.
```c
int formulaResolvente(float a, float b, float c);
```
Los valores de a, b y c son pasados como parámetros. La función retorna un 0 en caso de que no existan raíces posibles dentro del conjunto de los reales, y 1 en caso de que sí existan.

Se declaran las variables a, b y c de la ecuación y solicitamos al usuario que ingrese el valor de cada una. Además utilizamos el `int hayRaices` que nos indicará si la ecuacion tiene soluciones posibles.
```c
float a;
float b;
float c;

int hayRaices;

printf("\nIntroduzca el valor de a: ");
scanf("%f",&a);
printf("\nIntroduzca el valor de a: ");
scanf("%f",&b);
printf("\nIntroduzca el valor de a: ");
scanf("%f",&c);
```

Por último invocamos la función y mostramos por consola las raíces obtenidas.
```c
hayRaices = formulaResolvente(a,b,c);

    if(hayRaices == 1){
        printf("Existen raices");
    }
    else{
        printf("No existen raices dentro de los numeros reales");
    }
```

### Código Assembler IA32

Al invocar la función desde C los parámetros son almacenados en la pila. Para poder obtener estos valores contamos con el registro **EBP** que apunta a la base de la pila, y el registro **ESP** que apunta al tope de la misma.

Comienzo declarando las variables. En este caso solo necesito almacenar el valor -4 en una variable que luego utilizo durante el desarrollo de la fórmula resolvente.
```asm
section .data
   cuatroNeg dw -4
```

Luego declaro la función como global, de esta manera el linker vinculará la función con la llamada en C.
```asm
section .text

global formulaResolvente
```

Para evitar incongruencias en la estructura de la pila comienzo realizando el **Enter 0,0**. 
```asm
formulaResolvente:
    push ebp
    mov ebp,esp
```
Procedo con el desarrollo de la fórmula, obteniendo la primer raíz en caso de ser posible. Como los valores pueden ser de punto flotante utilizo la **FPU** mediante su [set de instrucciones](http://linasm.sourceforge.net/docs/instructions/fpu.php).
```asm
;Obtengo la primer raiz

   fld1                 ; 1
   fld dword[ebp+8]     ; a,1
   fscale               ; 2a,1
   fdivp st1            ; 1/(2a)
    
   fild word[cuatroNeg] ; -4,1/(2a)
   fld dword[ebp+8]     ; a,-4,1/(2a)
   fmulp st1            ; (-4a),1/(2a)
   fld dword[ebp+16]    ; c,(-4a),1/(2a)
   fmulp st1            ; -4ac,1/(2a)
   fld dword[ebp+12]    ; b,-4ac,1/(2a)
   fld dword[ebp+12]    ; b,b,-4ac,1/(2a)
   fmulp st1            ; b^2,-4ac,1/(2a)
   faddp st1            ; b^2 - 4ac,1/(2a)

   ;Revisar si existen soluciones

   ftst                 ; Compara el primer valor del stack con 0
   fstsw ax             ; Guarda el status en ax
   sahf                 ; Guarda las flags en ah
   jb noHayRaices       ; Si el resultado es negativo no se puede calcular la raiz 

   fsqrt                ; sqrt(b^2 - 4ac),1/(2a)
   fld dword[ebp+12]    ; b,sqrt(b^2 - 4ac),1/(2a)
   fchs                 ; -b,sqrt(b^2 - 4ac),1/(2a)
   faddp st1            ; -b + sqrt(b^2 - 4ac),1/(2a)
   fmulp st1            ; (-b + sqrt(b^2 - 4ac)) / 2a
```
Luego el proceso para obtener la segunda raíz es similar, solo hay que restar el valor obtenido en la raíz cuadrada en vez de sumarlo.
```asm
   fsubp st1            ; -b - sqrt(b^2 - 4ac),1/(2a)
   fmulp st1            ; (-b - sqrt(b^2 - 4ac)) / 2a
```

En caso de que no existan soluciones, salto a la etiqueta *noHayRaices*, la cual almacena el valor 0 en el registro eax.
```asm
noHayRaices:
    mov eax,0
    jmp end
```
Por último, una vez calculadas las raíces, se realiza un salto a la etiqueta *end* donde se produce el **Leave**.
```asm
end:
   pop ebp
   ret
```


### Compilación

Partiendo de la carpeta raíz del proyecto, nos ubicamos en la carpeta **Codigo**.
Para esto ejecutamos la siguiente línea en la terminal: 
```
ls Codigo
```

Luego compilamos el código assembler utilizando NASM indicando la arquitectura de 32 bits: 
```
nasm -f elf32 formulaResolvente.asm -o formulaResolvente.o
```

Continuamos compilando y linkeando el código C mediante gcc: 
```
gcc -m32 -o formulaResolvente formulaResolvente.o formulaResolvente.c
```

### Ejecución
Una vez compilado, podemos ejecutar el programa mediante la siguiente instrucción en la terminal: 
```
./formulaResolvente
```

Además podremos utilizar DDD para depurar el código, observando su comportamiento y el uso de los registros: 
```
ddd formulaResolvente
``` 

### Capturas

## Ejercicios

### Gestión de Memoria

#### Memoria Ejercicio 4

**4. Usted dispone de un dispositivo que utiliza un sistema de paginación con direcciones 
virtuales de 32 bits , 3 GB de memoria física y frames de 4 MB. ¿Cuántas entradas posee la 
tabla de páginas en cada uno de estos esquemas?**

**A. Si se utiliza un sistema de paginación de un solo nivel.**

```
Sabemos que con 22 bits direccionamos 4MB, y que el tamaño de los frames es igual al de las 
páginas. Por lo tanto si contamos con direcciones virtuales de 32 bits, entonces 10 bits son para el 
número de páginas y 22 bits son para el offset. 
Por lo tanto la tabla de páginas posee 2^10 = 1024 entradas.
```

**B. Si se utiliza un sistema de tabla de paginación invertido.**

```
La cantidad de entradas de la tabla de páginas se corresponde con el tamaño de la memoria 
principal. Por lo tanto basta con dividir el tamaño de la memoria principal por el tamaño de las 
páginas. Sabemos que con 30 bits direccionamos 1GB y con 31 bits direccionamos 2GB, además 
sabemos que reservamos 22 bits para el offset.
De esta manera obtenemos un total de (231 + 230) / 222 = 29 + 28 = 768 entradas en la tabla de 
páginas.
```

**C. Presente una propuesta de un esquema de tablas multinivel de dos dos niveles.**
```
Ya que contamos con 10 bits para el número de página, mi esquema de tablas multinivel de 2 
niveles estaría compuesto por 2 tablas cuyas direcciones están compuestas por 5 bits. 
El total de entradas de cada tabla es de 25 = 32.
```

#### Memoria Ejercicio 6

**6. Se encuentran cargados los siguientes registros de segmento para el proceso P1:**
   - CS -> base address: 10000, limit: 25000 
   - DS -> base address: 5000, limit: 4000 
   - SS -> base address: 50, limit: 3500 

**Por otro lado, el proceso lee las siguientes direcciones lógicas:**
   - A. La dirección 1 para el segmento de datos. 
   - B. La dirección 520 para el segmento de código. 
   - C. La dirección 350 para el segmento de stack.
   - D. La dirección 4000 para el segmento de stack.
   
**Calcular la dirección física asociada a cada uno de estos.** 
```
Respuesta: 
   - A) 1 es menor a 4000. Entonces la dirección física es 5000 + 1 = 5001.
   - B) 520 es menor a 25000. Entonces la dirección física es 10000 + 520 = 10520.
   - C) 350 es menor a 3500. Entonces la dirección física es 50 + 350 = 400.
   - D) 4000 es mayor a 3500. Entonces se produce una interrupción por dirección inválida.
```
#### Memoria Ejercicio 7

**7. Dado el siguiente esquema, indicar el estado final de la cache TLB y tabla de páginas.**

**También indicar la cantidad de rafagas utilizadas en cada secuencia.**

**Las páginas requeridas son las siguientes:**
   * A. Pagina 0, Pagina 2, Pagina 0, Pagina 4, Pagina 5
   * B. Pagina 2, Pagina 1, Pagina 0, Pagina 3, Pagina 4 

**TLB**

| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 0 | 3 | 0 |
| 3 | 2 | 1 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 3 | V | 0 |
| 1 | - | I |   |
| 2 | - | I |   |
| 3 | 2 | V | 1 | 
| 4 | 0 | V | 2 | 
| 5 | 1 | V | 3 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 3 | Página 0 |

Backing Store
| - | - | Página 1 | - | - | Página 2 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**Aclaraciones**
   * Se tiene un esquema de paginación con 6 páginas , 4 frames, una TLB con dos entradas y un backing store ilimitado. 
La columna tiempo indica el orden de llegada, donde el valor 0 es el más antiguo. 
   * Para decidir qué página se reemplaza en cada momento se utiliza la política de reemplazo FIFO (first-in , first-out). 
   * Siempre que se utiliza una entrada de la tabla de páginas, se actualiza la TLB 
   * No se contabilizan los tiempos de escritura en este ejercicio. 
   * Los tiempos de acceso son los siguientes:
      * TLB -> 1 rafaga 
      * Tabla de paginas -> 2 rafagas 
      * Backing Store -> 10 rafagas.

```
A) Pagina 0, Pagina 2, Pagina 0, Pagina 4, Pagina 5
```

**A1- Busco la página 0.**

Está en la TLB.

Tiempo de ejecución = 1 ráfaga.

Estado Final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 0 | 3 | 0 |
| 3 | 2 | 1 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 3 | V | 0 |
| 1 | - | I |   |
| 2 | - | I |   |
| 3 | 2 | V | 1 | 
| 4 | 0 | V | 2 | 
| 5 | 1 | V | 3 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 3 | Página 0 |

**Backing Store**
| - | - | Página 1 | - | - | Página 2 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**A2- Busco la página 2**

Está en el backing store.

Tiempo de ejecución = 1 + 2 + 10 = 13 ráfagas.

Estado final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 2 | 3 | 1 |
| 3 | 2 | 0 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | - | I |   |
| 1 | - | I |   |
| 2 | 3 | V | 3 |
| 3 | 2 | V | 0 | 
| 4 | 0 | V | 1 | 
| 5 | 1 | V | 2 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 3 | Página 2 |

**Backing Store**
| - | - | Página 1 | - | - | Página 0 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**A3- Busco la página 0**

Está en el backing store.

Tiempo de ejecución = 1 + 2 + 10 = 13 ráfagas.

Estado final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 2 | 3 | 0 |
| 0 | 2 | 1 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 2 | V | 3 |
| 1 | - | I |   |
| 2 | 3 | V | 2 |
| 3 | - | I |   | 
| 4 | 0 | V | 0 | 
| 5 | 1 | V | 1 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 0 | Página 2 |

**Backing Store**
| - | - | Página 1 | - | - | Página 3 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**A4- Busco la página 4**

Está en la memoria principal.

Tiempo de ejecución = 1 + 2 = 3 ráfagas.

Estado final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 4 | 0 | 1 |
| 0 | 2 | 0 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 2 | V | 3 |
| 1 | - | I |   |
| 2 | 3 | V | 2 |
| 3 | - | I |   | 
| 4 | 0 | V | 0 | 
| 5 | 1 | V | 1 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 0 | Página 2 |

**Backing Store**
| - | - | Página 1 | - | - | Página 3 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**A5- Busco la página 5**

Está en la memoria principal.

Tiempo de ejecución = 1 + 2 = 3 ráfagas.

Estado final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 4 | 0 | 0 |
| 5 | 1 | 1 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 2 | V | 3 |
| 1 | - | I |   |
| 2 | 3 | V | 2 |
| 3 | - | I |   | 
| 4 | 0 | V | 0 | 
| 5 | 1 | V | 1 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 0 | Página 2 |

**Backing Store**
| - | - | Página 1 | - | - | Página 3 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**Tiempo Total de Ejecución: 1 + 13 + 13 + 3 + 3 = 33 ráfagas**

```
B) Pagina 2, Pagina 1, Pagina 0, Pagina 3, Pagina 4
```

**B1- Busco la página 2.**

Está en el backing store.

Tiempo de ejecución = 1 + 2 + 10 = 13 ráfagas.

Estado Final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 2 | 3 | 1 |
| 3 | 2 | 0 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | - | I |   |
| 1 | - | I |   |
| 2 | 3 | V | 3 |
| 3 | 2 | V | 0 | 
| 4 | 0 | V | 1 | 
| 5 | 1 | V | 2 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 3 | Página 2 |

**Backing Store**
| - | - | Página 1 | - | - | Página 0 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**B2- Busco la página 1.**

Está en el backing store.

Tiempo de ejecución = 1 + 2 + 10 = 13 ráfagas.

Estado Final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 2 | 3 | 0 |
| 1 | 2 | 1 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | - | I |   |
| 1 | 2 | V | 3 |
| 2 | 3 | V | 2 |
| 3 | - | I |   | 
| 4 | 0 | V | 0 | 
| 5 | 1 | V | 1 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 4 | Página 5 | Página 1 | Página 2 |

**Backing Store**
| - | - | Página 3 | - | - | Página 0 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**B3- Busco la página 0.**

Está en el backing store.

Tiempo de ejecución = 1 + 2 + 10 = 13 ráfagas.

Estado Final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 0 | 0 | 1 |
| 1 | 2 | 0 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 0 | V | 3 |
| 1 | 2 | V | 2 |
| 2 | 3 | V | 1 |
| 3 | - | I |   | 
| 4 | - | I |   | 
| 5 | 1 | V | 0 | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 0 | Página 5 | Página 1 | Página 2 |

**Backing Store**
| - | - | Página 3 | - | - | Página 4 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**B4- Busco la página 3.**

Está en el backing store.

Tiempo de ejecución = 1 + 2 + 10 = 13 ráfagas.

Estado Final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 0 | 0 | 0 |
| 3 | 1 | 1 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 0 | V | 2 |
| 1 | 2 | V | 1 |
| 2 | 3 | V | 0 |
| 3 | 1 | V | 3 | 
| 4 | - | I |   | 
| 5 | - | I |   | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 0 | Página 3 | Página 1 | Página 2 |

**Backing Store**
| - | - | Página 5 | - | - | Página 4 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**B5- Busco la página 4.**

Está en el backing store.

Tiempo de ejecución = 1 + 2 + 10 = 13 ráfagas.

Estado Final:

**TLB**
| Página | Frame | Tiempo |
| ------ | ----- | ------ |
| 4 | 3 | 1 |
| 3 | 1 | 0 |

**Tabla de Páginas**
| Página | Frame | Valid | Tiempo |
| ------ | ----- | ----- | ------ |
| 0 | 0 | V | 1 |
| 1 | 2 | V | 0 |
| 2 | - | I |   |
| 3 | 1 | V | 2 | 
| 4 | 3 | V | 3 | 
| 5 | - | I |   | 

**Memoria Principal**
| Frame 0 | Frame 1 | Frame 2 | Frame 3 |
| ------- | ------- | ------- | ------- |
| Página 0 | Página 3 | Página 1 | Página 4 |

**Backing Store**
| - | - | Página 5 | - | - | Página 2 | - | - |
| --- | --- | --- | --- | --- | --- | --- | --- |

**Tiempo Total de Ejecución: 13 + 13 + 13 + 13 + 13 = 65 ráfagas**

### FPU

#### FPU Ejercicio 4

Se debe realizar una función en assembler IA-32 donde se defina un vector de números de punto flotante de precisión simple y calcule la suma. El prototipo de la función es:
```c
float suma_vf(float *vector, int cantidad);
```
Comienzo con el código C encargado de invocar la función. Declaro la función e inicializo un vector cuyos elementos son de tipo float, cuyo tamaño es arbitrario y se almacena en la variable *cantidad*. Además cuento con el puntero `float *vector` que apunta al primer elemento del vector. Por último invoco la función, mostrando por consola el resultado obtenido.
```c
#include <stdio.h>

float sum_vf(float *vector, int cantidad);

int main(){
    float array[5] = {5.4, 3.3, 2.2, 4.7, 3.2};

    int cantidad = sizeof(array)/sizeof(array[0]);

    float *vector = &array[0];

    printf("La suma de los numeros del vector es: %f\n",sum_vf(vector,cantidad));

}
```
En cuanto al código assembler, comienzo declarando `global sum_vf` y realizando el **Enter 0,0**.
```asm
section .text

global sum_vf

sum_vf:

    push ebp
    mov ebp,esp
```
Luego desapilo las variables, almacenando la dirección del primer elemento del vector en eax y la cantidad de elementos en ebx.
```asm
mov eax,[ebp+8]
mov ebx,[ebp+12]
```
Como deseo recorrer un vector, necesito un contador, en este caso utilizo el registro ecx.
```asm
mov ecx,0
```
Con el objetivo de evitar errores, compruebo que el vector no esté vacío. En caso de estarlo salto a la etiqueta *end*.
```asm
cmp ebx,0
je end
```
Al trabajar con variables tipo float requerimos el uso de la FPU. Comenzamos cargando el valor del primer elemento en la pila de la fpu e incrementando ecx en 1.
```asm
fld dword[eax]
inc eax
jmp loop
```
Comenzamos el ciclo comprobando si el vector fue recorrido por completo. En caso que así sea, saltamos a la etiqueta *end* y el valor retornado se obtiene de la pila de la fpu.
De no ser así, accedo al siguiente elemento del array. En este caso los elementos del vector son de tipo float, cuyo tamaño es de 4bytes, por lo que basta sumarle 4 a la dirección almacenada en eax. Procedo cargando en la pila el nuevo valor al que apunta eax, para luego obtener la suma de los valores almacenados en la pila e incrementar el contador en 1.
```asm
loop:
    cmp ecx,ebx         ;Compruebo si ya se recorrio todo el vector
    je end              ;Si ya se recorrio finalizo la funcion y retorno
                        ;el resultado en el stack de la fpu
    add eax,4           ;Accedo al siguiente elemento del array
    fld dword[eax]      ;Cargo en el stack de la fpu el valor actual de eax
    faddp st1           ;Sumo los dos valores almacenados.
    inc ecx             ;Incremento el contador en 1

    jmp loop
```
Para finalizar, realizo el **Leave**.
```asm
end:
   pop ebp
   ret
```

El programa puede ser compilado y ejecutado ingresando los siguientes comandos en la terminal:
```
ls EjercicioFPU
nasm -f elf32 ejercicioFPU.asm -o ejercicioFPU.o
gcc -m32 -o ejercicioFPU ejercicioFPU.o ejercicioFPU.c
./ejercicioFPU
```




Dificultades:

    *Pasar los parametros desde C :

        La funcion formulaResolvente envia los valores de a, b y c.
        Estos valores se almacenan en la pila.

        Solucion:

        Para desapilar las variables primero copio la direccion del esp al ebp.
        De esta manera obtengo que a = [ebp+8], b = [ebp+12] y c = [ebp+16]. 
    
    *Trabajar con puntos flotantes:

        Intente trabajar con variables tipo double pero no podia almacenar el valor
        en los registros.

        Solucion:

        El tipo double ocupa 8 bytes, por eso no era posible almacenar el valor en los
        registros. Ahora las variables son de tipo float, los cuales ocupan 4 bytes al
        igual que los registros.

    *Verificar si existen soluciones:

        Si realizo fsqrt sobre un valor negativo obtengo *.

        Solucion: 
        
        Verificar si b^2 - 4ac >= 0 antes de realizar fsqrt.
        Si se cumple la condicion prosigo con las instrucciones,
        en caso contrario retorno 0 ya que no existen raices
        de esa funcion.


    *Devolver las soluciones

        Devolver las soluciones a la funcion. Si fuese un solo valor
        lo almacenaria en el registro eax para retornarlo, pero al
        tener dos soluciones no puedo.

        Solucion:
