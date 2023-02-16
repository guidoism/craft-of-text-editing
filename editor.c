#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

typedef struct Buffer {
  char name[64];
  int point;
  struct Buffer* next;
} Buffer;

int main(void) {
  Buffer b = {.name="*scratch*"};
  printf("Buffer: %s\n", b.name);
  return 0;
}
