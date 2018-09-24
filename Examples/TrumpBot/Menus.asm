TrayMenuInit            PROTO :DWORD
TrayMenuSelection       PROTO :DWORD,:DWORD

RCMenuInit              PROTO :DWORD
RCMenuSelection         PROTO :DWORD,:DWORD



.CONST
IDM_TM_FIRST            EQU 20001
IDM_TM_ABOUT            EQU 20001
IDM_TM_EXIT             EQU 20002
IDM_TM_LAST             EQU 20100


IDM_RC_FIRST            EQU 8801
IDM_RC_ABOUT            EQU 8801
IDM_RC_EXIT             EQU 8802
IDM_RC_LAST             equ 8888


.DATA
szAppTooltip            DB 'TrumpBot',0

szTMAbout               DB '&About',0
szTMExit                DB '&Exit',0

szRCAbout               DB 'About',0
szRCExit                DB 'Exit',0



RCMenuPoint             POINT <>


.CODE


;-------------------------------------------------------------------------------------
; Init tray menu
;-------------------------------------------------------------------------------------
TrayMenuInit PROC hWin:DWORD
    Invoke CreatePopupMenu
    mov hTrayMenu, eax

	Invoke AppendMenu, hTrayMenu, MF_STRING or MF_ENABLED, IDM_TM_ABOUT, Addr szTMAbout
	Invoke AppendMenu, hTrayMenu, MF_SEPARATOR, 0, 0
    Invoke AppendMenu, hTrayMenu, MF_STRING or MF_ENABLED, IDM_TM_EXIT, Addr szTMExit

    Invoke MUITrayMenuCreate, hWin, hMainIcon, Addr szAppTooltip, MUITMT_POPUPMENU, hTrayMenu, MUITMS_HWNDEXTRA, hDFTrump
    mov hMUITM, eax

    ret
TrayMenuInit ENDP


;-------------------------------------------------------------------------------------
; Selection of a menu item from tray popup menu - Call from WM_COMMAND
;-------------------------------------------------------------------------------------
TrayMenuSelection PROC hWin:DWORD, wID:DWORD

    mov eax, wID
	.IF eax == IDM_TM_EXIT
	    Invoke DestroyWindow, hWnd    

    .ELSEIF eax == IDM_TM_ABOUT
        Invoke ShellAbout, hWin, Addr AppName, Addr AboutMsg,NULL

    .ENDIF

    ret
TrayMenuSelection ENDP


;-------------------------------------------------------------------------------------
; Init right click menu
;-------------------------------------------------------------------------------------
RCMenuInit PROC PRIVATE hWin:DWORD

	Invoke CreatePopupMenu	; Create RC Popup Menu
	mov hRCMenuPopup, eax ; Save RC Menu Handle
	Invoke AppendMenu, hRCMenuPopup, MF_STRING, IDM_RC_ABOUT, Addr szRCAbout
	Invoke AppendMenu, hRCMenuPopup, MF_SEPARATOR, 0, 0
	Invoke AppendMenu, hRCMenuPopup, MF_STRING, IDM_RC_EXIT, Addr szRCExit

    ret
RCMenuInit endp


;-------------------------------------------------------------------------------------
; Selection of a menu item from right click popup menu - Call from WM_COMMAND
;-------------------------------------------------------------------------------------
RCMenuSelection PROC hWin:DWORD, wID:DWORD

    mov eax, wID
	.IF eax == IDM_RC_EXIT
	    Invoke DestroyWindow, hWnd    

    .ELSEIF eax == IDM_RC_ABOUT
        Invoke ShellAbout, hWin, Addr AppName, Addr AboutMsg,NULL

    .ENDIF

    ret
RCMenuSelection ENDP









