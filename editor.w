@* Introduction. This is a text editor based off of Craig Finseth's
book {\it The Craft of Text Editing -- Emacs for the Modern World} and
Salvatore Sanfilippo's {\it Kilo} text editor. I also used Paige Ruten's
line-by-line explaination of {\it Kilo} while writing this.

@c
@<Includes@>@;
@<Macros@>@;
@<Disable Terminal Echo@>@;
@<Buffer Management@>@;
@<Process Keypress Functions@>@;

int main(void) {
  enable_raw_mode();
  create_buffer("*scratch*", sizeof("*scratch*"));
  while (1) {
    @<Refresh Screen@>@;
    process_keypress();
  }
  return 0;
}

@ Refresh Screen.

@<Refresh Screen@>=
  
write(STDOUT_FILENO, "\x1b[2J", 4);
write(STDOUT_FILENO, "\x1b[H", 3);

@ Process Keypress Functions.

@<Process Keypress Functions@>=
char read_key() {
  int nread;
  char c;
  while ((nread = read(STDIN_FILENO, &c, 1)) != 1) {
    if (nread == -1 && errno != EAGAIN) die("read");
  }
  return c;
}

void process_keypress() {
  char c = read_key();
  switch (c) {
    case CTRL_KEY('q'):
      write(STDOUT_FILENO, "\x1b[2J", 4);
      write(STDOUT_FILENO, "\x1b[H", 3);      
      exit(0);
      break;
  }
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
uint16_t create_buffer(const char* name, size_t strlen) {
  if (strlen > 64) {
    return -1;
  }
  for (int i = 0; i <= last_buffer; i++) {
    if (memcmp(name, buffers[i].name, strlen) == 0) {
      return -1;
    }
  }
  memcpy(buffers[++last_buffer].name, name, strlen);
  return last_buffer;
}

@ Macros. Where we make our lives just a little bit easier.

@<Macros@>=

#define CTRL_KEY(k) ((k) & 0x1f)

@ Just the stupid includes from the |clib|.

@<Includes@>=
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>

@ This is where we turn off echoing from the keyboard.

@<Disable Terminal Echo@>=
struct termios orig_termios;

void die(const char *s) {
  write(STDOUT_FILENO, "\x1b[2J", 4);
  write(STDOUT_FILENO, "\x1b[H", 3);  
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
