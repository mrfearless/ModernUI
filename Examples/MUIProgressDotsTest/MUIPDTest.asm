.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

include MUIPDTest.inc

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
	mov		wc.style, 0
	mov		wc.lpfnWndProc, offset WndProc
	mov		wc.cbClsExtra, NULL
	mov		wc.cbWndExtra, DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground, 0
	mov		wc.lpszMenuName, NULL
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

        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_CaptionBar
        ;-----------------------------------------------------------------------------------------------------		
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 64d, IDC_CAPTIONBAR, MUICS_NOCAPTIONTITLETEXT or MUICS_LEFT or MUICS_NOMAXBUTTON or MUICS_NOMINBUTTON or MUICS_WINNODROPSHADOW; or MUICS_NOCAPTIONTITLETEXT ;or MUICS_NOMAXBUTTON
        mov hCaptionBar, eax
        ; Set some properties for our CaptionBar control 
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(255,255,255)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(66,66,68)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnWidth, 36d
        Invoke MUICaptionBarLoadBackImage, hCaptionBar, MUICBIT_BMP, BMP_RSLOGO


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button
        ;-----------------------------------------------------------------------------------------------------
        ; Create a second ModernUI_Button control
        Invoke MUIButtonCreate, hWin, Addr szBtnCancelText, 350, 600, 90, 28, IDC_BTNCANCEL, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hBtnCancel, eax        
        
        Invoke MUIButtonSetProperty, hBtnCancel, @ButtonTextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hBtnCancel, @ButtonTextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hBtnCancel, @ButtonBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIButtonSetProperty, hBtnCancel, @ButtonBackColorAlt, MUI_RGBCOLOR(66,66,68)
        
        Invoke MUIButtonSetProperty, hBtnCancel, @ButtonBorderStyle, MUIBBS_ALL
        Invoke MUIButtonSetProperty, hBtnCancel, @ButtonBorderColor, MUI_RGBCOLOR(103,103,106)
        Invoke MUIButtonSetProperty, hBtnCancel, @ButtonBorderColorAlt, MUI_RGBCOLOR(56,163,254)


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Text
        ;-----------------------------------------------------------------------------------------------------        
        Invoke MUITextCreate, hWin, Addr szInstalling, 33, 129, 379, 80, IDC_TEXT1, MUITS_10PT or MUITS_FONT_SEGOE
        mov hText1, eax
        Invoke MUITextSetProperty, hText1, @TextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hText1, @TextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hText1, @TextBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUITextSetProperty, hText1, @TextBackColorAlt, MUI_RGBCOLOR(45,45,48)


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_ProgressDot
        ;-----------------------------------------------------------------------------------------------------
		Invoke MUIProgressDotsCreate, hWin, 300, 3, IDC_MUIPD, 0
		mov hMUIPD, eax
		Invoke MUIProgressDotsSetProperty, hMUIPD, @ProgressDotsBackColor, MUI_RGBCOLOR(45,45,48)
		Invoke MUIProgressDotsAnimateStart, hMUIPD


	.ELSEIF eax == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh
		.IF eax == IDC_BTNCANCEL
	        Invoke MUIProgressDotsAnimateStop, hMUIPD
	        Invoke SendMessage,hWin,WM_CLOSE,0,0
		.ENDIF


    ;-----------------------------------------------------------------------------------------------------
    ; ModernUI - Color background and border
    ;-----------------------------------------------------------------------------------------------------
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(45,45,48), MUI_RGBCOLOR(12,12,12)
        mov eax, 0
        ret
    ;-----------------------------------------------------------------------------------------------------
    
    
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
