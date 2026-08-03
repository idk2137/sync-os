ENTRY(start)
SECTIONS
{
    . = 0x7C00;

    .text : {
        boot.o(.text)
        kernel.o(.text)
    }

    .rodata : { kernel.o(.rodata) }
    .data : { kernel.o(.data) }
    .bss : { kernel.o(.bss) }

    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
        *(.note*)
    }

    . = 0x7C00 + 510;
    .signature : {
        SHORT(0xAA55)
    }
}
