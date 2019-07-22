TrayMenuInit            PROTO :DWORD
TrayMenuSelection       PROTO :DWORD,:DWORD
TrayMenuUpdate          PROTO :DWORD

.CONST
IDM_TM_FIRST            EQU 20001

IDM_TM_RESTORE          EQU 20001
IDM_TM_HIDE             EQU 20002
IDM_TM_ABOUT            EQU 20003
IDM_TM_EXIT             EQU 20004

IDM_TM_ICONS            EQU 20005
IDM_TM_ICONCPU          EQU 20006
IDM_TM_ICONMEM          EQU 20007

IDM_TM_RESPONSECPU      EQU 20008
IDM_TM_CPU05            EQU 20009
IDM_TM_CPU10            EQU 20010
IDM_TM_CPU20            EQU 20011
IDM_TM_CPU30            EQU 20012
IDM_TM_CPU50            EQU 20013

IDM_TM_RESPONSEMEM      EQU 20014
IDM_TM_MEM2             EQU 20015
IDM_TM_MEM5             EQU 20016
IDM_TM_MEM10            EQU 20017
IDM_TM_MEM20            EQU 20018
IDM_TM_MEM30            EQU 20019

IDM_TM_LAST             EQU 20100

.DATA
szAppTooltip            DB 'TrayInfo',0
szTMRestore             DB '&Restore',0
szTMHide                DB '&Hide',0

szTMIcons               DB "Tray Icons",0
szTMIconCPU             DB "CPU Load",0
szTMIconMEM             DB "Memory Load",0

szTMResponseCPU         DB "CPU Load Response",0
szTMCPU05               DB ".5 Seconds",0
szTMCPU10               DB "1 Second",0
szTMCPU20               DB "2 Seconds",0
szTMCPU30               DB "3 Seconds",0
szTMCPU50               DB "5 Seconds",0

szTMResponseMEM         DB "Memory Load Response",0
szTMMEM2                DB "2 Seconds",0
szTMMEM5                DB "5 Seconds",0
szTMMEM10               DB "10 Seconds",0
szTMMEM20               DB "20 Seconds",0
szTMMEM30               DB "30 Seconds",0

szTMAbout               DB '&About',0
szTMExit                DB '&Exit',0

.CODE

;-------------------------------------------------------------------------------------
; Init tray menu
;-------------------------------------------------------------------------------------
TrayMenuInit PROC hWin:DWORD
    Invoke CreatePopupMenu
    mov hTrayMenu, eax

    Invoke CreatePopupMenu
    mov hTMSubMenuIcons, eax
	Invoke AppendMenu, hTMSubMenuIcons, MF_STRING, IDM_TM_ICONCPU, Addr szTMIconCPU
	Invoke AppendMenu, hTMSubMenuIcons, MF_STRING, IDM_TM_ICONMEM, Addr szTMIconMEM

    Invoke CreatePopupMenu
    mov hTMSubMenuResponseCPU, eax
    Invoke AppendMenu, hTMSubMenuResponseCPU, MF_STRING, IDM_TM_CPU05, Addr szTMCPU05
	Invoke AppendMenu, hTMSubMenuResponseCPU, MF_STRING, IDM_TM_CPU10, Addr szTMCPU10
	Invoke AppendMenu, hTMSubMenuResponseCPU, MF_STRING, IDM_TM_CPU20, Addr szTMCPU20
	Invoke AppendMenu, hTMSubMenuResponseCPU, MF_STRING, IDM_TM_CPU30, Addr szTMCPU30
	Invoke AppendMenu, hTMSubMenuResponseCPU, MF_STRING, IDM_TM_CPU50, Addr szTMCPU50

    Invoke CreatePopupMenu
    mov hTMSubMenuResponseMEM, eax
    Invoke AppendMenu, hTMSubMenuResponseMEM, MF_STRING, IDM_TM_MEM2, Addr szTMMEM2
	Invoke AppendMenu, hTMSubMenuResponseMEM, MF_STRING, IDM_TM_MEM5, Addr szTMMEM5
	Invoke AppendMenu, hTMSubMenuResponseMEM, MF_STRING, IDM_TM_MEM10, Addr szTMMEM10
	Invoke AppendMenu, hTMSubMenuResponseMEM, MF_STRING, IDM_TM_MEM20, Addr szTMMEM20
	Invoke AppendMenu, hTMSubMenuResponseMEM, MF_STRING, IDM_TM_MEM30, Addr szTMMEM30

    Invoke AppendMenu, hTrayMenu, MF_STRING or MF_ENABLED, IDM_TM_RESTORE, Addr szTMRestore
    Invoke AppendMenu, hTrayMenu, MF_STRING or MF_ENABLED, IDM_TM_HIDE, Addr szTMHide
	Invoke AppendMenu, hTrayMenu, MF_SEPARATOR, 0, 0
	Invoke AppendMenu, hTrayMenu, MF_POPUP, hTMSubMenuIcons, Addr szTMIcons
	Invoke AppendMenu, hTrayMenu, MF_SEPARATOR, 0, 0
	Invoke AppendMenu, hTrayMenu, MF_POPUP, hTMSubMenuResponseCPU, Addr szTMResponseCPU
	Invoke AppendMenu, hTrayMenu, MF_POPUP, hTMSubMenuResponseMEM, Addr szTMResponseMEM
    Invoke AppendMenu, hTrayMenu, MF_SEPARATOR, 0, 0
    ;Invoke AppendMenu, hTrayMenu, MF_STRING or MF_ENABLED, IDM_TM_ABOUT, Addr szTMAbout
    ;Invoke AppendMenu, hTrayMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hTrayMenu, MF_STRING or MF_ENABLED, IDM_TM_EXIT, Addr szTMExit
    Invoke AppendMenu, hTrayMenu, MF_SEPARATOR, 0, 0

    ; load bitmaps
    Invoke SetMenuItemBitmaps, hTrayMenu, IDM_TM_RESTORE, MF_BYCOMMAND, hBmpShow, 0
    Invoke SetMenuItemBitmaps, hTrayMenu, IDM_TM_HIDE, MF_BYCOMMAND, hBmpHide, 0

;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseCPU, IDM_TM_CPU05, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseCPU, IDM_TM_CPU10, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseCPU, IDM_TM_CPU20, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseCPU, IDM_TM_CPU30, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseCPU, IDM_TM_CPU50, MF_BYCOMMAND, hBmpTime, 0
;    
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseMEM, IDM_TM_MEM2, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseMEM, IDM_TM_MEM5, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseMEM, IDM_TM_MEM10, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseMEM, IDM_TM_MEM20, MF_BYCOMMAND, hBmpTime, 0
;    Invoke SetMenuItemBitmaps, hTMSubMenuResponseMEM, IDM_TM_MEM30, MF_BYCOMMAND, hBmpTime, 0
    
    Invoke SetMenuItemBitmaps, hTrayMenu, IDM_TM_EXIT, MF_BYCOMMAND, hBmpExit, 0
    
    Invoke SetMenuItemBitmaps, hTrayMenu, 3, MF_BYPOSITION, hBmpIcons, 0
    
    Invoke SetMenuItemBitmaps, hTrayMenu, 5, MF_BYPOSITION, hBmpCPU, 0
    Invoke SetMenuItemBitmaps, hTrayMenu, 6, MF_BYPOSITION, hBmpMEM, 0

    Invoke TrayMenuUpdate, hWin
    ret
TrayMenuInit ENDP


;-------------------------------------------------------------------------------------
; Selection of a menu item from tray popup menu - Call from WM_COMMAND
;-------------------------------------------------------------------------------------
TrayMenuSelection PROC hWin:DWORD, wID:DWORD
    mov eax,wID
    
	.IF eax == IDM_TM_RESTORE
        Invoke ShowWindow, hWin, SW_SHOW    
        Invoke ShowWindow, hWin, SW_SHOWNORMAL  
        Invoke SetForegroundWindow, hWin ; Focus main window
	
	.ELSEIF eax == IDM_TM_HIDE
	    Invoke ShowWindow, hWin, SW_MINIMIZE
	    Invoke ShowWindow, hWin, SW_HIDE
	
	.ELSEIF eax == IDM_TM_EXIT
	    Invoke SendMessage,hWin,WM_CLOSE,0,0

    ;---------------------------------------------------------
    ; Tray Icons To Show
    ;---------------------------------------------------------
    .ELSEIF eax == IDM_TM_ICONCPU
        .IF g_IconCPU == ICONS_CPU_SHOW
            mov g_IconCPU, ICONS_CPU_HIDE
            Invoke KillTimer, hWin, TIMER_CPU
            Invoke MUITrayMenuHideTrayIcon, hMUITMCPU
            Invoke MUICheckboxSetState, hChkCPU, FALSE
        .ELSE
            Invoke GetSystemTimes, Addr last_idleTime, Addr last_kernelTime, Addr last_userTime 
            mov g_IconCPU, ICONS_CPU_SHOW
            Invoke MUITrayMenuShowTrayIcon, hMUITMCPU
            mov eax, g_ResponseCPU
            .IF eax == RESPONSE_CPU_05_SECS
                Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_05, NULL
            .ELSEIF eax == RESPONSE_CPU_1_SEC
                Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_1, NULL
            .ELSEIF eax == RESPONSE_CPU_2_SECS
                Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_2, NULL
            .ELSEIF eax == RESPONSE_CPU_3_SECS
                Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_3, NULL
            .ELSEIF eax == RESPONSE_CPU_5_SECS
                Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_5, NULL
            .ENDIF
            Invoke MUICheckboxSetState, hChkCPU, TRUE
        .ENDIF

    .ELSEIF eax == IDM_TM_ICONMEM
        .IF g_IconMEM == ICONS_MEM_SHOW
            mov g_IconMEM, ICONS_MEM_HIDE
            Invoke KillTimer, hWin, TIMER_MEM
            Invoke MUITrayMenuHideTrayIcon, hMUITMMEM
            Invoke MUICheckboxSetState, hChkMEM, FALSE
        .ELSE
            mov g_IconMEM, ICONS_MEM_SHOW
            Invoke MUITrayMenuShowTrayIcon, hMUITMMEM
            mov eax, g_ResponseMEM
            .IF eax == RESPONSE_MEM_2_SECS
                Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_2, NULL
            .ELSEIF eax == RESPONSE_MEM_5_SECS
                Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_5, NULL
            .ELSEIF eax == RESPONSE_MEM_10_SECS
                Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_10, NULL
            .ELSEIF eax == RESPONSE_MEM_20_SECS
                Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_20, NULL
            .ELSEIF eax == RESPONSE_MEM_30_SECS
                Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_30, NULL
            .ENDIF
            Invoke MUICheckboxSetState, hChkMEM, TRUE
        .ENDIF

    ;---------------------------------------------------------
    ; CPU Icon
    ;---------------------------------------------------------
    .ELSEIF eax == IDM_TM_CPU05
        .IF g_ResponseCPU != RESPONSE_CPU_05_SECS
            Invoke KillTimer, hWin, TIMER_CPU
            Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_05, NULL
            mov g_ResponseCPU, RESPONSE_CPU_05_SECS
        .ENDIF
        
    .ELSEIF eax == IDM_TM_CPU10
        .IF g_ResponseCPU != RESPONSE_CPU_1_SEC
            Invoke KillTimer, hWin, TIMER_CPU
            Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_1, NULL
            mov g_ResponseCPU, RESPONSE_CPU_1_SEC
        .ENDIF
        
    .ELSEIF eax == IDM_TM_CPU20
        .IF g_ResponseCPU != RESPONSE_CPU_2_SECS
            Invoke KillTimer, hWin, TIMER_CPU
            Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_2, NULL
            mov g_ResponseCPU, RESPONSE_CPU_2_SECS
        .ENDIF
        
    .ELSEIF eax == IDM_TM_CPU30
        .IF g_ResponseCPU != RESPONSE_CPU_3_SECS
            Invoke KillTimer, hWin, TIMER_CPU
            Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_3, NULL
            mov g_ResponseCPU, RESPONSE_CPU_3_SECS
        .ENDIF
    
    .ELSEIF eax == IDM_TM_CPU50
        .IF g_ResponseCPU != RESPONSE_CPU_5_SECS
            Invoke KillTimer, hWin, TIMER_CPU
            Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_5, NULL
            mov g_ResponseCPU, RESPONSE_CPU_5_SECS
        .ENDIF
    
    ;---------------------------------------------------------
    ; MEM Icon
    ;---------------------------------------------------------
    .ELSEIF eax == IDM_TM_MEM2
        .IF g_ResponseMEM != RESPONSE_MEM_2_SECS
            Invoke KillTimer, hWin, TIMER_MEM
            Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_2, NULL
            mov g_ResponseMEM, RESPONSE_MEM_2_SECS
        .ENDIF
        
    .ELSEIF eax == IDM_TM_MEM5
        .IF g_ResponseMEM != RESPONSE_MEM_5_SECS
            Invoke KillTimer, hWin, TIMER_MEM
            Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_5, NULL
            mov g_ResponseMEM, RESPONSE_MEM_5_SECS
        .ENDIF
        
    .ELSEIF eax == IDM_TM_MEM10
        .IF g_ResponseMEM != RESPONSE_MEM_10_SECS
            Invoke KillTimer, hWin, TIMER_MEM
            Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_10, NULL
            mov g_ResponseMEM, RESPONSE_MEM_10_SECS
        .ENDIF
        
    .ELSEIF eax == IDM_TM_MEM20
        .IF g_ResponseMEM != RESPONSE_MEM_20_SECS
            Invoke KillTimer, hWin, TIMER_MEM
            Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_20, NULL
            mov g_ResponseMEM, RESPONSE_MEM_20_SECS
        .ENDIF
    
    .ELSEIF eax == IDM_TM_MEM30
        .IF g_ResponseMEM != RESPONSE_MEM_30_SECS
            Invoke KillTimer, hWin, TIMER_MEM
            Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_30, NULL
            mov g_ResponseMEM, RESPONSE_MEM_30_SECS
        .ENDIF

    .ENDIF
    
    Invoke TrayMenuUpdate, hWin
    ret
TrayMenuSelection ENDP


;-------------------------------------------------------------------------------------
; Update TrayMenu submenu options to set checkmarks etc
;-------------------------------------------------------------------------------------
TrayMenuUpdate PROC hWin:DWORD
    LOCAL mi:MENUITEMINFO  
    
    mov mi.cbSize, SIZEOF MENUITEMINFO
    mov mi.fMask, MIIM_STATE ;+ MIIM_CHECKMARKS	

    ;---------------------------------------------------------
    ; Tray Icons To Show
    ;---------------------------------------------------------
    mov eax, g_IconCPU
    .IF eax == ICONS_CPU_SHOW
        mov mi.fState, MFS_CHECKED
    .ELSEIF eax == ICONS_CPU_HIDE
        mov mi.fState, MFS_UNCHECKED
    .ENDIF
    Invoke SetMenuItemInfo, hTMSubMenuIcons, IDM_TM_ICONCPU, FALSE, Addr mi
    
    mov eax, g_IconMEM
    .IF eax == ICONS_MEM_SHOW
        mov mi.fState, MFS_CHECKED
    .ELSEIF eax == ICONS_MEM_HIDE
        mov mi.fState, MFS_UNCHECKED
    .ENDIF
    Invoke SetMenuItemInfo, hTMSubMenuIcons, IDM_TM_ICONMEM, FALSE, Addr mi
    
    ;---------------------------------------------------------
    ; CPU Icon
    ;---------------------------------------------------------
    mov mi.fState, MFS_UNCHECKED
    Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU05, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU10, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU20, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU30, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU50, FALSE, Addr mi
    mov mi.fState, MFS_CHECKED
    mov eax, g_ResponseCPU
    .IF eax == RESPONSE_CPU_05_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU05, FALSE, Addr mi
    .ELSEIF eax == RESPONSE_CPU_1_SEC
        Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU10, FALSE, Addr mi        
    .ELSEIF eax == RESPONSE_CPU_2_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU20, FALSE, Addr mi
    .ELSEIF eax == RESPONSE_CPU_3_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU30, FALSE, Addr mi
    .ELSEIF eax == RESPONSE_CPU_5_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseCPU, IDM_TM_CPU50, FALSE, Addr mi
    .ENDIF

    ;---------------------------------------------------------
    ; MEM Icon
    ;---------------------------------------------------------
    mov mi.fState, MFS_UNCHECKED
    Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM2, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM5, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM10, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM20, FALSE, Addr mi
    Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM30, FALSE, Addr mi
    mov mi.fState, MFS_CHECKED
    mov eax, g_ResponseMEM
    .IF eax == RESPONSE_MEM_2_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM2, FALSE, Addr mi
    .ELSEIF eax == RESPONSE_MEM_5_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM5, FALSE, Addr mi        
    .ELSEIF eax == RESPONSE_MEM_10_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM10, FALSE, Addr mi
    .ELSEIF eax == RESPONSE_MEM_20_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM20, FALSE, Addr mi
    .ELSEIF eax == RESPONSE_MEM_30_SECS
        Invoke SetMenuItemInfo, hTMSubMenuResponseMEM, IDM_TM_MEM30, FALSE, Addr mi
    .ENDIF

    ret
TrayMenuUpdate ENDP
