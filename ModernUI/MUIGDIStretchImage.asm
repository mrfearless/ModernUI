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

;EXTERNDEF MUIGDIStretchBitmap           :PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
EXTERNDEF MUIGDIStretchBitmap            :PROTO :HBITMAP,:LPRECT,:LPMUIVALUE,:LPMUIVALUE,:LPMUIVALUE,:LPMUIVALUE
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
MUIGDIStretchImage PROC USES EBX hImage:MUIIMAGE, ImageHandleType:MUIIT, lpBoundsRect:LPRECT, lpImageWidth:LPMUIVALUE, lpImageHeight:LPMUIVALUE, lpImageX:LPMUIVALUE, lpImageY:LPMUIVALUE

    mov eax, ImageHandleType
    .IF eax == MUIIT_BMP ; bitmap/icon
        Invoke MUIGDIStretchBitmap, hImage, lpBoundsRect, lpImageWidth, lpImageHeight, lpImageX, lpImageY
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
    
    .IF lpImageX != 0
        mov ebx, lpImageX
        mov eax, 0
        mov [ebx], eax    
    .ENDIF
    .IF lpImageY != 0
        mov ebx, lpImageY
        mov eax, 0
        mov [ebx], eax    
    .ENDIF
    .IF lpImageWidth != 0
        mov ebx, lpImageWidth
        mov eax, 0
        mov [ebx], eax
    .ENDIF
    .IF lpImageHeight != 0
        mov ebx, lpImageHeight
        mov eax, 0
        mov [ebx], eax
    .ENDIF    
    mov eax, 0
    
    ret
MUIGDIStretchImage ENDP


MODERNUI_LIBEND





