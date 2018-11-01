;==============================================================================
;
; ModernUI Control - ModernUI_Checkbox
;
; Copyright (c) 2018 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
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
; ModernUI_Checkbox Prototypes
;------------------------------------------------------------------------------
MUICheckboxRegister             PROTO                                                                   ; Use 'ModernUI_Checkbox' as class in RadASM custom class control
MUICheckboxCreate               PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszText, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUICheckboxSetProperty          PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Checkbox, dwProperty, dwPropertyValue
MUICheckboxGetProperty          PROTO :DWORD, :DWORD                                                    ; hModernUI_Checkbox, dwProperty
MUICheckboxGetState             PROTO :DWORD                                                            ; hModernUI_Checkbox
MUICheckboxSetState             PROTO :DWORD, :DWORD                                                    ; hModernUI_Checkbox, bState

MUICheckboxLoadImages           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hModernUI_Checkbox, dwImageType, dwResIDImage, dwResIDImageAlt, dwResIDImageSel, dwResIDImageSelAlt, dwResIDImageDisabled, dwResIDImageDisabledSel
MUICheckboxSetImages            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hModernUI_Checkbox, dwImageType, hImage, hImageAlt, hImageSel, hImageSelAlt, hImageDisabled, hImageDisabledSel


;------------------------------------------------------------------------------
; ModernUI_Checkbox Structures
;------------------------------------------------------------------------------
IFNDEF MUI_CHECKBOX_PROPERTIES
MUI_CHECKBOX_PROPERTIES         STRUCT
    dwTextFont                  DD ?        ; hFont
    dwTextColor                 DD ?        ; Colorref
    dwTextColorAlt              DD ?        ; Colorref
    dwTextColorSel              DD ?        ; Colorref
    dwTextColorSelAlt           DD ?        ; Colorref
    dwTextColorDisabled         DD ?        ; Colorref
    dwBackColor                 DD ?        ; Colorref
    dwImageType                 DD ?        ; image type
    dwImage                     DD ?        ; hImage for empty checkbox
    dwImageAlt                  DD ?        ; hImage for empty checkbox when mouse moves over checkbox
    dwImageSel                  DD ?        ; hImage for checkbox with checkmark
    dwImageSelAlt               DD ?        ; hImage for checkbox with checkmark when mouse moves over checkbox
    dwImageDisabled             DD ?        ; hImage for disabled empty checkbox
    dwImageDisabledSel          DD ?        ; hImage for disabled checkbox with checkmark
    dwCheckboxDllInstance       DD ?
    dwCheckboxParam             DD ?
MUI_CHECKBOX_PROPERTIES         ENDS
ENDIF


.CONST
;------------------------------------------------------------------------------
; ModernUI_Checkbox Constants
;------------------------------------------------------------------------------

; ModernUI_Checkbox Messages
MUICM_GETSTATE                  EQU WM_USER + 1779 ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
MUICM_SETSTATE                  EQU WM_USER + 1778 ; wParam = TRUE/FALSE, lParam = NULL

; ModernUI_Checkbox Styles
MUICBS_CHECK                     EQU 00h     ;
MUICBS_RADIO                     EQU 01h     ;
MUICBS_HAND                      EQU 20h     ; Show a hand instead of an arrow when mouse moves over checkbox.
MUICBS_NOFOCUSRECT               EQU 100h    ; Dont show focus rect, just use change border to @CheckboxTextColorAlt when setfocus.

MUICBS_THEMEDARK                 EQU 200h    ; For default icons, if not set default dark icons for light backgrounds, if set light icons for dark backgrounds
MUICBS_THEME                     EQU 8000h   ; Use default windows theme colors and react to WM_THEMECHANGED

;------------------------------------------------------------------------------
; ModernUI_Checkbox Properties: Use with MUICheckboxSetProperty / 
; MUICheckboxGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@CheckboxTextFont               EQU 0       ; Font for checkbox text
@CheckboxTextColor              EQU 4       ; Colorref Text color for checkbox
@CheckboxTextColorAlt           EQU 8       ; Colorref
@CheckboxTextColorSel           EQU 12      ; Colorref
@CheckboxTextColorSelAlt        EQU 16      ; Colorref
@CheckboxTextColorDisabled      EQU 20      ; Colorref
@CheckboxBackColor              EQU 24      ; Colorref
@CheckboxImageType              EQU 28      ; Checkbox Image Types - One of the following: MUICIT_NONE, MUICIT_BMP, MUICIT_ICO or MUICIT_PNG
@CheckboxImage                  EQU 32      ; hImage
@CheckboxImageAlt               EQU 36      ; hImage
@CheckboxImageSel               EQU 40      ; hImage
@CheckboxImageSelAlt            EQU 44      ; hImage
@CheckboxImageDisabled          EQU 48      ; hImage
@CheckboxImageDisabledSel       EQU 52      ; hImage
@CheckboxDllInstance            EQU 56      ; Set to hInstance of dll before calling MUICheckboxLoadImages if used within a dll
@CheckboxParam                  EQU 60      ; Custom user data

; Checkbox Image Types
MUICIT_NONE                     EQU 0
MUICIT_BMP                      EQU 1
MUICIT_ICO                      EQU 2
MUICIT_PNG                      EQU 3








