section .text

global sum_vf

sum_vf:

    push ebp
    mov ebp,esp

    mov eax,[ebp+8]     ;Almacena la direccion del primer elemento del vector en eax
    mov ebx,[ebp+12]    ;Almacena la cantidad de elementos del vector
    mov ecx,0           ;Utilizo ecx como contador
    cmp ebx,0           ;Reviso que el vector no este vacio
    je end              ;Si esta vacio finalizo la funcion

    fld dword[eax]      ;Cargo en el stack de la fpu el valor de eax
    inc ecx             ;Incremento el contador en 1
    jmp loop            

loop:
    cmp ecx,ebx         ;Compruebo si ya se recorrio todo el vector
    je end              ;Si ya se recorrio finalizo la funcion y retorno
                        ;el resultado en el stack de la fpu
    add eax,4           ;Accedo al siguiente elemento del array
    fld dword[eax]      ;Cargo en el stack de la fpu el valor actual de eax
    faddp st1           ;Sumo los dos valores almacenados.
    inc ecx             ;Incremento el contador en 1

    jmp loop

end:
    pop ebp
    ret