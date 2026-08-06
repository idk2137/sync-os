#include "interrupt.h"

struct idt_entry {
    unsigned short base_low;
    unsigned short selector;
    unsigned char zero;
    unsigned char flags;
    unsigned short base_high;
} __attribute__((packed));

struct idt_ptr {
    unsigned short limit;
    unsigned int base;
} __attribute__((packed));

struct idt_entry idt[256];
struct idt_ptr idtp;

void outb(unsigned short port, unsigned char value) {
    asm volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

unsigned char inb(unsigned short port) {
    unsigned char value;
    asm volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

void idt_set_gate(int num, unsigned int base, unsigned short selector, unsigned char flags) {
    idt[num].base_low = base & 0xFFFF;
    idt[num].base_high = (base >> 16) & 0xFFFF;
    idt[num].selector = selector;
    idt[num].zero = 0;
    idt[num].flags = flags; // 0x8E = 32-bit Interrupt Gate, present
}

void pic_remap() {
    // Inicjalizacja w trybie kaskadowym
    outb(0x20, 0x11);
    outb(0xA0, 0x11);
    // Przemapowanie wektorów: Master na 0x20 (32), Slave na 0x28 (40)
    outb(0x21, 0x20);
    outb(0xA1, 0x28);
    // Połączenie master <-> slave
    outb(0x21, 0x04);
    outb(0xA1, 0x02);
    // Tryb 8086
    outb(0x21, 0x01);
    outb(0xA1, 0x01);
    
    // Maski: Odblokowujemy TYLKO Timer (IRQ0) i Klawiaturę (IRQ1). Reszta zablokowana (0xFC).
    outb(0x21, 0xFC);
    outb(0xA1, 0xFF);
}

// Deklaracje stubów z asemblera
extern void isr_stub_0(void);
extern void isr_stub_1(void);
extern void isr_stub_2(void);
extern void isr_stub_3(void);
extern void isr_stub_4(void);
extern void isr_stub_5(void);
extern void isr_stub_6(void);
extern void isr_stub_7(void);
extern void isr_stub_8(void);
extern void isr_stub_9(void);
extern void isr_stub_10(void);
extern void isr_stub_11(void);
extern void isr_stub_12(void);
extern void isr_stub_13(void);
extern void isr_stub_14(void);
extern void isr_stub_15(void);
extern void isr_stub_16(void);
extern void isr_stub_17(void);
extern void isr_stub_18(void);
extern void isr_stub_19(void);
extern void isr_stub_20(void);
extern void isr_stub_21(void);
extern void isr_stub_31(void);
extern void isr_stub_32(void);
extern void isr_stub_33(void);

void idt_init() {
    idtp.limit = sizeof(struct idt_entry) * 256 - 1;
    idtp.base = (unsigned int)&idt;

    // Wypełnijmy wybrane bramki
    idt_set_gate(0, (unsigned int)isr_stub_0, 0x08, 0x8E);
    idt_set_gate(1, (unsigned int)isr_stub_1, 0x08, 0x8E);
    idt_set_gate(2, (unsigned int)isr_stub_2, 0x08, 0x8E);
    idt_set_gate(3, (unsigned int)isr_stub_3, 0x08, 0x8E);
    idt_set_gate(4, (unsigned int)isr_stub_4, 0x08, 0x8E);
    idt_set_gate(5, (unsigned int)isr_stub_5, 0x08, 0x8E);
    idt_set_gate(6, (unsigned int)isr_stub_6, 0x08, 0x8E);
    idt_set_gate(7, (unsigned int)isr_stub_7, 0x08, 0x8E);
    idt_set_gate(8, (unsigned int)isr_stub_8, 0x08, 0x8E);
    idt_set_gate(13, (unsigned int)isr_stub_13, 0x08, 0x8E); // General Protection Fault
    idt_set_gate(14, (unsigned int)isr_stub_14, 0x08, 0x8E); // Page Fault

    // IRQ od PIC
    idt_set_gate(32, (unsigned int)isr_stub_32, 0x08, 0x8E); // Timer
    idt_set_gate(33, (unsigned int)isr_stub_33, 0x08, 0x8E); // Klawiatura

    asm volatile("lidt (%0)" : : "r"(&idtp));
}

void interrupt_enable() { asm volatile ("sti"); }
void interrupt_disable() { asm volatile ("cli"); }

static irq_handler_t keyboard_callback = 0;

void set_keyboard_handler(irq_handler_t handler) {
    keyboard_callback = handler;
}

// Główny handler wywoływany z asemblera
void common_interrupt_handler(unsigned int *esp) {
    unsigned int int_no = esp[8]; // Numer przerwania wrzucony na stos

    if (int_no == 33) { // Klawiatura
        unsigned char scancode = inb(0x60);
        if (keyboard_callback) {
            keyboard_callback(scancode);
        }
    } else if (int_no < 32) {
        // Tu trafią wyjątki procesora - jeśli wyskoczy GPF (13), system się zatrzyma i nie zresetuje bezmyślnie
        asm volatile("cli; hlt");
    }

    // Wyślij EOI do PIC
    if (int_no >= 32 && int_no < 40) {
        outb(0x20, 0x20); // Master EOI
    }
}
