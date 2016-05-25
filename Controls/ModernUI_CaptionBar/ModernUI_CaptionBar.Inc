;======================================================================================================================================
;
; ModernUI Control - ModernUI_CaptionBar v1.0.0.0
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
; ModernUI_CaptionBar Prototypes for users of controls
;--------------------------------------------------------------------------------------------------------------------------------------
MUICaptionBarRegister       PROTO                                           ; Use 'ModernUICaptionBar' as class in RadASM custom class control
MUICaptionBarCreate		    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszCaptionText, dwCaptionHeight, dwResourceID, dwStyle
MUICaptionBarSetProperty    PROTO :DWORD, :DWORD, :DWORD                    ; hCaptionBar, dwProperty, dwPropertyValue
MUICaptionBarGetProperty    PROTO :DWORD, :DWORD                            ; hCaptionBar, dwProperty

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Caption Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Caption Constants
;--------------------------------------------------------------------------------------------------------------------------------------

; CaptionBar Styles
MUICS_LEFT                  EQU 0h   ; left align caption bar text
MUICS_CENTER                EQU 1h   ; center align caption bar text
MUICS_NOMINBUTTON           EQU 2h   ; no minimize button
MUICS_NOMAXBUTTON           EQU 4h   ; no maximize/restore button
MUICS_NOCLOSEBUTTON         EQU 8h   ; no close button
MUICS_REDCLOSEBUTTON        EQU 10h  ; close button uses win8+ red background color


;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Caption Properties: Use with MUICaptionBarSetProperty / MUICaptionBarGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@CaptionBarTextColor        EQU 0   ; Text color for caption text and system buttons (min/max/restore/close)
@CaptionBarTextFont	        EQU 4   ; Font for caption text
@CaptionBarBackColor        EQU 8   ; Background color of caption and system buttons
@CaptionBarBtnTxtRollColor  EQU 12  ; Text color for system buttons when mouse moves over them
@CaptionBarBtnBckRollColor  EQU 16  ; Background color for system buttons when mouse moves over them







