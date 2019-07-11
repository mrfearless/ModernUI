;==============================================================================
;
; ModernUI Library
;
; Copyright (c) 2019 by fearless
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
; Convert font point size eg '12' to logical unit size for use with CreateFont,
; CreateFontIndirect
;------------------------------------------------------------------------------
MUIPointSizeToLogicalUnit PROC hWin:MUIWND, PointSize:MUIVALUE
    LOCAL hdc:HDC
    LOCAL dwLogicalUnit:DWORD
    
    Invoke GetDC, hWin
    mov hdc, eax
    Invoke SetMapMode, hdc, MM_TEXT
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    Invoke MulDiv, PointSize, eax, 72d
    neg eax
    mov dwLogicalUnit, eax
    Invoke ReleaseDC, hWin, hdc
    mov eax, dwLogicalUnit
    ret
MUIPointSizeToLogicalUnit ENDP


MODERNUI_LIBEND

