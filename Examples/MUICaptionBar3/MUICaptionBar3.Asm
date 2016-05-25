.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include MUICaptionBar3.inc

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
	
	; To be able to use the RadASM custom control on the main dialog resource
	; MUICaptionBar.dlg - we have to call this function to register our 
	; caption bar control. Then we enter 'ModernUICaptionBar' as our class
	; in the RadASM custom control. The control is thus created automatically
	; for us when the dialog is instantiated.
	
	Invoke MUICaptionBarRegister
	
	Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess, eax

;-------------------------------------------------------------------------------------
; WinMain
;-------------------------------------------------------------------------------------
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize, sizeof WNDCLASSEX
	mov		wc.style, CS_DROPSHADOW ;CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc, offset WndProc
	mov		wc.cbClsExtra, NULL
	mov		wc.cbWndExtra, DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
	mov		wc.lpszMenuName, NULL ;IDM_MENU
	mov		wc.lpszClassName, offset ClassName
	Invoke LoadIcon, NULL, IDI_APPLICATION
	;Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
	;mov hIcoMain, eax ; main application icon
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
		
		; Applies the ModernUI base style to the dialog, turning it into a borderless, caption less form
		; we set our own caption and system buttons with the ModernUI_CaptionBar control
		Invoke MUIApplyToDialog, hWin, TRUE
		
		; Get CaptionBar control handle from resource id and save handle
		Invoke GetDlgItem, hWin, IDC_CAPTIONBAR
		mov hCaptionBar, eax
		
		; Set some properties for our CaptionBar control 
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(26,166,140)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
		Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(89,179,162)

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(202,234,228), MUI_RGBCOLOR(26,166,140)
		mov eax, 0
		ret
		
	.ELSEIF eax == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh
		.IF eax == IDM_FILE_EXIT
			Invoke SendMessage,hWin,WM_CLOSE,0,0
			
		.ELSEIF eax == IDM_HELP_ABOUT
			Invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		
		.ELSEIF eax == IDC_BTN1
		    invoke DialogBoxParam, hInstance, IDD_SOMEOTHERDLG, hWin, OFFSET SomeOtherDlgProc, NULL
			
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
; SomeOtherDlg Proc
;-------------------------------------------------------------------------------------
SomeOtherDlgProc PROC hWin:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM

	mov  eax,iMsg
    .IF eax==WM_INITDIALOG
        
        ; This dialogs resources have been edited to give it the style flags required for our ModernUI styling
        ; hence no need to call MUIApplyToDialog - it is provided for ease of use, so you dont have to keep
        ; setting style flags - for those that forget or are lazy :)
        
        ; However, if we do wish to add the dropshadow effect to the dialog we can do so with MUIApplyToDialog 
        ; (the 2nd param if TRUE will enable the CS_DROPSHADOW style on the dialog)
        Invoke MUIApplyToDialog, hWin, TRUE
        
        ; Get CaptionBar control handle from resource id and save handle
		Invoke GetDlgItem, hWin, IDC_SOMEOTHERCAPTIONBAR
		mov hCaptionSomeOtherDlg, eax    
		
		; Set some properties for our CaptionBar control 
		Invoke MUICaptionBarSetProperty, hCaptionSomeOtherDlg, @CaptionBarBackColor, MUI_RGBCOLOR(148,89,179)
		Invoke MUICaptionBarSetProperty, hCaptionSomeOtherDlg, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
		Invoke MUICaptionBarSetProperty, hCaptionSomeOtherDlg, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(172,142,187)

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

	.ELSEIF eax == WM_PAINT
		invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(255,255,255), MUI_RGBCOLOR(148,89,179)
		mov eax, 0
		ret

    .ELSEIF eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
  
	.ELSEIF eax==WM_CLOSE
	    invoke EndDialog,hWin,NULL        
	.ELSE
      	mov eax,FALSE
		ret
	.ENDIF
	mov  eax,TRUE
	ret

SomeOtherDlgProc ENDP










end start
