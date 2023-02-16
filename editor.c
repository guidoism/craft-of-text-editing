#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

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

int main(void) {
  int16_t b = create_buffer("*scratch*");
  printf("Buffer: %s\n", buffers[b].name);
  int16_t b2 = create_buffer("*scratch*");
  printf("Buffer: %d\n", b2);
  return 0;
}


// Test: Make two buffers with the same name and get error
