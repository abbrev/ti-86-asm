;
;
;       some helpful system routine addresses
;
;
;       For now refer to existing TI-85 or TI-83 documentation
;       from the WEB.
;
;
_clrLCD                          equ            4A7Eh
_clrScrn                         equ            4A82h
_putmap                          equ            4A27h
_putc                            equ            4A2Bh
_puts                            equ            4A37h
_putps                           equ            4A3Bh
_vputmap                         equ            4AA1h
_vputs                           equ            4AA5h
_vputsn                          equ            4AA9h
_GRBUFCPY                        equ            4E39h
_ILine                           equ            4E51h
_IPoint                          equ            4E59h
_PDspGrph                        equ            4D6Fh
_CLine                           equ            51E9h
_getkey                          equ            55AAh
_RANDOM                          equ            55DAh
_newline                         equ            4A5Fh
_runindicoff                     equ            4AB1h
_runindicon                      equ            4AADh
;
;
;       start address for all ASM programs
;
;
_asm_exec_ram             equ         0D748h
;
;
;       op1 to op6 ram equates
;
;
_OP1                      equ         0C089h
_OP1EXPM                  equ         0C08Ah
_OP1EXPL                  equ         0C08Bh
_OP1M                     equ         0C08Ch
_OP1EXT                   equ         0C093h
_OP2                      equ         0C094h
_OP2EXPM                  equ         0C095h
_OP2EXPL                  equ         0C096h
_OP2M                     equ         0C097h
_OP2EXT                   equ         0C09Eh
_OP3                      equ         0C09Fh
_OP3EXPM                  equ         0C0A0h
_OP3EXPL                  equ         0C0A1h
_OP3M                     equ         0C0A2h
_OP3EXT                   equ         0C0A9h
_OP4                      equ         0C0AAh
_OP4EXPM                  equ         0C0ABh
_OP4EXPL                  equ         0C0ACh
_OP4M                     equ         0C0ADh
_OP4EXT                   equ         0C0B4h
_OP5                      equ         0C0B5h
_OP5EXPM                  equ         0C0B6h
_OP5EXPL                  equ         0C0B7h
_OP5M                     equ         0C0B8h
_OP5EXT                   equ         0C0BFh
_OP6                      equ         0C0C0h
_OP6EXPM                  equ         0C0C1h
_OP6EXPL                  equ         0C0C2h
_OP6M                     equ         0C0C3h
_OP6EXT                   equ         0C0CAh
;
;
;       screen shadow ram equates
;
;
_textShadow               equ         0C0F9h
_cmdShadow                equ         0CFABh
_plotSScreen              equ         0C9FAh
;
;
;       display cursor ram equates
;
;
_curRow                   equ         0C00Fh
_curCol                   equ         0C010h
_penCol                   equ         0C37Ch
_penRow                   equ         0C37Dh
;
;
;       link port equates
;
;
BPort           alias     7               ;4-bit I/O
D0LD1L	    alias 	     0FCH
D0LD1H	    alias 	     0D4H
D0HD1L	    alias 	     0E8H
D0HD1H	    alias 	     0C0H
;
;
;
;       character font equates
;
;
;
Lbinary	alias	001h
Loctal	alias	002h
Ldecimal	alias	003h
Lhexadecimal	alias	004h
Lconvert	alias	005h
LsqUp	alias	006h
LsqDown	alias	007h
Lintegral	alias	008h
Lcross	alias	009h
LhexA	alias	00Ah
LhexB	alias	00Bh
LhexC	alias	00Ch
LhexD	alias	00Dh
LhexE	alias	00Eh
LhexF	alias	00Fh
Lroot	alias	010h
Linverse	alias	011h
Lsquare	alias	012h
Langle	alias	013h
Ldegree	alias	014h
Lradian	alias	015h
Ltranspose	alias	016h
LLE	alias	017h
LNE	alias	018h
LGE	alias	019h
Lneg	alias	01Ah
Lexponent	alias	01Bh
Lstore	alias	01Ch
Lten	alias	01Dh
LupArrow	alias	01Eh
LdownArrow	alias	01Fh
Lspace	alias	020h
Lexclam	alias	021h
Lquote	alias	022h
Lpound	alias	023h
Ldollar	alias	024h
Lpercent	alias	025h
Lampersand	alias	026h
Lapostrophe	alias	027h
LlParen	alias	028h
LrParen	alias	029h
Lasterisk	alias	02Ah
LplusSign	alias	02Bh
Lcomma	alias	02Ch
Ldash	alias	02Dh
Lperiod	alias	02Eh
Lslash	alias	02Fh
L0	alias	030h
L1	alias	031h
L2	alias	032h
L3	alias	033h
L4	alias	034h
L5	alias	035h
L6	alias	036h
L7	alias	037h
L8	alias	038h
L9	alias	039h
Lcolon	alias	03Ah
Lsemicolon	alias	03Bh
LLT	alias	03Ch
LEQ	alias	03Dh
LGT	alias	03Eh
Lquestion	alias	03Fh
LatSign	alias	040h
LcapA	alias	041h
LcapB	alias	042h
LcapC	alias	043h
LcapD	alias	044h
LcapE	alias	045h
LcapF	alias	046h
LcapG	alias	047h
LcapH	alias	048h
LcapI	alias	049h
LcapJ	alias	04Ah
LcapK	alias	04Bh
LcapL	alias	04Ch
LcapM	alias	04Dh
LcapN	alias	04Eh
LcapO	alias	04Fh
LcapP	alias	050h
LcapQ	alias	051h
LcapR	alias	052h
LcapS	alias	053h
LcapT	alias	054h
LcapU	alias	055h
LcapV	alias	056h
LcapW	alias	057h
LcapX	alias	058h
LcapY	alias	059h
LcapZ	alias	05Ah
LlBrack	alias	05Bh
Lbackslash	alias	05Ch
LrBrack	alias	05Dh
Lcaret	alias	05Eh
Lunderscore	alias	05Fh
Lbackquote	alias	060h
La	alias	061h
Lb	alias	062h
Lc	alias	063h
Ld	alias	064h
Le	alias	065h
Lf	alias	066h
Lg	alias	067h
Lh	alias	068h
Li	alias	069h
Lj	alias	06Ah
Lk	alias	06Bh
Ll	alias	06Ch
Lm	alias	06Dh
Ln	alias	06Eh
Lo	alias	06Fh
Lp	alias	070h
Lq	alias	071h
Lr	alias	072h
Ls	alias	073h
Lt	alias	074h
Lu	alias	075h
Lv	alias	076h
Lw	alias	077h
Lx	alias	078h
Ly	alias	079h
Lz	alias	07Ah
LlBrace	alias	07Bh
Lbar	alias	07Ch
LrBrace	alias	07Dh
Ltilde	alias	07Eh
LinvEQ	alias	07Fh
Lsub0	alias	080h
Lsub1	alias	081h
Lsub2	alias	082h
Lsub3	alias	083h
Lsub4	alias	084h
Lsub5	alias	085h
Lsub6	alias	086h
Lsub7	alias	087h
Lsub8	alias	088h
Lsub9	alias	089h
LcapAAcute	alias	08Ah
LcapAGrave	alias	08Bh
LcapACaret	alias	08Ch
LcapADier	alias	08Dh
LaAcute	alias	08Eh
LaGrave	alias	08Fh
LaCaret	alias	090h
LaDier	alias	091h
LcapEAcute	alias	092h
LcapEGrave	alias	093h
LcapECaret	alias	094h
LcapEDier	alias	095h
LeAcute	alias	096h
LeGrave	alias	097h
LeCaret	alias	098h
LeDier	alias	099h
LcapIAcute	alias	09Ah
LcapIGrave	alias	09Bh
LcapICaret	alias	09Ch
LcapIDier	alias	09Dh
LiAcute	alias	09Eh
LiGrave	alias	09Fh
LiCaret	alias	0A0h
LiDier	alias	0A1h
LcapOAcute	alias	0A2h
LcapOGrave	alias	0A3h
LcapOCaret	alias	0A4h
LcapODier	alias	0A5h
LoAcute	alias	0A6h
LoGrave	alias	0A7h
LoCaret	alias	0A8h
LoDier	alias	0A9h
LcapUAcute	alias	0AAh
LcapUGrave	alias	0ABh
LcapUCaret	alias	0ACh
LcapUDier	alias	0ADh
LuAcute	alias	0AEh
LuGrave	alias	0AFh
LuCaret	alias	0B0h
LuDier	alias	0B1h
LcapCCed	alias	0B2h
LcCed	alias	0B3h
LcapNTilde	alias	0B4h
LnTilde	alias	0B5h
Laccent	alias	0B6h
Lgrave	alias	0B7h
Ldieresis	alias	0B8h
LquesDown	alias	0B9h
LexclamDown	alias	0BAh
Lalpha	alias	0BBh
Lbeta	alias	0BCh
Lgamma	alias	0BDh
LcapDelta	alias	0BEh
Ldelta	alias	0BFh
Lepsilon	alias	0C0h
Ltheta	alias	0C1h
Llambda	alias	0C2h
Lmu	alias	0C3h
Lpi	alias	0C4h
Lrho	alias	0C5h
LcapSigma	alias	0C6h
Lsigma	alias	0C7h
Ltau	alias	0C8h
Lphi	alias	0C9h
LcapOmega	alias	0CAh
LxMean	alias	0CBh
LyMean	alias	0CCh
LsupX	alias	0CDh
Lellipsis	alias	0CEh
Lleft	alias	0CFh
Lblock	alias	0D0h
Lper	alias	0D1h
Lhyphen	alias	0D2h
Larea	alias	0D3h
Ltemp	alias	0D4h
Lcube	alias	0D5h
Lenter	alias	0D6h
LblockArrow     alias     0D7h
;
;
;       'getkey' equates
;
;
kRight	alias	001h
kLeft	alias	002h
kUp	alias	003h
kDown	alias	004h
kColon	alias	005h
kEnter	alias	006h
kExit	alias	007h
kClear	alias	008h
kDel	alias	009h
kIns	alias	00Ah
kNext	alias	00Bh
kAdd	alias	00Ch
kSub	alias	00Dh
kMul	alias	00Eh
kDiv	alias	00Fh
kExpon	alias	010h
kLParen	alias	011h
kRParen	alias	012h
kLBrack	alias	013h
kRBrack	alias	014h
kEqual	alias	015h
kStore	alias	016h
kRecall	alias	017h
kComma	alias	018h
kAng	alias	019h
kChs	alias	01Ah
kDecPnt	alias	01Bh
k0	alias	01Ch
k1	alias	01Dh
k2	alias	01Eh
k3	alias	01Fh
k4	alias	020h
k5	alias	021h
k6	alias	022h
k7	alias	023h
k8	alias	024h
k9	alias	025h
kEE	alias	026h
kSpace	alias	027h
kCapA	alias	028h
kCapB	alias	029h
kCapC	alias	02Ah
kCapD	alias	02Bh
kCapE	alias	02Ch
kCapF	alias	02Dh
kCapG	alias	02Eh
kCapH	alias	02Fh
kCapI	alias	030h
kCapJ	alias	031h
kCapK	alias	032h
kCapL	alias	033h
kCapM	alias	034h
kCapN	alias	035h
kCapO	alias	036h
kCapP	alias	037h
kCapQ	alias	038h
kCapR	alias	039h
kCapS	alias	03Ah
kCapT	alias	03Bh
kCapU	alias	03Ch
kCapV	alias	03Dh
kCapW	alias	03Eh
kCapX	alias	03Fh
kCapY	alias	040h
kCapZ	alias	041h
ka	alias	042h
kb	alias	043h
kc	alias	044h
kd	alias	045h
ke	alias	046h
kf	alias	047h
kg	alias	048h
kh	alias	049h
ki	alias	04Ah
kj	alias	04Bh
kk	alias	04Ch
kl	alias	04Dh
km	alias	04Eh
kn	alias	04Fh
ko	alias	050h
kp	alias	051h
kq	alias	052h
kr	alias	053h
ks	alias	054h
kt	alias	055h
ku	alias	056h
kv	alias	057h
kw	alias	058h
kx	alias	059h
ky	alias	05Ah
kz	alias	05Bh
kVarx	alias	05Ch
kAns	alias	05Dh
kPi	alias	05Eh
kInv	alias	05Fh
kSin	alias	060h
kASin	alias	061h
kCos	alias	062h
kACos	alias	063h
kTan	alias	064h
kATan	alias	065h
kSquare	alias	066h
kSqrt	alias	067h
kLn	alias	068h
kExp	alias	069h
kLog	alias	06Ah
kALog	alias	06Bh
kMath	alias	06Ch
kCplx	alias	06Dh
kString	alias	06Eh
kTest	alias	06Fh
kConv	alias	070h
kChar	alias	071h
kBase	alias	072h
kCustom	alias	073h
kVars	alias	074h
kCatalog	alias	075h
kQuit	alias	076h
kLastEnt	alias	077h
kLinkIO	alias	078h
kMem	alias	079h
kList	alias	07Ah
kVector	alias	07Bh
kConst	alias	07Ch
kMatrix	alias	07Dh
kPoly	alias	07Eh
kSimult	alias	07Fh
kStat	alias	080h
kGrMenu	alias	081h
kMode	alias	082h
kPrgm	alias	083h
kCalcu	alias	084h
kSolver	alias	085h
;
kTable	alias	086h		; new key added for LEO
;
kBOL	alias	087h
kEOL	alias	088h
kCUSTM	alias	093h
kF1	alias	0C2h
kF2	alias	0C3h
kF3	alias	0C4h
kF4	alias	0C5h
kF5	alias	0C6h
kF6	alias	0C7h
kF7	alias	0C8h
kF8	alias	0C9h
kF9	alias	0CAh
kF10    alias     0CBh
kGRAPH	alias	0FFh


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Added from different ti86asm.inc file


; Reduced ti86asm.inc for E2 driver
;
_homeup         equ       4A95h       ; cursror to top left of home screen
_MEMCHK         equ       46BBh       ; ahl = # bytes of free memory
_check_for_var	equ	  46E3h	      ; Checks to see if there is enough
				      ; RAM for this variable: hl=size, 
				      ; OP1=name
;
_CREATEREAL    equ      46EBh   ; CREATE REAL VAR OP1, NO INPUTS
;
_CREATECPLX    equ      46F7h   ; CREATE CPLX VAR OP1, NO INPUTS
;
_CREATERCONST  equ      46EFh   ; CREATE REAL CONSTANT VAR OP1, NO INPUTS
_CREATECCONST  equ      46F3h   ; CREATE CPLX CONSTANT VAR OP1, NO INPUTS
;
_CREATERVECT   equ      46FFh   ; CREATE REAL VECTOR OP1, L = # ELEMENTS
_CREATECVECT   equ      4707h   ; CREATE CPLX VECTOR OP1, L = # ELEMENTS
;
_CREATERLIST   equ      470Fh   ; CREATE REAL LIST OP1, HL = # ELEMENTS
_CREATECLIST   equ      4717h   ; CREATE CPLX LIST OP1, HL = # ELEMENTS
;
_CREATERMAT    equ      471Fh   ; CREATE REAL MATRIX OP1, HL = ROW,COL
_CREATECMAT    equ      4727h   ; CREATE CPLX MATRIX OP1, HL = ROW,COL
;
_CREATESTRNG   equ      472Fh   ; CREATE STRING OP1, HL = # BYTES
;
_CREATEEQU     equ      4737h   ; CREATE EQUATION OP1, HL = # BYTES
;
_CREATEPICT    equ      473Bh   ; CREATE PICTURE VAR OP1, NO INPUTS
;
_CREATEPROG    equ      474Fh   ; CREATE PROGRAM VAR OP1, HL = # BYTES
;
_FINDSYM       equ      46CBh   ; LOOK UP VAR
_delvar        equ      475Fh   ; DELETE VAR
;
;
;
;
_flushallmenus  equ     49DCh   ; clear the 86's menu key stacks

; Writes b zeros to (hl)
_zeromem	equ	437Bh	

; Gets word at ahl and puts it in de -- Does not re-swap RAM page!
; Destroys ahl...
_get_word_ahl	equ	521Dh

; Sets word at ahl to de
_set_word_ahl	equ	5221h

