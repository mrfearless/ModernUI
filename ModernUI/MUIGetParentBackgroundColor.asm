;==============================================================================
;
; ModernUI Library
;
; Copyright (c) 2023 by fearless
;
; All Rights Reserved
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
include kernel32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets parent background color
; returns in eax, MUI_RGBCOLOR or -1 if NULL brush is set
; Useful for certain controls to retrieve the parents background color and then
; to set their own background color based on the same value.
;------------------------------------------------------------------------------
MUIGetParentBackgroundColor PROC hWin:MUIWND
    LOCAL hParent:DWORD
    LOCAL hBrush:DWORD
    LOCAL logbrush:LOGBRUSH
    
    Invoke GetParent, hWin
    mov hParent, eax
    
    Invoke GetClassLong, hParent, GCL_HBRBACKGROUND
    .IF eax == NULL
        ;PrintText 'GetClassLong, hParent, GCL_HBRBACKGROUND = NULL'
        mov eax, -1
        ret
    .ENDIF
    
    .IF eax > 32d
        mov hBrush, eax
        Invoke GetObject, hBrush, SIZEOF LOGBRUSH, Addr logbrush
        .IF eax == 0
            ;PrintText 'GetObject, hBrush, SIZEOF LOGBRUSH, Addr logbrush = 0'
            mov eax, -1
            ret
        .ENDIF
        mov eax, logbrush.lbColor
    .ELSE
        dec eax ; to adjust for initial value being COLOR_X+1
        Invoke GetSysColor, eax
        ret
    .ENDIF

    ret
MUIGetParentBackgroundColor ENDP


MODERNUI_LIBEND



