; this implements a one-instruction set computer VM
; it implements the "subtract and branch if less or equal" type of OISC
; 2006-11-28
; Copyright 2006 Christopher Williams

	segu "data"
	org	code_end
	
	seg "code"
	org	0xd748
start:
	ld	(exitsp),sp
	call	main
exit:
	ld	hl,(exitsp)
	ld	sp,hl
	ret

LD_HL_MHL:
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ret

	segu "data"
exitsp	ds 2
	seg "code"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OISC instruction and macro-instructions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; the subleq instruction stores m(b) - m(a) into m(b) and then jumps to c if
; the result is 0 or negative.
; subleq = "subtract and jump if less or equal"

; basic subleq instruction
subleq	macro a,b,c
	dw a,b,c
	endm

; basic subleq with implied location
subleqc	macro a,b
	dw a,b,$+2
	endm

; stop OISC VM
stopoisc	macro
	subleq	Z,Z,0
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Macro-instructions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; jump to address
jmp_	macro c
	subleq	Z,Z,c
	endm

add_	macro a,b
	subleqc	a,Z
	subleqc	Z,b
	subleqc	Z,Z
	endm

sto_	macro	a,b
	subleqc	b,b
	subleqc	a,Z
	subleqc	Z,b
	subleqc	Z,Z
	endm

beq_	macro b,c
	subleq	b,Z,@L1
	subleq	Z,Z,@OUT
@L1	subleqc	Z,Z
	subleq	Z,b,c
@OUT
	endm

; macro-instructions from
; http://www.sccs.swarthmore.edu/users/06/adem/engin/e25/finale/

; define a constant (do we really need this?)
def_	macro x,constant
x:	dw constant
	endm

; c = a + b
add3_	macro a,b,c
	subleqc	a,Z
	subleqc	b,Z	; Z = -a - b
	subleqc	c,c	; c = 0
	subleqc	Z,c	; c = a + b
	subleqc	Z,Z	; Z = 0
	endm

; c = b - a
sub3_	macro a,b,c
	subleqc	TA,TA	; TA = 0
	subleqc	TB,TB	; TB = 0
	subleqc	a,TA
	subleqc	b,TB
	subleqc	TB,TA	; TA = b - a
	subleqc	c,c
	subleqc	TB,TB
	subleqc	TA,TB	; TB = a - b
	subleqc	TB,c	; c = b - a
	endm

; move m(a) to m(b)
; same as sto_
mov_	macro a,b
	subleqc	b,b
	subleqc	a,Z
	subleqc	Z,b
	subleqc	Z,Z
	endm

; jmp immediate (does this work?)
jmpi_	macro a
	subleqc	Z,a
	subleqc	TA,TA
	subleqc	TA,Z
	subleqc	Z,Z,TA
	endm

; if a > b then jmp c
ifgt_	macro a,b,c
	subleqc	TA,TA
	subleqc	a,TA	; TA = -a
	subleqc	TB,TB
	subleqc	b,TB	; TB = -b
	subleqc	TB,TA	; TA = b-a
	subleq	NR,TB,c	; TB = b-a+1, if (b-a+1 <= 0) JMP c
	endm

; if a <= b then jmp c
ifle_	macro a,b,c
	subleqc	TA,TA
	subleqc	a,TA	; TA = -a
	subleqc	TB,TB
	subleqc	TA,TB	; TB = a
	subleq	b,TB,c	; TB = a-b, if (a-b <= 0) JMP c
	endm

; c = a / b
div_	macro a,b,c
	subleqc	TA,TA
	subleqc	TB,TB
	subleqc	TC,TC
	
	subleqc	b,TA
	subleqc	TA,TB	; TB = b
	
	subleqc	TA,TA
	subleqc	a,TA
	subleqc	TA,TC	; TC = a
	
	subleqc	c,c
	
@loop	subleqc	NR,c	; c++
	subleq	TC,TB,@done	; b -= a, if (b <= 0) JMP @done
	subleq	ZR,ZR,@loop	; loop back to c++
@done
	endm

; c = a * b
mul_	macro a,b,c
	subleqc	TA,TA
	subleqc	TB,TB
	subleqc	TC,TC
	
	subleqc	b,TA
	subleqc	TA,TB	; TB = b
	
	subleqc	NR,c	; c = 1
	
	subleqc	TA,TA
	subleqc	a,TA	; TA = -a
	
	subleqc	c,c
	
	; sub (-a) from dest and b--, when b<=0 esc
@loop	subleqc	TA,c
	subleq	TC,TB,@done
	subleq	ZR,ZR,@loop	; loop back
@done
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end of OISC instructions and macro-instructions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; test program
main:
	call	startoisc
	sto_	word0x5555,0xfc00+16*31
	sto_	word0xaaaa,0xfc00+16*32
	stopoisc
	ret

	def_	word0x5555,0x5555
	def_	word0xaaaa,0xaaaa

; call this to start the OISC virtual machine from the current Z80 PC
startoisc:
	pop	hl		; get pc
	call	runoisc
	jp	(hl)		; return to Z80 PC

; input:
; 	hl = starting PC of OISC code
; output:
; 	hl = ending PC of OISC code
runoisc:
	ld	de,0
	ld	(Z),de
	dec	de
	ld	(NR),de
	
.inst
	; get operands
	ld	c,(hl)		; a
	inc	hl
	ld	b,(hl)
	inc	hl
	
	ld	e,(hl)		; b
	inc	hl
	ld	d,(hl)
	inc	hl
		push	hl	; save pc
		push	de	; save b
	ld	h,b
	ld	l,c
	
	; get values
	ld	c,(hl)		; bc = *a
	inc	hl
	ld	b,(hl)
	
	ex	de,hl
	
	call	LD_HL_MHL	; hl = *b
	
	; subtract
	or	a
	sbc	hl,bc
		pop	de	; restore b
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d		; store back in *b
	
		pop	hl	; restore pc
	
	; jump if leq
	jp	m,.leq		; value is <= 0
	jp	z,.leq
	
	inc	hl
	inc	hl
	jr	.inst
	
.leq	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,d
	or	e
	ret	z
	
	ex	de,hl
	jr	.inst
	
	; reserved registers for OISC machine
	segu "data"
NR	dw -1
Z	ds 2
TA	ds 2
TB	ds 2
TC	ds 2
	seg "code"
	
code_end
