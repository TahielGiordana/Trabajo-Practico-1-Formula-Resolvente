#!/bin/bash
cd Codigo
nasm -f elf32 formulaResolvente.asm -o formulaResolvente.o
gcc -m32 -o formulaResolvente formulaResolvente.o formulaResolvente.c
./formulaResolvente