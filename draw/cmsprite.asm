; 8x8 clipped and masked (and/xor) sprite routine
; Christopher Williams
; 2007-01-05
; tested a limited amount; works as far as testing went

rrad	macro
	jp	@right
@left	rra
@right	rr	d
	djnz	@left
	endm

rrda	macro
	jp	@right
@left	rr	d
@right	rra
	djnz	@left
	endm

; input:
; 	bc = x,y
; 	ix = sprite:
; 	 8 bytes and mask
; 	 8 bytes xor mask
cmsprite:
	ld	d,8
	
	; clip y
	ld	a,c
	cp	-7
	jp	c,.nocliptop
	
	push	de
	ld	d,0
	ld	c,d
	neg
	ld	e,a
	add	ix,de
	pop	de
	
	neg
	add	a,d
	ld	d,a
	
	xor	a
	ld	c,a
.nocliptop
	cp	64
	ret	nc
	
	cp	64-7
	jp	c,.noclipbottom
	ld	a,64
	sub	c
	ld	d,a
.noclipbottom
	
	; find screen address and shift amount
	; hl = 0xfc00 + 16*y + x/8
	; 16*y + x/8 = (128*y + x) / 8
	ld	a,b
	and	7
	ld	e,a
	
	ld	a,b
	add	a,a
	jp	nc,.nc
	; x is negative
	dec	c
	;sub	128*2	; TI-86 (no-op)
	;sub	96*2	; TI-83
.nc
	sra	c	; divide pair "ca" by 16
	rra
	sra	c
	rra
	sra	c
	rra
	sra	c
	rra
	add	a,0x00;0xfa
	ld	l,a
	ld	a,c
	adc	a,0xfc;0xC9FA
	ld	h,a
	
	; clip x
	ld	a,b
	ld	b,d	; rows
	ld	c,e	; bits
	inc	c
	ld	e,16
	
	cp	128-7
	jp	c,.noclipx
	; past right or left edge
	; clip in x direction here
	
	cp	128
	jp	c,clipright
	
	cp	-7
	ret	c	; not visible
	
	inc	hl
	jp	clipleft
.noclipx
	ld	a,c
	dec	a
	jp	nz,drawmiddle
	; fall through

drawaligned:
	ld	d,a
.row
	; and
	ld	a,(ix+0)
	and	(hl)
	ld	(hl),a
	
	; xor
	ld	a,(ix+8)
	xor	(hl)
	ld	(hl),a
	
	add	hl,de
	inc	ix
	djnz	.row
	ret

; input:
; 	b = rows
; 	c = bits to shift
; 	ix = sprite
; 	hl = screen
drawmiddle:
.row
	push	bc
	
	; and
	ld	a,(ix+0)
	ld	d,0xff
	ld	b,c
	scf
	rrad
	and	(hl)
	ld	(hl),a
	inc	hl
	ld	a,d
	and	(hl)
	ld	(hl),a
	
	; xor
	ld	d,(ix+8)
	xor	a
	ld	b,c
	rrda
	xor	(hl)
	ld	(hl),a
	dec	hl
	ld	a,d
	xor	(hl)
	ld	(hl),a
	
	ld	d,b
	add	hl,de
	inc	ix
	pop	bc
	djnz	.row
	ret

clipleft:
.row
	push	bc
	
	; and
	ld	d,(ix+0)
	ld	a,0xff
	ld	b,c
	scf
	rrda
	and	(hl)
	ld	(hl),a
	
	; xor
	ld	d,(ix+8)
	xor	a
	ld	b,c
	rrda
	xor	(hl)
	ld	(hl),a
	
	ld	d,b	; 4, 1
	add	hl,de	;11, 1
	inc	ix
	pop	bc
	djnz	.row
	ret

clipright:
.row
	push	bc
	
	; and
	ld	a,(ix+0)
	ld	d,0xff
	ld	b,c
	scf
	rrad
	and	(hl)
	ld	(hl),a
	
	; xor
	ld	a,(ix+8)
	ld	d,0
	ld	b,c
	or	a
	rrad
	xor	(hl)
	ld	(hl),a
	
	ld	d,b
	add	hl,de
	inc	ix
	pop	bc
	djnz	.row
	ret
