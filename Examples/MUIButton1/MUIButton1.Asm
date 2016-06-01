;.386
;.model flat,stdcall
;option casemap:none
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

include MUIButton1.inc

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
	mov		wc.style, 0 ; not including CS_HREDRAW or CS_VREDRAW which helps prevent flickering
	mov		wc.lpfnWndProc, offset WndProc
	mov		wc.cbClsExtra, NULL
	mov		wc.cbWndExtra, DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
	mov		wc.lpszMenuName, IDM_MENU
	mov		wc.lpszClassName, offset ClassName
	;Invoke LoadIcon, NULL, IDI_APPLICATION
	Invoke LoadIcon, hInstance, ICO_SYSTEM ; resource icon for main application icon, in this case we use the example system icon
	mov		wc.hIcon, eax
	mov		wc.hIconSm, eax
	Invoke LoadCursor, NULL, IDC_ARROW
	mov		wc.hCursor,eax
	Invoke RegisterClassEx, addr wc
	Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, addr WndProc, NULL
	Invoke ShowWindow, hWnd, SW_SHOWNORMAL
	Invoke UpdateWindow, hWnd
	.WHILE TRUE
		invoke GetMessage, addr msg, NULL, 0, 0
	  .BREAK .if !eax
		Invoke TranslateMessage, addr msg
		Invoke DispatchMessage, addr msg
	.ENDW
	mov eax, msg.wParam
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

		;-----------------------------------------------------------------------------------------------------
        ; ModernUI_CaptionBar Example - similar to the other example projects based on this control
        ;-----------------------------------------------------------------------------------------------------
		; Applies the ModernUI base style to the dialog, turning it into a borderless, caption less form
		; we set our own caption and system buttons with the ModernUI_CaptionBar control
		Invoke MUIApplyToDialog, hWin, TRUE
		
		; Create CaptionBar control and save handle
		Invoke MUICaptionBarCreate, hWin, Addr AppName, 32, IDC_CAPTIONBAR, MUICS_LEFT or MUICS_REDCLOSEBUTTON
		mov hCaptionBar, eax
		
		; Set some properties for our CaptionBar control 
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)		
		
		;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button Examples: Button1
        ;-----------------------------------------------------------------------------------------------------
		; Create our ModernUI_Button control using ICO images
		Invoke MUIButtonCreate, hWin, Addr szButton1Text, 20, 50, 150, 38, IDC_BUTTON1, 0
		mov hBtn1, eax
		
		; Load some images for when user moves mouse over button, or if its selected state changes
		Invoke MUIButtonLoadImages, hBtn1, MUIBIT_ICO, ICO_SYSTEM_GREY, ICO_SYSTEM, ICO_SYSTEM, ICO_SYSTEM, ICO_SYSTEM_GREY
		
		; Set notification options for button - shows a little rounded rectangle on the right when text when button is 'notified' (MUIButtonNotify or MUIBM_NOTIFY)
		Invoke MUIButtonSetProperty, hBtn1, @ButtonNotifyRound, 4
		Invoke MUIButtonSetProperty, hBtn1, @ButtonNotifyTextColor, MUI_RGBCOLOR(255,255,255)
		Invoke MUIButtonSetProperty, hBtn1, @ButtonNotifyBackColor, MUI_RGBCOLOR(166,26,32)
		Invoke MUIButtonNotifySetText, hBtn1, Addr szNotifyText, FALSE
		
		; set timer to emulate check for messages or other notifications, then show notification in button via the WM_TIMER event
		Invoke SetTimer, hWin, hWin, 5000d, NULL ; set for 5 seconds
	
		;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button Examples: Button2
        ;-----------------------------------------------------------------------------------------------------
		; Create a second ModernUI_Button control that will use PNG images (stored as RC_DATA resources)
		; additional style flags to emulate a button pressed down and up again and a hand when hovering over button
		Invoke MUIButtonCreate, hWin, Addr szButton2Text, 20, 100, 150, 38, IDC_BUTTON2, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON
		mov hBtn2, eax
	    
	    ; Load some images for when user moves mouse over button, or if its selected state changes
	    Invoke MUIButtonLoadImages, hBtn2, MUIBIT_PNG, PNG_CHART_GREY, PNG_CHART, PNG_CHART, PNG_CHART, PNG_CHART_GREY
	    ; Note: the state of button2 is toggled everytime button1 is clicked: see WM_COMMAND for that

		;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button Examples: Button3
        ;-----------------------------------------------------------------------------------------------------	    
		; Create a third ModernUI_Button control that will use BMP images
		; Style flags also used to create auto state, toggles between states when clicked
		Invoke MUIButtonCreate, hWin, Addr szButton3Text, 20, 150, 150, 38, IDC_BUTTON3, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_AUTOSTATE
		mov hBtn3, eax
	    
	    ; Load some images for when user moves mouse over button, or if its selected state changes
	    Invoke MUIButtonLoadImages, hBtn3, MUIBIT_BMP, BMP_HOUSE_GREY, BMP_HOUSE, BMP_HOUSE_GREY, BMP_HOUSE, BMP_HOUSE_GREY
	    
	    ; Note: Bitmap buttons dont have transparency, so the house button in this example has been modified to match the grey color that appears when the mouse is over
	    ; the control: RGB 221, 221, 221
	    ; Icons and png use tranparency so they might be preferable when using with the ModernUI_Button control
	    
	
	.ELSEIF eax == WM_TIMER
	    mov eax, wParam
	    .IF eax == hWin
	        Invoke KillTimer, hWin, hWin
	        Invoke MUIButtonNotify, hBtn1, TRUE ; Notify button1 to show our notification text and little colored rectangle
	    .ENDIF
		
	;---------------------------------------------------------------------------------------------------------------
	; Handle painting of our dialog with our specified background and border color to mimic new Modern style UI feel
	;---------------------------------------------------------------------------------------------------------------
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(255,255,255), MUI_RGBCOLOR(27,161,226)
		mov eax, 0
		ret
    ;---------------------------------------------------------------------------------------------------------------
	
	.ELSEIF eax == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh
		.IF eax == IDM_FILE_EXIT
			Invoke SendMessage,hWin,WM_CLOSE,0,0
			
		.ELSEIF eax == IDM_HELP_ABOUT
			Invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		
		.ELSEIF eax == IDC_BUTTON1
		    ; clear notifications and reset timer for our example
		    Invoke MUIButtonNotify, hBtn1, FALSE
		    ;Invoke MessageBox, hWin, Addr szBtnClicked, Addr AppName, MB_OK
			Invoke SetTimer, hWin, hWin, 5000d, NULL ; set for 5 seconds
			
			; Toggle state on button2 everytime button1 is clicked
			Invoke MUIButtonGetState, hBtn2
			.IF eax == FALSE
			    Invoke MUIButtonSetState, hBtn2, TRUE
			.ELSE
			    Invoke MUIButtonSetState, hBtn2, FALSE
			.ENDIF
			
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

end start
