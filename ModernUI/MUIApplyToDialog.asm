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
includelib user32.lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Applies the ModernUI style to a dialog to make it a captionless, borderless 
; form. User can manually change a form in a resource editor to have the 
; following style flags: WS_POPUP or WS_VISIBLE and optionally with 
; DS_CENTER, DS_CENTERMOUSE, WS_CLIPCHILDREN, WS_CLIPSIBLINGS, WS_MINIMIZE, 
; WS_MAXIMIZE
;------------------------------------------------------------------------------
MUIApplyToDialog PROC hWin:MUIWND, bDropShadow:BOOL, bClipping:BOOL
    LOCAL dwStyle:DWORD
    LOCAL dwNewStyle:DWORD
    LOCAL dwClassStyle:DWORD

    mov dwNewStyle, WS_POPUP
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    and eax, DS_CENTER
    .IF eax == DS_CENTER
        or dwNewStyle, DS_CENTER
    .ENDIF
    
    mov eax, dwStyle
    and eax, DS_CENTERMOUSE
    .IF eax == DS_CENTERMOUSE
        or dwNewStyle, DS_CENTERMOUSE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_VISIBLE
    .IF eax == WS_VISIBLE
        or dwNewStyle, WS_VISIBLE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_MINIMIZE
    .IF eax == WS_MINIMIZE
        or dwNewStyle, WS_MINIMIZE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_MAXIMIZE
    .IF eax == WS_MAXIMIZE
        or dwNewStyle, WS_MAXIMIZE
    .ENDIF        

    .IF bClipping == TRUE
        mov eax, dwStyle
        and eax, WS_CLIPSIBLINGS
        .IF eax == WS_CLIPSIBLINGS
            or dwNewStyle, WS_CLIPSIBLINGS
        .ENDIF        
        or dwNewStyle, WS_CLIPCHILDREN
    .ENDIF

    Invoke SetWindowLong, hWin, GWL_STYLE, dwNewStyle
    
    ; Set dropshadow on or off on our dialog
    
    Invoke GetClassLong, hWin, GCL_STYLE
    mov dwClassStyle, eax
    
    .IF bDropShadow == TRUE
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax != CS_DROPSHADOW
            or dwClassStyle, CS_DROPSHADOW
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
        .ENDIF
    .ELSE    
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax == CS_DROPSHADOW
            and dwClassStyle,(-1 xor CS_DROPSHADOW)
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
        .ENDIF
    .ENDIF

    ; remove any menu that might have been assigned via class registration - for modern ui look
    Invoke GetMenu, hWin
    .IF eax != NULL
        Invoke SetMenu, hWin, NULL
    .ENDIF

    Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED

    ret
MUIApplyToDialog ENDP


MODERNUI_LIBEND



