;======================================================================================================================================
;
; ModernUI Control - ModernUI_Text v1.0.0.0
;
; Copyright (c) 2016 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;
; This software is provided 'as-is', without any express or implied warranty. In no event will the author be held liable for any 
; damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any non-commercial program. If you use the library in an application, an 
; acknowledgement in the application or documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave the original copyright notices intact and not 
; misrepresent the origin of the software. It is not allowed to claim you wrote the original software. Modified files must have a clear 
; notice that the files are modified, and not in the original state. This includes the name of the person(s) who modified the code. 
;
; If you want to distribute or redistribute any portion of this package, you will need to include the full package in it's original 
; state, including this license and all the copyrights. 
;
; While distributing this package (in it's original state) is allowed, it is not allowed to charge anything for this. You may not sell
; or include the package in any commercial package without having permission of the author. Neither is it allowed to redistribute any 
; of the package's components with commercial applications.
;
;======================================================================================================================================

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Text Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUITextRegister         PROTO                                                                   ; Use 'ModernUI_Text' as class in RadASM custom class control
MUITextCreate           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszText, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUITextSetProperty      PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Text, dwProperty, dwPropertyValue
MUITextGetProperty      PROTO :DWORD, :DWORD                                                    ; hModernUI_Text, dwProperty

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Text Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Text Constants
;--------------------------------------------------------------------------------------------------------------------------------------

; ModernUI_Text Styles
MUITS_DEFAULT           EQU 0  ; 8px
MUITS_CAPTION           EQU 1  ; 12px
MUITS_BODY              EQU 2  ; 15px
MUITS_BODYTITLE         EQU 3  ; 15px
MUITS_SUBTITLE          EQU 4  ; 20px
MUITS_TITLE             EQU 5  ; 24px
MUITS_SUBHEADER         EQU 6  ; 34px
MUITS_HEADER            EQU 7  ; 46px


MUITS_FONT_SEGOE        EQU 1 shl 4
MUITS_FONT_TAHOMA       EQU 2 shl 4
MUITS_FONT_SANS         EQU 3 shl 4
MUITS_FONT_ARIAL        EQU 4 shl 4
MUITS_FONT_TIMES        EQU 5 shl 4
MUITS_FONT_COURIER      EQU 6 shl 4
MUITS_FONT_VERDANA      EQU 7 shl 4

MUITS_ALIGN_RIGHT       EQU 256 ; right aligned text
MUITS_ALIGN_CENTER      EQU 512 ; center aligned text
MUITS_SINGLELINE        EQU 1024
MUITS_HAND              EQU 2048 ; Show a hand instead of an arrow when mouse moves over text

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Text Properties: Use with MUITextSetProperty / MUITextGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@TextFont               EQU 0       ; hFont
@TextColor              EQU 4       ; Colorref
@TextColorAlt           EQU 8       ; Colorref
@TextColorDisabled      EQU 12      ; Colorref
@TextBackColor          EQU 16      ; Colorref
@TextBackColorAlt       EQU 20      ; Colorref
@TextBackColorDisabled  EQU 24      ; Colorref






