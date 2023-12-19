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
; Gets parent's background bitmap from parent DC, at the child's location and 
; size. For use in setting background of child to 'transparent'
; Returns in eax hBitmap or NULL
;------------------------------------------------------------------------------
MUIGetParentBackgroundBitmap PROC hWin:MUIWND
    LOCAL rcWin:RECT
    LOCAL rcWnd:RECT
    LOCAL parWnd:DWORD
    LOCAL parDc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hOldBitmap:DWORD
	LOCAL dwWidth:DWORD
	LOCAL dwHeight:DWORD      

    Invoke GetParent, hWin; // Get the parent window.
    mov parWnd, eax
    Invoke GetDC, parWnd; // Get its DC.
    mov parDc, eax 
    ;Invoke UpdateWindow, hWnd
    Invoke GetWindowRect, hWin, Addr rcWnd;
    Invoke ScreenToClient, parWnd, Addr rcWnd; // Convert to the parent's co-ordinates
    Invoke GetClipBox, parDc, Addr rcWin
    
    ; Copy from parent DC.
    mov eax, rcWin.right
    sub eax, rcWin.left
    mov dwWidth, eax

    mov eax, rcWin.bottom
    sub eax, rcWin.top
    mov dwHeight, eax    

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke CreateCompatibleDC, parDc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, parDc, dwWidth, dwHeight
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax

    Invoke BitBlt, hdcMem, 0, 0, dwWidth, dwHeight, parDc, rcWnd.left, rcWnd.top, SRCCOPY;

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    Invoke SelectObject, hdcMem, hOldBitmap
    Invoke DeleteDC, hdcMem
    ;Invoke DeleteObject, hbmMem ; need to keep this bitmap to return it
    .IF hOldBitmap != 0
        Invoke DeleteObject, hOldBitmap
    .ENDIF          
    Invoke ReleaseDC, parWnd, parDc
    
    mov eax, hbmMem
    ret
MUIGetParentBackgroundBitmap ENDP


MODERNUI_LIBEND



