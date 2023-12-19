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
includelib user32.lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Modifies the extended window styles of a Window to add and/or remove styles
; if bFrameChanged is TRUE then forces SWP_FRAMECHANGED call via SetWindowPos
;------------------------------------------------------------------------------
MUIModifyStyleExA PROC USES EBX hWin:MUIWND, dwRemove:MUIVALUE, dwAdd:MUIVALUE, bFrameChanged:BOOL
    Invoke GetWindowLongA, hWin, GWL_EXSTYLE
    ; eax has current extended style
    
    ; Add dwAdd styles to current extended style with OR
    mov ebx, dwAdd
    or eax, ebx
    
    ; Remove dwRemove styles from current extended style with NOT (to invert dwRemove) and then AND together
    mov ebx, dwRemove
    not ebx
    and eax, ebx
    ; eax has new style
    
    Invoke SetWindowLongA, hWin, GWL_EXSTYLE, eax
    
    .IF bFrameChanged == FALSE
        ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE
    .ELSE
        ; Applies new extended styles set using the SetWindowLong function
        Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED
    .ENDIF

    xor eax, eax
    ret
MUIModifyStyleExA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Modifies the extended window styles of a Window to add and/or remove styles
; if bFrameChanged is TRUE then forces SWP_FRAMECHANGED call via SetWindowPos
;------------------------------------------------------------------------------
MUIModifyStyleExW PROC USES EBX hWin:MUIWND, dwRemove:MUIVALUE, dwAdd:MUIVALUE, bFrameChanged:BOOL
    Invoke GetWindowLongW, hWin, GWL_EXSTYLE
    ; eax has current extended style
    
    ; Add dwAdd styles to current extended style with OR
    mov ebx, dwAdd
    or eax, ebx
    
    ; Remove dwRemove styles from current extended style with NOT (to invert dwRemove) and then AND together
    mov ebx, dwRemove
    not ebx
    and eax, ebx
    ; eax has new style
    
    Invoke SetWindowLongW, hWin, GWL_EXSTYLE, eax
    
    .IF bFrameChanged == FALSE
        ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE
    .ELSE
        ; Applies new extended styles set using the SetWindowLong function
        Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED
    .ENDIF

    xor eax, eax
    ret
MUIModifyStyleExW ENDP


MODERNUI_LIBEND



