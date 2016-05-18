;======================================================================================================================================
;
; ModernUI Library v1.0.0.0
;
; Copyright (c) 2016 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;
; This software is provided 'as-is', without any express or implied warranty. In no event will the author be held liable for any 
; damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any non-commercial program. If you use the library in an application, an 
; acknowledgement in the application or documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave the original copyright notices intact and not 
; misrepresent the origin of the software. It is not allowed to claim you wrote the original software. Modified files must have a clear 
; notice that the files are modified, and not in the original state. This includes the name of the person(s) who modified the code. 
;
; If you want to distribute or redistribute any portion of this package, you will need to include the full package in it's original 
; state, including this license and all the copyrights. 
;
; While distributing this package (in it's original state) is allowed, it is not allowed to charge anything for this. You may not sell
; or include the package in any commercial package without having permission of the author. Neither is it allowed to redistribute any 
; of the package's components with commercial applications.
;
;======================================================================================================================================



;--------------------------------------------------------------------------------------------------------------------------------------
; PUBLIC ModernUI Prototypes for users of controls
;--------------------------------------------------------------------------------------------------------------------------------------
MUIGetExtProperty                PROTO :DWORD, :DWORD                   ; hControl, dwProperty
MUISetExtProperty                PROTO :DWORD, :DWORD, :DWORD           ; hControl, dwProperty, dwPropertyValue
_MUIGetIntProperty               PROTO :DWORD, :DWORD                   ; hControl, dwProperty
_MUISetIntProperty               PROTO :DWORD, :DWORD, :DWORD           ; hControl, dwProperty, dwPropertyValue


;--------------------------------------------------------------------------------------------------------------------------------------
; PRIVATE ModernUI Prototypes for control creators to use with their controls
;--------------------------------------------------------------------------------------------------------------------------------------
_MUIGDIPlusStart                 PROTO                                  ; Wrapper for GDIPlus startup
_MUIGDIPlusFinish                PROTO                                  ; Wrapper for GDIPlus shutdown

_MUIAllocMemProperties           PROTO :DWORD, :DWORD, :DWORD           ; hControl, cbWndExtraOffset, dwSizeToAllocate
_MUIFreeMemProperties            PROTO :DWORD, :DWORD                   ; hControl, cbWndExtraOffset


;--------------------------------------------------------------------------------------------------------------------------------------
; LTLI ModernUI Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; LTLI ModernUI Constants
;--------------------------------------------------------------------------------------------------------------------------------------

; ModernUI Custom Messages - each control should handle these
MUI_GETPROPERTY                 EQU WM_USER + 1800                      ; wParam = dwProperty, lParam = NULL
MUI_SETPROPERTY                 EQU WM_USER + 1799                      ; wParam = dwProperty, lParam = dwPropertyValue
;MUI_GETTHEME                    EQU WM_USER + 1798                      ; wParam = NULL, lParam = NULL. Returns in eax lpMUITHEMEStructure
;MUI_SETTHEME                    EQU WM_USER + 1797                      ; wParam = lpMUITHEMEStructure, lParam = NULL








; ModernUI Alpha Red Green Blue Macro
MUI_ARGBCOLOR MACRO alpha, red, green, blue
    EXITM < alpha SHL 24 OR red SHL 16 OR green SHL 8 OR blue >
ENDM

; ModernUI Red Green Blue Macro
MUI_RGBCOLOR macro r:REQ,g:REQ,b:REQ
    exitm <( ( ( ( r )  or  ( ( ( g ) )  shl  8 ) )  or  ( ( ( b ) )  shl  16 ) ) ) >
ENDM
























