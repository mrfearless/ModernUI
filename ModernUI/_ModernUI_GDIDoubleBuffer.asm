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
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIDoubleBufferStart - Starts double buffering. Used in a WM_PAINT event. 
; Place after BeginPaint call
;------------------------------------------------------------------------------
MUIGDIDoubleBufferStart PROC USES EBX hWin:DWORD, hdcSource:HDC, lpHDCBuffer:DWORD, lpClientRect:DWORD, lpBufferBitmap:DWORD, lpPreBufferBitamp:DWORD
    LOCAL hdcBuffer:DWORD
    LOCAL hBitmap:DWORD

    .IF lpHDCBuffer == 0 || lpClientRect == 0 || lpBufferBitmap == 0 || lpPreBufferBitamp == 0
        mov eax, FALSE
        ret
    .ENDIF
    Invoke GetClientRect, hWin, lpClientRect
    Invoke CreateCompatibleDC, hdcSource
    mov hdcBuffer, eax
    mov ebx, lpHDCBuffer
    mov [ebx], eax
    mov ebx, lpClientRect
    Invoke CreateCompatibleBitmap, hdcSource, [ebx].RECT.right, [ebx].RECT.bottom
    mov hBitmap, eax
    mov ebx, lpBufferBitmap
    mov [ebx], eax
    Invoke SelectObject, hdcBuffer, hBitmap
    mov ebx, lpPreBufferBitamp
    mov [ebx], eax
    mov eax, TRUE
    ret
MUIGDIDoubleBufferStart ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIDoubleBufferFinish - Finishes double buffering - cleans up afterwards.
; Used in a WM_PAINT event. Place before EndPaint call and after all Blt calls
;------------------------------------------------------------------------------
MUIGDIDoubleBufferFinish PROC hdcBuffer:HDC, hBufferBitmap:HBITMAP, hPreBufferBitamp:HBITMAP
    .IF hBufferBitmap != 0
        Invoke SelectObject, hdcBuffer, hBufferBitmap
        Invoke DeleteObject, hBufferBitmap
    .ENDIF
    .IF hPreBufferBitamp != 0
        Invoke SelectObject, hdcBuffer, hPreBufferBitamp
        Invoke DeleteObject, hPreBufferBitamp
    .ENDIF
    .IF hdcBuffer != 0
        Invoke DeleteDC, hdcBuffer
    .ENDIF
    ret
MUIGDIDoubleBufferFinish ENDP


END



