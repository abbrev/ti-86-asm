 org 0xd748
	ld	hl,.numberstr
	call	atoi
	ret

.numberstr	db "-12345",0

 include "atoi.asm"
