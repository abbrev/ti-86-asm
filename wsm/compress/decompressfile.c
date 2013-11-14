#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#define PROGRAMNAME "decompressfile"

#define RUN_MARKER	0xC0
#define MAX_RUN_LEN	63

int decompress(FILE *src, FILE *dest)
{
	unsigned int count;
	unsigned int val;
	
	while (1) {
		if ((val = fgetc(src)) == EOF)
			return -1;
		
		if (val == RUN_MARKER)
			break;
		
		if ((val & RUN_MARKER) == RUN_MARKER) {
			count = val & ~RUN_MARKER;
			if ((val = fgetc(src)) == EOF)
				return -1;
			for (; count; --count)
				if (fputc(val, dest) == EOF)
					return -1;
		} else
			if (fputc(val, dest) == EOF)
				return -1;
	}
	
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
	
	decompress(srcfile, destfile);
	
	return 0;
}
