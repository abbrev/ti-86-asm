#include <stdio.h>
#include <string.h>

size_t strlen(const char *s)
{
	char *end;
	for (end = (char *)s; *end; ++end)
		;
	return end - s;
}

int strncmp(const char *s1, const char *s2, size_t n)
{
	int c;
	for (; n; ++s1, ++s2, --n) {
		c = *s1;
		if (c == '\0')
			return c-*s2;
		
		c-=*s2;
		if (c)
			return c;
	}
	return 0;
}

char *strstr(const char *haystack, const char *needle)
{
	int len = strlen(needle);
	char *s;
	for (s = (char *)haystack; strncmp(s, needle, len); ++s) {
		if (*s == '\0')
			return NULL;
	}
	return s;
}

int main()
{
	char s1[] = "food";
	char s2[] = "fork";
	char s3[] = "";
	printf("%d\n", strncmp(s1, s2, 2));
	printf("%p\n", strstr(s1, s3));
	return 0;
}
