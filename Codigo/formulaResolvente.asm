section .text

global formulaResolvente
    
formulaResolvente:
    xor eax,eax

    push ebp
    mov ebp,esp

    mov eax, [ebp+16]
    mov ebx, [ebp+12]
    mov ecx, [ebp+8]
        
    jmp end
    
end:
    pop ebp
    ret