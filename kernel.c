
  void print(char *message, char color){
    char *video_memory = (char *) 0xB8000;
    int i = 0;
    while (message[i] != '\0') {
    video_memory[i * 2] = message[i];
    video_memory[i * 2 + 1] = color;
    i++;
    }
  }



void kernel_main() {
  print("Welcome to my Kernel OS!", 0x0B);
  while (1) {}
}
