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
include user32.inc
includelib user32.lib
includelib Kernel32.Lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Allocs memory for the properties of a control
;------------------------------------------------------------------------------
MUIAllocMemProperties PROC hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, SizeToAllocate:MUIVALUE
    LOCAL pMem:DWORD
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, SizeToAllocate
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov pMem, eax
    
    Invoke SetWindowLong, hWin, cbWndExtraOffset, pMem
    
    mov eax, TRUE
    ret
MUIAllocMemProperties ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Frees memory for the properties of a control
;------------------------------------------------------------------------------
MUIFreeMemProperties PROC hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES
    Invoke GetWindowLong, hWin, cbWndExtraOffset
    .IF eax != NULL
        invoke GlobalFree, eax
        Invoke SetWindowLong, hWin, cbWndExtraOffset, 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret
MUIFreeMemProperties ENDP


MODERNUI_LIBEND



