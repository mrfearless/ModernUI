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
; Sets a window/controls region from a region stored as an RC_DATA resource: 
; idRgnRes if lpdwCopyRgn != NULL a copy of region handle is provided (for any
; future calls to FrameRgn for example)
;------------------------------------------------------------------------------
MUISetRegionFromResource PROC USES EBX hWin:DWORD, idRgnRes:DWORD, lpdwCopyRgn:DWORD, bRedraw:DWORD
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
        .IF lpdwCopyRgn != NULL
            mov eax, NULL
            mov ebx, lpdwCopyRgn
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE    
        ret
    .ENDIF
    
    Invoke SetWindowRgn, hWin, NULL, FALSE
    Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
    mov hRgn, eax
    .IF eax == NULL
        .IF lpdwCopyRgn != NULL
            mov eax, NULL
            mov ebx, lpdwCopyRgn
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE
        ret
    .ENDIF
    Invoke SetWindowRgn, hWin, hRgn, bRedraw
    
    .IF lpdwCopyRgn != NULL
        Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
        mov hRgn, eax
        mov ebx, lpdwCopyRgn
        mov [ebx], eax
    .ENDIF

    mov eax, TRUE    
    ret
MUISetRegionFromResource ENDP


END



