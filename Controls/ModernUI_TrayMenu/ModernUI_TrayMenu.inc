;==============================================================================
;
; ModernUI Control - ModernUI_TrayMenu
;
; Copyright (c) 2023 by fearless
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
; ModernUI_TrayMenu Prototypes
;------------------------------------------------------------------------------
MUITrayMenuRegister         PROTO                                                   ; Use 'ModernUI_TrayMenu' as class in RadASM custom class control
MUITrayMenuCreate           PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hWndParent, hTrayMenuIcon, lpszTooltip, dwMenuType, dwMenu, dwOptions, hWndExtra
MUITrayMenuSetProperty      PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_TrayMenu, dwProperty, dwPropertyValue
MUITrayMenuGetProperty      PROTO :DWORD,:DWORD                                     ; hModernUI_TrayMenu, dwProperty
MUITrayMenuAssignMenu       PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_TrayMenu, dwMenuType, dwMenu

; Tray Menu Item Functions
MUITrayMenuSetTrayIcon      PROTO :DWORD,:DWORD                                     ; hModernUI_TrayMenu, hTrayIcon
MUITrayMenuSetTooltipText   PROTO :DWORD,:DWORD                                     ; hModernUI_TrayMenu, lpszTooltip
MUITrayMenuEnableMenuItem   PROTO :DWORD,:DWORD                                     ; hModernUI_TrayMenu, MenuItemID
MUITrayMenuDisableMenuItem  PROTO :DWORD,:DWORD                                     ; hModernUI_TrayMenu, MenuItemID
MUITrayMenuChangeMenuItemState PROTO :DWORD,:DWORD,:DWORD                           ; hModernUI_TrayMenu, MenuItemID, MenuItemState
MUITrayMenuSetMenuItemText  PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_TrayMenu, MenuItemID, lpszMenuItemText
MUITrayMenuHideTrayIcon     PROTO :DWORD                                            ; hModernUI_TrayMenu
MUITrayMenuShowTrayIcon     PROTO :DWORD                                            ; hModernUI_TrayMenu
MUITrayMenuShowNotification PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hModernUI_TrayMenu, lpszNotificationMessage, lpszNotificationTitle, dwTimeout, dwStyle
MUITrayMenuSetTrayIconText  PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_TrayMenu, lpszText, hFontIconText, dwTextColorRGB

MUITrayMenuMinimizeToTray   PROTO :DWORD                                            ; hModernUI_TrayMenu
MUITrayMenuRestoreFromTray  PROTO :DWORD                                            ; hModernUI_TrayMenu

; Tray Icon Functions (standalone - no menu)
MUITrayIconCreate           PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hWndParent, dwTrayIconResID, hTrayIcon, lpszTooltip - Returns in eax hModernUI_TrayIcon
MUITrayIconDestroy          PROTO :DWORD                                            ; hModernUI_TrayIcon
MUITrayIconSetTrayIcon      PROTO :DWORD,:DWORD                                     ; hModernUI_TrayIcon, hTrayIcon
MUITrayIconSetTooltipText   PROTO :DWORD,:DWORD                                     ; hModernUI_TrayIcon, lpszTooltip
MUITrayIconShowNotification PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hModernUI_TrayIcon, lpszNotificationMessage, lpszNotificationTitle, dwTimeout, dwStyle
MUITrayIconSetTrayIconText  PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_TrayIcon, lpszText, hFontIconText, dwTextColorRGB

MUITrayCreateIconText       PROTO :DWORD,:DWORD,:DWORD                              ; lpszText, hFontIconText, dwTextColorRGB

;------------------------------------------------------------------------------
; ModernUI_TrayMenu Structures
;------------------------------------------------------------------------------
IFNDEF MUI_TRAYMENU_PROPERTIES
MUI_TRAYMENU_PROPERTIES     STRUCT
    dwTrayMenuIcon          DD ?
    dwTrayMenuTooltipText   DD ?
    dwTrayMenuVisible       DD ?
    dwTrayMenuType          DD ?
    dwTrayMenuHandleMenu    DD ?
    dwTrayMenuExtraWndHandle DD ?
MUI_TRAYMENU_PROPERTIES     ENDS
ENDIF

.CONST
;------------------------------------------------------------------------------
; ModernUI_TrayMenu Constants
;------------------------------------------------------------------------------

; ModernUI_TrayMenu Styles
; Tray Menu Type: dwMenuType of TrayMenuCreate and TrayMenuAssignMenu functions
MUITMT_MENUDEFER            EQU 0 ; Specified that dwMenu is ignored.
MUITMT_POPUPMENU            EQU 1 ; Specifies that dwMenu is a handle to a menu created with CreatePopupMenu
MUITMT_MENUITEMS            EQU 2 ; Specifies that dwMenu is a pointer to a list of TMITEM structures used to build menu from
MUITMT_NOMENUEVER           EQU 3 ; Specified that no menu is ever added to the icon at any point.

; Tray Menu Style
MUITMS_DEFAULT              EQU 0 ; default 
MUITMS_MINONCLOSE           EQU 1 ; minimizes window when close clicked
MUITMS_HIDEIFMIN            EQU 2 ; hide window when minimized
MUITMS_HWNDEXTRA            EQU 4 ; use hWndExtra as window to process for hiding/showing


; Tray Menu Notification Icon
MUITMNI_NONE                EQU 0 ; No icon.
MUITMNI_INFO                EQU 1 ; An information icon.
MUITMNI_WARNING             EQU 2 ; A warning icon.
MUITMNI_ERROR               EQU 3 ; An error icon.

;------------------------------------------------------------------------------
; ModernUI_TrayMenu Properties: Use with MUIrayMenuSetProperty / 
; MUITrayMenuGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@TrayMenuIcon               EQU 0   ; hIcon to display in tray
@TrayMenuTooltipText        EQU 4   ; lpszText to display over icon in tray
@TrayMenuVisible            EQU 8   ; bool visible = TRUE/FALSE
@TrayMenuType               EQU 12  ; Tray Menu Type: TMT_MENUDEFER, TMT_POPUPMENU, TMT_MENUITEMS, TMT_NOMENUEVER
@TrayMenuHandleMenu         EQU 16  ; hMenu
@TrayMenuExtraWndHandle     EQU 20  ; hWnd Extra window handle to use for restoring a main window that isnt parent to current child window that hTM is based on



IFNDEF MUITMITEM
MUITMITEM                   STRUCT
    MenuItemID              DD 0
    MenuItemType            DD 0
    MenuItemText            DD 0
    MenuItemState           DD 0
MUITMITEM                   ENDS
ENDIF

IFNDEF MUITRAYMENU             ; Used with TrayMenuCreate and/or TrayMenuAssignMenu functions
MUITRAYMENU MACRO menulabel:REQ
    .DATA
menulabel                   DB 0FFh,0FFh,0FFh,0F0h   
    ;% echo menulabel
    ;% EXITM <menulabel  >
ENDM
ENDIF

IFNDEF MUITRAYMENU_ITEM       ; Used with TrayMenuCreate and/or TrayMenuAssignMenu functions
MUITRAYMENU_ITEM MACRO menutext:REQ, menuid:=<NULL>, menustate:=<MFS_ENABLED>
    LOCAL menustatetext, DashLines
    
    IFIDNI <menustate>, <ENABLED>
        menustatetext TEXTEQU <MFS_ENABLED>
    ELSE
        IFIDNI <menustate>, <DISABLED>
            menustatetext TEXTEQU <MFS_DISABLED>
        ELSE    
            menustatetext TEXTEQU <menustate>
        ENDIF
    ENDIF
    
    IF menuid eq 0
        MUITMITEM <0, MF_SEPARATOR, 0, MFS_ENABLED>
    ELSE
        IFIDNI <menutext>, <SEPARATOR>
            MUITMITEM <0, MF_SEPARATOR, 0, MFS_ENABLED>
        ELSE
            DashLines = @InStr(1, <menutext>, <->)
            IF DashLines gt 0
                MUITMITEM <0, MF_SEPARATOR, 0, MFS_ENABLED>
            ELSE
                MUITMITEM <menuid, MF_STRING, Offset menutext, menustatetext>
            ENDIF
        ENDIF
    ENDIF
ENDM
ENDIF

IFNDEF MUITRAYMENU_END         ; Used with TrayMenuCreate and/or TrayMenuAssignMenu functions
MUITRAYMENU_END                TEXTEQU <DB 0FFh,0FFh,0FFh,0FFh>
ENDIF

;	
; https://masm32.com/board/index.php?topic=7972.0
;	HWND hWndTray = FindWindow(TEXT("Shell_TrayWnd"), NULL);
;	hWndTray = GetWindow(hWndTray, GW_CHILD);	//notification area
;	PostMessage(hWndTray, WM_PAINT , 0, 0);
;	
