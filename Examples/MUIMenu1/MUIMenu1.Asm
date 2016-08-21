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

IFDEF DEBUG32
    PRESERVEXMMREGS equ 1
    includelib M:\Masm32\lib\Debug32.lib
    DBG32LIB equ 1
    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
    include M:\Masm32\include\debug32.inc
ENDIF

include MUIMenu1.inc

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
        ; ModernUI_Button Examples: Createing a button as a menu item - Menu1
        ;-----------------------------------------------------------------------------------------------------
		; Create our ModernUI_Button control
		Invoke MUIButtonCreate, hWin, Addr szMenu1Text, 20, 50, 200, 45, IDC_MENUITEM1, MUIBS_LEFT + MUIBS_HAND
		mov hMenu1, eax
		Invoke MUIButtonLoadImages, hMenu1, MUIBIT_ICO, ICO_IMAGE, ICO_IMAGE, ICO_IMAGE, ICO_IMAGE, ICO_IMAGE
		Invoke MUIButtonSetAllProperties, hMenu1, Addr MUI_MENUITEM_DARKTHEME, SIZEOF MUI_BUTTON_PROPERTIES

		; Create our ModernUI_Button control
		Invoke MUIButtonCreate, hWin, Addr szMenu2Text, 20, 94, 200, 45, IDC_MENUITEM2, MUIBS_LEFT + MUIBS_HAND
		mov hMenu2, eax
		Invoke MUIButtonLoadImages, hMenu2, MUIBIT_ICO, ICO_FILE, ICO_FILE, ICO_FILE, ICO_FILE, ICO_FILE
        Invoke MUIButtonSetAllProperties, hMenu2, Addr MUI_MENUITEM_DARKTHEME, SIZEOF MUI_BUTTON_PROPERTIES
        
		; Create our ModernUI_Button control
		Invoke MUIButtonCreate, hWin, Addr szMenu3Text, 20, 138, 200, 45, IDC_MENUITEM3, MUIBS_LEFT + MUIBS_HAND
		mov hMenu3, eax
		Invoke MUIButtonLoadImages, hMenu3, MUIBIT_ICO, ICO_FOLDER, ICO_FOLDER, ICO_FOLDER, ICO_FOLDER, ICO_FOLDER
        Invoke MUIButtonSetAllProperties, hMenu3, Addr MUI_MENUITEM_DARKTHEME, SIZEOF MUI_BUTTON_PROPERTIES


;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBackColor, MUI_RGBCOLOR(51,51,51) ; 28,43,54 51,51,51
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBackColorAlt, MUI_RGBCOLOR(61,61,61)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBackColorSel, MUI_RGBCOLOR(71,71,71) ;71,71,71
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBackColorSelAlt, MUI_RGBCOLOR(71,71,71)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonTextColor, MUI_RGBCOLOR(185,185,185) ; 134,159,177 185,185,185
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonTextColorAlt, MUI_RGBCOLOR(195,195,195)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonTextColorSel, MUI_RGBCOLOR(255,255,255)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonTextColorSelAlt, MUI_RGBCOLOR(255,255,255)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBorderColor, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBorderColorAlt, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBorderColorSel, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonBorderStyle, MUIBBS_BOTTOM + MUIBBS_TOP
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentStyle, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentStyleAlt, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentStyleSel, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentStyleSelAlt, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentColor, 0
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentColorAlt, MUI_RGBCOLOR(71,121,145) ;71,121,145
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentColorSel, MUI_RGBCOLOR(57,149,193)
;        Invoke MUIButtonSetProperty, hMenu1, @ButtonAccentColorSelAlt, MUI_RGBCOLOR(57,149,193)

;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBackColor, MUI_RGBCOLOR(51,51,51)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBackColorAlt, MUI_RGBCOLOR(61,61,61)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBackColorSel, MUI_RGBCOLOR(71,71,71)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBackColorSelAlt, MUI_RGBCOLOR(71,71,71)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonTextColor, MUI_RGBCOLOR(185,185,185)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonTextColorAlt, MUI_RGBCOLOR(195,195,195)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonTextColorSel, MUI_RGBCOLOR(255,255,255)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonTextColorSelAlt, MUI_RGBCOLOR(255,255,255)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBorderColor, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBorderColorAlt, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBorderColorSel, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonBorderStyle, MUIBBS_BOTTOM + MUIBBS_TOP
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentStyle, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentStyleAlt, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentStyleSel, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentStyleSelAlt, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentColor, 0
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentColorAlt, MUI_RGBCOLOR(71,121,145)        
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentColorSel, MUI_RGBCOLOR(57,149,193)
;        Invoke MUIButtonSetProperty, hMenu2, @ButtonAccentColorSelAlt, MUI_RGBCOLOR(57,149,193) ;180,212,226

;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBackColor, MUI_RGBCOLOR(51,51,51)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBackColorAlt, MUI_RGBCOLOR(61,61,61)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBackColorSel, MUI_RGBCOLOR(71,71,71)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBackColorSelAlt, MUI_RGBCOLOR(71,71,71)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonTextColor, MUI_RGBCOLOR(185,185,185)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonTextColorAlt,  MUI_RGBCOLOR(195,195,195)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonTextColorSel, MUI_RGBCOLOR(255,255,255)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonTextColorSelAlt, MUI_RGBCOLOR(255,255,255)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBorderColor, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBorderColorAlt, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBorderColorSel, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(105,105,105)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonBorderStyle, MUIBBS_BOTTOM + MUIBBS_TOP
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentStyle, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentStyleAlt, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentStyleSel, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentStyleSelAlt, MUIBAS_LEFT
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentColor, 0
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentColorAlt, MUI_RGBCOLOR(71,121,145)        
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentColorSel, MUI_RGBCOLOR(57,149,193)
;        Invoke MUIButtonSetProperty, hMenu3, @ButtonAccentColorSelAlt, MUI_RGBCOLOR(57,149,193)
        
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
	    
	    .ELSEIF eax == IDC_MENUITEM1
	        Invoke MUIButtonSetState, hMenu1, TRUE
	        Invoke MUIButtonSetState, hMenu2, FALSE
	        Invoke MUIButtonSetState, hMenu3, FALSE
	    
	    .ELSEIF eax == IDC_MENUITEM2
	        Invoke MUIButtonSetState, hMenu1, FALSE
	        Invoke MUIButtonSetState, hMenu2, TRUE
	        Invoke MUIButtonSetState, hMenu3, FALSE
	        
	    .ELSEIF eax == IDC_MENUITEM3
	        Invoke MUIButtonSetState, hMenu1, FALSE
	        Invoke MUIButtonSetState, hMenu2, FALSE
	        Invoke MUIButtonSetState, hMenu3, TRUE
	        
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
