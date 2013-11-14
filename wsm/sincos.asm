; sincos.asm, sine and cosine table
; by Chris Williams

; input is 0..256 instead of 0..360
; returns -127..127 instead of -1..1
; For cosine, add 64 to A or to sintable
; Define a 320-byte sintable label

; MUST call buildsintable before the sine table (sintable) is used.
; 32 bytes
buildsintable:
	ld	hl,.presintable
	ld	de,sintable
	ld	bc,65
	push	de
	ldir

	dec	hl
	ld	b,63	; hl = .presintable + 64, de = .presintable + 65
.mirror
	dec	hl
	ld	a,(hl)
	ld	(de),a
	inc	de
	djnz	.mirror

	pop	hl	; hl = sintable, de = sintable + 128
	ld	b,128+64	; 64 more entries for cosine
.negative
	xor	a
	sub	(hl)		; negative of (hl)
	inc	hl
	ld	(de),a		; faster than "ld a,(hl)\ neg"
	inc	de
	djnz	.negative
	
	ret

; 65-entry 1-byte sine table
; this holds a quarter (plus one) of a full sine wave
.presintable:
	db    0,   3,   6,   9,  12,  15,  18,  21
	db   24,  27,  30,  33,  36,  39,  42,  45
	db   48,  51,  54,  57,  59,  62,  65,  67
	db   70,  73,  75,  78,  80,  82,  85,  87
	db   89,  91,  94,  96,  98, 100, 102, 103
	db  105, 107, 108, 110, 112, 113, 114, 116
	db  117, 118, 119, 120, 121, 122, 123, 123
	db  124, 125, 125, 126, 126, 126, 126, 126
	db  127
