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
include msimg32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msimg32.lib

include ModernUI.inc


.DATA
szMUIGDIBlendBitmapsDisplayDC DB 'DISPLAY',0

.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIBlendBitmaps - Blends two bitmaps together, or alternatively one bitmap
; and a block of color. dwTransparency determines level of blending
;------------------------------------------------------------------------------
MUIGDIBlendBitmaps PROC USES EBX hBitmap1:HBITMAP, hBitmap2:HBITMAP, ColorBitmap2:MUICOLORRGB, Transparency:MUIVALUE
    LOCAL nBmpWidth:DWORD
    LOCAL nBmpHeight:DWORD  
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hdcTemp:HDC
    LOCAL hdcBmp:HDC
    LOCAL pvBitsMem:DWORD
    LOCAL pvBitsTemp:DWORD
    LOCAL hbmMem:DWORD
    LOCAL hbmMemOld:DWORD
    LOCAL hbmTemp:DWORD
    LOCAL hbmTempOld:DWORD
    LOCAL hBitmap1Old:DWORD
    LOCAL hBitmap2Old:DWORD
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL bmi:BITMAPINFO
    LOCAL bf:BLENDFUNCTION    
    LOCAL bm:BITMAP
    LOCAL rect:RECT

    Invoke CreateDC, Addr szMUIGDIBlendBitmapsDisplayDC, NULL, NULL, NULL
    mov hdc, eax
    
    Invoke RtlZeroMemory, Addr bm, SIZEOF BITMAP
    Invoke GetObject, hBitmap1, SIZEOF bm, Addr bm
    mov eax, bm.bmWidth
    mov nBmpWidth, eax
    mov eax, bm.bmHeight
    mov nBmpHeight, eax    
    
    
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleDC, hdc
    mov hdcTemp, eax

    Invoke RtlZeroMemory, Addr bmi, SIZEOF BITMAPINFO

    ; setup bitmap info  
    mov bmi.bmiHeader.biSize, SIZEOF BITMAPINFOHEADER
    mov eax, nBmpWidth
    mov bmi.bmiHeader.biWidth, eax
    mov eax, nBmpHeight
    mov bmi.bmiHeader.biHeight, eax
    mov bmi.bmiHeader.biPlanes, 1
    mov bmi.bmiHeader.biBitCount, 32
    mov bmi.bmiHeader.biCompression, BI_RGB
    mov eax, nBmpWidth
    mov ebx, nBmpHeight
    mul ebx
    mov ebx, 4
    mul ebx
    mov bmi.bmiHeader.biSizeImage, eax

    ; create our DIB section and select the bitmap into the dc 
    Invoke CreateDIBSection, hdcMem, Addr bmi, DIB_RGB_COLORS, Addr pvBitsMem, NULL, 0
    mov hbmMem, eax

    Invoke CreateDIBSection, hdcTemp, Addr bmi, DIB_RGB_COLORS, Addr pvBitsTemp, NULL, 0
    mov hbmTemp, eax

    Invoke SelectObject, hdcMem, hbmMem
    mov hbmMemOld, eax

    Invoke SelectObject, hdcTemp, hbmTemp
    mov hbmTempOld, eax

    Invoke CreateCompatibleDC, hdcMem
    mov hdcBmp, eax 
    Invoke SelectObject, hdcBmp, hBitmap1
    mov hBitmap1Old, eax
    Invoke BitBlt, hdcMem, 0, 0, nBmpWidth, nBmpHeight, hdcBmp, 0, 0, SRCCOPY
    Invoke SelectObject, hdcBmp, hBitmap1Old
    Invoke DeleteObject, hBitmap1Old
    Invoke DeleteDC, hdcBmp

    .IF hBitmap2 != 0
        Invoke CreateCompatibleDC, hdcTemp
        mov hdcBmp, eax 
        Invoke SelectObject, hdcBmp, hBitmap2
        mov hBitmap2Old, eax
        Invoke BitBlt, hdcTemp, 0, 0, nBmpWidth, nBmpHeight, hdcBmp, 0, 0, SRCCOPY
        Invoke SelectObject, hdcBmp, hBitmap2Old
        Invoke DeleteObject, hBitmap2Old
        Invoke DeleteDC, hdcBmp
    .ELSE
        Invoke CreateSolidBrush, ColorBitmap2
        mov hBrush, eax
        Invoke SelectObject, hdcTemp, hBrush
        mov hBrushOld, eax
        mov rect.left, 0
        mov rect.top, 0
        mov eax, nBmpWidth
        mov rect.right, eax
        mov eax, nBmpHeight
        mov rect.bottom, eax
        Invoke FillRect, hdcTemp, Addr rect, hBrush
        Invoke SelectObject, hdcTemp, hBrushOld
        Invoke DeleteObject, hBrushOld
        Invoke DeleteObject, hBrush
    .ENDIF

    mov bf.BlendOp, AC_SRC_OVER
    mov bf.BlendFlags, 0
    mov eax, Transparency
    mov bf.SourceConstantAlpha, al ;transparency
    mov bf.AlphaFormat, 0 ;0;AC_SRC_ALPHA; AC_SRC_ALPHA   

    ;mov eax, dword ptr bf
    Invoke AlphaBlend, hdcMem, 0, 0, nBmpWidth, nBmpHeight, hdcTemp, 0, 0, nBmpWidth, nBmpHeight, dword ptr bf

    Invoke SelectObject, hdcTemp, hbmTempOld
    Invoke DeleteObject, hbmTempOld
    Invoke DeleteObject, hbmTemp
    Invoke SelectObject, hdcMem, hbmMemOld
    Invoke DeleteObject, hbmMemOld

    Invoke DeleteDC, hdcMem
    Invoke DeleteDC, hdcTemp
    Invoke DeleteDC, hdc
    
    mov eax, hbmMem
    
    ret

MUIGDIBlendBitmaps ENDP


MODERNUI_LIBEND






