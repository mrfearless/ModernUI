;======================================================================================================================================
;
; ModernUI Control - ModernUI_ProgressBar v1.0.0.0
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
; ModernUI_ProgressBar Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUIProgressBarRegister		PROTO																	; Use 'ModernUI_ProgressBar' as class in RadASM custom class control
MUIProgressBarCreate		PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD        	; hWndParent, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIProgressBarSetProperty	PROTO :DWORD, :DWORD, :DWORD											; hModernUI_ProgressBar, dwProperty, dwPropertyValue
MUIProgressBarGetProperty	PROTO :DWORD, :DWORD													; hModernUI_ProgressBar, dwProperty
MUIProgressBarSetMinMax     PROTO :DWORD, :DWORD, :DWORD
MUIProgressBarSetPercent    PROTO :DWORD, :DWORD
MUIProgressBarGetPercent    PROTO :DWORD
MUIProgressBarStep          PROTO :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_ProgressBar Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_ProgressBar Constants
;--------------------------------------------------------------------------------------------------------------------------------------

MUIPBM_STEP                 EQU WM_USER + 1750
MUIPBM_SETPERCENT           EQU WM_USER + 1749


; ModernUI_ProgressBar Styles


;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_ProgressBar Properties: Use with MUIProgressBarSetProperty / MUIProgressBarGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@ProgressBarTextColor        EQU 0   ; Text color for caption text and system buttons (min/max/restore/close)
@ProgressBarTextFont	     EQU 4   ; Font for caption text
@ProgressBarBackColor        EQU 8   ; Background color of caption and system buttons
@ProgressBarProgressColor    EQU 12  ;
@ProgressBarBorderColor      EQU 16  ;
@ProgressBarPercent          EQU 20  ; 
@ProgressBarMin              EQU 24  ;
@ProgressBarMax              EQU 28  ;
@ProgressBarStep             EQU 32  ;








