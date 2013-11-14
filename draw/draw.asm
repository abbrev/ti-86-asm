	segu	"data"
	org	code_end

	seg	"code"
	org	0xd748

_FREESAVEY equ 0xCEAE
_FREESAVEX equ 0xCEAF

_clrLCD equ 0x4a7e
_clrScrn equ 0x4a82
_runindicoff equ 0x4ab1

K_EXIT equ 0x37
K_MORE equ 0x38
K_CLEAR equ 0x0f
K_XVAR equ 0x28

_plotSScreen equ 0xc9fa
VIDEO_MEM equ 0xfc00
_curRow equ 0xc00f

start:
	call	_runindicoff
	
	ld	hl,_plotSScreen
	ld	de,VIDEO_MEM
	ld	bc,1024
	ldir
	
	call	initmouse
	
	ld	de,(_FREESAVEY)
	ld	a,63
	sub	e
	ld	e,a
	;ld	d,64
	;ld	e,32
	call	movemouse
	call	showcursor
	
	xor	a
	ld	(mode),a
	;ld	hl,pencilcursor
	;call	setcursor
	
	ld	a,MOUSE_MOVE|MOUSE_DOWN|KEY_DOWN|KEY_UP|TIMER_EXPIRED
	call	mousewatch
	
	if 0
	; test the timer facility
	ld	a,1
	ld	hl,1;83
	call	settimer
	endif
	
	ld	hl,mycallback
	call	startmouse
	
	call	hidecursor
	
	call	getmouse
	
	ld	a,63
	sub	e
	ld	e,a
	ld	(_FREESAVEY),de
	
	ld	hl,VIDEO_MEM
	ld	de,_plotSScreen
	ld	bc,1024
	ldir
	
	im	1
	ld	hl,0
	ld	(_curRow),hl
	jp	_clrScrn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The mouse callback
; input:
; 	hl = event structure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mycallback:
	; is it a mouse event?
	ld	a,(hl)
	and	MOUSE_MOVE|MOUSE_DOWN
	jp	nz,mouseEvent
	
	; no...
	
	; is it a timer event?
	ld	a,(hl)
	cp	TIMER_EXPIRED
	jp	z,timerExpired
	
	; no...
	
	; it's not a mouse nor a timer event, so it must be a key event
	cp	KEY_DOWN
	jr	nz,.notkeydown
	push	hl
	ld	de,kevent_keycode
	add	hl,de
	ld	a,(hl)
	pop	hl
	
	cp	K_EXIT
	jr	nz,.notexit
	
	jp	stopmouse
.notexit
	cp	K_CLEAR
	jr	nz,.notclear
	
	; if CLEAR is pressed, set a timer to erase
	ld	hl,0
	ld	de,92	; about 1/2 second
	jp	setitimer
.notclear
	cp	K_MORE
	jr	nz,.notmore
	
	ld	hl,mode
	ld	a,(hl)
	inc	a
	and	1
	ld	(hl),a
	jr	z,.pencil
	ld	hl,erasercursor
	jp	setcursor
.pencil
	ld	hl,pencilcursor
	jp	setcursor
.notmore
	ret
.notkeydown
	cp	KEY_UP
	ret	nz
	
	push	hl
	ld	de,kevent_keycode
	add	hl,de
	ld	a,(hl)
	pop	hl
	cp	K_CLEAR
	ret	nz
	
	; cancel a pending timer
	; (hl is not set because the interval is not used when the value is 0)
	ld	de,0
	jp	setitimer

; This is called when the timer expires.
; In this application, the timer is used only when CLEAR is pressed.
; input:
; 	hl = event structure
timerExpired:
	call	hidecursor
	call	_clrLCD
	jp	showcursor

; routine to handle mouse events
; input:
; 	hl = event structure
mouseEvent:
	ld	de,mevent_button
	add	hl,de
	ld	a,(hl)
	or	a
	ret	z
	
	push	hl
	call	hidecursor
	pop	hl
	
	dec	hl
	ld	c,(hl)
	dec	hl
	ld	b,(hl)
	call	FindPixel
	push	af
	ld	a,(mode)
	or	a
	pop	bc
	ld	a,b
	jr	z,.draw
	; erase
	cpl
	and	(hl)
	ld	(hl),a
	jp	showcursor
.draw
	or	(hl)
	ld	(hl),a
	jp	showcursor

;---------------------------------------------------------------------
; The Eble-Yopp-Yopp-Eble-Eble-Eble-Yopp-Eble Faster FindPixel Routine
; 32-39 bytes/109 t-states not counting ret or possible push/pop of BC
;---------------------------------------------------------------------
; Input:  C = y
;         B = x
; Output: HL= address of byte in video memory
;         A = bitmask (bit corresponding to pixel is set)
;         D is modified
;         Flags are modified
;
; +-----------+
; |(0,0)      |  <- Screen layout
; |           |
; |   (127,63)|  Note: make sure coordinates are within bounds
; +-----------+
;
;---------------------------------------------------------------------
FindPixel:
	ld	hl,FP_Bits	; HL -> bitmask table
	ld	a,b	; A = x coordinate
	and	7	; A = bit offset
	or	l	; add bit offset to HL (the addition to L will
	ld	l,a	;  not carry, because the table is aligned)
	ld	d,(hl)	; C = bitmask (saved for later)
;36 t-states up to this point
	ld	h,0x3f	; to understand this, draw a picture
	ld	a,c	; A = y coordinate (top two bits clear)
	add	a,a	; does not carry
	add	a,a	; does not carry
	ld	l,a
	ld	a,b
	rra		; puts 0 into the high bit
	add	hl,hl	; does not carry
	rra		; puts 0 into the high bit
	add	hl,hl	; does not carry
	rra		; puts 0 into the high bit
	or	l
	ld	l,a
	ld	a,d	; A = bitmask (saved from above)
;109 t-states up to this point
	ret

	align	8	; align FP_Bits on the next 8-byte boundary
FP_Bits	db	$80,$40,$20,$10,$08,$04,$02,$01

defaultcursor:
pencilcursor:
	db	0,0
	
	db	0b11111001
	db	0b11110000
	db	0b11100000
	db	0b11000001
	db	0b10000011
	db	0b00000111
	db	0b00001111
	db	0b00011111
	
	db	0b11100110
	db	0b11001001
	db	0b10010101
	db	0b00100010
	db	0b01000100
	db	0b10001000
	db	0b11010000
	db	0b11100000

erasercursor:
	db	0,0
	
	db	0b11110111
	db	0b11100011
	db	0b11000001
	db	0b10000000
	db	0b00000001
	db	0b10000011
	db	0b11000111
	db	0b11101111
	
	db	0b11101000
	db	0b11010100
	db	0b10100010
	db	0b01000111
	db	0b10001110
	db	0b01011100
	db	0b00111000
	db	0b00010000

	include "mouse.asm"

	segu	"data"
mode ds 1
	seg	"code"

code_end
