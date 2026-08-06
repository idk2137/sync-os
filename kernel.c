#include "interrupt.h"

int cursor_position = 0;
int current_column = 0;

void update_cursor(int position) {
    outb(0x3D4, 0x0F);
    outb(0x3D5, (unsigned char)(position & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, (unsigned char)((position >> 8) & 0xFF));
}

void print(char *message, char color) {
  char *video_memory = (char *) 0xB8000;
  int i = 0;
  while (message[i] != '\0') {
    if(message[i] == '\n'){
      current_column = cursor_position % 80;
      cursor_position = cursor_position + (80 - current_column);
      i++;
    } else {
    video_memory[cursor_position * 2] = message[i];
    video_memory[cursor_position * 2 + 1] = color;
    cursor_position++;
    i++;
    }
  }
  update_cursor(cursor_position);
}

void clear_screen () {
  for (int i =0; i < 25; i++) {
    for (int j =0; j < 80; j++) {
      print(" ", 0x0F);
    }
  }
  cursor_position = 0;
  current_column = 0;
}

void print_hex(unsigned char val, char color) {
    const char hex_chars[] = "0123456789ABCDEF";
    char buf[3];
    buf[0] = hex_chars[(val >> 4) & 0xF];
    buf[1] = hex_chars[val & 0xF];
    buf[2] = '\0';
    print("0x", color);
    print(buf, color);
}

void keyboard_scancode_handler(unsigned char scancode) {
    print_hex(scancode, 0x0C);
    print(" ", 0x0C);
}

void kernel_main() {
  clear_screen();

  print("Welcome to Sync OS!\n", 0x0B);
  print("Keyboard scancodes:\n", 0x0B);

  // Kolejność jest istotna: najpierw PIC i IDT, dopiero potem sti.
  pic_remap();
  idt_init();                                  // czyści IDT, ustawia gate'y, woła lidt
  set_keyboard_handler(keyboard_scancode_handler);

  interrupt_enable();

  while (1) {
    asm volatile ("hlt");
  }
}
