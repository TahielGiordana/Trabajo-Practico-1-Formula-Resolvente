section .data
    cuatroNeg dw -4

section .text

global formulaResolvente
    
formulaResolvente:

    push ebp
    mov ebp,esp

    ;a,b,c son tipo float, por lo tanto ocupan 4bytes (1 double word)

    ;formulaResolvente() = [ebp+4], a = [ebp+8], b=[ebp+12], c=[ebp+16]
    ;raiz1 = [ebp+20] , raiz2 = [ebp+24]

    ;Voy a usar dos variables que almaceno en la pila.
    ;Una es para guardar el resultado de la raiz cuadrada en [ebp-8]
    ;La otra es para guardar el 2a en [ebp-12]

    ;FPU
    ;Obtengo la primer raiz

    fld1                 ; 1
    fld dword[ebp+8]     ; a,1
    fscale               ; 2a,1
    fdivp st1            ; 1/(2a)
    fstp dword[ebp-12]   ;Guardo 1/(2a) y vacio el stack
    
    fild word[cuatroNeg] ; -4
    fld dword[ebp+8]     ; a,-4
    fmulp st1            ; (-4a)
    fld dword[ebp+16]    ; c,(-4a)
    fmulp st1            ; -4ac
    fld dword[ebp+12]    ; b,-4ac
    fld dword[ebp+12]    ; b,b,-4ac
    fmulp st1            ; b^2,-4ac
    faddp st1            ; b^2 - 4ac

    ;Revisar si existen soluciones

    ftst                 ; Compara el primer valor del stack con 0
    fstsw ax             ; Guarda el status en ax
    sahf                 ; Guarda las flags en ah
    jb noHayRaices       ; Si el resultado es negativo no se puede calcular la raiz     

    fsqrt                ; sqrt(b^2 - 4ac)
    fst dword[ebp-8]   ; Guardo el resultado de la raiz cuadrada y vacio el stack

    fld dword[ebp+12]    ; b, sqrt(b^2 - 4ac)
    fchs                 ; -b, sqrt(b^2 - 4ac)
    faddp st1            ; -b + sqrt(b^2 - 4ac)
    fld dword[ebp-12]   ; 1/(2a), -b + sqrt(b^2 - 4ac)
    fmulp st1            ; (-b + sqrt(b^2 - 4ac)) / 2a
    mov ebx, [ebp+20]    ; Almaceno en ebx la direccion de la primer raiz
    fstp dword[ebx]      ; Guardo el valor obtenido en raiz1 y vacio el stack

    ;Repito el proceso para la segunda raiz
    
    fld dword[ebp-8]    ; sqrt(b^2 - 4ac)
    fchs                ; -sqrt(b^2 - 4ac)
    fld dword[ebp+12]    ; b, -sqrt(b^2 - 4ac)
    fchs                 ; -b, -sqrt(b^2 - 4ac)
    faddp st1            ; -b - sqrt(b^2 - 4ac)
    fld dword[ebp-12]   ; 1/(2a), -b - sqrt(b^2 - 4ac)
    fmulp st1            ; (-b - sqrt(b^2 - 4ac)) / 2a
    mov ebx, [ebp+24]    ; Almaceno en ebx la direccion de la segunda raiz
    fstp dword[ebx]      ; Guardo el valor obtenido en raiz2 y vacio el stack
    
    mov eax,1            ; Hay soluciones, retorna 1
    jmp end

noHayRaices:             ;En caso de no haber soluciones retorna 0
    mov eax,0
    jmp end
    
end:
    pop ebp
    ret