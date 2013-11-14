
;             FAST EIGHT BIT SIGNED MULTIPLICATION ROUTINES
;                     by Matthew Shepcar  August 1998


; This routine finds the value of (H*E+64)/128 and stores the result in H.
; It is slightly faster if H is positive and minutely faster if E is.
; A, HL, DE are used by the code.   DE will contain the sign extended value
; of E*2.   HL will contain (H*E*2+128).   A will be the same as D.


MultAxH:                
        ld e,a
MultExH:                
        ld l,1          ;initial result (the 1 is for rounding)
        sla h           ;shift sign bit out
        jr nc,NotNegMult
; H is negative but use its positive counterpart and flip E's sign to get
; the same result
        xor a
        sub e           ;negate E
        add a,a         ;double
        ld e,a
        sbc a,a         
        ld d,a          ;sign extend E
        jr nc,$+5
        inc h           
        ld l,-1         ;initial result is different if E is negative
        add hl,hl       ;double result & get next bit of H
        jr c,$+3
        add hl,de       ;add DE to result if bit clear (H's bits have
        add hl,hl       ;the reverse meaning because we are treating it as
        jr c,$+3        ;a positive number)
        add hl,de
        add hl,hl
        jr c,$+3
        add hl,de
        add hl,hl
        jr c,$+3        
        add hl,de       
        add hl,hl       
        jr c,$+3
        add hl,de
        add hl,hl
        jr c,$+3
        add hl,de
        add hl,hl
        jr c,$+3
        add hl,de       ;twos complement = flip bits and add 1
        add hl,de       ;this final addition constitutes the 'add 1'
        ret

NotNegMult:
        sla e
        sbc a,a
        ld d,a
        jr nc,$+5
        inc h
        ld l,-1
        add hl,hl
        jr nc,$+3
        add hl,de
        add hl,hl
        jr nc,$+3
        add hl,de
        add hl,hl
        jr nc,$+3
        add hl,de
        add hl,hl
        jr nc,$+3
        add hl,de
        add hl,hl
        jr nc,$+3
        add hl,de
        add hl,hl
        jr nc,$+3
        add hl,de
        add hl,hl
        ret nc
        add hl,de
        ret

 if 0
MultAxDE:
        ld b,-1
        add a,a         ;shift sign bit out
        jr nc,NotNegMult16
        push de
        or a
        sbc hl,hl
        sbc hl,de
        add hl,hl
        ex de,hl
        sbc hl,hl
        jr c,$+4
        inc b
        inc l
        adc a,0
        add hl,hl
        rla
        jr c,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr c,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr c,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr c,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr c,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr c,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr c,$+4
        add hl,de
        adc a,b
        add hl,de  
        adc a,b
        ld l,h
        ld h,a
        pop de
        ret

NotNegMult16:
        sla e
        rl d
        sbc hl,hl
        jr c,$+4
        inc b
        inc l
        adc a,0
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,b
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,b
        ld l,h
        ld h,a
        ret

 endif
