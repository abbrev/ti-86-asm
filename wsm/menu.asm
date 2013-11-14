; Generic menu routine
; version 0.1
; 2006-07-24
; 
; Author: Christopher Williams
; Email: abbrev@gmail.com

VIDEO_MEM_WIDTH	equ 16
VIDEO_HEIGHT	equ 64

setpenpos	macro	row,col
	ld	bc,row*256+col
	ld	(_penCol),bc
		endm

; struct menu {
; 	char *title		2 bytes
; 	void (*action)(int key, int selection)	2 bytes
; 	unsigned short numitems	2 bytes
; 	struct {
; 		char *title	2 bytes
; 		void (*action)(void)	2 bytes
; 	} items[];	4 bytes total per item
; };


; input:
; 	hl = struct menu *m (menu)
; 	de = int initsel (initial selection)
; output:
; 	none
run_menu:
	push	ix		; allocate local variables
	ld	ix,0
	add	ix,sp
	push	hl		; menu = m
	
	; local variables and arguments:
	segu	"offsets"
	org	-6
.selected	ds	2
.numitems	ds	2
.menu	ds	2
.frameptr	ds	2
.retaddr	ds	2
	seg	"code"
	
	ld	bc,4
	add	hl,bc		; hl = &menu->numitems
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	bc		; numitems = menu->numitems
	
	ex	de,hl		; hl = initsel
	ld	d,b
	ld	e,c
	push	hl
	or	a
	sbc	hl,de
	pop	hl
	jr	c,.initselok
	ld	hl,0
.initselok
	push	hl		; selected = initsel
	
.redraw
	; draw menu from scratch
	
	; erase rectangle (24,2)-(103,61)
	ld	hl,VIDEO_MEM+2*16+24/8
	ld	bc,10*256+64-4
	call	eraserect
	
	; OR borders
	ld	c,0b00000011
	ld	b,64
	ld	hl,VIDEO_MEM+22/8
	call	vborder
	ld	c,0b11000000
	ld	b,64
	ld	hl,VIDEO_MEM+104/8
	call	vborder
	
	ld	hl,VIDEO_MEM+16*0+24/8
	ld	b,low (104-24)/8
	call	hborder
	ld	hl,VIDEO_MEM+16*9+24/8
	ld	b,low (104-24)/8
	call	hborder
	ld	hl,VIDEO_MEM+16*62+24/8
	ld	b,low (104-24)/8
	call	hborder
	
	; draw selection box
	ld	a,0b11111111
	ld	hl,VIDEO_MEM+32/8+VIDEO_MEM_WIDTH*32
	ld	b,8
.seltoploop
	ld	(hl),a
	inc	hl
	djnz	.seltoploop
	
	ld	hl,VIDEO_MEM+32/8+VIDEO_MEM_WIDTH*40
	ld	b,8
.selbtmloop
	ld	(hl),a
	inc	hl
	djnz	.selbtmloop
	
	ld	a,0b01111111
	ld	(VIDEO_MEM+24/8+VIDEO_MEM_WIDTH*32),a
	ld	(VIDEO_MEM+24/8+VIDEO_MEM_WIDTH*40),a
	ld	a,0b11111110
	ld	(VIDEO_MEM+96/8+VIDEO_MEM_WIDTH*32),a
	ld	(VIDEO_MEM+96/8+VIDEO_MEM_WIDTH*40),a
	
	; write the title
	ld	l,(ix+.menu)
	ld	h,(ix+.menu+1)
	
	setpenpos	2,25
	call	.writeitem
	
.writeitems
	ld	de,VIDEO_MEM_WIDTH
	ld	hl,VIDEO_MEM+24/8+VIDEO_MEM_WIDTH*33
	ld	b,7
	ld	a,0b01000000
.selleftloop
	ld	(hl),a
	add	hl,de
	djnz	.selleftloop
	
	ld	hl,VIDEO_MEM+96/8+VIDEO_MEM_WIDTH*33
	ld	b,7
	ld	a,0b00000010
.selrightloop
	ld	(hl),a
	add	hl,de
	djnz	.selrightloop
	
	; write the items
	ld	l,(ix+.selected)
	ld	h,(ix+.selected+1)
	push	hl
	call	.getitem
	
	; current selection
	setpenpos	33,27
	push	hl
	call	.writeitem
	pop	hl
	pop	de
	
	push	de
	push	hl
	
	ld	b,3
	ld	c,41		; starting pen row
	; hl = address of current item (contains address of title string)
	; de = item number
	; b = counter
	; c = pen row
.bottomloop
	inc	de
	ld	a,e
	cp	(ix+.numitems)
	jr	nz,.nz1
	ld	a,d
	cp	(ix+.numitems+1)
	jr	z,.bottomdone
.nz1
	ld	a,c
	ld	(_penRow),a
	add	a,6
	ld	c,a
	ld	a,27
	ld	(_penCol),a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	call	.writeitem
	djnz	.bottomloop
.bottomdone
	
	pop	hl
	pop	de
	
	ld	b,3
	ld	c,25		; starting pen row
.toploop
	ld	a,d
	or	e
	jr	z,.topdone
	
	dec	de
	ld	a,c
	ld	(_penRow),a
	sub	6
	ld	c,a
	ld	a,27
	ld	(_penCol),a
	dec	hl
	dec	hl
	dec	hl
	dec	hl
	call	.writeitem
	djnz	.toploop
.topdone

; main loop
.loop
	push	ix
	
.keyloop
	halt
	call	GET_KEY
	or	a
	jr	z,.keyloop
	
	pop	ix
	
	cp	K_UP
	jr	nz,.notup
	; up
	
	ld	a,(ix+.selected)	; if (selected != 0)
	or	(ix+.selected+1)
	jr	z,.loop
	
	ld	l,(ix+.selected)
	ld	h,(ix+.selected+1)
	dec	hl
	ld	(ix+.selected),l
	ld	(ix+.selected+1),h	; --selected
	jr	.eraseitems
.notup
	cp	K_DOWN
	jr	nz,.notdown
	; down
	
	ld	l,(ix+.selected)	; if (selected != numitems - 1)
	ld	h,(ix+.selected+1)
	inc	hl
	ld	a,l
	cp	(ix+.numitems)
	jr	nz,.nz2
	ld	a,h
	cp	(ix+.numitems+1)
	jr	z,.loop
.nz2
	ld	(ix+.selected),l
	ld	(ix+.selected+1),h
.eraseitems
	ld	bc,10*256+6*3
	ld	hl,VIDEO_MEM+24/8+VIDEO_MEM_WIDTH*13
	call	eraserect
	ld	bc,10*256+6*3
	ld	hl,VIDEO_MEM+24/8+VIDEO_MEM_WIDTH*41
	call	eraserect
	ld	bc,10*256+6
	ld	hl,VIDEO_MEM+24/8+VIDEO_MEM_WIDTH*33
	call	eraserect
	jp	.writeitems
.notdown
	cp	K_EXIT
	jr	nz,.notexit
	jr	.done
.notexit
	cp	K_ENTER
	jr	z,.enter
	cp	K_SECOND
	jr	nz,.not2nd
.enter
	; enter/2nd
	ld	b,a
	ld	l,(ix+.selected)
	ld	h,(ix+.selected+1)
	call	.getitem
	inc	hl
	inc	hl		; hl = &menu->items[selected].action
.doaction
	call	LD_HL_MHL
	or	h
	jp	z,.loop
	
	ld	a,b
	ld	e,(ix+.selected)
	ld	d,(ix+.selected+1)
	
	push	ix
	call	jp_mhl		; menu->items[selected].action()
	pop	ix
	
	jp	.redraw
.not2nd
	ld	b,a
	ld	l,(ix+.menu)
	ld	h,(ix+.menu+1)
	inc	hl
	inc	hl		; hl = &menu->action
	jr	.doaction
.while
	jp	.loop
	
.done
	ld	sp,ix		; free space from local variables
	pop	ix
	ret

; input:
; 	hl = number of item
; output:
; 	hl = address of item
.getitem:
	add	hl,hl
	add	hl,hl		; hl = num*(sizeof(menu->items[].title)
				;    + sizeof(menu->items[].action)) = num*18
	ld	e,(ix+.menu)
	ld	d,(ix+.menu+1)
	add	hl,de
	ld	de,6
	add	hl,de		; hl = &menu->items[num]
	ret

; input:
; 	hl = char **
; hl, de, and bc are preserved
.writeitem:
	push	bc
	push	de
	push	hl
	
	call	LD_HL_MHL
	call	_vputs
	
	pop	hl
	pop	de
	pop	bc
	ret

; draw horizontal border
; hl = start LCD address
; b = byte count
hborder
	ld	a,0b11111111
	ld	c,2
	ld	de,VIDEO_MEM_WIDTH
.hb1
	push	hl
	push	bc
.hb2
	ld	(hl),a
	inc	hl
	djnz	.hb2
	
	pop	bc
	pop	hl
	add	hl,de
	dec	c
	jr	nz,.hb1
	ret

; draw vertical border
; hl = start LCD address
; b = row count
; c = OR mask
vborder
	ld	de,VIDEO_MEM_WIDTH
.vb1
	ld	a,(hl)
	or	c
	ld	(hl),a
	add	hl,de
	djnz	.vb1
	ret

jp_mhl:
	jp	(hl)

; input:
; 	hl = starting address
; 	b = width, in bytes
; 	c = height, in pixels
; output:
; 	hl = address below bottom row of rect
eraserect:
	ld	a,VIDEO_MEM_WIDTH
	sub	b
	ld	e,a
	sbc	a,a
	ld	d,a
	xor	a
.yloop	push	bc
.xloop	ld	(hl),a
	inc	hl
	djnz	.xloop
	
	pop	bc
	add	hl,de
	dec	c
	jr	nz,.yloop
	ret
