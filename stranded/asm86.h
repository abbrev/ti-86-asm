;====================================================================
;These are common zshell and usgard calls that are known on the TI-86
;If possible, use the call that is commented next to the one you want
;====================================================================
MUL_HL  equ  $4547

CP_HL_DE  equ  $403C
LD_HL_MHL  equ  $4010
GET_KEY  equ  $5371
UNPACK_HL  equ  $4044

D_HL_DECI  equ  $4a33

BUSY_OFF  equ  $4ab1			;_runindoff
BUSY_ON  equ  $4aad				;_runindicon
D_ZT_STR  equ  $4a37			;_puts
D_LT_STR  equ  $4a3b			;_putps
TX_CHARPUT  equ  $4a2b			;_putc
D_ZM_STR  equ  $4aa5			;_vputs
D_LM_STR  equ  $4aa9			;_vputsn
M_CHARPUT  equ  $4aa1			;_vputmap
CLEARLCD  equ  $4a7e			;_clrLCD


;========================================================
;These are memory addresses common for zshell programming
;If possible, use the one on the right
;========================================================

CONTRAST  equ  $c008			
CURSOR_ROW  equ  $c00f			;_curRow
CURSOR_COL  equ  $c010			;_curCol
BUSY_COUNTER  equ  $c087 
BUSY_BITMAP	 equ  $c088
TEXT_MEM  equ  $c0f9			;_textShadow
CURSOR_X  equ  $c37c			;_penCol
CURSOR_Y  equ  $c37d			;_penRow
GRAPH_MEM  equ  $c9fa			;_plotSScreen
TEXT_MEM2  equ  $cfab			;_cmdShadow
VAT_END  equ  $d298
VAT_START  equ  $8000
VIDEO_MEM  equ  $fc00

;==================================================================
;all the keys are used with <call GET_KEY>, not TI's <call _getkey>
;==================================================================
K_NOKEY        equ $00    ;No key
K_DOWN         equ $01    ;Down
K_LEFT         equ $02    ;Left
K_RIGHT        equ $03    ;Right
K_UP           equ $04    ;Up
K_ENTER        equ $09    ;Enter
K_PLUS         equ $0A    ;+                      X
K_MINUS        equ $0B    ;-                      T
K_STAR         equ $0C    ;*                      O
K_SLASH        equ $0D    ;/                      J
K_RAISE        equ $0E    ;^                      E
K_CLEAR        equ $0F    ;Clear
K_SIGN         equ $11    ;(-)                    Space
K_3            equ $12    ;3                      W
K_6            equ $13    ;6                      S
K_9            equ $14    ;9                      N
K_RIGHTPAR     equ $15    ;)                      I
K_TAN          equ $16    ;Tan                    D
K_CUSTOM       equ $17    ;Custom
K_DOT          equ $19    ;.                      Z
K_2            equ $1A    ;2                      V
K_5            equ $1B    ;5                      R
K_8            equ $1C    ;8                      M
K_LEFTPAR      equ $1D    ;(                      H
K_COS          equ $1E    ;Cos                    C
K_PRGM         equ $1F    ;Prgm
K_DEL          equ $20    ;Del
K_0            equ $21    ;0                      Y
K_1            equ $22    ;1                      U
K_4            equ $23    ;4                      Q
K_7            equ $24    ;7                      L
K_EE           equ $25    ;EE                     G
K_SIN          equ $26    ;Sin                    B
K_TABLE        equ $27    ;Table		  ;Used to be Stat on the TI-85, now K_TABLE
K_XVAR         equ $28    ;x-Var                  x
K_ON           equ $29    ;On
K_STO          equ $2A    ;Sto                     equ 
K_COMMA        equ $2B    ;,                      P
K_SQUARE       equ $2C    ;x^2                    K
K_LN           equ $2D    ;Ln                     F
K_LOG          equ $2E    ;Log                    A
K_GRAPH        equ $2F    ;Graph
K_ALPHA        equ $30    ;Alpha
K_F5           equ $31    ;F5
K_F4           equ $32    ;F4
K_F3           equ $33    ;F3
K_F2           equ $34    ;F2
K_F1           equ $35    ;F1
K_SECOND       equ $36    ;2nd
K_EXIT         equ $37    ;EXIT
K_MORE         equ $38    ;MORE
