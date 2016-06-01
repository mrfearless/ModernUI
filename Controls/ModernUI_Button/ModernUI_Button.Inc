;======================================================================================================================================
;
; ModernUI Control - ModernUI_Button v1.0.0.0
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
; ModernUI_Button Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUIButtonRegister		        PROTO																	; Use 'ModernUI_Button' as class in RadASM custom class control
MUIButtonCreate		            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD	; hWndParent, lpszText, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIButtonSetProperty	        PROTO :DWORD, :DWORD, :DWORD											; hModernUI_Button, dwProperty, dwPropertyValue
MUIButtonGetProperty	        PROTO :DWORD, :DWORD													; hModernUI_Button, dwProperty
MUIButtonGetState               PROTO :DWORD                                                            ; hModernUI_Button
MUIButtonSetState               PROTO :DWORD, :DWORD                                                    ; hModernUI_Button, bState

MUIButtonLoadImages             PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD            ; hModernUI_Button, dwImageType, dwResIDImage, dwResIDImageAlt, dwResIDImageSel, dwResIDImageSelAlt, dwResIDImageDisabled
MUIButtonSetImages              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD            ; hModernUI_Button, dwImageType, hImage, hImageAlt, hImageSel, hImageSelAlt, hImageDisabled

MUIButtonNotifySetText          PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, lpszNotifyText, bRedraw
MUIButtonNotifyLoadImage        PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, dwImageType, dwResIDNotifyImage
MUIButtonNotifySetImage         PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, dwImageType, hNotifyImage
MUIButtonNotifySetFont          PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, hFont, bRedraw
MUIButtonNotify                 PROTO :DWORD                                                            ; hModernUI_Button

MUIButtonNoteSetText            PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, lpszNoteText, bRedraw
MUIButtonNoteSetFont            PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, hFont, bRedraw

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Button Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Button Constants
;--------------------------------------------------------------------------------------------------------------------------------------

; ModernUI_Button Messages
MUIBM_GETSTATE                  EQU WM_USER + 1779 ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
MUIBM_SETSTATE                  EQU WM_USER + 1778 ; wParam = TRUE/FALSE, lParam = NULL

MUIBM_NOTIFYSETTEXT             EQU WM_USER + 1777 ; wParam = lpszNotifyText, lParam = Redraw TRUE/FALSE
MUIBM_NOTIFYSETIMAGE            EQU WM_USER + 1776 ; wParam = dwImageType, lParam = Handle of Image
MUIBM_NOTIFYLOADIMAGE           EQU WM_USER + 1775 ; wParam = dwImageType, lParam = ResourceID
MUIBM_NOTIFYSETFONT             EQU WM_USER + 1774 ; wParam = hFont, lParam = TRUE/FALSE to redraw control
MUIBM_NOTIFY                    EQU WM_USER + 1773 ; wParam = NULL, lParam = NULL

MUIBM_NOTESETTEXT               EQU WM_USER + 1772 ; wParam = lpszNoteText, lParam = TRUE/FALSE to redraw control
MUIBM_NOTESETFONT               EQU WM_USER + 1771 ; wParam = hFont, lParam = TRUE/FALSE to redraw control




; ModernUI_Button Styles
MUIBS_LEFT                      EQU 1 
MUIBS_BOTTOM                    EQU 2
MUIBS_CENTER                    EQU 4
MUIBS_AUTOSTATE                 EQU 8
MUIBS_PUSHBUTTON                EQU 10h
MUIBS_HAND                      EQU 20h

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Button Properties: Use with MUIButtonSetProperty / MUIButtonGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------


@ButtonTextFont                 EQU 0    ; 
@ButtonTextColor                EQU 4    ; 
@ButtonTextColorAlt             EQU 8    ; 
@ButtonTextColorSel             EQU 12    ; 
@ButtonTextColorSelAlt          EQU 16    ; 
@ButtonTextColorDisabled        EQU 20    ; 
@ButtonBackColor                EQU 24    ; 
@ButtonBackColorAlt             EQU 28    ; 
@ButtonBackColorSel             EQU 32    ; 
@ButtonBackColorSelAlt          EQU 36    ; 
@ButtonBackColorDisabled        EQU 40    ; 
@ButtonBorderColor              EQU 44    ; 
@ButtonBorderColorAlt           EQU 48    ; 
@ButtonBorderColorSel           EQU 52    ; 
@ButtonBorderColorSelAlt        EQU 56    ; 
@ButtonBorderColorDisabled      EQU 60    ; 
@ButtonBorderStyle              EQU 64    ; 
@ButtonAccentColor              EQU 68    ; 
@ButtonAccentColorAlt           EQU 72    ; 
@ButtonAccentColorSel           EQU 76    ; 
@ButtonAccentColorSelAlt        EQU 80    ; 
@ButtonAccentStyle              EQU 84    ; 
@ButtonAccentStyleAlt           EQU 88    ; 
@ButtonAccentStyleSel           EQU 92    ; 
@ButtonAccentStyleSelAlt        EQU 96    ; 
@ButtonImageType                EQU 100    ; 0 = none, 1 = bitmap, 2 = icon, 3 = png
@ButtonImage                    EQU 104    ; 
@ButtonImageAlt                 EQU 108    ; 
@ButtonImageSel                 EQU 112    ; 
@ButtonImageSelAlt              EQU 116    ; 
@ButtonImageDisabled            EQU 120    ; 
@ButtonNotifyTextFont           EQU 124    ; 
@ButtonNotifyTextColor          EQU 128    ; 
@ButtonNotifyBackColor          EQU 132    ; 
@ButtonNotifyRound              EQU 136    ; 
@ButtonNotifyImageType          EQU 140    ; 
@ButtonNotifyImage              EQU 144    ; 
@ButtonNoteTextFont             EQU 148    
@ButtonNoteTextColor            EQU 152
@ButtonNoteTextColorDisabled    EQU 156

; Button Border Styles
MUIBBS_NONE                     EQU 0
MUIBBS_LEFT                     EQU 1
MUIBBS_TOP                      EQU 2
MUIBBS_BOTTOM                   EQU 4
MUIBBS_RIGHT                    EQU 8
MUIBBS_ALL                      EQU MUIBBS_LEFT + MUIBBS_TOP + MUIBBS_BOTTOM + MUIBBS_RIGHT


; Button Accent Styles
MUIBAS_NONE                     EQU 0
MUIBAS_LEFT                     EQU 1
MUIBAS_TOP                      EQU 2
MUIBAS_BOTTOM                   EQU 4
MUIBAS_RIGHT                    EQU 8
MUIBAS_ALL                      EQU MUIBAS_LEFT + MUIBAS_TOP + MUIBAS_BOTTOM + MUIBAS_RIGHT

; Button Image Types
MUIBIT_NONE                     EQU 0
MUIBIT_BMP                      EQU 1
MUIBIT_ICO                      EQU 2
MUIBIT_PNG                      EQU 3




