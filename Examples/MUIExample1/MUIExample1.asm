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


include MUIExample1.inc

include Panels.asm

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
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, 0
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, DLGWINDOWEXTRA
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, 0
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset ClassName
    Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
    mov hIcoMain, eax ; main application icon
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    Invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor,eax
    Invoke RegisterClassEx, addr wc
    Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, addr WndProc, NULL
    mov hWnd, eax
    Invoke ShowWindow, hWnd, SW_SHOWNORMAL
    Invoke UpdateWindow, hWnd
    .WHILE TRUE
        invoke GetMessage,addr msg,NULL,0,0
        .BREAK .if !eax

        .IF hCurrentPanel != NULL
            Invoke IsDialogMessage, hCurrentPanel, addr msg ; add in a reference to our currently selected child dialog so we can do tabbing between controls etc.
            .IF eax == 0
                invoke TranslateMessage,addr msg
                invoke DispatchMessage,addr msg
            .ENDIF
        .ELSE
            invoke TranslateMessage,addr msg
            invoke DispatchMessage,addr msg
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
        Invoke InitGUI, hWin

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        ;.IF eax == IDC_BTNCANCEL
        ;    Invoke MUIProgressDotsAnimateStop, hMUIPD
        ;    Invoke SendMessage,hWin,WM_CLOSE,0,0
        ;.ENDIF


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
    
        Invoke MUISmartPanelCurrentPanelIndex, hMUISmartPanel
        .IF eax == 1 ; preparing installation dialog panel
        
            mov eax, dwInstallStage
            .IF eax == 0 ; before prep has finished        
                Invoke MUIProgressDotsAnimateStop, hMUIPD
                Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 0, FALSE
                .IF hPreThread != NULL
                    Invoke ResumeThread, hPreThread
                .ENDIF
                .IF dwInstallStage == 1
                    Invoke MUIProgressDotsAnimateStop, hMUIPD
                    Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 2, FALSE ; 3rd dialog - choose components
                .ENDIF                
                ret
            .ELSEIF eax == 1
                Invoke MUIProgressDotsAnimateStop, hMUIPD
                Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 2, FALSE ; 3rd dialog - choose components
                ret
            .ENDIF
        
        .ELSEIF eax == 2 ; choosing components dialog panel
        
            Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 0, FALSE
            ret
        
        .ENDIF
        
        Invoke DestroyWindow,hWin
        
    .ELSEIF eax == WM_DESTROY
        Invoke PostQuitMessage,NULL
        
    .ELSE
        Invoke DefWindowProc,hWin,uMsg,wParam,lParam
        ret
    .ENDIF
    xor eax,eax
    ret
WndProc endp


;-------------------------------------------------------------------------------------
; InitGUI - initialize GUI
;-------------------------------------------------------------------------------------
InitGUI PROC hWin:DWORD
    
    ;-----------------------------------------------------------------------------------------------------
    ; ModernUI_CaptionBar
    ;-----------------------------------------------------------------------------------------------------      
    Invoke MUICaptionBarCreate, hWin, Addr AppName, 50d, IDC_CAPTIONBAR, MUICS_NOCAPTIONTITLETEXT or MUICS_LEFT or MUICS_NOMAXBUTTON or MUICS_NOMINBUTTON or MUICS_WINNODROPSHADOW; or MUICS_NOCAPTIONTITLETEXT ;or MUICS_NOMAXBUTTON
    mov hMUICaptionBar, eax
    Invoke MUICaptionBarSetProperty, hMUICaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(45,45,48)
    Invoke MUICaptionBarSetProperty, hMUICaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUICaptionBarSetProperty, hMUICaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(66,66,68)
    Invoke MUICaptionBarSetProperty, hMUICaptionBar, @CaptionBarBtnWidth, 36d
    Invoke MUICaptionBarLoadBackImage, hMUICaptionBar, MUICBIT_BMP, BMP_RSLOGO


    ; ------------------------------------------------------------------------
    ; ModernUI_SmartPanel
    ; ------------------------------------------------------------------------
    Invoke MUISmartPanelCreate, hWin, 2, 98, 457, 545, IDC_SMARTPANEL, MUISPS_SLIDEPANELS_NORMAL or MUISPS_SPS_SKIPBETWEEN
    mov hMUISmartPanel, eax
    ; Register child panels to use with ModernUI_SmartPanel:
    Invoke MUISmartPanelRegisterPanel, hMUISmartPanel, IDD_Panel1, Addr Panel1Proc
    mov hPanel1, eax
    Invoke MUISmartPanelRegisterPanel, hMUISmartPanel, IDD_Panel2, Addr Panel2Proc
    mov hPanel2, eax
    Invoke MUISmartPanelRegisterPanel, hMUISmartPanel, IDD_Panel3, Addr Panel3Proc
    mov hPanel3, eax
    Invoke MUISmartPanelRegisterPanel, hMUISmartPanel, IDD_Panel4, Addr Panel4Proc
    mov hPanel4, eax
    ; Set current panel to index 0 and store handle to current panel in 
    ; hCurrentPanel (for use with IsDialogMessage)
    Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 1, FALSE
    Invoke MUISmartPanelSetIsDlgMsgVar, hMUISmartPanel, Addr hCurrentPanel


    ;-----------------------------------------------------------------------------------------------------
    ; ModernUI_Text: Community Edition 2018
    ;-----------------------------------------------------------------------------------------------------        
    Invoke MUITextCreate, hWin, Addr szRSHeader, 17, 70, 457, 30, IDC_TEXTRSHEADER, MUITS_CAPTION or MUITS_FONT_SEGOE 
    mov hMUITextRSHeader, eax
    Invoke MUITextSetProperty, hMUITextRSHeader, @TextColor, MUI_RGBCOLOR(179,179,179)
    Invoke MUITextSetProperty, hMUITextRSHeader, @TextColorAlt, MUI_RGBCOLOR(179,179,179)
    Invoke MUITextSetProperty, hMUITextRSHeader, @TextBackColor, MUI_RGBCOLOR(45,45,48)
    Invoke MUITextSetProperty, hMUITextRSHeader, @TextBackColorAlt, MUI_RGBCOLOR(45,45,48)
    
    ret

InitGUI ENDP


;-------------------------------------------------------------------------------------
; PreInstallation - Prepare installation. Calls PreInstallationThread
;-------------------------------------------------------------------------------------
PreInstallation PROC
    Invoke CreateThread, NULL, NULL, Addr PreInstallationThread, NULL, NULL, Addr lpThreadID
    mov hPreThread, eax
    ret
PreInstallation ENDP


;-------------------------------------------------------------------------------------
; PreInstallationThread - Main work for preparing installation goes here
;-------------------------------------------------------------------------------------
PreInstallationThread PROC dwParam:DWORD
    
    mov dwInstallStage, 0
    
    ; Pretend we are doing something here for the preperation of the installation
    Invoke SleepEx, 5000, FALSE

    ; Finally, we finished the prep part, now move on to next dialog for user to 
    ; choose components or installation location or something

    Invoke MUIProgressDotsAnimateStop, hMUIPD ; stop dots
    Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 2, FALSE ; move to dialog 3
    mov hPreThread, 0
    mov dwInstallStage, 1
    
    ret
PreInstallationThread ENDP



end start
