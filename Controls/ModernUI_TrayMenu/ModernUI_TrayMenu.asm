;==============================================================================
;
; ModernUI Control - ModernUI_TrayMenu
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

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

;DEBUG32 EQU 1
;
;IFDEF DEBUG32
;    PRESERVEXMMREGS equ 1
;    includelib M:\Masm32\lib\Debug32.lib
;    DBG32LIB equ 1
;    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
;    include M:\Masm32\include\debug32.inc
;ENDIF

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include comctl32.inc
include shell32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shell32.lib

include masm32.inc
includelib masm32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_TrayMenu.inc



IFNDEF WM_SHELLNOTIFY
WM_SHELLNOTIFY              EQU WM_USER+5 ; Msg Event Sent Back When Tray Event Triggered
ENDIF
IFNDEF NIN_BALLOONSHOW
NIN_BALLOONSHOW             EQU WM_USER+2 ; Returned via WM_SHELLNOTIFY: wParam is resource id of tray icon, lParam is this value 
ENDIF
IFNDEF NIN_BALLOONHIDE
NIN_BALLOONHIDE             EQU WM_USER+3 ; Returned via WM_SHELLNOTIFY: wParam is resource id of tray icon, lParam is this value 
ENDIF
IFNDEF NIN_BALLOONTIMEOUT
NIN_BALLOONTIMEOUT          EQU WM_USER+4 ; Returned via WM_SHELLNOTIFY: wParam is resource id of tray icon, lParam is this value 
ENDIF
IFNDEF NIN_BALLOONUSERCLICK
NIN_BALLOONUSERCLICK        EQU WM_USER+5 ; Returned via WM_SHELLNOTIFY: wParam is resource id of tray icon, lParam is this value 
ENDIF

IFNDEF TMITEM
TMITEM              STRUCT
    MenuItemID      DD 0
    MenuItemType    DD 0
    MenuItemText    DD 0
    MenuItemState   DD 0
TMITEM              ENDS
ENDIF

IFNDEF NOTIFYICONDATAA
NOTIFYICONDATAA STRUCT
  cbSize            DWORD      ?
  hWnd              DWORD      ?
  uID               DWORD      ?
  uFlags            DWORD      ?
  uCallbackMessage  DWORD      ?
  hIcon             DWORD      ?
  szTip             BYTE       128 dup(?)
  dwState           DWORD      ?
  dwStateMask       DWORD      ?
  szInfo            BYTE       256 dup(?)
  union
      uTimeout      DWORD      ?
      uVersion      DWORD      ?
  ends
  szInfoTitle       BYTE       64 dup(?)
  dwInfoFlags       DWORD      ?
NOTIFYICONDATAA ENDS

NOTIFYICONDATA  equ  <NOTIFYICONDATAA>
ENDIF


;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_TrayMenuWndProc                    PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TrayMenuSetSubclass                PROTO :DWORD
_MUI_TrayMenuWindowSubClass_Proc        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TrayMenuInit                       PROTO :DWORD
_MUI_TrayMenuCleanup                    PROTO :DWORD
_MUI_TM_AddIconAndTooltip               PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TM_ShowTrayMenu                    PROTO :DWORD, :DWORD
_MUI_TM_RestoreFromTray                 PROTO :DWORD, :DWORD
_MUI_TM_MinimizeToTray                  PROTO :DWORD, :DWORD
_MUI_TM_IconText                        PROTO :DWORD, :DWORD, :DWORD
_MUI_TM_HideNotification                PROTO :DWORD


;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
IFNDEF MUI_TRAYMENU_PROPERTIES
MUI_TRAYMENU_PROPERTIES                 STRUCT
    dwTrayMenuIcon                      DD ?
    dwTrayMenuTooltipText               DD ?
    dwTrayMenuVisible                   DD ?
    dwTrayMenuType                      DD ?
    dwTrayMenuHandleMenu                DD ?
    dwTrayMenuExtraWndHandle            DD ?
MUI_TRAYMENU_PROPERTIES                 ENDS
ENDIF

; Internal properties
_MUI_TRAYMENU_PROPERTIES                STRUCT
    NID                                 DD ? ; ptr to NOTIFYICONDATA struct
    dwTrayMenuIconVisible               DD ?
    dwTrayIconVisible                   DD ?
    dwParent                            DD ?
_MUI_TRAYMENU_PROPERTIES                ENDS


.CONST
WM_INITSUBCLASS                         EQU WM_USER + 99

; Internal properties
@TrayMenuNID                            EQU 0
@TrayMenuIconVisible                    EQU 4
@TrayIconVisible                        EQU 8
@TrayParent                             EQU 12
; External public properties


.DATA
ALIGN 4
szMUITrayIconDisplayDC                  DB 'DISPLAY',0
szMUITrayMenuClass                      DB 'ModernUI_TrayMenu',0        ; Class name for creating our ModernUI_TrayMenu control
szMUITrayMenuFont                       DB 'Tahoma',0                   ; Font used for ModernUI_TrayMenu text

; File M:\radasm\Masm\projects\Test Projects\cpuload\blank.ico opened at 1150 bytes
ALIGN 4
icoMUITrayBlankIcon       db 0,0,1,0,1,0,16,16,0,0,1,0,32,0,104,4
    db 0,0,22,0,0,0,40,0,0,0,16,0,0,0,32,0
    db 0,0,1,0,32,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,255,255
    db 172,65,255,255,172,65,255,255,172,65,255,255,172,65,255,255
    db 172,65,255,255,172,65,255,255,172,65,255,255,172,65,255,255
    db 172,65,255,255,172,65,255,255,172,65,255,255,172,65,255,255
    db 172,65,255,255,172,65,255,255,172,65,255,255,172,65


.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_TrayMenu control
;------------------------------------------------------------------------------
MUITrayMenuSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUITrayMenuSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_TrayMenu control
;------------------------------------------------------------------------------
MUITrayMenuGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUITrayMenuGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUITrayMenuRegister - Registers the ModernUI_TrayMenu control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_TrayMenu
;------------------------------------------------------------------------------
MUITrayMenuRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUITrayMenuClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUITrayMenuClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_TrayMenuWndProc
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
        Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

MUITrayMenuRegister ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUITrayMenuCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUITrayMenuCreate PROC PUBLIC hWndParent:DWORD, hTrayMenuIcon:DWORD, lpszTooltip:DWORD, dwMenuType:DWORD, dwMenu:DWORD, dwOptions:DWORD, hWndExtra:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL hWndSubClass:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUITrayMenuRegister
    
    Invoke CreateWindowEx, NULL, Addr szMUITrayMenuClass, lpszTooltip, dwOptions, 0, 0, 0, 0, hWndParent, NULL, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        .IF hTrayMenuIcon != NULL
            Invoke MUISetExtProperty, hControl, @TrayMenuIcon, hTrayMenuIcon
        .ENDIF
        .IF lpszTooltip != NULL
            Invoke MUISetExtProperty, hControl, @TrayMenuTooltipText, lpszTooltip
        .ENDIF
        .IF hWndExtra != NULL
            ;PrintDec hWndExtra
            Invoke MUISetExtProperty, hControl, @TrayMenuExtraWndHandle, hWndExtra
        .ENDIF
        
        Invoke MUISetIntProperty, hControl, @TrayParent, hWndParent
        ; otherwise values are set, and MUITrayMenuAssignMenu destroys menu before assigning the prior destoryed handle.
;        .IF dwMenuType != NULL
;            Invoke MUISetExtProperty, hControl, @TrayMenuType, dwMenuType
;        .ENDIF
;        .IF dwMenu != NULL
;            Invoke MUISetExtProperty, hControl, @TrayMenuHandleMenu, dwMenu
;        .ENDIF

        Invoke _MUI_TM_AddIconAndTooltip, hControl, hWndParent, hTrayMenuIcon, lpszTooltip
        
        .IF dwMenuType != NULL && dwMenu != NULL
            .IF dwMenuType != MUITMT_MENUDEFER && dwMenuType != MUITMT_NOMENUEVER
                Invoke MUITrayMenuAssignMenu, hControl, dwMenuType, dwMenu
            .ENDIF
        .ENDIF
        
        ;PrintDec hWndParent
        ;PrintDec hControl
        
        ;Invoke _MUI_TrayMenuSetSubclass, hControl

        
;        Invoke GetWindowSubclass, hWndParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hControl, Addr hWndSubClass
;        .IF eax == TRUE
;            mov eax, hWndSubClass
;            .IF eax == hControl
;                PrintText 'Subclass already installed'
;                ; Subclass already installed
;                ;Invoke RemoveWindowSubclass, hParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hWin
;                ;Invoke SetWindowSubclass, hParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hWin, hWin
;            .ENDIF
;        .ELSE
;            PrintDec hWndSubClass
;            PrintText 'installing Subclass'
;            Invoke SetWindowSubclass, hWndParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hControl, hControl
;            .IF eax == TRUE
;                PrintText 'True'
;            .ENDIF
;        .ENDIF  
        
 
    .ENDIF
    mov eax, hControl
    ret
MUITrayMenuCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TrayMenuWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_TrayMenuWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_TRAYMENU_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_TRAYMENU_PROPERTIES ; external properties
        Invoke _MUI_TrayMenuInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_TrayMenuCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4
        mov eax, 0
        ret    

    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY
        mov eax, wParam
        .IF eax == @TrayMenuType
            mov eax, lParam ; lParam == @TrayMenuType
            .IF eax != MUITMT_MENUDEFER && eax != MUITMT_NOMENUEVER
                Invoke MUIGetExtProperty, hWin, @TrayMenuHandleMenu
                mov ebx, eax
                .IF ebx != NULL ; ebx = @TrayMenuHandleMenu
                    Invoke MUITrayMenuAssignMenu, hWin, lParam, ebx
                .ENDIF
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, lParam

        .ELSEIF eax == @TrayMenuHandleMenu
            mov eax, lParam ; lParam == @TrayMenuHandleMenu
            .IF eax != NULL
                Invoke MUIGetExtProperty, hWin, @TrayMenuType
                mov ebx, eax ; ebx = @TrayMenuType
                .IF ebx != MUITMT_MENUDEFER && ebx != MUITMT_NOMENUEVER
                    Invoke MUITrayMenuAssignMenu, hWin, ebx, lParam
                .ENDIF
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, lParam
            
        .ELSEIF eax == @TrayMenuIcon
            .IF lParam != NULL
                Invoke MUIGetExtProperty, hWin, @TrayMenuTooltipText
                .IF eax != NULL
                    Invoke MUITrayMenuSetTrayIcon, hWin, lParam
                    ret
                .ENDIF
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, lParam

        .ELSEIF eax == @TrayMenuTooltipText
            .IF lParam != NULL
                Invoke MUIGetExtProperty, hWin, @TrayMenuIcon
                .IF eax != NULL
                    Invoke MUITrayMenuSetTooltipText, hWin, lParam
                    ret
                .ENDIF
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, lParam
        
        .ELSE
            Invoke MUISetExtProperty, hWin, wParam, lParam
        .ENDIF
        ret
        
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_TrayMenuWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TrayMenuSetSubclass - Set sublcass for TrayMenu control
;------------------------------------------------------------------------------
_MUI_TrayMenuSetSubclass PROC hControl:DWORD
    LOCAL hWndSubClass:DWORD
    LOCAL hParent:DWORD
    LOCAL TrayMenuType:DWORD
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuType
    mov TrayMenuType, eax
    
    .IF TrayMenuType == MUITMT_NOMENUEVER
        ret
    .ENDIF
    
    ;Invoke MUIGetIntProperty, hControl, @TrayParent
    Invoke GetWindow, hControl, GW_OWNER
    mov hParent, eax
    
    ;PrintDec hParent
    ;PrintDec hControl
    
    Invoke GetWindowSubclass, hParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hControl, Addr hWndSubClass
    .IF eax == TRUE
        mov eax, hWndSubClass
        .IF eax == hControl
            ;PrintText 'Subclass already installed'
            ; Subclass already installed
            ;Invoke RemoveWindowSubclass, hParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hWin
            ;Invoke SetWindowSubclass, hParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hWin, hWin
        .ENDIF
    .ELSE
        ;PrintDec hWndSubClass
        ;PrintText 'installing Subclass'
        Invoke SetWindowSubclass, hParent, Addr _MUI_TrayMenuWindowSubClass_Proc, hControl, hControl
        .IF eax == TRUE
            ;PrintText 'True'
        .ENDIF
    .ENDIF    
    ret

_MUI_TrayMenuSetSubclass ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TrayMenuWindowSubClass_Proc - sublcass main window to handle our WM_SHELLNOTIFY
;------------------------------------------------------------------------------
_MUI_TrayMenuWindowSubClass_Proc PROC PRIVATE hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL dwStyle:DWORD
    
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Addr _MUI_TrayMenuWindowSubClass_Proc, uIdSubclass
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam 
        ret
    
    .ELSEIF eax == WM_SYSCOMMAND
        ;PrintText 'WM_SYSCOMMAND'
        .IF wParam == SC_CLOSE
            Invoke GetWindowLong, dwRefData, GWL_STYLE
            mov dwStyle, eax
            ;PrintText 'MinOnClose'
            ;PrintDec dwStyle
            AND eax, MUITMS_MINONCLOSE
            .IF eax == MUITMS_MINONCLOSE ; MinimizeOnClose is ON
                mov eax, dwStyle
                AND eax, MUITMS_HIDEIFMIN
                .IF eax == MUITMS_HIDEIFMIN  
                    Invoke _MUI_TM_MinimizeToTray, hWin, TRUE
                .ELSE
                    Invoke _MUI_TM_MinimizeToTray, hWin, FALSE
                .ENDIF
                xor eax, eax
                ret
            ;.ELSE
            ;    Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            ;    ret
            .ENDIF
        .ENDIF
    
    .ELSEIF eax == WM_SIZE
        ;PrintText 'WM_SIZE'
        .IF wParam == SIZE_MINIMIZED
            Invoke GetWindowLong, dwRefData, GWL_STYLE
            mov dwStyle, eax
            ;PrintText 'HideIfMin'
            ;PrintDec dwStyle
            AND eax, MUITMS_HIDEIFMIN
            .IF eax == MUITMS_HIDEIFMIN         
                Invoke _MUI_TM_MinimizeToTray, hWin, TRUE
            .ELSE
                Invoke _MUI_TM_MinimizeToTray, hWin, FALSE
            .ENDIF
        .ENDIF
    
    .ELSEIF eax == WM_SHELLNOTIFY
        .IF lParam == WM_RBUTTONDOWN
            Invoke _MUI_TM_ShowTrayMenu, hWin, dwRefData ;hTM
        .ELSEIF lParam == WM_LBUTTONDOWN
            Invoke _MUI_TM_RestoreFromTray, hWin, dwRefData
        .ELSEIF lParam == WM_RBUTTONDBLCLK
            Invoke _MUI_TM_ShowTrayMenu, hWin, dwRefData ;hTM
        .ELSEIF lParam == WM_LBUTTONDBLCLK
            Invoke _MUI_TM_RestoreFromTray, hWin, dwRefData
        .ENDIF
    .ENDIF
    
    Invoke DefSubclassProc, hWin, uMsg, wParam, lParam         
    ret

_MUI_TrayMenuWindowSubClass_Proc endp


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TrayMenuInit - set initial default values
;------------------------------------------------------------------------------
_MUI_TrayMenuInit PROC PRIVATE hControl:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    

    Invoke GetParent, hControl
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax
    
    Invoke _MUI_TrayMenuSetSubclass, hControl
    
    ret

_MUI_TrayMenuInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TrayMenuCleanup - Frees memory used by control
;------------------------------------------------------------------------------
_MUI_TrayMenuCleanup PROC PRIVATE hControl:DWORD
    LOCAL NID:DWORD

    Invoke MUIGetIntProperty, hControl, @TrayMenuNID
    mov NID, eax
    
    .IF NID != NULL
        Invoke Shell_NotifyIcon, NIM_DELETE, NID ; Remove tray icon
        Invoke GlobalFree, NID
    .ENDIF
    
    ret
_MUI_TrayMenuCleanup ENDP







;==============================================================================
; TRAY MENU Functions
;==============================================================================



MUI_ALIGN
;------------------------------------------------------------------------------
; Assigns a menu to the ModernUI_TrayMenu control, using a popup menu created with 
; CreatePopupMenu or by building a menu from a block of MUITRAYMENUITEM structures
; dwMenuType determines which dwMenu contains
; if dwMenuType == MUITMT_POPUPMENU, dwMenu is a handle to a popup menu
; if dwMenuType == MUITMT_MENUITEMS, dwMenu is pointer to array of structures
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuAssignMenu PROC PUBLIC USES EBX hControl:DWORD, dwMenuType:DWORD, dwMenu:DWORD
    LOCAL mi:MENUITEMINFO
    LOCAL hTrayMenu:DWORD
    LOCAL CurrentItem:DWORD
    LOCAL CurrentItemOffset:DWORD
    LOCAL pTrayMenuItem:DWORD
    LOCAL MenuItemID:DWORD
    LOCAL MenuItemType:DWORD
    LOCAL MenuItemText:DWORD
    LOCAL MenuItemState:DWORD
    
    IFDEF DEBUG32
        PrintText 'TrayMenuAssignMenu'
    ENDIF

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    ; check menu doesnt exist already, if so destroy it before assigning new one
    Invoke MUIGetExtProperty, hControl, @TrayMenuHandleMenu
    mov hTrayMenu, eax
    .IF hTrayMenu != 0
        Invoke DestroyMenu, hTrayMenu
        Invoke MUISetExtProperty, hControl, @TrayMenuHandleMenu, 0
    .ENDIF
    
    .IF dwMenuType == MUITMT_POPUPMENU
        ;PrintText 'MUITMT_POPUPMENU'
        .IF dwMenu != NULL
            Invoke MUISetExtProperty, hControl, @TrayMenuHandleMenu, dwMenu
            mov eax, TRUE
        .ELSE
            Invoke MUISetExtProperty, hControl, @TrayMenuHandleMenu, 0
            mov eax, FALSE
        .ENDIF
        ret        
    .ENDIF
    
    .IF dwMenuType == MUITMT_MENUITEMS
        ;PrintText 'MUITMT_MENUITEMS'
        .IF dwMenu == NULL
            mov eax, FALSE
            ret
        .ENDIF
        
        mov ebx, dwMenu
        mov eax, [ebx]
        .IF eax != 0F0FFFFFFh
            ;PrintDec eax
            mov eax, FALSE
            ret 
        .ENDIF
        
        mov ebx, dwMenu
        add ebx, 4d
        mov pTrayMenuItem, ebx
        
        invoke CreatePopupMenu  ; Create Tray Icon Popup Menu
        mov hTrayMenu, eax ; Save Tray Menu Popup Handle
        
        mov CurrentItem, 1
        
        mov eax, TRUE
        .WHILE eax == TRUE
            
            ; Fetch all items for menu item
            mov ebx, pTrayMenuItem
            mov eax, [ebx].TMITEM.MenuItemID
            mov MenuItemID, eax
            .IF MenuItemID == 0FFFFFFFFh
                ;IFDEF DEBUG32
                ;    PrintText 'Reached End of Menu Definition'
                ;ENDIF    
                .BREAK
            .ENDIF
            
            mov eax, [ebx].TMITEM.MenuItemType
            mov MenuItemType, eax
            mov eax, [ebx].TMITEM.MenuItemText
            mov MenuItemText, eax
            mov eax, [ebx].TMITEM.MenuItemState
            mov MenuItemState, eax
    
            mov mi.cbSize, SIZEOF MENUITEMINFO
            mov mi.fMask, MIIM_STRING + MIIM_FTYPE + MIIM_ID + MIIM_STATE
            mov mi.hSubMenu, NULL
            mov mi.hbmpChecked, NULL
            mov mi.hbmpUnchecked, NULL
            mov eax, MenuItemID
            mov mi.wID, eax
            ;PrintDec mi.wID
            mov eax, MenuItemType
            mov mi.fType, eax
            mov mi.cch, 0h
    
            ; decide how to create menu item based on the content found
            .IF MenuItemType == MF_STRING
                mov mi.fMask, MIIM_STRING + MIIM_FTYPE + MIIM_ID + MIIM_STATE
                mov eax, MenuItemState
                mov mi.fState, eax
                mov eax, MenuItemText
                mov mi.dwTypeData, eax
                Invoke InsertMenuItem, hTrayMenu, MenuItemID, FALSE, Addr mi
                
            .ELSEIF MenuItemType == MF_SEPARATOR
                mov mi.fMask, MIIM_FTYPE + MIIM_STATE
                mov mi.fState, MFS_ENABLED
                mov mi.dwTypeData, 0
                Invoke InsertMenuItem, hTrayMenu, CurrentItem, TRUE, Addr mi
                ;PrintDec CurrentItem
            .ENDIF
            
            add pTrayMenuItem, SIZEOF TMITEM
            inc CurrentItem
            mov eax, TRUE
        .ENDW
        
        .IF CurrentItem != 0
            Invoke MUISetExtProperty, hControl, @TrayMenuHandleMenu, hTrayMenu
        .ELSE
            Invoke DestroyMenu, hTrayMenu
            Invoke MUISetExtProperty, hControl, @TrayMenuHandleMenu, 0
        .ENDIF
    .ENDIF
    mov eax, TRUE
    ret
MUITrayMenuAssignMenu ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Changes a menu item's state
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuChangeMenuItemState PROC PUBLIC hControl:DWORD, MenuItemID:DWORD, MenuItemState:DWORD
    LOCAL mi:MENUITEMINFO
    LOCAL hTrayMenu:DWORD

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuHandleMenu
    mov hTrayMenu, eax

    .IF hTrayMenu != NULL       
        mov mi.cbSize, SIZEOF MENUITEMINFO
        mov mi.fMask, MIIM_STATE
        mov eax, MenuItemState
        mov mi.fState, eax
        Invoke SetMenuItemInfo, hTrayMenu, MenuItemID, FALSE, Addr mi
        .IF eax != 0
            mov eax, TRUE
        .ELSE
            mov eax, FALSE
        .ENDIF
    .ELSE
        mov eax, FALSE
    .ENDIF  
    ret

MUITrayMenuChangeMenuItemState endp


MUI_ALIGN
;------------------------------------------------------------------------------
; Enables a menu item on the tray menu
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuEnableMenuItem PROC PUBLIC hControl:DWORD, MenuItemID:DWORD
    LOCAL mi:MENUITEMINFO
    LOCAL hTrayMenu:DWORD

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuHandleMenu
    mov hTrayMenu, eax
    
    .IF hTrayMenu != NULL   
        mov mi.cbSize, SIZEOF MENUITEMINFO
        mov mi.fMask, MIIM_STATE
        mov mi.fState, MFS_ENABLED
        Invoke SetMenuItemInfo, hTrayMenu, MenuItemID, FALSE, Addr mi
        .IF eax != 0
            mov eax, TRUE
        .ELSE
            mov eax, FALSE
        .ENDIF
    .ELSE
        mov eax, FALSE
    .ENDIF         
    ret
MUITrayMenuEnableMenuItem ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Disables (greys out) a menu item on the tray menu. 
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuDisableMenuItem PROC PUBLIC hControl:DWORD, MenuItemID:DWORD
    LOCAL mi:MENUITEMINFO
    LOCAL hTrayMenu:DWORD

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuHandleMenu
    mov hTrayMenu, eax
    .IF hTrayMenu != NULL
        mov mi.cbSize, SIZEOF MENUITEMINFO
        mov mi.fMask, MIIM_STATE
        mov mi.fState, MFS_GRAYED
        Invoke SetMenuItemInfo, hTrayMenu, MenuItemID, FALSE, Addr mi
        .IF eax != 0
            mov eax, TRUE
        .ELSE
            mov eax, FALSE
        .ENDIF
    .ELSE
        mov eax, FALSE
    .ENDIF        
    ret
MUITrayMenuDisableMenuItem ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets the icon of the tray menu
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuSetTrayIcon PROC PUBLIC USES EBX hControl:DWORD, hTrayIcon:DWORD
    LOCAL NID:DWORD
    LOCAL lpszTooltip:DWORD

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @TrayMenuNID
    mov NID, eax
    .IF NID == NULL
        Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, SIZEOF NOTIFYICONDATA
        .IF eax == NULL
            mov eax, FALSE ; if we cant alloc mem, we return false and control isnt created.
            ret
        .ENDIF
        mov NID, eax
        
        Invoke MUISetIntProperty, hControl, @TrayMenuNID, NID       
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuTooltipText
    mov lpszTooltip, eax
    
    ; Fill NID structure with required info
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax    
    mov eax, WM_SHELLNOTIFY
    mov [ebx].NOTIFYICONDATA.uCallbackMessage, eax
    .IF hTrayIcon == NULL
        Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, FALSE
        Invoke GlobalFree, NID
        Invoke MUISetIntProperty, hControl, @TrayMenuNID, 0
        mov eax, FALSE
        ret
    .ENDIF
    Invoke MUISetExtProperty, hControl, @TrayMenuIcon, hTrayIcon
    
    mov ebx, NID
    mov eax, hTrayIcon
    mov [ebx].NOTIFYICONDATA.hIcon, eax
    .IF lpszTooltip != NULL
        mov eax,  NIF_ICON + NIF_MESSAGE + NIF_TIP
        mov [ebx].NOTIFYICONDATA.uFlags, eax    
        mov eax, lpszTooltip
        Invoke szLen, eax
        .IF eax != 0
            mov ebx, NID
            lea ebx, [ebx].NOTIFYICONDATA.szTip
            mov eax, lpszTooltip
            invoke szCopy, eax, ebx
        .ENDIF
    .ELSE
        mov eax,  NIF_ICON + NIF_MESSAGE
        mov [ebx].NOTIFYICONDATA.uFlags, eax    
    .ENDIF
    invoke Shell_NotifyIcon, NIM_MODIFY, NID ; Send msg to show icon in tray
    .IF eax != 0
        Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, TRUE
        mov eax, TRUE
    .ELSE
        Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, FALSE
        Invoke GlobalFree, NID
        Invoke MUISetIntProperty, hControl, @TrayMenuNID, 0
        mov eax, FALSE
    .ENDIF
    ret
MUITrayMenuSetTrayIcon endp


MUI_ALIGN
;------------------------------------------------------------------------------
; Set tooltip of the tray menu
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuSetTooltipText PROC PUBLIC USES EBX hControl:DWORD, lpszTooltip:DWORD
    LOCAL NID:DWORD
    LOCAL hTrayIcon:DWORD

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @TrayMenuNID
    mov NID, eax
    .IF NID == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuIcon
    mov hTrayIcon, eax
    
    ; Fill NID structure with required info
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax    
    mov eax, WM_SHELLNOTIFY
    mov [ebx].NOTIFYICONDATA.uCallbackMessage, eax
    .IF hTrayIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    mov ebx, NID
    mov eax, hTrayIcon
    mov [ebx].NOTIFYICONDATA.hIcon, eax
    .IF lpszTooltip != NULL
        mov eax,  NIF_ICON + NIF_MESSAGE + NIF_TIP
        mov [ebx].NOTIFYICONDATA.uFlags, eax    
        mov eax, lpszTooltip
        Invoke szLen, eax
        .IF eax != 0        
            mov ebx, NID
            lea ebx, [ebx].NOTIFYICONDATA.szTip
            mov eax, lpszTooltip
            invoke szCopy, eax, ebx
        .ENDIF
        Invoke MUISetExtProperty, hControl, @TrayMenuTooltipText, lpszTooltip
    .ELSE
        mov eax,  NIF_ICON + NIF_MESSAGE
        mov [ebx].NOTIFYICONDATA.uFlags, eax    
    .ENDIF
    invoke Shell_NotifyIcon, NIM_MODIFY, NID ; Send msg to show icon in tray
    .IF eax != 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret

MUITrayMenuSetTooltipText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Returns in eax icon created and set as the tray menu icon. Use DeleteObject once finished
; using this icon, and before calling this function again (if icon was previously created
; with this function)
; Returns in eax hIcon or NULL
;------------------------------------------------------------------------------
MUITrayMenuSetTrayIconText PROC PUBLIC hControl:DWORD, lpszText:DWORD, lpszFont:DWORD, dwTextColorRGB:DWORD
    LOCAL hTrayIcon:DWORD

    .IF hControl == NULL
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke _MUI_TM_IconText, lpszText, lpszFont, dwTextColorRGB
    mov hTrayIcon, eax
    
    .IF hTrayIcon == NULL
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke MUITrayMenuSetTrayIcon, hControl, hTrayIcon
    
    mov eax, hTrayIcon
    ret
MUITrayMenuSetTrayIconText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
;
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuHideTrayIcon PROC PUBLIC hControl:DWORD
    LOCAL NID:DWORD

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @TrayMenuIconVisible
    .IF eax == TRUE
        Invoke MUIGetIntProperty, hControl, @TrayMenuNID
        mov NID, eax
        .IF NID != NULL
            Invoke Shell_NotifyIcon, NIM_DELETE, NID ; Remove tray icon
            Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, FALSE
            Invoke GlobalFree, NID
            Invoke MUISetIntProperty, hControl, @TrayMenuNID, 0
            mov eax, TRUE
            ret
        .ENDIF
        mov eax, FALSE
    .ELSE
        mov eax, TRUE
    .ENDIF
    ret
MUITrayMenuHideTrayIcon ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
;
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuShowTrayIcon PROC PUBLIC hControl:DWORD
    LOCAL hParent:DWORD
    LOCAL hTrayIcon:DWORD
    LOCAL lpszTooltip:DWORD

    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF

    Invoke MUIGetIntProperty, hControl, @TrayMenuIconVisible
    .IF eax == FALSE
    
        Invoke MUIGetExtProperty, hControl, @TrayMenuIcon
        mov hTrayIcon, eax
        .IF hTrayIcon == NULL
            mov eax, FALSE
            ret
        .ENDIF
    
        Invoke MUIGetExtProperty, hControl, @TrayMenuTooltipText
        mov lpszTooltip, eax
        .IF lpszTooltip == NULL
            mov eax, FALSE
            ret
        .ENDIF
        
        Invoke MUIGetIntProperty, hControl, @TrayParent
        mov hParent, eax
        
        ;Invoke GetParent, hControl
        ;mov hParent, eax
        Invoke _MUI_TM_AddIconAndTooltip, hControl, hParent, hTrayIcon, lpszTooltip
        
        Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, TRUE
    .ENDIF

    mov eax, TRUE
    ret
MUITrayMenuShowTrayIcon ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Show a balloon style tooltip over tray menu with custom information
;
; MUITMNI_NONE           EQU 0 ; No icon.
; MUITMNI_INFO           EQU 1 ; An information icon.
; MUITMNI_WARNING        EQU 2 ; A warning icon.
; MUITMNI_ERROR          EQU 3 ; An error icon.
; MUITMNI_USER           EQU 4 ; Windows XP: Use the icon identified in hIcon as the notification balloon's title icon
;
;
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayMenuShowNotification PROC PUBLIC USES EBX hControl:DWORD, lpszNotificationMessage:DWORD, lpszNotificationTitle:DWORD, dwTimeout:DWORD, dwStyle:DWORD
    LOCAL hTrayIcon:DWORD
    LOCAL NID:DWORD
    
    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuIcon
    mov hTrayIcon, eax
    .IF hTrayIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF  
    
    Invoke MUIGetIntProperty, hControl, @TrayMenuNID
    mov NID, eax
    .IF NID == NULL
        mov eax, FALSE ; if we cant alloc mem, we return false and control isnt created.
        ret
    .ENDIF
    
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax
    mov eax,  NIF_ICON + NIF_MESSAGE + NIF_INFO + NIF_TIP
    mov [ebx].NOTIFYICONDATA.uFlags, eax
    mov eax, WM_SHELLNOTIFY
    mov [ebx].NOTIFYICONDATA.uCallbackMessage, eax
    .IF dwTimeout == NULL
        mov eax, 3000d
    .ELSE
        mov eax, dwTimeout
    .ENDIF
    mov [ebx].NOTIFYICONDATA.uTimeout, eax
    mov eax, NOTIFYICON_VERSION
    mov [ebx].NOTIFYICONDATA.uVersion, eax
    .IF dwStyle == NULL
        mov eax, MUITMNI_INFO
    .ELSE
        mov eax, dwStyle
    .ENDIF
    mov [ebx].NOTIFYICONDATA.dwInfoFlags, eax ;TMNI_INFO ; Balloon Style
    
    mov eax, hTrayIcon
    mov [ebx].NOTIFYICONDATA.hIcon, eax ; Save handle of icon
    
    .IF lpszNotificationMessage != NULL
        Invoke szLen, lpszNotificationMessage
        .IF eax != 0
            mov ebx, NID
            mov eax, lpszNotificationMessage
            lea ebx, [ebx].NOTIFYICONDATA.szInfo
            ;invoke szCopy, eax, ebx       
            Invoke lstrcpyn, ebx, eax, 256d     
        .ENDIF
    .ENDIF
    
    .IF lpszNotificationTitle != NULL
        Invoke szLen, lpszNotificationTitle
        .IF eax != 0
            mov ebx, NID
            mov eax, lpszNotificationTitle
            lea ebx, [ebx].NOTIFYICONDATA.szInfoTitle
            ;invoke szCopy, eax, ebx     
            Invoke lstrcpyn, ebx, eax, 64d       
        .ENDIF        
    .ENDIF

    invoke Shell_NotifyIcon, NIM_MODIFY, NID ; Send msg to show icon in tray
    
    .IF dwTimeout == NULL
        Invoke KillTimer, hControl, hControl
        Invoke SetTimer, hControl, hControl, 3000d, NULL
    .ELSE
        Invoke KillTimer, hControl, hControl
        Invoke SetTimer, hControl, hControl, dwTimeout, NULL
    .ENDIF
    
    mov eax, TRUE
    ret

MUITrayMenuShowNotification ENDP


;==============================================================================
; TRAY ICON Functions
;==============================================================================


MUI_ALIGN
;------------------------------------------------------------------------------
; Creates a tray icon and tooltip text. Standalone without any menu
; Returns in eax hTI (handle of TrayIcon = NID)
;------------------------------------------------------------------------------
MUITrayIconCreate PROC PUBLIC USES EBX hWndParent:DWORD, dwTrayIconResID:DWORD, hTrayIcon:DWORD, lpszTooltip:DWORD
    LOCAL NID:DWORD

    IFDEF DEBUG32
        PrintText 'TrayIconCreate'
    ENDIF
    mov eax, SIZEOF NOTIFYICONDATA
    add eax, 4d
    
    Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, eax ;SIZEOF NOTIFYICONDATA
    .IF eax == NULL
        mov eax, NULL ; if we cant alloc mem, we return null and icon isnt created.
        ret
    .ENDIF
    mov NID, eax
    
    mov ebx, NID
    add ebx, SIZEOF NOTIFYICONDATA
    mov eax, hWndParent
    mov [ebx], eax
    
    ; Fill NID structure with required info
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax
    mov eax, hWndParent
    mov [ebx].NOTIFYICONDATA.hWnd, eax  
    

    mov eax, dwTrayIconResID ; use hControl has unique id for each tryamenu icon ; dwTrayMenuResID
    mov [ebx].NOTIFYICONDATA.uID, eax ; Tray ID
    mov eax,  NIF_ICON + NIF_TIP
    mov [ebx].NOTIFYICONDATA.uFlags, eax
    ;mov eax, WM_SHELLNOTIFY
    ;mov [ebx].NOTIFYICONDATA.uCallbackMessage, eax
    ;.IF hTrayIcon == NULL
    ;    .IF NID != NULL
    ;        Invoke GlobalFree, NID
    ;    .ENDIF    
    ;    mov eax, NULL
    ;    ret
    ;.ENDIF
    
    .IF hTrayIcon == NULL
        Invoke MUICreateIconFromMemory, Addr icoMUITrayBlankIcon, 0
    .ELSE
        mov eax, hTrayIcon
    .ENDIF
    
    mov ebx, NID
    mov [ebx].NOTIFYICONDATA.hIcon, eax
    mov eax, lpszTooltip
    .IF eax != NULL
        ;PrintText 'szLen'
        Invoke szLen, eax
        .IF eax != 0
            ;PrintText 'szCopy'
            mov ebx, NID
            lea ebx, [ebx].NOTIFYICONDATA.szTip
            mov eax, lpszTooltip
            invoke szCopy, eax, ebx
        .ENDIF
    .ENDIF
    
    ;PrintText 'Shell_NotifyIcon'
    invoke Shell_NotifyIcon, NIM_ADD, NID ; Send msg to show icon in tray
    .IF eax != 0
        mov eax, NID
    .ELSE
        .IF NID != NULL
            Invoke GlobalFree, NID
        .ENDIF
        mov eax, NULL
    .ENDIF
    ret


MUITrayIconCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUITrayIconDestroy
;------------------------------------------------------------------------------
MUITrayIconDestroy PROC hTI:DWORD
    LOCAL NID:DWORD
    
    mov eax, hTI
    mov NID, eax
    
    .IF NID != NULL
        Invoke Shell_NotifyIcon, NIM_DELETE, NID ; Remove tray icon
    .ENDIF

    .IF NID != NULL
        Invoke GlobalFree, NID
    .ENDIF    

    mov eax, TRUE
    ret

MUITrayIconDestroy ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUITrayIconSetTrayIcon
;------------------------------------------------------------------------------
MUITrayIconSetTrayIcon PROC USES EBX hTI:DWORD, hTrayIcon:DWORD
    LOCAL NID:DWORD
    LOCAL hWndParent:DWORD
    
    .IF hTI == NULL
        mov eax, FALSE
        ret
    .ENDIF
    .IF hTrayIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    mov eax, hTI
    mov NID, eax

    mov ebx, NID
    add ebx, SIZEOF NOTIFYICONDATA
    mov eax, [ebx]  
    mov hWndParent, eax

    ; Fill NID structure with required info
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax    
    mov eax, hWndParent
    mov [ebx].NOTIFYICONDATA.hWnd, eax      
    mov eax, hTrayIcon
    mov [ebx].NOTIFYICONDATA.hIcon, eax
    mov eax, NIF_ICON
    mov [ebx].NOTIFYICONDATA.uFlags, eax    
    invoke Shell_NotifyIcon, NIM_MODIFY, NID ; Send msg to show icon in tray
    .IF eax != 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret

MUITrayIconSetTrayIcon ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUITrayIconSetTooltipText
;------------------------------------------------------------------------------
MUITrayIconSetTooltipText PROC USES EBX hTI:DWORD, lpszTooltip:DWORD
    LOCAL NID:DWORD
    LOCAL hWndParent:DWORD
    
    .IF hTI == NULL
        mov eax, FALSE
        ret
    .ENDIF
    .IF lpszTooltip == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    mov eax, hTI
    mov NID, eax

    mov ebx, NID
    add ebx, SIZEOF NOTIFYICONDATA
    mov eax, [ebx]  
    mov hWndParent, eax

    ; Fill NID structure with required info
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax    
    mov eax, hWndParent
    mov [ebx].NOTIFYICONDATA.hWnd, eax      
    mov eax, NIF_TIP
    mov [ebx].NOTIFYICONDATA.uFlags, eax    
        
    .IF lpszTooltip != NULL
        mov eax, lpszTooltip
        Invoke szLen, eax
        .IF eax != 0        
            mov ebx, NID
            lea ebx, [ebx].NOTIFYICONDATA.szTip
            mov eax, lpszTooltip
            invoke szCopy, eax, ebx
        .ELSE
            mov eax, FALSE
            ret
        .ENDIF
    .ENDIF
    
    invoke Shell_NotifyIcon, NIM_MODIFY, NID ; Send msg to show icon in tray
    .IF eax != 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    
    ret

MUITrayIconSetTooltipText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Show a balloon style tooltip over tray icon with custom information
;
; MUITMNI_NONE           EQU 0 ; No icon.
; MUITMNI_INFO           EQU 1 ; An information icon.
; MUITMNI_WARNING        EQU 2 ; A warning icon.
; MUITMNI_ERROR          EQU 3 ; An error icon.
; MUITMNI_USER           EQU 4 ; Windows XP: Use the icon identified in hIcon as the notification balloon's title icon
;
;
; Returns in eax TRUE of succesful or FALSE otherwise.
;------------------------------------------------------------------------------
MUITrayIconShowNotification PROC USES EBX hTI:DWORD, lpszNotificationMessage:DWORD, lpszNotificationTitle:DWORD, dwTimeout:DWORD, dwStyle:DWORD
    LOCAL NID:DWORD
    LOCAL hWndParent:DWORD
    LOCAL lenMessage:DWORD
    
    .IF hTI == NULL
        mov eax, FALSE
        ret
    .ENDIF
    .IF lpszNotificationMessage == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    mov eax, hTI
    mov NID, eax
    
    mov ebx, NID
    add ebx, SIZEOF NOTIFYICONDATA
    mov eax, [ebx]  
    mov hWndParent, eax
    
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax
    mov eax, hWndParent
    mov [ebx].NOTIFYICONDATA.hWnd, eax  
    mov eax, NIF_INFO + NIF_TIP
    mov [ebx].NOTIFYICONDATA.uFlags, eax

    .IF dwTimeout == NULL
        mov eax, 3000d
    .ELSE
        mov eax, dwTimeout
    .ENDIF
    mov [ebx].NOTIFYICONDATA.uTimeout, eax
    mov eax, NOTIFYICON_VERSION
    mov [ebx].NOTIFYICONDATA.uVersion, eax
    .IF dwStyle == NULL
        mov eax, MUITMNI_INFO
    .ELSE
        mov eax, dwStyle
    .ENDIF
    mov [ebx].NOTIFYICONDATA.dwInfoFlags, eax ;TMNI_INFO ; Balloon Style
    
    .IF lpszNotificationMessage != NULL
        Invoke szLen, lpszNotificationMessage
        mov lenMessage, eax
        .IF eax != 0
            mov ebx, NID
            mov eax, lpszNotificationMessage
            lea ebx, [ebx].NOTIFYICONDATA.szInfo
            ;invoke szCopy, eax, ebx          
            Invoke lstrcpyn, ebx, eax, 256d  
            
            .IF lenMessage > 252d
                mov ebx, NID
                lea eax, [ebx].NOTIFYICONDATA.szInfo
                add eax, 252d
                mov byte ptr [eax], "."
                mov byte ptr [eax+1], "."
                mov byte ptr [eax+2], "."
                mov byte ptr [eax+3], 0
            .ENDIF
            
        .ENDIF
    .ENDIF
    
    .IF lpszNotificationTitle != NULL
        Invoke szLen, lpszNotificationTitle
        .IF eax != 0
            mov ebx, NID
            mov eax, lpszNotificationTitle
            lea ebx, [ebx].NOTIFYICONDATA.szInfoTitle
            ;invoke szCopy, eax, ebx     
            Invoke lstrcpyn, ebx, eax, 64d       
        .ENDIF        
    .ENDIF

    invoke Shell_NotifyIcon, NIM_MODIFY, NID ; Send msg to show icon in tray
    
    mov eax, TRUE
    ret

MUITrayIconShowNotification ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Returns in eax icon created and set as the tray menu icon. Use DeleteObject once finished
; using this icon, and before calling this function again (if icon was previously created
; with this function)
; Returns in eax hIcon or NULL
;------------------------------------------------------------------------------
MUITrayIconSetTrayIconText PROC PUBLIC hControl:DWORD, lpszText:DWORD, lpszFont:DWORD, dwTextColorRGB:DWORD
    LOCAL hTrayIcon:DWORD

    .IF hControl == NULL
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke _MUI_TM_IconText, lpszText, lpszFont, dwTextColorRGB
    mov hTrayIcon, eax
    
    .IF hTrayIcon == NULL
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke MUITrayIconSetTrayIcon, hControl, hTrayIcon
    
    mov eax, hTrayIcon
    ret
MUITrayIconSetTrayIconText ENDP



;==============================================================================
; Internal Functions
;==============================================================================


MUI_ALIGN
;------------------------------------------------------------------------------
; Adds tray menu icon and tooltip text. Called from TrayMenuCreate
;------------------------------------------------------------------------------
_MUI_TM_AddIconAndTooltip PROC PRIVATE USES EBX hControl:DWORD, hWndParent:DWORD, hTrayMenuIcon:DWORD, lpszTooltip:DWORD
    LOCAL NID:DWORD

    IFDEF DEBUG32
        PrintText 'TM_AddIconAndTooltip'
    ENDIF

    Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, SIZEOF NOTIFYICONDATA
    .IF eax == NULL
        mov eax, FALSE ; if we cant alloc mem, we return false and control isnt created.
        ret
    .ENDIF
    mov NID, eax
    
    
    Invoke MUISetIntProperty, hControl, @TrayMenuNID, NID
    
    ;PrintText '_SetNID'
    
    ; Fill NID structure with required info
    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax
    mov eax, hWndParent
    mov [ebx].NOTIFYICONDATA.hWnd, eax
;   .IF dwTrayMenuResID == NULL
;       mov eax, FALSE
;       ret
;   .ENDIF
    ;PrintText 'dwTrayMenuResID'
    mov eax, hControl ; use hControl has unique id for each tryamenu icon ; dwTrayMenuResID
    mov [ebx].NOTIFYICONDATA.uID, eax ; Tray ID
    mov eax,  NIF_ICON + NIF_MESSAGE + NIF_TIP
    mov [ebx].NOTIFYICONDATA.uFlags, eax
    mov eax, WM_SHELLNOTIFY
    mov [ebx].NOTIFYICONDATA.uCallbackMessage, eax

;    .IF hTrayMenuIcon == NULL
;        Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, FALSE
;        Invoke GlobalFree, NID
;        Invoke MUISetIntProperty, hControl, @TrayMenuNID, 0
;        mov eax, FALSE
;        ret
;    .ENDIF

    .IF hTrayMenuIcon == NULL
        Invoke MUICreateIconFromMemory, Addr icoMUITrayBlankIcon, 0
    .ELSE
        mov eax, hTrayMenuIcon
    .ENDIF
    
    mov ebx, NID    
    mov [ebx].NOTIFYICONDATA.hIcon, eax
    mov eax, lpszTooltip
    .IF eax != NULL
        ;PrintText 'szLen'
        Invoke szLen, eax
        .IF eax != 0
            ;PrintText 'szCopy'
            mov ebx, NID
            lea ebx, [ebx].NOTIFYICONDATA.szTip
            mov eax, lpszTooltip
            invoke szCopy, eax, ebx
        .ENDIF
    .ENDIF
    ;PrintText 'Shell_NotifyIcon'
    
    invoke Shell_NotifyIcon, NIM_ADD, NID ; Send msg to show icon in tray
    .IF eax != 0
        Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, TRUE
        mov eax, TRUE
    .ELSE
        Invoke MUISetIntProperty, hControl, @TrayMenuIconVisible, FALSE
        Invoke GlobalFree, NID
        Invoke MUISetIntProperty, hControl, @TrayMenuNID, 0
        mov eax, FALSE
    .ENDIF
    ret

_MUI_TM_AddIconAndTooltip ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Shows the main window if minimized when right clicking on tray menu icon
;------------------------------------------------------------------------------
_MUI_TM_ShowTrayMenu PROC PRIVATE hWin:DWORD, hControl:DWORD
    LOCAL TrayMenuPoint:POINT
    LOCAL hTrayMenu:DWORD

    IFDEF DEBUG32
        PrintText 'TM_ShowTrayMenu'
    ENDIF
    
    Invoke MUIGetExtProperty, hControl, @TrayMenuHandleMenu
    mov hTrayMenu, eax

    .IF hTrayMenu == NULL
        ret
    .ENDIF
    
    ;Invoke _MUI_TM_RestoreFromTray, hWin, hControl
    
    Invoke GetCursorPos, Addr TrayMenuPoint ;lpdwTrayMenuPoint
    ; Focus Main Window - ; Fix for shortcut menu not popping up right
    Invoke SetForegroundWindow, hWin
    Invoke TrackPopupMenu, hTrayMenu, TPM_RIGHTALIGN + TPM_LEFTBUTTON + TPM_RIGHTBUTTON, TrayMenuPoint.x, TrayMenuPoint.y, NULL, hWin, NULL
    Invoke PostMessage, hWin, WM_NULL, 0, 0 ; Fix for shortcut menu not popping up right
    ret
_MUI_TM_ShowTrayMenu ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Restore the application from the tray when left clicking on tray menu icon
;------------------------------------------------------------------------------
_MUI_TM_RestoreFromTray PROC PRIVATE hWin:DWORD, hControl:DWORD
    LOCAL hParent:DWORD
    LOCAL hWndExtra:DWORD
    LOCAL dwStyle:DWORD
    LOCAL wp:WINDOWPLACEMENT
    IFDEF DEBUG32
        PrintText 'TM_RestoreFromTray'
    ENDIF

    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax

    Invoke MUIGetExtProperty, hControl, @TrayMenuExtraWndHandle
    .IF eax != NULL
        mov hParent, eax
        mov hWndExtra, eax
    .ELSE
        mov hParent, 0
        mov hWndExtra, 0
    .ENDIF
    ;PrintDec hWndExtra


    
    ; 20/02/2018 - added to process only hwndextra handle as the main window to process for show/hide only
    ;PrintDec dwStyle 
    mov eax, dwStyle
    and eax, MUITMS_HWNDEXTRA
    .IF eax == MUITMS_HWNDEXTRA
        ;PrintText 'MUITMS_HWNDEXTRA'
        .IF hWndExtra != 0
            ;PrintText 'Show Window'
            invoke ShowWindow, hWndExtra, SW_SHOW 
        .ENDIF
    .ELSE

        ; 22/07/2016 - added to show parent window first if TM is used with a child dialog (x64dbg plugins Snapshot UpdateChecker as an example)
        .IF hParent != 0
            Invoke GetWindowPlacement, hParent, Addr wp
            mov eax, wp.showCmd
            .IF eax == SW_SHOWMINIMIZED
                invoke ShowWindow, hParent, SW_RESTORE
            
            .ELSEIF eax == SW_HIDE
                invoke ShowWindow, hParent, SW_SHOW
            
            .ENDIF
            Invoke SetForegroundWindow, hParent ; Focus main window
            Invoke SetWindowPos, hParent, HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW
        .ENDIF
    
        Invoke IsWindowVisible, hWin
        .IF eax == 0
            invoke ShowWindow, hWin, SW_SHOW    
            invoke ShowWindow, hWin, SW_SHOWNORMAL  
            Invoke SetForegroundWindow, hWin ; Focus main window
            ret
        .ENDIF
        Invoke IsIconic, hWin
        .IF eax != 0
            invoke ShowWindow, hWin, SW_SHOW    
            invoke ShowWindow, hWin, SW_SHOWNORMAL  
            Invoke SetForegroundWindow, hWin ; Focus main window
        .ENDIF
    .ENDIF
    ret
_MUI_TM_RestoreFromTray ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Minimize to Tray - Called from WM_SIZE (wParam==SIZE_MINIMIZED) in sublclass
;------------------------------------------------------------------------------
_MUI_TM_MinimizeToTray PROC PUBLIC hWin:DWORD, dwHideWindow:DWORD
    Invoke ShowWindow, hWin, SW_MINIMIZE
    
    .IF dwHideWindow == TRUE   
        invoke ShowWindow, hWin, SW_HIDE ; Hide main window
    .ENDIF
    ret
_MUI_TM_MinimizeToTray  ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Hides Notification After Timeout value has passed
;------------------------------------------------------------------------------
_MUI_TM_HideNotification PROC PRIVATE USES EBX hControl:DWORD
    LOCAL NID:DWORD
    
    .IF hControl == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @TrayMenuNID
    mov NID, eax
    .IF NID == NULL
        mov eax, FALSE ; if we cant alloc mem, we return false and control isnt created.
        ret
    .ENDIF

    mov ebx, NID
    mov eax, sizeof NOTIFYICONDATA
    mov [ebx].NOTIFYICONDATA.cbSize, eax
    mov eax,  NIF_INFO
    mov [ebx].NOTIFYICONDATA.uFlags, eax
    lea eax, [ebx].NOTIFYICONDATA.szInfo
    mov byte ptr [eax], 0h
    invoke Shell_NotifyIcon, NIM_MODIFY, NID ; Send msg to show icon in tray
    
    mov eax, TRUE
    ret

_MUI_TM_HideNotification ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Create Transparent Text Icon For Traybar
; Original sourcecode: http://www.techpowerup.com/forums/showthread.php?t=141783
;
; Returns handle to an icon (cursor) in eax, use DeleteObject to free this when 
; you have finished with it
;------------------------------------------------------------------------------
_MUI_TM_IconText PROC PRIVATE lpszText:DWORD, lpszFont:DWORD, dwTextColorRGB:DWORD
    ;// Creates a DC for use in multithreaded programs (works in single threaded as well)
    LOCAL hdc:HDC
    LOCAL hMemDC:HDC
    LOCAL hdcMem2:HDC
    LOCAL hBitmap:DWORD
    LOCAL hBitmapOld:DWORD    
    LOCAL hbmMask:DWORD
    LOCAL hbmMaskOld:DWORD
    LOCAL hAphaCursor:HICON
    LOCAL cbox:RECT
    LOCAL hbrBkgnd:HBRUSH
    LOCAL lentext:DWORD
    LOCAL ii:ICONINFO
    LOCAL hAlphaCursor:DWORD
    LOCAL hFont:DWORD
    LOCAL hFontOld:DWORD

    
    Invoke lstrlen, lpszText
    mov lentext, eax
    
    ;// Only safe way I could find to make a DC for multithreading
    Invoke CreateDC, Addr szMUITrayIconDisplayDC, NULL,NULL,NULL
    mov hdc, eax

    ;// Makes it easier to center the text
    mov cbox.left, 0
    mov cbox.top, 0
    mov cbox.right, 16
    mov cbox.bottom, 16
    
    ;// Create the text bitmap.
    Invoke CreateCompatibleBitmap, hdc, cbox.right, cbox.bottom
    mov hBitmap, eax
    Invoke CreateCompatibleDC, hdc
    mov hMemDC, eax
    Invoke SelectObject, hMemDC, hBitmap
    mov hBitmapOld, eax

    ;// Draw the text bitmap
    Invoke CreateSolidBrush, MUI_RGBCOLOR(72,72,72) ;RGBCOLOR(0,0,0) 
    mov hbrBkgnd, eax
    Invoke FillRect, hMemDC, Addr cbox, hbrBkgnd
    Invoke DeleteObject, hbrBkgnd
    ;Invoke GetStockObject, DEFAULT_GUI_FONT
    .IF lpszFont == NULL
        lea eax, szMUITrayMenuFont
    .ELSE
        mov eax, lpszFont
    .ENDIF
    Invoke CreateFont, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, eax ;CTEXT("Segoe UI")
    mov hFont, eax
    Invoke SelectObject, hMemDC, hFont
    mov hFontOld, eax    
    
    
    ;Invoke SelectObject, hMemDC, eax
    Invoke SetBkColor, hMemDC, MUI_RGBCOLOR(72,72,72) ;RGBCOLOR(0,0,0)
    Invoke SetTextColor, hMemDC, dwTextColorRGB ;RGBCOLOR(118,198,238) ;RGBCOLOR(255,255,255)
    Invoke DrawText, hMemDC, lpszText, lentext, Addr cbox, DT_SINGLELINE or DT_VCENTER or DT_CENTER
    
    ;// Create monochrome (1 bit) mask bitmap.
    Invoke CreateBitmap, cbox.right, cbox.bottom, 1, 1, NULL
    mov hbmMask, eax
    Invoke CreateCompatibleDC, 0
    mov hdcMem2, eax
    Invoke SelectObject, hdcMem2, hbmMask
    mov hbmMaskOld, eax

    ;// Draw transparent color and create the mask
    Invoke SetBkColor, hMemDC, MUI_RGBCOLOR(72,72,72) ;RGBCOLOR(0,0,0)
    Invoke BitBlt, hdcMem2, 0, 0, cbox.right, cbox.bottom, hMemDC, 0, 0, SRCCOPY
    
    ;// Clean up
    Invoke DeleteDC, hdcMem2
    Invoke DeleteDC, hMemDC
    Invoke DeleteDC, hdc    
    
    mov ii.fIcon, TRUE
    mov ii.xHotspot, 0
    mov ii.yHotspot, 0
    mov eax, hbmMask
    mov ii.hbmMask, eax
    mov eax, hBitmap
    mov ii.hbmColor, eax

    ;// Create the icon with transparent background
    Invoke CreateIconIndirect, Addr ii
    mov hAlphaCursor, eax

    Invoke DeleteObject, hFont
    Invoke DeleteObject, hFontOld
    Invoke DeleteObject, hBitmap
    Invoke DeleteObject, hbmMask
    Invoke DeleteObject, hbmMaskOld
    Invoke DeleteObject, hbrBkgnd

;    ;Invoke SelectObject, hdcMem2, hbmMaskOld ; deselect mask
;    ;Invoke DeleteObject, eax
;    Invoke DeleteObject, hbmMask
;    Invoke DeleteDC, hdcMem2    
;    
;    ;Invoke SelectObject, hMemDC, hBitmapOld ; deselect bitmap
;    ;Invoke DeleteObject, eax
;    ;Invoke SelectObject, hMemDC, hFontOld ; deselect font
;    ;Invoke DeleteObject, eax
;    Invoke DeleteDC, hMemDC
;    Invoke DeleteObject, hBitmap
;    Invoke DeleteObject, hFont
;    Invoke DeleteObject, hbrBkgnd
;    Invoke DeleteObject, hbmMaskOld
;    Invoke DeleteObject, hBitmapOld
;    Invoke DeleteObject, hFontOld
;    Invoke DeleteDC, hdc

    mov eax, hAlphaCursor
    ret

_MUI_TM_IconText ENDP





























END
