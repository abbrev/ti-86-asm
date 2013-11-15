; I lost the original source to fly3d long ago. :(
; 
; This is a disassembly (with comments and renamed labels) of the original
; fly3d.86p binary.
; 
; If I recall correctly, this program is very similar to rotate.asm, so it
; shouldn't be too difficult to reconstruct this program.

_puts         equ 0x4a37
_clrLCD       equ 0x4a7e
_clrScrn      equ 0x4a82
_homeUp       equ 0x4a95
_runIndicOff  equ 0x4ab1
_getkey       equ 0x55aa ;A = key value
_curRow       equ 0xc00f ;cursor row
_asm_exec_ram equ 0xd748
lcdmem        equ 0xfc00
lcdsize       equ 1024 ; bytes
lcdwidth      equ 128
lcdheight     equ 64

kRight        equ 0x01
kLeft         equ 0x02
kUp           equ 0x03
kDown         equ 0x04
kExit         equ 0x07


	org _asm_exec_ram

	CALL	_runIndicOff
	CALL	_clrLCD
	XOR	A
	LD	(pitch),A
	LD	(roll),A
	LD	HL,0x0701 ; row 1 col 7
	LD	(_curRow),HL
	LD	HL,name
	CALL	_puts
	LD	HL,0x0203 ; row 3 col 2
	LD	(_curRow),HL
	LD	HL,description
	CALL	_puts
	LD	HL,0x0204 ; row 4 col 2
	LD	(_curRow),HL
	LD	HL,my_name
	CALL	_puts
	LD	HL,0x0206 ; row 6 col 2
	LD	(_curRow),HL
	LD	HL,email
	CALL	_puts
	CALL	_getkey
	LD	HL,back_buffer
	CALL	clrbuf

; loop
main_loop
	CALL	draw_screen

; loop
waitkey	CALL	_getkey
	CP	kLeft
	JR	Z,left
	CP	kRight
	JR	Z,right
	CP	kUp
	JR	Z,up
	CP	kDown
	JR	Z,down
	CP	kExit
	JR	NZ,waitkey

	CALL	_homeUp
	JP	_clrScrn


; left key pressed
; subtract 4 from roll angle
left	LD	HL,roll
	LD	A,(HL)
	SUB	4
	LD	(HL),A
	JR	main_loop

; right key pressed
; add 4 to roll angle
right	LD	HL,roll
	LD	A,(HL)
	ADD	A,4
	LD	(HL),A
	JR	main_loop

; up key pressed
; subtract from pitch proportional to current roll angle
up	LD	A,(roll)
	CALL	cos
	LD	L,A
	LD	A,-4
	CALL	muls
	ADD	HL,HL
	LD	A,L
	RLA
	LD	A,H
	LD	HL,pitch
	ADC	A,(HL)
	LD	(HL),A
	CALL	_d7f4
	JR	main_loop

; down key pressed
; add to pitch proportional to current roll angle
down	LD	A,(roll)
	CALL	cos
	LD	L,A
	LD	A,4
	CALL	muls
	ADD	HL,HL
	LD	A,L
	RLA
	LD	A,H
	LD	HL,pitch
	ADC	A,(HL)
	LD	(HL),A
	CALL	_d7f4
	JR	main_loop

; this routine appears to invert roll and pitch when pitch goes more than 90
; degrees above or below horizontal
_d7f4	LD	HL,pitch
	LD	A,(HL)
	LD	B,64+1
	CP	B
	RET	C
	LD	B,-64
	CP	B
	RET	NC
	LD	A,(HL)
	NEG
	ADD	A,128
	LD	(HL),A
	LD	HL,roll
	LD	A,(HL)
	ADD	A,128
	LD	(HL),A
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

viewport_width equ 32
viewport_height equ 24

; advance this many bytes to start on the next line
viewport_next_row equ (lcdwidth-viewport_width)/8

; routine
; draw screen
draw_screen
	LD	A,(roll)
	CALL	sin
	LD	(s_roll),A
	LD	A,(roll)
	CALL	cos
	LD	(c_roll),A
	LD	HL,viewport
	XOR	A
	LD	(px_y),A
; loop
.next_row
	LD	A,0x80
	LD	(pxmask),A
	XOR	A
	LD	(px_x),A
; loop
.next_col
	PUSH	HL
	LD	A,(px_x)
	SUB	viewport_width/2
	LD	L,A
	LD	A,(s_roll)
	CALL	muls
	ADD	HL,HL
	LD	A,H
	PUSH	AF
	LD	A,(px_y)
	SUB	viewport_height/2
	LD	L,A
	LD	A,(c_roll)
	CALL	muls
	ADD	HL,HL
	POP	AF
	ADD	A,H
	LD	HL,pitch
	LD	B,(HL)
	SUB	B
	LD	A,(px_x)
	LD	D,A
	LD	A,(px_y)
	LD	E,A
	LD	A,(pxmask)
	POP	HL
	JP	M,.d866
	OR	(HL)
	JR	.d868
.d866	CPL
	AND	(HL)
.d868	LD	(HL),A
	LD	A,(pxmask)
	RRCA
	JR	NC,.d870
	INC	HL
.d870	LD	(pxmask),A
	LD	A,(px_x)
	INC	A
	LD	(px_x),A
	CP	viewport_width
	JR	NZ,.next_col
	LD	DE,viewport_next_row
	ADD	HL,DE
	LD	A,(px_y)
	INC	A
	LD	(px_y),A
	CP	viewport_height
	JR	NZ,.next_row

	; draw overlay
	LD	HL,viewport
	LD	DE,overlay_and
	LD	C,viewport_height
; loop
.d895	LD	B,viewport_width/8
; loop
.d897	LD	A,(DE)
	AND	(HL)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	.d897
	PUSH	BC
	LD	BC,viewport_next_row
	ADD	HL,BC
	POP	BC
	DEC	C
	JR	NZ,.d895

	LD	HL,viewport
	LD	DE,overlay_xor
	LD	C,viewport_height
; loop
.d8af	LD	B,viewport_width/8
; loop
.d8b1	LD	A,(DE)
	XOR	(HL)
	LD	(HL),A
	INC	HL
	INC	DE
	DJNZ	.d8b1
	PUSH	BC
	LD	BC,16-viewport_width/8
	ADD	HL,BC
	POP	BC
	DEC	C
	JR	NZ,.d8af

	; copy back buffer to LCD
	LD	HL,back_buffer
	LD	DE,lcdmem
	LD	BC,lcdsize
	LDIR
	RET

; clear screen buffer
clrbuf	XOR	A
	LD	(HL),A
	LD	D,H
	LD	E,L
	INC	DE
	LD	BC,lcdsize-1
	LDIR
	RET

; sine
sin	CPL
	ADD	A,64+1 ; add 90 degrees, plus one to turn CPL into NEG
; XXX in hindsight, a single ADD A,192 would have worked: sin(x) = cos(x+270)
; fall through
; cosine
cos	SRL	A
	LD	L,A
	LD	H,0x00
	ADC	A,H
	LD	DE,cosines
	ADD	HL,DE
	LD	B,(HL)
	LD	H,0x00
	LD	L,A
	ADD	HL,DE
	LD	A,(HL)
	SUB	B
	SRA	A
	ADC	A,B
	RET
; This cosine routine uses a 128-entry table and linearly interpolates between
; adjacent entries if the angle (0..255) is between two values. This is
; probably a bad time/space tradeoff (half the table could have been generated
; from one half of a cosine wave table)


; cosine table
cosines	db  127,  127,  126,  126,  125,  123,  122,  120
	db  117,  115,  112,  109,  106,  102,   98,   94
	db   90,   85,   80,   75,   70,   65,   60,   54
	db   48,   42,   37,   30,   24,   18,   12,    6
	db    0,   -7,  -13,  -19,  -25,  -31,  -38,  -43
	db  -49,  -55,  -61,  -66,  -71,  -76,  -81,  -86
	db  -91,  -95,  -99, -103, -107, -110, -113, -116
	db -118, -121, -123, -124, -126, -127, -127, -128
	db -128, -128, -127, -127, -126, -124, -123, -121
	db -118, -116, -113, -110, -107, -103,  -99,  -95
	db  -91,  -86,  -81,  -76,  -71,  -66,  -61,  -55
	db  -49,  -43,  -38,  -31,  -25,  -19,  -13,   -7
	db    0,    6,   12,   18,   24,   30,   37,   42
	db   48,   54,   60,   65,   70,   75,   80,   85
	db   90,   94,   98,  102,  106,  109,  112,  115
	db  117,  120,  122,  123,  125,  126,  126,  127
	db  127
; end of cosine table (129 bytes)


	include "mul.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; data
name:
	db "FLY 3D!",0
description:
	db "A flight sim demo",0
my_name:
	db "by Chris Williams",0
email:
	db "cow3.14@juno.com",0

; x and y pixel counters
px_x	ds 1
px_y	ds 1

; pixel mask
pxmask	ds 1

pitch	ds 1

roll	ds 1

; sin(roll)
s_roll	ds 1

; cos(roll)
c_roll	ds 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; image data
; 192 bytes (96 bytes for AND mask, 96 bytes for XOR mask)
overlay_and:
	db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x80, 0x00, 0xFF
	db 0xFE, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F
	db 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0xFE, 0x7F
	db 0xFF, 0x7F, 0xFE, 0x7F, 0xFF, 0x3F, 0xFE, 0xFF
	db 0xFF, 0xBF, 0xFE, 0xFF, 0xFF, 0xBF, 0xFE, 0xFF
	db 0xFF, 0xBF, 0xFE, 0xFF, 0xFF, 0xBF, 0xFE, 0xFF
	db 0xFF, 0xBF, 0xFC, 0xFF, 0xFF, 0x9F, 0xFC, 0xFF
	db 0xFF, 0x9F, 0xFC, 0xFF, 0xFF, 0x9F, 0xFC, 0xFF
	db 0xF8, 0x00, 0x00, 0x0F, 0xE0, 0x00, 0x00, 0x03
	db 0xC0, 0x00, 0x00, 0x01, 0x80, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
overlay_xor:
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x00
	db 0x00, 0x80, 0x00, 0x80, 0x00, 0x04, 0x90, 0x00
	db 0x00, 0x82, 0xA0, 0x80, 0x00, 0x00, 0x05, 0x00
	db 0x00, 0x80, 0x08, 0x80, 0x00, 0x40, 0x05, 0x00
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 0x05, 0x00
	db 0x00, 0x00, 0x80, 0x00, 0x00, 0x40, 0x01, 0x00
	db 0x00, 0x06, 0xB2, 0x00, 0x00, 0x40, 0x01, 0x00
	db 0x00, 0x20, 0x82, 0x00, 0x00, 0x40, 0x01, 0x00
	db 0x00, 0x20, 0x02, 0x00, 0x07, 0xF8, 0x1F, 0xF0
	db 0x1F, 0xF8, 0x1F, 0xFC, 0x3F, 0x7F, 0xFC, 0x7E
	db 0x7F, 0xFF, 0xFC, 0x7F, 0xFF, 0xF8, 0xCF, 0xFF
	db 0xFD, 0xFB, 0xFF, 0xFF, 0xFF, 0xFF, 0xCF, 0xFF

;_dad9
back_buffer

;_dc1f equ 0xdc1f
viewport equ back_buffer+16*20+6 ; 20 pixels down, 48 (8*6) pixels right

