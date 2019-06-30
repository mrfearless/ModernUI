;==============================================================================
;
; DrawTextEXT v1.0.0.0
;
; by mrfearless - www.github.com/mrfearless - http://www.LetTheLight.in
;
; Adapted from DrawHTML code posted by Ukkie9 
;
; https://www.codeproject.com/Articles/7936/DrawHTML
;
;==============================================================================

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib masm32.lib

include DrawTextEXT.inc


;------------------------------------------------------------------------------
; Macros for checking register = (or !=) tab, space, crlf, whitespace
;------------------------------------------------------------------------------
ISTAB MACRO x:REQ           ; (x == 09h)
    LOCAL tmp$
    tmp$ TEXTEQU <(x == 09h) >
    % ECHO tmp$
    EXITM tmp$
ENDM

ISTABNOT MACRO x:REQ        ; (x != 09h)
    LOCAL tmp$
    tmp$ TEXTEQU <(x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 09h) >    
    % ECHO tmp$
    EXITM tmp$
ENDM

ISSPACE MACRO x:REQ         ; (x == 20h)
    LOCAL tmp$
    tmp$ TEXTEQU <(x == 20h) >
    % ECHO tmp$
    EXITM tmp$
ENDM

ISSPACENOT MACRO x:REQ      ; (x != 20h)
    LOCAL tmp$
    tmp$ TEXTEQU <(x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 20h) >    
    % ECHO tmp$
    EXITM tmp$
ENDM

ISCRLF MACRO x:REQ          ; (x == 0Ah || x == 0Dh)
    LOCAL tmp$
    tmp$ TEXTEQU <(x == 0Ah || x == 0Dh) >
    % ECHO tmp$
    EXITM tmp$    
ENDM

ISCRLFNOT MACRO x:REQ       ; (x != 0Ah && x != 0Dh)
    LOCAL tmp$
    tmp$ TEXTEQU <(x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 0Ah && x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 0Dh) >
    % ECHO tmp$
    EXITM tmp$    
ENDM

ISWHITESPACE MACRO x:REQ    ; (x == 20h || ( x >= 09h && x <= 0Dh ))
    LOCAL tmp$
    tmp$ TEXTEQU <(x>
    tmp$ CATSTR tmp$, < == 20h || >
    tmp$ CATSTR tmp$, <(x >
    tmp$ CATSTR tmp$, <!>>
    tmp$ CATSTR tmp$, <= 09h >
    tmp$ CATSTR tmp$, <&& >
    tmp$ CATSTR tmp$, <x >
    tmp$ CATSTR tmp$, <!<>
    tmp$ CATSTR tmp$, <= 0Dh)) >
    % ECHO tmp$
    EXITM tmp$
ENDM

ISWHITESPACENOT MACRO x:REQ ; (x != 20h && x != 09h && x != 0Ah && x != 0Bh && x != 0Ch && x != 0Dh)
    LOCAL tmp$
    tmp$ TEXTEQU <(x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 20h && >
    tmp$ CATSTR tmp$, <x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 09h && >
    tmp$ CATSTR tmp$, <x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 0Ah && >
    tmp$ CATSTR tmp$, <x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 0Bh && >
    tmp$ CATSTR tmp$, <x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 0Ch && >
    tmp$ CATSTR tmp$, <x >
    tmp$ CATSTR tmp$, <!!>
    tmp$ CATSTR tmp$, <= 0Dh) >
    % ECHO tmp$
    EXITM tmp$
ENDM
;==============================================================================


;------------------------------------------------------------------------------
; Prototypes
;------------------------------------------------------------------------------
;DrawHTMLCODE Functions:
_HTMLCODE_GetToken      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; lpszString, dwSize, dwTokenLength, dwWhiteSpace, lpTagInfo
_HTMLCODE_QUOTE         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hdc, hFont, lplpszStart, lpNewCount, dwTokenLength, lpRect, dwTagType
_HTMLCODE_PRE           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hdc, hFont, lplpszStart, lpNewCount, dwTokenLength, lpRect, dwTagType
_HTMLCODE_ALINK         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hdc, hFont, lplpszStart, lpNewCount, lpdwTokenLength, lpRect, dwXPos, lpHyperlink
_HTMLCODE_COLOR         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hdc, dwTag, lpszStart, lpColorStack, lpdwColorStackTop
_HTMLCODE_FONT          PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hdc, dwTag, lpszStart, lpColorStack, lpdwColorStackTop
_HTMLCODE_HR            PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD         ; hdc, dwLeft, dwTop, dwHeight, dwMaxWidth, dwLineHeight
_HTMLCODE_LIST          PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hdc, hFont, lpListStack, lpListLevel, dwTag 
_HTMLCODE_LISTITEM      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD         ; hdc, hFont, lpListStack, lpListLevel, lpRect, dwNewFormat
_HTMLCODE_LinkUrlTitle  PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; lpszHrefString, dwHrefStringLength, lpszUrl, lpszTitle


; DrawBBCODE Functions:
_BBCODE_GetToken        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; lpszString, dwSize, dwTokenLength, dwWhiteSpace, lpTagInfo
_BBCODE_CODE            PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD         ; hdc, hFont, lplpszStart, lpNewCount, dwTokenLength, lpRect
_BBCODE_QUOTE           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hdc, hFont, lplpszStart, lpNewCount, dwTokenLength, lpRect, dwTagType
_BBCODE_COLOR           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hdc, dwTag, lpszStart, lpColorStack, lpdwColorStackTop
_BBCODE_LIST            PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hdc, hFont, lpListStack, lpListLevel, dwTag 
_BBCODE_LISTITEM        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD         ; hdc, hFont, lpListStack, lpListLevel, lpRect, dwNewFormat
_BBCODE_URL             PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hdc, hFont, lplpszStart, lpNewCount, lpdwTokenLength, lpRect, dwXPos, lpHyperlink
_BBCODE_LinkUrlTitle    PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; lpszHrefString, dwHrefStringLength, lpszUrl, lpszTitle


; Utility Functions:
GetTagContents          PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; lpszString, dwSize, dwTokenLength, dwType, dwTagBracket
GetFontVariant          PROTO :DWORD,:DWORD,:DWORD                              ; hdc, hfontSource, Styles
ColorStackPush          PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hdc, clr, lpStack, lpdwStackTop
ColorStackPop           PROTO :DWORD,:DWORD,:DWORD                              ; hdc, lpStack lpdwStackTop
ParseColor              PROTO :DWORD                                            ; String
HexDigit                PROTO :DWORD                                            ; lpCharHex
ListStackPush           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; dwListType, dwItemIndent, dwBulletIndent, lpStack, lpdwStackTop
ListStackPop            PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; lpdwListType, lpdwItemIndent, lpdwBulletIndent, lpStack, lpdwStackTop
ListStackPeek           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; lpdwListType, lpdwItemIndent, lpdwBulletIndent, lpStack, dwStackTop
ListStackSetCounter     PROTO :DWORD,:DWORD,:DWORD                              ; dwValue, lpStack, dwStackTop
szCatStrToWide          PROTO :DWORD,:DWORD                                     ; lpszWideDest, lpszSource


DrawTextEXTLinkCreate   PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hWndParent, dwXpos, dwYpos, dwWidth, dwHeight
DrawTextEXTLinkProc     PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hWin, uMsg, wParam, lParam
DrawTextEXTLinkPaint    PROTO :DWORD                                            ; hWin
DrawTextEXTLinkAddUrl   PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hWin, lpRect, lpszLinkUrl, lpszLinkTitle
DrawTextEXTLinkReset    PROTO :DWORD                                            ; hWin
DrawTextEXTLinkClick    PROTO :DWORD                                            ; hWin
DrawTextEXTLinkReady    PROTO :DWORD                                            ; hWin
DrawTextEXTLinkItem     PROTO :DWORD                                            ; hWin
DrawTextEXTLinkNotify   PROTO :DWORD,:DWORD                                     ; hWin, dwNotifyCode

.CONST
;------------------------------------------------------------------------------
; Constants
;------------------------------------------------------------------------------
LIST_INDENT             EQU 6   ; (6 x width of space char)
LIST_INDENT_BULLET      EQU 3   ; Bullet indent is calced as width of space char x ( current listindent value - LIST_INDENT_BULLET)
PRE_INDENT              EQU 6   ; Code/Pre indent from left right of fillrect
QUOTE_INDENT            EQU 6   ; Quote indent from left and right
HR_INDENT               EQU 0   ; horizontal rule ident from left and right

LISTSTACK_SIZE          EQU 6   ; Max list stack level = max nested depth of lists
COLORSTACK_SIZE         EQU 32  ; Max color stack level
LINKURL_SIZE            EQU 16  ; Max link urls in array 



;---------------------------------------
; DrawTextEXTLink properties:
;---------------------------------------
DTEL_MOUSEOVER          EQU 0   ; TRUE/FALSE for mouse over status
DTEL_ENABLEDSTATE       EQU 4   ; TRUE/FALSE for enabled state
DTEL_UPDATEFLAG         EQU 8   ; - Not used currently
DTEL_LINKURLSTOTAL      EQU 12  ; DWORD dwTotalLinkUrls
DTEL_LINKURLSARRAY      EQU 16  ; DWORD ptrLinkUrlArray
DTEL_FONTNORMAL         EQU 20  ; hFont for normal text when mouse over status is FALSE
DTEL_FONTUNDERLINE      EQU 24  ; hFont for underline text when mouse over status is TRUE
DTEL_BACKCOLOR          EQU 28  ; COLORREF for back color of link title text 
DTEL_TEXTCOLOR          EQU 32  ; COLORREF for text color of link title text


;---------------------------------------
; tTOKEN Token flags returned:
;---------------------------------------
ENDFLAG                 EQU 100h
tNONE                   EQU 0 
tB                      EQU 1 
tBR                     EQU 2
tFONT                   EQU 3 
tI                      EQU 4 
tP                      EQU 5 
tSUB                    EQU 6 
tSUP                    EQU 7 
tU                      EQU 8 
tCOLOR                  EQU 10
tPRE                    EQU 11
tCODE                   EQU 12
tQUOTE1                 EQU 13
tQUOTE2                 EQU 14
tQUOTE3                 EQU 15
tLIST                   EQU 16
tLISTO                  EQU 17
tLISTITEM               EQU 18
tHR                     EQU 19
tALINK                  EQU 20
tTAB                    EQU 21
tCMNT                   EQU 22

;---------------------------------------
; GetTagContents dwType:
;---------------------------------------
GETTAG_PRE              EQU 0   ; To fetch <pre> to </pre> tag contents
GETTAG_CODE             EQU 1   ; To fetch <code> to </code> or [code] to [/code] tag contents
GETTAG_Q                EQU 2   ; To fetch <q> to </q> or [q] to [/q] tag contents
GETTAG_QUOTE            EQU 3   ; To fetch <quote> to </quote> or [quote] to [/quote] tag contents
GETTAG_BLOCKQ           EQU 4   ; To fetch <blockq> to </blockq> tag contents
GETTAG_ALINK            EQU 5   ; To fetch <a to </a> tag contents
GETTAG_URL              EQU 6   ; To fetch [url] to [/url] tag contents
GETTAG_MAX              EQU GETTAG_URL

;---------------------------------------
; GetTagContents dwTagBracket:
;---------------------------------------
GETTAG_BRACKET_ANGLE    EQU 0   ; <> brackets
GETTAG_BRACKET_SQUARE   EQU 1   ; [] brackets

;---------------------------------------
; Font Flags:
;---------------------------------------
FV_NORMAL               EQU 00h
FV_BOLD                 EQU 01h
FV_ITALIC               EQU (FV_BOLD shl 1)
FV_UNDERLINE            EQU (FV_ITALIC shl 1)
FV_SUPERSCRIPT          EQU (FV_UNDERLINE shl 1)
FV_SUBSCRIPT            EQU (FV_SUPERSCRIPT shl 1)
FV_PRE                  EQU (FV_SUBSCRIPT shl 1)
FV_QUOTE                EQU (FV_PRE shl 1)
FV_ALINK                EQU (FV_QUOTE shl 1)
FV_NUMBER               EQU (FV_ALINK shl 1)

;------------------------------------------------------------------------------
; Structures
;------------------------------------------------------------------------------

;---------------------------------------
; Stores url link information
;---------------------------------------
IFNDEF LINKURL
LINKURL                 STRUCT
    rcLinkUrl           RECT <0,0,0,0>
    szLinkUrl           DB LINKURL_MAXLENGTH DUP (0)
    szLinkTitle         DB LINKURL_MAXLENGTH DUP (0)
LINKURL                 ENDS
ENDIF

;---------------------------------------
; Notification for DrawTextEXTLink
;---------------------------------------
IFNDEF NM_DTEL
NM_DTEL                 STRUCT
    hdr                 NMHDR <>
    item                LINKURL <>
NM_DTEL                 ENDS
ENDIF


;---------------------------------------
; For list items using the list stack
;---------------------------------------
LISTINFO                STRUCT
    ListType            DD 0    ; <ul> == 0, <ol> >= 1 (acts as number counter as well for <ol>)
    ItemIndent          DD 0    ; xpos indent for list item text
    BulletIndent        DD 0    ; xpos indent for bullet symbol
LISTINFO                ENDS

;---------------------------------------
; For tags <x>, </x> or [x], [/x]
;---------------------------------------
TAG                     STRUCT
    mnemonic            DB 8 DUP (0) ; ascii of tag (without brackets etc)
    token               DD 0    ; constant tTOKEN to return
    param               DD 0    ; does it take a parameter
    block               DD 0    ; block mode
TAG                     ENDS

;---------------------------------------
; For handling more than one tag type
;---------------------------------------
TAGINFO                 STRUCT
    TagList             DD 0    ; pointer to array of tag
    TagCount            DD 0    ; count of tags in tag list
    TagOpen             DB 0    ; delimiter for tag open: <, [, etc
    TagClose            DB 0    ; delimiter for tag close: >, ], ect
TAGINFO                 ENDS

.DATA
ALIGN 16
;------------------------------------------------------------------------------
; Initialized Data
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; TAG Structure:            Mnemonic    Token       P   B     Notes
;------------------------------------------------------------------------------
HTMLCODE_TAGS           TAG <<0>,       tNONE,      0,  0>  ; -
                        TAG <"b",       tB,         0,  0>  ; Bold
                        TAG <"br",      tBR,        0,  1>  ; Line Break
                        TAG <"em",      tI,         0,  0>  ; Italic
                        TAG <"font",    tFONT,      1,  0>  ; Font color='#FEDCBA'
                        TAG <"i",       tI,         0,  0>  ; Italic
                        TAG <"p",       tP,         0,  1>  ; Paragraph
                        TAG <"strong",  tB,         0,  0>  ; Bold
                        TAG <"sub",     tSUB,       0,  0>  ; Subscript
                        TAG <"sup",     tSUP,       0,  0>  ; Superscript
                        TAG <"u",       tU,         0,  0>  ; Underline
                        TAG <"pre",     tPRE,       0,  1>  ; Preformatted code
                        TAG <"code",    tCODE,      0,  1>  ; Preformatted code
                        TAG <"color",   tCOLOR,     1,  0>  ; Color='#FEDCBA'
                        TAG <"q",       tQUOTE1,    0,  1>  ; Quote
                        TAG <"quote",   tQUOTE2,    0,  1>  ; Quote
                        TAG <"blockq",  tQUOTE3,    0,  1>  ; Quote
                        TAG <"ul",      tLIST,      0,  1>  ; Unordered list with bullets
                        TAG <"ol",      tLISTO,     0,  1>  ; Ordered list with numbers
                        TAG <"li",      tLISTITEM,  0,  1>  ; List item
                        TAG <"hr",      tHR,        0,  1>  ; Horizontal line
                        TAG <"a",       tALINK,     1,  0>  ; Url link
                        TAG <"!",       tCMNT,      1,  0>  ; cnmt 
HTMLCODE_TAGCOUNT       EQU 23
HTMLCODE_TAGINFO        TAGINFO <Offset HTMLCODE_TAGS, HTMLCODE_TAGCOUNT, "<", ">">

;------------------------------------------------------------------------------
; TAG Structure:            Mnemonic    Token       P   B     Notes
;------------------------------------------------------------------------------
BBCODE_TAGS             TAG <<0>,       tNONE,      0,  0>  ; -
                        TAG <"b",       tB,         0,  0>  ; Bold
                        TAG <"i",       tI,         0,  0>  ; Italic
                        TAG <"u",       tU,         0,  0>  ; Underline
                        TAG <"color",   tCOLOR,     1,  0>  ; Color='#FEDCBA'
                        TAG <"code",    tCODE,      0,  1>  ; Preformatted code
                        TAG <"q",       tQUOTE1,    0,  1>  ; Quote
                        TAG <"quote",   tQUOTE2,    0,  1>  ; Quote
                        TAG <"ul",      tLIST,      0,  1>  ; Unordered list with bullets
                        TAG <"list",    tLIST,      0,  1>  ; Unordered list with bullets
                        TAG <"ol",      tLISTO,     0,  1>  ; Ordered list with numbers
                        TAG <"li",      tLISTITEM,  0,  1>  ; List item
                        TAG <"*",       tLISTITEM,  0,  1>  ; List item
                        TAG <"url",     tALINK,     1,  0>  ; Url link
                        TAG <"comment", tCMNT,      1,  0>  ; cnmt 
BBCODE_TAGCOUNT         EQU 15
BBCODE_TAGINFO          TAGINFO <Offset BBCODE_TAGS, BBCODE_TAGCOUNT, "[", "]">
;------------------------------------------------------------------------------


;---------------------------------------
; Some Strings:
;---------------------------------------
ALIGN 4
szTxtExtentTest         DB "Åy",0           ; Used for getting height width of chars
szColorEquTag           DB "color=",0       ; Used for checking param of font tag 
szSpace                 DB " ",0            ; Used for getting width of space char
szFullstop              DB ".",0            ; Used for ordered number list items
szPreFont               DB "Courier New",0  ; Preformatted/Code font
szPreTag                DB "pre",0          ; Used for getting content between pre tags
szCodeTag               DB "code",0         ; Used for getting content between code tags
szQuoteTag1             DB "q",0            ; Used for getting content between q tags
szQuoteTag2             DB "quote",0        ; Used for getting content between quote tags
szQuoteTag3             DB "blockq",0       ; Used for getting content between blockq tags
szAlinkTag              DB "a",0            ; Used for getting content between a tags
szHRefTag               DB "href=",0        ; href="url">
szUrlTag                DB "url",0          ; url
szDrawTextEXTLinkClass  DB "DTELink",0      ; class for hyperlink window
szDTELinkOpen           DB "open",0         ; Open in new tab in existing browser
szDTELinkNew            DB "new",0          ; New browser
DTELinkID               DD 65535            ; Resource ID for hyperlink, dec on each control
DTELNM                  NM_DTEL <>          ; Notification data passed via WM_NOTIFY

;---------------------------------------
; Unicode Symbol Strings:
;---------------------------------------
ALIGN 4
szDblQuoteOpenW         DB 1Ch,20h,0h,0h    ; " Curly Double Quote Open
szDblQuoteCloseW        DB 1Dh,20h,0h,0h    ; " Curly Double Quote Close
szBulletSymbolW         DB 22h,20h,0h,0h    ; . Bullet Symbol
szWhiteBulletSymbolW    DB 0E6h,25h,0h,0h   ; . White bullet
szTriangleBulletSymbolW DB 23h,20h,0h,0h    ; . Triangle bullet



.CODE


ALIGN 16


;==============================================================================
; DrawTextEXT
;==============================================================================
DrawTextEXT PROC hdc:DWORD, lpString:DWORD, nCount:DWORD, lpRect:DWORD, uFormat:DWORD, lpHyperlink:DWORD, dwCodeType:DWORD
    mov eax, dwCodeType
    .IF eax == 0
        Invoke DrawHTMLCODE, hdc, lpString, nCount, lpRect, uFormat, lpHyperlink
    .ELSE
        Invoke DrawBBCODE, hdc, lpString, nCount, lpRect, uFormat, lpHyperlink
    .ENDIF
    ret
DrawTextEXT ENDP



;==============================================================================
; DrawHTMLCODE Functions
;==============================================================================


;------------------------------------------------------------------------------
; Draws text within the bounding rect and processes text for tags to change 
; font features (bold, italic, underline, etc), font color, line and paragraph 
; breaks. Calls _HTMLCODE_GetToken to retrieve next word/token to paint until 
; no more words/tokens.
; 
; Returns in eax height of text drawn similar to DrawText
;------------------------------------------------------------------------------
DrawHTMLCODE PROC USES EBX ECX EDX hdc:DWORD, lpString:DWORD, nCount:DWORD, lpRect:DWORD, uFormat:DWORD, lpHyperlink:DWORD
    LOCAL lpszStart:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nRight:DWORD
    LOCAL nBottom:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL nMinWidth:DWORD
    LOCAL nHeight:DWORD
    LOCAL SavedDC:DWORD
    LOCAL Tag:DWORD
    LOCAL TagPrevious:DWORD
    LOCAL nTokenLength:DWORD
    LOCAL hfontBase:DWORD
    LOCAL Styles:DWORD
    LOCAL CurStyles:DWORD
    LOCAL nIndex:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nWidthOfSpace:DWORD
    LOCAL XPos:DWORD
    LOCAL bWhiteSpace:DWORD
    LOCAL NewFormat:DWORD
    LOCAL NewCount:DWORD
    LOCAL SavedStyle:DWORD
    LOCAL SavedColor:DWORD
    LOCAL SavedBkColor:DWORD
    LOCAL ColorStackTop:DWORD
    LOCAL ListLevel:DWORD
    LOCAL dwListIndent:DWORD
    LOCAL dwListItemMode:DWORD
    LOCAL dwBulletIndent:DWORD
    LOCAL hDTELink:DWORD
    LOCAL hDTELinkParent:DWORD  
    LOCAL rect:RECT
    LOCAL nSize:POINT
    LOCAL hfontSpecial[FV_NUMBER]:DWORD
    LOCAL ColorStack[COLORSTACK_SIZE]:COLORREF
    LOCAL ListStack[LISTSTACK_SIZE]:LISTINFO

    ;PrintText 'DrawHTMLCODE'
    .IF hdc == NULL || lpString == NULL
        mov eax, 0
        ret
    .ENDIF
    
    .IF SDWORD ptr nCount < 0
        Invoke szLen, lpString
    .ELSE
        mov eax, nCount
    .ENDIF
    mov NewCount, eax

    .IF lpRect != NULL
        Invoke CopyRect, Addr rect, lpRect
        mov eax, rect.left
        mov nLeft, eax
        mov eax, rect.top
        mov nTop, eax
        mov eax, rect.right
        mov nRight, eax
        mov eax, nRight
        sub eax, nLeft
        mov nMaxWidth, eax
        mov eax, rect.bottom
        mov nBottom, eax
    .ELSE
        Invoke GetCurrentPositionEx, hdc, Addr nSize
        mov eax, nSize.x
        mov nLeft, eax
        mov eax, nSize.y
        mov nTop, eax
        Invoke GetDeviceCaps, hdc, HORZRES
        mov ebx, nLeft
        sub eax, ebx
        mov nMaxWidth, eax
    .ENDIF
    
    .IF SDWORD ptr nMaxWidth < 0
        mov nMaxWidth, 0
    .ENDIF

    ; toggle flags we do not support
    mov eax, uFormat
    and eax, (-1 xor (DT_CENTER or DT_RIGHT or DT_TABSTOP))
    or eax, (DT_LEFT or DT_NOPREFIX)
    mov NewFormat, eax

    ; get the "default" font from the DC
    Invoke SaveDC, hdc
    mov SavedDC, eax
    
    Invoke GetStockObject, SYSTEM_FONT
    Invoke SelectObject, hdc, eax
    mov hfontBase, eax
    Invoke SelectObject, hdc, hfontBase
    lea ebx, hfontSpecial
    mov nIndex, 0
    mov eax, 0
    .WHILE eax < FV_NUMBER
        mov dword ptr [ebx+eax*DWORD], 0
        inc nIndex
        mov eax, nIndex
    .ENDW
    mov dword ptr [ebx], 0
    
    ; get font height (use characters with ascender and descender);
    ; we make the assumption here that changing the font style will
    ; not change the font height
    Invoke GetTextExtentPoint32, hdc, Addr szTxtExtentTest, 2, Addr nSize
    mov eax, nSize.y
    mov nLineHeight, eax
    mov Styles, 0 ; assume the active font is normal weight, roman, non-underlined
    mov XPos, 0
    mov nMinWidth, 0
    mov CurStyles, -1 ; force a select of the proper style
    mov nHeight, 0
    mov bWhiteSpace, FALSE
    mov ColorStackTop, 0
    mov TagPrevious, 0
    mov ListLevel, 0

    Invoke RtlZeroMemory, Addr ColorStack, SIZEOF ColorStack
    Invoke RtlZeroMemory, Addr ListStack, SIZEOF ListStack

    Invoke WindowFromDC, hdc
    mov hDTELinkParent, eax
    .IF lpHyperlink != NULL
        mov ebx, lpHyperlink
        mov eax, [ebx]
        mov hDTELink, eax
    .ENDIF
    Invoke IsWindow, hDTELink
    .IF hDTELink != NULL && eax != FALSE ; Already exists, make sure its sized to fit our area
        IFDEF DEBUG32
            PrintText 'HYPERLINKS ALREADY EXISTS OK'
        ENDIF         
        ;PrintText 'Already Exists'
        ;Invoke SetWindowLong, hDTELink, DTEL_ENABLEDSTATE, FALSE ; disable while we add links
        mov eax, nRight
        add eax, nLeft
        add eax, nLeft
        mov ebx, nBottom
        add ebx, nTop
        add ebx, nTop
        ;Invoke SetWindowPos, hDTELink, NULL, 0, 0, eax, ebx, SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE
        Invoke DrawTextEXTLinkReset, hDTELink
    .ELSE ; create hyperlink window
        mov eax, nRight
        add eax, nLeft
        add eax, nLeft
        mov ebx, nBottom
        add ebx, nTop
        add ebx, nTop
        .IF lpHyperlink != NULL
            Invoke DrawTextEXTLinkCreate, hDTELinkParent, 0, 0, eax, ebx
            .IF eax != NULL
                mov hDTELink, eax
                mov ebx, lpHyperlink
                mov [ebx], eax
                IFDEF DEBUG32
                    PrintText 'HYPERLINKS OK'
                ENDIF                   
            .ELSE
                mov hDTELink, 0
                IFDEF DEBUG32
                    PrintText 'FAILED TO CREATE HYPERLINK - NO LINK URLS'
                ENDIF                
            .ENDIF
        .ELSE
            mov hDTELink, 0
            IFDEF DEBUG32
                PrintText 'HYPERLINK IS NOT SET - NO LINK URLS'
            ENDIF
        .ENDIF
    .ENDIF

    ; TODO - check if text has no tags, if none then pass onto DrawText the entire lot
    
    mov eax, lpString
    mov lpszStart, eax

    .WHILE TRUE
        Invoke _HTMLCODE_GetToken, Addr lpszStart, Addr NewCount, Addr nTokenLength, Addr bWhiteSpace, Addr HTMLCODE_TAGINFO
        mov Tag, eax

        .IF SDWORD ptr eax < 0
            .BREAK
        .ENDIF
        
        mov eax, Tag
        and eax, (-1 xor ENDFLAG)

        ;------------------------------------------------------------------
        .IF eax == tP
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <p>
                mov eax, NewFormat
                and eax, DT_SINGLELINE
                .IF eax != DT_SINGLELINE
                    mov eax, lpszStart
                    .IF eax != lpString
                        xor edx, edx
                        mov eax, 3
                        mov ebx, nLineHeight
                        mul ebx
                        mov ecx, 2
                        div ecx
                        add nHeight, eax
                    .ENDIF
                    mov XPos, 0
                .ENDIF
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tPRE
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <pre>
                .IF TagPrevious != (tPRE or ENDFLAG)
                    mov eax, nLineHeight
                    add nHeight, eax
                .ENDIF

                mov eax, Styles
                mov SavedStyle, eax
                Invoke GetTextColor, hdc
                mov SavedColor, eax
                Invoke GetBkColor, hdc
                mov SavedBkColor, eax
                
                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nMaxWidth
                mov rect.right, eax
                lea eax, nHeight
                mov rect.bottom, eax
                
                Invoke _HTMLCODE_PRE, hdc, hfontBase, Addr lpszStart, Addr NewCount, nTokenLength, Addr rect, GETTAG_PRE
                mov nSize.x, eax

            .ELSE ; </pre>
                mov eax, SavedStyle
                mov Styles, eax
                mov eax, SavedColor
                Invoke SetTextColor, hdc, eax
                mov eax, SavedBkColor
                Invoke SetBkColor, hdc, eax
            .ENDIF
            mov XPos, 0
            
        ;------------------------------------------------------------------
        .ELSEIF eax == tCODE
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <code>
                .IF TagPrevious != (tCODE or ENDFLAG)
                    mov eax, nLineHeight
                    add nHeight, eax
                .ENDIF

                mov eax, Styles
                mov SavedStyle, eax
                Invoke GetTextColor, hdc
                mov SavedColor, eax
                Invoke GetBkColor, hdc
                mov SavedBkColor, eax

                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nMaxWidth
                mov rect.right, eax
                lea eax, nHeight
                mov rect.bottom, eax
                
                Invoke _HTMLCODE_PRE, hdc, hfontBase, Addr lpszStart, Addr NewCount, nTokenLength, Addr rect, GETTAG_CODE
                ;mov XPos, eax
                ;mov nSize.x, eax

            .ELSE ; </code>
                mov eax, SavedStyle
                mov Styles, eax
                mov eax, SavedColor
                Invoke SetTextColor, hdc, eax
                mov eax, SavedBkColor
                Invoke SetBkColor, hdc, eax
            .ENDIF
            mov XPos, 0

        ;------------------------------------------------------------------
        .ELSEIF eax == tQUOTE1 || eax == tQUOTE2 || eax == tQUOTE3
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <q>, <quote> or <blockq>
                mov eax, Styles
                mov SavedStyle, eax
                Invoke GetTextColor, hdc
                mov SavedColor, eax
                Invoke GetBkColor, hdc
                mov SavedBkColor, eax

                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nMaxWidth
                mov rect.right, eax
                lea eax, nHeight
                mov rect.bottom, eax                
                
                Invoke _HTMLCODE_QUOTE, hdc, hfontBase, Addr lpszStart, Addr NewCount, nTokenLength, Addr rect, Tag

            .ELSE ; </q>, </quote> or </blockq>
                mov eax, SavedStyle
                mov Styles, eax
                mov eax, SavedColor
                Invoke SetTextColor, hdc, eax
                mov eax, SavedBkColor
                Invoke SetBkColor, hdc, eax
            .ENDIF
            mov XPos, 0

        ;------------------------------------------------------------------
        .ELSEIF eax == tALINK
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <a href="">text

                mov eax, Styles
                mov SavedStyle, eax
                Invoke GetTextColor, hdc
                mov SavedColor, eax
                Invoke GetBkColor, hdc
                mov SavedBkColor, eax

                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nHeight
                mov rect.bottom, eax                
                
                Invoke _HTMLCODE_ALINK, hdc, hfontBase, Addr lpszStart, Addr NewCount, Addr nTokenLength, Addr rect, XPos, hDTELink
                add XPos, eax

            .ELSE ; </a>
                mov eax, SavedStyle
                mov Styles, eax
                mov eax, SavedColor
                Invoke SetTextColor, hdc, eax
                mov eax, SavedBkColor
                Invoke SetBkColor, hdc, eax
                Invoke SelectObject, hdc, hfontBase
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tLIST || eax == tLISTO ; unordered list or orderded list
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <ul> or <ol>
            
                Invoke _HTMLCODE_LIST, hdc, hfontBase, Addr ListStack, Addr ListLevel, Tag
                
                mov eax, NewFormat
                and eax, DT_SINGLELINE
                .IF eax != DT_SINGLELINE
                    .IF ListLevel < 2
                        mov eax, nLineHeight
                        shr eax, 1
                        add eax, 2
                        add nHeight, eax
                    .ENDIF
                    mov XPos, 0
                .ENDIF                

            .ELSE ; </ul> or <ol>
                ;Invoke ListStackPop, Addr dwListType, Addr dwListIndent, Addr dwListBulletIndent, Addr ListStack, Addr ListLevel
                Invoke ListStackPop, NULL, NULL, NULL, Addr ListStack, Addr ListLevel
                .IF Tag == tLISTO
                    Invoke ListStackSetCounter, 1, Addr ListStack, ListLevel
                .ENDIF
                ;mov dwListCounter, 1
                Invoke SelectObject, hdc, hfontBase
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tLISTITEM && ListLevel > 0
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <li>
                
                mov dwListItemMode, 1
                
                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nMaxWidth
                mov rect.right, eax
                lea eax, nHeight
                mov rect.bottom, eax
                
                Invoke _HTMLCODE_LISTITEM, hdc, hfontBase, Addr ListStack, ListLevel, Addr rect, NewFormat
                mov XPos, eax

            .ELSE ; </li>
                mov dwListItemMode, 0
                Invoke SelectObject, hdc, hfontBase
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tHR
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <hr>
                mov eax, NewFormat
                and eax, DT_SINGLELINE
                .IF eax != DT_SINGLELINE
                    mov eax, nLineHeight
                    sub eax, 2
                    add nHeight, eax
                    mov XPos, 0
                    Invoke _HTMLCODE_HR, hdc, nLeft, nTop, nHeight, nMaxWidth, nLineHeight
                    mov eax, nLineHeight
                    sub eax, 2
                    add nHeight, eax
                    mov XPos, 0                    
                .ENDIF                
                ;Invoke _HTMLCODE_HR, hdc, nLeft, nTop, nHeight, nMaxWidth, nLineHeight
            .ENDIF            

        ;------------------------------------------------------------------
        .ELSEIF eax == tBR
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <br>
                Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
                mov eax, nSize.y
                mov nLineHeight, eax              

                mov eax, NewFormat
                and eax, DT_SINGLELINE
                .IF eax != DT_SINGLELINE
                    mov eax, nLineHeight
                    add eax, 2d
                    add nHeight, eax
                    mov XPos, 0
                .ENDIF
                Invoke SelectObject, hdc, hfontBase
            .ENDIF
            mov nSize.x, 0

        ;------------------------------------------------------------------
        .ELSEIF eax == tB
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; </b>
                and Styles, (-1 xor FV_BOLD)
            .ELSE ; <b>
                or Styles, FV_BOLD
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tI
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; </i>
                and Styles, (-1 xor FV_ITALIC)
            .ELSE ; <i>
                or Styles, FV_ITALIC
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tU
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; </u>
                and Styles, (-1 xor FV_UNDERLINE)
            .ELSE ; <u>
                or Styles, FV_UNDERLINE
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tSUB
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; </sub>
                and Styles, (-1 xor FV_SUBSCRIPT)
            .ELSE ; <sub>
                or Styles, FV_SUBSCRIPT
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tSUP
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; </sup>
                and Styles, (-1 xor FV_SUPERSCRIPT)
            .ELSE ; <sup>
                or Styles, FV_SUPERSCRIPT
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tCOLOR
            Invoke _HTMLCODE_COLOR, hdc, Tag, lpszStart, Addr ColorStack, Addr ColorStackTop

        ;------------------------------------------------------------------
        .ELSEIF eax == tFONT
            Invoke _HTMLCODE_FONT, hdc, Tag, lpszStart, Addr ColorStack, Addr ColorStackTop

        .ELSEIF eax == tCMNT

        ;------------------------------------------------------------------
        .ELSE ; Default

            mov eax, Tag
            and eax, (tNONE or ENDFLAG)
            .IF eax == ENDFLAG ; Nothing to draw, just skip end tag and continue
                
                ; Goto update current position for next word/token and loop again
                
            .ELSE ; otherwise we assume it was a word (or an unknown tag) to draw

                ;----------------------------------------------------------
                ; Start of the drawing text with font styles
                ;----------------------------------------------------------
                mov eax, CurStyles
                .IF eax != Styles
                    lea ebx, hfontSpecial
                    mov ecx, Styles
                    mov eax, dword ptr [ebx+ecx*DWORD]
                    .IF eax == NULL
                        Invoke GetFontVariant, hdc, hfontBase, Styles
                        lea ebx, hfontSpecial
                        mov ecx, Styles
                        mov dword ptr [ebx+ecx*DWORD], eax
                    .ENDIF
                    mov eax, Styles
                    mov CurStyles, eax
                    lea ebx, hfontSpecial
                    mov ecx, Styles
                    mov eax, dword ptr [ebx+ecx*DWORD]
                    Invoke SelectObject, hdc, eax
                    ; get the width of a space character (for word spacing)
                    Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
                    mov eax, nSize.x
                    mov nWidthOfSpace, eax
                    mov eax, nSize.y
                    mov nLineHeight, eax                    
                .ENDIF

                ;----------------------------------------------------------
                ; Check word length, check whether to wrap around
                ;----------------------------------------------------------
                Invoke GetTextExtentPoint32, hdc, lpszStart, nTokenLength, Addr nSize
                mov eax, nSize.x
                .IF eax > nMaxWidth
                    mov nMaxWidth, eax ; must increase width: long non-breakable word
                .ENDIF
                .IF bWhiteSpace == TRUE
                    mov eax, nWidthOfSpace
                    add XPos, eax
                .ENDIF
                
                .IF dwListItemMode == 1 
                    Invoke ListStackPeek, NULL, Addr dwListIndent, Addr dwBulletIndent, Addr ListStack, ListLevel
                    mov eax, XPos
                    add eax, dwListIndent
                    sub eax, dwBulletIndent
                    add eax, nSize.x
                .ELSE
                    mov eax, XPos
                    add eax, nSize.x
                .ENDIF
                .IF eax > nMaxWidth && bWhiteSpace == TRUE
                    mov eax, uFormat
                    and eax, DT_WORDBREAK
                    .IF eax == DT_WORDBREAK
                        .IF dwListItemMode == 1
                            Invoke ListStackPeek, NULL, Addr dwListIndent, NULL, Addr ListStack, ListLevel
                            ; word wrap
                            mov eax, nLineHeight
                            add eax, 2d
                            add nHeight, eax
                            mov eax, dwListIndent
                            ;add eax, nWidthOfSpace ; for some reason needs extra space for indent?, not sure why?
                            mov XPos, eax
                        .ELSE
                            ; word wrap
                            mov eax, nLineHeight
                            ;add eax, 2d
                            add nHeight, eax
                            mov XPos, 0
                        .ENDIF
                    .ELSE
                        ; no word wrap, must increase the width
                        mov eax, XPos
                        add eax, nSize.x
                        mov nMaxWidth, eax
                    .ENDIF
                .ENDIF

                ;----------------------------------------------------------
                ; Output text (unless DT_CALCRECT is set)
                ;----------------------------------------------------------
                mov eax, uFormat
                and eax, DT_CALCRECT
                .IF eax == 0
                    ; handle negative heights, too (suggestion of "Sims")
                    mov eax, nTop
                    .IF sdword ptr eax < 0
                        mov eax, nLeft
                        add eax, XPos
                        mov rect.left, eax
                        mov eax, nTop
                        sub eax, nHeight
                        mov rect.top, eax
                        mov eax, nLeft
                        add eax, nMaxWidth
                        mov rect.right, eax
                        mov eax, nTop
                        mov ebx, nHeight
                        add ebx, nLineHeight
                        sub eax, ebx
                        mov rect.bottom, eax
                    .ELSE
                        mov eax, nLeft
                        add eax, XPos
                        mov rect.left, eax
                        mov eax, nTop
                        add eax, nHeight
                        mov rect.top, eax
                        mov eax, nLeft
                        add eax, nMaxWidth
                        mov rect.right, eax
                        mov eax, nTop
                        add eax, nHeight
                        add eax, nLineHeight
                        mov rect.bottom, eax                
                    .ENDIF
                    
                    ; Reposition subscript text to align below the baseline
                    mov eax, Styles
                    and eax, FV_SUBSCRIPT
                    .IF eax == FV_SUBSCRIPT
                        mov eax, NewFormat
                        or eax, DT_BOTTOM or DT_SINGLELINE
                        mov NewFormat, eax
                    .ENDIF

                    Invoke DrawText, hdc, lpszStart, nTokenLength, Addr rect, NewFormat

                    ;----------------------------------------------------------
                    ; Check if underline style is used. For the underline style
                    ; the spaces between words should be underlined as well
                    ;----------------------------------------------------------
                    mov eax, Styles
                    and eax, FV_UNDERLINE
                    mov ebx, XPos
                    .IF (bWhiteSpace == TRUE) && (eax == FV_UNDERLINE) && (ebx >= nWidthOfSpace)
                        mov eax, nTop
                        .IF sdword ptr eax < 0
                            mov eax, nLeft
                            add eax, XPos
                            sub eax, nWidthOfSpace
                            mov rect.left, eax
                            mov eax, nTop
                            sub eax, nHeight
                            mov rect.top, eax
                            mov eax, nLeft
                            add eax, XPos
                            mov rect.right, eax
                            mov eax, nTop
                            mov ebx, nHeight
                            add ebx, nLineHeight
                            sub eax, ebx
                            mov rect.bottom, eax
                        .ELSE
                            mov eax, nLeft
                            add eax, XPos
                            sub eax, nWidthOfSpace
                            mov rect.left, eax
                            mov eax, nTop
                            add eax, nHeight
                            mov rect.top, eax
                            mov eax, nLeft
                            add eax, XPos
                            mov rect.right, eax
                            mov eax, nTop
                            add eax, nHeight
                            add eax, nLineHeight
                            mov rect.bottom, eax
                        .ENDIF
                        ; Underline text spaces
                        Invoke DrawText, hdc, Addr szSpace, 1, Addr rect, uFormat
                    .ENDIF
                .ENDIF

                ;----------------------------------------------------------
                ; Finish drawing text out
                ;----------------------------------------------------------

            .ENDIF

            ;----------------------------------------------------------
            ; Update current position for next word/token
            ;----------------------------------------------------------
            mov eax, nSize.x
            add XPos, eax
            mov eax, XPos
            .IF eax > nMinWidth
                mov nMinWidth, eax
            .ENDIF
            mov bWhiteSpace, FALSE

        .ENDIF

        ;----------------------------------------------------------
        ; End of Tag/Word checking and processing 
        ; Loop again to get next token or word
        ;----------------------------------------------------------
        mov eax, Tag
        mov TagPrevious, eax
        mov eax, nTokenLength
        add lpszStart, eax
        mov eax, TRUE

    .ENDW ; Loop again


    ;------------------------------------------------------------------
    ; Finish up and tidy some stuff as well
    ;------------------------------------------------------------------
    Invoke RestoreDC, hdc, SavedDC
    lea ebx, hfontSpecial
    mov nIndex, 1
    mov eax, 1
    .WHILE eax < FV_NUMBER
        mov eax, dword ptr [ebx+eax*DWORD]
        .IF eax != NULL
            Invoke DeleteObject, eax
        .ENDIF
        inc nIndex
        mov eax, nIndex
    .ENDW
    ; do not erase hfontSpecial[0]
    ; store width and height back into the lpRect structure
    mov eax, NewFormat
    and eax, DT_CALCRECT
    .IF eax != 0 && lpRect != NULL
        mov eax, rect.left
        add eax, nMinWidth
        mov rect.right, eax
        mov eax, rect.top
        .IF SDWORD ptr eax < 0
            mov eax, rect.top
            mov ebx, nHeight
            add ebx, nLineHeight
            sub eax, ebx
            mov rect.bottom, eax
        .ELSE
            mov eax, rect.top
            add eax, nHeight
            add eax, nLineHeight
            mov rect.bottom, eax
        .ENDIF
        Invoke CopyRect, lpRect, Addr rect
    .ENDIF
    Invoke IsWindow, hDTELink
    .IF hDTELink != NULL && eax != FALSE
        Invoke DrawTextEXTLinkReady, hDTELink
    .ENDIF
    mov eax, nHeight
    ret
DrawHTMLCODE ENDP


;------------------------------------------------------------------------------
; Gets the next word or tag token from text and returns in eax a token type 
; value indicating the tag that was found and if tag was a start or end tag.
; if 0 then normal word was found.
; if -1 then no more tokens/words left.
;
; Note: This strips extra whitespace from words - this is for calculations 
; later on to determine if word should wrap to next line.
;
; Returns in eax a token type. Adjusts nSize (lpdwSize parameter) on return to
; decrease total chars left to process. Returns nTokenLength (lpdwTokenLength
; parameter) with correct size of token processed. Returns bWhiteSpace
; (lpdwWhiteSpace parameter). Returns adjusted position of lpszString to point
; it to next char after token/word (skipping whitespaces)
; Not 100% sure what bWhiteSpace is used for exactly, maybe its useful?
;------------------------------------------------------------------------------
_HTMLCODE_GetToken PROC USES EBX ECX lpszString:DWORD, lpdwSize:DWORD, lpdwTokenLength:DWORD, lpdwWhiteSpace:DWORD, lpTagInfo:DWORD
    LOCAL lpszStart:DWORD
    LOCAL EndToken:DWORD
    LOCAL nLength:DWORD
    LOCAL EntryWhiteSpace:DWORD
    LOCAL Index:DWORD
    LOCAL IsEndTag:DWORD
    LOCAL pTag:DWORD
    LOCAL pTagList:DWORD
    LOCAL nTagCount:DWORD
    LOCAL lpszTag:DWORD
    LOCAL LengthTag:DWORD
    LOCAL lpszScan:DWORD
    LOCAL nSize:DWORD
    LOCAL dbTagOpen:BYTE
    LOCAL dbTagClose:BYTE

    ;PrintText '_HTMLCODE_GetToken'

    .IF lpszString == NULL
        mov eax, -1
        ret
    .ENDIF
    
    .IF lpdwSize == NULL
        mov eax, -1
        ret
    .ENDIF

    mov ebx, lpdwSize
    mov eax, [ebx]
    mov nSize, eax

    mov ebx, lpszString
    mov eax, [ebx]
    mov lpszStart, eax

    .IF lpdwWhiteSpace != NULL
        mov ebx, lpdwWhiteSpace
        mov eax, [ebx]
        mov EntryWhiteSpace, eax
        mov ecx, lpszStart
        movzx ebx, byte ptr [ecx]
        .IF ISWHITESPACE(bl)
            mov eax, EntryWhiteSpace
            or eax, TRUE
        .ELSE
            mov eax, EntryWhiteSpace
            or eax, FALSE
        .ENDIF
        mov ebx, lpdwWhiteSpace
        mov [ebx], eax
    .ELSE
        mov EntryWhiteSpace, FALSE
    .ENDIF

    mov ecx, lpszStart
    movzx ebx, byte ptr [ecx]
    .WHILE (nSize > 0) && ISWHITESPACE(bl)
        inc lpszStart
        inc ecx
        dec nSize
        movzx ebx, byte ptr [ecx]
    .ENDW

    .IF sdword ptr nSize <= 0
        mov eax, -1
        ret
    .ENDIF

    ; Get tag delimiters
    mov ebx, lpTagInfo
    movzx eax, byte ptr [ebx].TAGINFO.TagOpen
    mov dbTagOpen, al
    movzx eax, byte ptr [ebx].TAGINFO.TagClose
    mov dbTagClose, al

    mov eax, lpszStart
    mov EndToken, eax
    mov nLength, 0
    mov IsEndTag, 0
    mov ebx, EndToken
    movzx eax, byte ptr [ebx]
    .IF al == dbTagOpen ; might be a HTML tag, check
        inc EndToken
        inc nLength

        mov ecx, EndToken
        movzx ebx, byte ptr [ecx]
        mov eax, nLength
        .IF eax < nSize && bl == '/'
            mov IsEndTag, ENDFLAG
            inc EndToken
            inc nLength
        .ENDIF

        mov ecx, EndToken
        mov eax, nLength
        .WHILE (eax < nSize) && (ISWHITESPACENOT(bl)) && bl != dbTagOpen && bl != dbTagClose
            inc EndToken
            inc ecx
            inc nLength
            movzx ebx, byte ptr [ecx]
            mov eax, nLength
        .ENDW

        mov ebx, lpTagInfo
        mov eax, [ebx].TAGINFO.TagCount
        mov nTagCount, eax
        mov eax, [ebx].TAGINFO.TagList
        mov pTagList, eax

        mov eax, nTagCount
        mov ebx, SIZEOF TAG
        mul ebx
        add eax, pTagList
        mov pTag, eax

        mov eax, nTagCount
        mov Index, eax
        .WHILE eax > 0 ; scan tags to see if one matches
            mov ebx, pTag
            lea eax, [ebx].TAG.mnemonic
            mov lpszTag, eax
            Invoke szLen, lpszTag
            mov LengthTag, eax
            
            mov eax, lpszStart
            .IF IsEndTag == ENDFLAG
                inc eax
                inc eax
            .ELSE
                inc eax
            .ENDIF
            mov lpszScan, eax
            Invoke szCmpi, lpszTag, lpszScan, LengthTag
            .IF eax == 0 ; match
                .BREAK
            .ELSE
            .ENDIF
            sub pTag, SIZE TAG
            dec Index
            mov eax, Index
        .ENDW
        ; Index contains the tag if one was found or 0 otherwise
        ;PrintStringByAddr lpszTag
        ;PrintDec Index
        
        .IF Index > 0 ; so it is a tag, see whether to accept parameters
            mov ebx, pTag
            mov eax, [ebx].TAG.param
            .IF (eax == TRUE) && (IsEndTag != ENDFLAG)
                mov ecx, EndToken
                movzx ebx, byte ptr [ecx]
                mov eax, nLength
                .WHILE (eax < nSize) && bl != dbTagOpen && bl != dbTagClose  ; '<' '>'
                    inc EndToken
                    inc ecx
                    inc nLength
                    movzx ebx, byte ptr [ecx]
                    mov eax, nLength
                .ENDW
            .ELSE
                mov ecx, EndToken
                movzx ebx, byte ptr [ecx]
                .IF bl != dbTagClose ;'>'
                    ;PrintText '.IF bl != dbTagClose'
                    mov Index, 0
                .else
                .ENDIF
                ; no parameters, then '>' must follow the tag
            .ENDIF
            mov ebx, pTag
            mov eax, [ebx].TAG.block
            .IF lpdwWhiteSpace != NULL && eax == TRUE
                ;.IF dwPreMode == 1 ;|| dwPreMode == 2
                ;    ;mov [ebx].TAG.block, FALSE
                ;    mov ebx, dwWhiteSpace
                ;    mov eax, TRUE
                ;    mov [ebx], eax                    
                ;.ELSE
                    mov ebx, lpdwWhiteSpace
                    mov eax, FALSE
                    mov [ebx], eax
                ;.ENDIF
            .ENDIF
        .ENDIF

        ; skip trailing white space in some circumstances
        mov ecx, EndToken
        movzx ebx, byte ptr [ecx]
        .IF bl == dbTagClose;'>'
            inc EndToken
            inc nLength
        .ENDIF
        
        mov ebx, pTag
        mov eax, [ebx].TAG.block
        .IF Index > 0 && ( eax == TRUE || EntryWhiteSpace == TRUE)
            mov ecx, EndToken
            movzx ebx, byte ptr [ecx]
            mov eax, nLength
            .WHILE (eax < nSize) && ISWHITESPACE(bl); ( bl == 20h || (bl >= 09h && bl <= 0Dh) )
                inc EndToken
                inc ecx
                inc nLength
                movzx ebx, byte ptr [ecx]
                mov eax, nLength
            .ENDW
        .ENDIF

    .ELSE ; normal word (no tag)

        mov Index, 0
        mov ecx, EndToken
        movzx ebx, byte ptr [ecx]
        mov eax, nLength
        .WHILE (eax < nSize) && (ISWHITESPACENOT(bl)) && bl != dbTagOpen  ; '<' (bl != 20h && bl != 09h && bl != 0Ah && bl != 0Bh && bl != 0Ch && bl != 0Dh)
            inc EndToken
            inc ecx
            inc nLength
            movzx ebx, byte ptr [ecx]
            mov eax, nLength
        .ENDW

    .ENDIF

    .IF lpdwTokenLength != NULL
        mov ebx, lpdwTokenLength
        mov eax, nLength
        mov [ebx], eax
    .ENDIF
    .IF lpdwSize != NULL
        mov eax, nSize
        mov ebx, nLength
        sub eax, ebx ; subtract size and length to store new size for next call of this funciton
        mov ebx, lpdwSize
        mov [ebx], eax
    .ENDIF
    
    mov ebx, lpszString
    mov eax, lpszStart
    mov [ebx], eax

    mov ebx, lpTagInfo
    mov eax, [ebx].TAGINFO.TagList
    mov pTagList, eax

    mov eax, Index
    mov ebx, SIZEOF TAG
    mul ebx
    add eax, pTagList
    mov pTag, eax    

    mov ebx, pTag
    mov eax, [ebx].TAG.token
    or eax, IsEndTag

    ret
_HTMLCODE_GetToken ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_PRE - Pre Tag or Code Tag
;
; Draws the pre/code text with its background fill and courier font
; 
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nMaxWidth and Addr nHeight (for value and modified on return)
;
; Returns in eax width of text drawn. nHeight (pointer to this is stored in  
; rect.bottom and is passed via lpRect parameter) is updated to reflect the new
; height of text drawn. nNewCount (lpNewCount parameter) is updated for 
; characters left in lpszStart. lpszStart (lplpszStart parameter) is updated to
; point to next token, usually: </pre> or </code>
;------------------------------------------------------------------------------
_HTMLCODE_PRE PROC USES EBX hdc:DWORD, hFont:DWORD, lplpszStart:DWORD, lpNewCount:DWORD, dwTokenLength:DWORD, lpRect:DWORD, dwTagType:DWORD ;dwLeft:DWORD, dwTop:DWORD, lpdwHeight:DWORD, dwMaxWidth:DWORD
    LOCAL lpTagContentText:DWORD
    LOCAL nTagContentLength:DWORD
    LOCAL nWidthOfSpace:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL lpdwHeight:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nHeight:DWORD
    LOCAL rect:RECT
    LOCAL nSize:POINT
    
    Invoke GetTagContents, lplpszStart, lpNewCount, dwTokenLength, dwTagType, GETTAG_BRACKET_ANGLE
    .IF eax != NULL
        mov lpTagContentText, eax
        Invoke szLen, lpTagContentText
        mov nTagContentLength, eax
        Invoke GetFontVariant, hdc, hFont, FV_PRE
        Invoke SelectObject, hdc, eax
        Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
        mov eax, nSize.x
        mov nWidthOfSpace, eax
        mov eax, nSize.y
        mov nLineHeight, eax
        
        mov ebx, lpRect
        mov eax, [ebx].RECT.left
        mov nLeft, eax
        mov eax, [ebx].RECT.top
        mov nTop, eax
        mov eax, [ebx].RECT.right
        mov nMaxWidth, eax
        mov eax, [ebx].RECT.bottom
        mov lpdwHeight, eax
        
        mov ebx, lpdwHeight
        mov eax, [ebx]
        mov nHeight, eax
        
        mov eax, nLeft ;dwLeft ;
        add eax, PRE_INDENT
        mov rect.left, eax
        mov eax, nTop ;dwTop ;
        add eax, nLineHeight
        add eax, nHeight
        mov rect.top, eax
        mov eax, nLeft ;dwLeft ;
        add eax, nMaxWidth ;dwMaxWidth ;
        sub eax, PRE_INDENT
        mov rect.right, eax
        mov eax, nTop ;dwTop ;
        add eax, nHeight
        add eax, nLineHeight
        add eax, nLineHeight
        mov rect.bottom, eax 

        ; Calc height of text to draw
        Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect, DT_CALCRECT or DT_WORDBREAK or DT_EXPANDTABS ;or DT_TABSTOP or 1024d
        ;add eax, 4 ; to increase rect fill space - comment out to restore
        mov ebx, lpdwHeight
        add [ebx], eax
        ;add nHeight, eax ; add height of DT_CALCRECT to nHeight for next lines after this
        mov eax, nLeft ;dwLeft ;
        add eax, nMaxWidth ;dwMaxWidth ;
        sub eax, PRE_INDENT
        mov rect.right, eax ; reset right to max width as its changed after DT_CALCRECT
        
        ; Background fill and draw text
        Invoke SetTextColor, hdc, dwRGBCodeTextColor
        Invoke SetBkColor, hdc, dwRGBCodeBackColor
        sub rect.left, PRE_INDENT
        add rect.right, PRE_INDENT
        ;add rect.bottom, 4 ; to increase rect fill space - comment out to restore
        Invoke FillRect, hdc, Addr rect, CodeBackBrush
        add rect.left, PRE_INDENT
        sub rect.right, PRE_INDENT
        ;add rect.top, 1 ; to increase rect fill space - comment out to restore

        Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect,  DT_WORDBREAK or DT_EXPANDTABS ;or DT_TABSTOP or 1024d
        Invoke GlobalFree, lpTagContentText
        mov ebx, lpNewCount
        mov eax, [ebx]
        sub eax, nTagContentLength
        mov [ebx], eax ; adjust (reduce) count of chars now left to process
        mov eax, nTagContentLength
        mov ebx, lplpszStart
        add [ebx], eax ; adjust string to point at end of pre
        mov eax, nSize.x
    .ELSE
        xor eax, eax
    .ENDIF
    ret

_HTMLCODE_PRE ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_QUOTE - Quote Tag or Q Tag or Blockq Tag
; 
; Draws the quote text surrounded by curly double quotes. Quote text is 
; centered, has a slightly larger font and has a background fill.
;
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nMaxWidth and Addr nHeight (for value and modified on return)
;
; Returns in eax width of text drawn. nHeight (pointer to this is stored in  
; rect.bottom and is passed via lpRect parameter) is updated to reflect the new
; height of text drawn. nNewCount (lpNewCount parameter) is updated for 
; characters left in lpszStart. lpszStart (lplpszStart parameter) is updated to
; point to next token, usually: </q> or </quote> or </blockq>
;------------------------------------------------------------------------------
_HTMLCODE_QUOTE PROC USES EBX hdc:DWORD, hFont:DWORD, lplpszStart:DWORD, lpNewCount:DWORD, dwTokenLength:DWORD, lpRect:DWORD, dwTag:DWORD
    LOCAL lpTagContentText:DWORD
    LOCAL nTagContentLength:DWORD
    LOCAL lpWideTagContentText:DWORD
    LOCAL nWideTagContentLength:DWORD    
    LOCAL nWidthOfSpace:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL lpdwHeight:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nHeight:DWORD
    LOCAL rect:RECT
    LOCAL nSize:POINT

    mov eax, dwTag
    .IF eax == tQUOTE1
        mov eax, GETTAG_Q
    .ELSEIF eax == tQUOTE2
        mov eax, GETTAG_QUOTE
    .ELSEIF eax == tQUOTE3
        mov eax, GETTAG_BLOCKQ
    .ENDIF
    Invoke GetTagContents, lplpszStart, lpNewCount, dwTokenLength, eax, GETTAG_BRACKET_ANGLE
    .IF eax != NULL
        mov lpTagContentText, eax
        Invoke szLen, lpTagContentText
        mov nTagContentLength, eax
        shl eax, 1 ; x 2
        add eax, 8
        mov nWideTagContentLength, eax
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        mov lpWideTagContentText, eax
        
        Invoke lstrcpyW, lpWideTagContentText, Addr szDblQuoteOpenW
        Invoke szCatStrToWide, lpWideTagContentText, lpTagContentText
        Invoke lstrcatW, lpWideTagContentText, Addr szDblQuoteCloseW
        ;DbgDump lpWideTagContentText, nWideTagContentLength
        Invoke GetFontVariant, hdc, hFont, FV_QUOTE
        Invoke SelectObject, hdc, eax
        Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
        mov eax, nSize.x
        mov nWidthOfSpace, eax
        mov eax, nSize.y
        mov nLineHeight, eax

        mov ebx, lpRect
        mov eax, [ebx].RECT.left
        mov nLeft, eax
        mov eax, [ebx].RECT.top
        mov nTop, eax
        mov eax, [ebx].RECT.right
        mov nMaxWidth, eax
        mov eax, [ebx].RECT.bottom
        mov lpdwHeight, eax
        
        mov ebx, lpdwHeight
        mov eax, [ebx]
        mov nHeight, eax

        mov eax, nLeft
        add eax, QUOTE_INDENT
        mov rect.left, eax
        mov eax, nTop
        add eax, nLineHeight
        add eax, nHeight
        mov rect.top, eax
        mov eax, nLeft
        add eax, nMaxWidth
        sub eax, QUOTE_INDENT
        mov rect.right, eax
        mov eax, nTop
        add eax, nHeight
        add eax, nLineHeight
        add eax, nLineHeight
        mov rect.bottom, eax                          

        ; Calc height of text to draw
        ;Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect, DT_WORDBREAK or DT_EXPANDTABS or DT_CALCRECT
        add nTagContentLength, 2 ; add two for extra "" quotemarks
        Invoke DrawTextW, hdc, lpWideTagContentText, nTagContentLength, Addr rect, DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_CALCRECT
        sub nTagContentLength, 2 ; restore original width
        
        mov ebx, lpdwHeight
        add [ebx], eax        
        ;add nHeight, eax ; add height of DT_CALCRECT to nHeight for next lines after this
        mov eax, nLeft
        add eax, nMaxWidth
        sub eax, QUOTE_INDENT
        mov rect.right, eax ; reset right to max width as its changed after DT_CALCRECT
        
        ; Background fill and draw text
        Invoke SetTextColor, hdc, dwRGBQuoteTextColor
        Invoke SetBkColor, hdc, dwRGBQuoteBackColor
        sub rect.left, QUOTE_INDENT
        add rect.right, QUOTE_INDENT
        Invoke FillRect, hdc, Addr rect, QuoteBackBrush
        add rect.left, QUOTE_INDENT
        sub rect.right, QUOTE_INDENT
        ;Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect,  DT_WORDBREAK or DT_EXPANDTABS
        add nTagContentLength, 2 ; add two for extra "" quotemarks
        Invoke DrawTextW, hdc, lpWideTagContentText, nTagContentLength, Addr rect, DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS
        sub nTagContentLength, 2 ; restore original width
        Invoke GlobalFree, lpTagContentText
        Invoke GlobalFree, lpWideTagContentText
        
;        mov eax, NewCount
;        sub eax, nTagContentLength
;        mov NewCount, eax ; adjust (reduce) count of chars now left to process
;        mov eax, nTagContentLength ; adjust string to point at end of pre
;        add lpszStart, eax
        
        mov ebx, lpNewCount
        mov eax, [ebx]
        sub eax, nTagContentLength
        mov [ebx], eax ; adjust (reduce) count of chars now left to process
        mov eax, nTagContentLength
        mov ebx, lplpszStart
        add [ebx], eax ; adjust string to point at end of pre
        mov eax, nSize.x        
    .ELSE
        xor eax, eax
    .ENDIF
    ret

_HTMLCODE_QUOTE ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_ALINK - Hyperlink Tag
;
; Adds a link url (url, title and region rect) to the DrawTextEXTLink control
; 
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nHeight

; Returns in eax width of url title text drawn. nNewCount (lpNewCount parameter)
; is updated for characters left in lpszStart. lpszStart (lplpszStart parameter)
; is updated to point to next token, usually: </a>. 
; nTokenLength (lpdwTokenLength) is updated to reflect change of drawing url
; title text instead of using tokenlength for <a href= contents.
;
;------------------------------------------------------------------------------
_HTMLCODE_ALINK PROC USES EBX hdc:DWORD, hFont:DWORD, lplpszStart:DWORD, lpNewCount:DWORD, lpdwTokenLength:DWORD, lpRect:DWORD, dwXPos:DWORD, hDTELink:DWORD
    LOCAL lpTagContentText:DWORD
    LOCAL nTagContentLength:DWORD
    LOCAL nTokenLength:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nHeight:DWORD
    LOCAL nLenLinkTitle:DWORD
    LOCAL hWndDC:DWORD
    LOCAL nNewCount:DWORD
    LOCAL rect:RECT
    LOCAL nSize:POINT
    LOCAL nSizeSpace:POINT
    LOCAL pt:POINT
    LOCAL szLinkUrl[256]:BYTE
    LOCAL szLinkTitle[256]:BYTE
    
    mov ebx, lpdwTokenLength
    mov eax, [ebx]
    mov nTokenLength, eax

    mov ebx, lpNewCount
    mov eax, [ebx]
    mov nNewCount, eax

    Invoke GetTagContents, lplpszStart, lpNewCount, nTokenLength, GETTAG_ALINK, GETTAG_BRACKET_ANGLE
    .IF eax != NULL                
        mov lpTagContentText, eax
        Invoke szLen, lpTagContentText
        mov nTagContentLength, eax
        
        ;PrintStringByAddr lpTagContentText
        
        Invoke RtlZeroMemory, Addr szLinkUrl, SIZEOF szLinkUrl
        Invoke RtlZeroMemory, Addr szLinkTitle, SIZEOF szLinkTitle
        
        ; split into url and title text
        Invoke _HTMLCODE_LinkUrlTitle, lpTagContentText, nTagContentLength, Addr szLinkUrl, Addr szLinkTitle
        .IF eax == TRUE

            Invoke szLen, Addr szLinkTitle
            mov nLenLinkTitle, eax
            Invoke GetFontVariant, hdc, hFont, FV_UNDERLINE
            Invoke SelectObject, hdc, eax
            Invoke GetTextExtentPoint32, hdc, Addr szLinkTitle, nLenLinkTitle, Addr nSize
            
            mov ebx, lpRect
            mov eax, [ebx].RECT.left
            mov nLeft, eax
            mov eax, [ebx].RECT.top
            mov nTop, eax
            mov eax, [ebx].RECT.bottom
            mov nHeight, eax            
            
            mov eax, nLeft
            add eax, dwXPos
            .IF dwXPos != 0
                Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSizeSpace
                mov eax, nSizeSpace.x
                add nSize.x, eax
                mov eax, nLeft
                add eax, dwXPos
                add eax, nSizeSpace.x
            .ELSE
                mov eax, nLeft
                add eax, dwXPos
            .ENDIF
            mov rect.left, eax
            mov eax, nTop
            add eax, nHeight
            mov rect.top, eax
            mov eax, nLeft
            add eax, dwXPos
            add eax, nSize.x
            mov rect.right, eax
            mov eax, nTop
            add eax, nHeight
            add eax, nSize.y ;nLineHeight
            mov rect.bottom, eax                 

            Invoke IsWindow, hDTELink
            .IF hDTELink != NULL && eax != FALSE ; Already exists
                Invoke GetFontVariant, hdc, hFont, FV_NORMAL
                Invoke SetWindowLong, hDTELink, DTEL_FONTNORMAL, eax ; font normal
                Invoke GetFontVariant, hdc, hFont, FV_UNDERLINE
                Invoke SetWindowLong, hDTELink, DTEL_FONTUNDERLINE, eax ; font underline
                Invoke GetBkColor, hdc
                Invoke SetWindowLong, hDTELink, DTEL_BACKCOLOR, eax ; back color
                ;Invoke SetWindowLong, hDTELink, DTEL_TEXTCOLOR, 0C87C0Bh ; text color
                Invoke DrawTextEXTLinkAddUrl, hDTELink, Addr rect, Addr szLinkUrl, Addr szLinkTitle
            .ELSE
            
                Invoke GetCursorPos, Addr pt
                Invoke WindowFromDC, hdc
                mov hWndDC, eax
                ;PrintDec hWndDC
                Invoke ScreenToClient, hWndDC, Addr pt
                Invoke PtInRect, Addr rect, pt.x, pt.y
                .IF eax == TRUE
                    Invoke GetFontVariant, hdc, hFont, FV_UNDERLINE
                    Invoke SelectObject, hdc, eax                
                .ELSE
                    Invoke GetFontVariant, hdc, hFont, FV_NORMAL
                    Invoke SelectObject, hdc, eax                
                .ENDIF
                Invoke GetWindowLong, hDTELink, DTEL_BACKCOLOR
                Invoke SetTextColor, hdc, eax
                Invoke DrawText, hdc, Addr szLinkTitle, nLenLinkTitle, Addr rect,  DT_WORDBREAK or DT_EXPANDTABS
            .ENDIF

            Invoke GlobalFree, lpTagContentText
            
            mov ebx, lpNewCount
            mov eax, [ebx]
            ;sub eax, nTokenLength
            sub eax, 3
            mov [ebx], eax
            
;            mov ebx, lpNewCount
;            mov eax, [ebx]
;    
;            add eax, nTokenLength
;            sub eax, nTagContentLength
;            PrintText 'new NewCount'
;            PrintDec eax
;            mov [ebx], eax; adjust (reduce) count of chars now left to process
;
            mov eax, nTagContentLength
            add eax,3
;            PrintText 'new tokenlength'
;            PrintDec eax 
            mov ebx, lpdwTokenLength
            mov [ebx], eax

            mov eax, nSize.x
            ;add dwXPos, eax
            ;mov eax, dwXPos
        .ENDIF
    .ELSE
        xor eax, eax
    .ENDIF
    ret

_HTMLCODE_ALINK ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_COLOR - Color Tag
; 
; Sets the color of the text based on the color parameter string.
; 
; Returns in eax 0
;------------------------------------------------------------------------------
_HTMLCODE_COLOR PROC hdc:DWORD, dwTag:DWORD, lpszStart:DWORD, lpColorStack:DWORD, lpdwColorStackTop:DWORD
    LOCAL lpColString:DWORD
    LOCAL dwRGB:DWORD

    mov eax, dwTag
    and eax, ENDFLAG
    .IF eax == 0 ; <color>
        mov eax, lpszStart ; <color='#C00000'>
        add eax, 7d
        mov lpColString, eax
        Invoke ParseColor, Addr lpColString
        mov dwRGB, eax
        Invoke ColorStackPush, hdc, dwRGB, lpColorStack, lpdwColorStackTop
    .ELSE ; </color>
        Invoke ColorStackPop, hdc, lpColorStack, lpdwColorStackTop
    .ENDIF
    xor eax, eax
    ret
_HTMLCODE_COLOR ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_FONT - Font Color Tag
; 
; Sets the color of the text based on the color parameter string.
;
; Returns in eax 0
;------------------------------------------------------------------------------
_HTMLCODE_FONT PROC USES EBX hdc:DWORD, dwTag:DWORD, lpszStart:DWORD, lpColorStack:DWORD, lpdwColorStackTop:DWORD
    LOCAL lpColString:DWORD
    LOCAL dwRGB:DWORD

    mov eax, dwTag
    and eax, ENDFLAG
    .IF eax == 0 ; <font>
        mov ebx, lpszStart ; <font color='#C00000'>
        add ebx, 6d
        Invoke szCmpi, ebx, Addr szColorEquTag, 6
        .IF eax == 0 ; match
            mov eax, lpszStart
            add eax, 12d
            mov lpColString, eax
            Invoke ParseColor, Addr lpColString
            mov dwRGB, eax
            Invoke ColorStackPush, hdc, dwRGB, lpColorStack, lpdwColorStackTop
        .ENDIF
    .ELSE ; </font>
        Invoke ColorStackPop, hdc, lpColorStack, lpdwColorStackTop
    .ENDIF
    xor eax, eax
    ret
_HTMLCODE_FONT ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_HR - Horizontal Rule Tag
;
; Draws a horizontal line
; 
; Returns in eax 0
;------------------------------------------------------------------------------
_HTMLCODE_HR PROC USES EBX hdc:DWORD, dwLeft:DWORD, dwTop:DWORD, dwHeight:DWORD, dwMaxWidth:DWORD, dwLineHeight:DWORD
    LOCAL hPen:DWORD
    LOCAL hOldPen:DWORD
    LOCAL rect:RECT
    LOCAL SavedColor:DWORD
    
    Invoke GetDCPenColor, hdc
    mov SavedColor, eax
    Invoke GetStockObject, DC_PEN
    mov hPen, eax
    Invoke SelectObject, hdc, hPen
    mov hOldPen, eax                 
    Invoke SetDCPenColor, hdc, dwRGBHorzRuleColor
    
    mov eax, dwLeft ;nLeft
    add eax, HR_INDENT
    mov rect.left, eax
    mov eax, dwTop ;nTop
    mov ebx, dwLineHeight ;nLineHeight
    shr ebx, 1 ; div by 2
    add eax, ebx
    add eax, dwHeight ;nHeight
    mov rect.top, eax
    mov eax, dwLeft ;nLeft
    add eax, dwMaxWidth ;nMaxWidth
    sub eax, HR_INDENT
    mov rect.right, eax

    Invoke MoveToEx, hdc, rect.left, rect.top, NULL
    Invoke LineTo, hdc, rect.right, rect.top
    Invoke SetDCPenColor, hdc, SavedColor
    Invoke SelectObject, hdc, hOldPen
    xor eax, eax    
    ret
_HTMLCODE_HR ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_LIST - List Tag - Ordered or Unordered List
;
; Calculates indents for list level and stores that info on the list stack.
;
; Returns in eax 0
;------------------------------------------------------------------------------
_HTMLCODE_LIST PROC USES EBX hdc:DWORD, hFont:DWORD, lpListStack:DWORD, lpListLevel:DWORD, dwTag:DWORD 
    LOCAL nSize:POINT
    LOCAL nWidthOfSpace:DWORD
    LOCAL ListLevel:DWORD
    LOCAL dwListType:DWORD
    LOCAL dwListIndent:DWORD
    LOCAL dwListBulletIndent:DWORD
    
    Invoke SelectObject, hdc, hFont
    Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
    mov eax, nSize.x
    mov nWidthOfSpace, eax
    ;mov eax, nSize.y
    ;mov nLineHeight, eax                  
    mov eax, dwTag
    .IF eax == tLIST
        mov dwListType, 0 ; unordered list - bullet symbols
    .ELSE
        mov dwListType, 1 ; ordered list - numbers
        ;mov dwListCounter, 1
    .ENDIF
    
    mov ebx, lpListLevel
    mov eax, [ebx]
    mov ListLevel, eax

    ; calc indents
    mov eax, ListLevel
    inc eax
    mov ebx, LIST_INDENT
    mul ebx
    mov ebx, nWidthOfSpace
    mul ebx
    mov dwListIndent, eax
    mov eax, ListLevel
    inc eax
    mov ebx, LIST_INDENT
    mul ebx
    sub eax, LIST_INDENT_BULLET
    mov ebx, nWidthOfSpace
    mul ebx
    mov dwListBulletIndent, eax

    Invoke ListStackPush, dwListType, dwListIndent, dwListBulletIndent, lpListStack, lpListLevel
    xor eax, eax
    ret
_HTMLCODE_LIST ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_LISTITEM - List Item Tag
;
; Indents based on list level and draws bullets or numbers based on list type.
; The text for the list item is handled normally by the main DrawHTMLCODE
; function and parsed for other tags as normal.
;
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nMaxWidth and Addr nHeight (for value and modified on return)
;
; Returns in eax width of text drawn. nHeight (pointer to this is stored in  
; rect.bottom and is passed via lpRect parameter) is updated to reflect the new
; height of bullets or numbers drawn.
;------------------------------------------------------------------------------
_HTMLCODE_LISTITEM PROC USES EBX hdc:DWORD, hFont:DWORD, lpListStack:DWORD, dwListLevel:DWORD, lpRect:DWORD, dwNewFormat:DWORD
    LOCAL nSize:POINT
    LOCAL rect:RECT
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL lpdwHeight:DWORD
    LOCAL nHeight:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nWidthOfSpace:DWORD
    LOCAL dwListType:DWORD
    LOCAL dwListIndent:DWORD
    LOCAL dwListBulletIndent:DWORD
    LOCAL szListItemNo[8]:BYTE

    mov eax, dwNewFormat
    and eax, DT_SINGLELINE
    .IF eax != DT_SINGLELINE

        Invoke GetFontVariant, hdc, hFont, FV_BOLD or FV_ITALIC or FV_UNDERLINE
        Invoke SelectObject, hdc, eax            
        ;Invoke SelectObject, hdc, hfontBase
        Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
        mov eax, nSize.x
        mov nWidthOfSpace, eax
        mov eax, nSize.y
        mov nLineHeight, eax       
        
        Invoke ListStackPeek, Addr dwListType, Addr dwListIndent, Addr dwListBulletIndent, lpListStack, dwListLevel
        
        ; Get params from rect for local vars
        mov ebx, lpRect
        mov eax, [ebx].RECT.left
        mov nLeft, eax
        mov eax, [ebx].RECT.top
        mov nTop, eax
        mov eax, [ebx].RECT.right
        mov nMaxWidth, eax
        mov eax, [ebx].RECT.bottom
        mov lpdwHeight, eax
        
        mov ebx, lpdwHeight
        mov eax, [ebx]
        mov nHeight, eax    
    
        mov eax, nLeft
        add eax, dwListBulletIndent
        mov rect.left, eax
        mov eax, nTop
        add eax, nLineHeight
        ;.IF dwListType == 0
            add eax, 2d
        ;.ELSE
        ;    add eax, 2d
        ;.ENDIF
        add eax, nHeight
        mov rect.top, eax
        mov eax, nLeft
        add eax, nMaxWidth
        mov rect.right, eax
        mov eax, nTop
        add eax, nHeight
        add eax, nLineHeight
        add eax, nLineHeight
        mov rect.bottom, eax                    
        
        Invoke GetFontVariant, hdc, hFont, FV_BOLD
        Invoke SelectObject, hdc, eax
        
        .IF dwListType == 0 ; Unorderded list, so draw bullet
            mov eax, dwListLevel
            .IF eax == 1 || eax == 4 || eax == 7 || eax >= 10
                Invoke DrawTextW, hdc, Addr szBulletSymbolW, 1, Addr rect, DT_LEFT
            .ELSEIF eax == 2 || eax == 5 || eax == 8
                Invoke DrawTextW, hdc, Addr szTriangleBulletSymbolW, 1, Addr rect, DT_LEFT ;szWhiteBulletSymbolW
            .ELSEIF eax == 3 || eax == 6 || eax == 9
                Invoke DrawTextW, hdc, Addr szWhiteBulletSymbolW, 1, Addr rect, DT_LEFT
            .ENDIF
        .ELSE ; draw number
            Invoke dwtoa, dwListType, Addr szListItemNo
            Invoke szCatStr, Addr szListItemNo, Addr szFullstop
            Invoke szLen, Addr szListItemNo
            .IF eax == 2 ; for 1. to 9.
                mov eax, nLeft
                add eax, dwListBulletIndent
                sub eax, nWidthOfSpace
            .ELSEIF eax == 3 ; for 10.-99.
                mov eax, nLeft
                add eax, dwListBulletIndent
                sub eax, nWidthOfSpace
                sub eax, nWidthOfSpace
            .ELSE ; for 100.-999.
                mov eax, nLeft
                add eax, dwListBulletIndent
                sub eax, nWidthOfSpace
                sub eax, nWidthOfSpace
                sub eax, nWidthOfSpace
            .ENDIF
            mov rect.left, eax
            Invoke DrawText, hdc, Addr szListItemNo, -1, Addr rect, DT_LEFT
            inc dwListType
            Invoke ListStackSetCounter, dwListType, lpListStack, dwListLevel
        .ENDIF
        Invoke SelectObject, hdc, hFont
        
        mov eax, nLineHeight
        add eax, 2d
        add eax, nHeight
        mov ebx, lpdwHeight
        mov [ebx], eax ; add nHeight, eax
        mov eax, dwListIndent
    .ELSE
        xor eax, eax
    .ENDIF
    ret
_HTMLCODE_LISTITEM ENDP


;------------------------------------------------------------------------------
; _HTMLCODE_LinkUrlTitle - Seperate the [href="url">title] string to a url and title
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
_HTMLCODE_LinkUrlTitle PROC USES EBX ECX EDI ESI lpszHrefString:DWORD, dwHrefStringLength:DWORD, lpszUrl:DWORD, lpszTitle:DWORD

    .IF dwHrefStringLength == 0 || lpszHrefString == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    mov esi, lpszHrefString
    movzx eax, byte ptr [esi]
    mov ebx, 0
    .WHILE ebx < dwHrefStringLength && al != 0
        
        .IF al == 22h || al == 27h ; " or '
            mov edi, lpszUrl
            mov ecx, lpszTitle ; store in title as well, just in case title is empty
            inc ebx
            inc esi
            movzx eax, byte ptr [esi]
            .WHILE ebx < dwHrefStringLength && al != 0 && al != 22h && al != 27h
                mov byte ptr [edi], al
                mov byte ptr [ecx], al
                inc edi
                inc ecx
                inc ebx
                inc esi
                movzx eax, byte ptr [esi]
            .ENDW
            .IF al == 0
                ; we hit end of string instead of another quote mark, so fail
                mov edi, lpszUrl
                mov byte ptr [edi], 0
                mov edi, lpszTitle
                mov byte ptr [edi], 0
                mov eax, FALSE
                ret
            .ELSE
                mov byte ptr [edi], 0
                mov byte ptr [ecx], 0                
            .ENDIF

            ; continue on to get title
            inc ebx
            inc esi
            movzx eax, byte ptr [esi]
            .IF al == '>' || al == ']'
                inc ebx
                inc esi
                movzx eax, byte ptr [esi]
            .ENDIF

            mov edi, lpszTitle
            movzx eax, byte ptr [esi]
            .WHILE ebx < dwHrefStringLength && al != 0
                mov byte ptr [edi], al
                mov byte ptr [edi+1], 0
                inc edi
                inc ebx
                inc esi
                movzx eax, byte ptr [esi]
            .ENDW
            ;mov byte ptr [edi], 0
            mov eax, TRUE
            ret
        .ENDIF
        
        inc ebx
        inc esi
        movzx eax, byte ptr [esi]
    .ENDW
    
    mov eax, FALSE
    ret
_HTMLCODE_LinkUrlTitle ENDP




;==============================================================================
; DrawBBCODE Functions - NOT TESTED! NEEDS TO BE REFACTORED! DONT USE YET!
;==============================================================================


;------------------------------------------------------------------------------
; Draws text within the bounding rect and processes text for tags to change 
; font features (bold, italic, underline, etc), font color, line and paragraph 
; breaks. Calls _BBCODEGetToken to retrieve next word/token to paint until 
; no more words/tokens.
;
; Returns in eax height of text drawn similar to DrawText
;------------------------------------------------------------------------------
DrawBBCODE PROC USES EBX ECX EDX hdc:DWORD, lpString:DWORD, nCount:DWORD, lpRect:DWORD, uFormat:DWORD, lpHyperlink:DWORD
    LOCAL lpszStart:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nRight:DWORD
    LOCAL nBottom:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL nMinWidth:DWORD
    LOCAL nHeight:DWORD
    LOCAL SavedDC:DWORD
    LOCAL Tag:DWORD
    LOCAL TagPrevious:DWORD
    LOCAL nTokenLength:DWORD
    LOCAL hfontBase:DWORD
    LOCAL Styles:DWORD
    LOCAL CurStyles:DWORD
    LOCAL nIndex:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nWidthOfSpace:DWORD
    LOCAL XPos:DWORD
    LOCAL bWhiteSpace:DWORD
    LOCAL NewFormat:DWORD
    LOCAL NewCount:DWORD
    LOCAL SavedStyle:DWORD
    LOCAL SavedColor:DWORD
    LOCAL SavedBkColor:DWORD
    LOCAL ColorStackTop:DWORD
    LOCAL ListLevel:DWORD
    LOCAL dwListIndent:DWORD
    LOCAL dwListItemMode:DWORD
    LOCAL dwBulletIndent:DWORD
    LOCAL hDTELink:DWORD
    LOCAL hDTELinkParent:DWORD
    LOCAL rect:RECT
    LOCAL nSize:POINT    
    LOCAL hfontSpecial[FV_NUMBER]:DWORD
    LOCAL ColorStack[COLORSTACK_SIZE]:COLORREF
    LOCAL ListStack[LISTSTACK_SIZE]:LISTINFO  
    
    ;PrintText 'DrawBBCODE'
    .IF hdc == NULL || lpString == NULL
        mov eax, 0
        ret
    .ENDIF
    
    .IF SDWORD ptr nCount < 0
        Invoke szLen, lpString
    .ELSE
        mov eax, nCount
    .ENDIF
    mov NewCount, eax

   .IF lpRect != NULL
        Invoke CopyRect, Addr rect, lpRect
        mov eax, rect.left
        mov nLeft, eax
        mov eax, rect.top
        mov nTop, eax
        mov eax, rect.right
        mov nRight, eax
        mov eax, nRight
        sub eax, nLeft
        mov nMaxWidth, eax
        mov eax, rect.bottom
        mov nBottom, eax        
    .ELSE
        Invoke GetCurrentPositionEx, hdc, Addr nSize
        mov eax, nSize.x
        mov nLeft, eax
        mov eax, nSize.y
        mov nTop, eax
        Invoke GetDeviceCaps, hdc, HORZRES
        mov ebx, nLeft
        sub eax, ebx
        mov nMaxWidth, eax
    .ENDIF
    ;PrintDec nLeft
    .IF SDWORD ptr nMaxWidth < 0
        mov nMaxWidth, 0
    .ENDIF

    ; toggle flags we do not support
    mov eax, uFormat
    and eax, (-1 xor (DT_CENTER or DT_RIGHT or DT_TABSTOP))
    or eax, (DT_LEFT or DT_NOPREFIX)
    mov NewFormat, eax

    ; get the "default" font from the DC
    Invoke SaveDC, hdc
    mov SavedDC, eax
    
    Invoke GetStockObject, SYSTEM_FONT
    Invoke SelectObject, hdc, eax
    mov hfontBase, eax
    Invoke SelectObject, hdc, hfontBase
    lea ebx, hfontSpecial
    mov nIndex, 0
    mov eax, 0
    .WHILE eax < FV_NUMBER
        mov dword ptr [ebx+eax*DWORD], 0
        inc nIndex
        mov eax, nIndex
    .ENDW
    mov dword ptr [ebx], 0

    ; get font height (use characters with ascender and descender);
    ; we make the assumption here that changing the font style will
    ; not change the font height
    Invoke GetTextExtentPoint32, hdc, Addr szTxtExtentTest, 2, Addr nSize
    mov eax, nSize.y
    mov nLineHeight, eax
    mov Styles, 0 ; assume the active font is normal weight, roman, non-underlined
    mov XPos, 0
    mov nMinWidth, 0
    mov CurStyles, -1 ; force a select of the proper style
    mov nHeight, 0
    mov bWhiteSpace, FALSE
    mov ColorStackTop, 0
    mov TagPrevious, 0
    mov ListLevel, 0
    mov nSize.x, 0

    Invoke RtlZeroMemory, Addr ColorStack, SIZEOF ColorStack
    Invoke RtlZeroMemory, Addr ListStack, SIZEOF ListStack

    Invoke WindowFromDC, hdc
    mov hDTELinkParent, eax
    .IF lpHyperlink != NULL
        mov ebx, lpHyperlink
        mov eax, [ebx]
        mov hDTELink, eax
    .ENDIF
    Invoke IsWindow, hDTELink
    .IF hDTELink != NULL && eax != FALSE ; Already exists, make sure its sized to fit our area
        IFDEF DEBUG32
            PrintText 'HYPERLINKS ALREADY EXISTS OK'
        ENDIF         
        ;PrintText 'Already Exists'
        ;Invoke SetWindowLong, hDTELink, DTEL_ENABLEDSTATE, FALSE ; disable while we add links
        mov eax, nRight
        add eax, nLeft
        add eax, nLeft
        mov ebx, nBottom
        add ebx, nTop
        add ebx, nTop
        ;Invoke SetWindowPos, hDTELink, NULL, 0, 0, eax, ebx, SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE
        Invoke DrawTextEXTLinkReset, hDTELink
    .ELSE ; create hyperlink window
        mov eax, nRight
        add eax, nLeft
        add eax, nLeft
        mov ebx, nBottom
        add ebx, nTop
        add ebx, nTop
        .IF lpHyperlink != NULL
            Invoke DrawTextEXTLinkCreate, hDTELinkParent, 0, 0, eax, ebx
            .IF eax != NULL
                mov hDTELink, eax
                mov ebx, lpHyperlink
                mov [ebx], eax
                IFDEF DEBUG32
                    PrintText 'HYPERLINKS OK'
                ENDIF                   
            .ELSE
                mov hDTELink, 0
                IFDEF DEBUG32
                    PrintText 'FAILED TO CREATE HYPERLINK - NO LINK URLS'
                ENDIF                
            .ENDIF
        .ELSE
            mov hDTELink, 0
            IFDEF DEBUG32
                PrintText 'HYPERLINK IS NOT SET - NO LINK URLS'
            ENDIF
        .ENDIF
    .ENDIF

    mov eax, lpString
    mov lpszStart, eax

    .WHILE TRUE
        
        Invoke _BBCODE_GetToken, Addr lpszStart, Addr NewCount, Addr nTokenLength, Addr bWhiteSpace, Addr BBCODE_TAGINFO
        mov Tag, eax
        
        ;PrintDec Tag
        
        .IF SDWORD ptr eax < 0
            .BREAK
        .ENDIF
        
        mov eax, Tag
        and eax, (-1 xor ENDFLAG)
        
        ;------------------------------------------------------------------
        .IF eax == tBR ; CRLF, (13,10), (0Dh,0Ah), LF, 13, 0Dh
            ;PrintText 'tBR'
            mov eax, TagPrevious
            .IF eax != (tCODE or ENDFLAG) ; [/code]
            ;.ELSE
                ;PrintDec nTokenLength
                ;PrintDec bWhiteSpace
                Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
                mov eax, nSize.y
                mov nLineHeight, eax              
    
                mov eax, NewFormat
                and eax, DT_SINGLELINE
                .IF eax != DT_SINGLELINE
                    mov eax, nLineHeight
                    add eax, 2d
                    add nHeight, eax
                    mov XPos, 0
                .ENDIF
                Invoke SelectObject, hdc, hfontBase
                mov nSize.x, 0
                ;PrintDec XPos
                ;PrintDec nSize.x
                ;mov bWhiteSpace, FALSE
                ;.IF TagPrevious == (tLISTITEM) ; [li] or [*] and not [/li]
                ;    mov dwListItemMode, 0 ; then line break ends listitem
                ;.ENDIF
             
            .ENDIF
        
        ;------------------------------------------------------------------
        .ELSEIF eax == tTAB
            ;PrintText 'tTAB'
            Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
            mov eax, nSize.x
            shl eax, 2 ; x 4 for 4 spaces
            add XPos, eax
        
        ;------------------------------------------------------------------
        .ELSEIF eax == tCODE ; [code] or [/code]
            ;PrintText 'tCODE'
            mov eax, Tag
            and eax, ENDFLAG        
            .IF eax == 0 ; [code]
                ;.IF TagPrevious != (tCODE or ENDFLAG)
                ;    mov eax, nLineHeight
                ;    add nHeight, eax
                ;.ENDIF

                mov eax, Styles
                mov SavedStyle, eax
                Invoke GetTextColor, hdc
                mov SavedColor, eax
                Invoke GetBkColor, hdc
                mov SavedBkColor, eax

                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nMaxWidth
                mov rect.right, eax
                lea eax, nHeight
                mov rect.bottom, eax
                
                Invoke _BBCODE_CODE, hdc, hfontBase, Addr lpszStart, Addr NewCount, nTokenLength, Addr rect

            .ELSE ; [/code]
                mov eax, SavedStyle
                mov Styles, eax
                mov eax, SavedColor
                Invoke SetTextColor, hdc, eax
                mov eax, SavedBkColor
                Invoke SetBkColor, hdc, eax
            .ENDIF
            mov XPos, 0
            
        ;------------------------------------------------------------------
        .ELSEIF eax == tQUOTE1 || eax == tQUOTE2 ; [q], [quote]
            ;PrintText 'tQUOTE'        
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; [q], [quote]
                mov eax, Styles
                mov SavedStyle, eax
                Invoke GetTextColor, hdc
                mov SavedColor, eax
                Invoke GetBkColor, hdc
                mov SavedBkColor, eax

                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nMaxWidth
                mov rect.right, eax
                lea eax, nHeight
                mov rect.bottom, eax                
                
                Invoke _BBCODE_QUOTE, hdc, hfontBase, Addr lpszStart, Addr NewCount, nTokenLength, Addr rect, Tag

            .ELSE ; [/q], [/quote]
                mov eax, SavedStyle
                mov Styles, eax
                mov eax, SavedColor
                Invoke SetTextColor, hdc, eax
                mov eax, SavedBkColor
                Invoke SetBkColor, hdc, eax
            .ENDIF
            mov XPos, 0        
        
        ;------------------------------------------------------------------
        .ELSEIF eax == tALINK ; [url] or [/url]
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; 

                mov eax, Styles
                mov SavedStyle, eax
                Invoke GetTextColor, hdc
                mov SavedColor, eax
                Invoke GetBkColor, hdc
                mov SavedBkColor, eax

                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nHeight
                mov rect.bottom, eax                
                
                Invoke _BBCODE_URL, hdc, hfontBase, Addr lpszStart, Addr NewCount, Addr nTokenLength, Addr rect, XPos, hDTELink
                add XPos, eax

            .ELSE ; </a>
                mov eax, SavedStyle
                mov Styles, eax
                mov eax, SavedColor
                Invoke SetTextColor, hdc, eax
                mov eax, SavedBkColor
                Invoke SetBkColor, hdc, eax
                Invoke SelectObject, hdc, hfontBase
            .ENDIF        

        ;------------------------------------------------------------------
        .ELSEIF eax == tLIST || eax == tLISTO ; <ul> or <ol> unordered list or orderded list
            ;PrintText 'tLIST'
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; <ul> or <ol>
            
                Invoke _BBCODE_LIST, hdc, hfontBase, Addr ListStack, Addr ListLevel, Tag
                
                mov eax, NewFormat
                and eax, DT_SINGLELINE
                .IF eax != DT_SINGLELINE
                    .IF ListLevel < 2
                        mov eax, nLineHeight
                        add eax, 2d
                        add nHeight, eax
                    .ENDIF
                    mov XPos, 0
                .ENDIF                

            .ELSE ; </ul> or <ol>
                ;Invoke ListStackPop, Addr dwListType, Addr dwListIndent, Addr dwListBulletIndent, Addr ListStack, Addr ListLevel
                Invoke ListStackPop, NULL, NULL, NULL, Addr ListStack, Addr ListLevel
                .IF Tag == tLISTO
                    Invoke ListStackSetCounter, 1, Addr ListStack, ListLevel
                .ENDIF
                ;mov dwListCounter, 1
                Invoke SelectObject, hdc, hfontBase
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tLISTITEM && ListLevel > 0 ; [li] or [*]
            ;PrintText 'tLISTITEM'        
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == 0 ; [li]
                
                mov dwListItemMode, 1
                
                ; Store some params in rect structure
                mov eax, nLeft
                mov rect.left, eax
                mov eax, nTop
                mov rect.top, eax
                mov eax, nMaxWidth
                mov rect.right, eax
                lea eax, nHeight
                mov rect.bottom, eax
                
                Invoke _BBCODE_LISTITEM, hdc, hfontBase, Addr ListStack, ListLevel, Addr rect, NewFormat
                mov XPos, eax

            .ELSE ; [/li]
                mov dwListItemMode, 0
                Invoke SelectObject, hdc, hfontBase
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tB ; [b] or [/b]
            ;PrintText 'tB'
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; [/b]
                and Styles, (-1 xor FV_BOLD)
            .ELSE ; [b]
                or Styles, FV_BOLD
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tI ; [i] or [/i]
            ;PrintText 'tI'
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; [/i]
                and Styles, (-1 xor FV_ITALIC)
            .ELSE ; [i]
                or Styles, FV_ITALIC
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tU ; [u] or [/u]
            ;PrintText 'tU'
            mov eax, Tag
            and eax, ENDFLAG
            .IF eax == ENDFLAG ; [/u]
                and Styles, (-1 xor FV_UNDERLINE)
            .ELSE ; [u]
                or Styles, FV_UNDERLINE
            .ENDIF

        ;------------------------------------------------------------------
        .ELSEIF eax == tCOLOR ; [color] or [/color]
            ;PrintText 'tCOLOR'
            Invoke _BBCODE_COLOR, hdc, Tag, lpszStart, Addr ColorStack, Addr ColorStackTop
        
        ;------------------------------------------------------------------
        .ELSEIF eax == tCMNT
        
        ;------------------------------------------------------------------
        .ELSE ; default
            mov eax, Tag
            and eax, (tNONE or ENDFLAG)
            .IF eax == ENDFLAG ; Nothing to draw, just skip end tag and continue
                
                ; Goto update current position for next word/token and loop again
                
            .ELSE ; otherwise we assume it was a word (or an unknown tag) to draw
                
                ;PrintText 'word'
                ;PrintDec XPos
                
                ;----------------------------------------------------------
                ; Start of the drawing text with font styles
                ;----------------------------------------------------------
                mov eax, CurStyles
                .IF eax != Styles
                    lea ebx, hfontSpecial
                    mov ecx, Styles
                    mov eax, dword ptr [ebx+ecx*DWORD]
                    .IF eax == NULL
                        Invoke GetFontVariant, hdc, hfontBase, Styles
                        lea ebx, hfontSpecial
                        mov ecx, Styles
                        mov dword ptr [ebx+ecx*DWORD], eax
                    .ENDIF
                    mov eax, Styles
                    mov CurStyles, eax
                    lea ebx, hfontSpecial
                    mov ecx, Styles
                    mov eax, dword ptr [ebx+ecx*DWORD]
                    Invoke SelectObject, hdc, eax
                    ; get the width of a space character (for word spacing)
                    Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
                    mov eax, nSize.x
                    mov nWidthOfSpace, eax
                    mov eax, nSize.y
                    mov nLineHeight, eax                    
                .ENDIF
            
                ;----------------------------------------------------------
                ; Check word length, check whether to wrap around
                ;----------------------------------------------------------
                Invoke GetTextExtentPoint32, hdc, lpszStart, nTokenLength, Addr nSize
                mov eax, nSize.x
                .IF eax > nMaxWidth
                    mov nMaxWidth, eax ; must increase width: long non-breakable word
                .ENDIF
                .IF bWhiteSpace == TRUE
                    mov eax, nWidthOfSpace
                    add XPos, eax
                .ENDIF
                
                .IF dwListItemMode == 1 
                    Invoke ListStackPeek, NULL, Addr dwListIndent, Addr dwBulletIndent, Addr ListStack, ListLevel
                    mov eax, XPos
                    add eax, dwListIndent
                    sub eax, dwBulletIndent
                    add eax, nSize.x
                .ELSE
                    mov eax, XPos
                    add eax, nSize.x
                .ENDIF                
                mov eax, XPos
                add eax, nSize.x
                .IF eax > nMaxWidth && bWhiteSpace == TRUE
                    mov eax, uFormat
                    and eax, DT_WORDBREAK
                    .IF eax == DT_WORDBREAK
                        .IF dwListItemMode == 1
                            Invoke ListStackPeek, NULL, Addr dwListIndent, NULL, Addr ListStack, ListLevel
                            ; word wrap
                            mov eax, nLineHeight
                            add eax, 2d
                            add nHeight, eax
                            mov eax, dwListIndent
                            ;add eax, nWidthOfSpace ; for some reason needs extra space for indent?, not sure why?
                            mov XPos, eax
                        .ELSE
                            ; word wrap
                            mov eax, nLineHeight
                            add nHeight, eax
                            mov XPos, 0
                        .ENDIF
                    .ELSE
                        ; no word wrap, must increase the width */
                        mov eax, XPos
                        add eax, nSize.x
                        mov nMaxWidth, eax
                    .ENDIF
                .ENDIF
                
                ;----------------------------------------------------------
                ; Output text (unless DT_CALCRECT is set)
                ;----------------------------------------------------------
                mov eax, uFormat
                and eax, DT_CALCRECT
                .IF eax == 0
                    ; handle negative heights, too (suggestion of "Sims")
                    mov eax, nTop
                    .IF sdword ptr eax < 0
                        mov eax, nLeft
                        add eax, XPos
                        mov rect.left, eax
                        mov eax, nTop
                        sub eax, nHeight
                        mov rect.top, eax
                        mov eax, nLeft
                        add eax, nMaxWidth
                        mov rect.right, eax
                        mov eax, nTop
                        mov ebx, nHeight
                        add ebx, nLineHeight
                        sub eax, ebx
                        mov rect.bottom, eax
                    .ELSE
                        ;PrintDec nLeft
                        ;PrintDec XPos
                        mov eax, nLeft
                        add eax, XPos
                        mov rect.left, eax
                        ;PrintDec rect.left
                        mov eax, nTop
                        add eax, nHeight
                        mov rect.top, eax
                        mov eax, nLeft
                        add eax, nMaxWidth
                        mov rect.right, eax
                        mov eax, nTop
                        add eax, nHeight
                        add eax, nLineHeight
                        mov rect.bottom, eax                
                    .ENDIF
                    
                    ; reposition subscript text to align below the baseline
                    mov eax, Styles
                    and eax, FV_SUBSCRIPT
                    .IF eax == FV_SUBSCRIPT
                        mov eax, NewFormat
                        or eax, DT_BOTTOM or DT_SINGLELINE
                        mov NewFormat, eax
                    .ENDIF

                    Invoke DrawText, hdc, lpszStart, nTokenLength, Addr rect, NewFormat
                    
                    ;----------------------------------------------------------
                    ; Check if underline style is used. For the underline style
                    ; the spaces between words should be underlined as well
                    ;----------------------------------------------------------
                    mov eax, Styles
                    and eax, FV_UNDERLINE
                    mov ebx, XPos
                    .IF (bWhiteSpace == TRUE) && (eax == FV_UNDERLINE) && (ebx >= nWidthOfSpace)
                        mov eax, nTop
                        .IF sdword ptr eax < 0
                            mov eax, nLeft
                            add eax, XPos
                            sub eax, nWidthOfSpace
                            mov rect.left, eax
                            mov eax, nTop
                            sub eax, nHeight
                            mov rect.top, eax
                            mov eax, nLeft
                            add eax, XPos
                            mov rect.right, eax
                            mov eax, nTop
                            mov ebx, nHeight
                            add ebx, nLineHeight
                            sub eax, ebx
                            mov rect.bottom, eax
                        .ELSE
                            mov eax, nLeft
                            add eax, XPos
                            sub eax, nWidthOfSpace
                            mov rect.left, eax
                            mov eax, nTop
                            add eax, nHeight
                            mov rect.top, eax
                            mov eax, nLeft
                            add eax, XPos
                            mov rect.right, eax
                            mov eax, nTop
                            add eax, nHeight
                            add eax, nLineHeight
                            mov rect.bottom, eax
                        .ENDIF
                        ; Underline text spaces
                        Invoke DrawText, hdc, Addr szSpace, 1, Addr rect, uFormat
                    .ENDIF
                .ENDIF

                ;----------------------------------------------------------
                ; Finish drawing text out
                ;----------------------------------------------------------
            
            .ENDIF
      
            ;----------------------------------------------------------
            ; Update current position for next word/token
            ;----------------------------------------------------------
            mov eax, nSize.x
            add XPos, eax
            mov eax, XPos
            .IF eax > nMinWidth
                mov nMinWidth, eax
            .ENDIF
            mov bWhiteSpace, FALSE
            
        .ENDIF
        
        ;----------------------------------------------------------
        ; End of Tag/Word checking and processing 
        ; Loop again to get next token or word
        ;----------------------------------------------------------
        mov eax, Tag
        mov TagPrevious, eax
        mov eax, nTokenLength
        add lpszStart, eax
        mov eax, TRUE
        
    .ENDW ; Loop again
    
    
    ;------------------------------------------------------------------
    ; Finish up and tidy some stuff as well
    ;------------------------------------------------------------------
    Invoke RestoreDC, hdc, SavedDC
    
    lea ebx, hfontSpecial
    mov nIndex, 1
    mov eax, 1
    .WHILE eax < FV_NUMBER
        mov eax, dword ptr [ebx+eax*DWORD]
        .IF eax != NULL
            Invoke DeleteObject, eax
        .ENDIF
        inc nIndex
        mov eax, nIndex
    .ENDW
    ; do not erase hfontSpecial[0]
    ; store width and height back into the lpRect structure
    mov eax, NewFormat
    and eax, DT_CALCRECT
    .IF eax != 0 && lpRect != NULL
        mov eax, rect.left
        add eax, nMinWidth
        mov rect.right, eax
        mov eax, rect.top
        .IF SDWORD ptr eax < 0
            mov eax, rect.top
            mov ebx, nHeight
            add ebx, nLineHeight
            sub eax, ebx
            mov rect.bottom, eax
        .ELSE
            mov eax, rect.top
            add eax, nHeight
            add eax, nLineHeight
            mov rect.bottom, eax
        .ENDIF
        Invoke CopyRect, lpRect, Addr rect
    .ENDIF
    Invoke IsWindow, hDTELink
    .IF hDTELink != NULL && eax != FALSE
        Invoke DrawTextEXTLinkReady, hDTELink
    .ENDIF    
    mov eax, nHeight
    ret
DrawBBCODE ENDP


;------------------------------------------------------------------------------
; Gets the next word or tag token from text and returns in eax a token type 
; value indicating the tag that was found and if tag was a start or end tag.
; if 0 then normal word was found.
; if -1 then no more tokens/words left.
;
; Note: This strips extra whitespace from words - this is for calculations 
; later on to determine if word should wrap to next line.
; 
; Returns in eax a token type 
;------------------------------------------------------------------------------
_BBCODE_GetToken PROC USES EBX ECX lpszString:DWORD, dwSize:DWORD, dwTokenLength:DWORD, dwWhiteSpace:DWORD, lpTagInfo:DWORD
    LOCAL lpszStart:DWORD
    LOCAL EndToken:DWORD
    LOCAL nLength:DWORD
    LOCAL EntryWhiteSpace:DWORD
    LOCAL Index:DWORD
    LOCAL IsEndTag:DWORD
    LOCAL pTag:DWORD
    LOCAL pTagList:DWORD
    LOCAL nTagCount:DWORD
    LOCAL lpszTag:DWORD
    LOCAL LengthTag:DWORD
    LOCAL lpszScan:DWORD
    LOCAL nSize:DWORD
    LOCAL dbTagOpen:BYTE
    LOCAL dbTagClose:BYTE

    .IF lpszString == NULL
        mov eax, -1
        ret
    .ENDIF
    
    .IF dwSize == NULL
        mov eax, -1
        ret
    .ENDIF

    mov ebx, dwSize
    mov eax, [ebx]
    mov nSize, eax

    mov ebx, lpszString
    mov eax, [ebx]
    mov lpszStart, eax

    .IF dwWhiteSpace != NULL
        mov ebx, dwWhiteSpace
        mov eax, [ebx]
        mov EntryWhiteSpace, eax
        mov ecx, lpszStart
        movzx ebx, byte ptr [ecx]
        .IF ISWHITESPACE(bl)
            mov eax, EntryWhiteSpace
            or eax, TRUE
        .ELSE
            mov eax, EntryWhiteSpace
            or eax, FALSE
        .ENDIF
        mov ebx, dwWhiteSpace
        mov [ebx], eax
    .ELSE
        mov EntryWhiteSpace, FALSE
    .ENDIF

    mov ecx, lpszStart
    movzx ebx, byte ptr [ecx]
    .WHILE (nSize > 0) && (ISSPACE(bl) || ISTAB(bl)); ISWHITESPACE(bl)
        inc lpszStart
        inc ecx
        dec nSize
        movzx ebx, byte ptr [ecx]
    .ENDW

    .IF sdword ptr nSize <= 0
        mov eax, -1
        ret
    .ENDIF

    ; Get tag delimiters
    mov ebx, lpTagInfo
    movzx eax, byte ptr [ebx].TAGINFO.TagOpen
    mov dbTagOpen, al
    movzx eax, byte ptr [ebx].TAGINFO.TagClose
    mov dbTagClose, al

    mov eax, lpszStart
    mov EndToken, eax
    mov nLength, 0
    mov IsEndTag, 0
    mov ebx, EndToken
    movzx eax, byte ptr [ebx]
    .IF al == dbTagOpen ; might be a BBCODE tag, check
        inc EndToken
        inc nLength

        mov ecx, EndToken
        movzx ebx, byte ptr [ecx]
        mov eax, nLength
        .IF eax < nSize && bl == '/'
            mov IsEndTag, ENDFLAG
            inc EndToken
            inc nLength
        .ENDIF

        mov ecx, EndToken
        mov eax, nLength
        .WHILE (eax < nSize) && (ISSPACENOT(bl)) && bl != dbTagOpen && bl != dbTagClose ;ISWHITESPACENOT(bl)
            inc EndToken
            inc ecx
            inc nLength
            movzx ebx, byte ptr [ecx]
            mov eax, nLength
        .ENDW

        mov ebx, lpTagInfo
        mov eax, [ebx].TAGINFO.TagCount
        mov nTagCount, eax
        mov eax, [ebx].TAGINFO.TagList
        mov pTagList, eax

        mov eax, nTagCount
        mov ebx, SIZEOF TAG
        mul ebx
        add eax, pTagList
        mov pTag, eax

        mov eax, nTagCount
        mov Index, eax
        .WHILE eax > 0 ; scan tags to see if one matches
            mov ebx, pTag
            lea eax, [ebx].TAG.mnemonic
            mov lpszTag, eax
            Invoke szLen, lpszTag
            mov LengthTag, eax
            
            mov eax, lpszStart
            .IF IsEndTag == ENDFLAG
                inc eax
                inc eax
            .ELSE
                inc eax
            .ENDIF
            mov lpszScan, eax
            Invoke szCmpi, lpszTag, lpszScan, LengthTag
            .IF eax == 0 ; match
                .BREAK
            .ELSE
            .ENDIF
            sub pTag, SIZE TAG
            dec Index
            mov eax, Index
        .ENDW
        ; Index contains the tag if one was found or 0 otherwise
        ;PrintDec Index
        ;PrintStringByAddr lpszTag

        .IF Index > 0 ; so it is a tag, see whether to accept parameters
            mov ebx, pTag
            mov eax, [ebx].TAG.param
            .IF (eax == TRUE) && (IsEndTag != ENDFLAG)
                mov ecx, EndToken
                movzx ebx, byte ptr [ecx]
                mov eax, nLength
                .WHILE (eax < nSize) && bl != dbTagOpen && bl != dbTagClose  ; '<' '>'
                    inc EndToken
                    inc ecx
                    inc nLength
                    movzx ebx, byte ptr [ecx]
                    mov eax, nLength
                .ENDW
            .ELSE
                mov ecx, EndToken
                movzx ebx, byte ptr [ecx]
                .IF bl != dbTagClose ;'>'
                    mov Index, 0
                .else
                .ENDIF
                ; no parameters, then '>' must follow the tag
            .ENDIF
            mov ebx, pTag
            mov eax, [ebx].TAG.block
            .IF dwWhiteSpace != NULL && eax == TRUE
                ;.IF dwPreMode == 1 ;|| dwPreMode == 2
                ;    ;mov [ebx].TAG.block, FALSE
                ;    mov ebx, dwWhiteSpace
                ;    mov eax, TRUE
                ;    mov [ebx], eax                    
                ;.ELSE
                    mov ebx, dwWhiteSpace
                    mov eax, FALSE
                    mov [ebx], eax
                ;.ENDIF
            .ENDIF
        .ENDIF

        ; skip trailing white space in some circumstances
        mov ecx, EndToken
        movzx ebx, byte ptr [ecx]
        .IF bl == dbTagClose;'>'
            inc EndToken
            inc nLength
        .ENDIF
        
        mov ebx, pTag
        mov eax, [ebx].TAG.block
        .IF Index > 0 && ( eax == TRUE || EntryWhiteSpace == TRUE)
            mov ecx, EndToken
            movzx ebx, byte ptr [ecx]
            mov eax, nLength
            .WHILE (eax < nSize) && (ISSPACE(bl) || ISTAB(bl)) ; ( bl == 20h || (bl >= 09h && bl <= 0Dh) ) ISWHITESPACE(bl)
                inc EndToken
                inc ecx
                inc nLength
                movzx ebx, byte ptr [ecx]
                mov eax, nLength
            .ENDW
        .ENDIF

    .ELSE ; normal word (no tag) or CRLF

        mov ecx, EndToken
        movzx ebx, byte ptr [ecx]
        .IF ISCRLF(bl)
            movzx ebx, byte ptr [ecx+1]
            .IF ISCRLF(bl) ; cr and lf
                ;PrintText 'CRLF'
                inc EndToken
                inc EndToken
                mov nLength, 2
            .ELSE ; was just newline
                ;PrintText 'LF'
                inc EndToken
                mov nLength, 1
            .ENDIF
            mov Index, -1 ; special marker to indicate use tBR
            mov ebx, dwWhiteSpace
            mov eax, FALSE
            mov [ebx], eax
        
        .ELSEIF ISTAB(bl)
            ;PrintText 'TAB'        
            inc EndToken
            mov nLength, 1
            mov Index, -2 ; special marker to indicate use tTAB
        
        .ELSE
            ;PrintText 'text'
            ;PrintDec nLength
            ;push ecx
            
            mov Index, 0
            mov ecx, EndToken
            movzx ebx, byte ptr [ecx]
            mov eax, nLength
            .WHILE (eax < nSize) && ( ISSPACENOT(bl) && ISTABNOT(bl) && ISCRLFNOT(bl) ) && bl != dbTagOpen  ; ISWHITESPACENOT(bl) '<' (bl != 20h && bl != 09h && bl != 0Ah && bl != 0Bh && bl != 0Ch && bl != 0Dh)
                inc EndToken
                inc ecx
                inc nLength
                movzx ebx, byte ptr [ecx]
                mov eax, nLength
            .ENDW
            ;pop ecx
            ;mov ecx, EndToken
            ;DbgDump ecx, nLength
            
        .ENDIF
    .ENDIF

    .IF dwTokenLength != NULL
        mov ebx, dwTokenLength
        mov eax, nLength
        mov [ebx], eax
    .ENDIF

    mov eax, nSize
    mov ebx, nLength
    sub eax, ebx ; subtract size and length to store new size for next call of this funciton
    mov ebx, dwSize
    mov [ebx], eax
    
    mov ebx, lpszString
    mov eax, lpszStart
    mov [ebx], eax

    mov ebx, lpTagInfo
    mov eax, [ebx].TAGINFO.TagList
    mov pTagList, eax

    mov eax, Index
    .IF eax == -2
        mov eax, tTAB
    .ELSEIF eax == -1
        mov eax, tBR
    .ELSE
        mov ebx, SIZEOF TAG
        mul ebx
        add eax, pTagList
        mov pTag, eax    
    
        mov ebx, pTag
        mov eax, [ebx].TAG.token
        or eax, IsEndTag
    .ENDIF
    
    ret
_BBCODE_GetToken ENDP


;------------------------------------------------------------------------------
; _BBCODE_CODE - Code Tag
;
; Draws the pre/code text with its background fill and courier font
; 
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nMaxWidth and Addr nHeight (for value and modified on return)
;
; Returns in eax width of text drawn. nHeight (pointer to this is stored in  
; rect.bottom and is passed via lpRect parameter) is updated to reflect the new
; height of text drawn. nNewCount (lpNewCount parameter) is updated for 
; characters left in lpszStart. lpszStart (lplpszStart parameter) is updated to
; point to next token, usually: </pre> or </code>
;------------------------------------------------------------------------------
_BBCODE_CODE PROC USES EBX hdc:DWORD, hFont:DWORD, lplpszStart:DWORD, lpNewCount:DWORD, dwTokenLength:DWORD, lpRect:DWORD
    LOCAL lpTagContentText:DWORD
    LOCAL nTagContentLength:DWORD
    LOCAL nWidthOfSpace:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL lpdwHeight:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nHeight:DWORD
    LOCAL rect:RECT
    LOCAL nSize:POINT
    
    Invoke GetTagContents, lplpszStart, lpNewCount, dwTokenLength, GETTAG_CODE, GETTAG_BRACKET_SQUARE
    .IF eax != NULL
        mov lpTagContentText, eax
        Invoke szLen, lpTagContentText
        mov nTagContentLength, eax
        
        ;PrintStringByAddr lpTagContentText
        
        Invoke GetFontVariant, hdc, hFont, FV_PRE
        Invoke SelectObject, hdc, eax
        Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
        mov eax, nSize.x
        mov nWidthOfSpace, eax
        mov eax, nSize.y
        mov nLineHeight, eax
        
        mov ebx, lpRect
        mov eax, [ebx].RECT.left
        mov nLeft, eax
        mov eax, [ebx].RECT.top
        mov nTop, eax
        mov eax, [ebx].RECT.right
        mov nMaxWidth, eax
        mov eax, [ebx].RECT.bottom
        mov lpdwHeight, eax
        
        mov ebx, lpdwHeight
        mov eax, [ebx]
        mov nHeight, eax
        
        mov eax, nLeft ;dwLeft ;
        add eax, PRE_INDENT
        mov rect.left, eax
        mov eax, nTop ;dwTop ;
        add eax, nLineHeight
        add eax, nHeight
        mov rect.top, eax
        mov eax, nLeft ;dwLeft ;
        add eax, nMaxWidth ;dwMaxWidth ;
        sub eax, PRE_INDENT
        mov rect.right, eax
        mov eax, nTop ;dwTop ;
        add eax, nHeight
        add eax, nLineHeight
        add eax, nLineHeight
        mov rect.bottom, eax 

        ; Calc height of text to draw
        Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect, DT_CALCRECT or DT_WORDBREAK or DT_EXPANDTABS ;or DT_TABSTOP or 1024d
        ;add eax, 4 ; to increase rect fill space - comment out to restore
        mov ebx, lpdwHeight
        add [ebx], eax
        ;add nHeight, eax ; add height of DT_CALCRECT to nHeight for next lines after this
        mov eax, nLeft ;dwLeft ;
        add eax, nMaxWidth ;dwMaxWidth ;
        sub eax, PRE_INDENT
        mov rect.right, eax ; reset right to max width as its changed after DT_CALCRECT
        
        ; Background fill and draw text
        Invoke SetTextColor, hdc, dwRGBCodeTextColor
        Invoke SetBkColor, hdc, dwRGBCodeBackColor
        sub rect.left, PRE_INDENT
        add rect.right, PRE_INDENT
        ;add rect.bottom, 4 ; to increase rect fill space - comment out to restore
        Invoke FillRect, hdc, Addr rect, CodeBackBrush
        add rect.left, PRE_INDENT
        sub rect.right, PRE_INDENT
        ;add rect.top, 1 ; to increase rect fill space - comment out to restore

        Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect,  DT_WORDBREAK or DT_EXPANDTABS ;or DT_TABSTOP or 1024d
        Invoke GlobalFree, lpTagContentText
        mov ebx, lpNewCount
        mov eax, [ebx]
        sub eax, nTagContentLength
        mov [ebx], eax ; adjust (reduce) count of chars now left to process
        mov eax, nTagContentLength
        mov ebx, lplpszStart
        add [ebx], eax ; adjust string to point at end of pre
        mov eax, nSize.x
    .ELSE
        xor eax, eax
    .ENDIF
    ret

_BBCODE_CODE ENDP


;------------------------------------------------------------------------------
; _BBCODE_QUOTE - Quote Tag or Q Tag
; 
; Draws the quote text surrounded by curly double quotes. Quote text is 
; centered, has a slightly larger font and has a background fill.
;
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nMaxWidth and Addr nHeight (for value and modified on return)
;
; Returns in eax width of text drawn. nHeight (pointer to this is stored in  
; rect.bottom and is passed via lpRect parameter) is updated to reflect the new
; height of text drawn. nNewCount (lpNewCount parameter) is updated for 
; characters left in lpszStart. lpszStart (lplpszStart parameter) is updated to
; point to next token, usually: </q> or </quote> or </blockq>
;------------------------------------------------------------------------------
_BBCODE_QUOTE PROC USES EBX hdc:DWORD, hFont:DWORD, lplpszStart:DWORD, lpNewCount:DWORD, dwTokenLength:DWORD, lpRect:DWORD, dwTag:DWORD
    LOCAL lpTagContentText:DWORD
    LOCAL nTagContentLength:DWORD
    LOCAL lpWideTagContentText:DWORD
    LOCAL nWideTagContentLength:DWORD    
    LOCAL nWidthOfSpace:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL lpdwHeight:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nHeight:DWORD
    LOCAL rect:RECT
    LOCAL nSize:POINT

    mov eax, dwTag
    .IF eax == tQUOTE1
        mov eax, GETTAG_Q
    .ELSEIF eax == tQUOTE2
        mov eax, GETTAG_QUOTE
    .ENDIF
    Invoke GetTagContents, lplpszStart, lpNewCount, dwTokenLength, eax, GETTAG_BRACKET_SQUARE
    .IF eax != NULL
        mov lpTagContentText, eax
        Invoke szLen, lpTagContentText
        mov nTagContentLength, eax
        shl eax, 1 ; x 2
        add eax, 8
        mov nWideTagContentLength, eax
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        mov lpWideTagContentText, eax
        
        Invoke lstrcpyW, lpWideTagContentText, Addr szDblQuoteOpenW
        Invoke szCatStrToWide, lpWideTagContentText, lpTagContentText
        Invoke lstrcatW, lpWideTagContentText, Addr szDblQuoteCloseW
        ;DbgDump lpWideTagContentText, nWideTagContentLength
        Invoke GetFontVariant, hdc, hFont, FV_QUOTE
        Invoke SelectObject, hdc, eax
        Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
        mov eax, nSize.x
        mov nWidthOfSpace, eax
        mov eax, nSize.y
        mov nLineHeight, eax

        mov ebx, lpRect
        mov eax, [ebx].RECT.left
        mov nLeft, eax
        mov eax, [ebx].RECT.top
        mov nTop, eax
        mov eax, [ebx].RECT.right
        mov nMaxWidth, eax
        mov eax, [ebx].RECT.bottom
        mov lpdwHeight, eax
        
        mov ebx, lpdwHeight
        mov eax, [ebx]
        mov nHeight, eax

        mov eax, nLeft
        add eax, QUOTE_INDENT
        mov rect.left, eax
        mov eax, nTop
        add eax, nLineHeight
        add eax, nHeight
        mov rect.top, eax
        mov eax, nLeft
        add eax, nMaxWidth
        sub eax, QUOTE_INDENT
        mov rect.right, eax
        mov eax, nTop
        add eax, nHeight
        add eax, nLineHeight
        add eax, nLineHeight
        mov rect.bottom, eax                          

        ; Calc height of text to draw
        ;Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect, DT_WORDBREAK or DT_EXPANDTABS or DT_CALCRECT
        add nTagContentLength, 2 ; add two for extra "" quotemarks
        Invoke DrawTextW, hdc, lpWideTagContentText, nTagContentLength, Addr rect, DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_CALCRECT
        sub nTagContentLength, 2 ; restore original width
        
        mov ebx, lpdwHeight
        add [ebx], eax        
        ;add nHeight, eax ; add height of DT_CALCRECT to nHeight for next lines after this
        mov eax, nLeft
        add eax, nMaxWidth
        sub eax, QUOTE_INDENT
        mov rect.right, eax ; reset right to max width as its changed after DT_CALCRECT
        
        ; Background fill and draw text
        Invoke SetTextColor, hdc, dwRGBQuoteTextColor
        Invoke SetBkColor, hdc, dwRGBQuoteBackColor
        sub rect.left, QUOTE_INDENT
        add rect.right, QUOTE_INDENT
        Invoke FillRect, hdc, Addr rect, QuoteBackBrush
        add rect.left, QUOTE_INDENT
        sub rect.right, QUOTE_INDENT
        ;Invoke DrawText, hdc, lpTagContentText, nTagContentLength, Addr rect,  DT_WORDBREAK or DT_EXPANDTABS
        add nTagContentLength, 2 ; add two for extra "" quotemarks
        Invoke DrawTextW, hdc, lpWideTagContentText, nTagContentLength, Addr rect, DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS
        sub nTagContentLength, 2 ; restore original width
        Invoke GlobalFree, lpTagContentText
        Invoke GlobalFree, lpWideTagContentText
        
;        mov eax, NewCount
;        sub eax, nTagContentLength
;        mov NewCount, eax ; adjust (reduce) count of chars now left to process
;        mov eax, nTagContentLength ; adjust string to point at end of pre
;        add lpszStart, eax
        
        mov ebx, lpNewCount
        mov eax, [ebx]
        sub eax, nTagContentLength
        mov [ebx], eax ; adjust (reduce) count of chars now left to process
        mov eax, nTagContentLength
        mov ebx, lplpszStart
        add [ebx], eax ; adjust string to point at end of pre
        mov eax, nSize.x        
    .ELSE
        xor eax, eax
    .ENDIF
    ret

_BBCODE_QUOTE ENDP


;------------------------------------------------------------------------------
; _BBCODE_COLOR - Color Tag
; 
; Sets the color of the text based on the color parameter string.
; 
; Returns in eax 0
;------------------------------------------------------------------------------
_BBCODE_COLOR PROC hdc:DWORD, dwTag:DWORD, lpszStart:DWORD, lpColorStack:DWORD, lpdwColorStackTop:DWORD
    LOCAL lpColString:DWORD
    LOCAL dwRGB:DWORD

    mov eax, dwTag
    and eax, ENDFLAG
    .IF eax == 0 ; <color>
        mov eax, lpszStart ; <color=#C00000>
        add eax, 7d
        mov lpColString, eax
        Invoke ParseColor, Addr lpColString
        mov dwRGB, eax
        Invoke ColorStackPush, hdc, dwRGB, lpColorStack, lpdwColorStackTop
    .ELSE ; </color>
        Invoke ColorStackPop, hdc, lpColorStack, lpdwColorStackTop
    .ENDIF
    xor eax, eax
    ret
_BBCODE_COLOR ENDP


;------------------------------------------------------------------------------
; _BBCODE_LIST - List Tag - Ordered or Unordered List
;
; Calculates indents for list level and stores that info on the list stack.
;
; Returns in eax 0
;------------------------------------------------------------------------------
_BBCODE_LIST PROC USES EBX hdc:DWORD, hFont:DWORD, lpListStack:DWORD, lpListLevel:DWORD, dwTag:DWORD 
    LOCAL nSize:POINT
    LOCAL nWidthOfSpace:DWORD
    LOCAL ListLevel:DWORD
    LOCAL dwListType:DWORD
    LOCAL dwListIndent:DWORD
    LOCAL dwListBulletIndent:DWORD
    
    Invoke SelectObject, hdc, hFont
    Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
    mov eax, nSize.x
    mov nWidthOfSpace, eax
    ;mov eax, nSize.y
    ;mov nLineHeight, eax                  
    mov eax, dwTag
    .IF eax == tLIST
        mov dwListType, 0 ; unordered list - bullet symbols
    .ELSE
        mov dwListType, 1 ; ordered list - numbers
        ;mov dwListCounter, 1
    .ENDIF
    
    mov ebx, lpListLevel
    mov eax, [ebx]
    mov ListLevel, eax

    ; calc indents
    mov eax, ListLevel
    inc eax
    mov ebx, LIST_INDENT
    mul ebx
    mov ebx, nWidthOfSpace
    mul ebx
    mov dwListIndent, eax
    mov eax, ListLevel
    inc eax
    mov ebx, LIST_INDENT
    mul ebx
    sub eax, LIST_INDENT_BULLET
    mov ebx, nWidthOfSpace
    mul ebx
    mov dwListBulletIndent, eax

    Invoke ListStackPush, dwListType, dwListIndent, dwListBulletIndent, lpListStack, lpListLevel
    xor eax, eax
    ret
_BBCODE_LIST ENDP


;------------------------------------------------------------------------------
; _BBCODE_LISTITEM - List Item Tag
;
; Indents based on list level and draws bullets or numbers based on list type.
; The text for the list item is handled normally by the main DrawBBCODE
; function and parsed for other tags as normal.
;
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nMaxWidth and Addr nHeight (for value and modified on return)
;
; Returns in eax width of text drawn. nHeight (pointer to this is stored in  
; rect.bottom and is passed via lpRect parameter) is updated to reflect the new
; height of bullets or numbers drawn.
;------------------------------------------------------------------------------
_BBCODE_LISTITEM PROC USES EBX hdc:DWORD, hFont:DWORD, lpListStack:DWORD, dwListLevel:DWORD, lpRect:DWORD, dwNewFormat:DWORD
    LOCAL nSize:POINT
    LOCAL rect:RECT
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nMaxWidth:DWORD
    LOCAL lpdwHeight:DWORD
    LOCAL nHeight:DWORD
    LOCAL nLineHeight:DWORD
    LOCAL nWidthOfSpace:DWORD
    LOCAL dwListType:DWORD
    LOCAL dwListIndent:DWORD
    LOCAL dwListBulletIndent:DWORD
    LOCAL szListItemNo[8]:BYTE

    mov eax, dwNewFormat
    and eax, DT_SINGLELINE
    .IF eax != DT_SINGLELINE

        Invoke GetFontVariant, hdc, hFont, FV_BOLD or FV_ITALIC or FV_UNDERLINE
        Invoke SelectObject, hdc, eax            
        ;Invoke SelectObject, hdc, hfontBase
        Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSize
        mov eax, nSize.x
        mov nWidthOfSpace, eax
        mov eax, nSize.y
        mov nLineHeight, eax       
        
        Invoke ListStackPeek, Addr dwListType, Addr dwListIndent, Addr dwListBulletIndent, lpListStack, dwListLevel
        
        ; Get params from rect for local vars
        mov ebx, lpRect
        mov eax, [ebx].RECT.left
        mov nLeft, eax
        mov eax, [ebx].RECT.top
        mov nTop, eax
        mov eax, [ebx].RECT.right
        mov nMaxWidth, eax
        mov eax, [ebx].RECT.bottom
        mov lpdwHeight, eax
        
        mov ebx, lpdwHeight
        mov eax, [ebx]
        mov nHeight, eax    
    
        mov eax, nLeft
        add eax, dwListBulletIndent
        mov rect.left, eax
        mov eax, nTop
        add eax, nLineHeight
        add eax, 2d
        add eax, nHeight
        mov rect.top, eax
        mov eax, nLeft
        add eax, nMaxWidth
        mov rect.right, eax
        mov eax, nTop
        add eax, nHeight
        add eax, nLineHeight
        add eax, nLineHeight
        mov rect.bottom, eax                    
        
        Invoke GetFontVariant, hdc, hFont, FV_BOLD
        Invoke SelectObject, hdc, eax        
        
        .IF dwListType == 0 ; Unorderded list, so draw bullet
            mov eax, dwListLevel
            .IF eax == 1 || eax == 4 || eax == 7 || eax >= 10
                Invoke DrawTextW, hdc, Addr szBulletSymbolW, 1, Addr rect, DT_LEFT
            .ELSEIF eax == 2 || eax == 5 || eax == 8
                Invoke DrawTextW, hdc, Addr szTriangleBulletSymbolW, 1, Addr rect, DT_LEFT ;szWhiteBulletSymbolW
            .ELSEIF eax == 3 || eax == 6 || eax == 9
                Invoke DrawTextW, hdc, Addr szWhiteBulletSymbolW, 1, Addr rect, DT_LEFT
            .ENDIF
        .ELSE ; draw number
            Invoke dwtoa, dwListType, Addr szListItemNo
            Invoke szCatStr, Addr szListItemNo, Addr szFullstop
            Invoke szLen, Addr szListItemNo
            .IF eax == 2 ; for 1. to 9.
                mov eax, nLeft
                add eax, dwListBulletIndent
                sub eax, nWidthOfSpace
            .ELSEIF eax == 3 ; for 10.-99.
                mov eax, nLeft
                add eax, dwListBulletIndent
                sub eax, nWidthOfSpace
                sub eax, nWidthOfSpace
            .ELSE ; for 100.-999.
                mov eax, nLeft
                add eax, dwListBulletIndent
                sub eax, nWidthOfSpace
                sub eax, nWidthOfSpace
                sub eax, nWidthOfSpace
            .ENDIF
            mov rect.left, eax
            Invoke DrawText, hdc, Addr szListItemNo, -1, Addr rect, DT_LEFT
            inc dwListType
            Invoke ListStackSetCounter, dwListType, lpListStack, dwListLevel
        .ENDIF
        Invoke SelectObject, hdc, hFont
        
        mov eax, nLineHeight
        add eax, 2d
        add eax, nHeight
        mov ebx, lpdwHeight
        mov [ebx], eax ; add nHeight, eax
        mov eax, dwListIndent
    .ELSE
        xor eax, eax
    .ENDIF
    ret
_BBCODE_LISTITEM ENDP

;------------------------------------------------------------------------------
; _BBCODE_URL - Hyperlink Tag
;
; Adds a link url (url, title and region rect) to the DrawTextEXTLink control
; 
; lpRect is a pointer to a rect, used to pass a few parameters: 
; nLeft, nTop, nHeight

; Returns in eax width of url title text drawn. nNewCount (lpNewCount parameter)
; is updated for characters left in lpszStart. lpszStart (lplpszStart parameter)
; is updated to point to next token, usually: [/url]. 
; nTokenLength (lpdwTokenLength) is updated to reflect change of drawing url
; title text instead of using tokenlength for [url=www.site.com]
;
;------------------------------------------------------------------------------
_BBCODE_URL PROC USES EBX hdc:DWORD, hFont:DWORD, lplpszStart:DWORD, lpNewCount:DWORD, lpdwTokenLength:DWORD, lpRect:DWORD, dwXPos:DWORD, hDTELink:DWORD
    LOCAL lpTagContentText:DWORD
    LOCAL nTagContentLength:DWORD
    LOCAL nTokenLength:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL nHeight:DWORD
    LOCAL nLenLinkTitle:DWORD
    LOCAL hWndDC:DWORD
    LOCAL nNewCount:DWORD
    LOCAL rect:RECT
    LOCAL nSize:POINT
    LOCAL nSizeSpace:POINT
    LOCAL pt:POINT
    LOCAL szLinkUrl[256]:BYTE
    LOCAL szLinkTitle[256]:BYTE
    
    mov ebx, lpdwTokenLength
    mov eax, [ebx]
    mov nTokenLength, eax

    mov ebx, lpNewCount
    mov eax, [ebx]
    mov nNewCount, eax

    Invoke GetTagContents, lplpszStart, lpNewCount, nTokenLength, GETTAG_URL, GETTAG_BRACKET_SQUARE
    .IF eax != NULL                
        mov lpTagContentText, eax
        Invoke szLen, lpTagContentText
        mov nTagContentLength, eax
        
        ;PrintStringByAddr lpTagContentText
        
        Invoke RtlZeroMemory, Addr szLinkUrl, SIZEOF szLinkUrl
        Invoke RtlZeroMemory, Addr szLinkTitle, SIZEOF szLinkTitle
        
        ; split into url and title text
        Invoke _BBCODE_LinkUrlTitle, lpTagContentText, nTagContentLength, Addr szLinkUrl, Addr szLinkTitle
        .IF eax == TRUE

            Invoke szLen, Addr szLinkTitle
            mov nLenLinkTitle, eax
            Invoke GetFontVariant, hdc, hFont, FV_UNDERLINE
            Invoke SelectObject, hdc, eax
            Invoke GetTextExtentPoint32, hdc, Addr szLinkTitle, nLenLinkTitle, Addr nSize

;            lea ebx, szLinkTitle
;            DbgDump ebx, nLenLinkTitle
;            Invoke szLen, Addr szLinkUrl
;            lea ebx, szLinkUrl
;            DbgDump ebx, eax
            
            mov ebx, lpRect
            mov eax, [ebx].RECT.left
            mov nLeft, eax
            mov eax, [ebx].RECT.top
            mov nTop, eax
            mov eax, [ebx].RECT.bottom
            mov nHeight, eax            
            
            mov eax, nLeft
            add eax, dwXPos
            .IF dwXPos != 0
                Invoke GetTextExtentPoint32, hdc, Addr szSpace, 1, Addr nSizeSpace
                mov eax, nSizeSpace.x
                add nSize.x, eax
                mov eax, nLeft
                add eax, dwXPos
                add eax, nSizeSpace.x
            .ELSE
                mov eax, nLeft
                add eax, dwXPos
            .ENDIF
            mov rect.left, eax
            mov eax, nTop
            add eax, nHeight
            mov rect.top, eax
            mov eax, nLeft
            add eax, dwXPos
            add eax, nSize.x
            mov rect.right, eax
            mov eax, nTop
            add eax, nHeight
            add eax, nSize.y ;nLineHeight
            mov rect.bottom, eax                 

            Invoke IsWindow, hDTELink
            .IF hDTELink != NULL && eax != FALSE ; Already exists
                Invoke GetFontVariant, hdc, hFont, FV_NORMAL
                Invoke SetWindowLong, hDTELink, DTEL_FONTNORMAL, eax ; font normal
                Invoke GetFontVariant, hdc, hFont, FV_UNDERLINE
                Invoke SetWindowLong, hDTELink, DTEL_FONTUNDERLINE, eax ; font underline
                Invoke GetBkColor, hdc
                Invoke SetWindowLong, hDTELink, DTEL_BACKCOLOR, eax ; back color
                ;Invoke SetWindowLong, hDTELink, DTEL_TEXTCOLOR, 0C87C0Bh ; text color
                Invoke DrawTextEXTLinkAddUrl, hDTELink, Addr rect, Addr szLinkUrl, Addr szLinkTitle
            .ELSE
            
                Invoke GetCursorPos, Addr pt
                Invoke WindowFromDC, hdc
                mov hWndDC, eax
                Invoke ScreenToClient, hWndDC, Addr pt
                Invoke PtInRect, Addr rect, pt.x, pt.y
                .IF eax == TRUE
                    Invoke GetFontVariant, hdc, hFont, FV_UNDERLINE
                    Invoke SelectObject, hdc, eax                
                .ELSE
                    Invoke GetFontVariant, hdc, hFont, FV_NORMAL
                    Invoke SelectObject, hdc, eax                
                .ENDIF
                Invoke GetWindowLong, hDTELink, DTEL_BACKCOLOR
                Invoke SetTextColor, hdc, eax
                Invoke DrawText, hdc, Addr szLinkTitle, nLenLinkTitle, Addr rect,  DT_WORDBREAK or DT_EXPANDTABS
            .ENDIF

            Invoke GlobalFree, lpTagContentText
            
            mov ebx, lpNewCount
            mov eax, [ebx]
            sub eax, 4 ; add spacing for: /url]
            mov [ebx], eax
            mov eax, nTagContentLength
            add eax, 4 ; add spacing for: /url]
            mov ebx, lpdwTokenLength
            mov [ebx], eax
            mov eax, nSize.x
        .ENDIF
    .ELSE
        xor eax, eax
    .ENDIF
    ret
_BBCODE_URL ENDP


;------------------------------------------------------------------------------
; _BBCODE_LinkUrlTitle - Seperate the '=www.site.com]title' string to a url and title
; ; or handle [url]www.site.com[/url] without a title
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
_BBCODE_LinkUrlTitle PROC USES EBX ECX EDI ESI lpszHrefString:DWORD, dwHrefStringLength:DWORD, lpszUrl:DWORD, lpszTitle:DWORD

    .IF dwHrefStringLength == 0 || lpszHrefString == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    mov ebx, 0
    mov esi, lpszHrefString
    movzx eax, byte ptr [esi]
    
    .IF al == '=' ; url is specified
        mov edi, lpszUrl
        mov ecx, lpszTitle ; store in title as well, just in case title is empty
        inc ebx
        inc esi
        movzx eax, byte ptr [esi]
        .WHILE ebx < dwHrefStringLength && al != 0 && al != ']'
            mov byte ptr [edi], al
            mov byte ptr [ecx], al
            inc edi
            inc ecx
            inc ebx
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
        .IF al == 0
            ; we hit end of string instead of another ] mark, so fail
            mov edi, lpszUrl
            mov byte ptr [edi], 0
            mov edi, lpszTitle
            mov byte ptr [edi], 0
            mov eax, FALSE
            ret
        .ELSE
            mov byte ptr [edi], 0
            mov byte ptr [ecx], 0                
        .ENDIF
        
        ; continue on to get title
        inc ebx
        inc esi
        movzx eax, byte ptr [esi]
        .IF al == 0 ; we just have a url, title already set to this, so return true
            mov eax, TRUE
            ret
        .ENDIF
        
        ; otherwise get title till end of string
        mov edi, lpszTitle
        movzx eax, byte ptr [esi]
        .WHILE ebx < dwHrefStringLength && al != 0
            mov byte ptr [edi], al
            inc edi
            inc ebx
            inc esi
            movzx eax, byte ptr [esi]
        .ENDW
        mov byte ptr [edi], 0
        mov eax, TRUE
        ret

    .ELSEIF al == ']' ; title is url as well
        mov edi, lpszUrl
        mov ecx, lpszTitle
        inc ebx
        inc esi
        .WHILE ebx < dwHrefStringLength && al != 0
            mov byte ptr [edi], al
            mov byte ptr [ecx], al
            inc edi
            inc ecx
            inc ebx
            inc esi
            movzx eax, byte ptr [esi]            
        .ENDW
        mov byte ptr [edi], 0
        mov byte ptr [ecx], 0           
        mov eax, TRUE
        ret
    .ENDIF

    mov eax, FALSE
    ret
_BBCODE_LinkUrlTitle ENDP






;==============================================================================
; Utility  Functions
;==============================================================================


;------------------------------------------------------------------------------
; GetTagContents - Gets text from between tags. If dwType =:
; 0 - <pre> to </pre>
; 1 - <code> to </code> 
; 2 - <q> to <q>
; 3 - <quote> to <quote>
; 4 - <blockq> to <blockq>
; 5 - <a> to </a>
;
; Returns in eax pointer to zero terminated string or null if error/no text 
;------------------------------------------------------------------------------
GetTagContents PROC USES EBX EDI ESI lpszString:DWORD, dwSize:DWORD, dwTokenLength:DWORD, dwType:DWORD, dwTagBracket:DWORD
    LOCAL nSize:DWORD
    LOCAL saveesi:DWORD
    LOCAL lpszText:DWORD
    LOCAL lpszTagContentsText:DWORD
    LOCAL nLengthTagContentsText:DWORD
    LOCAL nLengthTag:DWORD
    LOCAL nLength:DWORD
    LOCAL bFoundEndTag:DWORD
    LOCAL szTag[16]:BYTE
    
    ;PrintText 'GetTagContents'
    .IF lpszString == NULL || dwSize == NULL
        mov eax, NULL
        ret
    .ENDIF
    
    .IF dwType > GETTAG_MAX ; if unknown type return 0
        mov eax, 0
        ret
    .ENDIF
    
    mov ebx, dwSize
    mov eax, [ebx]
    mov nSize, eax

    mov ebx, lpszString
    mov eax, [ebx]
    .IF dwType == GETTAG_ALINK
        add eax, 3 ; skip over <a_ 
    .ELSEIF dwType == GETTAG_URL
        add eax, 4 ; skip over [url
    .ELSE
        add eax, dwTokenLength
    .ENDIF
    mov lpszText, eax

    mov bFoundEndTag, FALSE
    mov nLengthTagContentsText, 0
    mov eax, 0
    mov esi, lpszText

    .WHILE (eax <= nSize)
        movzx ebx, byte ptr [esi]
        
        .IF bl == '/' ; get end tag
            mov nLengthTag, 0
            inc esi
            movzx ebx, byte ptr [esi]
            lea edi, szTag
            mov eax, nLengthTagContentsText
            .IF dwTagBracket == GETTAG_BRACKET_ANGLE
                .WHILE (eax <= nSize) && bl != '>'
                    mov byte ptr [edi], bl
                    inc edi
                    inc esi
                    movzx ebx, byte ptr [esi]
                    inc nLengthTag
                    inc nLengthTagContentsText
                    mov eax, nLengthTagContentsText
                .ENDW
            .ELSEIF dwTagBracket == GETTAG_BRACKET_SQUARE
                .WHILE (eax <= nSize) && bl != ']'
                    mov byte ptr [edi], bl
                    inc edi
                    inc esi
                    movzx ebx, byte ptr [esi]
                    inc nLengthTag
                    inc nLengthTagContentsText
                    mov eax, nLengthTagContentsText
                .ENDW
            .ELSE
                IFDEF DEBUG32
                    PrintText 'Bracket type not implemented yet'
                ENDIF
                mov eax, 0
                ret
            .ENDIF
            mov byte ptr [edi], 0 ; end null szTag
            inc nLengthTagContentsText
            inc esi
            mov saveesi, esi ; save esi
            ;PrintStringByAddr esi
            ;lea eax, szTag
            ;DbgDump eax, nLengthTag
            
            ; got tag, check if it matches the one we want
            .IF dwType == GETTAG_PRE ; </pre>
                Invoke szCmpi, Addr szPreTag, Addr szTag, 3
                .IF eax == 0 ; match
                    sub nLengthTagContentsText, 5 ; take </pre
                    mov bFoundEndTag, TRUE
                    .BREAK
                .ELSE
                    inc nLengthTagContentsText
                .ENDIF
            .ELSEIF dwType == GETTAG_CODE ; </code>
                ;PrintText 'GETTAG_CODE'
                Invoke szCmpi, Addr szCodeTag, Addr szTag, 4
                .IF eax == 0 ; match
                    ;PrintText 'match'
                    sub nLengthTagContentsText, 6 ; take </code
                    mov bFoundEndTag, TRUE
                    .BREAK
                .ELSE 
                    inc nLengthTagContentsText
                .ENDIF
            .ELSEIF dwType == GETTAG_Q ; </q>
                Invoke szCmpi, Addr szQuoteTag1, Addr szTag, 1
                .IF eax == 0 ; match
                    sub nLengthTagContentsText, 3 ; take </q
                    mov bFoundEndTag, TRUE
                    .BREAK
                .ELSE 
                    inc nLengthTagContentsText
                .ENDIF                
            .ELSEIF dwType == GETTAG_QUOTE ; </quote>
                Invoke szCmpi, Addr szQuoteTag2, Addr szTag, 5
                .IF eax == 0 ; match
                    sub nLengthTagContentsText, 7 ; take </quote
                    mov bFoundEndTag, TRUE
                    .BREAK
                .ELSE 
                    inc nLengthTagContentsText
                .ENDIF  
            .ELSEIF dwType == GETTAG_BLOCKQ; </blockq>
                Invoke szCmpi, Addr szQuoteTag3, Addr szTag, 6
                .IF eax == 0 ; match
                    sub nLengthTagContentsText, 8 ; take </blockq
                    mov bFoundEndTag, TRUE
                    .BREAK
                .ELSE 
                    inc nLengthTagContentsText
                .ENDIF
            .ELSEIF dwType == GETTAG_ALINK; </a>
                Invoke szCmpi, Addr szAlinkTag, Addr szTag, 1
                .IF eax == 0 ; match
                    sub nLengthTagContentsText, 3 ; take </a
                    mov bFoundEndTag, TRUE
                    .BREAK
                .ELSE 
                    inc nLengthTagContentsText
                .ENDIF  
            .ELSEIF dwType == GETTAG_URL ; [/url]
                Invoke szCmpi, Addr szUrlTag, Addr szTag, 3
                .IF eax == 0 ; match
                    sub nLengthTagContentsText, 5 ; take [/url
                    mov bFoundEndTag, TRUE
                    .BREAK
                .ELSE 
                    inc nLengthTagContentsText
                .ENDIF             
            .ELSE
                IFDEF DEBUG32
                PrintText 'Error value not supported yet'
                ENDIF
            .ENDIF
            mov esi, saveesi
        .ENDIF
        inc esi
        inc nLengthTagContentsText
        mov eax, nLengthTagContentsText
    .ENDW    
    
    ; at end, either ran out of text and didnt find any end tag
    ; or we broke out of loop and found end tag
    .IF bFoundEndTag == FALSE
        mov eax, NULL
        ret
    .ENDIF

    mov eax, nLengthTagContentsText
    add eax, 4
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax == NULL
        ret
    .ENDIF
    mov lpszTagContentsText, eax
    
    ;PrintDec nLengthTagContentsText
    
    ; adjust length to skip back over the / and <
    mov ebx, lpszString
    mov eax, [ebx]
    .IF dwType == GETTAG_ALINK
        add eax, 3 ; skip over /a>
    .ELSEIF dwType == GETTAG_URL
        add eax, 4 ; skip over /url]
    .ELSE
        add eax, dwTokenLength
    .ENDIF
    mov lpszText, eax

    Invoke RtlMoveMemory, lpszTagContentsText, lpszText, nLengthTagContentsText
    mov eax, lpszTagContentsText
    ret

GetTagContents ENDP


;------------------------------------------------------------------------------
; GetFontVariant - Creates a font based on the base font and modifies it for 
; required features: bold, italic, underline etc.
; 
; Returns in eax the new font handle.
;------------------------------------------------------------------------------
GetFontVariant PROC USES ECX EDX hdc:DWORD, hfontSource:DWORD, Styles:DWORD
    LOCAL logFont:LOGFONT
    LOCAL hFont:DWORD

    Invoke RtlZeroMemory, Addr logFont, SIZEOF LOGFONT
    Invoke GetStockObject, SYSTEM_FONT
    mov hFont, eax
    Invoke SelectObject, hdc, hFont
    Invoke GetObject, hfontSource, SIZEOF LOGFONT, Addr logFont
    .IF eax == 0
        ret
    .ENDIF    

    mov eax, Styles
    and eax, FV_PRE
    .IF eax == FV_PRE
        mov eax, logFont.lfHeight
        .IF sdword ptr eax < 0
            add logFont.lfHeight, 4d;7d
        .ELSE
            sub logFont.lfHeight, 2d;4d
        .ENDIF
        lea eax, szPreFont
        lea ecx, logFont.lfFaceName
        Invoke lstrcpyn, ecx, eax, 32

    .ELSE

        mov eax, Styles
        and eax, FV_QUOTE
        .IF eax == FV_QUOTE
            mov eax, logFont.lfHeight
            .IF sdword ptr eax < 0
                sub logFont.lfHeight, 4d;7d
            .ELSE
                add logFont.lfHeight, 2d;4d
            .ENDIF        
            mov logFont.lfItalic, TRUE
        .ELSE
            mov eax, Styles
            and eax, FV_BOLD
            .IF eax == FV_BOLD
                mov eax, FW_BOLD
            .ELSE
                mov eax, FW_NORMAL
            .ENDIF
            mov logFont.lfWeight, eax
    
            mov eax, Styles
            and eax, FV_ITALIC
            .IF eax == FV_ITALIC
                mov eax, TRUE
            .ELSE
                mov eax, FALSE
            .ENDIF
            mov logFont.lfItalic, al
    
            mov eax, Styles
            and eax, FV_UNDERLINE
            .IF eax == FV_UNDERLINE
                mov eax, TRUE
            .ELSE
                mov eax, FALSE
            .ENDIF    
            mov logFont.lfUnderline, al
    
            mov eax, Styles
            and eax, FV_SUPERSCRIPT or FV_SUBSCRIPT
            .IF eax == FV_SUPERSCRIPT or FV_SUBSCRIPT
                xor edx, edx
                mov eax, logFont.lfHeight
                mov ebx, 7
                mul ebx
                mov ecx, 10d
                div ecx
                ;mov eax, logFont.lfHeight * 7 / 10;
                mov logFont.lfHeight, eax
            .ENDIF
        .ENDIF
    .ENDIF
    Invoke CreateFontIndirect, Addr logFont
    ; eax contains new font handle
    ret
GetFontVariant ENDP


;------------------------------------------------------------------------------
; ColorStackPush - Pushes color onto self contained stack (not globally seen)
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
ColorStackPush PROC USES EBX ECX hdc:DWORD, clr:DWORD, lpStack:DWORD, lpdwStackTop:DWORD
    LOCAL dwStackTop:DWORD

    .IF lpStack == NULL || lpdwStackTop == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov ebx, lpdwStackTop ; get ptr to stacktop
    mov eax, [ebx] ; dwStackTop in eax
    mov dwStackTop, eax
    .IF eax < COLORSTACK_SIZE
        Invoke GetTextColor, hdc
        mov ebx, lpStack ; get ptr to stack 
        mov ecx, dwStackTop
        mov dword ptr [ebx + ecx *DWORD], eax ; save color to stack
        inc ecx ; inc dwStackTop
        mov ebx, lpdwStackTop ; get ptr to stacktop
        mov [ebx], ecx ; save new dwStackTop
    .ENDIF
    Invoke SetTextColor, hdc, clr
    mov eax, TRUE
    ret
ColorStackPush ENDP


;------------------------------------------------------------------------------
; ColorStackPop - Pops color from self contained stack (not globally seen)
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
ColorStackPop PROC USES EBX ECX hdc:DWORD, lpStack:DWORD, lpdwStackTop:DWORD
    LOCAL clr:DWORD
    LOCAL okay:DWORD
    LOCAL dwStackTop:DWORD

    .IF lpStack == NULL || lpdwStackTop == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov ebx, lpdwStackTop ; get ptr to stacktop
    mov eax, [ebx] ; dwStackTop in eax
    mov dwStackTop, eax

    .IF dwStackTop > 0
        mov okay, TRUE
    .ELSE
        mov okay, FALSE
    .ENDIF

    .IF okay
        mov ebx, lpStack ; get ptr to stack
        mov ecx, dwStackTop
        mov eax, dword ptr [ebx + ecx *DWORD] ; get clr from stack
        mov clr, eax
        dec ecx ; dec dwStackTop
        mov ebx, lpdwStackTop ; get ptr to stacktop
        mov [ebx], ecx ; save new dwStackTop        
    .ELSE
        mov ebx, lpStack ; get ptr to stack
        mov eax, dword ptr [ebx]
        mov clr, eax
    .ENDIF
    Invoke SetTextColor, hdc, clr
    mov eax, okay
    ret
ColorStackPop ENDP


;------------------------------------------------------------------------------
; ParseColor - Parse color string '#CF0924' with/without quotes and # 
;
; Returns in eax an RGB color
;------------------------------------------------------------------------------
ParseColor PROC USES EBX ECX EDX ESI String:DWORD
    LOCAL dwRed:DWORD
    LOCAL dwGreen:DWORD
    LOCAL dwBlue:DWORD

    mov ebx, String
    mov eax,dword ptr [ebx]
    movsx ecx,byte ptr [eax]
    cmp ecx,27h ; '
    je LABEL_0x012127CD
    mov edx,dword ptr [ebx]
    movsx eax,byte ptr [edx]
    cmp eax,22h ; "
    jne LABEL_0x012127D6
    
    LABEL_0x012127CD:
    mov ecx,dword ptr [ebx]
    add ecx,1h
    mov dword ptr [ebx],ecx
    
    LABEL_0x012127D6:
    mov edx,dword ptr [ebx]
    movsx eax,byte ptr [edx]
    cmp eax,23h ; #
    jne LABEL_0x012127EA
    mov ecx,dword ptr [ebx]
    add ecx,1h
    mov dword ptr [ebx],ecx
    
    LABEL_0x012127EA:
    mov edx,1h
    imul eax,edx,0h
    mov ebx, String
    mov ecx,dword ptr [ebx]
    movzx edx,byte ptr [ecx+eax]
    push edx
    call HexDigit
    mov esi,eax
    shl esi,4h
    mov eax,1h
    shl eax,0h
    mov ecx,dword ptr [ebx]
    movzx edx,byte ptr [ecx+eax]
    push edx
    call HexDigit
    or esi,eax
    mov dword ptr [dwRed],esi
    mov eax,1h
    shl eax,1h
    mov ecx,dword ptr [ebx]
    movzx edx,byte ptr [ecx+eax]
    push edx
    call HexDigit
    mov esi,eax
    shl esi,4h
    mov eax,1h
    imul ecx,eax,3h
    mov ebx, String
    mov edx,dword ptr [ebx]
    movzx eax,byte ptr [edx+ecx]
    push eax
    call HexDigit
    or esi,eax
    mov dword ptr [dwGreen],esi
    mov ecx,1h
    shl ecx,2h
    mov edx,dword ptr [ebx]
    movzx eax,byte ptr [edx+ecx]
    push eax
    call HexDigit
    mov esi,eax
    shl esi,4h
    mov ecx,1h
    imul edx,ecx,5h
    mov ebx, String
    mov eax,dword ptr [ebx]
    movzx ecx,byte ptr [eax+edx]
    push ecx
    call HexDigit
    or esi,eax
    mov dword ptr [dwBlue],esi
    movzx eax,byte ptr [dwRed]
    movzx edx,byte ptr [dwGreen]
    shl edx,8h
    or eax,edx
    movzx ecx,byte ptr [dwBlue]
    shl ecx,10h
    or eax,ecx
    ret
ParseColor ENDP


;------------------------------------------------------------------------------
; HexDigit - Used by ParseColor to convert hex ascii char to dword value.
;------------------------------------------------------------------------------
HexDigit PROC lpCharHex:DWORD
    movzx eax, byte ptr [lpCharHex]
    .IF al >= '0' && al <= '9'
        sub eax, 30h
    .ELSEIF al >= 'A' && al <= 'F'
        sub eax, 37h
    .ELSEIF al >= 'a' && al <= 'f' 
        sub eax, 57h
    .ELSE
        mov eax, 0
    .ENDIF
    ret
HexDigit ENDP


;------------------------------------------------------------------------------
; ListStackPush - Pushes (Stores) list information onto list stack and 
; increments list stacktop
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
ListStackPush PROC USES EBX ECX dwListType:DWORD, dwItemIndent:DWORD, dwBulletIndent:DWORD, lpStack:DWORD, lpdwStackTop:DWORD
    LOCAL dwStackTop:DWORD
    LOCAL pListEntry:DWORD
    
    .IF lpStack == NULL || lpdwStackTop == NULL
        mov eax, FALSE
        ret
    .ENDIF

    mov ebx, lpdwStackTop ; get ptr to stacktop
    mov eax, [ebx] ; dwStackTop in eax
    mov dwStackTop, eax
    .IF eax < LISTSTACK_SIZE
        mov eax, dwStackTop
        mov ebx, SIZEOF LISTINFO
        mul ebx
        add eax, lpStack
        mov ebx, eax
        
        ; save information to listinfo
        mov eax, dwListType
        mov [ebx].LISTINFO.ListType, eax
        mov eax, dwItemIndent
        mov [ebx].LISTINFO.ItemIndent, eax
        mov eax, dwBulletIndent
        mov [ebx].LISTINFO.BulletIndent, eax
        
        mov eax, dwStackTop
        inc eax
        mov ebx, lpdwStackTop ; get ptr to stacktop
        mov [ebx], eax ; save new dwStackTop
    .ENDIF
    mov eax, TRUE
    ret
ListStackPush ENDP


;------------------------------------------------------------------------------
; ListStackPop - Pops (retrieves) list information from list stack and 
; decrements list stacktop
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
ListStackPop PROC USES EBX ECX lpdwListType:DWORD, lpdwItemIndent:DWORD, lpdwBulletIndent:DWORD, lpStack:DWORD, lpdwStackTop:DWORD
    LOCAL dwStackTop:DWORD
    LOCAL okey:DWORD
    LOCAL dwListType:DWORD
    LOCAL dwItemIndent:DWORD
    LOCAL dwBulletIndent:DWORD

    .IF lpStack == NULL || lpdwStackTop == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov ebx, lpdwStackTop ; get ptr to stacktop
    mov eax, [ebx] ; dwStackTop in eax
    mov dwStackTop, eax

    .IF dwStackTop > 0
        mov okey, TRUE
    .ELSE
        mov okey, FALSE
    .ENDIF

    .IF okey
        mov eax, dwStackTop
        dec eax
        mov ebx, SIZEOF LISTINFO
        mul ebx
        add eax, lpStack
        mov ebx, eax
    .ELSE
        mov ebx, lpStack ; get ptr to stack 
    .ENDIF

    ; get information from listinfo
    mov eax, [ebx].LISTINFO.ListType
    mov dwListType, eax
    mov eax, [ebx].LISTINFO.ItemIndent
    mov dwItemIndent, eax
    mov eax, [ebx].LISTINFO.BulletIndent
    mov dwBulletIndent, eax

    .IF lpdwListType != NULL
        mov ebx, lpdwListType
        mov eax, dwListType
        mov [ebx], eax
    .ENDIF
    .IF lpdwItemIndent != NULL
        mov ebx, lpdwItemIndent
        mov eax, dwItemIndent
        mov [ebx], eax
    .ENDIF
    .IF lpdwBulletIndent != NULL
        mov ebx, lpdwBulletIndent
        mov eax, dwBulletIndent
        mov [ebx], eax
    .ENDIF
    
    .IF okey
        mov eax, dwStackTop
        dec eax
        mov ebx, lpdwStackTop ; get ptr to stacktop
        mov [ebx], eax ; save new dwStackTop
    .ENDIF

    mov eax, TRUE
    ret
ListStackPop ENDP


;------------------------------------------------------------------------------
; ListStackPeek - Peeks (reads) list information from list stack. 
; Does not adjust stacktop
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
ListStackPeek PROC USES EBX ECX lpdwListType:DWORD, lpdwItemIndent:DWORD, lpdwBulletIndent:DWORD, lpStack:DWORD, dwStackTop:DWORD
    LOCAL okey:DWORD
    LOCAL dwListType:DWORD
    LOCAL dwItemIndent:DWORD
    LOCAL dwBulletIndent:DWORD

    .IF lpStack == NULL
        mov eax, FALSE
        ret
    .ENDIF

    .IF dwStackTop > 0
        mov okey, TRUE
    .ELSE
        mov okey, FALSE
    .ENDIF

    .IF okey
        mov eax, dwStackTop
        dec eax
        mov ebx, SIZEOF LISTINFO
        mul ebx
        add eax, lpStack
        mov ebx, eax
    .ELSE
        mov ebx, lpStack ; get ptr to stack 
    .ENDIF

    ; get information from listinfo
    mov eax, [ebx].LISTINFO.ListType
    mov dwListType, eax
    mov eax, [ebx].LISTINFO.ItemIndent
    mov dwItemIndent, eax
    mov eax, [ebx].LISTINFO.BulletIndent
    mov dwBulletIndent, eax

    .IF lpdwListType != NULL
        mov ebx, lpdwListType
        mov eax, dwListType
        mov [ebx], eax
    .ENDIF
    .IF lpdwItemIndent != NULL
        mov ebx, lpdwItemIndent
        mov eax, dwItemIndent
        mov [ebx], eax
    .ENDIF
    .IF lpdwBulletIndent != NULL
        mov ebx, lpdwBulletIndent
        mov eax, dwBulletIndent
        mov [ebx], eax
    .ENDIF
    mov eax, TRUE
    ret
ListStackPeek ENDP


;------------------------------------------------------------------------------
; ListStackSetCounter - Sets ListType field in list stack. 
; Does not adjust stacktop.
;
; Used as a counter for ordered lists if ListType > 0. ListType == 0 is an
; unordered list.
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
ListStackSetCounter PROC dwValue:DWORD, lpStack:DWORD, dwStackTop:DWORD
    LOCAL okey:DWORD

    .IF lpStack == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    .IF dwStackTop > 0
        mov okey, TRUE
    .ELSE
        mov okey, FALSE
    .ENDIF

    .IF okey
        mov eax, dwStackTop
        dec eax
        mov ebx, SIZEOF LISTINFO
        mul ebx
        add eax, lpStack
        mov ebx, eax
    .ELSE
        mov ebx, lpStack ; get ptr to stack 
    .ENDIF    
    
    mov eax, dwValue
    mov [ebx].LISTINFO.ListType, eax
    
    ret

ListStackSetCounter ENDP


;------------------------------------------------------------------------------
; szCatStrToWide - Concat a zero terminated source ascii string 
; (also converts it to wide unicode) to a double null terminated destination 
; wide unicode string.
; 
; Returns 0 in eax
;------------------------------------------------------------------------------
szCatStrToWide PROC USES EDI ESI lpszWideDest:DWORD, lpszSource:DWORD
    mov edi, lpszWideDest
    mov esi, lpszSource
    ; Get double null end of wide destination string 
    movzx eax, word ptr [edi]
    .WHILE ax != 0
        inc edi
        inc edi
        movzx eax, word ptr [edi]
    .ENDW
    
    ; Start adding bytes to destination string
    movzx eax, byte ptr [esi]
    .WHILE al != 0
        mov byte ptr [edi], al
        mov byte ptr [edi+1], 0
        inc edi
        inc edi
        inc esi
        movzx eax, byte ptr [esi]
    .ENDW
    mov byte ptr [edi], 0
    mov byte ptr [edi+1], 0
    xor eax, eax
    ret
szCatStrToWide ENDP 




;------------------------------------------------------------------------------
; DrawTextEXTLink - Control for hyperlink window
;
; Returns in eax handle to the new control or NULL if an error occured.
;------------------------------------------------------------------------------
DrawTextEXTLinkCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax
    
    Invoke GetClassInfoEx, hinstance, Addr szDrawTextEXTLinkClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        lea eax, szDrawTextEXTLinkClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, DrawTextEXTLinkProc
        mov wc.lpfnWndProc, eax
        Invoke LoadCursor, NULL, IDC_HAND
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL ;COLOR_WINDOW+1;
        mov wc.style, 0
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 36d ; 0=mouseover, 4=enabled, 8=updateflag, 12=totallinkurls, 16=linkurlarray,20=hFontNormal,24=hFontUnderline,28=backcolor,32=clrtext
        Invoke RegisterClassEx, Addr wc
    .ENDIF
    
    Invoke CreateWindowEx, NULL, Addr szDrawTextEXTLinkClass, NULL, WS_CHILD or WS_VISIBLE, xpos, ypos, controlwidth, controlheight, hWndParent, DTELinkID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        dec DTELinkID
        ;PrintDec hControl
    .ENDIF
    mov eax, hControl    
    ret

DrawTextEXTLinkCreate ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkProc - Main processing window for our hyperlink window
;------------------------------------------------------------------------------
DrawTextEXTLinkProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT

    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        mov eax, LINKURL_SIZE
        mov ebx, SIZEOF LINKURL
        mul ebx
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax != NULL
            Invoke SetWindowLong, hWin, DTEL_LINKURLSARRAY, eax ; pointer to linkurlarray
        .ENDIF
        Invoke DrawTextEXTLinkReset, hWin
        Invoke SetWindowLong, hWin, DTEL_ENABLEDSTATE, FALSE ; EnabledState
        Invoke GetSysColor, COLOR_HOTLIGHT
        Invoke SetWindowLong, hWin, DTEL_TEXTCOLOR, eax
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke GetWindowLong, hWin, DTEL_LINKURLSARRAY ; pointer to linkurlarray
        .IF eax != NULL
            Invoke GlobalFree, eax
        .ENDIF
        mov eax, 0
        ret

    .ELSEIF eax == WM_LBUTTONUP
        Invoke GetWindowLong, hWin, DTEL_ENABLEDSTATE ; EnabledState
        .IF eax == TRUE
            Invoke SetWindowLong, hWin, DTEL_MOUSEOVER, FALSE ; Mouseover
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke DrawTextEXTLinkNotify, hWin, DTELN_MOUSECLICK
            Invoke DrawTextEXTLinkClick, hWin
        .ENDIF

    .ELSEIF eax == WM_MOUSEMOVE
        .IF wParam == 0 && lParam == 0 ; for fake mousemove if needed in future
            Invoke SetWindowLong, hWin, DTEL_MOUSEOVER, TRUE ; Mouseover
            .IF eax != TRUE
                mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
                mov TE.dwFlags, TME_LEAVE
                mov eax, hWin
                mov TE.hwndTrack, eax
                mov TE.dwHoverTime, NULL
                Invoke TrackMouseEvent, Addr TE
            .ENDIF            
        .ELSE
            Invoke GetWindowLong, hWin, DTEL_ENABLEDSTATE ; EnabledState
            .IF eax == TRUE            
                Invoke SetWindowLong, hWin, DTEL_MOUSEOVER, TRUE ; Mouseover
                .IF eax != TRUE ; only trigger repaint once
                    Invoke InvalidateRect, hWin, NULL, TRUE
                    Invoke DrawTextEXTLinkNotify, hWin, DTELN_MOUSEOVER
                    mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
                    mov TE.dwFlags, TME_LEAVE
                    mov eax, hWin
                    mov TE.hwndTrack, eax
                    mov TE.dwHoverTime, NULL
                    Invoke TrackMouseEvent, Addr TE
                .ENDIF
            .ENDIF
        .ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        Invoke GetWindowLong, hWin, DTEL_ENABLEDSTATE ; EnabledState
        .IF eax == TRUE
            Invoke SetWindowLong, hWin, DTEL_MOUSEOVER, FALSE ; Mouseover
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke DrawTextEXTLinkNotify, hWin, DTELN_MOUSELEAVE
        .ENDIF

    .ELSEIF eax == WM_KILLFOCUS
        Invoke SetWindowLong, hWin, DTEL_MOUSEOVER, FALSE ; Mouseover
        Invoke InvalidateRect, hWin, NULL, TRUE

    .ELSEIF eax == WM_ERASEBKGND
        ;Invoke GetWindowLong, hWin, DTEL_ENABLEDSTATE ; EnabledState
        ;.IF eax == TRUE
            mov eax, 1
        ;.ELSE
        ;    mov eax, 0
        ;.ENDIF
        ret        

    .ELSEIF eax == WM_PAINT
        ;Invoke GetWindowLong, hWin, DTEL_ENABLEDSTATE ; EnabledState
        ;.IF eax == TRUE    
            Invoke DrawTextEXTLinkPaint, hWin
            mov eax, 0
        ;.ELSE
        ;    mov eax, 1
        ;.ENDIF
        ret
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret
DrawTextEXTLinkProc ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkPaint - paints the link text in the visible regions
;------------------------------------------------------------------------------
DrawTextEXTLinkPaint PROC hWin:DWORD
    LOCAL ptrLinkUrlArray:DWORD
    LOCAL ptrLinkUrlEntry:DWORD
    LOCAL nTotalLinkUrls:DWORD
    LOCAL nCurrentLinkUrl:DWORD
    LOCAL lpszUrl:DWORD
    LOCAL lpszTitle:DWORD
    LOCAL hdc:DWORD
    LOCAL hdcMem:DWORD
    LOCAL hbmMem:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL BackColor:DWORD
    LOCAL TextColor:DWORD
    LOCAL SavedDC:DWORD
    LOCAL MouseOver:DWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL clientrect:RECT
    LOCAL rect:RECT
    LOCAL pt:POINT
    LOCAL hRgn:DWORD
    
    ;PrintText 'DrawTextEXTLinkPaint'
    
    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    Invoke GetClientRect, hWin, Addr clientrect

    Invoke GetWindowLong, hWin, DTEL_LINKURLSTOTAL ; total link urls
    .IF eax == 0
        Invoke EndPaint, hWin, Addr ps
        ret
    .ENDIF
    mov nTotalLinkUrls, eax
    ;PrintDec nTotalLinkUrls
    
    Invoke GetWindowLong, hWin, DTEL_LINKURLSARRAY ; pointer to link url arrays
    .IF eax == 0
        Invoke EndPaint, hWin, Addr ps
        ret
    .ENDIF
    mov ptrLinkUrlArray, eax
    mov ptrLinkUrlEntry, eax    
    
    Invoke GetWindowLong, hWin, DTEL_MOUSEOVER ; mouseover
    mov MouseOver, eax
    Invoke GetWindowLong, hWin, DTEL_BACKCOLOR ; back color
    mov BackColor, eax    
    Invoke GetWindowLong, hWin, DTEL_TEXTCOLOR ; text color
    mov TextColor, eax
    Invoke GetCursorPos, Addr pt
    Invoke ScreenToClient, hWin, Addr pt    
    
    ;Invoke SaveDC, hdc
    ;mov SavedDC, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, clientrect.right, clientrect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax    

    ;Invoke GetStockObject, HOLLOW_BRUSH
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, BackColor    
    Invoke FillRect, hdcMem, Addr clientrect, hBrush
    
    Invoke SetBkMode, hdcMem, OPAQUE
    Invoke SetBkColor, hdcMem, BackColor    
    ;Invoke SetBkMode, hdcMem, OPAQUE
    ;Invoke GetWindowLong, hWin, DTEL_BACKCOLOR ; back color
    ;Invoke SetBkColor, hdcMem, eax
    
    Invoke SetTextColor, hdcMem, TextColor

    mov nCurrentLinkUrl, 0
    mov eax, 0
    .WHILE eax < nTotalLinkUrls
        mov ebx, ptrLinkUrlEntry
        lea eax, [ebx].LINKURL.szLinkUrl
        mov lpszUrl, eax
        lea eax, [ebx].LINKURL.szLinkTitle
        mov lpszTitle, eax        
        lea eax, [ebx].LINKURL.rcLinkUrl
        Invoke CopyRect, Addr rect, eax

        Invoke PtInRect, Addr rect, pt.x, pt.y
        .IF eax == TRUE && MouseOver == TRUE
            Invoke GetWindowLong, hWin, DTEL_FONTUNDERLINE ; font underline
            Invoke SelectObject, hdcMem, eax
        .ELSE
            Invoke GetWindowLong, hWin, DTEL_FONTNORMAL ; font normal
            Invoke SelectObject, hdcMem, eax
        .ENDIF
 
        Invoke DrawText, hdcMem, lpszTitle, -1, Addr rect, DT_LEFT

        add ptrLinkUrlEntry, SIZEOF LINKURL
        inc nCurrentLinkUrl
        mov eax, nCurrentLinkUrl
    .ENDW    
    
    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, clientrect.right, clientrect.bottom, hdcMem, 0, 0, SRCCOPY
    

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    .IF hOldBrush != 0
        Invoke SelectObject, hdcMem, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF       
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem
    
    ;Invoke RestoreDC, hdc, SavedDC

    Invoke EndPaint, hWin, Addr ps

    ret
DrawTextEXTLinkPaint ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkAddUrl - Adds a hyper link with url, title and rect that the
; link is in. The rect is coverted to a region and added to any existing region
; the rest is excluded from view. Only these regions are visible over the 
; DrawHTMLCODE or DrawBBCODE text and thus only when mouse moves over these
; regions it will change cursor and update the link text, clicking the mouse 
; in one of regions will call to DrawTextEXTLinkClick which will determine
; which link was clicked (based on the current cursor position vs the stored
; rect's for each link added via this function.)
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
DrawTextEXTLinkAddUrl PROC USES EBX hWin:DWORD, lpRect:DWORD, lpszLinkUrl:DWORD, lpszLinkTitle:DWORD
    LOCAL ptrLinkUrlArray:DWORD
    LOCAL ptrLinkUrlEntry:DWORD
    LOCAL nTotalLinkUrls:DWORD
    LOCAL hWinRgn:DWORD
    LOCAL hRgn:DWORD
    LOCAL rect:RECT

    ;PrintText 'DrawTextEXTLinkAddUrl'

    .IF hWin == 0 || lpszLinkUrl == 0
        mov eax, FALSE
        ret
    .ENDIF

    Invoke GetWindowLong, hWin, DTEL_LINKURLSTOTAL ; total link urls
    .IF eax >= LINKURL_SIZE
        mov eax, FALSE
        ret
    .ENDIF
    mov nTotalLinkUrls, eax

    Invoke GetWindowLong, hWin, DTEL_LINKURLSARRAY ; pointer to link url arrays
    .IF eax != 0
        mov ptrLinkUrlArray, eax
        
        mov eax, nTotalLinkUrls
        mov ebx, SIZEOF LINKURL
        mul ebx
        add eax, ptrLinkUrlArray
        mov ptrLinkUrlEntry, eax

        Invoke CopyRect, ptrLinkUrlEntry, lpRect
        mov ebx, ptrLinkUrlEntry
        lea ebx, [ebx].LINKURL.szLinkUrl
        Invoke lstrcpyn, ebx, lpszLinkUrl, LINKURL_MAXLENGTH
        
        mov ebx, ptrLinkUrlEntry
        lea ebx, [ebx].LINKURL.szLinkTitle
        Invoke lstrcpyn, ebx, lpszLinkTitle, LINKURL_MAXLENGTH
        
;        Invoke CopyRect, Addr rect, lpRect
;
;        ;PrintDec rect.left
;        ;PrintDec rect.top
;
;        .IF nTotalLinkUrls == 0
;            ;PrintText 'FIRST REGION'
;            
;            ;Invoke CreateRectRgn, 0, 0, 0, 0
;            ;mov hRgn, eax
;            Invoke CreateRectRgn, rect.left, rect.top, rect.right, rect.bottom
;            mov hWinRgn, eax
;            ;Invoke CombineRgn, hWinRgn, hWinRgn, hRgn, RGN_OR
;        .ELSE
;            Invoke CreateRectRgn, 0, 0, 0, 0
;            mov hWinRgn, eax
;            Invoke GetWindowRgn, hWin, hWinRgn
;            .IF eax == NULLREGION
;                ;PrintText 'NULLREGION'
;                Invoke CreateRectRgn, rect.left, rect.top, rect.right, rect.bottom
;                mov hRgn, eax
;                Invoke CombineRgn, hWinRgn, hWinRgn, hRgn, RGN_COPY
;             .ELSEIF eax == ERROR
;                ;PrintText 'ERROR'
;                Invoke CreateRectRgn, rect.left, rect.top, rect.right, rect.bottom
;                mov hWinRgn, eax
;            .ELSE
;                ;PrintText 'OTHER REGION'
;                Invoke CreateRectRgn, rect.left, rect.top, rect.right, rect.bottom
;                mov hRgn, eax
;                Invoke CombineRgn, hWinRgn, hWinRgn, hRgn, RGN_OR;RGN_OR
;            .ENDIF
;        .ENDIF
;        Invoke SetWindowRgn, hWin, hWinRgn, FALSE
;;        Invoke InvalidateRect, hWin, NULL, FALSE

        inc nTotalLinkUrls
        Invoke SetWindowLong, hWin, DTEL_LINKURLSTOTAL, nTotalLinkUrls ; total link urls

    .ENDIF
    mov eax, TRUE
    ret
DrawTextEXTLinkAddUrl ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkReset - Resets the internal total count of links added and
; sets the DrawTextEXTLink window region to nothing.
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
DrawTextEXTLinkReset PROC USES EBX hWin:DWORD
    LOCAL hWinRgn:DWORD
    
    ;PrintText 'DrawTextEXTLinkReset'
    
    .IF hWin == 0
        mov eax, FALSE
        ret
    .ENDIF

    Invoke SetWindowLong, hWin, DTEL_ENABLEDSTATE, FALSE ; EnabledState 
    Invoke SetWindowLong, hWin, DTEL_LINKURLSTOTAL, 0 ; total link urls
    ;Invoke SetWindowRgn, hWin, NULL, FALSE
    Invoke CreateRectRgn, 0, 0, 0, 0
    mov hWinRgn, eax
    
    Invoke SetWindowRgn, hWin, hWinRgn, FALSE    
    ;Invoke InvalidateRect, hWin, NULL, FALSE
    mov eax, TRUE
    ret
DrawTextEXTLinkReset ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkReady - Called to set all regions once all link urls have been
; added and everything is ready to show. 
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
DrawTextEXTLinkReady PROC USES EBX hWin:DWORD
    LOCAL ptrLinkUrlArray:DWORD
    LOCAL ptrLinkUrlEntry:DWORD
    LOCAL nTotalLinkUrls:DWORD
    LOCAL nCurrentLinkUrl:DWORD
    LOCAL rect:RECT
    LOCAL hWinRgn:DWORD
    LOCAL hRgn:DWORD
    
    ;PrintText 'DrawTextEXTLinkReady'
    ;Invoke SetWindowLong, hWin, DTEL_ENABLEDSTATE, TRUE ; EnabledState 
    ;ret
    
    .IF hWin == 0
        mov eax, FALSE
        ret
    .ENDIF

    Invoke GetWindowLong, hWin, DTEL_LINKURLSTOTAL ; total link urls
    .IF eax == 0
        mov eax, FALSE
        ret
    .ENDIF
    mov nTotalLinkUrls, eax
    
    Invoke GetWindowLong, hWin, DTEL_LINKURLSARRAY ; pointer to link url arrays
    .IF eax == 0
        mov eax, FALSE
        ret
    .ENDIF
    mov ptrLinkUrlArray, eax
    mov ptrLinkUrlEntry, eax    

    Invoke CreateRectRgn, 0, 0, 0, 0
    mov hWinRgn, eax    
    
    mov nCurrentLinkUrl, 0
    mov eax, 0
    .WHILE eax < nTotalLinkUrls
        mov ebx, ptrLinkUrlEntry
        lea eax, [ebx].LINKURL.rcLinkUrl
        Invoke CopyRect, Addr rect, eax
    
        Invoke CreateRectRgn, rect.left, rect.top, rect.right, rect.bottom
        mov hRgn, eax
        Invoke CombineRgn, hWinRgn, hWinRgn, hRgn, RGN_OR
    
        add ptrLinkUrlEntry, SIZEOF LINKURL
        inc nCurrentLinkUrl
        mov eax, nCurrentLinkUrl
    .ENDW    

    Invoke SetWindowRgn, hWin, hWinRgn, FALSE
    ;Invoke InvalidateRect, hWin, NULL, FALSE
    Invoke SetWindowLong, hWin, DTEL_ENABLEDSTATE, TRUE ; EnabledState 
    
    mov eax, TRUE
    ret
DrawTextEXTLinkReady ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkClick - Processes a mouse click and determines which url was
; clicked by comparing the current curosr position vs the stored rect's for 
; each url. Once the correct link has been located the url for that is 
; retrieved. 

; If the url string begins with a # then the rest of the string is assumed to 
; be a resource id, and is converted from the string to a integer. This is
; then passed to the parent window via WM_COMMAND, with the resource id stored 
; in the low word of wParam. This allows a user to specify an 'internal' link
; and process as they see fit.
;
; If the url string does not being with a #, then a call to ShellExecute is
; made and the url is opened in a web browser. 
;
; Returns in eax TRUE if success or FALSE if error
;------------------------------------------------------------------------------
DrawTextEXTLinkClick PROC USES EBX hWin:DWORD
;    LOCAL ptrLinkUrlArray:DWORD
    LOCAL ptrLinkUrlEntry:DWORD
;    LOCAL nTotalLinkUrls:DWORD
;    LOCAL nCurrentLinkUrl:DWORD
    LOCAL hParent:DWORD
    LOCAL lpszUrl:DWORD
;    LOCAL rect:RECT
;    LOCAL pt:POINT
;
;    .IF hWin == 0
;        mov eax, FALSE
;        ret
;    .ENDIF
;
;    Invoke GetWindowLong, hWin, DTEL_LINKURLSTOTAL ; total link urls
;    .IF eax == 0
;        mov eax, FALSE
;        ret
;    .ENDIF
;    mov nTotalLinkUrls, eax
;    
;    Invoke GetWindowLong, hWin, DTEL_LINKURLSARRAY ; pointer to link url arrays
;    .IF eax == 0
;        mov eax, FALSE
;        ret
;    .ENDIF
;    mov ptrLinkUrlArray, eax
;    mov ptrLinkUrlEntry, eax
;
;    Invoke GetParent, hWin
;    mov hParent, eax
;    Invoke GetCursorPos, Addr pt
;    Invoke ScreenToClient, hWin, Addr pt
;    
;    mov nCurrentLinkUrl, 0
;    mov eax, 0
;    .WHILE eax < nTotalLinkUrls
;        mov ebx, ptrLinkUrlEntry
;        lea eax, [ebx].LINKURL.rcLinkUrl
;        Invoke CopyRect, Addr rect, eax
;    
;        Invoke PtInRect, Addr rect, pt.x, pt.y
;        .IF eax == TRUE
;            mov ebx, ptrLinkUrlEntry
;            lea ebx, [ebx].LINKURL.szLinkUrl
;            mov lpszUrl, ebx
;            movzx eax, byte ptr [ebx]
;            .IF al == '#' ; res id string pass this to parent via WM_COMMAND
;                inc ebx
;                movzx eax, byte ptr [ebx]
;                .IF al != 0
;                    Invoke atol, ebx
;                    Invoke PostMessage, hParent, WM_COMMAND, eax, hWin
;                .ENDIF 
;            .ELSEIF al == 0 ; null string, do nothing
;            .ELSE
;                Invoke ShellExecute, hWin, Addr szDTELinkOpen, lpszUrl, NULL, NULL, SW_SHOW
;            .ENDIF
;            mov eax, TRUE
;            ret
;        .ENDIF    
;    
;        add ptrLinkUrlEntry, SIZEOF LINKURL
;        inc nCurrentLinkUrl
;        mov eax, nCurrentLinkUrl
;    .ENDW
;
;    mov eax, FALSE
;    ret

    Invoke DrawTextEXTLinkItem, hWin
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ELSE
        mov ptrLinkUrlEntry, eax
        mov ebx, eax
        Invoke GetParent, hWin
        mov hParent, eax
        lea ebx, [ebx].LINKURL.szLinkUrl
        mov lpszUrl, ebx
        movzx eax, byte ptr [ebx]
        .IF al == '#' ; res id string pass this to parent via WM_COMMAND
            inc ebx
            movzx eax, byte ptr [ebx]
            .IF al != 0
                Invoke atol, ebx
                Invoke PostMessage, hParent, WM_COMMAND, eax, hWin
            .ENDIF 
        .ELSEIF al == 0 ; null string, do nothing
        .ELSE
            Invoke ShellExecute, hWin, Addr szDTELinkOpen, lpszUrl, NULL, NULL, SW_SHOW
        .ENDIF
        mov eax, TRUE
        ret
    .ENDIF
    ret
DrawTextEXTLinkClick ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkItem - Get current link url item
; 
; Returns in eax pointer to LINKURL entry or NULL otherwise
;------------------------------------------------------------------------------
DrawTextEXTLinkItem PROC USES EBX hWin:DWORD
    LOCAL ptrLinkUrlArray:DWORD
    LOCAL ptrLinkUrlEntry:DWORD
    LOCAL nTotalLinkUrls:DWORD
    LOCAL nCurrentLinkUrl:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT

    .IF hWin == 0
        mov eax, NULL
        ret
    .ENDIF

    Invoke GetWindowLong, hWin, DTEL_LINKURLSTOTAL ; total link urls
    .IF eax == 0
        mov eax, NULL
        ret
    .ENDIF
    mov nTotalLinkUrls, eax
    
    Invoke GetWindowLong, hWin, DTEL_LINKURLSARRAY ; pointer to link url arrays
    .IF eax == 0
        mov eax, NULL
        ret
    .ENDIF
    mov ptrLinkUrlArray, eax
    mov ptrLinkUrlEntry, eax

    Invoke GetCursorPos, Addr pt
    Invoke ScreenToClient, hWin, Addr pt
    
    mov nCurrentLinkUrl, 0
    mov eax, 0
    .WHILE eax < nTotalLinkUrls
        mov ebx, ptrLinkUrlEntry
        lea eax, [ebx].LINKURL.rcLinkUrl
        Invoke CopyRect, Addr rect, eax
    
        Invoke PtInRect, Addr rect, pt.x, pt.y
        .IF eax == TRUE
            mov eax, ptrLinkUrlEntry
            ret
        .ENDIF    
    
        add ptrLinkUrlEntry, SIZEOF LINKURL
        inc nCurrentLinkUrl
        mov eax, nCurrentLinkUrl
    .ENDW

    mov eax, NULL
    ret
DrawTextEXTLinkItem ENDP


;------------------------------------------------------------------------------
; DrawTextEXTLinkNotify - Notify parent about hyperlink
;------------------------------------------------------------------------------
DrawTextEXTLinkNotify PROC USES EBX hWin:DWORD, dwNotifyCode:DWORD
    LOCAL hParent:DWORD
    LOCAL idControl:DWORD
    LOCAL ptrLinkUrlEntry:DWORD

    .IF dwNotifyCode != DTELN_MOUSELEAVE ; use previous values if mouseleave
        Invoke DrawTextEXTLinkItem, hWin
        .IF eax == NULL
            mov eax, FALSE
            ret
        .ENDIF
        mov ptrLinkUrlEntry, eax
    .ENDIF

    Invoke GetParent, hWin
    mov hParent, eax
    Invoke GetDlgCtrlID, hWin
    mov idControl, eax

    mov eax, hWin
    mov DTELNM.hdr.hwndFrom, eax
    mov eax, dwNotifyCode
    mov DTELNM.hdr.code, eax    

    .IF dwNotifyCode != DTELN_MOUSELEAVE ; use previous values if mouseleave
        mov ebx, ptrLinkUrlEntry
        lea eax, [ebx].LINKURL.rcLinkUrl
        lea ebx, DTELNM.item.rcLinkUrl
        Invoke CopyRect, ebx, eax
    
        mov ebx, ptrLinkUrlEntry
        lea eax, [ebx].LINKURL.szLinkUrl
        lea ebx, DTELNM.item.szLinkUrl
        Invoke lstrcpyn, ebx, eax, LINKURL_MAXLENGTH
        
        mov ebx, ptrLinkUrlEntry
        lea eax, [ebx].LINKURL.szLinkTitle
        lea ebx, DTELNM.item.szLinkTitle
        Invoke lstrcpyn, ebx, eax, LINKURL_MAXLENGTH
    .ENDIF

    Invoke PostMessage, hParent, WM_NOTIFY, idControl, Addr DTELNM 
    mov eax, TRUE
    ret
DrawTextEXTLinkNotify ENDP


