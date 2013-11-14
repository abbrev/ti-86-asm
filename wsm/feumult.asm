; Fast enough unsigned 8-bit multiply routine
; by Chris Williams <cow3.14@juno.com>
; 2004 May 09
; Redistribution: use this routine as you wish.

; input:
; 	E and H = operands
; output:
; 	HL = E*H (unsigned)
; 35 bytes
; 204-251 cycles (more with more 1 bits in H), average = 227.5 cycles
; for comparison, Dan Eble's routine averages 272 cycles,
; but Kirk Meyer's Very Fast routine is only 207 cycles.
; Use this one where size is important but speed is not (plus this routine's
; license is unrestrictive, so you can GPL it for example).
muluAxH:
	ld	e,a
muluExH:
	ld	l,0	; 7
	ld	d,l	; 4
	add	hl,hl	; 11
	jr	nc,$+3	; 12/7
	add	hl,de	; 11
	add	hl,hl
	jr	nc,$+3
	add	hl,de
	add	hl,hl
	jr	nc,$+3
	add	hl,de
	add	hl,hl
	jr	nc,$+3
	add	hl,de
	add	hl,hl
	jr	nc,$+3
	add	hl,de
	add	hl,hl
	jr	nc,$+3
	add	hl,de
	add	hl,hl
	jr	nc,$+3
	add	hl,de
	add	hl,hl
	ret	nc	; 11/5
	add	hl,de
	ret		; 10
