.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

include MUIProgressBar.inc

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
	mov		wc.lpszMenuName, IDM_MENU
	mov		wc.lpszClassName, offset ClassName
	Invoke LoadIcon, NULL, IDI_APPLICATION
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
		; Create CaptionBar control and save handle
		Invoke MUICaptionBarCreate, hWin, Addr AppName, 32, IDC_CAPTIONBAR,  MUICS_LEFT or MUICS_REDCLOSEBUTTON 
		mov hCaptionBar, eax
		
		; Set some properties for our CaptionBar control 
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)		
		
		;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button Example: Start Button - Used to start the progress bar in this example
        ;-----------------------------------------------------------------------------------------------------
		; Create our ModernUI_Button control
		Invoke MUIButtonCreate, hWin, Addr szStartButtonText, 20, 140, 140, 38, IDC_STARTBUTTON, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
		mov hStartBtn, eax
		
		;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button Example: Exit Button - used to exit this example
        ;-----------------------------------------------------------------------------------------------------
		; Create a second ModernUI_Button control
		Invoke MUIButtonCreate, hWin, Addr szExitButtonText, 180, 140, 140, 38, IDC_EXITBUTTON, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
		mov hExitBtn, eax

		;-----------------------------------------------------------------------------------------------------
        ; ModernUI_ProgressBar Example - when user clicks Start Button we start the progress bar or restart
        ;-----------------------------------------------------------------------------------------------------
		Invoke MUIProgressBarCreate, hWin, 20,80,300,10, IDC_PB, 0 ;50,50,500,10
		mov hPB, eax
		
		; set a particular color for our progress bar border color, something subtle
		Invoke MUIProgressBarSetProperty, hPB, @ProgressBarBorderColor, MUI_RGBCOLOR(163,163,163)

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
		
		.ELSEIF eax == IDC_STARTBUTTON
		    Invoke KillTimer, hWin, hWin
		    Invoke MUIProgressBarSetPercent, hPB, 0
		    Invoke SetTimer, hWin, hWin, 200, 0
		
		.ELSEIF eax == IDC_EXITBUTTON
		    Invoke KillTimer, hWin, hWin
            Invoke SendMessage,hWin,WM_CLOSE,0,0
		.ENDIF
    
    .ELSEIF eax == WM_TIMER
         Invoke MUIProgressBarStep, hPB
    
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
