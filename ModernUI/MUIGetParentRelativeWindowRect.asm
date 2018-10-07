;==============================================================================
;
; ModernUI Library v0.0.0.5
;
; Copyright (c) 2018 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;==============================================================================

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include windows.inc
include user32.inc
includelib user32.lib

include ModernUI.inc



.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Get rectangle of a window/control relative to it's parent
;------------------------------------------------------------------------------
MUIGetParentRelativeWindowRect PROC hControl:DWORD, lpRectControl:DWORD
    LOCAL hParent:DWORD
    
    Invoke GetWindowRect, hControl, lpRectControl
    .IF eax == 0
        mov eax, FALSE
        ret
    .ENDIF
    Invoke GetAncestor, hControl, GA_PARENT
    mov hParent, eax
    Invoke MapWindowPoints, HWND_DESKTOP, hParent, lpRectControl, 2

    mov eax, TRUE
    ret 
MUIGetParentRelativeWindowRect ENDP










END