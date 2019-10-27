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

include TrayInfo.inc
include Menu.asm

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
    
    Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    Invoke ExitProcess, eax

;-------------------------------------------------------------------------------------
; WinMain
;-------------------------------------------------------------------------------------
WinMain PROC hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, NULL ; CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, Offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, DLGWINDOWEXTRA
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
    mov wc.lpszMenuName, IDM_MENU
    mov wc.lpszClassName, Offset ClassName

    Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
    mov hMainIcon, eax ; main application icon
    mov  wc.hIcon, eax
    mov wc.hIconSm, eax
    Invoke LoadCursor, NULL, IDC_ARROW
    mov wc.hCursor,eax
    Invoke RegisterClassEx, Addr wc
    Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, Addr WndProc, NULL
    mov hWnd, eax
    ; Hide initial dialog and only display icons
    ;Invoke ShowWindow, hWnd, SW_SHOWNORMAL
    ;Invoke UpdateWindow, hWnd
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
        
        Invoke InitGUI, hWin
        
        ;-----------------------------------------------------------------------------
        ; ModernUI_CaptionBar
        ;-----------------------------------------------------------------------------
        Invoke MUIApplyToDialog, hWin, TRUE, TRUE
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 32, IDC_CAPTIONBAR, MUICS_NOMAXBUTTON or MUICS_LEFT or MUICS_REDCLOSEBUTTON
        mov hCaptionBar, eax
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244)   
        
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Checkbox
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUICheckboxCreate, hWin, Addr szCheckTextCPU, 13, 55, 215, 24, IDC_CHECKCPU, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP ;or THEMEDARK; or MUICBS_NOFOCUSRECT
        mov hChkCPU, eax
        Invoke MUICheckboxCreate, hWin, Addr szCheckTextMEM, 13, 80, 215, 24, IDC_CHECKMEM, MUICBS_HAND or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_TABSTOP ;or THEMEDARK; or MUICBS_NOFOCUSRECT
        mov hChkMEM, eax        
        
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szButtonTextExit, 20, 130, 140, 38, IDC_BUTTONEXIT, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER or WS_TABSTOP or MUIBS_THEME or MUIBS_NOFOCUSRECT
        mov hBtnExit, eax
        Invoke MUIButtonCreate, hWin, Addr szButtonTextHide, 180, 130, 140, 38, IDC_BUTTONHIDE, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER or WS_TABSTOP or MUIBS_THEME or MUIBS_NOFOCUSRECT
        mov hBtnHide, eax
        
        ;-----------------------------------------------------------------------------
        ; ModernUI_TrayMenu
        ;-----------------------------------------------------------------------------
        Invoke MUITrayMenuCreate, hWin, hMainIcon, Addr szAppTooltip, MUITMT_POPUPMENU, hTrayMenu, MUITMS_HIDEIFMIN or MUITMS_MINONCLOSE,0
        mov hMUITM, eax
        Invoke MUITrayMenuCreate, hWin, hIconBlank, Addr szCPUTip, MUITMT_POPUPMENU, hTrayMenu, MUITMS_HIDEIFMIN or MUITMS_MINONCLOSE,0
        mov hMUITMCPU, eax
        Invoke MUITrayMenuCreate, hWin, hIconBlank, Addr szMEMTip, MUITMT_POPUPMENU, hTrayMenu, MUITMS_HIDEIFMIN or MUITMS_MINONCLOSE,0
        mov hMUITMMEM, eax
        
        ;-----------------------------------------------------------------------------
        ; Start Icon Timers
        ;-----------------------------------------------------------------------------
        Invoke InitTimers, hWin


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
        
        .ELSEIF eax == IDC_BUTTONEXIT ; ModernUI_Button
            Invoke SendMessage, hWin, WM_CLOSE, 0, 0
        
        .ELSEIF eax == IDC_BUTTONHIDE ; ModernUI_Button
	        Invoke ShowWindow, hWin, SW_MINIMIZE
	        Invoke ShowWindow, hWin, SW_HIDE
        
        .ELSEIF eax == IDM_HELP_ABOUT
            Invoke ShellAbout, hWin, Addr AppName, Addr AboutMsg,NULL
        
        .ELSEIF eax == IDC_CHECKCPU ; ModernUI_Checkbox
            Invoke MUICheckboxGetState, hChkCPU
            .IF eax == FALSE
                mov g_IconCPU, ICONS_CPU_HIDE
                Invoke KillTimer, hWin, TIMER_CPU
                Invoke MUITrayMenuHideTrayIcon, hMUITMCPU
            .ELSE
                Invoke GetSystemTimes, Addr last_idleTime, Addr last_kernelTime, Addr last_userTime 
                mov g_IconCPU, ICONS_CPU_SHOW
                Invoke MUITrayMenuShowTrayIcon, hMUITMCPU
                mov eax, g_ResponseCPU
                .IF eax == RESPONSE_CPU_05_SECS
                    Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_05, NULL
                .ELSEIF eax == RESPONSE_CPU_1_SEC
                    Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_1, NULL
                .ELSEIF eax == RESPONSE_CPU_2_SECS
                    Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_2, NULL
                .ELSEIF eax == RESPONSE_CPU_3_SECS
                    Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_3, NULL
                .ELSEIF eax == RESPONSE_CPU_5_SECS
                    Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_5, NULL
                .ENDIF
            .ENDIF
            Invoke TrayMenuUpdate, hWin
        
        .ELSEIF eax == IDC_CHECKMEM ; ModernUI_Checkbox
            Invoke MUICheckboxGetState, hChkMEM
            .IF eax == FALSE
                mov g_IconMEM, ICONS_MEM_HIDE
                Invoke KillTimer, hWin, TIMER_MEM
                Invoke MUITrayMenuHideTrayIcon, hMUITMMEM
            .ELSE
                mov g_IconMEM, ICONS_MEM_SHOW
                Invoke MUITrayMenuShowTrayIcon, hMUITMMEM
                mov eax, g_ResponseMEM
                .IF eax == RESPONSE_MEM_2_SECS
                    Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_2, NULL
                .ELSEIF eax == RESPONSE_MEM_5_SECS
                    Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_5, NULL
                .ELSEIF eax == RESPONSE_MEM_10_SECS
                    Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_10, NULL
                .ELSEIF eax == RESPONSE_MEM_20_SECS
                    Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_20, NULL
                .ELSEIF eax == RESPONSE_MEM_30_SECS
                    Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_30, NULL
                .ENDIF
            .ENDIF
            Invoke TrayMenuUpdate, hWin
        
        ; Handle all tray menu clicks within the one function
		.ELSEIF eax >= IDM_TM_FIRST && eax <= IDM_TM_LAST
		    Invoke TrayMenuSelection, hWin, eax 
            
        .ENDIF

    .ELSEIF eax == WM_TIMER
        ;PrintText 'WM_TIMER'
        mov eax, wParam
        .IF eax == TIMER_CPU ; poll for cpu load and update of tray icon
            Invoke CPULoad
        .ELSEIF eax == TIMER_MEM ; poll for mem load and update of tray icon
            Invoke GetMemoryLoad
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


;-------------------------------------------------------------------------------------
; InitGUI - initialize some gdi resources
;-------------------------------------------------------------------------------------
InitGUI PROC hWin:DWORD
    
    ; Fonts for tray icons
    Invoke CreateFont, -10, 0, 0, 0, 0, FALSE, FALSE, FALSE, 0, 0, 0, 0, 0, CTEXT("Segeo UI")
    mov hFontCPU, eax
    
    Invoke CreateFont, -10, 0, 0, 0, 0, FALSE, FALSE, FALSE, 0, 0, 0, 0, 0, CTEXT("Segeo UI")
    mov hFontMEM, eax
    
    ; A blank icon, just in case we need it
    Invoke LoadIcon, hInstance, ICO_BLANK
    mov hIconBlank, eax

    ; Tray menu bitmaps
    Invoke LoadBitmap, hInstance, BMP_TM_SHOW
    mov hBmpShow, eax
    Invoke LoadBitmap, hInstance, BMP_TM_HIDE
    mov hBmpHide, eax
    Invoke LoadBitmap, hInstance, BMP_TM_ICONS
    mov hBmpIcons, eax
    Invoke LoadBitmap, hInstance, BMP_TM_CPU
    mov hBmpCPU, eax
    Invoke LoadBitmap, hInstance, BMP_TM_MEM
    mov hBmpMEM, eax
    Invoke LoadBitmap, hInstance, BMP_TM_TIME
    mov hBmpTime, eax
    Invoke LoadBitmap, hInstance, BMP_TM_EXIT
    mov hBmpExit, eax
    
    ; Start creating the tray menu, before calling ModernUI_TrayMenu functions
    ; so we can assign ready made menu to it
    Invoke TrayMenuInit, hWin

    ret
InitGUI ENDP


;-------------------------------------------------------------------------------------
; InitTimers - init timers and other things for the tray icons
;-------------------------------------------------------------------------------------
InitTimers PROC hWin:DWORD
    
    ; Set checkbox initial states
    .IF g_IconCPU == ICONS_CPU_SHOW
        Invoke MUICheckboxSetState, hChkCPU, TRUE
    .ENDIF
    
    .IF g_IconMEM == ICONS_MEM_SHOW
        Invoke MUICheckboxSetState, hChkMEM, TRUE
    .ENDIF
    
    ;PrintText 'InitTimers'
    
    ; Assign a 0% icon to each tray icon to begin with before polling takes over
    Invoke MUITrayMenuSetTrayIconText, hMUITMCPU, Addr szZeroPercent, hFontCPU, MUI_RGBCOLOR(96,207,137)
    mov hIconCPU, eax ; save returned icon handle for later
    Invoke MUITrayMenuSetTrayIconText, hMUITMMEM, Addr szZeroPercent, hFontMEM, MUI_RGBCOLOR(96,176,207)
    mov hIconMEM, eax ; save returned icon handle for later
    
    ;PrintText 'InitTimers::MUITrayMenuSetTrayIconText'
    
    ; Get g_ResponseCPU and g_ResponseMEM values
    ; Could fetch these from an ini file for user to keep settings persistant
    
    Invoke GetSystemTimes, Addr last_idleTime, Addr last_kernelTime, Addr last_userTime 
    
    ;---------------------------------------------------------
    ; CPU Icon Timer
    ;---------------------------------------------------------
    mov eax, g_ResponseCPU
    .IF eax == RESPONSE_CPU_05_SECS
        Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_05, NULL
    .ELSEIF eax == RESPONSE_CPU_1_SEC
        Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_1, NULL
    .ELSEIF eax == RESPONSE_CPU_2_SECS
        Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_2, NULL
    .ELSEIF eax == RESPONSE_CPU_3_SECS
        Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_3, NULL
    .ELSEIF eax == RESPONSE_CPU_5_SECS
        Invoke SetTimer, hWin, TIMER_CPU, TIME_CPU_5, NULL
    .ENDIF
    
    ;---------------------------------------------------------
    ; MEM Icon Timer
    ;---------------------------------------------------------
    mov eax, g_ResponseMEM
    .IF eax == RESPONSE_MEM_2_SECS
        Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_2, NULL
    .ELSEIF eax == RESPONSE_MEM_5_SECS
        Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_5, NULL
    .ELSEIF eax == RESPONSE_MEM_10_SECS
        Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_10, NULL
    .ELSEIF eax == RESPONSE_MEM_20_SECS
        Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_20, NULL
    .ELSEIF eax == RESPONSE_MEM_30_SECS
        Invoke SetTimer, hWin, TIMER_MEM, TIME_MEM_30, NULL
    .ENDIF

    ret
InitTimers ENDP

;-------------------------------------------------------------------------------------
; CPULoad - get the cpu load and change icon to reflect percentage of the cpu load
;-------------------------------------------------------------------------------------
CPULoad PROC
    LOCAL dwPercent:DWORD
    
    Invoke GetCPULoad, Addr szCpuLoadPercent
    mov dwPercent, eax
    
    .IF hIconCPU != 0
        Invoke DestroyIcon, hIconCPU ; delete existing icon otherwise gdi leak
    .ELSE
        ;PrintText 'hIconCPU == 0'
    .ENDIF
    
    ; Create a tray icon based on our percent text and assign it to our existing TrayMenu
    .IF sdword ptr dwPercent >= 90
        Invoke MUITrayMenuSetTrayIconText, hMUITMCPU, Addr szCpuLoadPercent, hFontCPU, MUI_RGBCOLOR(207,96,96)
    .ELSE
        Invoke MUITrayMenuSetTrayIconText, hMUITMCPU, Addr szCpuLoadPercent, hFontCPU, MUI_RGBCOLOR(96,207,137) ;MUI_RGBCOLOR(255,50,75)
    .ENDIF
    mov hIconCPU, eax ; save returned icon handle for later

;    Invoke lstrcpy, Addr szCPUToolTip, Addr szCPUTip
;    Invoke lstrcat, Addr szCPUToolTip, Addr szCpuLoadPercent
;    Invoke lstrcat, Addr szCPUToolTip, Addr szPercentage
;    Invoke MUITrayMenuSetTooltipText, hMUITMCPU, Addr szCPUToolTip

    ret
CPULoad ENDP

;-------------------------------------------------------------------------------------
; GetCPULoad - calculates the cpu load based on times
;-------------------------------------------------------------------------------------
GetCPULoad PROC USES EBX EDX lpszPercent:DWORD
    LOCAL idleTime:FILETIME
    LOCAL kernelTime:FILETIME
    LOCAL userTime:FILETIME
    LOCAL idl:FILETIME
    LOCAL ker:FILETIME
    LOCAL usr:FILETIME
    LOCAL sys:FILETIME
    LOCAL sysidl:FILETIME
    LOCAL preresult:DWORD
    LOCAL divvalue:DWORD
    LOCAL percent:DWORD
    LOCAL fPercent:REAL10
    LOCAL dw100:DWORD
    LOCAL decimalPlace:DWORD
    
    mov decimalPlace, 1
    
    Invoke GetSystemTimes, Addr idleTime, Addr kernelTime, Addr userTime
    
    finit
    
    mov eax, idleTime.dwLowDateTime
    sub eax, last_idleTime.dwLowDateTime
    mov idl.dwLowDateTime, eax
    
    mov eax, kernelTime.dwLowDateTime
    sub eax, last_kernelTime.dwLowDateTime
    mov ker.dwLowDateTime, eax
    
    mov eax, userTime.dwLowDateTime
    sub eax, last_userTime.dwLowDateTime
    mov usr.dwLowDateTime, eax
    
    xor eax,eax
    add eax, ker.dwLowDateTime
    add eax, usr.dwLowDateTime
    mov ebx, eax
    mov divvalue, eax
    xor edx, edx
    sub eax, idl.dwLowDateTime
    imul eax, 100
    mov preresult, eax
    .IF ebx != 0
        idiv ebx
    .ELSE
        mov eax, 0
    .ENDIF
    mov percent, eax    
    
    ; if percentage is 0-9 then show a decimal place, otherwise dont
    .IF sdword ptr percent < 10
        fild preresult
        fild divvalue
        fdiv
        fstp fPercent
        .IF lpszPercent != NULL
            Invoke FpuFLtoA, Addr fPercent, decimalPlace, lpszPercent, SRC1_REAL Or STR_REG
        .ENDIF
    .ELSE
        .IF lpszPercent != NULL
            Invoke dwtoa, percent, lpszPercent
        .ENDIF
    .ENDIF
    
    ; store results for next go around
    fild qword ptr idleTime
    fistp qword ptr last_idleTime
    
    fild qword ptr kernelTime
    fistp qword ptr last_kernelTime
    
    fild qword ptr userTime
    fistp qword ptr last_userTime
    
    mov eax, percent
    ret

GetCPULoad ENDP


;------------------------------------------------------------------------------
; Get memory load percent
;------------------------------------------------------------------------------
GetMemoryLoad PROC
    LOCAL mse:MEMORYSTATUSEX
    LOCAL dwMemoryLoad:DWORD
    
    mov mse.dwLength, SIZEOF MEMORYSTATUSEX     ; initialise length
    Invoke GlobalMemoryStatusEx, Addr mse       ; call API
    
    mov eax, mse.dwMemoryLoad
    mov dwMemoryLoad, eax
    
    Invoke dwtoa, mse.dwMemoryLoad, Addr szMemLoadPercent ; convert to text

    .IF hIconMEM != 0
        Invoke DestroyIcon, hIconMEM ; delete existing icon otherwise gdi leak
    .ELSE
        ;PrintText 'hIconMEM == 0'
    .ENDIF

    ; Create a tray icon based on our percent text and assign it to our existing TrayMenu
    
    .IF sdword ptr dwMemoryLoad >= 90
        Invoke MUITrayMenuSetTrayIconText, hMUITMMEM, Addr szMemLoadPercent, hFontMEM, MUI_RGBCOLOR(207,96,96)
    .ELSE
        Invoke MUITrayMenuSetTrayIconText, hMUITMMEM, Addr szMemLoadPercent, hFontMEM, MUI_RGBCOLOR(96,176,207)
    .ENDIF
    mov hIconMEM, eax ; save returned icon handle for later
    
;    Invoke lstrcpy, Addr szMEMToolTip, Addr szMEMTip
;    Invoke lstrcat, Addr szMEMToolTip, Addr szMemLoadPercent
;    Invoke lstrcat, Addr szMEMToolTip, Addr szPercentage
;    Invoke MUITrayMenuSetTooltipText, hMUITMMEM, Addr szMEMToolTip
    
    ret
GetMemoryLoad ENDP


end start
