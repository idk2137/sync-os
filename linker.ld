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
        interrupt.o(.text)
        interrupt_c.o(.text)
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

    _kernel_end = .;

    /* Wymuszamy fizyczny rozmiar pliku binarnego tak, by objąć całe .bss
       (ktore samo w sobie nie zajmuje miejsca w --oformat binary) plus zapas. */
    . = _kernel_end + 256;
    .end_marker : {
        BYTE(0)
    }
}
