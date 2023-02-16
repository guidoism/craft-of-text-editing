@* Introduction. This is a text editor based off of Craig Finseth's
book {\it The Craft of Text Editing -- Emacs for the Modern World} and
Salvatore Sanfilippo's Kilo text editor.

@c
@<Includes@>@;
@<Disable Terminal Echo@>@;
@<Buffer Management@>@;

int main(void) {
  enable_raw_mode();
  create_buffer("*scratch*");
  
  char c;
  while (1) {
    char c = '\0';
    read(STDIN_FILENO, &c, 1);
    if (iscntrl(c)) {
      printf("%d\r\n", c);
    } else {
      printf("%d ('%c')\r\n", c, c);
    }
    if (c == 'q') break;
  }
  
  return 0;
}

@ Buffer Management.

@<Buffer Management@>=
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

@ Just the stupid includes from the |clib|.

@<Includes@>=
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>

@ This is where we turn off echoing from the keyboard.

@<Disable Terminal Echo@>=
struct termios orig_termios;
void disable_raw_mode() {
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}

void enable_raw_mode() {
  tcgetattr(STDIN_FILENO, &orig_termios);
  atexit(disable_raw_mode);
  struct termios raw = orig_termios;
  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw.c_oflag &= ~(OPOST);
  raw.c_cflag |= (CS8);
  raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  raw.c_cc[VMIN] = 0;
  raw.c_cc[VTIME] = 1;
  tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}
