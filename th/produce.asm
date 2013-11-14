; produce, example program for th
; $Id: produce.asm,v 1.5 2007/05/02 22:26:27 christop Exp $
; This program prints and produces the letters A to Z in one thread and consumes
; and prints the letters in another thread.
; This is a very trivial use for threads, but it demonstrates their use. It also
; shows how to make a simple (one-byte) pipe for sending data to another thread.

 segu "data"
 org code_end
 seg "code"

 nolist
 include "asm86.h"
 include "ti86asm.inc"
 list

STACK_SIZE equ 100

 org _asm_exec_ram
 include "th.asm"

THREAD_MAX equ 4

 segu "data"
consumer_thread ds 2
consumer_stack  ds STACK_SIZE
byte     ds 1

pipe     ds 2
 seg "code"

; main thread
; if EXIT is pressed, kills main thread and consumerthread
main:
	call	_runindicoff
	call	_clrScrn
	
	;call	th_init
	
	; create a thread to run "consumer_code" on stack "consumer_stack"
	ld	hl,consumer_code	; code
	ld	de,consumer_stack+STACK_SIZE	; stack
	call	th_create
	ld	(consumer_thread),hl		; save the pointer
	
	ld	hl,pipe
	ld	(hl),0
	
	ld	a,'A'
	ld	(byte),a
	
	ld	hl,1*256+1
	ld	(_curRow),hl
	ld	hl,.pcstr
	call	_puts
	
	ld	hl,10*256+0
	ld	(_curRow),hl
	ld	a,0x1c	; right arrow "->"
	call	_putc
	
	ld	hl,2*256+3
	ld	(_curRow),hl
	ld	hl,.holdESCstr
	call	_puts
	
;***********************************************************
; producer thread
;***********************************************************
.loop
	call	GET_KEY
	cp	K_EXIT
	jp	z,exit	; exit program (this also kills mythread)
	
	ld	a,(byte)
	ld	b,a
	call	send
	
	ld	a,(byte)
	ld	hl,8*256+0
	ld	(_curRow),hl
	call	_putc
	
	inc	a
	cp	'Z'+1
	jr	nz,$+4
	ld	a,'A'
	ld	(byte),a
	
	call	th_yield	; yield before we pause
	
	ld	b,183/3
.haltloop
	halt
	djnz	.haltloop
	
	jr	.loop
.pcstr	db "producer \x1c consumer\0"
.holdESCstr
	db "Hold 'ESC' to exit\0"

;***********************************************************
; send a byte of data
;***********************************************************
; input:
; 	a = byte to send
send:
	ld	hl,pipe
	push	af
	jr	.test
.loop	push	hl
	call	th_sleep	; sleep on this pipe
	pop	hl
.test	ld	a,(hl)
	or	a
	jr	nz,.loop
	pop	af
	
	inc	(hl)		; make pipe full
	inc	hl
	ld	(hl),a		; put data into pipe
	dec	hl
	jp	th_wake		; wake every thread sleeping on this pipe

;***********************************************************
; consumer thread
;***********************************************************
consumer_code:
.loop	call	receive
	ld	hl,12*256+0
	ld	(_curRow),hl
	call	_putc
	jr	.loop

;***********************************************************
; receive a byte of data
;***********************************************************
; input:
; 	none
; output:
; 	a = byte received
receive:
	ld	hl,pipe
	jr	.test
.loop	push	hl
	call	th_sleep
	pop	hl
.test	ld	a,(hl)
	or	a
	jr	z,.loop		; pipe is empty
	
	ld	(hl),0		; make pipe empty
	inc	hl
	ld	a,(hl)		; get data from pipe
	dec	hl
	push	af
	call	th_wake		; wake every thread sleeping on this pipe
	pop	af
	ret

code_end:
