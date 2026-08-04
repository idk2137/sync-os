nasm -f elf32 boot.asm -o boot.o
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c kernel.c -o kernel.o
ld -m elf_i386 -T linker.ld -o kernel.bin boot.o kernel.o --oformat binary
qemu-system-x86_64 -drive format=raw,file=kernel.bin
