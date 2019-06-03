;==============================================================================
;
; ModernUI Library v0.0.0.5
;
; Copyright (c) 2019 by fearless
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

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include comctl32.inc
include masm32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib masm32.lib

MUI_UNICODE EQU 1 ; for wide text
MUI_DONTUSEGDIPLUS EQU 1 ; exclude (gdiplus) support
MODERNUI_DLL EQU 1

; ModernUI Library Source:
Include .\..\ModernUI\ModernUI.inc
Include .\..\ModernUI\_ModernUI_Base.asm
Include .\..\ModernUI\_ModernUI_GDIDoubleBuffer.asm
Include .\..\ModernUI\_ModernUI_GDIPlus.asm
Include .\..\ModernUI\_ModernUI_Memory.asm
Include .\..\ModernUI\ModernUI_DPI.asm
Include .\..\ModernUI\MUIAllocStructureMemory.asm
Include .\..\ModernUI\MUIApplyToDialog.asm
Include .\..\ModernUI\MUICenterWindow.asm
Include .\..\ModernUI\MUICreateBitmapFromMemory.asm
Include .\..\ModernUI\MUICreateCursorFromMemory.asm
Include .\..\ModernUI\MUICreateIconFromMemory.asm
Include .\..\ModernUI\MUIGDIBlend.asm
Include .\..\ModernUI\MUIGDIBlendBitmaps.asm
Include .\..\ModernUI\MUIGDIStretchBitmap.asm
Include .\..\ModernUI\MUIGDIStretchImage.asm
Include .\..\ModernUI\MUIGetImageSize.asm
Include .\..\ModernUI\MUIGetImageSizeEx.asm
Include .\..\ModernUI\MUIGetParentBackgroundBitmap.asm
Include .\..\ModernUI\MUIGetParentBackgroundColor.asm
Include .\..\ModernUI\MUIGetParentRelativeWindowRect.asm
Include .\..\ModernUI\MUILoadBitmapFromResource.asm
Include .\..\ModernUI\MUILoadIconFromResource.asm
Include .\..\ModernUI\MUILoadImageFromResource.asm
Include .\..\ModernUI\MUILoadPngFromResource.asm
Include .\..\ModernUI\MUILoadRegionFromResource.asm
Include .\..\ModernUI\MUIPaintBackground.asm
Include .\..\ModernUI\MUIPaintBackgroundImage.asm
Include .\..\ModernUI\MUIPointSizeToLogicalUnit.asm
Include .\..\ModernUI\MUISetRegionFromResource.asm

; ModernUI Controls:
Include .\..\Controls\ModernUI_Button\ModernUI_Button.asm
Include .\..\Controls\ModernUI_CaptionBar\ModernUI_CaptionBar.asm
Include .\..\Controls\ModernUI_Checkbox\ModernUI_Checkbox.asm
Include .\..\Controls\ModernUI_ProgressBar\ModernUI_ProgressBar.asm
Include .\..\Controls\ModernUI_ProgressDots\ModernUI_ProgressDots.asm
Include .\..\Controls\ModernUI_SmartPanel\ModernUI_SmartPanel.asm
Include .\..\Controls\ModernUI_Text\ModernUI_Text.asm
Include .\..\Controls\ModernUI_Tooltip\ModernUI_Tooltip.asm
Include .\..\Controls\ModernUI_TrayMenu\ModernUI_TrayMenu.asm

.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllEntry PROC hInst:HINSTANCE, reason:DWORD, reserved:DWORD
    .IF reason == DLL_PROCESS_ATTACH
        Invoke MUIButtonRegister
        Invoke MUICaptionBarRegister
        Invoke MUICheckboxRegister
        Invoke MUIProgressBarRegister
        Invoke MUIProgressDotsRegister
        Invoke MUISmartPanelRegister
        Invoke MUITextRegister
        Invoke MUITooltipRegister
        Invoke MUITrayMenuRegister        
    .ENDIF
    mov eax,TRUE
    ret
DllEntry ENDP

END DllEntry


