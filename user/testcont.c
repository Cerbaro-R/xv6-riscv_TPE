#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  printf("Meu contador: %d\n", getcontator());

  exit(0);
}