;======================================================================================================================================
;
; ModernUI Control - ModernUI_DesktopFace v1.0.0.0
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
; ModernUI_DesktopFace Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUIDesktopFaceRegister      PROTO                                   ; Use 'ModernUI_DesktopFace' as class in RadASM custom class control
MUIDesktopFaceCreate		PROTO :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, xpos, ypos, dwStyle
MUIDesktopFaceSetProperty	PROTO :DWORD, :DWORD, :DWORD            ; hModernUI_DesktopFace, dwProperty, dwPropertyValue
MUIDesktopFaceGetProperty	PROTO :DWORD, :DWORD                    ; hModernUI_DesktopFace, dwProperty
MUIDesktopFaceSetImage      PROTO :DWORD, :DWORD, :DWORD            ; hModernUI_DesktopFace, dwImageType, dwImageHandle
MUIDesktopFaceSetRegion     PROTO :DWORD, :DWORD                    ; hModernUI_DesktopFace, idRgnResID
MUIDesktopFaceSetOpacity    PROTO :DWORD, :DWORD                    ; hModernUI_DesktopFace, dwOpacity
MUIDesktopFaceShow          PROTO :DWORD, :DWORD                    ; hModernUI_DesktopFace, bShow


;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_DesktopFace Structures
;--------------------------------------------------------------------------------------------------------------------------------------

IFNDEF MUIDF_NOTIFY         ; Notification Message Structure for ModernUI_DesktopFace
MUIDF_NOTIFY                STRUCT
    hdr                     NMHDR <>
    lParam                  DD ?
MUIDF_NOTIFY                ENDS
ENDIF


.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_DesktopFace Constants
;--------------------------------------------------------------------------------------------------------------------------------------

DFM_SHOWWINDOW              EQU WM_USER + 200 ; wParam = TRUE/FALSE to show, lParam = NULL


; ModernUI_DesktopFace Notify Codes:
MUIDFN_LEFTCLICK            EQU 1   ; Left mouse button click event
MUIDFN_RIGHTCLICK           EQU 2   ; Right mouse button click event
MUIDFN_DOUBLECLICK          EQU 3   ; Double left click mouse event
MUIDFN_KEYPRESS             EQU 4   ; Keypress, lParam contains vKey, return 1 to ignore or 0 to continue default processing
MUIDFN_SHOW                 EQU 5   ; Control is about to show
MUIDFN_HIDE                 EQU 6   ; Control is about to hide
;MUIDFN_MOUSEOVER           EQU 7   ;
;MUIDFN_MOUSELEAVE          EQU 8   ;


; ModernUI_DesktopFace Styles
MUIDFS_POS_AS_SPECIFIED     EQU 0
MUIDFS_POS_VERT_BOTTOM      EQU 1
MUIDFS_POS_VERT_TOP         EQU 2
MUIDFS_POS_VERT_CENTER      EQU 4
MUIDFS_POS_HORZ_LEFT        EQU 8
MUIDFS_POS_HORZ_CENTER      EQU 10h
MUIDFS_POS_HORZ_RIGHT       EQU 20h
MUIDFS_POPIN                EQU 40h
MUIDFS_POPOUT               EQU 80h


;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_DesktopFace Properties: Use with MUIDesktopFaceSetProperty / MUIDesktopFaceGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@DesktopFaceImageType       EQU 0   ; Image Types - One of the following: MUIDFIT_NONE, MUIDFIT_BMP, MUIDFIT_ICO or MUIDFIT_PNG
@DesktopFaceImage           EQU 4   ; Handle of image
@DesktopFaceRegion          EQU 8   ; Resource ID of region to apply to window
@DesktopFaceOpacity         EQU 12  ; opacity
@DesktopFaceFadeStepIn      EQU 16  ; steps to add opacity during fade in - default 8
@DesktopFaceFadeStepOut     EQU 20  ; steps to subtract opacity during fade out - default 16
@DesktopFacePopStepIn       EQU 24  ; steps to add height during pop in - default 8
@DesktopFacePopStepOut      EQU 28  ; steps to substract height during pop out - default 16


; Button Image Types
MUIDFIT_NONE                EQU 0
MUIDFIT_BMP                 EQU 1
MUIDFIT_ICO                 EQU 2
MUIDFIT_PNG                 EQU 3








