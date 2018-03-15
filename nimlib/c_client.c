#include <stdio.h>
#include "nimlib.h"

int main(int argc, char** argv) {
  printf("Hello, World!\n");
  float result = nimfunc(0);
  printf("Result from calling nimlib: %f\n", result);
  return 0;
}