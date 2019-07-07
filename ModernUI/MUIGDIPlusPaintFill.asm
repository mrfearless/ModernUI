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
; MUIGDIPlusPaintFill - Fills a rectangle with a specific color
;
; lpFillRect is a pointer to a GDIPRECT containing the bounding box to fill
; dwFillColor is an ARGBCOLOR to paint fill the rectangle with
;------------------------------------------------------------------------------
MUIGDIPlusPaintFill PROC pGraphics:DWORD, lpFillGdipRect:DWORD, dwFillColor:DWORD
    LOCAL pBrush:DWORD
    Invoke GdipCreateSolidFill, dwFillColor, Addr pBrush
    Invoke GdipFillRectangle, pGraphics, pBrush, [lpFillGdipRect].GDIPRECT.left, [lpFillGdipRect].GDIPRECT.top, [lpFillGdipRect].GDIPRECT.right, [lpFillGdipRect].GDIPRECT.bottom
    Invoke GdipDeleteBrush, pBrush
    ret
MUIGDIPlusPaintFill ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIPlusPaintFillI - Fills a rectangle with a specific color
;
; lpFillRectI is a pointer to a RECT containing the bounding box to fill
; dwFillColor is an ARGBCOLOR to paint fill the rectangle with
;------------------------------------------------------------------------------
MUIGDIPlusPaintFillI PROC pGraphics:DWORD, lpFillRectI:DWORD, dwFillColor:DWORD
    LOCAL pBrush:DWORD
    Invoke GdipCreateSolidFill, dwFillColor, Addr pBrush
    Invoke GdipFillRectangleI, pGraphics, pBrush, [lpFillRectI].RECT.left, [lpFillRectI].RECT.top, [lpFillRectI].RECT.right, [lpFillRectI].RECT.bottom
    Invoke GdipDeleteBrush, pBrush
    ret
MUIGDIPlusPaintFillI ENDP


ENDIF


MODERNUI_LIBEND

