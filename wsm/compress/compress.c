#include "compress.h"

#define RUN_MARKER	0xC0
#define MAX_RUN_LEN	63

unsigned char *compress(unsigned char *dest, unsigned char const *src, unsigned int size)
{
	unsigned int count;
	unsigned char val;
		
	while (size) {
		count = 1;
		val = *src;
		--size;
		
		while (val == *++src && count < MAX_RUN_LEN && size) {
			++count;
			--size;
		}
		
		if (count > 1 || (val & RUN_MARKER) == RUN_MARKER)
			*dest++ = count | RUN_MARKER;
		
		*dest++ = val;
	}
	*dest++ = RUN_MARKER; /* this marks the end of the compressed data */
	return dest;
}

unsigned char *decompress(unsigned char *dest, unsigned char const *src)
{
	unsigned int count;
	unsigned char val;
	while (1) {
		val = *src++;
		
		if (val == RUN_MARKER)
			break;
		
		if ((val & RUN_MARKER) == RUN_MARKER) {
			count = val & ~RUN_MARKER;
			for (val = *src++; count; --count)
				*dest++ = val;
		} else
			*dest++ = val;
	}
	
	return dest;
}
