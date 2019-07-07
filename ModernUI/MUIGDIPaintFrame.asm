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
; MUIGDIPaintFrame - Draws a border (or parts of) around a rectangle with a 
; specific color.
; 
; lpFrameRect is a pointer to a RECT containing the bounding box of the frame
; dwFrameColor is an RGBCOLOR to paint the frame edges. If dwFrameColor is -1 
; then no painting occurs.
; dwFrameStyle indicates what parts of the frame are painted. dwFrameStyle can 
; be a combination of the following flags:
; - MUIPFS_NONE
; - MUIPFS_LEFT
; - MUIPFS_TOP
; - MUIPFS_BOTTOM
; - MUIPFS_RIGHT
; - MUIPFS_ALL
;------------------------------------------------------------------------------
MUIGDIPaintFrame PROC hdc:DWORD, lpFrameRect:DWORD, dwFrameColor:DWORD, dwFrameStyle:DWORD
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL hPen:DWORD
    LOCAL hPenOld:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT

    .IF dwFrameColor != -1
        .IF dwFrameStyle != MUIPFS_NONE
            mov eax, dwFrameStyle
            and eax, MUIPFS_ALL
            .IF eax == MUIPFS_ALL 
                ;--------------------------------------------------------------
                ; Paint entire frame
                ;--------------------------------------------------------------
                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hBrushOld, eax
                Invoke SetDCBrushColor, hdc, dwFrameColor
                Invoke FrameRect, hdc, lpFrameRect, hBrush
                .IF hBrushOld != 0
                    Invoke SelectObject, hdc, hBrushOld
                    Invoke DeleteObject, hBrushOld
                .ENDIF     
                .IF hBrush != 0
                    Invoke DeleteObject, hBrush
                .ENDIF
            .ELSE
                ;--------------------------------------------------------------
                ; Paint only certain parts of the frame
                ;--------------------------------------------------------------
                Invoke CreatePen, PS_SOLID, 1, dwFrameColor
                mov hPen, eax
                Invoke SelectObject, hdc, hPen
                mov hPenOld, eax 
                Invoke CopyRect, Addr rect, lpFrameRect
                mov eax, dwFrameStyle
                and eax, MUIPFS_TOP
                .IF eax == MUIPFS_TOP
                    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.top
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_RIGHT
                .IF eax == MUIPFS_RIGHT
                    dec rect.right                
                    Invoke MoveToEx, hdc, rect.right, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.right
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_BOTTOM
                .IF eax == MUIPFS_BOTTOM
                    dec rect.bottom
                    Invoke MoveToEx, hdc, rect.left, rect.bottom, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.bottom
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_LEFT
                .IF eax == MUIPFS_LEFT
                    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.left, rect.bottom
                .ENDIF
                .IF hPenOld != 0
                    Invoke SelectObject, hdc, hPenOld
                    Invoke DeleteObject, hPenOld
                .ENDIF
                .IF hPen != 0
                    Invoke DeleteObject, hPen
                .ENDIF
            .ENDIF
        .ENDIF
    .ENDIF
    ret
MUIGDIPaintFrame ENDP


MODERNUI_LIBEND

