nasm -f elf32 boot.asm -o boot.o
nasm -f elf32 interrupt.asm -o interrupt.o
# -mno-sse -mno-sse2 -mno-mmx -mgeneral-regs-only: zabraniają GCC generować kod SSE/MMX/FPU.
# BEZ TEGO gcc autowektoryzuje np. inicjalizację tablic (jak w print_hex) na instrukcje typu
# "movdqa" (SSE2), które w kernelu bez zainicjalizowanego FPU/SSE (brak CR0/CR4 setup) powodują
# #UD (Invalid Opcode) natychmiast po wejściu do funkcji - dokładnie to widzieliśmy w QEMU.
CFLAGS="-m32 -ffreestanding -fno-pic -fno-stack-protector -nostdlib -nodefaultlibs -mno-sse -mno-sse2 -mno-mmx -mgeneral-regs-only"
gcc $CFLAGS -c kernel.c -o kernel.o
gcc $CFLAGS -c interrupt.c -o interrupt_c.o
ld -m elf_i386 -T linker.ld -o kernel.bin boot.o interrupt.o kernel.o interrupt_c.o --oformat binary

# Wymuszenie równego rozmiaru pliku do 13 sektorów (1 bootsektor + 12 sektorów kernela = 13*512 = 6656 bajty)
# UWAGA: musi być = 1 (bootsektor) + wartość "mov al, N" w boot.asm, bo boot.asm czyta N sektorów
# zaczynając OD SEKTORA 2 (za bootsektorem) - obraz musi więc mieć co najmniej N+1 sektorów fizycznie.
truncate -s 6656 kernel.bin

qemu-system-x86_64 -drive format=raw,file=kernel.bin
