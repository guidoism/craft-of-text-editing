#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>

typedef struct Buffer {
  char     name[64];
  int32_t  point;
  int16_t  id;
  int16_t  next;
} Buffer;

Buffer buffers[64]; // TODO: make expandable
uint16_t last_buffer = 0;

// Returns buffer id
uint16_t create_buffer(const char* name) {
  for (int i = 0; i <= last_buffer; i++) {
    if (strcmp(name, buffers[i].name) == 0) {
      return -1;
    }
  }
  strncpy(buffers[++last_buffer].name, name, 64);
  return last_buffer;
}

struct termios orig_termios;
void disable_raw_mode() {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}

void enable_raw_mode() {
  tcgetattr(STDIN_FILENO, &orig_termios);
  atexit(disable_raw_mode);
  struct termios raw = orig_termios;
  raw.c_lflag &= ~(ECHO);
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

int main(void) {
  enable_raw_mode();
  create_buffer("*scratch*");
  
  char c;
  while (read(STDIN_FILENO, &c, 1) == 1 && c != 'q');
  return 0;
}



  // Test: Make two buffers with the same name and get error
  /*
  int16_t b = create_buffer("*scratch*");
  printf("Buffer: %s\n", buffers[b].name);
  int16_t b2 = create_buffer("*scratch*");
  printf("Buffer: %d\n", b2);
  */
  

