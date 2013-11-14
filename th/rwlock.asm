; Readers/writer lock for th.
; Copyright 2006, 2007 Christopher Williams.
; Email: abbrev@gmail.com
; 
; $Id: rwlock.asm,v 1.4 2007/05/02 22:22:48 christop Exp $
; 
; This attempts to solve the third readers-writers problem. See
; http://en.wikipedia.org/wiki/Readers-writers_problem for more information.
; This library prevents both readers and writers from starving. It blocks
; attempts to read-lock the lock if a writer wants to write-lock it, until the
; writer releases the lock. Also, it lets readers obtain a freed write-lock
; before a writer can obtain a write-lock to prevent readers from starving.
; That's the theory, anyhow.

; There are six functions of interest here:
; rw_init         initialize a rwlock
; rw_trylock      try to obtain a lock without blocking
; rw_lock         obtain a lock
; rw_tryreadlock  try to obtain a read lock without blocking
; rw_readlock     obtain a read lock
; rw_unlock       unlock a rwlock variable
; Each function takes the address of the rwlock in HL.

; This is the read-write lock structure:
; struct rwlock {
; 	char writers;
; 	int readers;
; };

	segu "offsets"
	org 0
rw_writers ds 1	; This indicates that the lock is write-locked or (if
		; readers != 0) that a writer is attempting to
		; write-lock the lock. If this is set, an attempt to
		; read-lock the lock will block.
rw_readers ds 2	; This indicates how many readers have locked the lock.
		; (Should this be one only byte? Having more than 255 readers is
		; very unlikely.)

	seg "code"

; input:
; 	hl = struct rwlock *rw
; output:
; 	none
; registers destroyed:
; 	hl
rw_init:
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	ret

; input:
; 	hl = struct rwlock *rw
; output:
; 	carry is set if we got the lock
; registers destroyed:
; 	af, de
rw_trylock:
	ld	d,h
	ld	e,l
	inc	de	; de = &rw->readers, hl = &rw->writers
	ld	a,(de)
	or	a
	ret	nz	; rw->readers != 0
	inc	de
	ld	a,(de)
	dec	de
	or	a
	ret	nz	; rw->readers != 0
	
	ld	a,(hl)
	or	a
	ret	nz	; there's already a write-lock
	
	inc	(hl)	; we got the lock
	scf
	ret

; input:
; 	hl = struct rwlock *rw
; output:
; 	none
rw_lock:
	jr	.try
.sleep
	; We'll set the writers flag to block readers from obtaining read-locks.
	; This prevents writers from starving.
	ld	(hl),1
	
	push	hl
	call	th_sleep
	pop	hl
.try	call	rw_trylock
	jr	nc,.sleep
	ret

; input:
; 	hl = struct rwlock *rw
; output:
; 	carry is set if we got the lock
; registers destroyed:
; 	af, de
rw_tryreadlock:
	ld	a,(hl)	;rw->writers == 0
	or	a
	ret	nz
	
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	
	inc	de	;++rw->readers
	
	ld	(hl),d
	dec	hl
	ld	(hl),e
	dec	hl
	
	scf
	ret

; input:
; 	hl = struct rwlock *rw
; output:
; 	none
rw_readlock:
	jr	.try
.sleep	push	hl
	inc	hl
	call	th_sleep	;th_sleep(&rw->readers)
	pop	hl
.try	call	rw_tryreadlock
	jr	nc,.sleep
	ret

; input:
; 	hl = struct rwlock *rw
; output:
; 	carry is set on error (if rwlock is not locked)
rw_unlock:
	ld	d,h
	ld	e,l
	inc	hl	; de = &rw->writers, hl = &rw->readers
	
	ld	a,(hl)
	or	a
	jr	nz,.reader
	inc	hl
	ld	a,(hl)
	dec	hl
	or	a
	jr	z,.notreader
.reader
	ld	c,(hl)	;if (--rw->readers == 0 && rw->writers) {
	inc	hl
	ld	b,(hl)
	
	dec	bc
	
	ld	(hl),b
	dec	hl
	ld	(hl),c
	
	ld	a,b
	or	c
	jr	nz,.morereaders
	
	ld	a,(de)	;rw->writers != 0
	or	a
	ret	z
	
	ex	de,hl
	ld	(hl),0	;rw->writers = 0;
	call	th_wake	;th_wake(&rw->writers);
.morereaders
	or	a	; clear carry
	ret
.notreader
	ld	a,(de)
	or	a
	jr	z,.notwriter
	
	xor	a
	ld	(de),a	;rw->writers = 0;
	
	; We'll give readers a head-start to obtain read-locks before a writer
	; can obtain a write-lock. This prevents readers from starving.
	push	de
	call	th_wake	;th_wake(&rw->readers);
	call	th_yield	;th_yield();
	pop	hl
	call	th_wake	;th_wake(&rw->writers);
	;call	th_yield	; do we need this?
	
	or	a	; clear carry
	ret
.notwriter
	scf
	ret
