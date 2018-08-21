.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include MUICaptionBar1.inc

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
    Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
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
        
        ; Create CaptionBar control via MUI api
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 40d, IDC_CAPTIONBAR, MUICS_LEFT or MUICS_REDCLOSEBUTTON
        mov hCaptionBar, eax
        
        ; Set some properties for our CaptionBar control 
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(51,51,51)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(228,228,228)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(81,81,81)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBorderRollColor, MUI_RGBCOLOR(65,152,210)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnHeight, 28
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnWidth, 30
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnOffsetX, 4
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnOffsetY, 5
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackImageOffsetY, 6
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackImageOffsetX, 4
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarWindowBackColor, MUI_RGBCOLOR(206,219,229)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarWindowBorderColor, -1 ;MUI_RGBCOLOR(51,51,51)
        
        Invoke LoadImage, hInstance, ICO_MAIN, IMAGE_ICON, 24, 24, LR_DEFAULTCOLOR ; resource icon for main application icon
        mov hIcoMain, eax ; main application icon
        Invoke SendMessage, hCaptionBar, WM_SETICON, ICON_SMALL, hIcoMain        


        Invoke MUICaptionBarAddButton, hCaptionBar, NULL, IDC_CAPBTNMENU, ICO_MUI_MENU, ICO_MUI_MENU
        mov hCapBtnMenu, eax

;    .ELSEIF eax == WM_ERASEBKGND
;        mov eax, 1
;        ret
;
;    .ELSEIF eax == WM_PAINT
;        invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(255,255,255), MUI_RGBCOLOR(51,51,51)
;        mov eax, 0
;        ret

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDM_FILE_EXIT
            Invoke SendMessage,hWin,WM_CLOSE,0,0
            
        .ELSEIF eax == IDM_HELP_ABOUT
            Invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
        
        .ELSEIF eax == IDC_CAPBTNMENU
            Invoke MessageBox, hWin, Addr AppName, Addr AppName, MB_OK
            
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
