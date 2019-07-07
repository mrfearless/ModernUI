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


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIDoubleBufferStart - Starts double buffering. Used in a WM_PAINT event. 
; Place after BeginPaint call
;
; Example:
;
;    hdc:HDC 
;    LOCAL hdcMem:HDC
;    LOCAL hBufferBitmap:DWORD
;    LOCAL rect:RECT
;
;    Invoke BeginPaint, hWin, Addr ps
;    mov hdc, eax
;
;    ;----------------------------------------------------------
;    ; Setup Double Buffering
;    ;----------------------------------------------------------
;    Invoke MUIGDIDoubleBufferStart, hWin, hdc, Addr hdcMem, Addr rect, Addr hBufferBitmap 
;
;------------------------------------------------------------------------------
MUIGDIDoubleBufferStart PROC USES EBX hWin:DWORD, hdcSource:HDC, lpHDCBuffer:DWORD, lpClientRect:DWORD, lphBufferBitmap:DWORD
    LOCAL hdcBuffer:DWORD
    LOCAL hBufferBitmap:DWORD

    .IF lpHDCBuffer == 0 || lpClientRect == 0 || lphBufferBitmap == 0
        mov eax, FALSE                              ; Need all these to not be 0
        ret                                         ; so we need to fail if none are set
    .ENDIF
    Invoke GetClientRect, hWin, lpClientRect        ; Get dimensions of area to buffer
    Invoke CreateCompatibleDC, hdcSource            ; Create memory dc for our buffer
    mov hdcBuffer, eax                              ; Store memory dc created in a local variable
    mov ebx, lpHDCBuffer                            ; Get lpHDCBuffer
    mov [ebx], eax                                  ; Place hdcBuffer (in eax) into var pointed to by lpHDCBuffer (in ebx)
    Invoke SaveDC, hdcBuffer                        ; Save hdcBuffer status for later restore
    mov ebx, lpClientRect                           ; Create bitmap of size that matches dimensions
    Invoke CreateCompatibleBitmap, hdcSource, [ebx].RECT.right, [ebx].RECT.bottom
    mov hBufferBitmap, eax                          ; Store bitmap created in a local variable
    mov ebx, lphBufferBitmap                        ; Get lphBufferBitmap
    mov [ebx], eax                                  ; Place hBufferBitmap (in eax) into var pointed to by lphBufferBitmap (in ebx)
    Invoke SelectObject, hdcBuffer, hBufferBitmap   ; Select our created buffer bitmap into our memory dc
    mov eax, TRUE                                   ; When we later use hdcBuffer for drawing, we are actually using  
    ret                                             ; hBufferBitmap, which we will BitBlt back to hdcSource later on
MUIGDIDoubleBufferStart ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIDoubleBufferFinish - Finishes double buffering - cleans up afterwards.
; Used in a WM_PAINT event. Place before EndPaint call and after all Blt calls
;
; hBitmapUsed, hFontUsed, hBrushUsed, and hPenUsed are optional parameters.
; If you have used a bitmap image (not the double buffer bitmap which
; is hBufferBitmap) or a font, brush or pen in your code in the hdcBuffer 
; you can pass the handles here for cleaning up, otherwise pass 0 for the
; parameters that you havent used.
;
; Example:
;
;    ;----------------------------------------------------------
;    ; BitBlt from hdcMem back to hdc
;    ;----------------------------------------------------------
;    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY
;
;    ;----------------------------------------------------------
;    ; Finish Double Buffering & Cleanup
;    ;----------------------------------------------------------    
;    Invoke MUIGDIDoubleBufferFinish, hdcMem, hBufferBitmap, 0, 0, hBrush, 0
;
;    Invoke EndPaint, hWin, Addr ps
;
;------------------------------------------------------------------------------
MUIGDIDoubleBufferFinish PROC hdcBuffer:HDC, hBufferBitmap:HBITMAP, hBitmapUsed:HBITMAP, hFontUsed:HFONT, hBrushUsed:HBRUSH, hPenUsed:HPEN
    .IF hdcBuffer != 0
        Invoke RestoreDC, hdcBuffer, -1         ; restore last saved state, which is just after hdcBuffer was created
        .IF hBitmapUsed != 0
            Invoke DeleteObject, hBitmapUsed    ; Delete optional bitmap image - if a bitmap image was used at all 
        .ENDIF
        .If hFontUsed != 0
            Invoke DeleteObject, hFontUsed      ; Delete optional font - if a font was used at all
        .ENDIF
        .If hBrushUsed != 0
            Invoke DeleteObject, hBrushUsed     ; Delete optional brush - if a brush was used at all
        .ENDIF
        .If hPenUsed != 0
            Invoke DeleteObject, hPenUsed       ; Delete optional pen - if a pen was used at all
        .ENDIF        
        .IF hBufferBitmap != 0
            Invoke DeleteObject, hBufferBitmap  ; Delete bitmap used for double buffering
        .ENDIF
        Invoke DeleteDC, hdcBuffer              ; Delete double buffer hdc
    .ENDIF
    xor eax, eax
    ret
MUIGDIDoubleBufferFinish ENDP





MODERNUI_LIBEND



