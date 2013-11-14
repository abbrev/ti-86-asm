; strxfrm - string transformation
; $Id: strxfrm.asm,v 1.2 2007/02/15 18:19:49 christop Exp $
; 
; input:
; 	de = address of dest
; 	hl = address of src
; 	bc = n (maximum number of characters to copy)
; output:
; 	hl = number of bytes required to store the transformed string in dest
; 	 excluding the terminating '\0' character.
strxfrm:
	call	strncpy
	jp	strlen		; XXX: is this the correct meaning of the
				; return value?
