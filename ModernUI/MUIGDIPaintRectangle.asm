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
; MUIGDIPaintRectangle - Draws a draws a rectangle. The rectangle is outlined 
; by using the specified outline color and filled by using the specified fill 
; color.
; 
; lpRect is a pointer to a RECT containing the bounding box of the frame
; FrameColor is an RGBCOLOR to paint the frame edges. If FrameColor is -1 
; then no outline painting occurs, just fill painting.
;------------------------------------------------------------------------------
MUIGDIPaintRectangle PROC hdc:HDC, lpRect:LPRECT, FrameColor:MUICOLORRGB, FillColor:MUICOLORRGB
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL hPen:DWORD
    LOCAL hPenOld:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    
    .IF FrameColor == -1 && FillColor == -1
        ret
    .ENDIF
    
    .IF FrameColor != -1
        
        .IF FillColor != -1
            ;--------------------------------------------------------------
            ; Paint Frame and Fill
            ;--------------------------------------------------------------
            Invoke CopyRect, Addr rect, lpRect
    
            ;--------------------------------------------------------------
            ; Create pen for outline
            ;--------------------------------------------------------------
            Invoke CreatePen, PS_SOLID, 1, FrameColor
            mov hPen, eax
            Invoke SelectObject, hdc, hPen
            mov hPenOld, eax 
            
            ;--------------------------------------------------------------
            ; Create brush for fill
            ;--------------------------------------------------------------
            Invoke CreateSolidBrush, FillColor
            mov hBrush, eax
            Invoke SelectObject, hdc, hBrush
            mov hBrushOld, eax
            
            ;--------------------------------------------------------------
            ; Draw outlined and filled rectangle
            ;--------------------------------------------------------------
            Invoke Rectangle, hdc, rect.left, rect.top, rect.right, rect.bottom
            
            ;--------------------------------------------------------------
            ; Tidy up
            ;--------------------------------------------------------------
            .IF hPenOld != 0
                Invoke SelectObject, hdc, hPenOld
                Invoke DeleteObject, hPenOld
            .ENDIF
            .IF hPen != 0
                Invoke DeleteObject, hPen
            .ENDIF
            .IF hBrushOld != 0
                Invoke SelectObject, hdc, hBrushOld
                Invoke DeleteObject, hBrushOld
            .ENDIF     
            .IF hBrush != 0
                Invoke DeleteObject, hBrush
            .ENDIF
            
        .ELSE
            ;--------------------------------------------------------------
            ; Paint frame only
            ;--------------------------------------------------------------
            Invoke MUIGDIPaintFrame, hdc, lpRect, FrameColor, MUIPFS_ALL
        .ENDIF
    .ELSE
        ;--------------------------------------------------------------
        ; Paint fill only
        ;--------------------------------------------------------------
        Invoke MUIGDIPaintFill, hdc, lpRect, FillColor
    .ENDIF
    ret
MUIGDIPaintRectangle ENDP


MODERNUI_LIBEND

