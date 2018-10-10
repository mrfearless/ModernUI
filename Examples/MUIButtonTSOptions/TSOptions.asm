.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

include TSOptions.inc

.code

start:

	Invoke GetModuleHandle,NULL
	mov hInstance, eax
	Invoke GetCommandLine
	mov CommandLine, eax
	Invoke InitCommonControls
	mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, offset icc
	
	Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess, eax

;-------------------------------------------------------------------------------------
; WinMain
;-------------------------------------------------------------------------------------
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize, sizeof WNDCLASSEX
	mov		wc.style, CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc, offset WndProc
	mov		wc.cbClsExtra, NULL
	mov		wc.cbWndExtra, DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
	mov		wc.lpszMenuName, NULL ;IDM_MENU
	mov		wc.lpszClassName, offset ClassName
	Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
	mov hIcoMain, eax ; main application icon
	mov		wc.hIcon, eax
	mov		wc.hIconSm, eax
	Invoke LoadCursor, NULL, IDC_ARROW
	mov		wc.hCursor,eax
	Invoke RegisterClassEx, addr wc
	Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, addr WndProc, NULL
    mov hWnd, eax
    Invoke ShowWindow, hWnd, SW_SHOWNORMAL
    Invoke UpdateWindow, hWnd
    .WHILE TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
        .BREAK .if !eax
        Invoke IsDialogMessage, hWnd, addr msg
        .IF eax == 0
            Invoke TranslateMessage, addr msg
            Invoke DispatchMessage, addr msg
        .ENDIF
    .ENDW
    mov eax,msg.wParam
	ret
WinMain endp


;-------------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;-------------------------------------------------------------------------------------
WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	mov eax, uMsg
	.IF eax == WM_INITDIALOG
		push hWin
		pop hWnd
		; Init Stuff Here
		Invoke InitGUI, hWin
		
		
	.ELSEIF eax == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh

        .IF eax >= OPT_APPLICATION && eax <= OPT_NOTIFICATIONS
            Invoke SetActiveButton, eax
        .ENDIF

	.ELSEIF eax == WM_CLOSE
		Invoke DestroyWindow,hWin
		
	.ELSEIF eax == WM_DESTROY
		Invoke PostQuitMessage,NULL
		
	.ELSE
		Invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp


;-------------------------------------------------------------------------------------
; InitGUI - Init GUI Stuff
;-------------------------------------------------------------------------------------
InitGUI PROC hWin:DWORD
    
    Invoke GetDlgItem, hWin, IDC_GREYFRAME
    Invoke SetWindowPos, eax, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE

    Invoke GetDlgItem, hWin, IDC_WHITESQUARE
    Invoke SetWindowPos, eax, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE

    
    ; --------------------------------------------------------------------------------------------
    ; Create the ModernUI buttons for each teamspeak option
    ; --------------------------------------------------------------------------------------------
    Invoke MUIButtonCreate, hWin, Addr szOptApplication, 10, 10, 160, 34, OPT_APPLICATION, MUIBS_LEFT or MUIBS_HAND 
    mov hOptApplication, eax
    Invoke MUIButtonCreate, hWin, Addr szOptmyTeamSpeak, 10, 46, 160, 34, OPT_MYTEAMSPEAK, MUIBS_LEFT or MUIBS_HAND
    mov hOptmyTeamSpeak, eax
    Invoke MUIButtonCreate, hWin, Addr szOptPlayback, 10, 82, 160, 34, OPT_PLAYBACK, MUIBS_LEFT or MUIBS_HAND
    mov hOptPlayback, eax
    Invoke MUIButtonCreate, hWin, Addr szOptCapture, 10, 118, 160, 34, OPT_CAPTURE, MUIBS_LEFT or MUIBS_HAND
    mov hOptCapture, eax
    Invoke MUIButtonCreate, hWin, Addr szOptDesign, 10, 154, 160, 34, OPT_DESIGN, MUIBS_LEFT or MUIBS_HAND
    mov hOptDesign, eax
    Invoke MUIButtonCreate, hWin, Addr szOptAddons, 10, 190, 160, 34, OPT_ADDONS, MUIBS_LEFT or MUIBS_HAND
    mov hOptAddons, eax
    Invoke MUIButtonCreate, hWin, Addr szOptHotkeys, 10, 226, 160, 34, OPT_HOKEYS, MUIBS_LEFT or MUIBS_HAND
    mov hOptHotkeys, eax
    Invoke MUIButtonCreate, hWin, Addr szOptWhisper, 10, 262, 160, 34, OPT_WHISPER, MUIBS_LEFT or MUIBS_HAND
    mov hOptWhisper, eax
    Invoke MUIButtonCreate, hWin, Addr szOptDownloads, 10, 298, 160, 34, OPT_DOWNLOADS, MUIBS_LEFT or MUIBS_HAND
    mov hOptDownloads, eax
    Invoke MUIButtonCreate, hWin, Addr szOptChat, 10, 334, 160, 34, OPT_CHAT, MUIBS_LEFT or MUIBS_HAND
    mov hOptChat, eax
    Invoke MUIButtonCreate, hWin, Addr szOptSecurity, 10, 370, 160, 34, OPT_SECURITY, MUIBS_LEFT or MUIBS_HAND
    mov hOptSecurity, eax
    Invoke MUIButtonCreate, hWin, Addr szOptMessages, 10, 406, 160, 34, OPT_MESSAGES, MUIBS_LEFT or MUIBS_HAND
    mov hOptMessages, eax
    Invoke MUIButtonCreate, hWin, Addr szOptNotifications, 10, 442, 160, 34, OPT_NOTIFICATIONS, MUIBS_LEFT or MUIBS_HAND
    mov hOptNotifications, eax
    
    ; --------------------------------------------------------------------------------------------
    ; create a special blank button at bottom (for future button additions possibly)
    ; --------------------------------------------------------------------------------------------
    ;Invoke MUIButtonCreate, hWin, Addr szOptBlank, 10, 478, 160, 34, OPT_NOTIFICATIONS, MUIBS_LEFT or MUIBS_NOFOCUSRECT ;or MUIBS_HAND
    ;mov hOptBlank, eax
    
    
    ; --------------------------------------------------------------------------------------------
    ; Load button icon and set color for border and background for when mouse over or selected etc
    ; --------------------------------------------------------------------------------------------
    Invoke MUIButtonLoadImages, hOptApplication, MUIBIT_ICO, ICO_Application, ICO_Application, ICO_Application, ICO_Application, ICO_Application
    Invoke MUIButtonSetAllProperties, hOptApplication, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES

;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptApplication, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptmyTeamSpeak, MUIBIT_ICO, ICO_myTeamSpeak, ICO_myTeamSpeak, ICO_myTeamSpeak, ICO_myTeamSpeak, ICO_myTeamSpeak
    Invoke MUIButtonSetAllProperties, hOptmyTeamSpeak, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptmyTeamSpeak, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptPlayback, MUIBIT_ICO, ICO_Playback, ICO_Playback, ICO_Playback, ICO_Playback, ICO_Playback
    Invoke MUIButtonSetAllProperties, hOptPlayback, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptPlayback, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptCapture, MUIBIT_ICO, ICO_Capture, ICO_Capture, ICO_Capture, ICO_Capture, ICO_Capture
    Invoke MUIButtonSetAllProperties, hOptCapture, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptCapture, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptDesign, MUIBIT_ICO, ICO_Design, ICO_Design, ICO_Design, ICO_Design, ICO_Design
    Invoke MUIButtonSetAllProperties, hOptDesign, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptDesign, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptAddons, MUIBIT_ICO, ICO_Addons, ICO_Addons, ICO_Addons, ICO_Addons, ICO_Addons
    Invoke MUIButtonSetAllProperties, hOptAddons, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptAddons, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptHotkeys, MUIBIT_ICO, ICO_Hotkeys, ICO_Hotkeys, ICO_Hotkeys, ICO_Hotkeys, ICO_Hotkeys
    Invoke MUIButtonSetAllProperties, hOptHotkeys, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptHotkeys, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptWhisper, MUIBIT_ICO, ICO_Whisper, ICO_Whisper, ICO_Whisper, ICO_Whisper, ICO_Whisper
    Invoke MUIButtonSetAllProperties, hOptWhisper, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptWhisper, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptDownloads, MUIBIT_ICO, ICO_Downloads, ICO_Downloads, ICO_Downloads, ICO_Downloads, ICO_Downloads
    Invoke MUIButtonSetAllProperties, hOptDownloads, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptDownloads, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptChat, MUIBIT_ICO, ICO_Chat, ICO_Chat, ICO_Chat, ICO_Chat, ICO_Chat
    Invoke MUIButtonSetAllProperties, hOptChat, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptChat, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptSecurity, MUIBIT_ICO, ICO_Security, ICO_Security, ICO_Security, ICO_Security, ICO_Security
    Invoke MUIButtonSetAllProperties, hOptSecurity, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptSecurity, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptMessages, MUIBIT_ICO, ICO_Messages, ICO_Messages, ICO_Messages, ICO_Messages, ICO_Messages
    Invoke MUIButtonSetAllProperties, hOptMessages, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptMessages, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    Invoke MUIButtonLoadImages, hOptNotifications, MUIBIT_ICO, ICO_Notifications, ICO_Notifications, ICO_Notifications, ICO_Notifications, ICO_Notifications
    Invoke MUIButtonSetAllProperties, hOptNotifications, Addr MUI_BUTTON_TEAMSPEAK, SIZEOF MUI_BUTTON_PROPERTIES
    
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBackColorAlt, MUI_RGBCOLOR(245,250,255)
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBackColorSel, MUI_RGBCOLOR(220,236,255)
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBackColorSelAlt, MUI_RGBCOLOR(208,228,253)
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBorderStyle, MUIBBS_ALL
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBorderColor, MUI_RGBCOLOR(255,255,255)
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBorderColorAlt, MUI_RGBCOLOR(185,215,252)
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBorderColorSel, MUI_RGBCOLOR(132,172,221)
;    Invoke MUIButtonSetProperty, hOptNotifications, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(125,162,206)

    ;Invoke MUIButtonSetProperty, hOptBlank, @ButtonBackColor, MUI_RGBCOLOR(255,255,255)
    ;Invoke MUIButtonSetProperty, hOptBlank, @ButtonBackColorAlt, MUI_RGBCOLOR(255,255,255)
    ;Invoke MUIButtonSetProperty, hOptBlank, @ButtonBackColorSel, MUI_RGBCOLOR(255,255,255)
    ;Invoke MUIButtonSetProperty, hOptBlank, @ButtonBackColorSelAlt, MUI_RGBCOLOR(255,255,255)
    ;Invoke MUIButtonSetProperty, hOptBlank, @ButtonBorderStyle, MUIBBS_NONE

    ; --------------------------------------------------------------------------------------------
    ; Set initial selected button to the first one - Application
    ; --------------------------------------------------------------------------------------------
    Invoke MUIButtonSetState, hOptApplication, TRUE

    ret

InitGUI ENDP


;-------------------------------------------------------------------------------------
; Update button states to only show the single selected button. Setting state will 
; refresh the button and auto change the colors and borders based on our property 
; settings in InitGUI. Note: mouseover will auto change the colors and borders for us
;-------------------------------------------------------------------------------------
SetActiveButton PROC idButton:DWORD
    
    mov eax, idButton
	.IF eax == OPT_APPLICATION
        Invoke MUIButtonSetState, hOptApplication, TRUE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE
	
	.ELSEIF eax == OPT_MYTEAMSPEAK
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, TRUE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_PLAYBACK
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, TRUE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_CAPTURE
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, TRUE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_DESIGN
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, TRUE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_ADDONS
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, TRUE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_HOKEYS
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, TRUE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_WHISPER
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, TRUE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_DOWNLOADS
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, TRUE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_CHAT
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, TRUE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_SECURITY
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, TRUE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_MESSAGES
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, TRUE
	    Invoke MUIButtonSetState, hOptNotifications, FALSE

	.ELSEIF eax == OPT_NOTIFICATIONS
        Invoke MUIButtonSetState, hOptApplication, FALSE
	    Invoke MUIButtonSetState, hOptmyTeamSpeak, FALSE
	    Invoke MUIButtonSetState, hOptPlayback, FALSE
	    Invoke MUIButtonSetState, hOptCapture, FALSE
	    Invoke MUIButtonSetState, hOptDesign, FALSE
	    Invoke MUIButtonSetState, hOptAddons, FALSE
	    Invoke MUIButtonSetState, hOptHotkeys, FALSE
	    Invoke MUIButtonSetState, hOptWhisper, FALSE
	    Invoke MUIButtonSetState, hOptDownloads, FALSE
	    Invoke MUIButtonSetState, hOptChat, FALSE
	    Invoke MUIButtonSetState, hOptSecurity, FALSE
	    Invoke MUIButtonSetState, hOptMessages, FALSE
	    Invoke MUIButtonSetState, hOptNotifications, TRUE

	.ENDIF    
    ret

SetActiveButton ENDP




end start
