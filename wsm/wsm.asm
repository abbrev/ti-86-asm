; wsm.asm, World Sunlight Map
; Copyright 2004 Chris Williams <cow3.14@juno.com>
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

	nolist
	include "asm86.h"
	include "ti86asm.inc"
	list
	
	segu "data"
	org code_end
	seg "code"
	
	org _asm_exec_ram
	include	"atexit.asm"
	
main:
	call	_runindicoff
	call	buildsintable
	
	ld	hl,clearHome
	call	atexit
	
	ld	hl,0
	ld	(month),hl
	ld	(day),hl
	ld	(hour),hl
	
	ld	hl,mnu_month
	ld	de,(month)
	call	run_menu
	
	; ...
	
	ret
	
setmonth:
	ld	(month),de
	
	; mnu_day.numitems = monthlengths[month]
	ld	hl,monthlengths
	add	hl,de
	ld	a,(hl)
	ld	hl,mnu_day+4
	ld	(hl),a
	
	ld	hl,mnu_day
	ld	de,(day)
	jp	run_menu
	
setday:
	ld	(day),de
	ld	hl,mnu_hour
	ld	de,(hour)
	jp	run_menu
	
sethour:
	ld	(hour),de
	
	if	0
	ld	hl,mnu_minute
	ld	de,0
	jp	run_menu
	
setminute:
	ld	(minute),de
	endif
	
	call	draw_map
.getkey	halt
	call	GET_KEY
	or	a
	jr	z,.getkey
	cp	K_CLEAR
	jp	z,exit
	ret
	
exit_on_clear:
	cp	K_CLEAR
	jp	z,exit
	ret
	
clearHome:
	ld	hl,0
	ld	(_curRow),hl
	jp	_clrLCD
	
draw_map:
	ld	hl,earthimage
	ld	de,VIDEO_MEM
	ld	(currpixeladdr),de
	call	decompress
	
	ld	a,0b10000000
	ld	(currpixelmask),a
	
	call	get_doy_and_hour
	
	; theta = 128-256*hour/24
	; -- 256*hour/24 ~= (hour*171) >> 4
	; FIXME: add in minutes to equation
	ld	a,(hour)
	ld	h,171
	call	muluAxH
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	rl	l		; to round
	ld	a,128
	sbc	a,h
	ld	(suntheta),a	; suntheta = 128 - 256*hour/24
	
	; 170 or 171 days is Summer Solstice
	; 183 days is (about) half a year
	; 16.6755... is 23.45 degrees (incl. of sun at Summer Solstice) in 256
	; phi = 16.67555556 * cos(256*(doy-172)/365)
	; -- 256*(doy-86)/183 ~= ((doy-86)*179) >> 7
	; -- 16.676*x ~= (x*67) >> 2
	ld	a,(doy)		; actually half of day of year
	sub	170/2
	jr	nc,.doyinbounds	; make sure doy >= 0
	add	a,183
.doyinbounds
	ld	h,179		; 256 * 128 / 183
	call	muluAxH
	add	hl,hl		; 256 * (doy-86) / 183
	ld	bc,0x80
	add	hl,bc		; to round
	ld	e,h
	ld	d,0
	
	ld	hl,costable
	add	hl,de
	ld	a,(hl)		; cos(n)
	
	ld	h,67		; 4 * 16.6755... 
	call	MultAxH
	sra	h
	inc	h		; to round
	sra	h		; 16.6755... * n
	ld	e,h
	ld	d,0		; phi
	
	ld	hl,costable
	add	hl,de
	ld	a,(hl)
	ld	(sunx),a	; sunx = cos(phi)
	; suny is 0 (we shift the earth's theta below to compensate)
	
	ld	hl,sintable
	add	hl,de
	ld	a,(hl) 		; sinphi = sin(phi)
	ld	(sunz),a	; sunz = sinphi
	
; Now we start looping for each pixel
	xor	a
	ld	(row),a
	;jp	.forrowcond
.forrow	; for r=0 to h-1
	add	a,a
	ld	b,a
	ld	a,64
	sub	b
	ld	d,0
	ld	e,a		; phi = ymax + dy * r
	
	ld	hl,costable
	add	hl,de
	ld	a,(hl)
	ld	(cosphi),a	; cosphi = cos(phi)
	
	ld	hl,sintable
	add	hl,de
	ld	h,(hl) 		; sinphi = sin(phi)
	
	ld	a,(sunz)
	call	MultAxH
	ld	a,h
	ld	(z_times_sunz),a
	
	; 
	xor	a
	ld	(col),a
	;jp	.forcolcond
.forcol	; for c=0 to w-1
	add	a,a
	add	a,-128
	ld	hl,suntheta
	sub	(hl)
	ld	d,0
	ld	e,a		; theta = xmin + dx * c - suntheta
	
	ld	hl,costable
	add	hl,de
	ld	h,(hl)		; cos(theta)
	ld	a,(cosphi)
	call	MultAxH 	; x = cos(theta) * cosphi
	
	ld	a,(sunx)
	call	MultAxH		; x * sunx
	
	ld	a,(z_times_sunz)
	add	a,h		; cosangle = x*sunx + z_times_sunz
	
	ld	c,0x80
	cp	c
	jr	c,.illum	; if cosangle > 0
	xor	a		; truncate to 0
.illum
	add	a,c		; the darkest illuminated part is 50% gray
	ld	bc,(col)	; row and col
	ld	d,a
	call	bayerdither
	ld	hl,(currpixeladdr)
	ld	de,currpixelmask
	jr	nc,.incpixel	; if bayerdither(row,col,g)
	ld	a,(de)
	or	(hl)
	ld	(hl),a
.incpixel
	ld	a,(de)
	rrca
	ld	(de),a
	jr	nc,.samebyte
	inc	hl
	ld	(currpixeladdr),hl ; pxon(row,col)
.samebyte
	
	;increment col
	ld	hl,col
	inc	(hl)
	ld	a,(hl)
;.forcolcond
	cp	128
	jp	c,.forcol
	
	;increment row
	ld	hl,row
	inc	(hl)
	ld	a,(hl)
;.forrowcond
	cp	64
	jp	c,.forrow
	
	ret

; FIXME: is this correct?
; input:
; 	month = 0..11
; 	day = 0..30
; output:
; 	doy = 0..182 (half days)
get_doy_and_hour:
	ld	hl,0
	ld	a,(month)
	or	a
	jr	z,.addday
	
	ld	b,a
	ld	de,monthlengths
.nextmonth
	ld	a,(de)
	inc	de
	add	a,l
	ld	l,a
	adc	a,h
	sub	l
	ld	h,a
	djnz	.nextmonth	; add up the days in each month
.addday
	ld	a,(day)
	add	a,l
	ld	l,a
	adc	a,h
	sub	l
	ld	h,a
	inc	hl		; to round
	rrc	h
	rr	l
	ld	a,l
	ld	(doy),a
	
	ret

monthlengths
	db	31,28,31,30,31,30,31,31,30,31,30,31

	include	"mult.asm"
	include	"menu.asm"
NEED_DECOMPRESS	equ 1
	include	"compress/compress.asm"
	include	"bayer/bayer.asm"
	include	"feumult.asm"
	include	"sincos.asm"
;mulu equ MUL_AxL
earthimage:
	nolist
	include	"earth.gfx"
	list
	;
	nolist
	include	"menus.data"
	list
code_end

	segu	"data"
doy	ds	1
month	ds	2
day	ds	2
hour	ds	2
minute	ds	2

cosphi	ds	1
sunx	ds	1
sunz	ds	1
suntheta	ds	1
z_times_sunz	ds	1
currpixeladdr	ds	2
currpixelmask	ds	1
col	ds	1
row	ds	1
sintable	ds	320
costable	equ	sintable+64
