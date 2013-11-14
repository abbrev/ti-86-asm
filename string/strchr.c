#include <stdio.h>
#include <string.h>

int main()
{
	char s[] = "";
	printf("%p, %p\n", s, strchr(s, 0));
	return 0;
}
