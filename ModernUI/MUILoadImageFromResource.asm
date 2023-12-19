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
include ole32.inc
includelib gdiplus.lib
includelib ole32.lib
ENDIF


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUILoadImageFromResource
;------------------------------------------------------------------------------
MUILoadImageFromResource PROC hWin:MUIWND, InstanceProperty:MUIPROPERTY, Property:MUIPROPERTY, ImageHandleType:MUIIT, idResImage:RESID
    mov eax, ImageHandleType
    .IF eax == MUIIT_NONE
        mov eax, NULL
    .ELSEIF eax == MUIIT_BMP ; bitmap/icon
        Invoke MUILoadBitmapFromResource, hWin, InstanceProperty, Property, idResImage
    .ELSEIF eax == MUIIT_ICO ; icon  
        Invoke MUILoadIconFromResource, hWin, InstanceProperty, Property, idResImage
    IFDEF MUI_USEGDIPLUS
    .ELSEIF eax == MUIIT_PNG ; png
        Invoke MUILoadPngFromResource, hWin, InstanceProperty, Property, idResImage
    .ELSEIF eax > MUIIT_PNG
        mov eax, NULL
    ELSE
    .ELSEIF eax > MUIIT_BMP
        mov eax, NULL
    ENDIF
    .ENDIF
    ret
MUILoadImageFromResource ENDP




MODERNUI_LIBEND




