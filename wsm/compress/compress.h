#ifndef _COMPRESS_H_
#define _COMPRESS_H_

unsigned char *compress(unsigned char *dest, unsigned char const *src, unsigned int size);
unsigned char *decompress(unsigned char *dest, unsigned char const *src/*, unsigned int size*/);

#endif /* _COMPRESS_H_ */
