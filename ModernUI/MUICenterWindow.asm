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
includelib user32.lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Center child window hWndChild into parent window or desktop if hWndParent is 
; NULL. Parent doesnt need to be the owner.
; No returned value
;------------------------------------------------------------------------------
MUICenterWindow PROC hWndChild:DWORD, hWndParent:DWORD
    LOCAL rectChild:RECT         ; Child window coordonate
    LOCAL rectParent:RECT        ; Parent window coordonate
    LOCAL rectDesktop:RECT       ; Desktop coordonate (WORKAREA)
    LOCAL dwChildLeft:DWORD      ;
    LOCAL dwChildTop:DWORD       ; Child window new coordonate
    LOCAL dwChildWidth:DWORD     ; used by MoveWindow
    LOCAL dwChildHeight:DWORD    ;
    LOCAL bParentMinimized:DWORD ; Is parent window minimized
    LOCAL bParentVisible:DWORD   ; Is parent window visible

    Invoke IsIconic, hWndParent
    mov bParentMinimized, eax
    
    Invoke IsWindowVisible, hWndParent
    mov bParentVisible, eax

    Invoke GetWindowRect, hWndChild, addr rectChild
    .IF eax != 0    ; 0 = no centering possible

        Invoke SystemParametersInfo, SPI_GETWORKAREA, NULL, addr rectDesktop, NULL
        .IF eax != 0    ; 0 = no centering possible
            
            .IF bParentMinimized == FALSE || bParentVisible == FALSE || hWndParent == NULL ; use desktop space
                mov eax, rectDesktop.left
                mov rectParent.left, eax
                mov eax, rectDesktop.top
                mov rectParent.top, eax
                mov eax, rectDesktop.right
                mov rectParent.right, eax
                mov eax, rectDesktop.bottom
                mov rectParent.bottom, eax
            .ELSE
                Invoke GetWindowRect, hWndParent, addr rectParent
                .IF eax == 0    ; 0 = we take the desktop as parent (invalid or NULL hWndParent)
                    mov eax, rectDesktop.left
                    mov rectParent.left, eax
                    mov eax, rectDesktop.top
                    mov rectParent.top, eax
                    mov eax, rectDesktop.right
                    mov rectParent.right, eax
                    mov eax, rectDesktop.bottom
                    mov rectParent.bottom, eax
                .ENDIF
            .ENDIF
            ;
            ; Get new coordonate and make sure the child window
            ; is not moved outside the desktop workarea
            ;
            mov eax, rectChild.right                   ; width = right - left
            sub eax, rectChild.left
            mov dwChildWidth, eax
            mov eax, rectParent.right
            sub eax, rectParent.left
            sub eax, dwChildWidth                      ; eax = Parent width - Child width...
            sar eax, 1                                 ; divided by 2
            add eax, rectParent.left                   ; eax = temporary left coord (need validation)
            .IF sdword ptr eax < rectDesktop.left
                mov eax, rectDesktop.left
            .ENDIF
            mov dwChildLeft, eax
            add eax, dwChildWidth                      ; eax = new left coord + child width
            .IF sdword ptr eax > rectDesktop.right     ; if child right outside desktop workarea
                mov eax, rectDesktop.right
                sub eax, dwChildWidth                  ; right = desktop right - child width
                mov dwChildLeft, eax                   ;
            .ENDIF

            mov eax, rectChild.bottom                  ; height = bottom - top
            sub eax, rectChild.top
            mov dwChildHeight, eax
            mov eax, rectParent.bottom
            sub eax, rectParent.top
            sub eax, dwChildHeight                     ; eax = Parent height - Child height...
            sar eax, 1
            add eax, rectParent.top
            .IF sdword ptr eax < rectDesktop.top       ; eax (child top) must not be smaller, if so...
                mov eax, rectDesktop.top               ; child top = Desktop.top
            .ENDIF
            mov dwChildTop, eax
            add eax, dwChildHeight                     ; eax = new top coord + child height
            .IF sdword ptr eax > rectDesktop.bottom
                mov eax, rectDesktop.bottom            ; child is outside desktop bottom
                sub eax, dwChildHeight                 ; child top = Desktop.bottom - child height
                mov dwChildTop, eax                    ;
           .ENDIF
           ;
           ; Now we have the new coordonate - the dialog window can be moved
           ;
           Invoke MoveWindow, hWndChild, dwChildLeft, dwChildTop, dwChildWidth, dwChildHeight, TRUE
        .ENDIF
    .ENDIF
    xor eax, eax
    ret
MUICenterWindow ENDP


END



