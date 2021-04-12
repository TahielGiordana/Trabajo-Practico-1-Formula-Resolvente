# Trabajo-Practico-1-Formula-Resolvente

Organización del Computador 2 - UNGS 2021

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