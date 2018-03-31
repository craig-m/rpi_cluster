#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <limits.h>

/*
 * R-Pi Welcome script.
 *
 * make clean && make && make test && make install
*/

int main() {
  printf("\n");
  printf("Raspberry Pi cluster node. \n");
  system( "/bin/uname -a" );
  printf("\n");
  return 0;
}
