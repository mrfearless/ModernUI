;==============================================================================
;
; ModernUI Control - ModernUI_ProgressBar
;
; Copyright (c) 2019 by fearless
;
; All Rights Reserved
;
; http://github.com/mrfearless/ModernUI
;
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
; Permission is granted to anyone to use this software for any non-commercial 
; program. If you use the library in an application, an acknowledgement in the
; application or documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave
; the original copyright notices intact and not misrepresent the origin of the
; software. It is not allowed to claim you wrote the original software. 
; Modified files must have a clear notice that the files are modified, and not
; in the original state. This includes the name of the person(s) who modified 
; the code. 
;
; If you want to distribute or redistribute any portion of this package, you 
; will need to include the full package in it's original state, including this
; license and all the copyrights.  
;
; While distributing this package (in it's original state) is allowed, it is 
; not allowed to charge anything for this. You may not sell or include the 
; package in any commercial package without having permission of the author. 
; Neither is it allowed to redistribute any of the package's components with 
; commercial applications.
;
;==============================================================================


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

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_ProgressBar.inc

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_ProgressBarWndProc         PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ProgressBarInit            PROTO :DWORD
_MUI_ProgressBarCleanup         PROTO :DWORD
_MUI_ProgressBarPaint           PROTO :DWORD
_MUI_ProgressBarPaintText       PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ProgressBarCalcWidth       PROTO :DWORD, :DWORD
_MUI_ProgressBarPulse           PROTO :DWORD
_MUI_ProgressBarCalcPulse       PROTO :DWORD, :DWORD
_MUI_ProgressSetPulseColors     PROTO :DWORD
_MUI_ProgressGetPulseColor      PROTO :DWORD
_MUI_ProgressGetR2GColor        PROTO :DWORD
_MUI_ProgressBarDwordToAscii    PROTO :DWORD, :DWORD


;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
MUI_PROGRESSBAR_PROPERTIES      STRUCT
    dwTextColor                 DD ?
    dwTextFont                  DD ?
    dwBackColor                 DD ?
    dwProgressColor             DD ?
    dwBorderColor               DD ?
    dwPercent                   DD ?
    dwMin                       DD ?
    dwMax                       DD ?
    dwStep                      DD ?
    dwPulse                     DD ?
    dwPulseTime                 DD ?
    dwTextType                  DD ?
    dwSetTextPos                DD ?
MUI_PROGRESSBAR_PROPERTIES      ENDS

; Internal properties
_MUI_PROGRESSBAR_PROPERTIES     STRUCT
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
    dwProgressBarWidth          DD ?
    dwPulseActive               DD ?
    dwPulseStep                 DD ?
    dwPulseWidth                DD ?
    dwPulseColors               DD ?
    dwHeartbeatTimer            DD ?
_MUI_PROGRESSBAR_PROPERTIES     ENDS

RGBA        STRUCT
    Red     DB ?
    Green   DB ?
    Blue    DB ?
    Alpha   DB ?
RGBA        ENDS


.CONST
PROGRESS_TIMER_ID_HEARTBEAT     EQU 1
PROGRESS_TIMER_ID_PULSE         EQU 2
PROGRESS_HEARTBEAT_TIME         EQU 3000 ; every 5 seconds
PROGRESS_PULSE_TIME             EQU 30
PROGRESS_MAX_PULSE_STEP         EQU 30

; Internal properties
@ProgressBarEnabledState        EQU 0
@ProgressBarMouseOver           EQU 4
@ProgressBarWidth               EQU 8
@ProgressPulseActive            EQU 12
@ProgressPulseStep              EQU 16
@ProgressPulseWidth             EQU 20
@ProgressPulseColors            EQU 24
@ProgressHeartbeatTimer         EQU 28

.DATA
ALIGN 4
szMUIProgressBarClass           DB 'ModernUI_ProgressBar',0     ; Class name for creating our ModernUI_ProgressBar control
szMUIProgressBarFont            DB 'Segoe UI',0                 ; Font used for ModernUI_ProgressBar text
hMUIProgressBarFont             DD 0                            ; Handle to ModernUI_ProgressBar font (segoe ui)

; start with 186,39,33
; increase G (39) by 1 until matches R (186) 186,186,33
; then decrease R (186) until it reaches end red (33) 33,186,33
; then increase B (33) until it reach end blue (69) 33,186,69
; end with 33,186,69
; 186-39 + 186-33 = 300 / 100% pts = add 3 per color 

; https://semantic-ui.com/modules/progress.html#/examples

;RGBA <186,039,033,0>,<186,042,033,0>,<186,045,033,0>,<186,048,033,0>,<186,051,033,0>,<186,054,033,0>,<186,057,033,0>,<186,060,033,0>,<186,063,033,0>,<186,066,033,0>

R2GProgress \
    RGBA <186,069,033,0>,<186,072,033,0>,<186,075,033,0>,<186,078,033,0>,<186,081,033,0>,<186,084,033,0>,<186,087,033,0>,<186,090,033,0>,<186,093,033,0>,<186,096,033,0>
    RGBA <186,099,033,0>,<186,102,033,0>,<186,105,033,0>,<186,108,033,0>,<186,111,033,0>,<186,114,033,0>,<186,117,033,0>,<186,120,033,0>,<186,123,033,0>,<186,126,033,0>
    RGBA <186,129,033,0>,<186,132,033,0>,<186,135,033,0>,<186,138,033,0>,<186,141,033,0>,<186,144,033,0>,<186,147,033,0>,<186,150,033,0>,<186,153,033,0>,<186,156,033,0>
    RGBA <186,159,033,0>,<186,162,033,0>,<186,165,033,0>,<186,168,033,0>,<186,171,033,0>,<186,174,033,0>,<186,177,033,0>,<186,180,033,0>,<186,183,033,0>,<186,186,033,0>
    RGBA <183,186,033,0>,<180,186,033,0>,<177,186,033,0>,<174,186,033,0>,<171,186,033,0>,<168,186,033,0>,<165,186,033,0>,<162,186,033,0>,<159,186,033,0>,<156,186,033,0>
    RGBA <153,186,033,0>,<150,186,033,0>,<147,186,033,0>,<144,186,033,0>,<141,186,033,0>,<138,186,033,0>,<135,186,033,0>,<132,186,033,0>,<129,186,033,0>,<126,186,033,0>
    RGBA <123,186,033,0>,<120,186,033,0>,<117,186,033,0>,<114,186,033,0>,<111,186,033,0>,<108,186,033,0>,<105,186,033,0>,<102,186,033,0>,<099,186,033,0>,<096,186,033,0>
    RGBA <093,186,033,0>,<090,186,033,0>,<087,186,033,0>,<084,186,033,0>,<081,186,033,0>,<078,186,033,0>,<075,186,033,0>,<072,186,033,0>,<069,186,033,0>,<066,186,033,0>
    RGBA <063,186,033,0>,<060,186,033,0>,<057,186,033,0>,<054,186,033,0>,<051,186,033,0>,<048,186,033,0>,<045,186,033,0>,<042,186,033,0>,<039,186,033,0>,<036,186,033,0>
    RGBA <033,186,033,0>,<033,186,036,0>,<033,186,039,0>,<033,186,042,0>,<033,186,045,0>,<033,186,048,0>,<033,186,051,0>,<033,186,054,0>,<033,186,057,0>,<033,186,060,0>
    RGBA <033,186,063,0>


.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_ProgressBar control
;------------------------------------------------------------------------------
MUIProgressBarSetProperty PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIProgressBarSetProperty ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_ProgressBar control
;------------------------------------------------------------------------------
MUIProgressBarGetProperty PROC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIProgressBarGetProperty ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarRegister - Registers the ModernUI_ProgressBar control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_ProgressBar
;------------------------------------------------------------------------------
MUIProgressBarRegister PROC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIProgressBarClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIProgressBarClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_ProgressBarWndProc
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
        Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

MUIProgressBarRegister ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUIProgressBarCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUIProgressBarRegister

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF

    Invoke CreateWindowEx, NULL, Addr szMUIProgressBarClass, NULL, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL

    .ENDIF
    mov eax, hControl
    ret
MUIProgressBarCreate ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_ProgressBarWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        ; sets text of our control, delete if not required.
        ;Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName  
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_PROGRESSBAR_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_PROGRESSBAR_PROPERTIES ; external properties
        Invoke _MUI_ProgressBarInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_ProgressBarCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_ProgressBarPaint, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if _MUI_PROGRESS_PROPERTIES ; internal properties available
        Invoke GetWindowLong, hWin, 0
        .IF eax != 0 ; Yes they are
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_TIMER
        mov eax, wParam
        .IF eax == PROGRESS_TIMER_ID_HEARTBEAT
            IFDEF DEBUG32
            ;PrintText 'WM_TIMER::PROGRESS_TIMER_ID_HEARTBEAT'
            ENDIF
            Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
            Invoke SetTimer, hWin, PROGRESS_TIMER_ID_PULSE, PROGRESS_PULSE_TIME, NULL
        .ELSEIF eax == PROGRESS_TIMER_ID_PULSE
            Invoke _MUI_ProgressBarPulse, hWin
        .ENDIF
        ret
    
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        mov eax, wParam
        .IF eax == @ProgressBarPercent
            Invoke MUIProgressBarSetPercent, hWin, wParam
        .ELSEIF eax == @ProgressBarProgressColor
            Invoke MUISetExtProperty, hWin, wParam, lParam
            Invoke _MUI_ProgressSetPulseColors, hWin
        .ELSEIF eax == @ProgressBarPulse
            .IF lParam == FALSE ; if setting to false and already active kill timers etc
                Invoke MUIGetIntProperty, hWin, @ProgressHeartbeatTimer
                .IF eax == TRUE
                    Invoke MUISetIntProperty, hWin, @ProgressHeartbeatTimer, FALSE
                    Invoke MUISetIntProperty, hWin, @ProgressPulseActive, FALSE
                    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_HEARTBEAT
                    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
                .ENDIF
            .ELSE
                Invoke GetWindowLong, hWin, GWL_STYLE
                and eax, MUIPBS_R2G
                .IF eax == MUIPBS_R2G
                    Invoke MUISetExtProperty, hWin, wParam, FALSE
                    ret
                .ENDIF
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, lParam
        .ELSE
            Invoke MUISetExtProperty, hWin, wParam, lParam
        .ENDIF
        ret
    
    .ELSEIF eax == MUIPBM_STEP
        Invoke MUIProgressBarStep, hWin
        ret
    
    .ELSEIF eax == MUIPBM_SETPERCENT
        Invoke MUIProgressBarSetPercent, hWin, wParam
        ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_ProgressBarWndProc ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarInit - set initial default values
;------------------------------------------------------------------------------
_MUI_ProgressBarInit PROC hWin:DWORD
    LOCAL ncm:NONCLIENTMETRICS
    LOCAL lfnt:LOGFONT
    LOCAL hFont:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hWin
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF

    ; Set default initial internal property values     
    Invoke MUISetIntProperty, hWin, @ProgressBarWidth, 0

    ; Set default initial external property values 
    Invoke MUISetExtProperty, hWin, @ProgressBarTextColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hWin, @ProgressBarBackColor, MUI_RGBCOLOR(193,193,193)
    Invoke MUISetExtProperty, hWin, @ProgressBarBorderColor, MUI_RGBCOLOR(163,163,163)
    Invoke MUISetExtProperty, hWin, @ProgressBarProgressColor, MUI_RGBCOLOR(27,161,226)

    Invoke MUISetExtProperty, hWin, @ProgressBarPercent, 0
    Invoke MUISetExtProperty, hWin, @ProgressBarMin, 0
    Invoke MUISetExtProperty, hWin, @ProgressBarMax, 100

    .IF hMUIProgressBarFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hFont, eax
        Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
        mov lfnt.lfHeight, -10d
        mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUIProgressBarFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke MUISetExtProperty, hWin, @ProgressBarTextFont, hMUIProgressBarFont
    ;Invoke _MUI_ProgressBarCalcIncrementRemainder, hControl
    
    ; Create array for pulse colors
    mov eax, PROGRESS_MAX_PULSE_STEP
    add eax, 2
    mov ebx, SIZEOF DWORD
    mul ebx
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    Invoke MUISetIntProperty, hWin, @ProgressPulseColors, eax
    
    Invoke _MUI_ProgressSetPulseColors, hWin
    
    mov eax, dwStyle
    and eax, MUIPBS_NOPULSE
    .IF eax == MUIPBS_NOPULSE
        Invoke MUISetExtProperty, hWin, @ProgressBarPulse, FALSE
    .ELSE
        Invoke MUISetExtProperty, hWin, @ProgressBarPulse, TRUE
    .ENDIF
    
    Invoke MUISetExtProperty, hWin, @ProgressBarPulseTime, PROGRESS_HEARTBEAT_TIME
    
    mov eax, dwStyle
    and eax, MUIPBS_TEXT_CENTRE or MUIPBS_TEXT_FOLLOW
    .IF eax == MUIPBS_TEXT_CENTRE or MUIPBS_TEXT_FOLLOW
        Invoke MUISetExtProperty, hWin, @ProgressBarTextType, MUIPBTT_CENTRE
    .ELSEIF eax == MUIPBS_TEXT_CENTRE
        Invoke MUISetExtProperty, hWin, @ProgressBarTextType, MUIPBTT_CENTRE
    .ELSEIF eax == MUIPBS_TEXT_FOLLOW
        Invoke MUISetExtProperty, hWin, @ProgressBarTextType, MUIPBTT_FOLLOW
    .ENDIF

    mov eax, dwStyle
    and eax, MUIPBS_R2G
    .IF eax == MUIPBS_R2G
        Invoke MUISetExtProperty, hWin, @ProgressBarPulse, FALSE
    .ENDIF
    
    mov eax, TRUE
    ret
_MUI_ProgressBarInit ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarCleanup
;------------------------------------------------------------------------------
_MUI_ProgressBarCleanup PROC hWin:DWORD
    
    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_HEARTBEAT
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseColors
    .IF eax != NULL
        Invoke GlobalFree, eax
    .ENDIF
    ret
_MUI_ProgressBarCleanup ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPaint
;------------------------------------------------------------------------------
_MUI_ProgressBarPaint PROC hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rectprogress:RECT
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL Percent:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL BorderColor:DWORD
    LOCAL ProgressColor:DWORD
    LOCAL bPulseActive:DWORD
    LOCAL PulseColor:DWORD
    LOCAL ProgressWidth:DWORD

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke MUIGDIDoubleBufferStart, hWin, hdc, Addr hdcMem, Addr rect, Addr hBufferBitmap

    ;----------------------------------------------------------
    ; Get some property values
    ;---------------------------------------------------------- 
    Invoke MUIGetExtProperty, hWin, @ProgressBarTextColor
    mov TextColor, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarBackColor
    mov BackColor, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarBorderColor
    mov BorderColor, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarPercent
    mov Percent, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarProgressColor
    mov ProgressColor, eax
    Invoke MUIGetIntProperty, hWin, @ProgressPulseActive
    mov bPulseActive, eax
    Invoke CopyRect, Addr rectprogress, Addr rect

    ;----------------------------------------------------------
    ; Paint background
    ;----------------------------------------------------------
    Invoke MUIGDIPaintFill, hdcMem, Addr rect, BackColor

    ;----------------------------------------------------------
    ; Draw Progress
    ;----------------------------------------------------------
    Invoke MUIGetIntProperty, hWin, @ProgressBarWidth
    mov ProgressWidth, eax
    mov rectprogress.right, eax
    ;PrintDec ProgressColor
    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUIPBS_R2G
    .IF eax == MUIPBS_R2G
        Invoke _MUI_ProgressGetR2GColor, hWin
        mov ProgressColor, eax
        ;PrintDec ProgressColor
    .ENDIF
    Invoke MUIGDIPaintFill, hdcMem, Addr rectprogress, ProgressColor

    ;----------------------------------------------------------
    ; Draw Pulse
    ;----------------------------------------------------------
    .IF bPulseActive == TRUE
        Invoke MUIGetIntProperty, hWin, @ProgressPulseWidth
        .IF eax >= ProgressWidth
            mov eax, ProgressWidth
        .ENDIF
        mov rectprogress.right, eax
        Invoke _MUI_ProgressGetPulseColor, hWin
        mov PulseColor, eax
        Invoke MUIGDIPaintFill, hdcMem, Addr rectprogress, PulseColor
    .ENDIF
    
    ;----------------------------------------------------------
    ; Paint Percentage Text
    ;----------------------------------------------------------
    Invoke MUIGetExtProperty, hWin, @ProgressBarTextType
    .IF eax != MUIPBTT_NONE
        Invoke _MUI_ProgressBarPaintText, hWin, hdcMem, Addr rect, TextColor
    .ENDIF
    
    ;----------------------------------------------------------
    ; Paint Border
    ;----------------------------------------------------------
    Invoke MUIGDIPaintFrame, hdcMem, Addr rect, BorderColor, MUIPFS_ALL

    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Finish Double Buffering & Cleanup
    ;----------------------------------------------------------    
    Invoke MUIGDIDoubleBufferFinish, hdcMem, hBufferBitmap, 0, 0, hBrush, 0    

    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_ProgressBarPaint ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPaintText - paint percentage text
;------------------------------------------------------------------------------
_MUI_ProgressBarPaintText PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD, dwTextColor:DWORD
    LOCAL hFont:HFONT
    LOCAL hFontOld:HFONT
    LOCAL ProgressWidth:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwTextType:DWORD
    LOCAL dwTextStyle:DWORD
    LOCAL dwPercent:DWORD
    LOCAL dwLenPercentText:DWORD
    LOCAL szPercentText[8]:BYTE
    LOCAL szDisplayText[128]:BYTE
    LOCAL sz:_SIZE
    LOCAL szspace:_SIZE
    LOCAL rect:RECT

    Invoke MUIGetExtProperty, hWin, @ProgressBarTextType
    mov dwTextType, eax
    .IF eax != MUIPBTT_CENTRE && eax != MUIPBTT_FOLLOW
        ret
    .ENDIF

    Invoke CopyRect, Addr rect, lpRect
    mov eax, rect.right
    sub eax, rect.left
    mov dwWidth, eax
    
    Invoke MUIGetIntProperty, hWin, @ProgressBarWidth
    mov ProgressWidth, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarPercent
    mov dwPercent, eax
    Invoke _MUI_ProgressBarDwordToAscii, dwPercent, Addr szPercentText
    Invoke lstrcat, Addr szPercentText, CTEXT("%")
    Invoke lstrlen, Addr szPercentText
    mov dwLenPercentText, eax
    
;    Invoke GetWindowText, hWin, Addr szDisplayText, (SIZEOF szDisplayText) - 8
;    .IF eax == 0
;        Invoke lstrcpy, Addr szDisplayText, Addr szPercentText
;    .ELSE
;        Invoke MUIGetExtProperty, hWin, @ProgressBarSetTextPos
;    .ENDIF
    
    Invoke MUIGetExtProperty, hWin, @ProgressBarTextFont
    mov hFont, eax
    Invoke SelectObject, hdc, hFont
    mov hFontOld, eax
    
    Invoke GetTextExtentPoint32, hdc, CTEXT(" "), 1, Addr szspace
    Invoke GetTextExtentPoint32, hdc, Addr szPercentText, dwLenPercentText, Addr sz
    mov eax, sz.x
    .IF eax <= dwWidth

        ;Invoke SetBkMode, hdc, OPAQUE
        ;Invoke SetBkColor, hdc, BackColor
        Invoke SetBkMode, hdc, TRANSPARENT
        Invoke SetTextColor, hdc, dwTextColor
    
        mov dwTextStyle, DT_SINGLELINE or DT_VCENTER or DT_CENTER

        .IF dwTextType == MUIPBTT_CENTRE
            Invoke DrawText, hdc, Addr szPercentText, dwLenPercentText, Addr rect, dwTextStyle
        .ELSE ; MUIPBTT_FOLLOW
            mov eax, sz.x
            add eax, szspace.x
            .IF eax <= ProgressWidth
                mov eax, ProgressWidth;rect.right
                mov rect.right, eax
                sub eax, sz.x
                sub eax, szspace.x
                mov rect.left, eax
                Invoke DrawText, hdc, Addr szPercentText, dwLenPercentText, Addr rect, dwTextStyle
            .ENDIF
        .ENDIF
    .ENDIF
    
    Invoke SelectObject, hdc, hFontOld
    Invoke DeleteObject, hFontOld
    
    ret
_MUI_ProgressBarPaintText ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarCalcWidth
;------------------------------------------------------------------------------
_MUI_ProgressBarCalcWidth PROC hWin:DWORD, dwPercent:DWORD
    LOCAL rect:RECT
    LOCAL dwProgressWidth:DWORD
    LOCAL dwWidth:DWORD
    LOCAL nTmp:DWORD

    Invoke GetWindowRect, hWin, Addr rect
    
    mov eax, rect.right
    sub eax, rect.left
    mov dwWidth, eax

    mov nTmp, 100

    finit
    fild dwWidth
    fild nTmp
    fdiv
    fld st
    fild dwPercent
    fmul
    fistp dwProgressWidth
    
    ;PrintDec dwPercent
    ;PrintDec dwProgressWidth
    
    mov eax, dwProgressWidth
    ret

_MUI_ProgressBarCalcWidth ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarCalcPulse
;------------------------------------------------------------------------------
_MUI_ProgressBarCalcPulse PROC hWin:DWORD, dwPulseStep:DWORD
    LOCAL rect:RECT
    LOCAL dwPulseWidth:DWORD
    LOCAL dwWidth:DWORD
    LOCAL nTmp:DWORD
    
    Invoke GetWindowRect, hWin, Addr rect
    
    mov eax, rect.right
    sub eax, rect.left
    mov dwWidth, eax

    mov nTmp, PROGRESS_MAX_PULSE_STEP

    finit
    fild dwWidth
    fild nTmp
    fdiv
    fld st
    fild dwPulseStep
    fmul
    fistp dwPulseWidth
    
    ;PrintDec dwPulse
    ;PrintDec dwPulseWidth
    
    mov eax, dwPulseWidth
    
    ret
_MUI_ProgressBarCalcPulse ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPulse
;------------------------------------------------------------------------------
_MUI_ProgressBarPulse PROC hWin:DWORD
    LOCAL dwPulseStep:DWORD
    LOCAL dwPulseWidth:DWORD
    LOCAL dwProgressWidth:DWORD
    
    Invoke MUISetIntProperty, hWin, @ProgressPulseActive, TRUE
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseStep
    mov dwPulseStep, eax
    Invoke _MUI_ProgressBarCalcPulse, hWin, dwPulseStep
    mov dwPulseWidth, eax
    Invoke MUISetIntProperty, hWin, @ProgressPulseWidth, dwPulseWidth
    
    Invoke MUIGetIntProperty, hWin, @ProgressBarWidth
    mov dwProgressWidth, eax
    
    Invoke InvalidateRect, hWin, NULL, FALSE
    Invoke UpdateWindow, hWin
    
    mov eax, dwPulseWidth
    .IF eax > dwProgressWidth
        mov dwPulseStep, 0
        Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
        Invoke MUISetIntProperty, hWin, @ProgressPulseActive, FALSE
    .ELSE
        inc dwPulseStep
        .IF dwPulseStep >= PROGRESS_MAX_PULSE_STEP
            mov dwPulseStep, 0
            Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
            Invoke MUISetIntProperty, hWin, @ProgressPulseActive, FALSE
        .ENDIF
    .ENDIF
    
    Invoke MUISetIntProperty, hWin, @ProgressPulseStep, dwPulseStep
    Invoke InvalidateRect, hWin, NULL, FALSE
    Invoke UpdateWindow, hWin
    
    ret
_MUI_ProgressBarPulse ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressSetPulseColors
;------------------------------------------------------------------------------
_MUI_ProgressSetPulseColors PROC USES EBX ECX hWin:DWORD
    LOCAL ProgressBarColor:DWORD
    LOCAL pProgressPulseColors:DWORD
    LOCAL nPulseColor:DWORD
    LOCAL PulseColor:DWORD
    LOCAL clrRed:DWORD
    LOCAL clrGreen:DWORD
    LOCAL clrBlue:DWORD
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseColors
    .IF eax == NULL
        xor eax, eax
        ret
    .ENDIF
    mov pProgressPulseColors, eax
    
;    ; Calc last entry
;    mov eax, PROGRESS_MAX_PULSE_STEP
;    mov ebx, SIZEOF DWORD
;    mul ebx
;    add pProgressPulseColors, eax
    
    Invoke MUIGetExtProperty, hWin, @ProgressBarProgressColor
    mov ProgressBarColor, eax
    
    ; Split DWORD to individual RGB
    mov eax, ProgressBarColor
    xor ebx, ebx
    mov bl, al
    mov clrRed, ebx
    xor ebx, ebx
    mov bl, ah
    mov clrGreen, ebx
    xor ebx, ebx
    shr eax, 16d
    mov bl, al
    mov clrBlue, ebx    
    
    add clrRed, PROGRESS_MAX_PULSE_STEP+8
    add clrGreen, PROGRESS_MAX_PULSE_STEP+8
    add clrBlue, PROGRESS_MAX_PULSE_STEP+8
    .IF clrRed >= 255
        mov clrRed, 255
    .ENDIF
    .IF clrGreen >= 255
        mov clrGreen, 255
    .ENDIF
    .IF clrBlue >= 255
        mov clrBlue, 255
    .ENDIF
    
    mov eax, 0
    mov nPulseColor, 0
    .WHILE eax < PROGRESS_MAX_PULSE_STEP
        
        ; combine individual RGB back to DWORD
        xor ecx, ecx
        mov ecx, clrBlue
        shl ecx, 16d
        xor ebx, ebx
        mov ebx, clrGreen
        mov eax, clrRed
        mov ch, bl
        mov cl, al
        mov PulseColor, ecx
        
;        IFDEF DEBUG32
;        PrintDec clrRed
;        PrintDec clrGreen
;        PrintDec clrBlue
;        PrintDec PulseColor
;        ENDIF
        
        mov ebx, pProgressPulseColors
        mov [ebx], ecx
        
        dec clrRed
        dec clrGreen
        dec clrBlue
        
        add pProgressPulseColors, SIZEOF DWORD
        inc nPulseColor
        mov eax, nPulseColor
    .ENDW
    
    ; Add extra safety buffers
    mov ebx, pProgressPulseColors
    mov eax, ProgressBarColor
    mov [ebx], eax
    
    add pProgressPulseColors, SIZEOF DWORD
    mov ebx, pProgressPulseColors
    mov eax, ProgressBarColor
    mov [ebx], eax
    
    ret
_MUI_ProgressSetPulseColors ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressGetPulseColor
;------------------------------------------------------------------------------
_MUI_ProgressGetPulseColor PROC USES EBX hWin:DWORD
    LOCAL ProgressBarColor:DWORD
    LOCAL pProgressPulseColors:DWORD
    LOCAL ProgressBarWidth:DWORD
    LOCAL SinglePulseWidth:DWORD
    LOCAL maxpulse:DWORD
    LOCAL dwPulseStep:DWORD
    
    Invoke MUIGetExtProperty, hWin, @ProgressBarProgressColor
    mov ProgressBarColor, eax
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseColors
    .IF eax == NULL
        mov eax, ProgressBarColor
        ret
    .ENDIF
    mov pProgressPulseColors, eax
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseStep
    mov dwPulseStep, eax
    
    Invoke MUIGetIntProperty, hWin, @ProgressBarWidth
    mov ProgressBarWidth, eax
    
    Invoke _MUI_ProgressBarCalcPulse, hWin, 1
    mov SinglePulseWidth, eax
    
    ;PrintDec ProgressBarWidth
    ;PrintDec SinglePulseWidth
    
    finit
    fild ProgressBarWidth
    fild SinglePulseWidth
    fdiv
    fistp maxpulse
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseStep
    mov eax, PROGRESS_MAX_PULSE_STEP
    dec eax ; for 0 based index
    sub eax, maxpulse
    add eax, dwPulseStep
    .IF sdword ptr eax < 0
        mov eax, 0
    .ENDIF
    .IF eax >= PROGRESS_MAX_PULSE_STEP
        mov eax, PROGRESS_MAX_PULSE_STEP
        dec eax
    .ENDIF
    mov ebx, SIZEOF DWORD
    mul ebx
    add eax, pProgressPulseColors
    mov ebx, eax
    mov eax, [ebx]

    ret
_MUI_ProgressGetPulseColor ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressGetR2GColor
;------------------------------------------------------------------------------
_MUI_ProgressGetR2GColor PROC USES EBX hWin:DWORD
    Invoke MUIGetExtProperty, hWin, @ProgressBarPercent
    mov ebx, SIZEOF DWORD
    mul ebx
    lea ebx, R2GProgress
    add eax, ebx
    mov ebx, eax
    mov eax, [ebx] ; RGBCOLOR in eax
    ret
_MUI_ProgressGetR2GColor ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarSetMinMax
;------------------------------------------------------------------------------
MUIProgressBarSetMinMax PROC hControl:DWORD, dwMin:DWORD, dwMax:DWORD
    Invoke MUISetExtProperty, hControl, @ProgressBarMin, dwMin
    Invoke MUISetExtProperty, hControl, @ProgressBarMax, dwMax
    ret
MUIProgressBarSetMinMax ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarSetPercent
;------------------------------------------------------------------------------
MUIProgressBarSetPercent PROC hControl:DWORD, dwPercent:DWORD
    LOCAL dwOldPercent:DWORD
    LOCAL dwNewPercent:DWORD
    LOCAL dwOldWidth:DWORD
    LOCAL dwNewWidth:DWORD
    LOCAL dwCurrentWidth:DWORD

    Invoke InvalidateRect, hControl, NULL, TRUE
    Invoke UpdateWindow, hControl

    Invoke MUIGetExtProperty, hControl, @ProgressBarPercent
    mov dwOldPercent, eax
    .IF eax == dwPercent
        ret
    .ENDIF
    mov eax, dwPercent
    .IF sdword ptr eax > 100
        mov eax, 100
    .ENDIF
    .IF sdword ptr eax < 0
        mov eax, 0
    .ENDIF
    mov dwNewPercent, eax

    sub eax, dwOldPercent
    .IF sdword ptr eax > 1 ; if lots of steps to draw between old and new percent
        .IF sdword ptr dwNewPercent >= 0 && sdword ptr dwNewPercent <= 100
            Invoke _MUI_ProgressBarCalcWidth, hControl, dwOldPercent
            mov dwOldWidth, eax
            mov dwCurrentWidth, eax
    
            Invoke _MUI_ProgressBarCalcWidth, hControl, dwNewPercent
            mov dwNewWidth, eax
            
            mov eax, dwCurrentWidth
            .IF sdword ptr eax < dwNewWidth ; going up
                mov eax, dwCurrentWidth
                .WHILE sdword ptr eax <= dwNewWidth
                    Invoke MUISetIntProperty, hControl, @ProgressBarWidth, dwCurrentWidth
                    Invoke InvalidateRect, hControl, NULL, TRUE
                    Invoke UpdateWindow, hControl
                    ;Invoke Sleep, 5
                    ;PrintDec dwCurrentWidth
                    inc dwCurrentWidth
                    mov eax, dwCurrentWidth
                .ENDW
            .ELSE ; going down
                Invoke MUISetIntProperty, hControl, @ProgressBarWidth, dwNewWidth
;                mov eax, dwCurrentWidth
;                .WHILE sdword ptr eax >= dwNewWidth
;                    Invoke MUISetIntProperty, hControl, @ProgressBarWidth, dwCurrentWidth
;                    Invoke InvalidateRect, hControl, NULL, TRUE
;                    Invoke UpdateWindow, hControl
;                    Invoke Sleep, 1
;                    ;PrintDec dwCurrentWidth
;                    dec dwCurrentWidth
;                    mov eax, dwCurrentWidth
;                .ENDW
            .ENDIF
        .ENDIF
    .ELSE
        Invoke _MUI_ProgressBarCalcWidth, hControl, dwNewPercent
        Invoke MUISetIntProperty, hControl, @ProgressBarWidth, eax
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @ProgressBarPercent, dwNewPercent
    Invoke InvalidateRect, hControl, NULL, TRUE
    Invoke UpdateWindow, hControl
    
    Invoke MUIGetExtProperty, hControl, @ProgressBarPulse
    .IF eax == TRUE
        .IF dwNewPercent == 0 || dwNewPercent >= 100
            ; check if heartbeat timer is stopped, if not we stop it
            Invoke MUIGetIntProperty, hControl, @ProgressHeartbeatTimer
            .IF eax == TRUE
                Invoke MUISetIntProperty, hControl, @ProgressHeartbeatTimer, FALSE
                Invoke KillTimer, hControl, PROGRESS_TIMER_ID_HEARTBEAT
            .ENDIF
        .ELSE
            ; check if heartbeat timer is already started, if not we start it
            Invoke MUIGetIntProperty, hControl, @ProgressHeartbeatTimer
            .IF eax == FALSE
                Invoke MUISetIntProperty, hControl, @ProgressHeartbeatTimer, TRUE
                Invoke MUIGetExtProperty, hControl, @ProgressBarPulseTime
                .IF eax == 0
                    mov eax, PROGRESS_HEARTBEAT_TIME
                .ENDIF
                Invoke SetTimer, hControl, PROGRESS_TIMER_ID_HEARTBEAT, eax, NULL
            .ENDIF
        .ENDIF
    .ENDIF

    mov eax, dwNewPercent
    ret
MUIProgressBarSetPercent ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarGetPercent
;------------------------------------------------------------------------------
MUIProgressBarGetPercent PROC hControl:DWORD
    Invoke MUIGetExtProperty, hControl, @ProgressBarPercent
    ret
MUIProgressBarGetPercent ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarStep
;------------------------------------------------------------------------------
MUIProgressBarStep PROC hControl:DWORD
    Invoke MUIGetExtProperty, hControl, @ProgressBarPercent
    inc eax
    Invoke MUIProgressBarSetPercent, hControl, eax
    ret
MUIProgressBarStep ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarDwordToAscii - Paul Dixon's utoa_ex function. unsigned dword to ascii.
; Returns: Buffer pointed to by lpszAsciiString will contain ascii string
;------------------------------------------------------------------------------
OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE
_MUI_ProgressBarDwordToAscii PROC dwValue:DWORD, lpszAsciiString:DWORD
    mov eax, [esp+4]                ; uvar      : unsigned variable to convert
    mov ecx, [esp+8]                ; pbuffer   : pointer to result buffer

    push esi
    push edi

    jmp udword

  align 4
  chartab:
    dd "00","10","20","30","40","50","60","70","80","90"
    dd "01","11","21","31","41","51","61","71","81","91"
    dd "02","12","22","32","42","52","62","72","82","92"
    dd "03","13","23","33","43","53","63","73","83","93"
    dd "04","14","24","34","44","54","64","74","84","94"
    dd "05","15","25","35","45","55","65","75","85","95"
    dd "06","16","26","36","46","56","66","76","86","96"
    dd "07","17","27","37","47","57","67","77","87","97"
    dd "08","18","28","38","48","58","68","78","88","98"
    dd "09","19","29","39","49","59","69","79","89","99"

  udword:
    mov esi, ecx                    ; get pointer to answer
    mov edi, eax                    ; save a copy of the number

    mov edx, 0D1B71759h             ; =2^45\10000    13 bit extra shift
    mul edx                         ; gives 6 high digits in edx

    mov eax, 68DB9h                 ; =2^32\10000+1

    shr edx, 13                     ; correct for multiplier offset used to give better accuracy
    jz short skiphighdigits         ; if zero then don't need to process the top 6 digits

    mov ecx, edx                    ; get a copy of high digits
    imul ecx, 10000                 ; scale up high digits
    sub edi, ecx                    ; subtract high digits from original. EDI now = lower 4 digits

    mul edx                         ; get first 2 digits in edx
    mov ecx, 100                    ; load ready for later

    jnc short next1                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja   ZeroSupressed              ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    inc esi                         ; update pointer by 1
    jmp  ZS1                        ; continue with pairs of digits to the end

  align 16
  next1:
    mul ecx                         ; get next 2 digits
    jnc short next2                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja   ZS1a                       ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    add esi, 1                      ; update pointer by 1
    jmp  ZS2                        ; continue with pairs of digits to the end

  align 16
  next2:
    mul ecx                         ; get next 2 digits
    jnc short next3                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja   ZS2a                       ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    add esi, 1                      ; update pointer by 1
    jmp  ZS3                        ; continue with pairs of digits to the end

  align 16
  next3:

  skiphighdigits:
    mov eax, edi                    ; get lower 4 digits
    mov ecx, 100

    mov edx, 28F5C29h               ; 2^32\100 +1
    mul edx
    jnc short next4                 ; if zero, supress them by ignoring
    cmp edx, 9                      ; 1 digit or 2?
    ja  short ZS3a                  ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    inc esi                         ; update pointer by 1
    jmp short  ZS4                  ; continue with pairs of digits to the end

  align 16
  next4:
    mul ecx                         ; this is the last pair so don; t supress a single zero
    cmp edx, 9                      ; 1 digit or 2?
    ja  short ZS4a                  ; 2 digits, just continue with pairs of digits to the end

    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dh                   ; but only write the 1 we need, supress the leading zero
    mov byte ptr [esi+1], 0         ; zero terminate string

    pop edi
    pop esi
    ret 8

  align 16
  ZeroSupressed:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx
    add esi, 2                      ; write them to answer

  ZS1:
    mul ecx                         ; get next 2 digits
  ZS1a:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx                   ; write them to answer
    add esi, 2

  ZS2:
    mul ecx                         ; get next 2 digits
  ZS2a:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx                   ; write them to answer
    add esi, 2

  ZS3:
    mov eax, edi                    ; get lower 4 digits
    mov edx, 28F5C29h               ; 2^32\100 +1
    mul edx                         ; edx= top pair
  ZS3a:
    mov edx, chartab[edx*4]         ; look up 2 digits
    mov [esi], dx                   ; write to answer
    add esi, 2                      ; update pointer

  ZS4:
    mul ecx                         ; get final 2 digits
  ZS4a:
    mov edx, chartab[edx*4]         ; look them up
    mov [esi], dx                   ; write to answer

    mov byte ptr [esi+2], 0         ; zero terminate string

  sdwordend:

    pop edi
    pop esi
    ret 8
_MUI_ProgressBarDwordToAscii ENDP
OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef
;------------------------------------------------------------------------------


MODERNUI_LIBEND

; start with 186,39,33

;increase G (39) by 1 until matches R (186) 186,186,33
; then decrease R (186) until it reaches end red (33) 33,186,33
; then increase B (33) until it reach end blue (69) 33,186,69

; end with 33,186,69


