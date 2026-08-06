#ifndef INTERRUPT_H
#define INTERRUPT_H

#include <stdint.h>

#define IRQ_TIMER       0
#define IRQ_KEYBOARD    1
#define IRQ_SLAVE       2
#define IRQ_COM2        3
#define IRQ_COM1        4
#define IRQ_LPT2        5
#define IRQ_FPU         6
#define IRQ_PRIMARY     7
#define IRQ_RTC         8
#define IRQ_RESERVED    9
#define IRQ_SECONDARY   10
#define IRQ_PS2_MOUSE   11
#define IRQ_FLOATING    12
#define IRQ_ATI         13
#define IRQ_ATA         14

typedef void (*irq_handler_t)(unsigned char scancode);

void outb(unsigned short port, unsigned char value);
unsigned char inb(unsigned short port);

void pic_remap(void);
void idt_init(void);
void idt_set_gate(int num, unsigned int base, unsigned short selector, unsigned char flags);
void interrupt_enable(void);
void interrupt_disable(void);

void set_keyboard_handler(irq_handler_t handler);

extern void isr_stub_32(void);
extern void isr_stub_33(void);

#endif
