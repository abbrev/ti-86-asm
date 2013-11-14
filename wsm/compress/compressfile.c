#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#define PROGRAMNAME "compressfile"

#define RUN_MARKER	0xC0
#define MAX_RUN_LEN	63

int compress(FILE *src, FILE *dest)
{
	unsigned int count;
	unsigned char val;
	int c;
	
	c = fgetc(src);
	while (c != EOF) {
#if DEBUG
	fprintf(stderr, "getting '%c'\n", c);
#endif
		count = 1;
		val = c;
		
		while ((c = fgetc(src)) != EOF && val == c && count < MAX_RUN_LEN)
			++count;
		
#if DEBUG
	fprintf(stderr, "count = %d\n", count);
#endif
		if (count > 1 || (val & RUN_MARKER) == RUN_MARKER)
			fputc(count | RUN_MARKER, dest);
		
#if DEBUG
	fprintf(stderr, "putting '%c'\n", val);
#endif
		fputc(val, dest);
		
		if (c == EOF)
			break;
	}
	fputc(RUN_MARKER, dest); /* end of the compressed data */
	fflush(dest);
	
	return 0;
}

void usage(void)
{
	fputs("Usage: "PROGRAMNAME" [infile] [outfile]\n"
	  "If infile is missing or is \"-\", then standard in is used.\n"
	  "If outfile is missing or is \"-\", then standard out is used.\n",
	  stderr);
}

int main(int argc, char *argv[])
{
	int arg;
	FILE *srcfile, *destfile;
	char *srcfilename = NULL, *destfilename = NULL;
	
	for (arg = 1; arg < argc; ++arg) {
		if (!srcfilename)
			srcfilename = argv[arg];
		else if (!destfilename)
			destfilename = argv[arg];
		else {
			usage();
			exit(-1);
		}
	}
	
	if (!srcfilename || !strcmp(srcfilename, "-"))
		srcfile = stdin;
	else {
		srcfile = fopen(srcfilename, "rb");
		if (!srcfile) {
			perror(srcfilename);
			exit(-1);
		}
	}
	
	if (!destfilename || !strcmp(destfilename, "-"))
		destfile = stdout;
	else {
		destfile = fopen(destfilename, "wb");
		if (!destfile) {
			perror(destfilename);
			exit(-1);
		}
	}
	
	compress(srcfile, destfile);
	
	return 0;
}
