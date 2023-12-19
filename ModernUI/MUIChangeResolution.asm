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


.DATA
dmScreenSettings    DEVMODE <>

.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Change resolution
;------------------------------------------------------------------------------
MUIChangeScreenResolution PROC ScreenWidth:MUIVALUE, ScreenHeight:MUIVALUE, bitsPerPixel:MUIVALUE

    Invoke RtlZeroMemory, Addr dmScreenSettings, SIZEOF DEVMODE
    mov dmScreenSettings.dmSize, SIZEOF DEVMODE
    mov eax, ScreenWidth
    mov dmScreenSettings.dmPelsWidth, eax
    mov eax, ScreenHeight
    mov dmScreenSettings.dmPelsHeight, eax
    mov eax, bitsPerPixel
    .IF eax == 0
        mov eax, 32d
    .ENDIF
    mov dmScreenSettings.dmBitsPerPel, eax
    
    ;mov eax, (DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT)  ;; (040000h or 080000h or 0100000h)
    
    mov dmScreenSettings.dmFields, DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT or DM_DISPLAYFREQUENCY
    mov dmScreenSettings.dmDisplayFrequency, 60
    Invoke ChangeDisplaySettings, Addr dmScreenSettings, CDS_FULLSCREEN
    .IF (eax != DISP_CHANGE_SUCCESSFUL)
        xor eax, eax
    .ELSE
        mov eax, TRUE
    .ENDIF
    ret

MUIChangeScreenResolution ENDP

MODERNUI_LIBEND

