;atexit.asm, atexit, exit, and _Exit functions
;Copyright 2005, 2006 Chris Williams.
;
;This library is free software; you can redistribute it and/or
;modify it under the terms of the GNU Lesser General Public
;License as published by the Free Software Foundation; either
;version 2.1 of the License, or (at your option) any later version.
;
;This library is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;Lesser General Public License for more details.
;
;You should have received a copy of the GNU Lesser General Public
;License along with this library; if not, write to the Free Software
;Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



;This implements the C standard functions atexit, exit, and _Exit.
;
;The starting point "start" initialises the savesp, atexitsp, and numfuncs
;variables and reserves enough space on the stack for the addresses of at least
;32 functions (in accordance with POSIX :D ).
;
;The atexit function pushes the address of the function onto the atexit stack,
;unless ATEXIT_MAX has been reached.
;
;The exit function saves the exit status, then it sets the stack pointer to the
;atexit stack, and finally exit "returns" to whatever address is found at the
;bottom of the stack. The function addresses on the atexit stack are, in effect,
;return addresses at this time.
;
;Finally, the program ends with _Exit, which does the actual exit of the
;program.

;The POSIX minimum value for ATEXIT_MAX is 32, but this can be changed for
;specific applications if they do not require that many functions.
;The minimum is 0, and the maximum is 255.
ATEXIT_MAX	equ	32

start:
	ld	(savesp),sp
	
	call	@blah
	;we return here after all atexit-registered functions have returned
	;(the last function returns here).
;	ld	hl,(exitstatus)		;restore exit status
	jr	_Exit
@blah	ld	(atexitsp),sp
	
	ld	hl,-ATEXIT_MAX*2	;reserve space for atexit functions
	add	hl,sp
	ld	sp,hl
	
	ld	a,ATEXIT_MAX
	ld	(numfuncs),a
	
	call	main
	;fall through

;call the atexit-registered functions and exit the program
;input:
;	hl = status
;output:
;	none (does not return)
exit:
;	ld	(exitstatus),hl	;save exit status for later
	ld	hl,(atexitsp)	;set the stack to the atexit stack
	ld	sp,hl
	ret

;exit the program without calling the atexit-registered functions
;input:
;	hl = status
;output:
;	none (does not return)
_Exit:
	ld	sp,(savesp)
	ret

;register a function to be called on exit
;input:
;	hl = function to register
;output:
;	carry is set on error
atexit:
	ld	a,(numfuncs)
	sub	1		;decrement 1, carry if A is 0
	ret	c		;return if it carries
	
	ld	(numfuncs),a
	ld	de,(atexitsp)	;get the atexitsp
	ex	de,hl
	dec	hl		;"push" this function onto the atexit stack
	ld	(hl),d
	dec	hl
	ld	(hl),e
	ld	(atexitsp),hl	;store the new bottom of the atexit stack
	;carry is already clear at this point
	ret

;These variables can be moved to anywhere in RAM.
savesp
	ds	2
atexitsp
	ds	2
numfuncs
	ds	1
;exitstatus
;	ds	2
