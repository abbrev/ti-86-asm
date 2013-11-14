; testth, test program for th
; $Id: testth.asm,v 1.9 2007/05/02 22:26:27 christop Exp $
; This program counts up A to Z with one thread and 0 to 9 with another thread.
; This is a very trivial use for threads, but it demonstrates their use.

 segu "data"
 org code_end
 seg "code"

 nolist
 include "asm86.h"
 include "ti86asm.inc"
 list

THREAD_MAX equ 2

STACK_SIZE equ 100

 org _asm_exec_ram
 include "th.asm"

 segu "data"
mythread ds 2
mystack  ds STACK_SIZE
bytea    ds 1

byteb    ds 1
countb   ds 1
 seg "code"

; main thread
; if 1 is pressed, kills thread1 and thread2
; if 2 is pressed, kills thread2
main:
	ld	hl,mythread_code	; code
	ld	de,mystack+STACK_SIZE	; stack
	call	th_create
	ld	(mythread),hl
	
	ld	a,'A'
	ld	(bytea),a
.a
	ld	a,(bytea)
	ld	hl,0
	ld	(_curRow),hl
	call	_putc
	inc	a
	cp	'Z'+1
	jr	nz,$+4
	ld	a,'A'
	ld	(bytea),a
	ld	b,10*2
.a1
		push	bc
	call	GET_KEY
		pop	bc
	cp	K_1
	ret	z		; return from program (this also kills mythread)
	cp	K_2
	jr	nz,.anot_2
	ld	hl,(mythread)
	call	th_cancel	; cancel "mythread"
.anot_2
	call	th_yield	; we need to cooperate
	djnz	.a1
	jr	.a
	ret

mythread_code:
	ld	a,'0'		; meat of thread
	ld	(byteb),a	;
.b
	ld	a,26*2
	ld	(countb),a
	ld	a,(byteb)
	ld	hl,1*256+0
	ld	(_curRow),hl
	call	_putc
	inc	a
	cp	'9'+1
	jr	nz,$+4
	ld	a,'0'
	ld	(byteb),a
.b1
	call	th_yield
	ld	hl,countb
	dec	(hl)
	jr	z,.b
	jr	.b1
	ret

code_end:
.end
