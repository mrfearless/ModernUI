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
; MUILoadIconFromResource - Loads specified icon resource into the specified 
; external property and returns old icon handle (if it previously existed) in 
; eax or NULL. If dwInstanceProperty != 0 fetches stored value to use as 
; hinstance to load icon resource. If dwProperty == -1, no property to set, 
; so eax will contain hIcon or NULL
;------------------------------------------------------------------------------
MUILoadIconFromResource PROC hWin:MUIWND, InstanceProperty:MUIPROPERTY, Property:MUIPROPERTY, idResIcon:RESID
    LOCAL hinstance:DWORD
    LOCAL hOldIcon:DWORD

    .IF hWin == NULL || idResIcon == NULL
        mov eax, NULL
        ret
    .ENDIF

    .IF InstanceProperty != 0
        Invoke MUIGetExtProperty, hWin, InstanceProperty
        .IF eax == 0
            Invoke GetModuleHandle, NULL
        .ENDIF
    .ELSE
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax
    .IF Property != -1
        Invoke MUIGetExtProperty, hWin, Property
        .IF eax != 0
            mov hOldIcon, eax
        .ELSE
            mov hOldIcon, NULL
        .ENDIF
    .ENDIF
    
    Invoke LoadImage, hinstance, idResIcon, IMAGE_ICON, 0, 0, 0
    .IF Property != -1
        Invoke MUISetExtProperty, hWin, Property, eax
        mov eax, hOldIcon
    .ENDIF
    ret
MUILoadIconFromResource ENDP


MODERNUI_LIBEND



