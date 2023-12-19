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


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDICreateBitmapMask - Create a mask from an existing bitmap using the 
; specified color as the mask transparency: 
; http://www.winprog.org/tutorial/transparency.html
;------------------------------------------------------------------------------
MUIGDICreateBitmapMask PROC hBitmap:HBITMAP, TransparentColor:MUICOLORRGB
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hdcMem2:HDC
    LOCAL hdcMask:HDC
    LOCAL hbmMask:HBITMAP
    LOCAL hbmMaskOld:DWORD
    LOCAL hBitmapMask:DWORD
    LOCAL hBitmapMaskOld:DWORD
    LOCAL hBitmapOld:DWORD
    LOCAL bm:BITMAP

	Invoke GetDC, 0
	mov hdc, eax

    ; Create monochrome (1 bit) mask bitmap.  
    Invoke RtlZeroMemory, Addr bm, SIZEOF BITMAP
    Invoke GetObject, hBitmap, SIZEOF BITMAP, Addr bm
    Invoke CreateBitmap, bm.bmWidth, bm.bmHeight, 1, 1, NULL
    mov hbmMask, eax
    
    Invoke CreateCompatibleBitmap, hdc, bm.bmWidth, bm.bmHeight
    mov hBitmapMask, eax

    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleDC, hdc
    mov hdcMem2, eax
    Invoke CreateCompatibleDC, hdc
    mov hdcMask, eax

    Invoke SelectObject, hdcMem, hBitmap
    mov hBitmapOld, eax
    Invoke SelectObject, hdcMem2, hbmMask
    mov hbmMaskOld, eax
    Invoke SelectObject, hdcMask, hBitmapMask
    mov hBitmapMaskOld, eax
    
    Invoke SetBkColor, hdcMem, TransparentColor

    Invoke BitBlt, hdcMem2, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY
    Invoke BitBlt, hdcMask, 0, 0, bm.bmWidth, bm.bmHeight, hdcMem2, 0, 0, SRCINVERT

    ; Clean up.
    Invoke SelectObject, hdcMem, hBitmapOld
    Invoke DeleteObject, hBitmapOld
    
    Invoke SelectObject, hdcMem2, hbmMaskOld
    Invoke DeleteObject, hbmMaskOld
    Invoke DeleteObject, hbmMask
    
    Invoke SelectObject, hdcMask, hBitmapMaskOld
    Invoke DeleteObject, hBitmapMaskOld
    
    Invoke DeleteDC, hdcMem
    Invoke DeleteDC, hdcMem2
    Invoke DeleteDC, hdcMask
    
    Invoke ReleaseDC, 0, hdc
    
    mov eax, hBitmapMask
    ret
MUIGDICreateBitmapMask ENDP



MODERNUI_LIBEND