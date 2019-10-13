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
MUIGDIPaintFrame PROC hdc:HDC, lpFrameRect:LPRECT, FrameColor:MUICOLORRGB, FrameStyle:MUIPFS
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL hPen:DWORD
    LOCAL hPenOld:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT

    .IF FrameColor != -1
    
        Invoke CopyRect, Addr rect, lpFrameRect
        
        .IF FrameStyle != MUIPFS_NONE
            mov eax, FrameStyle
            and eax, MUIPFS_ALL
            .IF eax == MUIPFS_ALL 
                ;--------------------------------------------------------------
                ; Paint entire frame
                ;--------------------------------------------------------------
                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hBrushOld, eax
                Invoke SetDCBrushColor, hdc, FrameColor
                Invoke FrameRect, hdc, Addr rect, hBrush
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
                Invoke CreatePen, PS_SOLID, 1, FrameColor
                mov hPen, eax
                Invoke SelectObject, hdc, hPen
                mov hPenOld, eax 

                mov eax, FrameStyle
                and eax, MUIPFS_TOP
                .IF eax == MUIPFS_TOP
                    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.top
                .ENDIF
                mov eax, FrameStyle
                and eax, MUIPFS_RIGHT
                .IF eax == MUIPFS_RIGHT
                    dec rect.right                
                    Invoke MoveToEx, hdc, rect.right, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.right
                .ENDIF
                mov eax, FrameStyle
                and eax, MUIPFS_BOTTOM
                .IF eax == MUIPFS_BOTTOM
                    dec rect.bottom
                    Invoke MoveToEx, hdc, rect.left, rect.bottom, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.bottom
                .ENDIF
                mov eax, FrameStyle
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

