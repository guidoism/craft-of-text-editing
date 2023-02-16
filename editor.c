#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

typedef struct Buffer {
  char     name[64];
  uint32_t point;
  uint16_t id;
  uint16_t next;
} Buffer;

Buffer buffers[64]; // TODO: make expandable
uint16_t last_buffer = 0;

// Returns buffer id
uint16_t create_buffer(const char* name) {
  strncpy(buffers[++last_buffer].name, name, 64);
  return last_buffer;
}

int main(void) {
  uint16_t b = create_buffer("*scratch*");
  printf("Buffer: %s\n", buffers[b].name);
  uint16_t b2 = create_buffer("*scratch*");
  printf("Buffer: %s\n", buffers[b2].name);
  return 0;
}
