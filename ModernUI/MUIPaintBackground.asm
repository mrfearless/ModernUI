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


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Paints the background of the main window a specified color
; optional provide BorderColor for border. If BorderColor = -1, no border is
; drawn.
;
; If you are using this on a window/dialog that does not use the 
; ModernUI_CaptionBar control AND window/dialog is resizable, you should place 
; a call to InvalidateRect in the WM_NCCALCSIZE handler to prevent ugly drawing 
; artifacts when border is drawn whilst resize of window/dialog occurs. 
; The ModernUI_CaptionBar handles this call to WM_NCCALCSIZE already by default
;
; Here is an example of what to include if you need:
;
;    .ELSEIF eax == WM_NCCALCSIZE
;        Invoke InvalidateRect, hWin, NULL, TRUE
; 
;------------------------------------------------------------------------------
MUIPaintBackground PROC hWin:MUIWND, BackColor:MUICOLORRGB, BorderColor:MUICOLORRGB
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:HBITMAP

    Invoke BeginPaint, hWin, addr ps
    mov hdc, eax

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke MUIGDIDoubleBufferStart, hWin, hdc, Addr hdcMem, Addr rect, Addr hBufferBitmap

    ;----------------------------------------------------------
    ; Paint background
    ;----------------------------------------------------------
    Invoke MUIGDIPaintFill, hdcMem, Addr rect, BackColor

    ;----------------------------------------------------------
    ; Paint Border
    ;----------------------------------------------------------
    .IF BorderColor != -1
        Invoke MUIGDIPaintFrame, hdcMem, Addr rect, BorderColor, MUIPFS_ALL
    .ENDIF
    
    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Finish Double Buffering & Cleanup
    ;----------------------------------------------------------    
    Invoke MUIGDIDoubleBufferFinish, hdcMem, hBufferBitmap, 0, 0, 0, 0    

    Invoke EndPaint, hWin, addr ps
    mov eax, 0
    ret
MUIPaintBackground ENDP


MODERNUI_LIBEND



