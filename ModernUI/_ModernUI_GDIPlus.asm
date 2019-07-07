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

PUBLIC MUI_GDIPLUS

.DATA
;------------------------------------------------------------------------------
; Controls that use gdiplus check the MUI_GDIPLUS variable first. If it is 0 
; they call MUIGDIPlusStart and increment the MUI_GDIPLUS value. 
; When the control is destroyed, they decrement the MUI_GDIPLUS value and check
; if it is 0. If it is 0 they call MUIGDIPlusFinish to finish up.
;------------------------------------------------------------------------------
MUI_GDIPLUS          DD 0 
MUI_GDIPlusToken     DD 0
MUI_GDIPSI           GdiplusStartupInput <1,0,0,0>


.CODE

MUI_ALIGN
;------------------------------------------------------------------------------
; Start of ModernUI framework (wrapper for gdiplus startup)
; Placed at start of program before WinMain call
;------------------------------------------------------------------------------
MUIGDIPlusStart PROC
    .IF MUI_GDIPLUS == 0
        ;PrintText 'GdiplusStartup'
        Invoke GdiplusStartup, Addr MUI_GDIPlusToken, Addr MUI_GDIPSI, NULL
    .ENDIF
    inc MUI_GDIPLUS
    ;PrintDec MUI_GDIPLUS
    xor eax, eax
    ret
MUIGDIPlusStart ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Finish ModernUI framework (wrapper for gdiplus shutdown)
; Placed after WinMain call before ExitProcess
;------------------------------------------------------------------------------
MUIGDIPlusFinish PROC
    ;PrintDec MUI_GDIPLUS
    dec MUI_GDIPLUS
    .IF MUI_GDIPLUS == 0
        ;PrintText 'GdiplusShutdown'
        Invoke GdiplusShutdown, MUI_GDIPlusToken
    .ENDIF
    xor eax, eax
    ret
MUIGDIPlusFinish ENDP


ENDIF


MODERNUI_LIBEND

