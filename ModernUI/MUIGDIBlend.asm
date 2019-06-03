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
include kernel32.inc
include gdi32.inc
include msimg32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib msimg32.lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIBlend - Blends an existing dc (which can have a bitmap in it) with a 
; block of color. dwTransparency determines level of blending
;------------------------------------------------------------------------------
MUIGDIBlend PROC USES EBX hWin:DWORD, hdc:DWORD, dwColor:DWORD, dwTransparency:DWORD
    LOCAL hdcMem:HDC
    LOCAL pvBitsMem:DWORD
    LOCAL hbmMem:DWORD
    LOCAL hbmMemOld:DWORD
    LOCAL nWidth:DWORD
    LOCAL nHeight:DWORD
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD    
    LOCAL bmi:BITMAPINFO
    LOCAL bf:BLENDFUNCTION    
    LOCAL rect:RECT
    
    Invoke GetClientRect, hWin, Addr rect
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    
    Invoke RtlZeroMemory, Addr bmi, SIZEOF BITMAPINFO
    mov bmi.bmiHeader.biSize, SIZEOF BITMAPINFOHEADER
    mov eax, rect.right
    sub eax, rect.left
    mov nWidth, eax
    mov bmi.bmiHeader.biWidth, eax
    mov eax, rect.bottom
    sub eax, rect.top
    mov nHeight, eax
    mov bmi.bmiHeader.biHeight, eax
    mov bmi.bmiHeader.biPlanes, 1
    mov bmi.bmiHeader.biBitCount, 32
    mov bmi.bmiHeader.biCompression, BI_RGB
    mov eax, nWidth
    mov ebx, nHeight
    mul ebx
    mov ebx, 4
    mul ebx
    mov bmi.bmiHeader.biSizeImage, eax    
    
    Invoke CreateDIBSection, hdcMem, Addr bmi, DIB_RGB_COLORS, Addr pvBitsMem, NULL, 0
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hbmMemOld, eax
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SetDCBrushColor, hdcMem, dwColor
    Invoke SelectObject, hdcMem, hBrush
    mov hBrushOld, eax
    Invoke FillRect, hdcMem, Addr rect, hBrush
    Invoke SelectObject, hdcMem, hBrushOld
    Invoke DeleteObject, hBrushOld
    Invoke DeleteObject, hBrush
    
    mov bf.BlendOp, AC_SRC_OVER
    mov bf.BlendFlags, 0
    mov eax, dwTransparency
    mov bf.SourceConstantAlpha, al
    mov bf.AlphaFormat, 0 ; AC_SRC_ALPHA   
    Invoke AlphaBlend, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, rect.right, rect.bottom, dword ptr bf
    
    Invoke SelectObject, hdcMem, hbmMemOld
    Invoke DeleteObject, hbmMemOld
    Invoke DeleteDC, hdcMem
    ret
MUIGDIBlend ENDP


MODERNUI_LIBEND




