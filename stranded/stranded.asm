	include "asm86.h"
	include "ti86asm.inc"

	;include "ti86math.inc"
	;include "ti86ops.inc"
	;include "ti86abs.inc"

MOVE	equ	0
BLOCK	equ	1

	segu	"data"
	org	code_end
	seg	"code"
	org	_asm_exec_ram

main:
	call	_clrLCD
	call	_runindicoff
	
	ld	hl,titleStr
	
	ld	bc,0+4*256	; row 0, col 4
	ld	(_curRow),bc
	call	_puts
	ld	bc,2+3*256	; row 2, col 3
	ld	(_curRow),bc
	call	_puts
	ld	bc,3+0*256	; row 3, col 0
	ld	(_curRow),bc
	call	_puts
	ld	bc,4+1*256	; row 4, col 1
	ld	(_curRow),bc
	call	_puts
	ld	bc,7+2*256	; row 7, col 2
	ld	(_curRow),bc
	call	_puts
	
	call	wait2nd
	jr	c,.endgame
.again
	call	setup
	
	call	play
	or	a
	jr	nz,.again
.endgame
	res	4,(iy+9)	; reset ON flag
	call	_clrScrn
	ld	bc,0
	ld	(_curRow),bc
	jp	_runindicon

; output:
; 	carry is set if EXIT is pressed
wait2nd:
.wait
	call	getKey
	cp	K_SECOND
	jr	z,.second
	cp	K_EXIT
	jr	nz,.wait
	scf
	ret
.second
	or	a
	ret

; output:
; 	a = GET_KEY key code
; handles +/- to change contrast
getKey:
	halt
	call	GET_KEY
	cp	K_PLUS
	jr	nz,.notPlus
	call	contrastUp
	jr	getKey
.notPlus
	cp	K_MINUS
	ret	nz
	call	contrastDown
	jr	getKey

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup:
	call	_clrLCD
	
	call	resetGame
	
	call	drawBoard
	
	ld	bc,3+12*256	; row 3, col 12
	ld	(_curRow),bc
	ld	hl,playerStr
	call	_puts
	
	xor	a
	call	getPlayerCoords	; get the player's coordinates--returns hl
	ld	ix,whitePieceBM
	
	push	hl
	call	xorPiece
	pop	hl
	
	inc	hl
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	ld	ix,blackPieceBM
	call	xorPiece
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Play routine
; input:
; 	none
; output:
; 	a = 1 to play again, 0 to exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
play:
.loop
	call	writePlayer
	ld	hl,moveStr
	call	writeCommand
	
.move	; move
	ld	a,(playerTurn)
	call	getPlayerCoords
	
	push	bc		; old coords
	call	inputNewCoords	; Get new coords
	pop	de
	
	ret	c
	
	ld	a,b
	inc	a
	sub	d
	jr	c,.move		; bad move
	cp	3
	jr	nc,.move	; bad move
	
	ld	a,c
	inc	a
	sub	e
	jr	c,.move		; bad move
	cp	3
	jr	nc,.move	; bad move
	
	; ick. this code is kind of unreadable
		push	bc	; save new coords
	ld	b,d		; Erase old piece
	ld	c,e
	ld	a,(playerTurn)	; V
	or	a
	jr	z,.white	; V
	ld	ix,blackPieceBM	; V
	jr	.there		; V
.white				; V
	ld	ix,whitePieceBM	; V
.there				; V
		;pop	de
		push	ix		; V
		;push	de		; V
	call	xorPiece	; -
		pop	ix
	ld	a,(playerTurn)
	call	getPlayerCoords
	call	getSquare
	ld	(hl),0		; vacate old square
		pop	bc
	; ick ends here
	
		push	bc	; new coords
	call	getSquare
	ld	(hl),1		; occupy new square
	ld	a,(playerTurn)
	call	getPlayerCoords
		pop	bc	; restore new coords
	ld	(hl),b
	inc	hl
	ld	(hl),c
	
		push	bc
	call	xorPiece
	
	; block
	ld	hl,blockStr
	call	writeCommand
	
		pop	bc
	
	call	inputNewCoords
	ret	c
	
	ld	ix,blockBM
	push	bc
	call	xorPiece
	pop	bc
	
	call	getSquare
	ld	(hl),1
	
	ld	a,(playerTurn)
	xor	1
	ld	(playerTurn),a		; next player
	
	; check if this player can still move
	call	getPlayerCoords
	ld	h,b
	ld	l,c
	
	ld	e,-1	; y counter
.forY
	ld	d,-1	; x counter
.forX
	ld	a,l
	add	a,e
	cp	8
	jr	z,.trapped	; bottom of the board
	cp	-1
	jr	z,.nextY	; top of the board
	ld	c,a
	
	ld	a,h
	add	a,d
	cp	8
	jr	z,.nextY	; right of the board
	cp	-1
	jr	z,.nextX	; left of the board
	ld	b,a
	
	push	de
	push	hl
	call	getSquare
	pop	hl
	pop	de
	
	or	a
	jp	z,.loop		; player can move to an empty space
.nextX
	inc	d
	ld	a,d
	cp	2
	jr	nz,.forX
.nextY
	inc	e
	ld	a,e
	cp	2
	jr	nz,.forY
.trapped
	; player is trapped, therefore loses
	ld	hl,winsStr
	call	writeCommand
	call	wait2nd
	
	sbc	a,a	; if user pressed EXIT, don't play again
	inc	a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; getPlayerCoords
; input:
; 	a = player -- 0 or 1
; output:
; 	hl = pointer to player coords
; 	bc = player coords (xy)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getPlayerCoords:
	add	a,a
	ld	hl,coords+1
	add	a,l
	ld	l,a
	adc	a,h
	sub	l
	ld	h,a
	ld	c,(hl)
	dec	hl
	ld	b,(hl)
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; getSquare
; input:
; 	bc = xy
; output:
; 	hl = pointer to board square at (x, y)
; 	a = contents of square
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getSquare:
	ld	a,c
	add	a,a
	add	a,a
	add	a,a
	add	a,b
	
	ld	h,0
	ld	l,a
	ld	bc,board
	add	hl,bc
	
	ld	a,(hl)
	ret

; xorPiece
; draw a sprite at a tile coordinate (8x8 px)
; input:
; 	ix = sprite
; 	bc = x,y
xorPiece:
	ld	d,c
	ld	e,b
	sla	e
	srl	d
	rr	e
	ld	hl,VIDEO_MEM
	add	hl,de
	ld	de,16
	ld	b,8
.row
	ld	a,(ix)
	xor	(hl)
	ld	(hl),a
	add	hl,de
	inc	ix
	djnz	.row
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; resetGame
; input:
; 	none
; output:
; 	none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
resetGame:
	; clear the board
	ld	hl,board
	ld	de,board+1
	ld	bc,63
	ld	(hl),0
	ldir
	
	; put players' pieces on the board
	ld	hl,board+3*8+0	; 3, 0
	ld	(hl),1		; player 0
	ld	hl,board+4*8+7	; 4, 7
	ld	(hl),1		; player 1
	
	; set locations of players' pieces
	ld	bc,0x0300	; 0,3
	ld	(coords+0),bc
	ld	bc,0x0407	; 7,4
	ld	(coords+2),bc
	
	; set to player 0's turn
	xor	a
	ld	(playerTurn),a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; inputNewCoords
; returns coordinates of an empty square selected by the user
; input:
; 	bc = starting coords
; output:
; 	bc = new coords (x, y)
; 	carry is set if user exits the game (EXIT or CLEAR
; 	 is pressed)
; 	a = 1 if new game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
inputNewCoords:
	push	bc
	ld	ix,highlightBM
	call	xorPiece
	pop	bc
.get
	push	bc
	
.getkey
	call	getKey
	or	a
	jr	z,.getkey
	
	pop	bc
	
	ld	d,b	; save old coords to erase the highlight later
	ld	e,c
	
	cp	K_LEFT
	jr	nz,.notLeft
	
	ld	a,b
	or	a
	jr	z,.get		; x == 0
	dec	b
	jr	.moved
.notLeft
	cp	K_RIGHT
	jr	nz,.notRight
	
	ld	a,b
	cp	7
	jr	z,.get		; x == 7
	inc	b
	jr	.moved
.notRight
	cp	K_UP
	jr	nz,.notUp
	
	ld	a,c
	or	a
	jr	z,.get		; y == 0
	dec	c
	jr	.moved
.notUp
	cp	K_DOWN
	jr	nz,.notDown
	
	ld	a,c
	cp	7
	jr	z,.get		; y == 7
	inc	c
	jr	.moved
.notDown
	cp	K_EXIT
	jr	nz,.notExit
	
	xor	a	; don't play again
	scf
	ret
.notExit
	cp	K_SECOND
	jr	nz,.notEnter
	push	bc
	call	getSquare
	pop	bc
	
	or	a
	jr	nz,.get
	
	ld	ix,highlightBM
	push	bc
	call	xorPiece
	pop	bc
	
	or	a	; clear carry
	ret
.notEnter
	cp	K_CLEAR
	jr	nz,.get
	
	ld	a,1	; play again
	scf
	ret
.moved
	push	bc
	ld	b,d
	ld	c,e
	ld	ix,highlightBM
	call	xorPiece
	
	pop	bc
	push	bc
	ld	ix,highlightBM
	call	xorPiece
	pop	bc
	
	jp	.get

writePlayer:
	ld	a,(playerTurn)
	add	a,'1'
	ld	bc,3+19*256	; row 3, col 19
	ld	(_curRow),bc
	jp	_putc

; input:
; 	hl = command to write
writeCommand:
	ld	bc,4+12*256	; row 4, col 13
	ld	(_curRow),bc
	jp	_puts

drawBoard:
	ld	c,0
.fory
	ld	b,0
.forx
	ld	ix,gridBM
	push	bc
	call	xorPiece
	pop	bc
	
	inc	b
	ld	a,b
	cp	8
	jr	nz,.forx
	
	inc	c
	ld	a,c
	cp	8
	jr	nz,.fory
	
	ret

currCont equ 0xc008
contrastUp:
	ld	a,(currCont)
	cp	31
	ret	z
	inc	a
	jr	setContrast

contrastDown:
	ld	a,(currCont)
	or	a
	ret	z
	dec	a
	; fall through

; input:
; 	a = contrast
setContrast:
	ld	(currCont),a
	out	(2),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; bitmap of white piece
whitePieceBM:
	db	%00000000
	db	%00010000
	db	%01110000
	db	%00010000
	db	%00010000
	db	%01111100
	db	%00000000
	db	%00000000

; bitmap of black piece
blackPieceBM:
	db	%00000000
	db	%01111000
	db	%00001100
	db	%00111000
	db	%01100000
	db	%01111100
	db	%00000000
	db	%00000000

; bitmap for game grid
gridBM:
	db	%00000000
	db	%00000000
	db	%00000000
	db	%00000000
	db	%00000000
	db	%00000000
	db	%00000000
	db	%00000001

; bitmap to highlight grid
highlightBM:
	db	%11111110
	db	%11111110
	db	%11111110
	db	%11111110
	db	%11111110
	db	%11111110
	db	%11111110
	db	%00000000

; bitmap to show where a blocked
blockBM:
	db	%00000000
	db	%01010100
	db	%00101000
	db	%01010100
	db	%00101000
	db	%01010100
	db	%00000000
	db	%00000000

titleStr:
	;   012345678901234567890
	db     "STRANDED v1.0",0
	db    "Copyright 2006",0
	db "Christopher Williams",0
	db  "<abbrev@gmail.com>",0
	db   "Press 2nd to play",0

playerStr:
	db "Player",0

moveStr:
	db "move ",0

blockStr:
	db "block",0

winsStr:
	db "WINS!",0

; unitialized data

	segu "data"

playerTurn:
	ds 1

coords	ds 4

; game board
board	ds 64

	seg "code"
code_end
