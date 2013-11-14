; bayer.asm, Bayer dithering routine
; Copyright 2004, 2006 Christopher Williams
; Email: abbrev@gmail.com
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

; This routine tells whether a given pixel is on or off depending on its
; location (row and column) and its grey value.
; It implements Bayer dithering using 4x4 dither patterns.
; It looks up the threshold for the row and column in a table and compares it to
; the supplied grey level. If the level is less than the threshold, then the
; pixel is set, otherwise it's clear.
; I learned this technique from working with PostScript; it uses thresholds for
; dithering much like this routine does.

; input:
; 	d = gray value (0 = black, 255 = white)
; 	b = row, c = column
; output:
; 	carry is set if pixel is on
; 70 cycles
; 34 bytes min, 49 bytes max
bayerdither:
	ld	a,b		; 4
	add	a,a		; 4
	add	a,a		; 4
	and	3<<2		; 7
	ld	b,a		; 4
	
	ld	a,c		; 4
	and	3		; 7
	add	a,b		; 4
	or	.levels&0b11110000	; 7
	ld	l,a		; 4
	ld	h,.levels>>8	; 7
	
	ld	a,d		; 4
	cp	(hl)		; 7
	ret			; 10

; These are the minimum grey levels for which each pixel is off (white).
; To change the dither pattern, use each of the numbers 0 to 15, then multiply
; by 16 and add 8 to them. More simply, just use the hexadecimal numbers 0x08,
; 0x18, 0x28, etc.
; The lowest numbers go white first, and the highest numbers go black first.
 align 16
.levels
	if 1
	; fine checkerboard
	db	$98,$58,$a8,$68
	db	$28,$f8,$08,$d8
	db	$b8,$78,$88,$48
	db	$18,$c8,$38,$e8
	else
	if 0
	; newsprint
	db	$08,$28,$d8,$98
	db	$48,$68,$f8,$b8
	db	$c8,$88,$18,$38
	db	$e8,$a8,$58,$78
	else
	; "K map"
	db	$08,$18,$38,$28
	db	$48,$58,$78,$68
	db	$c8,$d8,$f8,$e8
	db	$88,$98,$b8,$a8
	endif
	endif
