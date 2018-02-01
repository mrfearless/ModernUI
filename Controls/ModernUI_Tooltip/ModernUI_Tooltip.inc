;======================================================================================================================================
;
; ModernUI Control - ModernUI_Tooltip v1.0.0.0
;
; Copyright (c) 2018 by fearless
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
; ModernUI_Tooltip Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUITooltipRegister          PROTO                                                                   ; Use 'ModernUI_Tooltip' as class in RadASM custom class control
MUITooltipCreate            PROTO :DWORD, :DWORD, :DWORD, :DWORD                                    ; hWndBuddyControl, lpszText, dwWidth, dwStyle
MUITooltipSetProperty       PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Tooltip, dwProperty, dwPropertyValue
MUITooltipGetProperty       PROTO :DWORD, :DWORD                                                    ; hModernUI_Tooltip, dwProperty

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Tooltip Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Tooltip Constants
;--------------------------------------------------------------------------------------------------------------------------------------
MUITTS_POS_BELOW            EQU 0    ; Position tooltip below control
MUITTS_POS_RIGHT            EQU 1    ; Position tooltip to the right of control
MUITTS_POS_ABOVE            EQU 2    ; Position tooltip above control
MUITTS_POS_LEFT             EQU 4    ; Position tooltip to the left of the control
MUITTS_POS_MOUSE            EQU 8    ; Position tooltip on control at mouse coords

MUITTS_NODROPSHADOW         EQU 16   ; Dont show dropshadow around tooltip - this will affect ALL tooltips
MUITTS_FADEIN               EQU 32   ; fade in tooltip
MUITTS_TIMEOUT              EQU 64   ; Uses @TooltipShowTimeout value (or default time if 0) before autohiding tip

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Tooltip Properties: Use with MUITooltipSetProperty / MUITooltipGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@TooltipFont                EQU 0    ; hFont
@TooltipTextColor           EQU 4    ; Colorref
@TooltipBackColor           EQU 8    ; Colorref
@TooltipBorderColor         EQU 12   ; Colorref
@TooltipShowDelay           EQU 16   ; DWORD milliseconds delay to show tooltip
@TooltipShowTimeout         EQU 24   ; DWORD milliseconds time to keep showing tooltip before hiding it. Requires MUITTS_TIMEOUT style flag
@TooltipInfoTitleText       EQU 28   ; lpszTitleString for title text to display
@TooltipOffsetX             EQU 32   ; DWORD Offset x +/- to set position of tip
@TooltipOffsetY             EQU 36   ; DWORD Offset y +/- to set position of tip








