;======================================================================================================================================
;
; ModernUI Control - ModernUI_SmartPanel v1.0.0.0
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
; ModernUI_SmartPanel Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------
MUISmartPanelRegister          PROTO                                                                   ; Use 'ModernUI_SmartPanel' as class in RadASM custom class control
MUISmartPanelCreate            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD            ; hWndParent, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUISmartPanelSetProperty       PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_SmartPanel, dwProperty, dwPropertyValue
MUISmartPanelGetProperty       PROTO :DWORD, :DWORD                                                    ; hModernUI_SmartPanel, dwProperty

MUISmartPanelGetCurrentPanel   PROTO :DWORD                                                            ; hModernUI_SmartPanel
MUISmartPanelSetCurrentPanel   PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_SmartPanel, PanelIndex, bNotify
MUISmartPanelNextPanel         PROTO :DWORD, :DWORD                                                    ; hModernUI_SmartPanel, bNotify
MUISmartPanelPrevPanel         PROTO :DWORD, :DWORD                                                    ; hModernUI_SmartPanel, bNotify
MUISmartPanelSetIsDlgMsgVar    PROTO :DWORD, :DWORD                                                    ; hModernUI_SmartPanel, Addr lpdwVar
MUISmartPanelRegisterPanel     PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_SmartPanel, dwResIdPanelDlg, lpdwPanelProc


;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_SmartPanel Structures
;--------------------------------------------------------------------------------------------------------------------------------------

IFNDEF MUISP_ITEM ; SmartPanel Notification Item
MUISP_ITEM                      STRUCT
    iItem                       DD 0
    lParam                      DD 0
    hPanel                      DD 0
MUISP_ITEM                      ENDS
ENDIF

IFNDEF NM_MUISMARTPANEL ; Notification Message Structure for SmartPanel
NM_MUISMARTPANEL                STRUCT
    hdr                         NMHDR <>
    itemOld                     MUISP_ITEM <>
    itemNew                     MUISP_ITEM <>
NM_MUISMARTPANEL                ENDS
ENDIF

.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_SmartPanel Constants
;--------------------------------------------------------------------------------------------------------------------------------------

; ModernUI_SmartPanel Messages
MUISPM_REGISTERPANEL            EQU WM_USER+1760 ; wParam Resource id of Dialog, lParam addr of Dialog proc, eax = null or handle panel on success.
MUISPM_SETCURRENTPANEL          EQU WM_USER+1759 ; wParam panel id to select, lparam = send notify msg to parent TRUE/FALSE
MUISPM_GETCURRENTPANEL          EQU WM_USER+1758 ; wParam & lparam = NULL, returns in eax current panel
MUISPM_NEXTPANEL                EQU WM_USER+1757 ; wParam send notify msg to parent TRUE/FALSE. lparam = NULL, moves to next panel. If at end and wraparound is specified moves back to start panel, otherwise stops here.
MUISPM_PREVPANEL                EQU WM_USER+1756 ; wParam send notify msg to parent TRUE/FALSE. lparam = NULL, moves to previous panel. If at begining and wraparound is specified moves to last panel, otherwise stops here.
MUISPM_GETTOTALPANELS           EQU WM_USER+1755 ; wParam & lparam = NULL, returns in eax total panels
MUISPM_SETISDLGMSGVAR           EQU WM_USER+1754 ; Address of variable to hold current panel dialog handle for use with IsDialogMessage message loop calls

;SmartPanel Notifications
MUISPN_SELCHANGED               EQU 0            ; Used with WM_NOTIFY. wParam is a NM_MUISMARTPANEL struct

; ModernUI_SmartPanel Styles
MUISPS_NORMAL                   EQU 00h
MUISPS_NOSLIDE                  EQU MUISPS_NORMAL
MUISPS_SLIDEPANELS_SLOW         EQU 01h
MUISPS_SLIDEPANELS_NORMAL       EQU 02h
MUISPS_SLIDEPANELS              EQU MUISPS_SLIDEPANELS_NORMAL
MUISPS_SLIDEPANELS_FAST         EQU 04h
MUISPS_SLIDEPANELS_VFAST        EQU 08h
MUISPS_SLIDEPANELS_INSTANT      EQU MUISPS_NORMAL
MUISPS_SPS_WRAPAROUND           EQU 10h ; for next/prev and showcase, if at end, moves to the right and starts again, otherwise if not specified, at last panel, scrolls left all the way back to start showing all panels along the way.
;--------------------------------------------------------------------------------------------------------------------------------------
; ModernUI_SmartPanel Properties: Use with MUIModernUI_SmartPanelSetProperty / MUIModernUI_SmartPanelGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@SmartPanelDllInstance          EQU 0












