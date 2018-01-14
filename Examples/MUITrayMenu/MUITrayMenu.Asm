.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include MUITrayMenu.inc

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
    LOCAL   wc:WNDCLASSEX
    LOCAL   msg:MSG

    mov     wc.cbSize, sizeof WNDCLASSEX
    mov     wc.style, CS_DROPSHADOW ;CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, offset WndProc
    mov     wc.cbClsExtra, NULL
    mov     wc.cbWndExtra, DLGWINDOWEXTRA
    push    hInst
    pop     wc.hInstance
    mov     wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
    mov     wc.lpszMenuName, NULL ;IDM_MENU
    mov     wc.lpszClassName, offset ClassName
    ;Invoke LoadIcon, NULL, IDI_APPLICATION
    Invoke LoadIcon, hInstance, ICO_MUI ; resource icon for main application icon
    mov hIcoMain, eax ; main application icon
    mov     wc.hIcon, eax
    mov     wc.hIconSm, eax
    Invoke LoadCursor, NULL, IDC_ARROW
    mov     wc.hCursor,eax
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
        
        ; Create CaptionBar control via ModernUI api
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 32d, IDC_CAPTIONBAR, MUICS_LEFT or MUICS_REDCLOSEBUTTON or MUICS_USEICONSFORBUTTONS ; or MUICS_NOCAPTIONTITLETEXT ;or MUICS_NOMAXBUTTON
        mov hCaptionBar, eax
        
        ; Load caption bar icons
        Invoke MUICaptionBarLoadIcons, hCaptionBar, ICO_MIN, NULL, ICO_MAX, NULL, ICO_RES, NULL, ICO_CLOSE, NULL
        
        ; Set some properties for our CaptionBar control
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(51,51,51)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(228,228,228)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(81,81,81)
       
        ; Create ModernUI_Button control for buttons: notify and exit
        Invoke MUIButtonCreate, hWin, Addr szShowNotifyText, 50, 80, 200, 38, IDC_SHOWNOTIFICATION, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hNotifyBtn, eax

        Invoke MUIButtonCreate, hWin, Addr szExitButton, 50, 130, 200, 38, IDC_EXIT, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hExitBtn, eax
        
        ; Create our ModernUI_TrayMenu control
        Invoke MUITrayMenuCreate, hWin, hIcoMain, Addr szTrayMenuTooltip, MUITMT_MENUITEMS, Addr TrayMenu1, MUITMS_MINONCLOSE or MUITMS_HIDEIFMIN, NULL
        mov hTrayMenu, eax

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        ; Paint our background
        Invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), MUI_RGBCOLOR(51,51,51) ; MUI_RGBCOLOR(255,255,255)
        mov eax, 0
        ret

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDM_TRAY_EXIT ; ModernUI_TrayMenu right click menu: Exit menu item 
            Invoke SendMessage,hWin,WM_CLOSE,0,0
        
        .ELSEIF eax == IDM_TRAY_OPT ; ModernUI_TrayMenu right click menu: Option menu item
        
        .ELSEIF eax == IDM_TRAY_URL ; ModernUI_TrayMenu right click menu: Web url menu item
            Invoke ShellExecute, hWin, Addr szShellCmdOpen, Addr szWebUrl, NULL, NULL, SW_SHOWNORMAL
        
        .ELSEIF eax == IDC_EXIT ; ModernUI_Button Exit Button
            Invoke SendMessage,hWin,WM_CLOSE,0,0
            
        .ELSEIF eax == IDC_SHOWNOTIFICATION ; ModernUI_Button Notify Button
            Invoke MUITrayMenuShowNotification, hTrayMenu, Addr szNotifyMsg, Addr szNotifyTitle, 5000d, MUITMNI_INFO
            
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
