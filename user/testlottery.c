#include "kernel/types.h"
#include "user/user.h"

#define TEMPO_TESTE 700

void
trabalhar(int tickets, int fim)
{
  settickets(tickets);

  // usa um limite de tempo
  while(uptime() < fim){

    // trabaio
    for(volatile uint64 i = 0; i < 1000000; i++)
      ;
  }

 //fim do tempo, mostrar o resultado
  printf("PID: %d | Tickets: %d | N. escolhido: %d\n",
         getpid(),
         gettickets(),
         getcontator());

  exit(0);
}

int
main(void)
{
  int pid;
  int fim;

  printf("=== TESTE LOTTERY ===\n");


  fim = uptime() + TEMPO_TESTE;

  // Processo 1
  pid = fork();

  if(pid == 0)
    trabalhar(100, fim);

  // Processo 2
  pid = fork();

  if(pid == 0)
    trabalhar(10, fim);

  // Processo 3
  pid = fork();

  if(pid == 0)
    trabalhar(1, fim);

  // Espera os três processos terminarem.
  wait(0);
  wait(0);
  wait(0);

  printf("=== FIM DO TESTE ===\n");

  exit(0);
}