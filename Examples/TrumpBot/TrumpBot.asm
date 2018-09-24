.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

include TrumpBot.inc
include Actions.asm
include Menus.asm

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

;------------------------------------------------------------------------------
; WinMain
;------------------------------------------------------------------------------
WinMain PROC hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize, SIZEOF WNDCLASSEX
    mov wc.style, 0
    mov wc.lpfnWndProc, Offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, 0
    push hInst
    pop wc.hInstance
    mov wc.hbrBackground, 0
    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, Offset ClassName
    Invoke LoadIcon, hInstance, ICO_MAIN ; resource icon for main application icon
    mov hMainIcon, eax ; main application icon
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    mov wc.hCursor, 0
    Invoke RegisterClassEx, Addr wc
    Invoke CreateWindowEx, 0, Addr ClassName, 0, WS_POPUP, 0,0,0,0,0,0,hInstance,0
    mov hWnd, eax
    .WHILE TRUE
        Invoke GetMessage, Addr msg, NULL, 0, 0
        .BREAK .if !eax
        Invoke TranslateMessage, Addr msg
        Invoke DispatchMessage, Addr msg
    .ENDW
    mov eax, msg.wParam
    ret
WinMain ENDP


;------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;------------------------------------------------------------------------------
WndProc PROC hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_CREATE
        Invoke InitGUI, hWin
        Invoke SetTimer, hWin, TIMER_TRUMP, 100, NULL
        
    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax >= IDM_RC_FIRST && eax <= IDM_RC_LAST
		    Invoke RCMenuSelection, hWin, eax 

		.ELSEIF eax >= IDM_TM_FIRST && eax <= IDM_TM_LAST
		    Invoke TrayMenuSelection, hWin, eax         

        .ENDIF

    .ELSEIF eax == WM_NOTIFY
        mov ebx, lParam
        mov eax, (MUIDF_NOTIFY ptr [ebx]).hdr.hwndFrom
        .IF eax == hDFTrump
            mov eax, (MUIDF_NOTIFY ptr [ebx]).hdr.code
            .IF eax == MUIDFN_DOUBLECLICK

            .ELSEIF eax == MUIDFN_LEFTCLICK
                ;--------------------------------------------------------------
                ; User has 'punched' (clicked) trumps face! hurray!
                ; We then hide trump which will trigger MUIDFN_HIDE below
                ; which resets the show trump timer
                ;--------------------------------------------------------------
                Invoke PlaySoundClip, WAV_PUNCH
                Invoke MUIDesktopFaceShow, hDFTrump, FALSE
                
                ; Hide intro tip and set it to basic info
                Invoke ShowWindow, hMUITIP, SW_HIDE
                Invoke MUITooltipSetProperty, hMUITIP, @TooltipInfoTitleText, 0
                Invoke SetWindowText, hMUITIP, Addr AppName

            .ELSEIF eax == MUIDFN_RIGHTCLICK
        	    Invoke GetCursorPos, addr RCMenuPoint
        	    Invoke SetForegroundWindow, hWin 
        	    Invoke TrackPopupMenu, hRCMenuPopup, TPM_RECURSE or TPM_LEFTALIGN or TPM_LEFTBUTTON, RCMenuPoint.x, RCMenuPoint.y, NULL, hWin, NULL
        	    Invoke PostMessage, hWin, WM_NULL, 0, 0              
            
            .ELSEIF eax == MUIDFN_SHOW
                .IF bTrumpStarted == FALSE
                    Invoke PlaySoundClip, WAV_MAGA
                    mov bTrumpStarted, TRUE
                .ELSE
                    Invoke PlaySoundClip, WAV_AMERICA
                    Invoke SetTimer, hWin, TIMER_TRUMP_HIDE, SHOWTRUMPTIME, NULL
                .ENDIF

            .ELSEIF eax == MUIDFN_HIDE
                Invoke GenRandomTime, ACTION_VFAST_MIN, ACTION_VFAST_MAX
                Invoke SetTimer, hWin, TIMER_TRUMP, eax, NULL

            .ENDIF
        .ENDIF
    
    .ELSEIF eax == WM_TIMER
        mov eax, wParam
        .IF eax == TIMER_TRUMP
            Invoke KillTimer, hWin, TIMER_TRUMP
            .IF bTrumpStarted == TRUE
                ;--------------------------------------------------------------
                ; We have started so after timer fires, move the trump face
                ; to a random position and show his face for a limited time
                ; By showing trump we trigger MUIDFN_SHOW in WM_NOTIFY above
                ; which resets our hide timer
                ;--------------------------------------------------------------
                Invoke SetRandomPosition, hDFTrump
                Invoke MUIDesktopFaceShow, hDFTrump, TRUE
            .ELSE
                ;--------------------------------------------------------------
                ; When we first start program show trump face at original 
                ; created position at bottom center of workspace, and also show
                ; intro tooltip. Once user 'punches' (clicks) trumps face, 
                ; timers start and we chase him around the desktop till user 
                ; gets bored and exits. 
                ;--------------------------------------------------------------
                Invoke MUIDesktopFaceShow, hDFTrump, TRUE
                Invoke ShowWindow, hMUITIP, SW_SHOW
            .ENDIF

        .ELSEIF eax == TIMER_TRUMP_HIDE
            ;------------------------------------------------------------------
            ; User hasnt 'punched' (clicked) on trump face - they missed him!
            ; We hide him for a time before reappearing somewhere else
            ; By hiding trump we trigger MUIDFN_HIDE in WM_NOTIFY above which 
            ; resets our show timer 
            ;------------------------------------------------------------------
            Invoke KillTimer, hWin, TIMER_TRUMP_HIDE
            Invoke MUIDesktopFaceShow, hDFTrump, FALSE
        
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


;------------------------------------------------------------------------------
; InitGUI
;------------------------------------------------------------------------------
InitGUI PROC hWin:DWORD
    
    ; Load images and cursors
    Invoke LoadImage, hInstance, ANI_BOXGLOVE, IMAGE_CURSOR, 0, 0, LR_DEFAULTCOLOR
    mov hBoxGloveCursor, eax
	Invoke LoadImage, hInstance, ICO_TRUMP, IMAGE_ICON, 128,128, LR_DEFAULTCOLOR
	mov hIcoTrump, eax        
    
    ;--------------------------------------------------------------------------
    ; Create ModernUI_DesktopFace control
    ;--------------------------------------------------------------------------
    Invoke MUIDesktopFaceCreate, hWin, 0, 0, MUIDFS_POS_VERT_BOTTOM or MUIDFS_POS_HORZ_CENTER or MUIDFS_POPIN or MUIDFS_POPOUT
    mov hDFTrump, eax
    Invoke MUIDesktopFaceSetImage, hDFTrump, MUIDFIT_ICO, hIcoTrump
    Invoke MUIDesktopFaceSetProperty, hDFTrump, @DesktopFaceRegion, RGN_TRUMP
    ;--------------------------------------------------------------------------
    
    ; Set cursor to boxing glove
    Invoke SetClassLong, hDFTrump, GCL_HCURSOR, hBoxGloveCursor
    
    ; Initialize tray menu and right click menu
    Invoke RCMenuInit, hWin
    Invoke TrayMenuInit, hWin  
    
    ;--------------------------------------------------------------------------
    ; Create ModernUI_Tooltip control
    ;--------------------------------------------------------------------------
    Invoke MUITooltipCreate, hDFTrump, Addr szTrumpBotIntroText, 200, MUITTS_POS_RIGHT or MUITTS_FADEIN ;or MUITTS_TIMEOUT
    mov hMUITIP, eax
    ;Invoke MUITooltipSetProperty, hMUITIP, @TooltipOffsetX, 30d
    Invoke MUITooltipSetProperty, hMUITIP, @TooltipOffsetY, 30d
    Invoke MUITooltipSetProperty, hMUITIP, @TooltipInfoTitleText, Addr AppName
    ret
InitGUI ENDP




end start








