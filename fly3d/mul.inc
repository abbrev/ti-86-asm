; mul.asm
; functions to multiply signed and unsigned numbers

muls:	; signed multiply
	ld	d,a
	ld	c,0		; c is negative flag
	bit	7,l
	jr	z,_lpositive
	ld	a,l
	neg
	ld	l,a		; l = |l|
	inc	c
_lpositive
	bit	7,d
	jr	z,_apositive
	ld	a,d
	neg
	ld	d,a		; a = |a|
	dec	c
_apositive
	ld	a,d
	call	mulu

	if 1
	ld	a,c
	or	a
	else
	xor	a
	or	c
	endif

	ret	z

	if 1
	xor	a
	sub	l
	ld	l,a
	ld	a,0
	sbc	a,h
	ld	h,a
	else
	ld	d,h
	ld	e,l
	xor	a
	ld	h,a
	ld	l,a
	sbc	hl,de		; hl = - hl
	endif

	ret

mulu:
;----------------------------------------------------------------------
; Fast 8-bit Multiply by Dan Eble
;----------------------------------------------------------------------
; Input:  A, L
; Output: HL= A*L
;         DE is modified
;         Flags are modified
; 64 bytes, 253-305 t-states (avg 272)
;----------------------------------------------------------------------
MUL_AxL:
        ld d,0         ; setup: DE = HL = L (zero-extended)
        ld e,l
        ld h,d
        rrca           ; check bit 0
        jr c,MAxL_0
        ld l,d         ; if 0, make total 0
MAxL_0:
        sla e          ; DE = 2*DE
        rl d
        rrca           ; check bit 1
        jr nc,MAxL_1
        add hl,de      ; if 1, add to total
MAxL_1:
        sla e
        rl d
        rrca
        jr nc,MAxL_2
        add hl,de
MAxL_2:
        sla e
        rl d
        rrca
        jr nc,MAxL_3
        add hl,de
MAxL_3:
        sla e
        rl d
        rrca
        jr nc,MAxL_4
        add hl,de
MAxL_4:
        sla e
        rl d
        rrca
        jr nc,MAxL_5
        add hl,de
MAxL_5:
        sla e
        rl d
        rrca
        jr nc,MAxL_6
        add hl,de
MAxL_6:
        sla e
        rl d
        rrca
        ret nc
        add hl,de
        ret
	
