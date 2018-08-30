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
MUIGetImageSize PROC PRIVATE USES EBX hImage:DWORD, dwImageType:DWORD, lpdwImageWidth:DWORD, lpdwImageHeight:DWORD
    LOCAL bm:BITMAP
    LOCAL iinfo:ICONINFO
    LOCAL nImageWidth:DWORD
    LOCAL nImageHeight:DWORD

    mov eax, dwImageType
    .IF eax == MUIIT_NONE
        mov eax, 0
        mov ebx, lpdwImageWidth
        mov [ebx], eax
        mov ebx, lpdwImageHeight
        mov [ebx], eax    
        mov eax, FALSE
        ret
        
    .ELSEIF eax == MUIIT_BMP ; bitmap/icon
        Invoke RtlZeroMemory, Addr bm, SIZEOF BITMAP
        Invoke GetObject, hImage, SIZEOF bm, Addr bm
        .IF eax != 0
            mov eax, bm.bmWidth
            mov ebx, lpdwImageWidth
            mov [ebx], eax
            mov eax, bm.bmHeight
            mov ebx, lpdwImageHeight
            mov [ebx], eax
        .ELSE
            mov eax, 0
            mov ebx, lpdwImageWidth
            mov [ebx], eax
            mov eax, 0
            mov ebx, lpdwImageHeight
            mov [ebx], eax
        .ENDIF
    
    .ELSEIF eax == MUIIT_ICO ; icon    
        Invoke GetIconInfo, hImage, Addr iinfo ; get icon information
        mov eax, iinfo.hbmColor ; bitmap info of icon has width/height
        .IF eax != NULL
            Invoke GetObject, iinfo.hbmColor, SIZEOF bm, Addr bm
            mov eax, bm.bmWidth
            mov ebx, lpdwImageWidth
            mov [ebx], eax
            mov eax, bm.bmHeight
            mov ebx, lpdwImageHeight
            mov [ebx], eax
        .ELSE ; Icon has no color plane, image width/height data stored in mask
            mov eax, iinfo.hbmMask
            .IF eax != NULL
                Invoke GetObject, iinfo.hbmMask, SIZEOF bm, Addr bm
                mov eax, bm.bmWidth
                mov ebx, lpdwImageWidth
                mov [ebx], eax
                mov eax, bm.bmHeight
                shr eax, 1 ;bmp.bmHeight / 2;
                mov ebx, lpdwImageHeight
                mov [ebx], eax                
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
    
    .ELSEIF eax == MUIIT_PNG ; png
        IFDEF MUI_USEGDIPLUS
        Invoke GdipGetImageWidth, hImage, Addr nImageWidth
        Invoke GdipGetImageHeight, hImage, Addr nImageHeight
        mov eax, nImageWidth
        mov ebx, lpdwImageWidth
        mov [ebx], eax
        mov eax, nImageHeight
        mov ebx, lpdwImageHeight
        mov [ebx], eax
        ENDIF
    .ENDIF
    
    mov eax, TRUE
    ret
MUIGetImageSize ENDP


END



