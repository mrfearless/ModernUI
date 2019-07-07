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
    LOCAL   wc:WNDCLASSEX
    LOCAL   msg:MSG

    mov     wc.cbSize, sizeof WNDCLASSEX
    mov     wc.style, CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, offset WndProc
    mov     wc.cbClsExtra, NULL
    mov     wc.cbWndExtra, DLGWINDOWEXTRA
    push    hInst
    pop     wc.hInstance
    mov     wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
    mov     wc.lpszMenuName, IDM_MENU
    mov     wc.lpszClassName, offset ClassName
    Invoke LoadIcon, hInstance, ICO_MAIN
    mov     wc.hIcon, eax
    mov     wc.hIconSm, eax
    Invoke LoadCursor, NULL, IDC_ARROW
    mov     wc.hCursor,eax
    Invoke RegisterClassEx, addr wc
    Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, addr WndProc, NULL
    mov hWnd, eax
    Invoke ShowWindow, hWnd, SW_SHOWNORMAL
    Invoke UpdateWindow, hWnd
    .WHILE TRUE
        invoke GetMessage, Addr msg, NULL, 0, 0
        .BREAK .if !eax
        Invoke IsDialogMessage, hWnd, Addr msg
        .IF eax == 0
            Invoke TranslateMessage, Addr msg
            Invoke DispatchMessage, Addr msg
        .ENDIF
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
        ; ModernUI_CaptionBar
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 32, IDC_CAPTIONBAR, MUICS_NOMAXBUTTON or MUICS_LEFT or MUICS_REDCLOSEBUTTON
        mov hCaptionBar, eax
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)      
        
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button: Start Button - Used to start the progress bar in this example
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szStartButtonText, 20, 160, 140, 38, IDC_STARTBUTTON, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER or WS_TABSTOP or MUIBS_THEME or MUIBS_NOFOCUSRECT
        mov hStartBtn, eax
        
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button: Exit Button - used to exit this example
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szExitButtonText, 180, 160, 140, 38, IDC_EXITBUTTON, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER or WS_TABSTOP or MUIBS_THEME or MUIBS_NOFOCUSRECT
        mov hExitBtn, eax

        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_ProgressBar Examples: - when user clicks Start Button we start the progress bars or restart
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIProgressBarCreate, hWin, 20,50,300,12, IDC_PB1, 0
        mov hPB1, eax
        Invoke MUIProgressBarSetProperty, hPB1, @ProgressBarBorderColor, MUI_RGBCOLOR(93,95,120)
        Invoke MUIProgressBarSetProperty, hPB1, @ProgressBarTextType, MUIPBTT_CENTRE ; show % text in centre
        Invoke MUIProgressBarSetProperty, hPB1, @ProgressBarPulseTime, 1500 ; speed up pulse
        
        Invoke MUIProgressBarCreate, hWin, 20,70,300,12, IDC_PB2, 0
        mov hPB2, eax
        Invoke MUIProgressBarSetProperty, hPB2, @ProgressBarBackColor, MUI_RGBCOLOR(255,255,255)
        Invoke MUIProgressBarSetProperty, hPB2, @ProgressBarTextColor, MUI_RGBCOLOR(96,96,96)
        Invoke MUIProgressBarSetProperty, hPB2, @ProgressBarProgressColor, MUI_RGBCOLOR(33,186,69) ; change progress color
        Invoke MUIProgressBarSetProperty, hPB2, @ProgressBarTextType, MUIPBTT_CENTRE ; show % text in centre
        
        Invoke MUIProgressBarCreate, hWin, 20,90,300,12, IDC_PB3, 0
        mov hPB3, eax
        Invoke MUIProgressBarSetProperty, hPB3, @ProgressBarBorderColor, MUI_RGBCOLOR(93,95,120)
        Invoke MUIProgressBarSetProperty, hPB3, @ProgressBarProgressColor, MUI_RGBCOLOR(186,69,33) ; change progress color
        Invoke MUIProgressBarSetProperty, hPB3, @ProgressBarPulse, FALSE ; dont show a pulse
        
        Invoke MUIProgressBarCreate, hWin, 20,110,300,12, IDC_PB4, MUIPBS_TEXT_FOLLOW ; % using style flag instead of @ProgressBarTextType - text follows progress
        mov hPB4, eax
        Invoke MUIProgressBarSetProperty, hPB4, @ProgressBarBackColor, MUI_RGBCOLOR(240,240,240)
        Invoke MUIProgressBarSetProperty, hPB4, @ProgressBarProgressColor, MUI_RGBCOLOR(131,131,138) ; change progress color
        
        Invoke MUIProgressBarCreate, hWin, 20,130,300,12, IDC_PB5, MUIPBS_TEXT_FOLLOW or MUIPBS_R2G ; % using style flag - text follows progress and goes from red to green
        mov hPB5, eax
        
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
            Invoke KillTimer, hWin, 1
            Invoke KillTimer, hWin, 2
            Invoke KillTimer, hWin, 3
            Invoke KillTimer, hWin, 4
            Invoke KillTimer, hWin, 5
            Invoke MUIProgressBarSetPercent, hPB1, 0
            Invoke MUIProgressBarSetPercent, hPB2, 0
            Invoke MUIProgressBarSetPercent, hPB3, 0
            Invoke MUIProgressBarSetPercent, hPB4, 0
            Invoke MUIProgressBarSetPercent, hPB5, 0
            Invoke SetTimer, hWin, 1, 200, 0
            Invoke SetTimer, hWin, 2, 250, 0
            Invoke SetTimer, hWin, 3, 300, 0
            Invoke SetTimer, hWin, 4, 200, 0
            Invoke SetTimer, hWin, 5, 250, 0
            mov dwTimer1, 0
        
        .ELSEIF eax == IDC_EXITBUTTON
            Invoke KillTimer, hWin, 1
            Invoke KillTimer, hWin, 2
            Invoke KillTimer, hWin, 3
            Invoke KillTimer, hWin, 4
            Invoke KillTimer, hWin, 5
            Invoke SendMessage,hWin,WM_CLOSE,0,0
        .ENDIF
    
    .ELSEIF eax == WM_TIMER
        mov eax, wParam
        .IF eax == 1
            Invoke MUIProgressBarStep, hPB1
            Invoke MUIProgressBarGetPercent, hPB1
            .IF eax == 20
                Invoke MUIProgressBarSetPercent, hPB1, 40
            .ELSEIF eax == 60
                Invoke MUIProgressBarSetPercent, hPB1, 80
            .ELSEIF eax == 100
                Invoke KillTimer, hWin, 1
                inc dwTimer1
                .IF dwTimer1 < 3 ; stops after 3 times
                    Invoke MUIProgressBarSetPercent, hPB1, 0
                    Invoke SetTimer, hWin, 1, 150, 0
                .ENDIF
            .ENDIF
        .ELSEIF eax == 2
            Invoke MUIProgressBarStep, hPB2
            Invoke MUIProgressBarGetPercent, hPB2
            .IF eax == 100
                Invoke KillTimer, hWin, 2
            .ENDIF
        .ELSEIF eax == 3
            Invoke MUIProgressBarStep, hPB3
            Invoke MUIProgressBarGetPercent, hPB3
            .IF eax == 100
                Invoke KillTimer, hWin, 3
            .ENDIF
        .ELSEIF eax == 4
            Invoke MUIProgressBarStep, hPB4
            Invoke MUIProgressBarGetPercent, hPB4
            .IF eax == 100
                Invoke KillTimer, hWin, 4
            .ENDIF
        .ELSEIF eax == 5
            Invoke MUIProgressBarStep, hPB5
            Invoke MUIProgressBarGetPercent, hPB5
            .IF eax == 100
                Invoke KillTimer, hWin, 5
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
