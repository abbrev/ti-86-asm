; mouse.asm
; Christopher Williams
; 2006-12-26, 2006-12-27
; this emulates a mouse using the arrow keys for direction and 2nd for a button
; this can be cleaned up a lot, particularly with the background-saving and
; -restoring code in showcursor in hidecursor, respectively.

	;include "asm86.h"

; multiply register B with constant N and divides by 256
; result is in register A
; I'm sure this could be done better.
multBxN	macro n
	xor	a
	
	if n&1
	add	a,b
	rra
	endif
	
	if n&2
	add	a,b
	rra
	else
	if n&3
	srl	a
	endif
	endif
	
	if n&4
	add	a,b
	rra
	else
	if n&7
	srl	a
	endif
	endif
	
	if n&8
	add	a,b
	rra
	else
	if n&15
	srl	a
	endif
	endif
	
	if n&16
	add	a,b
	rra
	else
	if n&31
	srl	a
	endif
	endif
	
	if n&32
	add	a,b
	rra
	else
	if n&63
	srl	a
	endif
	endif
	
	if n&64
	add	a,b
	rra
	else
	if n&127
	srl	a
	endif
	endif
	
	if n&128
	add	a,b
	rra
	else
	if n&255
	srl	a
	endif
	endif
	
	endm

	if 0

; multiply B by C and divide by 256.
; result is in A
; min 198 cycles (C=255), max 206 cycles (C=0), avg 202 cycles
multBxC:
	xor	a		; 4
	rrc	c		; 8
	jr	nc,.nc1		; 12/7
	add	a,b		; 4
.nc1	rra			; 4
	rrc	c		; 8
	jr	nc,.nc2		; 12/7
	add	a,b		; 4
.nc2	rra			; 4
	rrc	c		; 8
	jr	nc,.nc4		; 12/7
	add	a,b		; 4
.nc4	rra			; 4
	rrc	c		; 8
	jr	nc,.nc8		; 12/7
	add	a,b		; 4
.nc8	rra			; 4
	rrc	c		; 8
	jr	nc,.nc16	; 12/7
	add	a,b		; 4
.nc16	rra			; 4
	rrc	c		; 8
	jr	nc,.nc32	; 12/7
	add	a,b		; 4
.nc32	rra			; 4
	rrc	c		; 8
	jr	nc,.nc64	; 12/7
	add	a,b		; 4
.nc64	rra			; 4
	rrc	c		; 8
	jr	nc,.nc128	; 12/7
	add	a,b		; 4
.nc128	rra			; 4
	
	ret			; 10

	endif

MOUSE_MOVE equ 0x01
MOUSE_DOWN equ 0x02
MOUSE_UP   equ 0x04
KEY_DOWN   equ 0x08
KEY_UP     equ 0x10
TIMER_EXPIRED equ 0x20

	segu "structs"

;mouse event structure
;0 byte type (MOUSE_MOVE, MOUSE_DOWN, or MOUSE_UP)
;1 word time
;3 byte x
;4 byte y
;5 byte button

	org 0
mevent_type   ds 1
mevent_time   ds 2
mevent_x      ds 1
mevent_y      ds 1
mevent_button ds 1

;key event structure
;0 byte type (KEY_DOWN or KEY_UP)
;1 word time
;3 byte keycode
;4 byte pad1
;5 byte pad2

	org 0
kevent_type    ds 1
kevent_time    ds 2
kevent_keycode ds 1
kevent_pad     ds 2

;timer event structure
;0 byte type (TIMER_EXPIRED)
;1 word time
;3 byte pad1
;4 byte pad2
;5 byte pad3

	org 0
tevent_type   ds 1
tevent_time   ds 2
tevent_pad    ds 3

	seg "code"

EVENTSIZE equ 6
QSIZE equ 8

INTVECTORS equ 0xf600

; I don't know much about IM2 on the real TI-86. Does it jump to the first
; vector (at address I<<8)?
; If this doesn't work on real hardware, set this to something like 0xf7f7, and
; uncomment the ldir below.
INTERRUPT equ mouse_int ;0xf700

; init the mouse variables, interrupt, etc.
initmouse:
	ld	hl,defaultcursor
	ld	(cursor),hl
	xor	a
	ld	(numevents),a
	ld	(buttonstate),a
	ld	(eventmask),a
	ld	(mousedelay),a
	
	ld	h,a
	ld	l,a
	ld	(timervalue),hl
	ld	(timerinterval),hl
	ld	(time),hl
	ld	(mousey),hl
	
	inc	a
	ld	(cursorvisible),a
	
	; get an initial view of the keypad
	call	scankeypad
	
	; init interrupt
	di
	ld	hl,INTVECTORS
	;ld	de,INTVECTORS+2
	;ld	bc,254
	ld	(hl),INTERRUPT%256
	inc	hl
	ld	(hl),INTERRUPT/256
	;ldir
	
	if INTERRUPT+mouse_int_size > 0xfa70
	error "mouse int is too big!"
	endif
	
	if mouse_int != INTERRUPT
	ld	hl,mouse_int
	ld	de,INTERRUPT
	ld	bc,mouse_int_size
	ldir
	endif
	
	ld	a,INTVECTORS>>8
	ld	i,a
	im	2
	ei
	ret
	
	;jp	showcursor

mouse_int:
	rorg	INTERRUPT
	ex	af,af'
	exx
	
	ld	hl,(time)
	inc	hl
	ld	(time),hl
	
	ld	hl,(timervalue)
	ld	a,h
	or	l
	jr	z,.timernz
	dec	hl
	ld	(timervalue),hl
	ld	a,h
	or	l
	jr	nz,.timernz
	
	; the timer expired
	call	qnextevent
	jr	c,.qfull
	
	ld	(hl),TIMER_EXPIRED
	inc	hl
	ld	de,(time)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	
	ld	hl,numevents
	inc	(hl)
	
.qfull
	ld	hl,(timerinterval)
	ld	(timervalue),hl
.timernz
	
	; copy keypad matrix to old matrix
	ld	hl,keypad
	ld	de,oldkeypad
	ld	bc,7
	ldir
	
	call	scankeypad
	
	ld	hl,keypad+0
	ld	c,(hl)
	ld	de,(mousey)	; d = x, e = y
	
	; down, left, right, up
	rrc	c
	jr	c,.nodown
	inc	e
.nodown
	rrc	c
	jr	c,.noleft
	ld	a,d
	sub	1
	ld	d,a
	jr	nc,.noleft
	inc	d
.noleft
	rrc	c
	jr	c,.noright
	inc	d
.noright
	rrc	c
	jr	c,.noup
	ld	a,e
	sub	1
	ld	e,a
	jr	nc,.noup
	inc	e
.noup
	
	ld	a,d
	cp	128
	jr	c,.goodx
	ld	d,127
.goodx
	
	ld	a,e
	cp	64
	jr	c,.goody
	ld	e,63
.goody
	
	ld	a,(mousex)
	xor	d
	jr	nz,.move
	
	ld	a,(mousey)
	xor	e
	jr	z,.resetdelay
	
	if 0
	ld	hl,mousedelay
	ld	a,(hl)
	dec	(hl)
	or	a
	jp	nz,.nomove
	
	ld	a,MOUSEDELAY
	ld	(hl),a
	endif
	
.move
	; move cursor
	ld	hl,mousedelay
	dec	(hl)
	jp	nz,.nomove
	ld	hl,mousedelaydelay
	ld	a,(hl)
	ld	(mousedelay),a
	cp	MINDELAY
	jr	z,.min
	
	; in-line multiplication
	if DELAYMULT == 128
	
	srl	a
	
	else
	
	ld	b,a
	multBxN	DELAYMULT
	
	endif
	
	cp	MINDELAY
	jr	nc,.gemin
.lessmin
	ld	a,MINDELAY
.gemin
	ld	(mousedelaydelay),a
.min
	call	movemouse
	jr	.nomove
	
.resetdelay
	ld	a,MAXDELAY
	ld	(mousedelaydelay),a
	ld	a,1
	ld	(mousedelay),a
.nomove
	
	ld	hl,oldkeypad+6
	ld	a,(hl)
	ld	hl,keypad+6
	xor	(hl)
	and	0b00100000	; 2nd
	jr	z,.no2nddiff
	; state of 2nd key changed
	and	(hl)
	; A is the state of the 2nd key
	ld	hl,buttonstate
	jr	z,.buttondown
	
	; button is up
	;
	ld	(hl),0
	jr	.addbutton
	
.buttondown
	; button is up
	;
	ld	(hl),1
.addbutton
	call	qnextevent
	jr	c,.no2nddiff	; queue is full
	ld	a,(buttonstate)
	or	a
	jr	z,.up
	ld	a,MOUSE_DOWN
	jr	.notup
.up
	ld	a,MOUSE_UP
.notup
	ld	(hl),a
	inc	hl
	ld	de,(time)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	de,(mousey)
	ld	(hl),d
	inc	hl
	ld	(hl),e
	inc	hl
	ld	a,(buttonstate)
	ld	(hl),a
	
	ld	hl,numevents
	inc	(hl)
.no2nddiff
	
	; now check for keys up/down
	ld	b,7
	ld	hl,keypad+6
	ld	de,oldkeypad+6
.keyloop
	ld	a,(de)
	xor	(hl)
	jr	z,.nokeys
	; A key was pressed/released. Find out which one.
	push	bc
	push	de
	push	hl
	segu	"data"
.row	ds 1
	seg	"code"
	ld	hl,.row
	ld	(hl),b
	pop	hl
	ld	b,a
	ld	c,0b10000000
	ld	d,7	; current key in row
.keyrowloop
	ld	a,b
	and	c
	jr	z,.notthiskey
	; this key was pressed/released
	ld	a,d
	segu	"data"
.col	ds 1
	seg	"code"
	ld	(.col),a
	ld	a,(hl)
	and	c
	jr	z,.z
	ld	e,KEY_UP
	jr	.nz
.z
	ld	e,KEY_DOWN	; e = event
.nz
	push	hl
	
	push	bc
	push	de
	
	call	qnextevent
	pop	de
	jr	c,.qfull2
	
	; add key event to queue
	ld	(hl),e
	inc	hl
	ld	bc,(time)
	ld	(hl),c
	inc	hl
	ld	(hl),b
	inc	hl
	push	hl
	; compute the keycode
	ld	hl,.row
	ld	a,(hl)
	dec	a
	rlca
	rlca
	rlca
	ld	hl,.col
	add	a,(hl)
	inc	a
	pop	hl
	ld	(hl),a
	
	ld	hl,numevents
	inc	(hl)
.qfull2
	pop	bc
	pop	hl
.notthiskey
	dec	d
	rrc	c
	jr	nc,.keyrowloop
	
	pop	de
	pop	bc
.nokeys
	dec	hl
	dec	de
	djnz	.keyloop
	
	ex	af,af'
	exx
	ei
	reti
	rorg	$$
mouse_int_size	equ	$-mouse_int

scankeypad:
	; scan keypad
	ld	b,7
	ld	c,0b11111110
	ld	hl,keypad
.scan
	ld	a,c
	out	(1),a
	in	a,(1)
	ld	(hl),a
	inc	hl
	rlc	c
	djnz	.scan
	ret

; get the address of the next event in queue
; carry is set if queue is full
qnextevent:
	ld	a,(numevents)
	cp	QSIZE
	scf
	ret	z
	ld	b,a
	add	a,a
	add	a,b
	add	a,a	; *6
	ld	d,0
	ld	e,a
	ld	hl,eventqueue
	add	hl,de
	or	a
	ret

; output:
; 	de = x,y of mouse
getmouse:
	ld	de,(mousey)
	ret

; FIXME: should movemouse cause a MOUSE_MOVE event?
; input:
; 	de = x,y of mouse
movemouse:
	; wrap-around
	ld	a,d
	and	127
	ld	d,a
	ld	a,e
	and	63
	ld	e,a
	
	; erase from old position
	push	de
	call	hidecursor
	pop	de
	
	; draw in new position
	ld	(mousey),de
	call	showcursor
	
	; add event to queue
	; if there are no events in the queue, or if the last event was not
	; MOUSE_MOVE, we'll add a new event
	di
	ld 	hl,numevents
	ld	a,(hl)
	or	a
	jr	z,.addmove2
	
	dec	(hl)
	call	qnextevent
	ld	a,(hl)
	cp	MOUSE_MOVE
	jr	z,.addmove
	
	ld	hl,numevents
	inc	(hl)
	
.addmove2
	call	qnextevent
	jr	c,.done	; queue is full
.addmove
	; add move event to queue
	ld	(hl),MOUSE_MOVE
	inc	hl
	ld	de,(time)
	ld	(hl),e
	inc	hl
	ld	(hl),d	; time
	inc	hl
	ld	de,(mousey)
	ld	(hl),d	; x
	inc	hl
	ld	(hl),e	; y
	inc	hl
	ld	a,(buttonstate)
	ld	(hl),a	; button state
	
	ld	hl,numevents
	inc	(hl)
	
.done
	ei
	ret

; get the screen address of the background image
; clip it so it stays within the screen boundaries
; this is for saving/restoring a 16x8 px image, suitable for 8x8 px unaligned
; sprites. There are no special cases for when the sprite is off the edge; this
; always puts the whole 16x8 px image on-screen. It's smaller and probably
; faster this way despite having to read/write all 8 rows and 2 bytes per row in
; all cases.
; output:
; 	hl = screen address of background, aligned and clipped
; 	de = 15, for going to the next screen row
; 	b = 8, for the row counter
getbg:
	ld	hl,(cursor)
	ld	a,(mousex)
	sub	(hl)
	inc	hl
	
	cp	-7
	jr	c,.noclipleft
	xor	a
.noclipleft
	cp	129-16
	jr	c,.noclipright
	ld	a,128-16
.noclipright
	rrca
	rrca
	rrca
	and	15
	ld	e,a
	
	ld	a,(mousey)
	sub	(hl)
	cp	-7
	jr	c,.nocliptop
	xor	a
.nocliptop
	cp	65-8
	jr	c,.noclipbottom
	ld	a,64-8
.noclipbottom
	ld	l,a
	ld	h,0
	ld	d,h
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,de
	ld	de,0xfc00
	add	hl,de
	ld	ix,under
	ld	de,16-1
	ld	b,8
	ret

hidecursor:
	ld	hl,cursorvisible
	di
	ld	a,(hl)
	inc	(hl)
	ei
	or	a
	ret	nz
	
	; restore the background
	call	getbg
.row
	ld	a,(ix)
	inc	ix
	ld	(hl),a
	inc	hl
	ld	a,(ix)
	inc	ix
	ld	(hl),a
	
	add	hl,de
	
	djnz	.row
	ret

showcursor:
	ld	hl,cursorvisible
	dec	(hl)
	jr	z,.nowvisible
	ret	po	; return if no overflow
	inc	(hl)
	ret
	
.nowvisible
	; save background under cursor
	call	getbg
.row
	ld	a,(hl)
	inc	hl
	ld	(ix),a
	inc	ix
	ld	a,(hl)
	ld	(ix),a
	inc	ix
	
	add	hl,de
	
	djnz	.row
	;fall through
	;endif

drawcursor:
	ld	hl,(cursor)
	ld	d,(hl)	; hotspot x
	inc	hl
	ld	e,(hl)	; hotspot y
	inc	hl
	
	; skip and mask
	;ld	bc,8
	;add	hl,bc
	
	push	hl
	pop	ix
	
	ld	a,(mousex)
	sub	d
	ld	b,a
	ld	a,(mousey)
	sub	e
	ld	c,a
	
	call	cmsprite
	ret

; input:
; 	hl = timer interval
; 	de = timer value
setitimer:
	di
	ld	(timerinterval),hl
	ei
	ld	(timervalue),de
	ret

; output:
; 	hl = timer interval
; 	de = timer value
getitimer:
	ld	hl,(timerinterval)
	ld	de,(timervalue)
	ret

; input:
; 	hl = address of call-back routine
startmouse:
	ld	(mousecallback),hl
	ld	hl,0
	add	hl,sp
	ld	(mousesp),hl
.wait
	halt
	ld	a,(numevents)
	or	a
	jr	z,.wait
.event
	ld	a,(eventqueue)
	ld	hl,eventmask
	and	(hl)
	
	di
	jr	z,.rmevent
	
	; copy event to buffer for callback
	ld	hl,eventqueue
	ld	de,event
	ld	bc,EVENTSIZE
	ldir
.rmevent
	; remove the event from the queue
	ld	hl,eventqueue+EVENTSIZE
	ld	de,eventqueue
	ld	bc,EVENTSIZE*(QSIZE-1)
	ldir
	ld	hl,numevents
	dec	(hl)
	ei
	
	or	a
	jr	z,.nocallback
	ld	ix,(mousecallback)
	ld	hl,event
	call	jp_mix
.nocallback
	
	ld	a,(numevents)
	or	a
	jr	nz,.event
	jr	.wait
	
	ret

jp_mix:
	jp	(ix)

; return to the instruction after call to startmouse
stopmouse:
	ld	sp,(mousesp)
	ret

; input:
; 	a = mask of events to watch
mousewatch:
	ld	(eventmask),a
	ret

; input:
; 	hl = address of cursor
setcursor:
	push	hl
	call	hidecursor
	pop	hl
.change
	ld	(cursor),hl
	jp	showcursor

	include "cmsprite.asm"

	segu	"data"

; keypad state
keypad ds 7
oldkeypad ds 7

mousey ds 1
mousex ds 1
buttonstate ds 1

mousesp ds 2
eventmask ds 1
mousecallback ds 2

; address of current cursor
cursor ds 2

; cursor is visible if cursorvisible == 0
cursorvisible ds 1

; time since mouse was initialized, in ticks
time ds 2

timerinterval ds 2
timervalue ds 2

numevents ds 1
eventqueue ds QSIZE*EVENTSIZE

; buffer for application
event ds EVENTSIZE

; background image under cursor (16x8 px)
under ds 2*8

mousedelay ds 1

MAXDELAY equ 32
MINDELAY equ 2
DELAYMULT equ 160
mousedelaydelay ds 1

	seg	"code"
