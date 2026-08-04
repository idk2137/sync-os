ENTRY(start)
SECTIONS
{
    . = 0x7C00;

    .text.boot : {
        boot.o(.text)
    }

    . = 0x7C00 + 510;
    .signature : {
        SHORT(0xAA55)
    }

    /* Zmiana adresu bazowego - usuwa dziurę z zerami, ładuje kernel od razu za bootsectorem */
    . = 0x7E00;
    
    .text.kernel : {
        kernel.o(.text)
    }

    /* Dodanie wildcards (wieloznaczników), by GCC nie zgubiło tekstów i zmiennych z C */
    .rodata : { *(.rodata .rodata.*) }
    .data : { *(.data .data.*) }
    .bss : { *(.bss .bss.*) }

    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
        *(.note*)
    }

    . = 0x7C00 + 512 + (16 * 512);
    .end_marker : {
        BYTE(0)
    }
}
