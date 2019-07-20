;-----------------------------------------------------------------------------
; ModernUI_Animation demo - MUIAnim1
;
; github.com/mrfearless/ModernUI
;
;-----------------------------------------------------------------------------
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

include MUIAnim1.inc

.code

start:

    Invoke GetModuleHandle, NULL
    mov hInstance, eax
    Invoke GetCommandLine
    mov CommandLine, eax
    Invoke InitCommonControls
    mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, Offset icc
    
    ;Invoke MUIGDIPlusStart
    Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    ;Invoke MUIGDIPlusFinish
    
    Invoke ExitProcess, eax

;-------------------------------------------------------------------------------------
; WinMain
;-------------------------------------------------------------------------------------
WinMain PROC hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, Offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, DLGWINDOWEXTRA
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
    mov wc.lpszMenuName, IDM_MENU
    mov wc.lpszClassName, Offset ClassName
    Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
    mov  wc.hIcon, eax
    mov wc.hIconSm, eax
    Invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor,eax
    Invoke RegisterClassEx, Addr wc
    Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, Addr WndProc, NULL
    mov hWnd, eax
    Invoke ShowWindow, hWnd, SW_SHOWNORMAL
    Invoke UpdateWindow, hWnd
    .WHILE TRUE
        Invoke GetMessage, Addr msg, NULL, 0, 0
        .BREAK .if !eax
        Invoke TranslateMessage, Addr msg
        Invoke DispatchMessage, Addr msg
    .ENDW
    mov eax, msg.wParam
    ret
WinMain ENDP


;-------------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;-------------------------------------------------------------------------------------
WndProc PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_INITDIALOG
    
        ;-----------------------------------------------------------------------------
        ; ModernUI_CaptionBar
        ;-----------------------------------------------------------------------------
        Invoke MUIApplyToDialog, hWin, TRUE, TRUE
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 32, IDC_CAPTIONBAR, MUICS_NOMAXBUTTON or MUICS_LEFT or MUICS_REDCLOSEBUTTON
        mov hCaptionBar, eax
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)   

        ;-----------------------------------------------------------------------------
        ; Create our ModernUI_Animation control, animate the facebook clickbait image
        ;-----------------------------------------------------------------------------
        Invoke MUIAnimationCreate, hWin, 50, 50, 231, 148, IDC_ANIM1, MUIAS_STRETCH or MUIAS_LCLICK or MUIAS_HAND
        mov hAnim1, eax
        
        ;-----------------------------------------------------------------------------
        ; Load animation spritesheet. Frame times are in an array. MUIAFT_FULL is a 
        ; one for one entry for each frame for its time, MUIAFT_COMPACT means only the
        ; entries in the array that match the frame id (index) are updated with frame 
        ; times, the other frames default to default frame time value - which can be
        ; set by calling MUIAnimationSetDefaultTime
        ;----------------------------------------------------------------------------- 
        Invoke MUIAnimationLoadSpriteSheet, hAnim1, MUIAIT_PNG, PNG_FCCB, FCCBFrameCount, Addr FCCBFrameTimes, FCCBFrameTimesSize, MUIAFT_FULL
        ;Invoke MUIAnimationLoadSpriteSheet, hAnim1, MUIAIT_PNG, PNG_FCCB, FCCBFrameCount, Addr FrameTimes, FrameTimesSize, MUIAFT_COMPACT
        
        ; Modify some settings
        Invoke MUIAnimationSpeed, hAnim1, FP4(1.5) ; speed up animation
        ;Invoke MUIAnimationSpeed, hAnim1, FP4(0.5) ; slow down animation
        ;Invoke MUIAnimationSetDefaultTime, hAnim1, 40 ; if using MUIAFT_COMPACT set default frame times
        ;Invoke MUIAnimationStart, hAnim1 ; if style is MUIAS_LCLICK then clicking with play/stop animation
        
        ;-----------------------------------------------------------------------------
        ; Another ModernUI_Animation control for OnOff, to mimic a rocker/slider control
        ;-----------------------------------------------------------------------------
        Invoke MUIAnimationCreate, hWin, 100, 220, 127, 43, IDC_ONOFF, MUIAS_CENTER or MUIAS_LCLICK or MUIAS_HAND or MUIAS_CONTROL; MUIAS_STRETCH461, 294
        mov hOnOff, eax
        Invoke MUIAnimationLoadSpriteSheet, hOnOff, MUIAIT_PNG, PNG_ONOFF, OnOffFrameCount, Addr OnOffFrameTimes, OnOffFrameTimesSize, MUIAFT_FULL
        ;Invoke MUIAnimationSetProperty, hOnOff, @AnimationBorderColor, -1 ; no border
        Invoke MUIAnimationSetProperty, hOnOff, @AnimationBorderColor, MUI_RGBCOLOR(188,188,188)
        

    ;---------------------------------------------------------------------------------
    ; Handle painting of our dialog with our specified background and border color to 
    ; mimic new Modern style UI feel
    ;---------------------------------------------------------------------------------
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), MUI_RGBCOLOR(27,161,226)
        mov eax, 0
        ret
    ;---------------------------------------------------------------------------------
        
    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDM_FILE_EXIT
            Invoke SendMessage, hWin, WM_CLOSE, 0, 0
            
        .ELSEIF eax == IDM_HELP_ABOUT
            Invoke ShellAbout, hWin, Addr AppName, Addr AboutMsg,NULL
        
        .ELSEIF eax == IDC_ONOFF
            .IF OnOffState == FALSE
                mov OnOffState, TRUE
                Invoke MUIAnimationResume, hAnim1
            .ELSE
                mov OnOffState, FALSE
                Invoke MUIAnimationPause, hAnim1
            .ENDIF
        
        .ELSEIF eax == IDC_ANIM1
            .IF OnOffState == FALSE
                mov OnOffState, TRUE
                Invoke MUIAnimationResume, hOnOff
            .ELSE
                mov OnOffState, FALSE
                Invoke MUIAnimationResume, hOnOff
            .ENDIF
        
        .ENDIF

    .ELSEIF eax == WM_CLOSE
        Invoke DestroyWindow, hWin
        
    .ELSEIF eax == WM_DESTROY
        Invoke PostQuitMessage, NULL
        
    .ELSE
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ret
    .ENDIF
    xor eax, eax
    ret
WndProc ENDP

end start
