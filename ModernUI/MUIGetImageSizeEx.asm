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

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
includelib gdiplus.lib
ENDIF

EXTERNDEF MUIGetImageSize            :PROTO hImage:MUIIMAGE,ImageHandleType:MUIIT,lpImageWidth:LPMUIVALUE,lpImageHeight:LPMUIVALUE


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGetImageSizeEx - Similar to MUIGetImageSize, but also returns centering
; x and y co-ord information based on rectangle of hWin
;------------------------------------------------------------------------------
MUIGetImageSizeEx PROC USES EBX hWin:MUIWND, hImage:MUIIMAGE, ImageHandleType:MUIIT, lpImageWidth:LPMUIVALUE, lpImageHeight:LPMUIVALUE, lpImageX:LPMUIVALUE, lpImageY:LPMUIVALUE
    LOCAL rect:RECT
    LOCAL dwImageWidth:DWORD
    LOCAL dwImageHeight:DWORD
    LOCAL dwXPos:DWORD
    LOCAL dwYPos:DWORD
    LOCAL RetVal:DWORD

    Invoke MUIGetImageSize, hImage, ImageHandleType, Addr dwImageWidth, Addr dwImageHeight
    .IF eax == FALSE
        mov dwImageWidth, 0
        mov dwImageHeight, 0
        mov dwXPos, 0
        mov dwYPos, 0
        mov RetVal, FALSE
    .ELSE
        Invoke GetClientRect, hWin, Addr rect
        mov eax, rect.right
        sub eax, rect.left
        sub eax, dwImageWidth
        shr eax, 1 ; div by 2
        .IF sdword ptr eax < 0
            mov eax, 0
        .ENDIF
        mov dwXPos, eax
        mov eax, rect.bottom
        sub eax, rect.top
        sub eax, dwImageHeight
        shr eax, 1 ; div by 2
        .IF sdword ptr eax < 0
            mov eax, 0
        .ENDIF        
        mov dwYPos, eax
        mov RetVal, TRUE
    .ENDIF

    .IF lpImageWidth != 0
        mov ebx, lpImageWidth
        mov eax, dwImageWidth
        mov [ebx], eax
    .ENDIF
    .IF lpImageHeight != 0
        mov ebx, lpImageHeight
        mov eax, dwImageHeight
        mov [ebx], eax
    .ENDIF
    .IF lpImageX != 0
        mov ebx, lpImageX
        mov eax, dwXPos
        mov [ebx], eax
    .ENDIF
    .IF lpImageY != 0
        mov ebx, lpImageY
        mov eax, dwYPos
        mov [ebx], eax
    .ENDIF    

    mov eax, RetVal
    ret
MUIGetImageSizeEx ENDP


MODERNUI_LIBEND



