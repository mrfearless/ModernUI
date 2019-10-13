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
; MUIGDIPaintBrush - Fills a rectangle with a specific color
;
; lpBrushRect is a pointer to a RECT containing the bounding box to paint
; hBrushBitmap is an brush bitmap created from CreatePatternBrush to paint with
; dwBrushOrgX is x adjustment to start painting from in the source brush bitmap
; dwBrushOrgY is y adjustment to start painting from in the source brush bitmap
;------------------------------------------------------------------------------
MUIGDIPaintBrush PROC hdc:HDC, lpBrushRect:LPRECT, hBrushBitmap:HBITMAP, dwBrushOrgX:LPMUIVALUE, dwBrushOrgY:LPMUIVALUE
    LOCAL hBrushOld:DWORD
    LOCAL rect:RECT
    
    .IF hBrushBitmap == 0
        ret
    .ENDIF

    ; Adjust rect for FillRect call
    Invoke CopyRect, Addr rect, lpBrushRect
    inc rect.right
    inc rect.bottom
    Invoke SelectObject, hdc, hBrushBitmap
    mov hBrushOld, eax
    
    Invoke SetBrushOrgEx, hdc, dwBrushOrgX, dwBrushOrgY, 0   
    Invoke FillRect, hdc, Addr rect, hBrushBitmap
    Invoke SetBrushOrgEx, hdc, 0, 0, 0 ; reset the brush origin  

    .IF hBrushOld != 0
        Invoke SelectObject, hdc, hBrushOld
        Invoke DeleteObject, hBrushOld
    .ENDIF
   
    ret
MUIGDIPaintBrush ENDP


MODERNUI_LIBEND


