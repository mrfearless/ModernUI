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
; MUILoadBitmapFromResource - Loads specified bitmap resource into the specified 
; external property and returns old bitmap handle (if it previously existed) in 
; eax or NULL. If dwInstanceProperty != -1 fetches stored value to use as 
; hinstance to load bitmap resource. If dwProperty == -1, no property to set, 
; so eax will contain hBitmap or NULL
;
; To load a bitmap resource and simply return its handle, use -1 in property.
;
;------------------------------------------------------------------------------
MUILoadBitmapFromResource PROC hWin:DWORD, dwInstanceProperty:DWORD, dwProperty:DWORD, idResBitmap:DWORD
    LOCAL hinstance:DWORD
    LOCAL hOldBitmap:DWORD

    .IF (hWin == NULL && dwInstanceProperty != -1) || idResBitmap == NULL
        mov eax, NULL
        ret
    .ENDIF

    .IF dwInstanceProperty != -1
        Invoke MUIGetExtProperty, hWin, dwInstanceProperty
        .IF eax == 0
            Invoke GetModuleHandle, NULL
        .ENDIF
    .ELSE
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    .IF dwProperty != -1
        Invoke MUIGetExtProperty, hWin, dwProperty
        .IF eax != 0
            mov hOldBitmap, eax
        .ELSE
            mov hOldBitmap, NULL
        .ENDIF
    .ENDIF

    Invoke LoadBitmap, hinstance, idResBitmap
    .IF dwProperty != -1
        Invoke MUISetExtProperty, hWin, dwProperty, eax
        mov eax, hOldBitmap
    .ENDIF
    ret
MUILoadBitmapFromResource ENDP


MODERNUI_LIBEND



