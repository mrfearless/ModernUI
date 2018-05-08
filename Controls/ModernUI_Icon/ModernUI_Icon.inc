;======================================================================================================================================
;
; ModernUI Control - ModernUI_Icon v1.0.0.0
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
; ModernUI_Icon Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUIIconRegister		PROTO																	; Use 'ModernUI_Icon' as class in RadASM custom class control
MUIIconCreate		PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD	        ; hWndParent, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIIconSetProperty	PROTO :DWORD, :DWORD, :DWORD											; hModernUI_Icon, dwProperty, dwPropertyValue
MUIIconGetProperty	PROTO :DWORD, :DWORD													; hModernUI_Icon, dwProperty
MUIIconSetRegion    PROTO :DWORD, :DWORD                                                    ; hModernUI_Icon, idRgnRes

MUIIconGetState     PROTO :DWORD                                                            ; hModernUI_Icon
MUIIconSetState     PROTO :DWORD, :DWORD                                                    ; hModernUI_Icon, bState

MUIIconSetIcons     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD                    ; hModernUI_Icon, hIcon, hIconAlt, hIconSel, hIconSelAlt, hIconDisabled

;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Icon Structures
;--------------------------------------------------------------------------------------------------------------------------------------


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Icon Constants
;--------------------------------------------------------------------------------------------------------------------------------------
MUIIM_SETREGION                 EQU WM_USER + 1796 ; wParam = ptrRegionData, lParam = dwRegionDataSize
MUIIM_GETSTATE                  EQU WM_USER + 1779 ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
MUIIM_SETSTATE                  EQU WM_USER + 1778 ; wParam = TRUE/FALSE, lParam = NULL

; ModernUI_Icon Styles
MUIIS_PUSHBUTTON                EQU 10h     ; Simulate button movement down slightly when mouse click and movement up again when mouse is released.
MUIIS_HAND                      EQU 20h     ; Show a hand instead of an arrow when mouse moves over icon.
MUIIS_KEEPIMAGES                EQU 40h     ; Dont delete icon handles when control is destoyed. Essential if icon handles are used in multiple controls.


;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_Icon Properties: Use with MUIIconSetProperty / MUIMIconGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@IconBackColor          EQU 0   ; Background color of icon, -1 is transparent
@IconUnselected         EQU 4   ; hIcon
@IconUnselectedAlt      EQU 8   ; hIcon
@IconSelected           EQU 12  ; hIcon
@IconSelectedAlt        EQU 16  ; hIcon
@IconDisabled           EQU 20  ; hIcon











