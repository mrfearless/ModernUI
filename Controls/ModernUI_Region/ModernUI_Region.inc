;==============================================================================
;
; ModernUI Control - ModernUI_Region
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
; ModernUI_Region Prototypes
;------------------------------------------------------------------------------
MUIRegionButtonRegister         PROTO                                       ; Use 'ModernUI_RegionButton' as class in RadASM custom class control
MUIRegionButtonCreate           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD ; hWndParent, lpszText, xpos, ypos, dwResourceID, dwStyle
MUIRegionButtonSetProperty      PROTO :DWORD, :DWORD, :DWORD                ; hRegionButton, dwProperty, dwPropertyValue
MUIRegionButtonGetProperty      PROTO :DWORD, :DWORD                        ; hRegionButton, dwProperty
MUIRegionButtonSetRegion        PROTO :DWORD, :DWORD, :DWORD                ; hRegionButton, ptrRegionData, dwRegionDataSize
MUIRegionButtonSetRegionPoly    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD ; hRegionButton, ptrPolyData, dwPolyDataCount, dwPolyType, dwXAdjust, dwYAdjust, lpBoundsRect
MUIRegionButtonSetRegionBitmap  PROTO :DWORD, :DWORD                        ; hRegionButton, hBitmap
MUIRegionButtonGetState         PROTO :DWORD                                ; hRegionButton
MUIRegionButtonSetState         PROTO :DWORD, :DWORD                        ; hRegionButton, bState
MUIRegionButtonSetBrush         PROTO :DWORD, :DWORD, :DWORD, :DWORD        ; hRegionButton, hBitmapBrush, lpBoundsRect, dwBlendLevel
MUIRegionButtonSetBitmap        PROTO :DWORD, :DWORD                        ; hRegionButton, BitmapResID
MUIRegionButtomCustomStates     PROTO :DWORD, :DWORD, :DWORD                ; hRegionButton, lpCustomStatesArray, dwTotalCustomStates
MUIRegionButtonGetCustomState   PROTO :DWORD                                ; hRegionButton
MUIRegionButtonSetCustomState   PROTO :DWORD, :DWORD                        ; hRegionButton, dwStateIndex


_MUI_PolygonInflate             PROTO :DWORD, :DWORD, :DWORD, :DWORD

;------------------------------------------------------------------------------
; ModernUI_RegionButton Structures
;------------------------------------------------------------------------------
IFNDEF MUI_REGIONBUTTON_PROPERTIES
MUI_REGIONBUTTON_PROPERTIES     STRUCT
    dwBackColor                 DD ?    ; COLORREF. Back color.
    dwBackColorAlt              DD ?    ; COLORREF. Back color when mouse hovers over control.
    dwBackColorSel              DD ?    ; COLORREF. Back color when selected state = TRUE.
    dwBackColorSelAlt           DD ?    ; COLORREF. Back color when selected state = TRUE and mouse hovers over control.
    dwBackColorDisabled         DD ?    ; COLORREF. Back color when control is disabled.
    dwBorderColor               DD ?    ; COLORREF. Border color.
    dwBorderColorAlt            DD ?    ; COLORREF. Border color when mouse hovers over control.
    dwBorderColorSel            DD ?    ; COLORREF. Border color when selected state = TRUE.
    dwBorderColorSelAlt         DD ?    ; COLORREF. Border color when selected state = TRUE and mouse hovers over control.
    dwBorderColorDisabled       DD ?    ; COLORREF. Border color when control is disabled.
    dwBorderSize                DD ?    ; DWORD. Border size, 0 = disabled/no border (default)
    dwBorderSizeAlt             DD ?    ; DWORD. Border size when mouse hovers over, 0 = disabled/no border (default)
    dwBorderSizeSel             DD ?    ; DWORD. Border size when selected state = TRUE, 0 = disabled/no border (default)
    dwBorderSizeSelAlt          DD ?    ; DWORD. Border size when selected state = TRUE and mouse hovers over, 0 = disabled/no border (default)
    dwBorderSizeDisabled        DD ?    ; DWORD. Border size when control is disabled, 0 = disabled/no border (default)
    dwUserData                  DD ?    ; DWORD. User defined dword data
MUI_REGIONBUTTON_PROPERTIES     ENDS
ENDIF

IFNDEF MUIRB_NOTIFY                     ; Notification Message Structure for RegionButton
MUIRB_NOTIFY                    STRUCT
    hdr                         NMHDR <0,0,0>
    lParam                      DD 0
MUIRB_NOTIFY                    ENDS
ENDIF

IFNDEF MUIRB_POLY                       ; Used for array of polypoints for MUIRegionButtonSetRegionPoly if dwPolyType == 1, then dwPolyDataCount = no of array entries
MUIRB_POLY                      STRUCT
    ptrPolyData                 DD ?    ; DWORD. Pointer to array of points
    dwPolyDataCount             DD ?    ; DWORD. Count of points in array of points
MUIRB_POLY                      ENDS
ENDIF

IFNDEF MUI_REGIONBUTTON_STATE
MUI_REGIONBUTTON_STATE          STRUCT
    dwColor                     DD ?    ; Color of region button
    dwColorAlt                  DD ?    ; Color of region button when mouse moves over
    dwBorderColor               DD ?    ; Border color of region button
    dwBorderColorAlt            DD ?    ; Border color of region button when mouse moves over
    dwBorderSize                DD ?    ; Border width of region button
    dwBorderSizeAlt             DD ?    ; Border width of region button when mouse moves over
    dwStateFlag                 DD ?    ; Determines behaviour of state
MUI_REGIONBUTTON_STATE          ENDS
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
MUIRB_MOVE                      EQU 4h  ; Allow movement of control with CTRL+Arrow keys
MUIRB_PUSHBUTTON                EQU 8h  ; Simulate button press when clicking down and up
MUIRB_MOUSEMOVEPARENT           EQU 10h ; Notify parent of mousemove
MUIRB_AUTOSTATE                 EQU 20h ; Auto toggle state when clicked
MUIRB_AUTOCUSTOMSTATE           EQU 40h ; Auto toggle state based on custom states

; ModernUI_RegionButton Notify Codes:
MUIRBN_CLICKED                  EQU 1
MUIRBN_MOUSEOVER                EQU 2
MUIRBN_MOUSELEAVE               EQU 3
MUIRBN_SELECTED                 EQU 4
MUIRBN_UNSELECTED               EQU 5
MUIRBN_ENABLED                  EQU 6
MUIRBN_DISABLED                 EQU 7

; ModernUI_RegionButton dwPolyType:
MUIRBP_SINGLE                   EQU 0   ; Single array of points, dwPolyDataCount = no of points
MUIRBP_MULTIPLE                 EQU 1   ; Multiple array of array points, dwPolyDataCount = no of MUIRB_POLY array entries to combine
 

; ModernUI_RegionButton MUI_REGIONBUTTON_STATE dwStateFlag:
MUIRBSF_NONE                    EQU -2  ; No auto toggle, handled manually by programmer
MUIRBSF_TOGGLE_NEXT             EQU -1  ; Auto toggle to next state while < @RegionButtonStatesTotal else wrap to state 0
                                        ; if dwStateFlag is 0 - FFFFFFFDh = specify id of state to toggle to


;------------------------------------------------------------------------------
; ModernUI_RegionButton Properties: Use with MUIRegionSetProperty / 
; MUIRegionGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@RegionButtonBackColor          EQU 0   ; COLORREF. Back color.
@RegionButtonBackColorAlt       EQU 4   ; COLORREF. Back color when mouse hovers over control.
@RegionButtonBackColorSel       EQU 8   ; COLORREF. Back color when selected state = TRUE.
@RegionButtonBackColorSelAlt    EQU 12  ; COLORREF. Back color when selected state = TRUE and mouse hovers over control.
@RegionButtonBackColorDisabled  EQU 16  ; COLORREF. Back color when control is disabled.
@RegionButtonBorderColor        EQU 20  ; COLORREF. Border color.
@RegionButtonBorderColorAlt     EQU 24  ; COLORREF. Border color when mouse hovers over control.
@RegionButtonBorderColorSel     EQU 28  ; COLORREF. Border color when selected state = TRUE.
@RegionButtonBorderColorSelAlt  EQU 32  ; COLORREF. Border color when selected state = TRUE and mouse hovers over control.
@RegionButtonBorderColorDisabled EQU 36 ; COLORREF. Border color when control is disabled.
@RegionButtonBorderSize         EQU 40  ; DWORD. Border size, 0 = disabled/no border (default)
@RegionButtonBorderSizeAlt      EQU 44  ; DWORD. Border size when mouse hovers over, 0 = disabled/no border (default)
@RegionButtonBorderSizeSel      EQU 48  ; DWORD. Border size when selected state = TRUE, 0 = disabled/no border (default)
@RegionButtonBorderSizeSelAlt   EQU 52  ; DWORD. Border size when selected state = TRUE and mouse hovers over, 0 = disabled/no border (default)
@RegionButtonBorderSizeDisabled EQU 56  ; DWORD. Border size when control is disabled, 0 = disabled/no border (default)
@RegionButtonUserData           EQU 64  ; DWORD. User defined dword data


;------------------------------------------------------------------------------
;Example of @RegionButtonStatesColors array.
;------------------------------------------------------------------------------
; 8 states: 0 - 7. Divided into two color ranges, red and blue with a grey neutral color 
; Programmer sets state to state 0 initially, user clicks, and state is toggled to next state (-1 is MUIRBSF_TOGGLE_NEXT) each click, until it resets to state 0
; Programmer sets state to state 4 initially, user clicks, and state is toggled to next state (-1 is MUIRBSF_TOGGLE_NEXT) each click, until it resets to state 4
;
; CustomStates \
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(240,240,240),  MUI_RGBCOLOR(240,240,240)   ,0,0,0,0,   -1> ; grey color        State 0, toggles to next state (=1)
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(236,136,136),  MUI_RGBCOLOR(236,136,136)   ,0,0,0,0,   -1> ; light red color   State 1, toggles to next state (=2)
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(187,90,90),    MUI_RGBCOLOR(187,90,90)     ,0,0,0,0,   -1> ; medium red color  State 2, toggles to next state (=3)
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(123,42,42),    MUI_RGBCOLOR(123,42,42)     ,0,0,0,0,    0> ; dark red color    State 3, toggles to state 0
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(240,240,240),  MUI_RGBCOLOR(240,240,240    ,0,0,0,0,   -1> ; grey color        State 4, toggles to next state (=5)
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(136,155,236),  MUI_RGBCOLOR(136,155,236    ,0,0,0,0,   -1> ; light blue color  State 5, toggles to next state (=6)
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(90,94,187),    MUI_RGBCOLOR(90,94,187      ,0,0,0,0,   -1> ; medium blue color State 6, toggles to next state (=7)
; MUI_REGIONBUTTON_STATE <MUI_RGBCOLOR(42,53,123),    MUI_RGBCOLOR(42,53,123      ,0,0,0,0,    4> ; dark blue color   State 7, toggles to state 4

; could change above definition so that states toggle from grey to reds, to grey, to blues then resets back.
;------------------------------------------------------------------------------









