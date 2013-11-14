; compress.inc

RUN_MARKER	equ 0xC0
MAX_RUN_LEN	equ 255-RUN_MARKER

 ifdef NEED_COMPRESS
; input:
; 	hl	address of data to compress
; 	de	buffer for compressed data
; 	bc	size of data
compress:
		push	hl
		pop	ix	; ix = src
	jr	.compress2
.compress1
	ld	h,1		; count = 1
	ld	a,(ix)		; val = *src
	dec	bc		; --size
	ld	l,a
	jr	.compress4
.compress3
	inc	h		; ++count;
	dec	bc		; --size;
	inc	ix		; ++src
.compress4
	cp	(ix)
	jr	nz,.compress5
	ld	a,h
	cp	MAX_RUN_LEN
	jr	z,.compress5
	ld	a,b
	or	c
	ld	a,l
	jr	nz,.compress3	; while (val == *++src && count < MAX_RUN_LEN && size)
.compress5
	ld	a,h
	cp	2		; count > 1
	ld	a,RUN_MARKER
	jr	nc,.compress6
	and	l
	cp	RUN_MARKER	; (val & RUN_MARKER) == RUN_MARKER
	jr	nz,.compress7
.compress6
	or	h
	ld	(de),a
	inc	de		; *dest++ = count | RUN_MARKER
.compress7
	ld	a,l
	ld	(de),a
	inc	de		; *dest++ = val
.compress2
	ld	a,b
	or	c
	jr	nz,.compress1	; while (size)
	ld	a,RUN_MARKER
	ld	(de),a
	inc	de		; *dest++ = RUN_MARKER
	ret			; return dest
 endif

 ifdef NEED_DECOMPRESS
; input:
; 	hl	compressed data to decompress
; 	de	buffer for uncompressed data
; size: 22 bytes
decompress:			; while (1)
	ld	a,(hl)
	inc	hl		; val = *src++
	cp	RUN_MARKER
	ret	z		; RUN_MARKER marks the end of compressed data
	ld	b,1
	jr	c,.runloop	; is this a run?
	and	MAX_RUN_LEN	; yes
	ld	b,a		; count = val & ~RUN_MARKER
	ld	a,(hl)
	inc	hl		; val = *src++
.runloop
	ld	(de),a
	inc	de		; *dest++ = val
	djnz	.runloop
	jr	decompress
	ret			; return dest
 endif
