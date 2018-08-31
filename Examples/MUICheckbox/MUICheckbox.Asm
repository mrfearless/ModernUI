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

include MUICheckbox.inc

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
    mov     wc.hbrBackground, COLOR_WINDOW+1;COLOR_BTNFACE+1 ; COLOR_WINDOW+1
    mov     wc.lpszMenuName, IDM_MENU
    mov     wc.lpszClassName, offset ClassName
    Invoke LoadIcon, NULL, IDI_APPLICATION
    ;Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
    ;mov hIcoMain, eax ; main application icon
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
        ; ModernUI_CaptionBar Example - similar to the other example projects based on this control
        ;-----------------------------------------------------------------------------------------------------
        ; Applies the ModernUI base style to the dialog, turning it into a borderless, caption less form
        ; we set our own caption and system buttons with the ModernUI_CaptionBar control
        Invoke MUIApplyToDialog, hWin, TRUE, TRUE
        
        ; Create CaptionBar control and save handle
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 32, IDC_CAPTIONBAR, MUICS_LEFT or MUICS_REDCLOSEBUTTON
        mov hCaptionBar, eax
        
        ; Set some properties for our CaptionBar control 
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)      
        
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Checkbox Examples:
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUICheckboxCreate, hWin, Addr szCheckbox1Text, 20, 50, 300, 24, IDC_CHECKBOX1, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP or WS_DISABLED; or MUICBS_NOFOCUSRECT
        mov hChk1, eax
        Invoke MUICheckboxSetState, hChk1, FALSE

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox2Text, 20, 75, 300, 24, IDC_CHECKBOX2, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP or WS_DISABLED; or MUICBS_NOFOCUSRECT
        mov hChk2, eax
        Invoke MUICheckboxSetState, hChk2, TRUE
        
        Invoke MUICheckboxCreate, hWin, Addr szCheckbox3Text, 20, 100, 300, 24, IDC_CHECKBOX3, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP; or MUICBS_NOFOCUSRECT
        mov hChk3, eax

        Invoke MUICheckboxCreate, hWin, Addr szCheckbox4Text, 20, 125, 300, 24, IDC_CHECKBOX3, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP; or MUICBS_NOFOCUSRECT
        mov hChk4, eax

        Invoke MUICheckboxCreate, hWin, Addr szRadio1Text, 20, 150, 300, 24, IDC_RADIO1, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP or WS_DISABLED or MUICBS_RADIO; or MUICBS_NOFOCUSRECT
        mov hRadio1, eax
        Invoke MUICheckboxSetState, hRadio1, FALSE

        Invoke MUICheckboxCreate, hWin, Addr szRadio2Text, 20, 175, 300, 24, IDC_RADIO2, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP or WS_DISABLED or MUICBS_RADIO; or MUICBS_NOFOCUSRECT
        mov hRadio2, eax
        Invoke MUICheckboxSetState, hRadio2, TRUE

        Invoke MUICheckboxCreate, hWin, Addr szRadio3Text, 20, 200, 300, 24, IDC_RADIO3, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP or MUICBS_RADIO; or MUICBS_NOFOCUSRECT
        mov hRadio3, eax

        Invoke MUICheckboxCreate, hWin, Addr szRadio4Text, 20, 225, 300, 24, IDC_RADIO4, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP or MUICBS_RADIO; or MUICBS_NOFOCUSRECT
        mov hRadio4, eax

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
