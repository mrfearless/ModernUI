;==============================================================================
;
; ModernUI Control - ModernUI_Text
;
; Copyright (c) 2019 by fearless
;
; All Rights Reserved
;
; http://github.com/mrfearless/ModernUI
;
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
; Permission is granted to anyone to use this software for any non-commercial 
; program. If you use the library in an application, an acknowledgement in the
; application or documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave
; the original copyright notices intact and not misrepresent the origin of the
; software. It is not allowed to claim you wrote the original software. 
; Modified files must have a clear notice that the files are modified, and not
; in the original state. This includes the name of the person(s) who modified 
; the code. 
;
; If you want to distribute or redistribute any portion of this package, you 
; will need to include the full package in it's original state, including this
; license and all the copyrights.  
;
; While distributing this package (in it's original state) is allowed, it is 
; not allowed to charge anything for this. You may not sell or include the 
; package in any commercial package without having permission of the author. 
; Neither is it allowed to redistribute any of the package's components with 
; commercial applications.
;
;==============================================================================

;------------------------------------------------------------------------------
; ModernUI_Text Prototypes
;------------------------------------------------------------------------------
MUITextRegister         PROTO                                                                   ; Use 'ModernUI_Text' as class in RadASM custom class control
MUITextCreate           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszText, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUITextSetProperty      PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Text, dwProperty, dwPropertyValue
MUITextGetProperty      PROTO :DWORD, :DWORD                                                    ; hModernUI_Text, dwProperty
MUITextSetBufferSize    PROTO :DWORD, :DWORD                                                    ; hModernUI_Text, dwBufferSize

MUITextSetBackBrush     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD                            ; hModernUI_Text, hBrush, dwBrushOrgX, dwBrushOrgY, dwBrushPos
MUITextLoadBackBrush    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD                            ; hModernUI_Text, idResBitmap, dwBrushOrgX, dwBrushOrgY, dwBrushPos


.CONST
;------------------------------------------------------------------------------
; ModernUI_Text Constants
;------------------------------------------------------------------------------

; ModernUI_Text Styles

; Font size - AND 0Fh to get value                          : 0000 0000 0000 XXXX
MUITS_7PT               EQU 1  ; 7pt
MUITS_8PT               EQU 0  ; 8pt
MUITS_9PT               EQU 2  ; 9pt
MUITS_10PT              EQU 3  ; 10pt
MUITS_11PT              EQU 4  ; 11pt
MUITS_12PT              EQU 5  ; 12pt
MUITS_13PT              EQU 6  ; 13pt
MUITS_14PT              EQU 7  ; 14pt
MUITS_15PT              EQU 8  ; 15pt
MUITS_16PT              EQU 9  ; 16pt
MUITS_18PT              EQU 10 ; 18pt
MUITS_20PT              EQU 11 ; 20pt
MUITS_22PT              EQU 12 ; 22pt
MUITS_24PT              EQU 13 ; 24pt
MUITS_28PT              EQU 14 ; 28pt
MUITS_32PT              EQU 15 ; 32pt

; Font familty - AND 0F0h shr 4 to get value                : 0000 0000 0XXX 0000
MUITS_FONT_DIALOG       EQU 0 shl 4 ; 0000 0000 0000 0000
MUITS_FONT_SEGOE        EQU 1 shl 4 ; 0000 0000 0001 0000
MUITS_FONT_TAHOMA       EQU 2 shl 4 ; 0000 0000 0010 0000
MUITS_FONT_ARIAL        EQU 3 shl 4 ; 0000 0000 0011 0000
MUITS_FONT_TIMES        EQU 4 shl 4 ; 0000 0000 0100 0000
MUITS_FONT_COURIER      EQU 5 shl 4 ; 0000 0000 0101 0000
MUITS_FONT_VERDANA      EQU 6 shl 4 ; 0000 0000 0110 0000

; Text alignment - AND 300h shr 8 to get value              : 0000 00XX 0000 0000
MUITS_ALIGN_LEFT        EQU 0 shl 8 ; 0000 0000 0000 0000
MUITS_ALIGN_RIGHT       EQU 1 shl 8 ; 0000 0001 0000 0000
MUITS_ALIGN_CENTER      EQU 2 shl 8 ; 0000 0010 0000 0000
MUITS_ALIGN_JUSTIFY     EQU 3 shl 8 ; same as align left

; Font special - direct AND with and check value            : 000X XX00 0000 0000
MUITS_FONT_NORMAL       EQU 0 shl 10 ; 0000 0000 0000 0000
MUITS_FONT_BOLD         EQU 1 shl 10 ; 0000 0100 0000 0000
MUITS_FONT_ITALIC       EQU 1 shl 11 ; 0000 1000 0000 0000
MUITS_FONT_UNDERLINE    EQU 1 shl 12 ; 0001 0000 0000 0000

; Misc options - direct AND with and check value            : XXX0 0000 0000 0000
MUITS_SINGLELINE        EQU 1 shl 13 ; 0010 0000 0000 0000
MUITS_HAND              EQU 1 shl 14 ; 0100 0000 0000 0000 - Show a hand instead of an arrow when mouse moves over text
MUITS_LORUMIPSUM        EQU 1 shl 15 ; 1000 0000 0000 0000 - Show lorum ipsum in text box - for demo purposes etc.

MUITS_UTF8              EQU 1 shl 7
MUITS_HTMLCODE          EQU (MUITS_LORUMIPSUM or MUITS_ALIGN_JUSTIFY or MUITS_FONT_NORMAL)  ; only use one or other
MUITS_BBCODE            EQU (MUITS_LORUMIPSUM or MUITS_ALIGN_JUSTIFY or MUITS_FONT_BOLD)    ; dont use both options


;------------------------------------------------------------------------------
; ModernUI_Text Properties: Use with MUITextSetProperty / MUITextGetProperty or
; MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@TextFont               EQU 0       ; hFont
@TextColor              EQU 4       ; COLORREF
@TextColorAlt           EQU 8       ; COLORREF
@TextColorDisabled      EQU 12      ; COLORREF
@TextBackColor          EQU 16      ; COLORREF, -1 = transparent
@TextBackColorAlt       EQU 20      ; COLORREF
@TextBackColorDisabled  EQU 24      ; COLORREF
@TextDllInstance        EQU 28      ; DWORD

; Text Brush Position:
MUITBP_RELATIVE         EQU 0
MUITBP_ABSOLUTE         EQU 1

;------------------------------------------------------------------------------
; ModernUI_DrawTextEXT Properties: Use MUITextSetPropertyEx / MUITextGetPropertyEx
;------------------------------------------------------------------------------
@TextExtFont            EQU 0       ; hFont
@TextExtCodeTextColor   EQU 32      ; COLORREF
@TextExtCodeBackColor   EQU 36      ; COLORREF
@TextExtQuoteTextColor  EQU 40      ; COLORREF
@TextExtQuoteBackColor  EQU 44      ; COLORREF
@TextExtLinkTextColor   EQU 48      ; COLORREF
@TextExtLinkUnderline   EQU 52      ; DWORD. Text Link Style
@TextExtHelpTextColor   EQU 56      ; COLORREF
@TextExtHelpUnderline   EQU 60      ; DWORD. Text Help Style
@TextExtHorzRuleColor   EQU 64      ; COLORREF


; TextExt Link Style:
MUITLS_ALL              EQU 0       ; Underline links
MUITLS_HOVER            EQU 1       ; Underline only when mouse hovers over
MUITLS_NONE             EQU 2       ; Dont underline links ever

; TextExt Help Style:
MUITHS_ALL              EQU 0       ; Underline help
MUITHS_HOVER            EQU 1       ; Underline only when mouse hovers over
MUITHS_NONE             EQU 2       ; Dont underline help ever




;------------------------------------------------------------------------------
; DrawTextEXTLink Notification
;
; Send to the parent window via WM_NOTIFY with lParam a pointer to a NM_DTEL 
; structure. NM_DTEL.NMHDR.hdr.code will contain the notification code as
; defined below for: mouse over, mouse leave or mouse click.;
;
; Note: DrawTextEXTLink is a custom window that is created if a user passes a
; pointer to a DWORD variable in the lpHyperLink parameter of either 
; DrawHTMLCODE or DrawBBCODE. The variable will store the handle of the
; DrawTextEXTLink control for all future calls. If any url tags are used,
; DrawTextEXTLink creates an overlay made up of regions representing the 
; position of the url text, and draws the url text in these regions, along
; with the background, font etc. It handles cursor change, mouse over, and 
; click events for the hyperlink, along with notifications sent to the parent.
;
;------------------------------------------------------------------------------
LINKURL_MAXLENGTH       EQU 256 ; length of url text

IFNDEF LINKURL
LINKURL                 STRUCT
    rcLinkUrl           RECT <0,0,0,0>                  ; rect/rgn for linkurl
    szLinkUrl           DB LINKURL_MAXLENGTH DUP (0)    ; Url: 'www.site.com'
    szLinkTitle         DB LINKURL_MAXLENGTH DUP (0)    ; Title: 'MySite'
LINKURL                 ENDS
ENDIF

IFNDEF NM_DTEL
NM_DTEL                 STRUCT
    hdr                 NMHDR <>    ; Notify Header
    item                LINKURL <>  ; Link url information
NM_DTEL                 ENDS
ENDIF

; NM_DTEL.NMHDR.code values:
DTELN_MOUSEOVER         EQU 1   ; Mouse has moved over DrawTextEXTLink
DTELN_MOUSELEAVE        EQU 2   ; Mouse has left DrawTextEXTLink
DTELN_MOUSECLICK        EQU 3   ; User has clicked DrawTextEXTLink



