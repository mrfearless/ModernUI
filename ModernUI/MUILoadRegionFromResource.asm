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
include kernel32.inc
includelib kernel32.lib


include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; MUILoadRegionFromResource - Loads region from a resource
;------------------------------------------------------------------------------
MUILoadRegionFromResource PROC USES EBX hInst:HINSTANCE, idRgnRes:RESID, lpRegionData:POINTER, lpSizeRegionData:LPMUIVALUE
    LOCAL hRes:DWORD
    ; Load region
    Invoke FindResource, hInst, idRgnRes, RT_RCDATA ; load rng image as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInst, hRes
        .IF eax != 0
            .IF lpSizeRegionData != NULL
                mov ebx, lpSizeRegionData
                mov [ebx], eax
            .ELSE
                mov eax, FALSE
                ret
            .ENDIF
            Invoke LoadResource, hInst, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    .IF lpRegionData != NULL
                        mov ebx, lpRegionData
                        mov [ebx], eax
                        mov eax, TRUE
                    .ELSE
                        mov eax, FALSE
                    .ENDIF
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, FALSE
    .ENDIF    
    ret
MUILoadRegionFromResource ENDP


MODERNUI_LIBEND



