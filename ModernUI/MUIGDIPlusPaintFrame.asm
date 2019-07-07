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
include gdi32.inc
includelib user32.lib
includelib gdi32.lib

include ModernUI.inc

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
includelib gdiplus.lib

IFNDEF FP4
    FP4 MACRO value
    LOCAL vname
    .data
    align 4
      vname REAL4 value
    .code
    EXITM <vname>
    ENDM
ENDIF


IFNDEF GDIPRECT
GDIPRECT     STRUCT
    left     REAL4 ?
    top	     REAL4 ?
    right	 REAL4 ?
    bottom	 REAL4 ?
GDIPRECT     ENDS
ENDIF


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIPlusPaintFrame - Draws a border (or parts of) around a rectangle with a 
; specific color.
; 
; lpFrameRect is a pointer to a RECT containing the bounding box of the frame
; dwFrameColor is an ARGBCOLOR to paint the frame edges. If dwFrameColor is -1 
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
MUIGDIPlusPaintFrame PROC pGraphics:DWORD, lpFrameGdipRect:DWORD, dwFrameColor:DWORD, dwFrameStyle:DWORD
    LOCAL pPen:DWORD
    
    .IF dwFrameColor != -1
        .IF dwFrameStyle != MUIPFS_NONE
            mov eax, dwFrameStyle
            and eax, MUIPFS_ALL
            .IF eax == MUIPFS_ALL
                ;--------------------------------------------------------------
                ; Paint entire frame
                ;--------------------------------------------------------------
                Invoke GdipCreatePen1, dwFrameColor, FP4(1.0), UnitPixel, Addr pPen
                Invoke GdipDrawRectangleI, pGraphics, pPen, [lpFrameGdipRect].GDIPRECT.left, [lpFrameGdipRect].GDIPRECT.top, [lpFrameGdipRect].GDIPRECT.right, [lpFrameGdipRect].GDIPRECT.bottom
                Invoke GdipDeletePen, pPen
            .ELSE
                ;--------------------------------------------------------------
                ; Paint only certain parts of the frame
                ;--------------------------------------------------------------
                Invoke GdipCreatePen1, dwFrameColor, FP4(1.0), UnitPixel, Addr pPen
                
                mov eax, dwFrameStyle
                and eax, MUIPFS_TOP
                .IF eax == MUIPFS_TOP
                    Invoke GdipDrawLine, pGraphics, pPen, [lpFrameGdipRect].GDIPRECT.left, [lpFrameGdipRect].GDIPRECT.top, [lpFrameGdipRect].GDIPRECT.right, [lpFrameGdipRect].GDIPRECT.top
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_RIGHT
                .IF eax == MUIPFS_RIGHT
                    Invoke GdipDrawLine, pGraphics, pPen, [lpFrameGdipRect].GDIPRECT.right, [lpFrameGdipRect].GDIPRECT.top, [lpFrameGdipRect].GDIPRECT.right, [lpFrameGdipRect].GDIPRECT.bottom
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_BOTTOM
                .IF eax == MUIPFS_BOTTOM
                    Invoke GdipDrawLine, pGraphics, pPen, [lpFrameGdipRect].GDIPRECT.left, [lpFrameGdipRect].GDIPRECT.bottom, [lpFrameGdipRect].GDIPRECT.right, [lpFrameGdipRect].GDIPRECT.bottom
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_LEFT
                .IF eax == MUIPFS_LEFT
                    Invoke GdipDrawLine, pGraphics, pPen, [lpFrameGdipRect].GDIPRECT.left, [lpFrameGdipRect].GDIPRECT.top, [lpFrameGdipRect].GDIPRECT.left, [lpFrameGdipRect].GDIPRECT.bottom
                .ENDIF
                Invoke GdipDeletePen, pPen
            .ENDIF
        .ENDIF
    .ENDIF
    ret
MUIGDIPlusPaintFrame ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIPlusPaintFrameI - Draws a border (or parts of) around a rectangle with a 
; specific color.
; 
; lpFrameRect is a pointer to a RECT containing the bounding box of the frame
; dwFrameColor is an ARGBCOLOR to paint the frame edges. If dwFrameColor is -1 
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
MUIGDIPlusPaintFrameI PROC pGraphics:DWORD, lpFrameRectI:DWORD, dwFrameColor:DWORD, dwFrameStyle:DWORD
    LOCAL pPen:DWORD
    
    .IF dwFrameColor != -1
        .IF dwFrameStyle != MUIPFS_NONE
            mov eax, dwFrameStyle
            and eax, MUIPFS_ALL
            .IF eax == MUIPFS_ALL
                ;--------------------------------------------------------------
                ; Paint entire frame
                ;--------------------------------------------------------------
                Invoke GdipCreatePen1, dwFrameColor, FP4(1.0), UnitPixel, Addr pPen
                Invoke GdipDrawRectangleI, pGraphics, pPen, [lpFrameRectI].RECT.left, [lpFrameRectI].RECT.top, [lpFrameRectI].RECT.right, [lpFrameRectI].RECT.bottom
                Invoke GdipDeletePen, pPen
            .ELSE
                ;--------------------------------------------------------------
                ; Paint only certain parts of the frame
                ;--------------------------------------------------------------
                Invoke GdipCreatePen1, dwFrameColor, FP4(1.0), UnitPixel, Addr pPen
                
                mov eax, dwFrameStyle
                and eax, MUIPFS_TOP
                .IF eax == MUIPFS_TOP
                    Invoke GdipDrawLineI, pGraphics, pPen, [lpFrameRectI].RECT.left, [lpFrameRectI].RECT.top, [lpFrameRectI].RECT.right, [lpFrameRectI].RECT.top
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_RIGHT
                .IF eax == MUIPFS_RIGHT
                    Invoke GdipDrawLineI, pGraphics, pPen, [lpFrameRectI].RECT.right, [lpFrameRectI].RECT.top, [lpFrameRectI].RECT.right, [lpFrameRectI].RECT.bottom
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_BOTTOM
                .IF eax == MUIPFS_BOTTOM
                    Invoke GdipDrawLineI, pGraphics, pPen, [lpFrameRectI].RECT.left, [lpFrameRectI].RECT.bottom, [lpFrameRectI].RECT.right, [lpFrameRectI].RECT.bottom
                .ENDIF
                mov eax, dwFrameStyle
                and eax, MUIPFS_LEFT
                .IF eax == MUIPFS_LEFT
                    Invoke GdipDrawLineI, pGraphics, pPen, [lpFrameRectI].RECT.left, [lpFrameRectI].RECT.top, [lpFrameRectI].RECT.left, [lpFrameRectI].RECT.bottom
                .ENDIF
                Invoke GdipDeletePen, pPen
            .ENDIF
        .ENDIF
    .ENDIF
    ret
MUIGDIPlusPaintFrameI ENDP


ENDIF


MODERNUI_LIBEND