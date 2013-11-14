; atexit.asm, atexit, exit, and _Exit functions
; Copyright 2005 Chris Williams.
; 
; This library is free software; you can redistribute it and/or
; modify it under the terms of the GNU Lesser General Public
; License as published by the Free Software Foundation; either
; version 2.1 of the License, or (at your option) any later version.
; 
; This library is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
; Lesser General Public License for more details.
; 
; You should have received a copy of the GNU Lesser General Public
; License along with this library; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



; This implements the C standard functions atexit, exit, and _Exit.
; 
; The starting point "start" initialises the savesp, atexitsp, and numfuncs
; variables and reserves enough space on the stack for the addresses of at least
; 32 functions (in accordance with POSIX).
; 
; The atexit function pushes the address of the function onto the atexit stack,
; unless ATEXIT_MAX has been reached.
; 
; The exit function sets the stack pointer to the atexit stack, then it
; "returns" to whatever address is found at the bottom of the stack. The
; function addresses on the atexit stack are, in effect, return addresses at
; this time. The program's original return address is then reached after the
; last functions has run.
; 
; The _Exit function exits the program without executing the functions
; registered with atexit.

; The POSIX minimum value for ATEXIT_MAX is 32, but this can be changed for
; specific applications if they do not require that many functions.
; The minimum is 0, and the maximum is 255.
ATEXIT_MAX	equ	32

start:
	ld	(_Exitsp),sp
	ld	(atexitsp),sp
	
	ld	hl,-ATEXIT_MAX*2	;reserve space for atexit functions
	add	hl,sp
	ld	sp,hl
	
	xor	a
	ld	(numfuncs),a
	
	call	main
	;fall through

;call the atexit-registered functions and exit the program
;input:
;	none
;output:
;	none (does not return)
exit:
	ld	sp,(atexitsp)	;set the stack to the atexit stack
	ret

;exit the program without calling the atexit-registered functions
;input:
;	none
;output:
;	none (does not return)
_Exit:
	ld	sp,(_Exitsp)
	ret

;register a function to be called on exit
;input:
;	hl = function to register
;output:
;	carry is set on error
atexit:
	ld	a,(numfuncs)
	cp	ATEXIT_MAX
	scf
	ret	z
	inc	a		;increment the number of functions
	ld	(numfuncs),a
	ld	de,(atexitsp)	;get the atexitsp
	ex	de,hl
	dec	hl
	ld	(hl),d		;"push" this function on the atexit stack
	dec	hl
	ld	(hl),e
	ld	(atexitsp),hl	;store the new bottom of the atexit stack
	or	a		;clear carry
	ret
	
	segu	"data"
;These variables can be moved to anywhere in RAM.
_Exitsp	ds	2
atexitsp	ds	2
numfuncs	ds	1
;exitstatus	ds	2
	seg	"code"
