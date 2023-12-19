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
; Paints the border of the main window a specified color.
; If BorderColor = -1, no border is drawn.
;------------------------------------------------------------------------------
MUIPaintBorder PROC hWin:MUIWND, BorderColor:MUICOLORRGB
    LOCAL hdc:HDC
    LOCAL SavedDC:DWORD
    LOCAL rect:RECT

    .IF BorderColor == -1
        ret
    .ENDIF

    Invoke GetWindowDC, hWin
    .IF eax != 0
        mov hdc, eax
        Invoke SaveDC, hdc
        mov SavedDC, eax
        Invoke GetClientRect, hWin, Addr rect
        inc rect.right
        inc rect.bottom
        inc rect.right
        inc rect.bottom
        ;------------------------------------------------------
        ; Paint Border
        ;------------------------------------------------------
        Invoke MUIGDIPaintFrame, hdc, Addr rect, BorderColor, MUIPFS_ALL
    
        Invoke RestoreDC, hdc, SavedDC
        Invoke ReleaseDC, hWin, hdc
    .ENDIF

    ret
MUIPaintBorder ENDP



MODERNUI_LIBEND