[BITS 16]
global start
extern kernel_main

start:
    ; 1. Wyłącz przerwania na czas konfiguracji stosu
    cli 
    
    ; 2. Ustaw segmenty danych i stosu na 0
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    
    ; 3. Ustaw wierzchołek stosu tuż przed bootsectorem
    mov sp, 0x7C00 
    
    ; 4. Włącz przerwania
    sti 

    mov [BOOT_DRIVE], dl
    
    mov bx, 0x7E00           ; Załaduj z dysku prosto pod adres 0x7E00, nie robiąc dziury
    mov ah, 0x02
    mov al, 12               ; liczba sektorów kernela do wczytania (od sektora 2). kernel.bin=4589B=9 sektorów + zapas.
                              ; WYMAGA: cały plik kernel.bin musi mieć >= 1+12=13 sektorów (patrz truncate w build.sh)
    mov ch, 0x00             ; cylinder 0
    mov cl, 0x02             ; sector 2 (za bootsectorem)
    mov dh, 0x00             ; head 0
    mov dl, [BOOT_DRIVE]     ; napęd
    int 0x13
    jc disk_error

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm

disk_error:
    ; DIAGNOSTYKA: pokaż kod błędu BIOS z AH (ustawiany przez int 0x13 przy CF=1)
    push ax
    mov si, DISK_ERROR_MSG
    call print_string_16
    pop ax
    mov al, ah          ; kod błędu BIOS trafia do AL, żeby print_hex_16 mogło go pokazać
    call print_hex_16
    jmp $                      ; błąd jest krytyczny, zatrzymaj się tu na stałe

print_string_16:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string_16
.done:
    ret

; Wypisuje AL jako dwie cyfry hex (do diagnostyki błędu BIOS)
print_hex_16:
    push ax
    mov ah, 0x0E
    mov bx, ax
    shr al, 4
    and al, 0x0F
    call .nibble
    mov al, bl
    and al, 0x0F
    call .nibble
    pop ax
    ret
.nibble:
    cmp al, 10
    jl .digit
    add al, 'A' - 10 - '0'
.digit:
    add al, '0'
    mov ah, 0x0E
    int 0x10
    ret

BOOT_DRIVE db 0
DISK_ERROR_MSG db 'Disk read error! BIOS AH=', 0
BOOT_MSG db 'Booting Sync OS...',0

; ---- GDT ----
gdt_start:
    dq 0x0000000000000000      ; wpis zerowy, wymagany

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[BITS 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov esp, 0x90000
    call BEGIN_PM

BEGIN_PM:
    call kernel_main
    jmp $
