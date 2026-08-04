[BITS 16]
global start
extern kernel_main

start:
    mov [BOOT_DRIVE], dl
    xor ax, ax
    mov es, ax
    mov bx, 0x7E00      ; Załaduj z dysku prosto pod adres 0x7E00, nie robiąc dziury
    mov dh, 16
    mov dl, [BOOT_DRIVE]
    call load_sectors

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:init_pm

load_sectors:
    mov ah, 0x02
    mov al, dh               ; liczba sektorów do wczytania
    mov ch, 0x00
    mov cl, 0x02              ; zacznij od sektora 2
    mov dh, 0x00
    int 0x13
    jc disk_error             ; błąd -> skocz do obsługi błędu
    mov si, BOOT_MSG
    call print_string_16
    ret                        ; sukces -> wróć do miejsca wywołania (start:)

disk_error:
    mov si, DISK_ERROR_MSG
    call print_string_16
    jmp $                      ; błąd jest krytyczny, zatrzymaj się tu na stałe


boot_msg:
    mov si, BOOT_MSG
    call print_string_16
    ret


print_string_16:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string_16
.done:
    ret

BOOT_DRIVE db 0
DISK_ERROR_MSG db 'Disk read error!', 0
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


