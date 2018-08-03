;======================================================================================================================================
;
; ModernUI Control - ModernUI_ProgressBar v1.0.0.0
;
; Copyright (c) 2016 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;======================================================================================================================================
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

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_ProgressBarWndProc                 PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ProgressBarInit                    PROTO :DWORD
_MUI_ProgressBarPaint                   PROTO :DWORD
_MUI_ProgressBarCalcWidth               PROTO :DWORD, :DWORD


;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; External public properties
MUI_PROGRESSBAR_PROPERTIES              STRUCT
    dwTextColor                         DD ?
    dwTextFont                          DD ?
    dwBackColor                         DD ?
    dwProgressColor                     DD ?
    dwBorderColor                       DD ?
    dwPercent                           DD ?
    dwMin                               DD ?
    dwMax                               DD ?
    dwStep                              DD ?
MUI_PROGRESSBAR_PROPERTIES              ENDS

; Internal properties
_MUI_PROGRESSBAR_PROPERTIES             STRUCT
    dwEnabledState                      DD ?
    dwMouseOver                         DD ?
    dwProgressBarWidth                  DD ?
_MUI_PROGRESSBAR_PROPERTIES             ENDS


.CONST
; Internal properties
@ProgressBarEnabledState                EQU 0
@ProgressBarMouseOver                   EQU 4
@ProgressBarWidth                       EQU 8
; External public properties


.DATA
szMUIProgressBarClass                   DB 'ModernUI_ProgressBar',0     ; Class name for creating our ModernUI_ProgressBar control
szMUIProgressBarFont                    DB 'Segoe UI',0                 ; Font used for ModernUI_ProgressBar text
hMUIProgressBarFont                     DD 0                            ; Handle to ModernUI_ProgressBar font (segoe ui)


.CODE

align 4

;-------------------------------------------------------------------------------------
; Set property for ModernUI_ProgressBar control
;-------------------------------------------------------------------------------------
MUIProgressBarSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIProgressBarSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for ModernUI_ProgressBar control
;-------------------------------------------------------------------------------------
MUIProgressBarGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIProgressBarGetProperty ENDP


;-------------------------------------------------------------------------------------
; MUIProgressBarRegister - Registers the ModernUI_ProgressBar control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_ProgressBar
;-------------------------------------------------------------------------------------
MUIProgressBarRegister PROC PUBLIC
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


;-------------------------------------------------------------------------------------
; MUIProgressBarCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUIProgressBarCreate PROC PRIVATE hWndParent:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUIProgressBarRegister

    Invoke CreateWindowEx, NULL, Addr szMUIProgressBarClass, NULL, WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL

    .ENDIF
    mov eax, hControl
    ret
MUIProgressBarCreate ENDP


;-------------------------------------------------------------------------------------
; _MUI_ProgressBarWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_ProgressBarWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
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
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_ProgressBarPaint, hWin
        mov eax, 0
        ret
    
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        mov eax, wParam
        .IF eax == @ProgressBarPercent
            Invoke MUIProgressBarSetPercent, hWin, wParam
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


;-------------------------------------------------------------------------------------
; _MUI_ProgressBarInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_ProgressBarInit PROC PRIVATE hControl:DWORD
    LOCAL ncm:NONCLIENTMETRICS
    LOCAL lfnt:LOGFONT
    LOCAL hFont:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hControl
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle
    .ENDIF

    ; Set default initial internal property values     
    Invoke MUISetIntProperty, hControl, @ProgressBarWidth, 0

    ; Set default initial external property values 
    Invoke MUISetExtProperty, hControl, @ProgressBarTextColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hControl, @ProgressBarBackColor, MUI_RGBCOLOR(193,193,193)
    Invoke MUISetExtProperty, hControl, @ProgressBarBorderColor, 0 ; MUI_RGBCOLOR(163,163,163)
    Invoke MUISetExtProperty, hControl, @ProgressBarProgressColor, MUI_RGBCOLOR(27,161,226)

    Invoke MUISetExtProperty, hControl, @ProgressBarPercent, 0
    Invoke MUISetExtProperty, hControl, @ProgressBarMin, 0
    Invoke MUISetExtProperty, hControl, @ProgressBarMax, 100

    .IF hMUIProgressBarFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hFont, eax
        Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
        mov lfnt.lfHeight, -12d
        mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUIProgressBarFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke MUISetExtProperty, hControl, @ProgressBarTextFont, hMUIProgressBarFont
    ;Invoke _MUI_ProgressBarCalcIncrementRemainder, hControl
    ret
_MUI_ProgressBarInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_ProgressBarPaint
;-------------------------------------------------------------------------------------
_MUI_ProgressBarPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rectprogress:RECT
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL Percent:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL BorderColor:DWORD
    LOCAL ProgressColor:DWORD

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax

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
    Invoke CopyRect, Addr rectprogress, Addr rect

    ;----------------------------------------------------------
    ; Fill background
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, BackColor
    Invoke FillRect, hdcMem, Addr rect, hBrush

    ;----------------------------------------------------------
    ; Draw Progress
    ;----------------------------------------------------------
    .IF hOldBrush != 0
        Invoke SelectObject, hdcMem, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @ProgressBarWidth
    mov rectprogress.right, eax

    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, ProgressColor
    Invoke FillRect, hdcMem, Addr rectprogress, hBrush

    ;----------------------------------------------------------
    ; Border
    ;----------------------------------------------------------
    .IF BorderColor != 0
        .IF hOldBrush != 0
            Invoke SelectObject, hdcMem, hOldBrush
            Invoke DeleteObject, hOldBrush
        .ENDIF     
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdcMem, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdcMem, BorderColor
        Invoke FrameRect, hdcMem, Addr rect, hBrush
    .ENDIF

    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    .IF hOldBrush != 0
        Invoke SelectObject, hdcMem, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem

    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_ProgressBarPaint ENDP


;-------------------------------------------------------------------------------------
; _MUI_ProgressBarCalcWidth ;ECX EDX
;-------------------------------------------------------------------------------------
_MUI_ProgressBarCalcWidth PROC USES EBX hControl:DWORD, dwPercent:DWORD
    LOCAL rect:RECT
    LOCAL dwProgressWidth:DWORD
    LOCAL dwWidth:DWORD
    LOCAL nTmp:DWORD

    Invoke GetWindowRect, hControl, Addr rect
    
    mov eax, rect.right
    mov ebx, rect.left
    sub eax, ebx
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


;-------------------------------------------------------------------------------------
; MUIProgressBarSetMinMax
;-------------------------------------------------------------------------------------
MUIProgressBarSetMinMax PROC hControl:DWORD, dwMin:DWORD, dwMax:DWORD
    Invoke MUISetExtProperty, hControl, @ProgressBarMin, dwMin
    Invoke MUISetExtProperty, hControl, @ProgressBarMax, dwMax
    ret
MUIProgressBarSetMinMax ENDP


;-------------------------------------------------------------------------------------
; MUIProgressBarSetPercent
;-------------------------------------------------------------------------------------
MUIProgressBarSetPercent PROC hControl:DWORD, dwPercent:DWORD
    LOCAL dwOldPercent:DWORD
    LOCAL dwNewPercent:DWORD
    LOCAL dwOldWidth:DWORD
    LOCAL dwNewWidth:DWORD
    LOCAL dwCurrentWidth:DWORD

    Invoke MUIGetExtProperty, hControl, @ProgressBarPercent
    mov dwOldPercent, eax
    
    mov eax, dwPercent
    mov dwNewPercent, eax

    .IF sdword ptr dwNewPercent >= 0 && sdword ptr dwNewPercent <= 100
        ;Invoke MUISetExtProperty, hControl, @ProgressBarPercent, dwPercent
        ;Invoke InvalidateRect, hControl, NULL, TRUE
        ;PrintDec dwOldPercent
        ;PrintDec dwNewPercent

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
                Invoke InvalidateRect, hControl, NULL, FALSE
                Invoke UpdateWindow, hControl
                ;Invoke Sleep, 1
                ;PrintDec dwCurrentWidth
                inc dwCurrentWidth
                mov eax, dwCurrentWidth
            .ENDW
        
        .ELSE ; going down
            mov eax, dwCurrentWidth
            .WHILE sdword ptr eax >= dwNewWidth
            
                Invoke MUISetIntProperty, hControl, @ProgressBarWidth, dwCurrentWidth
                Invoke InvalidateRect, hControl, NULL, FALSE
                Invoke UpdateWindow, hControl
                ;Invoke Sleep, 1
                ;PrintDec dwCurrentWidth
                dec dwCurrentWidth
                mov eax, dwCurrentWidth
            .ENDW
        
        .ENDIF

        Invoke MUISetExtProperty, hControl, @ProgressBarPercent, dwNewPercent        
        Invoke UpdateWindow, hControl
    .ENDIF

    mov eax, dwNewPercent
    ret
MUIProgressBarSetPercent ENDP


;-------------------------------------------------------------------------------------
; MUIProgressBarGetPercent
;-------------------------------------------------------------------------------------
MUIProgressBarGetPercent PROC hControl:DWORD
    Invoke MUIGetExtProperty, hControl, @ProgressBarPercent
    ret
MUIProgressBarGetPercent ENDP


;-------------------------------------------------------------------------------------
; MUIProgressBarStep
;-------------------------------------------------------------------------------------
MUIProgressBarStep PROC hControl:DWORD
    LOCAL dwOldPercent:DWORD
    LOCAL dwNewPercent:DWORD
    LOCAL dwOldWidth:DWORD
    LOCAL dwNewWidth:DWORD
    LOCAL dwCurrentWidth:DWORD

    Invoke MUIGetExtProperty, hControl, @ProgressBarPercent
    mov dwOldPercent, eax
    inc eax
    mov dwNewPercent, eax
    .IF sdword ptr dwNewPercent >= 0 && sdword ptr dwNewPercent <= 100

        Invoke _MUI_ProgressBarCalcWidth, hControl, dwOldPercent
        mov dwOldWidth, eax
        mov dwCurrentWidth, eax

        Invoke _MUI_ProgressBarCalcWidth, hControl, dwNewPercent
        mov dwNewWidth, eax
        
        mov eax, dwCurrentWidth
        .WHILE sdword ptr eax <= dwNewWidth
        
            Invoke MUISetIntProperty, hControl, @ProgressBarWidth, dwCurrentWidth
            Invoke InvalidateRect, hControl, NULL, FALSE
            Invoke UpdateWindow, hControl
            Invoke Sleep, 1
            inc dwCurrentWidth
            mov eax, dwCurrentWidth
        .ENDW

        Invoke MUISetExtProperty, hControl, @ProgressBarPercent, dwNewPercent

    .ENDIF
    mov eax, dwNewPercent
    ret
MUIProgressBarStep ENDP










END
