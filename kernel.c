
int cursor_position = 0;


void print(char *message, char color) {
  char *video_memory = (char *) 0xB8000;
  int i = 0;
  while (message[i] != '\0') {
    video_memory[cursor_position * 2] = message[i];
    video_memory[cursor_position * 2 + 1] = color;
    cursor_position++;
    i++;
    }
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

void kernel_main() {
  print("Welcome to my Kernel OS!", 0x0B);
  print_digit(7, 0x0B);
  int num = 123;
  print_int(num, 0x0B);
  while (1) {}
}
