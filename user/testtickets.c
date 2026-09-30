#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  printf("Alterando tickets...\n");

  if(settickets(10) < 0)
    printf("Erro ao alterar tickets\n");
  else
    printf("Tickets alterados com sucesso\n");

  exit(0);
}

