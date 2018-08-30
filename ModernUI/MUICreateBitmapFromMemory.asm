;==============================================================================
;
; ModernUI Library v0.0.0.5
;
; Copyright (c) 2018 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
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


.DATA
szMUIBitmapFromMemoryDisplayDC DB 'DISPLAY',0


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICreateBitmapFromMemory
;
; http://www.masmforum.com/board/index.php?topic=16267.msg134453#msg134453
;------------------------------------------------------------------------------
MUICreateBitmapFromMemory PROC USES ECX EDX pBitmapData:DWORD
    LOCAL hDC:DWORD
    LOCAL hBmp:DWORD

    ;Invoke GetDC,hWnd
    Invoke CreateDC, Addr szMUIBitmapFromMemoryDisplayDC, NULL, NULL, NULL
    test    eax,eax
    jz      @f
    mov     hDC,eax
    mov     edx,pBitmapData
    lea     ecx,[edx + SIZEOF BITMAPFILEHEADER]  ; start of the BITMAPINFOHEADER header
    mov     eax,BITMAPFILEHEADER.bfOffBits[edx]
    add     edx,eax
    Invoke  CreateDIBitmap,hDC,ecx,CBM_INIT,edx,ecx,DIB_RGB_COLORS
    mov     hBmp,eax
    ;Invoke  ReleaseDC,hWnd,hDC
    Invoke DeleteDC, hDC
    mov     eax,hBmp
@@:
    ret
MUICreateBitmapFromMemory ENDP


END




