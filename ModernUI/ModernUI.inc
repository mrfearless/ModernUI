;==============================================================================
;
; ModernUI Library v0.0.0.5
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
; ModernUI Prototypes
;------------------------------------------------------------------------------
; ModernUI Base Functions:
MUIGetExtProperty               PROTO :DWORD,:DWORD                             ; hControl, dwProperty
MUISetExtProperty               PROTO :DWORD,:DWORD,:DWORD                      ; hControl, dwProperty, dwPropertyValue
MUIGetIntProperty               PROTO :DWORD,:DWORD                             ; hControl, dwProperty
MUISetIntProperty               PROTO :DWORD,:DWORD,:DWORD                      ; hControl, dwProperty, dwPropertyValue

MUIGetExtPropertyEx             PROTO :DWORD,:DWORD,:DWORD                      ; hControl, dwParentProperty, dwChildProperty
MUISetExtPropertyEx             PROTO :DWORD,:DWORD,:DWORD,:DWORD               ; hControl, dwParentProperty, dwChildProperty, dwPropertyValue
MUIGetIntPropertyEx             PROTO :DWORD,:DWORD,:DWORD                      ; hControl, dwParentProperty, dwChildProperty
MUISetIntPropertyEx             PROTO :DWORD,:DWORD,:DWORD,:DWORD               ; hControl, dwParentProperty, dwChildProperty, dwPropertyValue

MUIGetExtPropertyExtra          PROTO :DWORD,:DWORD                             ; hControl, dwProperty
MUISetExtPropertyExtra          PROTO :DWORD,:DWORD,:DWORD                      ; hControl, dwProperty, dwPropertyValue
MUIGetIntPropertyExtra          PROTO :DWORD,:DWORD                             ; hControl, dwProperty
MUISetIntPropertyExtra          PROTO :DWORD,:DWORD,:DWORD                      ; hControl, dwProperty, dwPropertyValue


; ModernUI Memory Functions:
MUIAllocMemProperties           PROTO :DWORD,:DWORD,:DWORD                      ; hControl, cbWndExtraOffset, dwSizeToAllocate
MUIFreeMemProperties            PROTO :DWORD,:DWORD                             ; hControl, cbWndExtraOffset
MUIAllocStructureMemory         PROTO :DWORD,:DWORD,:DWORD                      ; dwPtrStructMem, TotalItems, ItemSize

; ModernUI GDI DoubleBuffer Functions:
MUIGDIDoubleBufferStart         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD        ; hWin, hdcSource, lpHDCBuffer, lpClientRect, lphBufferBitmap
MUIGDIDoubleBufferFinish        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD ; hdcBuffer, hBufferBitmap, hBitmapUsed, hFontUsed, hBrushUsed, hPenUsed

; ModernUI GDIPlus Functions:
MUIGDIPlusStart                 PROTO                                           ; Wrapper for GDIPlus startup
MUIGDIPlusFinish                PROTO                                           ; Wrapper for GDIPlus shutdown

; ModernUI Painting & Color Functions:
MUIPaintBackground              PROTO :DWORD,:DWORD,:DWORD                      ; hDialogWindow, dwBackColor, dwBorderColor
MUIPaintBackgroundImage         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD ; hDialogWindow, dwBackColor, dwBorderColor, hImage, dwImageType, dwImageLocation
MUIGetParentBackgroundColor     PROTO :DWORD                                    ; hControl
MUIGetParentBackgroundBitmap    PROTO :DWORD                                    ; hControl

; ModernUI Window/Dialog Functions:
MUIApplyToDialog                PROTO :DWORD,:DWORD,:DWORD                      ; hDialogWindow, dwDropShadow (true to set drop shadow), dwClipping (true to set clipping on)
MUICenterWindow                 PROTO :DWORD,:DWORD                             ; hWndChild, hWndParent
MUIGetParentRelativeWindowRect  PROTO :DWORD,:DWORD                             ; hControl, lpRectControl

; ModernUI Region Functions:
MUILoadRegionFromResource       PROTO :DWORD,:DWORD,:DWORD,:DWORD               ; hInstance, idRgnRes, lpRegion, lpdwSizeRegion
MUISetRegionFromResource        PROTO :DWORD,:DWORD,:DWORD,:DWORD               ; hWin, idRgnRes, lpdwCopyRgn, bRedraw

; ModernUI Font Functions:
MUIPointSizeToLogicalUnit       PROTO :DWORD,:DWORD                             ; hControl, dwPointSize

; ModernUI Image Functions:
MUIGetImageSize                 PROTO :DWORD,:DWORD,:DWORD,:DWORD               ; hImage, dwImageType, lpdwImageWidth, lpdwImageHeight
MUICreateIconFromMemory         PROTO :DWORD,:DWORD                             ; pIconData, iIcon
MUICreateCursorFromMemory       PROTO :DWORD                                    ; pCursorData
MUICreateBitmapFromMemory       PROTO :DWORD                                    ; pBitmapData

; ModernUI DPI & Scaling Functions:
MUIDPI                          PROTO :DWORD,:DWORD                             ; lpdwDPIX, lpdwDPIY
MUIDPIScaleX                    PROTO :DWORD                                    ; dwValueX
MUIDPIScaleY                    PROTO :DWORD                                    ; dwValueY
MUIDPIScaleRect                 PROTO :DWORD                                    ; lpRect
MUIDPIScaleControl              PROTO :DWORD,:DWORD,:DWORD,:DWORD               ; lpdwLeft, lpdwTop, lpdwWidth, lpdwHeight
MUIDPIScaleFontSize             TEXTEQU <MUIPointSizeToLogicalUnit>             ; hControl, dwPointSize
MUIDPIScaledScreen              PROTO :DWORD,:DWORD                             ; lpdwScreenWidth, lpdwScreenHeight
MUIDPISetDPIAware               PROTO

.CONST

;------------------------------------------
; Define MUI_USEGDIPLUS to compile
; gdiplus support into ModernUI library 
; Other controls can force this off by
; defining MUI_DONTUSEGDIPLUS if they
; wish to exclude gdiplus support
;------------------------------------------
IFNDEF MUI_DONTUSEGDIPLUS
MUI_USEGDIPLUS                  EQU 1               ; Use GDI+ or not
ENDIF

;------------------------------------------
; Global constants used by all ModernUI
; controls. 
;------------------------------------------
MUI_INTERNAL_PROPERTIES         EQU 0               ; cbWndExtra offset for internal properties pointer
MUI_EXTERNAL_PROPERTIES         EQU 4               ; cbWndExtra offset for external properties pointer
MUI_INTERNAL_PROPERTIES_EXTRA   EQU 8               ; cbWndExtra offset for extra internal properties pointer
MUI_EXTERNAL_PROPERTIES_EXTRA   EQU 12              ; cbWndExtra offset for extra external properties pointer
MUI_PROPERTY_ADDRESS            EQU 80000000h       ; OR with dwProperty in MUIGetIntProperty/MUIGetExtProperty to return address of property 


MUI_ALIGN                       TEXTEQU <ALIGN 16>

;------------------------------------------
; ModernUI Custom Messages - each control 
; should handle these
;------------------------------------------
MUI_GETPROPERTY                 EQU WM_USER + 1800  ; wParam = dwProperty, lParam = NULL
MUI_SETPROPERTY                 EQU WM_USER + 1799  ; wParam = dwProperty, lParam = dwPropertyValue
;MUI_GETTHEME                   EQU WM_USER + 1798  ; wParam = NULL, lParam = NULL. Returns in eax lpMUITHEMEStructure
;MUI_SETTHEME                   EQU WM_USER + 1797  ; wParam = lpMUITHEMEStructure, lParam = NULL

;------------------------------------------
; Image Types
;------------------------------------------
MUIIT_NONE                      EQU 0
MUIIT_BMP                       EQU 1
MUIIT_ICO                       EQU 2
MUIIT_PNG                       EQU 3

;------------------------------------------
; Image Locations
;------------------------------------------
MUIIL_CENTER                    EQU 0
MUIIL_BOTTOMLEFT                EQU 1
MUIIL_BOTTOMRIGHT               EQU 2
MUIIL_TOPLEFT                   EQU 3
MUIIL_TOPRIGHT                  EQU 4
MUIIL_TOPCENTER                 EQU 5
MUIIL_BOTTOMCENTER              EQU 6


;------------------------------------------
; ModernUI Macros
;------------------------------------------
MUI_ARGBCOLOR MACRO alpha, red, green, blue
    EXITM < alpha SHL 24 OR red SHL 16 OR green SHL 8 OR blue >
ENDM

AlphaRGB MACRO alpha, red, green, blue
    EXITM < alpha SHL 24 OR red SHL 16 OR green SHL 8 OR blue >
ENDM

MUI_RGBCOLOR MACRO red:REQ, green:REQ, blue:REQ
    EXITM < red or green shl 8 or blue shl 16 >
ENDM

RGB MACRO red:REQ, green:REQ, blue:REQ
    EXITM < red or green shl 8 or blue shl 16 >
ENDM


;------------------------------------------
; Notes
;------------------------------------------
; Custom controls: dwStyle parameter of 
; CreateWindowEx.
;
; The low 16 bits of the dwStyle parameter 
; are defined by the implementor of the 
; window class (by the person who calls 
; RegisterClass) - Raymond Chen
;
; 0x0h - 0xFFFFh reserved for user creating
; the control to define styles
;------------------------------------------


;------------------------------------------
; Remove comment to include debug32 macros
;------------------------------------------
;DEBUG32 EQU 1
;IFDEF DEBUG32
;    PRESERVEXMMREGS equ 1
;    includelib M:\Masm32\lib\Debug32.lib
;    DBG32LIB equ 1
;    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
;    include M:\Masm32\include\debug32.inc
;ENDIF
;------------------------------------------


;------------------------------------------
; Remove comment to include unicode support
;------------------------------------------
;MUI_UNICODE TEXTEQU <__UNICODE__>
;IFDEF MUI_UNICODE
;__UNICODE__ EQU 1
;ECHO MUI_UNICODE BUILD
;ENDIF
;------------------------------------------








