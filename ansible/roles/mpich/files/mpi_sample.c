#include <stdio.h>
#include <string.h>
#include "mpi.h"

/* mpi_sample.c */

int main(int argc, char* argv[]){
	int my_rank;        /* rank of process */
	int p;              /* number of processes */
	int source;         /* rank of sender */
	int dest;           /* rank of receiver */
	int tag=0;          /* tag for messages */
	char message[100];  /* storage for message */
	MPI_Status status;  /* return status for receive */

	/* start up MPI */
	MPI_Init(&argc, &argv);

	/* find out process rank */
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

	/* find out number of processes */
	MPI_Comm_size(MPI_COMM_WORLD, &p);

  /* Get the name of the processor */
  char processor_name[MPI_MAX_PROCESSOR_NAME];
  int name_len;
  MPI_Get_processor_name(processor_name, &name_len);

  /* other nodes: */
	if (my_rank !=0){
    /* message */
    sprintf(message, "Host %s, Process %d.", processor_name, my_rank);
    dest = 0;
		/* use strlen+1 so that '\0' get transmitted */
		MPI_Send(message, strlen(message)+1, MPI_CHAR, dest, tag, MPI_COMM_WORLD);
	}
  /* first node: */
	else {
    /* message */
		printf("Host %s, Process 0. Total proc %d.\n", processor_name, p);
    for (source = 1; source < p; source++) {
			MPI_Recv(message, 100, MPI_CHAR, source, tag, MPI_COMM_WORLD, &status);
			printf("%s\n",message);
		}
	}

	/* shutdown MPI */
	MPI_Finalize();

	return 0;
}
