; th.asm, cooperative multithreading library for Z80
; 
; Copyright 2006, 2007 Christopher Williams
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
; 
; $Id: th.asm,v 1.15 2007/11/21 09:32:50 christop Exp $

 warning "make sure th.asm is included at the start"
 warning "of the program (address 0xD748 on the TI-86)"

; The central thread structure
; struct thread {
; 	enum { TH_RUNNING, TH_FREE, TH_SLEEPING, TH_ZOMBIE, } state;
; 	jmp_buf jmp_buf;
; 	void *arg;
; 	union {
; 		void *waitfor;
; 		int exitstatus;
; 	}
; };

	segu "offsets"
	org 0
thread_state      ds  1
thread_jmp_buf    ds  4
thread_waitfor    ds  2
; We don't need the "waitfor" field when a thread is a zombie, so we'll save
; space by re-using the memory for "exitstatus".
thread_exitstatus equ thread_waitfor
thread_sizeof     equ $
	
	segu "data"
numthreads     ds  1
exitsp         ds  2
current        ds  2
threads        ds  thread_sizeof*THREAD_MAX
threads_sizeof equ $-threads

; the following variables would make accessing a large and sparse "threads"
; array much faster. Only routines that change the state of a thread to or from
; TH_FREE need to maintain these variables. Alternatively, routines to allocate
; and de-allocate threads could maintain them.
;lowestfree  ds  2
;highestused ds  2

	seg "code"

; For efficiency, TH_RUNNING is 0 and TH_FREE is 1.
TH_RUNNING  alias 0
TH_FREE     alias 1
TH_SLEEPING alias 2
TH_ZOMBIE   alias 3
;TH_CANCELED alias 4

	ld	(exitsp),sp
	
	; initialize threading system
	ld	hl,threads
	ld	de,thread_sizeof
	ld	(hl),TH_RUNNING
	ld	(current),hl
	add	hl,de
	ld	a,TH_FREE
	ld	b,THREAD_MAX-1
.thloop	ld	(hl),a
	add	hl,de
	djnz	.thloop
	ld	a,1
	ld	(numthreads),a
	
	call	main
	; fall through

exit:
	ld	sp,(exitsp)
	ret

;cp_hl_de compares HL and DE
;status flags set to result of HL - DE
; The version in TI-OS (TI-86 ROM version 1.2) uses 6 bytes, takes 50 cycles,
; and uses the stack.
; 
; This one uses 6 bytes, takes 19/31 cycles (when H!=D and H=D, respectively),
; and does not use the stack. It modifies A, though.
cp_hl_de:
	ld	a,h	;4
	cp	d	;4
	ret	nz	;11/5
	ld	a,l	;4
	cp	e	;4
	ret		;10

; th_create, create a thread at a starting point using a stack
; input:
; 	hl = void *(*code)(void *) -- a pointer to a function that takes a
; 	                              pointer and returns a pointer
; 	de = char *stack
; 	bc = void *arg
; output:
; 	hl = thread *
; 	hl = NULL if no free slots
th_create:
	push	bc		; arg
	push	hl		; pc
	push	de		; sp
	
	ld	ix,threads
	ld	de,thread_sizeof
	ld	b,THREAD_MAX
.thloop	ld	a,(ix+0)
	dec	a	;cp	TH_FREE
	jr	z,.found
	
	add	ix,de
	djnz	.thloop
	
	; we couldn't find a free slot for a new thread
	pop	de
	pop	hl
	pop	bc
	scf
	ld	hl,0	; return NULL
	ret
	
.found
	ld	(ix+thread_state),a	; TH_RUNNING (a=0 at this point)
	
	ld	a,(numthreads)
	inc	a
	ld	(numthreads),a
	
	pop	hl	; sp
	pop	de	; pc
	pop	bc	; arg
	
	; Push the argument onto the thread's stack.
	dec	hl
	ld	(hl),c	; arg
	dec	hl
	ld	(hl),b
	
	; "Push" a return address onto the thread's stack.
	; This will cause the thread to return to the th_exit routine, causing
	; the thread to exit properly.
	dec	hl
	ld	(hl),th_exit/256
	dec	hl
	ld	(hl),th_exit%256
	
	; setup the jmp_buf
	ld	(ix+thread_jmp_buf+0),l	; sp
	ld	(ix+thread_jmp_buf+1),h
	ld	(ix+thread_jmp_buf+2),e	; pc
	ld	(ix+thread_jmp_buf+3),d
	
	push	ix
	pop	hl	; hl = thread *
	or	a	; clear carry
	ret

; decrement numthreads and exit program if it's 0
; internal routine
; registers destroyed:
; 	a, de
decnumthreads:
	ld	a,(numthreads)
	dec	a
	jr	nz,.nz
	ld	hl,0
	jp	exit
.nz	ld	(numthreads),a
	ret

; th_cancel, cancel a running thread
; input:
; 	hl = struct thread *tp
; output:
; 	none
th_cancel:
	ld	a,(hl)
	cp	TH_ZOMBIE
	jr	z,.z
	dec	a	;cp	TH_FREE
	
	call	nz,decnumthreads
	
.z	ld	(hl),TH_FREE
	call	th_wake	; wake up every thread that is sleeping on this thread
	jp	th_yield

; th_exit, exit the current thread
; input:
; 	hl = int status
; output:
; 	none (does not return)
th_exit:
	call	decnumthreads
	
	ex	de,hl	; de = status
	
	ld	hl,(current)
	push	hl	; hl = current
	
	ld	(hl),TH_ZOMBIE
	ld	bc,thread_exitstatus
	add	hl,bc
	ld	(hl),e
	inc	hl
	ld	(hl),d
	
	pop	hl
	call	th_wake	; wake up every thread that is sleeping on me
	jp	th_yield

; th_join, wait for a thread to finish running and return its exit status
; input:
; 	hl = struct thread *tp
; output:
; 	hl = int
; 	carry is set if thread was cancelled or is not running
th_join:	; FIXME: test this
	ld	de,(current)
	call	cp_hl_de
	scf
	ret	z	; tp == current
.nz	
	jr	.test
.loop	push	hl
	call	th_sleep
	pop	hl
.test	ld	a,(hl)
	cp	TH_FREE
	jr	z,.free
	cp	TH_ZOMBIE
	jr	nz,.loop
	
	ld	(hl),TH_FREE
	ld	de,thread_exitstatus
	add	hl,de
	jp	LD_HL_MHL
	
.free	scf
	ret

; th_sleep, sleep on an event
; input:
; 	hl = void *event
; output:
; 	none
th_sleep:
	ex	de,hl
	ld	hl,(current)
	ld	(hl),TH_SLEEPING	; current->state = TH_SLEEPING
	ld	bc,thread_waitfor
	add	hl,bc
	ld	(hl),e		; current->waitfor = event
	inc	hl
	ld	(hl),d
	jp	th_yield

; th_wake, wake every thread that is sleeping on a specific event
; input:
; 	hl = void *event
; output:
; 	none
th_wake:
	ld	ix,threads
	ld	de,thread_sizeof
	;ld	a,TH_SLEEPING
	ld	b,THREAD_MAX
.thloop	ld	a,(ix)
	cp	TH_SLEEPING	; is thread sleeping?
	jr	nz,.nz
	
	ld	a,(ix+thread_waitfor+0)
	cp	l
	jr	nz,.nz
	ld	a,(ix+thread_waitfor+1)
	cp	h
	jr	nz,.nz
	
	ld	(ix),TH_RUNNING	; tp->state = TH_RUNNING
.nz	add	ix,de
	djnz	.thloop
	ret

; th_yield, let another thread run
; input:
; 	none
; output:
; 	none
; registers destroyed:
; 	none
th_yield:
	push	ix
	push	hl
	push	de
	push	bc
	push	af
	
	ld	hl,(current)
	inc	hl	;ld	de,thread_jmp_buf
			;add	hl,de
	call	setjmp
	jr	nc,.notback	; we got here via a longjmp
	
	; we're back in a thread that is ready to run
	pop	af
	pop	bc
	pop	de
	pop	hl
	pop	ix
	ret
	
.notback
	ld	hl,(current)
	ld	bc,thread_sizeof
.next
	add	hl,bc	; next thread
	ld	de,threads+threads_sizeof
	call	cp_hl_de
	jr	nz,.nz	; are we past the end of the threads array?
	ld	hl,threads
.nz	ld	a,(hl)
	or	a	;cp	TH_RUNNING
	jr	z,.running
	
	; this thread is not running
	
	; if this thread is current thread, halt
	ld	de,(current)
	call	cp_hl_de
	jr	nz,.next
	
	; At this point, no threads are runnable, so we just halt and hope that
	; the interrupt handler wakes up a thread, exits the application, or
	; something to that effect. It's up to the application writer to ensure
	; this. Otherwise, we'll be in this loop forever. :(
	halt
	jr	.next
	
.running
	ld	(current),hl
	inc	hl	; HL = &current->jmp_buf
	; fall through to longjmp

; The following setjmp and longjmp are similar to C's equivalent routines, but
; this version of longjmp does not take the value argument. Also, instead of
; returning a value, setjmp set the carry flag when it returns via a longjmp.

; typedef struct {
; 	uint16_t sp;
; 	uint16_t pc;
; } jmp_buf[1];

; input:
; 	hl = env
; output:
; 	none (never returns)
; void longjmp(jmp_buf env, int val);
longjmp:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)	; de = env->sp
	inc	hl
	
	ex	de,hl
	ld	sp,hl
	ex	de,hl
	
	ld	e,(hl)
	inc	hl
	ld	d,(hl)	; de = env->pc
	
	scf		; set carry to indicate it's a longjmp
	
	ex	de,hl
	jp	(hl)

; input:
; 	hl = env
; output:
; 	carry clear if returned directly
; 	carry set if returned through longjmp
; int setjmp(jmp_buf env);
setjmp:
	pop	bc	; return address
	ex	de,hl
	ld	hl,0
	add	hl,sp
	ex	de,hl
	push	bc
	
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	
	or	a	; clear carry flag
	ret
