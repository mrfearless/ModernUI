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

include RB1.inc

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
WndProc proc USES EBX ECX hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL hMapButton:DWORD
	
	mov eax, uMsg
	.IF eax == WM_INITDIALOG
		push hWin
		pop hWnd
		; Init Stuff Here
		mov hPrevMapButton, 0
		Invoke GetDlgItem, hWin, IDC_LblCountry
		mov hLblCountry, eax
		
		;Invoke MUIRegionButtonCreate, hWin, Addr szRegionAfrica, 20, 20, IDC_RB1, WS_CHILD or WS_VISIBLE
		;mov hRB1, eax
		
		;Invoke MUIRegionButtonSetRegion, hRB1, Addr REGION_CENTRAL_AFRICA_DATA, REGION_CENTRAL_AFRICA_DATA_SIZE
		
		
		Invoke MUIMapCreate, hWin, NULL, 20,20, 305, 305, IDC_MAP1, WS_CHILD or WS_VISIBLE or MUIMS_UK_IRELAND_IND ;MUIMS_UK_IND ;MUIMS_UK_IRELAND_IND ;Addr szBritishIsles
		mov hMUIMap, eax
		;PrintDec hMUIMap
		
		Invoke MUIMapLoadImages, hMUIMap, MUIMIT_BMP, BMP_WATER, 0
		
	.ELSEIF eax == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh
		.IF eax == IDM_FILE_EXIT
			Invoke SendMessage,hWin,WM_CLOSE,0,0
		
		.ELSEIF eax == IDC_BTN1
		    ;Invoke MUIRegionButtonSetProperty, hRB1, @RegionButtonBackColor, MUI_RGBCOLOR(21,133,181)
		    
		    Invoke MUIMapButtonSetProperty, hMUIMap, MUIMB_SCOTLAND, @RegionButtonBackColor, MUI_RGBCOLOR(21,133,181)
		    
		    ;Invoke MessageBox, hWin, Addr AppName, Addr AppName, MB_OK
		
		.ELSEIF eax == IDM_HELP_ABOUT
			Invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL

        .ELSEIF eax == IDC_MAP1
            ;PrintText 'IDC_RB1'
            mov eax, wParam
            shr eax, 16d
            ;PrintDec wParam
            ;PrintDec eax
            .IF eax == MUIMB_IRELAND
                Invoke MessageBox, hWin, Addr szIrelandClicked, Addr szIrelandClicked, MB_OK
                Invoke SetWindowText, hLblCountry, Addr szIrelandClicked
            .ELSEIF eax == MUIMB_SCOTLAND
                Invoke MessageBox, hWin, Addr szScotlandClicked, Addr szScotlandClicked, MB_OK
                Invoke SetWindowText, hLblCountry, Addr szScotlandClicked
            .ELSEIF eax == MUIMB_ENGLAND
                Invoke MessageBox, hWin, Addr szEnglandClicked, Addr szEnglandClicked, MB_OK
                Invoke SetWindowText, hLblCountry, Addr szEnglandClicked
            .ELSEIF eax == MUIMB_WALES
                Invoke MessageBox, hWin, Addr szWalesClicked, Addr szWalesClicked, MB_OK
                Invoke SetWindowText, hLblCountry, Addr szWalesClicked
            .ELSEIF eax == MUIMB_NORTHERN_IRELAND
                Invoke MessageBox, hWin, Addr szNIrelandClicked, Addr szNIrelandClicked, MB_OK
                Invoke SetWindowText, hLblCountry, Addr szNIrelandClicked
            .ENDIF
			
		.ENDIF

    .ELSEIF eax == WM_NOTIFY
        
        mov ecx, lParam
        mov ebx, (MUIM_NOTIFY ptr [ecx]).hdr.code
        mov eax, (MUIM_NOTIFY ptr [ecx]).hdr.hwndFrom
       
        .IF eax == hMUIMap
            .IF ebx == MUIMN_MOUSEOVER
                ;PrintText 'MUIMN_MOUSEOVER'
                mov eax, (MUIM_NOTIFY ptr [ecx]).mapitem.hMapButton
                mov hMapButton, eax
                
                .IF eax != hPrevMapButton
                    mov hPrevMapButton, eax
                    ;PrintDec hMapButton
                    Invoke GetWindowText, hMapButton, Addr szCountry, SIZEOF szCountry
                    ;PrintString szCountry
                    Invoke SetWindowText, hLblCountry, Addr szCountry
                    
                .ENDIF    
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
