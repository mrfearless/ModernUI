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
include msimg32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msimg32.lib

include ModernUI.inc

EXTERNDEF MUIGDIPaintFill :PROTO hdc:HDC, lpFillRect:LPRECT, FillColor:MUICOLORRGB


IFNDEF TRIVERTEX
TRIVERTEX STRUCT
  x       DWORD ?
  y       DWORD ?
  Red     WORD ?
  Green   WORD ?
  Blue    WORD ?
  Alpha   WORD ?
TRIVERTEX ENDS
ENDIF

IFNDEF GRADIENT_TRIANGLE
GRADIENT_TRIANGLE STRUCT
  Vertex1         DWORD ?
  Vertex2         DWORD ?
  Vertex3         DWORD ?
GRADIENT_TRIANGLE ENDS
ENDIF

IFNDEF GRADIENT_RECT
GRADIENT_RECT STRUCT
  UpperLeft   DWORD ?
  LowerRight  DWORD ?
GRADIENT_RECT ENDS
ENDIF

;GRADIENT_FILL_RECT_H             equ 00000000h
;GRADIENT_FILL_RECT_V             equ 00000001h


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIPaintGradient - Fills specified rect in the DC with a gradient
;
; clrGradientFrom   COLORREF or MUI_RGBCOLOR from
; clrGradientTo     COLORREF or MUI_RGBCOLOR from
; HorzVertGradient  Horizontal == FALSE, Vertical == TRUE 
;
;------------------------------------------------------------------------------
MUIGDIPaintGradient PROC USES EBX hdc:HDC, lpGradientRect:LPRECT, GradientColorFrom:MUICOLORRGB, GradientColorTo:MUICOLORRGB, HorzVertGradient:MUIPGS
    LOCAL clrRed:DWORD
    LOCAL clrGreen:DWORD
    LOCAL clrBlue:DWORD
    LOCAL mesh:GRADIENT_RECT
    LOCAL vertex[3]:TRIVERTEX
    
    mov eax, GradientColorFrom
    .IF eax == GradientColorTo ; if same color then just do a fill instead
        Invoke MUIGDIPaintFill, hdc, lpGradientRect, GradientColorFrom
        ret
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Seperate GradientFrom ColorRef to 3 dwords for Red, Green & Blue
    ;--------------------------------------------------------------------------
    xor eax, eax
    mov eax, GradientColorFrom
    xor ebx, ebx
    mov bh, al
    mov clrRed, ebx
    xor ebx, ebx
    mov bh, ah
    mov clrGreen, ebx
    xor ebx, ebx
    shr eax, 16d
    mov bh, al
    mov clrBlue, ebx

    ;--------------------------------------------------------------------------
    ; Populate vertex 1 structure
    ;-------------------------------------------------------------------------- 
    ; fill x from rect left
    mov ebx, lpGradientRect
    mov eax, [ebx].RECT.left
    lea ebx, vertex
    mov [ebx].TRIVERTEX.x, eax

    ; fill y from rect top
    mov ebx, lpGradientRect
    mov eax, [ebx].RECT.top
    lea ebx, vertex
    mov [ebx].TRIVERTEX.y, eax

    ; fill colors from seperated colorref
    mov [ebx].TRIVERTEX.Alpha, 0
    mov eax, clrRed
    mov [ebx].TRIVERTEX.Red, ax
    mov eax, clrGreen
    mov [ebx].TRIVERTEX.Green, ax
    mov eax, clrBlue
    mov [ebx].TRIVERTEX.Blue, ax

    ;--------------------------------------------------------------------------
    ; Seperate GradientFrom ColorRef to 3 dwords for Red, Green & Blue
    ;--------------------------------------------------------------------------   
    xor eax, eax
    mov eax, GradientColorTo
    xor ebx, ebx
    mov bh, al
    mov clrRed, ebx
    xor ebx, ebx
    mov bh, ah
    mov clrGreen, ebx
    xor ebx, ebx
    shr eax, 16d
    mov bh, al
    mov clrBlue, ebx    

    ;--------------------------------------------------------------------------
    ; Populate vertex 2 structure
    ;--------------------------------------------------------------------------
    ; fill x from rect right
    mov ebx, lpGradientRect
    mov eax, [ebx].RECT.right
    lea ebx, vertex
    add ebx, sizeof TRIVERTEX
    mov [ebx].TRIVERTEX.x, eax
    
    ; fill x from rect right
    mov ebx, lpGradientRect
    mov eax, [ebx].RECT.bottom
    lea ebx, vertex
    add ebx, sizeof TRIVERTEX
    mov [ebx].TRIVERTEX.y, eax
    
    ; fill colors from seperated colorref
    mov [ebx].TRIVERTEX.Alpha, 0
    mov eax, clrRed
    mov [ebx].TRIVERTEX.Red, ax
    mov eax, clrGreen
    mov [ebx].TRIVERTEX.Green, ax
    mov eax, clrBlue
    mov [ebx].TRIVERTEX.Blue, ax

    ;--------------------------------------------------------------------------
    ; Set the mesh (gradient rectangle) point
    ;--------------------------------------------------------------------------
    mov mesh.UpperLeft, 0
    mov mesh.LowerRight, 1

    ;--------------------------------------------------------------------------
    ; Call GradientFill function
    ;--------------------------------------------------------------------------
    Invoke GradientFill, hdc, Addr vertex, 2, Addr mesh, 1, HorzVertGradient ; Horz = 0, Vert = 1

    ret
MUIGDIPaintGradient endp



MODERNUI_LIBEND

