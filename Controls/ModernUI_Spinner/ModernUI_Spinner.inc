;==============================================================================
;
; ModernUI Control - ModernUI_Spinner
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
; ModernUI_Spinner Prototypes
;------------------------------------------------------------------------------
MUISpinnerRegister		    PROTO								                    ; Use 'ModernUI_Spinner' as class in RadASM custom class control
MUISpinnerCreate		    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hWndParent, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUISpinnerSetProperty	    PROTO :DWORD,:DWORD,:DWORD						        ; hModernUI_Spinner, dwProperty, dwPropertyValue
MUISpinnerGetProperty	    PROTO :DWORD,:DWORD					                    ; hModernUI_Spinner, dwProperty

; Add image handle (bitmap, icon or png) as a spinner frame image
MUISpinnerAddFrame          PROTO :DWORD,:DWORD,:DWORD						        ; hModernUI_Spinner, dwImageType, hImage
MUISpinnerAddFrames         PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_Spinner, dwCount, dwImageType, lpArrayImageHandles
; Load an image resource id (bitmap, icon or png) as a spinner frame image
MUISpinnerLoadFrame         PROTO :DWORD,:DWORD,:DWORD						        ; hModernUI_Spinner, dwImageType, idResImage
MUISpinnerLoadFrames        PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_Spinner, dwCount, dwImageType, lpArrayResourceIDs
; Create a series of spinner frame images from an individual png handle/resid
MUISpinnerAddImage          PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_Spinner, hImage, dwNoFramesToCreate, bReverse
MUISpinnerLoadImage         PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_Spinner, idResImage, dwNoFramesToCreate, bReverse
; Create a series of spinner frame images from a sprite sheet
MUISpinnerAddSpriteSheet    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hModernUI_Spinner, dwSpriteCount, dwImageType, hImageSpriteSheet, bReverse
MUISpinnerLoadSpriteSheet   PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hModernUI_Spinner, dwSpriteCount, dwImageType, idResSpriteSheet, bReverse

; Spinner animation control
MUISpinnerEnable            PROTO :DWORD                                            ; hModernUI_Spinner
MUISpinnerDisable           PROTO :DWORD                                            ; hModernUI_Spinner
MUISpinnerReset             PROTO :DWORD                                            ; hModernUI_Spinner
MUISpinnerPause             PROTO :DWORD                                            ; hModernUI_Spinner
MUISpinnerResume            PROTO :DWORD                                            ; hModernUI_Spinner
MUISpinnerSpeed             PROTO :DWORD,:DWORD                                     ; hModernUI_Spinner, dwMillisecSpeed


;------------------------------------------------------------------------------
; ModernUI_Spinner Messages
;------------------------------------------------------------------------------
MUISPNM_ADDFRAME            EQU WM_USER+1752 ; wParam = dwImageType, lParam = hImage
MUISPNM_LOADFRAME           EQU WM_USER+1751 ; wParam = dwImageType, lParam = idResImage
MUISPNM_ENABLE              EQU WM_USER+1750 ; wParam & lParam = NULL
MUISPNM_DISABLE             EQU WM_USER+1749 ; wParam & lParam = NULL
MUISPNM_RESET               EQU WM_USER+1748 ; wParam & lParam = NULL
MUISPNM_PAUSE               EQU WM_USER+1747 ; wParam & lParam = NULL
MUISPNM_RESUME              EQU WM_USER+1746 ; wParam & lParam = NULL
MUISPNM_SPEED               EQU WM_USER+1745 ; wParam = dwMillisecSpeed

.CONST
;------------------------------------------------------------------------------
; ModernUI_Spinner Constants
;------------------------------------------------------------------------------

; ModernUI_Spinner Styles
MUISPNS_HAND                EQU 20h     ; Show a hand instead of an arrow when mouse moves over spinner.

;------------------------------------------------------------------------------
; ModernUI_Spinner Properties: Use with MUISpinnerSetProperty / 
; MUISpinnerGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@SpinnerBackColor           EQU 0   ; Background color of spinner
@SpinnerSpeed               EQU 4   ; milliseconds until next spin stage or rotation occurs
@SpinnerDllInstance         EQU 8

; Spinner Image Type:
MUISPIT_NONE                EQU 0
MUISPIT_BMP                 EQU 1
MUISPIT_ICO                 EQU 2
MUISPIT_PNG                 EQU 3





