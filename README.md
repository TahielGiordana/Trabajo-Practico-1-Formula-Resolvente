# Trabajo Práctico 1: Formula Resolvente
#### Organización del Computador 2
#### UNGS 1er Semestre 2021

##### Alumno: Giordana, Tahiel

## Índice
   - [Descripción](#descripción)
   - [Requisitos](#requisitos)
   - [Función Cuadrática](#función-cuadratica)
      - Código C
      - Código Assembler IA32
      - Compilación
      - Capturas
   - [Ejercicios](#ejercicios)
      - Gestión de Memoria
         - Ejercicio 4
         - Ejercicio 6
         - Ejercicio 7
      - FPU
         - Ejercicio 4
  
   

## Descripción

El objetivo del trabajo es realizar un programa en assembler IA32 que calcule las raíces de una función cuadrática a través de la fórmula resolvente.
Los coeficientes a, b y c son recibidos por parámetro, teniendo en cuenta que estos pueden tomar valores de punto flotante.
La función es invocada desde un programa en C, el cual permite al usuario ingresar los valores de a, b y c. 
Además, se debe compilar y linkear los archivos objeto de manera separada, obteniendo un ejecutable que muestra por consola las raíces obtenidas.
Por último, se presenta la resolución de ejercicios relacionados a la gestión de memoria y al uso de la FPU.

## Requisitos

## Función Cuadrática

### Código C

### Código Assembler IA32

### Compilación

### Capturas

## Ejercicios

### Gestión de Memoria

#### Ejercicio 4

#### Ejercicio 6

#### Ejercicio 7

### FPU

#### Ejercicio 4


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
