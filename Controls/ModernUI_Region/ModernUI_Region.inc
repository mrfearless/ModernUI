;==============================================================================
;
; ModernUI Control - ModernUI_Region
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
; ModernUI_Region Prototypes
;------------------------------------------------------------------------------
MUIRegionButtonRegister     PROTO                                                                   ; Use 'ModernUI_RegionButton' as class in RadASM custom class control
MUIRegionButtonCreate       PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD                    ; hWndParent, lpszText, xpos, ypos, dwResourceID, dwStyle
MUIRegionButtonSetProperty  PROTO :DWORD, :DWORD, :DWORD                                            ; hRegionButton, dwProperty, dwPropertyValue
MUIRegionButtonGetProperty  PROTO :DWORD, :DWORD                                                    ; hRegionButton, dwProperty
MUIRegionButtonSetRegion    PROTO :DWORD, :DWORD, :DWORD                                            ; hRegionButton, ptrRegionData, dwRegionDataSize
MUIRegionButtonSetBitmap    PROTO :DWORD, :DWORD                                                    ; hRegionButton, hBitmap
MUIRegionButtonGetState     PROTO :DWORD                                                            ; hRegionButton
MUIRegionButtonSetState     PROTO :DWORD, :DWORD                                                    ; hRegionButton, bState


;------------------------------------------------------------------------------
; ModernUI_RegionButton Structures
;------------------------------------------------------------------------------
IFNDEF MUI_REGIONBUTTON_PROPERTIES
MUI_REGIONBUTTON_PROPERTIES             STRUCT
    dwBackColor                         DD ? 
    dwBackColorAlt                      DD ? 
    dwBackColorSel                      DD ? 
    dwBackColorSelAlt                   DD ? 
    dwBackColorDisabled                 DD ?
    dwBorderColor                       DD ? 
    dwBorderColorAlt                    DD ? 
    dwBorderColorSel                    DD ? 
    dwBorderColorSelAlt                 DD ? 
    dwBorderColorDisabled               DD ? 
    dwBorderStyle                       DD ?
    dwUserData                          DD ?
MUI_REGIONBUTTON_PROPERTIES             ENDS
ENDIF

IFNDEF MUIRB_NOTIFY                      ; Notification Message Structure for RegionButton
MUIRB_NOTIFY                            STRUCT
    hdr                                 NMHDR <0,0,0>
    lParam                              DD 0
MUIRB_NOTIFY                            ENDS
ENDIF


.CONST
;------------------------------------------------------------------------------
; ModernUI_RegionButton Constants
;------------------------------------------------------------------------------
MUIRB_GETSTATE                  EQU WM_USER + 1798 ; wParam = NULL, lParam = NULL. EAX = dwState.
MUIRB_SETSTATE                  EQU WM_USER + 1797 ; wParam = TRUE/FALSE, lParam = NULL.
MUIRB_SETREGION                 EQU WM_USER + 1796 ; wParam = ptrRegionData, lParam = dwRegionDataSize
MUIRB_SETBITMAP                 EQU WM_USER + 1795 ; wParam = hBitmap, lParam = NULL.

; ModernUI_RegionButton Styles
MUIRB_HAND                      EQU 2h  ; Show a hand instead of an arrow when mouse moves over button.
MUIRB_MOVE                      EQU 4h
MUIRB_PUSHBUTTON                EQU 8h
MUIRB_MOUSEMOVEPARENT           EQU 10h ; Notify parent of mousemove

; ModernUI_RegionButton Notify Codes:
MUIRBN_CLICKED                  EQU 1
MUIRBN_MOUSEOVER                EQU 2
MUIRBN_MOUSELEAVE               EQU 3
MUIRBN_SELECTED                 EQU 4
MUIRBN_UNSELECTED               EQU 5
MUIRBN_ENABLED                  EQU 6
MUIRBN_DISABLED                 EQU 7


;------------------------------------------------------------------------------
; ModernUI_RegionButton Properties: Use with MUIRegionSetProperty / MUIRegionGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@RegionButtonBackColor          EQU 0      ; Colorref. Back color.
@RegionButtonBackColorAlt       EQU 4      ; Colorref. Back color when mouse hovers over control.
@RegionButtonBackColorSel       EQU 8      ; Colorref. Back color when selected state = TRUE.
@RegionButtonBackColorSelAlt    EQU 12     ; Colorref. Back color when selected state = TRUE and mouse hovers over control.
@RegionButtonBackColorDisabled  EQU 16     ; Colorref. Back color when control is disabled.
@RegionButtonBorderColor        EQU 20     ; Colorref. Border color.
@RegionButtonBorderColorAlt     EQU 24     ; Colorref. Border color when mouse hovers over control.
@RegionButtonBorderColorSel     EQU 28     ; Colorref. Border color when selected state = TRUE.
@RegionButtonBorderColorSelAlt  EQU 32     ; Colorref. Border color when selected state = TRUE and mouse hovers over control.
@RegionButtonBorderColorDisabled EQU 36    ; Colorref. Border color when control is disabled.
@RegionButtonBorderSize         EQU 40     ; RegionButton Border size, 0 = disabled/no border (default)
@RegionButtonUserData           EQU 44     ; User defined dword data











