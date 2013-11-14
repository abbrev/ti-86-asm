; rpn.asm, RPN interpreter
; usage:
; 	call	rpn
; 	rpn_codes
; 	...
; 	rtn

rpn:
	pop	hl
	ld	(rpn_pc),hl
	ld	ix,(rpn_sp)
rpn_exec:
	ld	hl,(rpn_pc)
	ld	a,(hl)		; get instruction
	inc	hl
	ld	(rpn_pc),hl	; pc -> next instruction
	
	ld	l,a
	ld	h,0
	add	hl,hl
	ld	de,rpn_ops
	add	hl,de
	call	jp_mhl
	jr	rpn_exec

jp_mhl:	jp	(hl)

rpn_ops:	; table of operators
	dw	rtn		; 00
; *** FIXME: reorder these following entries when the interpreter is done ***
	dw	push
	dw	pop
	dw	dup
	dw	exch
	dw	add
	dw	inc
	dw	dec
	dw	load
	dw	store
	dw	eq
	dw	ne
	dw	gt
	dw	lt
	dw	ge
	dw	le

; rpn operators below here

rtn:	; return to Z80 code
	ld	(rpn_sp),ix
	pop	bc		; return address
	ld	hl,(rpn_pc)
	jp	(hl)
push:	; push value onto stack
	ld	hl,(rpn_pc)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(rpn_pc),hl
	dec	ix
	dec	ix
	ld	(ix+0),e
	ld	(ix+1),d
	ret
pop:	; pop top value off stack
	inc	ix
	inc	ix
	ret
dup:	; duplicate first value
	dec	ix
	dec	ix
	ld	a,(ix+2)
	ld	(ix+0),a
	ld	a,(ix+3)
	ld	(ix+1),a
	ret
exch:	; exchange first two values
	ld	e,(ix+0)
	ld	d,(ix+1)
	
	ld	a,(ix+2)
	ld	(ix+0),a
	ld	a,(ix+3)
	ld	(ix+1),a
	
	ld	(ix+2),e
	ld	(ix+3),d
	ret
add:	; add two values
	ld	e,(ix+0)
	ld	d,(ix+1)
	inc	ix
	inc	ix
	ld	l,(ix+0)
	ld	h,(ix+1)
	add	hl,de
	ld	(ix+0),l
	ld	(ix+1),h
	ret
sub:	; subtract two values
	ld	e,(ix+0)
	ld	d,(ix+1)
	inc	ix
	inc	ix
	ld	l,(ix+0)
	ld	h,(ix+1)
	or	a	; clear carry
	sbc	hl,de
	ld	(ix+0),l
	ld	(ix+1),h
	ret
inc:	; increment
	ld	l,(ix+0)
	ld	h,(ix+1)
	inc	hl
	ld	(ix+0),l
	ld	(ix+1),h
	ret
dec:	; decrement
	ld	l,(ix+0)
	ld	h,(ix+1)
	dec	hl
	ld	(ix+0),l
	ld	(ix+1),h
	ret
load:	; load value
	ld	l,(ix+0)
	ld	h,(ix+1)
	dec	ix
	dec	ix
	ld	a,(hl)
	ld	(ix+0),a
	inc	hl
	ld	a,(hl)
	ld	(ix+1),a
	ret
store:	; store value
	ld	e,(ix+0)
	ld	d,(ix+1)
	ld	l,(ix+2)
	ld	h,(ix+3)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	ix
	inc	ix
	inc	ix
	inc	ix
	ret
eq:
	ld	e,(ix+0)
	ld	d,(ix+1)
	ld	l,(ix+2)
	ld	h,(ix+3)
	inc	ix
	inc	ix
ne:
gt:
lt:
ge:
le:
	ret

	segu	"data"
rpn_pc	ds	2
rpn_sp	ds	2
	
	ifndef	RPNSTACKSIZE
RPNSTACKSIZE	equ	100
	endif
	
rpn_stack:
	ds	RPNSTACKSIZE
	seg	"code"
