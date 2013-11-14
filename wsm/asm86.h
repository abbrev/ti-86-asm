; NOTE: I've modified this file from the original. (Chris Williams)
;====================================================================
;These are common zshell and usgard calls that are known on the TI-86
;If possible, use the call that is commented next to the one you want
;====================================================================
MUL_HL		equ  0x4547

CP_HL_DE	equ  0x403C
LD_HL_MHL	equ  0x4010
GET_KEY		equ  0x5371
UNPACK_HL	equ  0x4044

D_HL_DECI	equ  0x4a33

BUSY_OFF	equ  0x4ab1			;_runindoff
BUSY_ON		equ  0x4aad				;_runindicon
D_ZT_STR	equ  0x4a37			;_puts
D_LT_STR	equ  0x4a3b			;_putps
TX_CHARPUT	equ  0x4a2b			;_putc
D_ZM_STR	equ  0x4aa5			;_vputs
D_LM_STR	equ  0x4aa9			;_vputsn
M_CHARPUT	equ  0x4aa1			;_vputmap
CLEARLCD	equ  0x4a7e			;_clrLCD


;========================================================
;These are memory addresses common for zshell programming
;If possible, use the one on the right
;========================================================

CONTRAST	equ  0xc008			
CURSOR_ROW	equ  0xc00f			;_curRow
CURSOR_COL	equ  0xc010			;_curCol
BUSY_COUNTER	equ  0xc087 
BUSY_BITMAP	equ  0xc088
TEXT_MEM	equ  0xc0f9			;_textShadow
CURSOR_X	equ  0xc37c			;_penCol
CURSOR_Y	equ  0xc37d			;_penRow
GRAPH_MEM	equ  0xc9fa			;_plotSScreen
TEXT_MEM2	equ  0xcfab			;_cmdShadow
VAT_END		equ  0xd298
VAT_START	equ  0x8000
VIDEO_MEM	equ  0xfc00

;==================================================================
;all the keys are used with <call GET_KEY>, not TI's <call _getkey>
;==================================================================
K_NOKEY       alias 0x00    ;No key
K_DOWN        alias 0x01    ;Down
K_LEFT        alias 0x02    ;Left
K_RIGHT       alias 0x03    ;Right
K_UP          alias 0x04    ;Up
K_ENTER       alias 0x09    ;Enter
K_PLUS        alias 0x0A    ;+                      X
K_MINUS       alias 0x0B    ;-                      T
K_STAR        alias 0x0C    ;*                      O
K_SLASH       alias 0x0D    ;/                      J
K_RAISE       alias 0x0E    ;^                      E
K_CLEAR       alias 0x0F    ;Clear
K_SIGN        alias 0x11    ;(-)                    Space
K_3           alias 0x12    ;3                      W
K_6           alias 0x13    ;6                      S
K_9           alias 0x14    ;9                      N
K_RIGHTPAR    alias 0x15    ;)                      I
K_TAN         alias 0x16    ;Tan                    D
K_CUSTOM      alias 0x17    ;Custom
K_DOT         alias 0x19    ;.                      Z
K_2           alias 0x1A    ;2                      V
K_5           alias 0x1B    ;5                      R
K_8           alias 0x1C    ;8                      M
K_LEFTPAR     alias 0x1D    ;(                      H
K_COS         alias 0x1E    ;Cos                    C
K_PRGM        alias 0x1F    ;Prgm
K_DEL         alias 0x20    ;Del
K_0           alias 0x21    ;0                      Y
K_1           alias 0x22    ;1                      U
K_4           alias 0x23    ;4                      Q
K_7           alias 0x24    ;7                      L
K_EE          alias 0x25    ;EE                     G
K_SIN         alias 0x26    ;Sin                    B
K_TABLE       alias 0x27    ;Table		  ;Used to be Stat on the TI-85, now K_TABLE
K_XVAR        alias 0x28    ;x-Var                  x
K_ON          alias 0x29    ;On
K_STO         alias 0x2A    ;Sto                    equ 
K_COMMA       alias 0x2B    ;,                      P
K_SQUARE      alias 0x2C    ;x^2                    K
K_LN          alias 0x2D    ;Ln                     F
K_LOG         alias 0x2E    ;Log                    A
K_GRAPH       alias 0x2F    ;Graph
K_ALPHA       alias 0x30    ;Alpha
K_F5          alias 0x31    ;F5
K_F4          alias 0x32    ;F4
K_F3          alias 0x33    ;F3
K_F2          alias 0x34    ;F2
K_F1          alias 0x35    ;F1
K_SECOND      alias 0x36    ;2nd
K_EXIT        alias 0x37    ;EXIT
K_MORE        alias 0x38    ;MORE
