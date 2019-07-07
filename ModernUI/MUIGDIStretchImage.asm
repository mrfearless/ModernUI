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

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
includelib gdiplus.lib
ENDIF

EXTERNDEF MUIGDIStretchBitmap           :PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
;EXTERNDEF MUIGDIStretchIcon             :PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
;EXTERNDEF MUIGDIStretchPng              :PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIStretchImage - Returns new stretched image in eax. 
; Image is scaled to fit rectangle specified by lpBoundsRect. 
; On return the new image height and width are returned in lpdwImageWidth and 
; lpdwImageHeight. Additionaly the x and y positioning to center the new image 
; in the rectangle specified by lpBoundsRect are returned in lpdwImageX and 
; lpdwImageY.
;------------------------------------------------------------------------------
MUIGDIStretchImage PROC USES EBX hImage:DWORD, dwImageType:DWORD, lpBoundsRect:DWORD, lpdwImageWidth:DWORD, lpdwImageHeight:DWORD, lpdwImageX:DWORD, lpdwImageY:DWORD

    mov eax, dwImageType
    .IF eax == MUIIT_BMP ; bitmap/icon
        Invoke MUIGDIStretchBitmap, hImage, lpBoundsRect, lpdwImageWidth, lpdwImageHeight, lpdwImageX, lpdwImageY
        ret
        
    .ELSEIF eax == MUIIT_ICO ; icon
        ;Invoke MUIGDIStretchIcon, hImage, lpBoundsRect, lpdwImageWidth, lpdwImageHeight, lpdwImageX, lpdwImageY
        ret
    
    IFDEF MUI_USEGDIPLUS
    .ELSEIF eax == MUIIT_PNG ; png
        ;Invoke MUIGDIStretchPng, hImage, lpBoundsRect, lpdwImageWidth, lpdwImageHeight, lpdwImageX, lpdwImageY
        ret
    ENDIF

    .ENDIF
    
    .IF lpdwImageX != 0
        mov ebx, lpdwImageX
        mov eax, 0
        mov [ebx], eax    
    .ENDIF
    .IF lpdwImageY != 0
        mov ebx, lpdwImageY
        mov eax, 0
        mov [ebx], eax    
    .ENDIF
    .IF lpdwImageWidth != 0
        mov ebx, lpdwImageWidth
        mov eax, 0
        mov [ebx], eax
    .ENDIF
    .IF lpdwImageHeight != 0
        mov ebx, lpdwImageHeight
        mov eax, 0
        mov [ebx], eax
    .ENDIF    
    mov eax, 0
    
    ret
MUIGDIStretchImage ENDP


MODERNUI_LIBEND





