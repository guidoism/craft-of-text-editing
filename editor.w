@* Introduction. This is a text editor based off of Craig Finseth's
book {\it The Craft of Text Editing -- Emacs for the Modern World} and
Salvatore Sanfilippo's {\it Kilo} text editor. I also used Paige Ruten's
line-by-line explaination of {\it Kilo} while writing this.

@c
@<Includes@>@;
@<Disable Terminal Echo@>@;
@<Buffer Management@>@;

int main(void) {
  enable_raw_mode();
  create_buffer("*scratch*");
  
  while (1) {
    char c = '\0';
    if (read(STDIN_FILENO, &c, 1) == -1 && errno != EAGAIN) die("read");
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
#include <errno.h>

@ This is where we turn off echoing from the keyboard.

@<Disable Terminal Echo@>=
struct termios orig_termios;

void die(const char *s) {
  perror(s);
  exit(1);
}

void disable_raw_mode() {
  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios) == -1) die("tcsetattr");  
}

void enable_raw_mode() {
  if (tcgetattr(STDIN_FILENO, &orig_termios) == -1) die("tcgetattr");
  atexit(disable_raw_mode);
  struct termios raw = orig_termios;
  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw.c_oflag &= ~(OPOST);
  raw.c_cflag |= (CS8);
  raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  raw.c_cc[VMIN] = 0;
  raw.c_cc[VTIME] = 1;
  if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1) die("tcsetattr");
}
