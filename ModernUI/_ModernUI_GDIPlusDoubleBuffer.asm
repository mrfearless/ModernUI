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


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Start Double Buffering for GDI+
;------------------------------------------------------------------------------
MUIGDIPlusDoubleBufferStart PROC USES EBX hWin:DWORD, pGraphics:DWORD, lpBitmapHandle:DWORD, lpGraphicsBuffer:DWORD
    LOCAL rect:RECT
    LOCAL pBuffer:DWORD
    LOCAL pBitmap:DWORD
    
    Invoke GetClientRect, hWin, Addr rect
    Invoke GdipCreateBitmapFromGraphics, rect.right, rect.bottom, pGraphics, Addr pBitmap
    Invoke GdipGetImageGraphicsContext, pBitmap, Addr pBuffer

    ; Save our created bitmap and buffer back to pGraphicsBuffer
    .IF lpGraphicsBuffer != NULL
        mov ebx, lpGraphicsBuffer
        mov eax, pBuffer
        mov [ebx], eax
    .ENDIF
    .IF lpBitmapHandle != NULL
        mov ebx, lpBitmapHandle
        mov eax, pBitmap
        mov [ebx], eax
    .ENDIF
    
    xor eax, eax
    ret
MUIGDIPlusDoubleBufferStart ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Finish Double Buffering for GDI+ & copy finished pGraphicsBuffer to pGraphics (HDC)
;------------------------------------------------------------------------------
MUIGDIPlusDoubleBufferFinish PROC hWin:DWORD, pGraphics:DWORD, hBitmap:DWORD, pGraphicsBuffer:DWORD
    LOCAL rect:RECT
    
    Invoke GetClientRect, hWin, Addr rect
    Invoke GdipDrawImageRectI, pGraphics, hBitmap, 0, 0, rect.right, rect.bottom
    Invoke GdipDeleteGraphics, pGraphicsBuffer   
    invoke GdipDisposeImage, hBitmap
    xor eax, eax
    ret
MUIGDIPlusDoubleBufferFinish ENDP


ENDIF


MODERNUI_LIBEND

