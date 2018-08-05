;======================================================================================================================================
;
; ModernUI Library x86
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
;
; ModernUI_Controls.inc - file for ease of adding ModernUI to your project - Place in \Masm32\Include folder
;
;======================================================================================================================================

; ModernUI x86 Library:
include ModernUI.inc
includelib ModernUI.lib

; ModernUI Controls:
include ModernUI_Button.inc
includelib ModernUI_Button.lib
include ModernUI_CaptionBar.inc
includelib ModernUI_CaptionBar.lib
include ModernUI_Checkbox.inc
includelib ModernUI_Checkbox.lib
include ModernUI_ProgressBar.inc
includelib ModernUI_ProgressBar.lib
include ModernUI_ProgressDots.inc
includelib ModernUI_ProgressDots.lib
include ModernUI_SmartPanel.inc
includelib ModernUI_SmartPanel.lib
include ModernUI_Text.inc
includelib ModernUI_Text.lib
include ModernUI_Tooltip.inc
includelib ModernUI_Tooltip.lib
include ModernUI_TrayMenu.inc
includelib ModernUI_TrayMenu.lib


MUIRegisterControls PROTO

.CODE

;-----------------------------------------------------------------------------------------
; MUIRegisterControls - Register all ModernUI controls - place at startup of program
;-----------------------------------------------------------------------------------------
MUIRegisterControls PROC
    Invoke MUIButtonRegister
    Invoke MUICaptionBarRegister
    Invoke MUICheckboxRegister
    Invoke MUIProgressBarRegister
    Invoke MUIProgressDotsRegister
    Invoke MUISmartPanelRegister
    Invoke MUITextRegister
    Invoke MUITooltipRegister
    Invoke MUITrayMenuRegister
    ret
MUIRegisterControls ENDP








