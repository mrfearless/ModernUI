;==============================================================================
;
; ModernUI Control - ModernUI_ProgressBar
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
; ModernUI_ProgressBar Prototypes
;------------------------------------------------------------------------------
MUIProgressBarRegister      PROTO                                                   ; Use 'ModernUI_ProgressBar' as class in RadASM custom class control
MUIProgressBarCreate        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hWndParent, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIProgressBarSetProperty   PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_ProgressBar, dwProperty, dwPropertyValue
MUIProgressBarGetProperty   PROTO :DWORD,:DWORD                                     ; hModernUI_ProgressBar, dwProperty

MUIProgressBarSetMinMax     PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_ProgressBar, dwMin, dwMax
MUIProgressBarSetPercent    PROTO :DWORD,:DWORD                                     ; hModernUI_ProgressBar, dwPercent
MUIProgressBarGetPercent    PROTO :DWORD                                            ; hModernUI_ProgressBar
MUIProgressBarStep          PROTO :DWORD                                            ; hModernUI_ProgressBar


.CONST
;------------------------------------------------------------------------------
; ModernUI_ProgressBar Messages
;------------------------------------------------------------------------------
MUIPBM_STEP                 EQU WM_USER + 1750
MUIPBM_SETPERCENT           EQU WM_USER + 1749


;------------------------------------------------------------------------------
; ModernUI_ProgressBar Styles
;------------------------------------------------------------------------------
MUIPBS_PULSE                EQU 0   ; Show pulse hearbeat on progress (default)
MUIPBS_NOPULSE              EQU 1   ; Dont show pulse heartbeat on progress
MUIPBS_TEXT_NONE            EQU 0   ; Dont show % text (default)
MUIPBS_TEXT_CENTRE          EQU 2   ; Show % text in centre of progress control
MUIPBS_TEXT_FOLLOW          EQU 4   ; Show % text and follow progress bar 
MUIPBS_R2G                  EQU 8   ; Show a fading red to green progress bar

;------------------------------------------------------------------------------
; ModernUI_ProgressBar Properties: Use with MUIProgressBarSetProperty / 
; MUIProgressBarGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@ProgressBarTextColor       EQU 0   ; RGBCOLOR. Text color
@ProgressBarTextFont        EQU 4   ; HFONT. Font
@ProgressBarBackColor       EQU 8   ; RGBCOLOR. Background color
@ProgressBarProgressColor   EQU 12  ; RGBCOLOR. Progress bar color
@ProgressBarBorderColor     EQU 16  ; RGBCOLOR. Border color
@ProgressBarPercent         EQU 20  ; DWORD. Current percent - get or set
@ProgressBarMin             EQU 24  ; DWORD. Set min value (not used currently)
@ProgressBarMax             EQU 28  ; DWORD. Set max value (not used currently)
@ProgressBarStep            EQU 32  ; DWORD. Amount to step by (default 1) (not used currently)
@ProgressBarPulse           EQU 36  ; BOOL. Use pulse glow on bar. (default TRUE)
@ProgressBarPulseTime       EQU 40  ; DWORD. Milliseconds until pulse (default 3000ms)
@ProgressBarTextType        EQU 44  ; DWORD. (Default 0) dont show. 1=show centre, 2=follow progress
@ProgressBarSetTextPos      EQU 48  ; DWORD. (Default 0) 0 = preppend WM_SETTEXT text, 1 = append WM_SETTEXT text (not used currently)

; ProgressBar Text Type:
MUIPBTT_NONE                EQU 0   ; No percentage text in progress bar (default)
MUIPBTT_CENTRE              EQU 1   ; Percentage text in center of progress bar
MUIPBTT_FOLLOW              EQU 2   ; Percentage text follows progress as it draws








