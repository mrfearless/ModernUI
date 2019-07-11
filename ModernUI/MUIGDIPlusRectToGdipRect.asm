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
;-------------------------------------------------------------------------------------
; Convert normal RECT structure to GDIPRECT structure.
; Pass Addr of RECT struct (to convert from) & Addr of GDIPRECT Struct to convert to
;-------------------------------------------------------------------------------------
MUIGDIPlusRectToGdipRect PROC USES EBX EDX lpRect:LPRECT, lpGdipRect:LPGPRECT
    mov ebx, lpRect
    mov edx, lpGdipRect
    finit
    fild [ebx].RECT.left
    lea	eax, [edx].GDIPRECT.left
    fstp real4 ptr [eax]
    fild [ebx].RECT.top
    lea	eax, [edx].GDIPRECT.top
    fstp real4 ptr [eax]
    fild [ebx].RECT.right
    lea	eax, [edx].GDIPRECT.right
    fstp real4 ptr [eax]
    fild [ebx].RECT.bottom
    lea	eax, [edx].GDIPRECT.bottom
    fstp real4 ptr [eax]
    ret
MUIGDIPlusRectToGdipRect ENDP


MODERNUI_LIBEND

