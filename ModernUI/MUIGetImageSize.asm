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

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
includelib gdiplus.lib
ENDIF


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGetImageSize
;------------------------------------------------------------------------------
MUIGetImageSize PROC USES EBX hImage:DWORD, dwImageType:DWORD, lpdwImageWidth:DWORD, lpdwImageHeight:DWORD
    LOCAL bm:BITMAP
    LOCAL iinfo:ICONINFO
    LOCAL nImageWidth:DWORD
    LOCAL nImageHeight:DWORD
    LOCAL RetVal:DWORD
    
    mov nImageWidth, 0
    mov nImageHeight, 0
    mov RetVal, FALSE
    
    .IF hImage == NULL
        ; fall out and return defaults
    .ELSE

        mov eax, dwImageType
        ;-----------------------------------
        ; BITMAP
        ;-----------------------------------
        .IF eax == MUIIT_BMP ; bitmap/icon
            Invoke RtlZeroMemory, Addr bm, SIZEOF BITMAP
            Invoke GetObject, hImage, SIZEOF bm, Addr bm
            .IF eax != 0
                mov eax, bm.bmWidth
                mov nImageWidth, eax
                mov eax, bm.bmHeight
                mov nImageHeight, eax
                mov RetVal, TRUE
            .ENDIF
        ;-----------------------------------


        ;-----------------------------------
        ; ICON
        ;-----------------------------------
        .ELSEIF eax == MUIIT_ICO ; icon    
            Invoke GetIconInfo, hImage, Addr iinfo ; get icon information
            mov eax, iinfo.hbmColor ; bitmap info of icon has width/height
            .IF eax != NULL
                Invoke GetObject, iinfo.hbmColor, SIZEOF bm, Addr bm
                .IF eax != 0
                    mov eax, bm.bmWidth
                    mov nImageWidth, eax
                    mov eax, bm.bmHeight
                    mov nImageHeight, eax
                    mov RetVal, TRUE
                .ENDIF
            .ELSE ; Icon has no color plane, image width/height data stored in mask
                mov eax, iinfo.hbmMask
                .IF eax != NULL
                    Invoke GetObject, iinfo.hbmMask, SIZEOF bm, Addr bm
                    .IF eax != 0
                        mov eax, bm.bmWidth
                        mov nImageWidth, eax
                        mov eax, bm.bmHeight
                        shr eax, 1 ;bmp.bmHeight / 2;
                        mov nImageHeight, eax
                        mov RetVal, TRUE
                    .ENDIF
                .ENDIF
            .ENDIF
            ; free up color and mask icons created by the GetIconInfo function
            mov eax, iinfo.hbmColor
            .IF eax != NULL
                Invoke DeleteObject, eax
            .ENDIF
            mov eax, iinfo.hbmMask
            .IF eax != NULL
                Invoke DeleteObject, eax
            .ENDIF
        ;-----------------------------------


        ;-----------------------------------
        ; PNG
        ;-----------------------------------
        .ELSEIF eax == MUIIT_PNG ; png
            IFDEF MUI_USEGDIPLUS
            Invoke GdipGetImageWidth, hImage, Addr nImageWidth
            Invoke GdipGetImageHeight, hImage, Addr nImageHeight
            mov RetVal, TRUE
            ENDIF
        .ENDIF
        ;-----------------------------------

    .ENDIF


    .IF lpdwImageWidth != 0
        mov ebx, lpdwImageWidth
        mov eax, nImageWidth
        mov [ebx], eax
    .ENDIF
    .IF lpdwImageHeight != 0
        mov ebx, lpdwImageHeight
        mov eax, nImageHeight
        mov [ebx], eax
    .ENDIF
    mov eax, RetVal
    ret
MUIGetImageSize ENDP


MODERNUI_LIBEND



