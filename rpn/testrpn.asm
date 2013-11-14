	segu "data"
	org code_end
	seg "code"
	
	org 0xd748
	call	rpn
	dw	0
	ret

	include "rpn.asm"

code_end
