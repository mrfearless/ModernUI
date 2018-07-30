;======================================================================================================================================
;
; ModernUI Control - ModernUI_ProgressDots v1.0.0.0
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
; ModernUI_ProgressDots Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUIProgressDotsRegister     PROTO                                                                   ; Use 'ModernUI_ProgressDots' as class in RadASM custom class control
MUIProgressDotsCreate       PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD                            ; hWndParent, ypos, dwHeight, dwResourceID, dwStyle
MUIProgressDotsSetProperty  PROTO :DWORD, :DWORD, :DWORD                                            ; hMUIProgressDots, dwProperty, dwPropertyValue
MUIProgressDotsGetProperty  PROTO :DWORD, :DWORD                                                    ; hMUIProgressDots, dwProperty
MUIProgressDotsAnimateStart PROTO :DWORD                                                            ; hMUIProgressDots
MUIProgressDotsAnimateStop  PROTO :DWORD                                                            ; hMUIProgressDots

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_ProgressDots Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_ProgressDots Constants
;--------------------------------------------------------------------------------------------------------------------------------------

MUIPDM_ANIMATESTART         EQU WM_USER + 1750
MUIPDM_ANIMATESTOP          EQU WM_USER + 1749


;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_ProgressDots Properties: Use with MUIProgressDotsSetProperty / MUIProgressDotsGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@ProgressDotsBackColor        EQU 0   ; Background color of control 
@ProgressDotsDotColor         EQU 4   ; Progress Dots color 
@ProgressDotsShowInterval     EQU 8   ; Interval till dot starts showing, default is 16
@ProgressDotsTimeInterval     EQU 12  ; Milliseconds for timer, defaults to 10, higher will slow down animation of dots
@ProgressDotsSpeed            EQU 16  ; Speed for fast dots (before and after markers), default is 2. For adjusting xpos of dots. Middle portion is always xpos=xpos+1










