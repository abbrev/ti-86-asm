#include <stdio.h>

int runoisc(int pc)
{
	int mem[384];
	int a, b, c;
	
	while (pc >= 0)
	{
		a = mem[pc++];
		b = mem[pc++];
		c = mem[pc++];
		mem[b] -= mem[a];
		
		if (mem[b] <= 0)
			pc = c;
	}
	
	return pc;
}
