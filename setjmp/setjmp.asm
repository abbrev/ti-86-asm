; typedef struct {
; 	uint16_t sp;
; 	uint16_t pc;
; } jmp_buf[1];


; 2006-11-21: fixed setjmp - moved "push bc" after "add hl,sp"

; input:
; 	hl = env
; output:
; 	hl = 0 and carry clear if returned directly
; 	hl = not 0 and carry set if returned through longjmp
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
	
	xor	a	; clear carry flag
	ld	h,a	; return 0
	ld	l,a
	ret

; input:
; 	hl = env
; 	bc = val
; output:
; 	none (never returns)
; void longjmp(jmp_buf env, int val);
longjmp:
	ld	a,b
	or	c
	jr	nz,.nz
	inc	bc	; can't return 0
.nz	
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
	push	de	; push return address
	ld	l,c
	ld	h,b
	scf
	ret
