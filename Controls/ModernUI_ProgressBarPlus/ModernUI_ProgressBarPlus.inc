;==============================================================================
;
; ModernUI Control - ModernUI_ProgressBarPlus (GDI+ version)
;
; Copyright (c) 2023 by fearless
;
; All Rights Reserved
;
; http://github.com/mrfearless/ModernUI
;
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
; Permission is granted to anyone to use this software for any non-commercial 
; program. If you use the library in an application, an acknowledgement in the
; application or documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave
; the original copyright notices intact and not misrepresent the origin of the
; software. It is not allowed to claim you wrote the original software. 
; Modified files must have a clear notice that the files are modified, and not
; in the original state. This includes the name of the person(s) who modified 
; the code. 
;
; If you want to distribute or redistribute any portion of this package, you 
; will need to include the full package in it's original state, including this
; license and all the copyrights.  
;
; While distributing this package (in it's original state) is allowed, it is 
; not allowed to charge anything for this. You may not sell or include the 
; package in any commercial package without having permission of the author. 
; Neither is it allowed to redistribute any of the package's components with 
; commercial applications.
;
;==============================================================================

;------------------------------------------------------------------------------
; ModernUI_ProgressBarPlus Prototypes
;------------------------------------------------------------------------------
MUIProgressBarPlusRegister      PROTO                                                   ; Use 'ModernUI_ProgressBarPlus' as class in RadASM custom class control
MUIProgressBarPlusCreate        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hWndParent, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIProgressBarPlusSetProperty   PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_ProgressBarPlus, dwProperty, dwPropertyValue
MUIProgressBarPlusGetProperty   PROTO :DWORD,:DWORD                                     ; hModernUI_ProgressBarPlus, dwProperty

MUIProgressBarPlusSetMinMax     PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_ProgressBarPlus, dwMin, dwMax
MUIProgressBarPlusSetPercent    PROTO :DWORD,:DWORD                                     ; hModernUI_ProgressBarPlus, dwPercent
MUIProgressBarPlusGetPercent    PROTO :DWORD                                            ; hModernUI_ProgressBarPlus
MUIProgressBarPlusStep          PROTO :DWORD                                            ; hModernUI_ProgressBarPlus


.CONST
;------------------------------------------------------------------------------
; ModernUI_ProgressBarPlus Constants
;------------------------------------------------------------------------------

MUIPBPM_STEP                    EQU WM_USER + 1750
MUIPBPM_SETPERCENT              EQU WM_USER + 1749


;------------------------------------------------------------------------------
; ModernUI_ProgressBarPlus Properties: Use with MUIProgressBarPlusSetProperty / 
; MUIProgressBarPlusGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@ProgressBarPlusTextColor       EQU 0   ; ARGBCOLOR. Text color
@ProgressBarPlusTextFont        EQU 4   ; HFONT. Font
@ProgressBarPlusBackColor       EQU 8   ; ARGBCOLOR. Background color
@ProgressBarPlusProgressColor   EQU 12  ; ARGBCOLOR. Progress bar color
@ProgressBarPlusBorderColor     EQU 16  ; ARGBCOLOR. Border color
@ProgressBarPlusPercent         EQU 20  ; DWORD. Current percent - get or set
@ProgressBarPlusMin             EQU 24  ; DWORD. Set min value
@ProgressBarPlusMax             EQU 28  ; DWORD. Set max value
@ProgressBarPlusStep            EQU 32  ; DWORD. Amount to step by (default 1) 
@ProgressBarPlusPulse           EQU 36  ; BOOL. Use pulse glow on bar. (default TRUE)








