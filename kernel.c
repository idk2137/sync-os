
int cursor_position = 0;
int current_column = 0;

void outb(unsigned short port, unsigned char value) {
    asm volatile ("outb %0, %1" : : "a"(value), "Nd"(port));
}

void update_cursor(int position) {
    outb(0x3D4, 0x0F);                          // wybierz rejestr "low byte"
    outb(0x3D5, (unsigned char)(position & 0xFF));       // wyślij dolny bajt pozycji
    outb(0x3D4, 0x0E);                          // wybierz rejestr "high byte"
    outb(0x3D5, (unsigned char)((position >> 8) & 0xFF)); // wyślij górny bajt pozycji
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

void print_digit(int digit, char color) {
  char c = '0' + digit;
  char str[2];
  str[0] = c;
  str[1] = '\0';
  print(str, color);
}

void print_int (int num, char color) {
  char digits[12];
  int tmp;
  int i = 0;
  while (num != 0) {
    tmp = num % 10;
    digits[i] = '0' + tmp;
    num = num / 10;
    i++;  
  }
  while (i > 0) {
  i--;  
  char c = digits[i];
  char one_char[2] = {c, '\0'};
  print(one_char, color);
  }
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


void kernel_main() {
  clear_screen();
  print("Welcome to my Kernel OS!\n", 0x0B);
  print_digit(7, 0x0B);
  int num = 123;
  print_int(num, 0x0B);
  while (1) {}
}
