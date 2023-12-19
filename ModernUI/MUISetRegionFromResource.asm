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


EXTERNDEF MUILoadRegionFromResource :PROTO hInst:HINSTANCE, idRgnRes:RESID, lpRegionData:POINTER, lpSizeRegionData:LPMUIVALUE


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets a window/controls region from a region stored as an RC_DATA resource: 
; idRgnRes if lpCopyRgnHandle != NULL a copy of region handle is provided (for any
; future calls to FrameRgn for example)
;------------------------------------------------------------------------------
MUISetRegionFromResource PROC USES EBX hWin:MUIWND, idRgnRes:RESID, lpCopyRgnHandle:LPMUIVALUE, bRedraw:BOOL
    LOCAL hinstance:DWORD
    LOCAL ptrRegionData:DWORD
    LOCAL dwRegionDataSize:DWORD
    LOCAL hRgn:DWORD
    
    .IF idRgnRes == NULL
        Invoke SetWindowRgn, hWin, NULL, FALSE
        ret
    .ENDIF
 
    Invoke GetModuleHandle, NULL
    mov hinstance, eax
    
    Invoke MUILoadRegionFromResource, hinstance, idRgnRes, Addr ptrRegionData, Addr dwRegionDataSize
    .IF eax == FALSE
        .IF lpCopyRgnHandle != NULL
            mov eax, NULL
            mov ebx, lpCopyRgnHandle
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE    
        ret
    .ENDIF
    
    Invoke SetWindowRgn, hWin, NULL, FALSE
    Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
    mov hRgn, eax
    .IF eax == NULL
        .IF lpCopyRgnHandle != NULL
            mov eax, NULL
            mov ebx, lpCopyRgnHandle
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE
        ret
    .ENDIF
    Invoke SetWindowRgn, hWin, hRgn, bRedraw
    
    .IF lpCopyRgnHandle != NULL
        Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
        mov hRgn, eax
        mov ebx, lpCopyRgnHandle
        mov [ebx], eax
    .ENDIF

    mov eax, TRUE    
    ret
MUISetRegionFromResource ENDP


MODERNUI_LIBEND



