section .data
    cuatroNeg dw -4

section .text

global formulaResolvente
    
formulaResolvente:

    push ebp
    mov ebp,esp

    ;(Por ahora con a,b,c = int)
    ;a = [ebp+8], b=[ebp+12], c=[ebp+16]

    ;FPU
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

    ;Repito el proceso para la segunda raiz
    
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
    fsqrt                ; sqrt(b^2 - 4ac),1/(2a)
    fld dword[ebp+12]    ; b,sqrt(b^2 - 4ac),1/(2a)
    fchs                 ; -b,sqrt(b^2 - 4ac),1/(2a)
    fsubp st1            ; -b - sqrt(b^2 - 4ac),1/(2a)
    fmulp st1            ; (-b - sqrt(b^2 - 4ac)) / 2a
    
    jmp end

noHayRaices:
    mov eax,0
    jmp end
    
end:
    pop ebp
    ret