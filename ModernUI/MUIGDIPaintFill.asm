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
; MUIGDIPaintFill - Fills a rectangle with a specific color
;
; lpFillRect is a pointer to a RECT containing the bounding box to fill
; dwFillColor is an RGBCOLOR to paint fill the rectangle with
;------------------------------------------------------------------------------
MUIGDIPaintFill PROC hdc:HDC, lpFillRect:LPRECT, FillColor:MUICOLORRGB
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL rect:RECT
    
    ; Adjust rect for FillRect call
    Invoke CopyRect, Addr rect, lpFillRect
    inc rect.right
    inc rect.bottom
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hBrushOld, eax
    Invoke SetDCBrushColor, hdc, FillColor
    Invoke FillRect, hdc, Addr rect, hBrush
    .IF hBrushOld != 0
        Invoke SelectObject, hdc, hBrushOld
        Invoke DeleteObject, hBrushOld
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF      
    ret
MUIGDIPaintFill ENDP


MODERNUI_LIBEND


