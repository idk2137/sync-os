[BITS 32]

global isr_stub_0
global isr_stub_1
global isr_stub_2
global isr_stub_3
global isr_stub_4
global isr_stub_5
global isr_stub_6
global isr_stub_7
global isr_stub_8
global isr_stub_9
global isr_stub_10
global isr_stub_11
global isr_stub_12
global isr_stub_13
global isr_stub_14
global isr_stub_15
global isr_stub_16
global isr_stub_17
global isr_stub_18
global isr_stub_19
global isr_stub_20
global isr_stub_21
global isr_stub_31
global isr_stub_32
global isr_stub_33
global common_handle

extern common_interrupt_handler

; Makro dla wyjątków BEZ kodu błędu
%macro ISR_NOERR 1
isr_stub_%1:
    cli
    push byte 0          ; sztuczny error code
    push byte %1         ; numer wyjątku
    jmp common_handle
%endmacro

; Makro dla wyjątków Z kodem błędu (CPU sam go daje)
%macro ISR_ERR 1
isr_stub_%1:
    cli
    push byte %1         ; numer wyjątku (CPU wrzuciło już error code nad nim)
    jmp common_handle
%endmacro

; Wyjątki CPU (0-31)
ISR_NOERR 0
ISR_NOERR 1
ISR_NOERR 2
ISR_NOERR 3
ISR_NOERR 4
ISR_NOERR 5
ISR_NOERR 6
ISR_NOERR 7
ISR_ERR   8
ISR_NOERR 9
ISR_ERR   10
ISR_ERR   11
ISR_ERR   12
ISR_ERR   13
ISR_ERR   14
ISR_NOERR 15
ISR_NOERR 16
ISR_ERR   17
ISR_NOERR 18
ISR_NOERR 19
ISR_NOERR 20
ISR_ERR   21
; 22-30 zarezerwowane, dajmy im też stub NOERR żeby nie było dziur w IDT
%assign i 22
%rep 9
    ISR_NOERR i
%assign i i + 1
%endrep
ISR_NOERR 31

; Sprzętowe IRQ zmapowane przez PIC (32 = Timer, 33 = Klawiatura)
isr_stub_32:
    cli
    push byte 0
    push byte 32
    jmp common_handle

isr_stub_33:
    cli
    push byte 0
    push byte 33
    jmp common_handle

common_handle:
    pushad                    ; Zapisz rejestry ogólnego przeznaczenia

    mov ax, ds                ; Załaduj poprawne segmenty danych kernela
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push esp                  ; Przekaż wskaźnik na stos jako argument (zawiera strukturę z rejestrami i numerem przerwania)
    call common_interrupt_handler
    add esp, 4                ; Posprzątaj wskaźnik ze stosu

    popad                     ; Przywróć rejestry
    add esp, 8                ; Usuń error_code i interrupt_number ze stosu
    sti
    iret                      ; Powrót z przerwania
