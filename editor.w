@* Introduction. This is a text editor based off of Craig Finseth's
book {\it The Craft of Text Editing -- Emacs for the Modern World} and
Salvatore Sanfilippo's {\it Kilo} text editor. I also used Paige Ruten's
line-by-line explaination of {\it Kilo} while writing this.

Let's break apart our editor into: 1. Buffers that hold text, 2.
Windows that are a view into a buffer, and 3. Editing the contents of
a buffer.

Let's start with the view since it's the most interesting. We are
essentially projecting the one-dimensional sequence of characters into
a two-dimensional window that is |w| characters wide and |h| characters
high. A decision needs do be made: Do we truncate long lines or
wrap them to the next line? We will want both options so let's
implement both.

@c
@<Includes@>@;
@<Macros@>@;
@<Disable Terminal Echo@>@;
@<Buffer Management@>@;
@<Process Keypress Functions@>@;
@<Refresh Screen Functions@>@;

int main(void) {
  enable_raw_mode();
  create_buffer("*scratch*", sizeof("*scratch*"));
  while (1) {
    refresh_screen();
    process_keypress();
  }
  return 0;
}

@* Project the Buffer onto the Window.

@ Refresh Screen.

@<Refresh Screen Functions@>=

uint16_t rows = 25;
uint16_t cols = 80;
  
void refresh_screen(void) {
  write(STDOUT_FILENO, "\x1b[2J", 4); // Clear entire screen (J command with arg of 2)
  write(STDOUT_FILENO, "\x1b[H", 3); // Reposition cursor to bottom left (row/col args omited)
  Buffer * b = &buffers[current_buffer];
  int k = 0;
  for (int j = 0; j < rows; j++) {
    for (int i = 0; i < cols; i++) {
      if (k < 64) {
        write(STDOUT_FILENO, &b->contents[k++], 1);
      }
      else {
        write(STDOUT_FILENO, " ", 1);
      }
    }
    write(STDOUT_FILENO, "\r\n", 2);
  }
}

@* Edit Contents of the Buffer.

{\it The Emacs Way of Doing Things} is that every key
stroke is a command, even something as simple as the
letter 'a'. This enables extreme flexability. We can
always change the definition.


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
  if (c > 'a' && c < 'z') {
    insert(c);
  } 
  else switch (c) {
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
  char     contents[64];
} Buffer;

Buffer buffers[64]; // TODO: make expandable
uint16_t current_buffer = 0;
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

void insert(char c) {
  Buffer * b = &buffers[current_buffer];
  b->contents[b->point++] = c;
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