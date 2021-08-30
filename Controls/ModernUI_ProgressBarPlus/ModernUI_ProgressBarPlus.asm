;==============================================================================
;
; ModernUI Control - ModernUI_ProgressBarPlus (GDI+ version)
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

ECHO MUI_USEGDIPLUS
include gdiplus.inc
include ole32.inc
includelib gdiplus.lib
includelib ole32.lib

include ModernUI_ProgressBarPlus.inc

IFNDEF FP4
    FP4 MACRO value
    LOCAL vname
    .data
    align 4
      vname REAL4 value
    .code
    EXITM <vname>
    ENDM
ENDIF

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusWndProc             PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ProgressBarPlusInit                PROTO :DWORD
_MUI_ProgressBarPlusCleanup             PROTO :DWORD
_MUI_ProgressBarPlusPaint               PROTO :DWORD
_MUI_ProgressBarPlusCalcWidth           PROTO :DWORD, :DWORD, :DWORD
_MUI_ProgressBarPlusCalcPulse           PROTO :DWORD, :DWORD, :DWORD
_MUI_ProgressBarPlusPulse               PROTO :DWORD
_MUI_ProgressBarPlusSetPulseColors      PROTO :DWORD
_MUI_ProgressBarPlusGetPulseColor       PROTO :DWORD
_MUI_RectToRealRect                     PROTO :DWORD, :DWORD

;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
MUI_PROGRESSBARPLUS_PROPERTIES          STRUCT
    dwTextColor                         DD ?
    dwTextFont                          DD ?
    dwBackColor                         DD ?
    dwProgressColor                     DD ?
    dwBorderColor                       DD ?
    dwPercent                           DD ?
    dwMin                               DD ?
    dwMax                               DD ?
    dwStep                              DD ?
    dwPulse                             DD ?
MUI_PROGRESSBARPLUS_PROPERTIES          ENDS

; Internal properties
_MUI_PROGRESSBARPLUS_PROPERTIES         STRUCT
    dwEnabledState                      DD ?
    dwMouseOver                         DD ?
    dwProgressBarWidth                  REAL4 ?
    dwPulseActive                       DD ?
    dwPulseStep                         DD ?
    dwPulseWidth                        REAL4 ?
    dwPulseColors                       DD ?
    dwHeartbeatTimer                    DD ?
_MUI_PROGRESSBARPLUS_PROPERTIES         ENDS

IFNDEF GDIPLUSRECT
GDIPLUSRECT     STRUCT
    left        REAL4 ?
    top	        REAL4 ?
    right	    REAL4 ?
    bottom	    REAL4 ?
GDIPLUSRECT     ENDS
ENDIF

.CONST
PROGRESS_TIMER_ID_HEARTBEAT             EQU 1
PROGRESS_TIMER_ID_PULSE                 EQU 2
PROGRESS_HEARTBEAT_TIME                 EQU 3000 ; every 5 seconds
PROGRESS_PULSE_TIME                     EQU 30
PROGRESS_MAX_PULSE_STEP                 EQU 30

; Internal properties
@ProgressBarPlusEnabledState            EQU 0
@ProgressBarPlusMouseOver               EQU 4
@ProgressBarWidth                       EQU 8
@ProgressPulseActive                    EQU 12
@ProgressPulseStep                      EQU 16
@ProgressPulseWidth                     EQU 20
@ProgressPulseColors                    EQU 24
@ProgressHeartbeatTimer                 EQU 28

.DATA
ALIGN 4
szMUIProgressBarPlusClass               DB 'ModernUI_ProgressBarPlus',0 ; Class name for creating our ModernUI_ProgressBarPlus control
szMUIProgressBarPlusFont                DB 'Segoe UI',0                 ; Font used for ModernUI_ProgressBarPlus text
hMUIProgressBarPlusFont                 DD 0                            ; Handle to ModernUI_ProgressBarPlus font (segoe ui)


.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_ProgressBarPlus control
;------------------------------------------------------------------------------
MUIProgressBarPlusSetProperty PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIProgressBarPlusSetProperty ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_ProgressBarPlus control
;------------------------------------------------------------------------------
MUIProgressBarPlusGetProperty PROC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIProgressBarPlusGetProperty ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarPlusRegister - Registers the ModernUI_ProgressBarPlus control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_ProgressBarPlus
;------------------------------------------------------------------------------
MUIProgressBarPlusRegister PROC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIProgressBarPlusClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIProgressBarPlusClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_ProgressBarPlusWndProc
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

MUIProgressBarPlusRegister ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarPlusCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUIProgressBarPlusCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUIProgressBarPlusRegister

    Invoke CreateWindowEx, NULL, Addr szMUIProgressBarPlusClass, NULL, WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL

    .ENDIF
    mov eax, hControl
    ret
MUIProgressBarPlusCreate ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPlusWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        ; sets text of our control, delete if not required.
        ;Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName  
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, MUI_INTERNAL_PROPERTIES, SIZEOF _MUI_PROGRESSBARPLUS_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, MUI_EXTERNAL_PROPERTIES, SIZEOF MUI_PROGRESSBARPLUS_PROPERTIES ; external properties
        Invoke MUIGDIPlusStart
        Invoke _MUI_ProgressBarPlusInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_ProgressBarPlusCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, MUI_INTERNAL_PROPERTIES
        Invoke MUIFreeMemProperties, hWin, MUI_EXTERNAL_PROPERTIES
        Invoke MUIGDIPlusFinish
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_ProgressBarPlusPaint, hWin
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
            Invoke _MUI_ProgressBarPlusPulse, hWin
        .ENDIF
        ret
    
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        mov eax, wParam
        .IF eax == @ProgressBarPlusPercent
            Invoke MUIProgressBarPlusSetPercent, hWin, wParam
        .ELSEIF eax == @ProgressBarPlusProgressColor
            Invoke MUISetExtProperty, hWin, wParam, lParam
            Invoke _MUI_ProgressBarPlusSetPulseColors, hWin
        .ELSEIF eax == @ProgressBarPlusPulse
            .IF lParam == FALSE ; if setting to false and already active kill timers etc
                Invoke MUIGetIntProperty, hWin, @ProgressHeartbeatTimer
                .IF eax == TRUE
                    Invoke MUISetIntProperty, hWin, @ProgressHeartbeatTimer, FALSE
                    Invoke MUISetIntProperty, hWin, @ProgressPulseActive, FALSE
                    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_HEARTBEAT
                    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
                .ENDIF
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, lParam
        .ELSE
            Invoke MUISetExtProperty, hWin, wParam, lParam
        .ENDIF
        ret
    
    .ELSEIF eax == MUIPBPM_STEP
        Invoke MUIProgressBarPlusStep, hWin
        ret
    
    .ELSEIF eax == MUIPBPM_SETPERCENT
        Invoke MUIProgressBarPlusSetPercent, hWin, wParam
        ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_ProgressBarPlusWndProc ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPlusInit - set initial default values
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusInit PROC hWin:DWORD
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
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusTextColor, MUI_ARGBCOLOR(255,255,255,255)
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusBackColor, MUI_ARGBCOLOR(255,193,193,193)
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusBorderColor, MUI_ARGBCOLOR(255,163,163,163)
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusProgressColor, MUI_ARGBCOLOR(255,27,161,226)

    Invoke MUISetExtProperty, hWin, @ProgressBarPlusPercent, 0
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusMin, 0
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusMax, 100

    .IF hMUIProgressBarPlusFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hFont, eax
        Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
        mov lfnt.lfHeight, -12d
        mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUIProgressBarPlusFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusTextFont, hMUIProgressBarPlusFont
    ;Invoke _MUI_ProgressBarCalcIncrementRemainder, hControl
    
    ; Create array for pulse colors
    mov eax, PROGRESS_MAX_PULSE_STEP
    add eax, 2
    mov ebx, SIZEOF DWORD
    mul ebx
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    Invoke MUISetIntProperty, hWin, @ProgressPulseColors, eax
    
    Invoke _MUI_ProgressBarPlusSetPulseColors, hWin
    
    Invoke MUISetExtProperty, hWin, @ProgressBarPlusPulse, TRUE
    
    mov eax, TRUE
    ret
_MUI_ProgressBarPlusInit ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPlusCleanup
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusCleanup PROC hWin:DWORD
    
    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_HEARTBEAT
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseColors
    .IF eax != NULL
        Invoke GlobalFree, eax
    .ENDIF
    ret
_MUI_ProgressBarPlusCleanup ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPaint
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusPaint PROC hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rectprogress:RECT
    LOCAL rect:RECT
    LOCAL gdiprect:GDIPLUSRECT
    LOCAL hdc:HDC
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL pBitmap:DWORD
    LOCAL pBrush:DWORD
    LOCAL pPen:DWORD
    LOCAL Percent:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL BorderColor:DWORD
    LOCAL ProgressColor:DWORD
    LOCAL bPulseActive:DWORD
    LOCAL dwPulseStep:DWORD
    LOCAL PulseColor:DWORD
    LOCAL ProgressWidth:REAL4
    LOCAL PulseWidth:REAL4

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    mov pGraphics, 0
    mov pGraphicsBuffer, 0
    mov pBitmap, 0
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect
    Invoke _MUI_RectToRealRect, Addr rect, Addr gdiprect
    
    Invoke GdipCreateFromHDC, hdc, Addr pGraphics
    Invoke MUIGDIPlusDoubleBufferStart, hWin, pGraphics, Addr pBitmap, Addr pGraphicsBuffer
    
    Invoke GdipSetPageUnit, pGraphicsBuffer, UnitPixel     
    invoke GdipSetSmoothingMode, pGraphicsBuffer, SmoothingModeAntiAlias
    invoke GdipSetPixelOffsetMode, pGraphicsBuffer, PixelOffsetModeHighQuality
    invoke GdipSetInterpolationMode, pGraphicsBuffer, InterpolationModeHighQualityBicubic   
    
    ;----------------------------------------------------------
    ; Get some property values
    ;---------------------------------------------------------- 
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusTextColor
    mov TextColor, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusBackColor
    mov BackColor, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusBorderColor
    mov BorderColor, eax
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusPercent        
    mov Percent, eax    
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusProgressColor
    mov ProgressColor, eax
    Invoke MUIGetIntProperty, hWin, @ProgressPulseActive
    mov bPulseActive, eax
    Invoke CopyRect, Addr rectprogress, Addr rect

    ;----------------------------------------------------------
    ; Fill background
    ;----------------------------------------------------------
    Invoke GdipCreateSolidFill, BackColor, Addr pBrush
    Invoke GdipFillRectangleI, pGraphicsBuffer, pBrush, rect.left, rect.top, rect.right, rect.bottom
    Invoke GdipDeleteBrush, pBrush

    ;----------------------------------------------------------
    ; Draw Progress
    ;----------------------------------------------------------
    .IF Percent != 0
        Invoke GdipCreateSolidFill, ProgressColor, Addr pBrush
        Invoke _MUI_ProgressBarPlusCalcWidth, hWin, Percent, Addr gdiprect.right
        
        ;Invoke MUIGetIntProperty, hWin, (MUI_PROPERTY_ADDRESS OR @ProgressBarWidth)
        ;fld qword ptr [eax]
        ;fstp gdiprect.right
        Invoke GdipFillRectangle, pGraphicsBuffer, pBrush, gdiprect.left, gdiprect.top, gdiprect.right, gdiprect.bottom
        Invoke GdipDeleteBrush, pBrush
    .ENDIF
    
    ;----------------------------------------------------------
    ; Draw Pulse
    ;----------------------------------------------------------
    .IF bPulseActive == TRUE
    
        Invoke MUIGetIntProperty, hWin, @ProgressPulseStep
        mov dwPulseStep, eax
        
        Invoke _MUI_ProgressBarPlusCalcPulse, hWin, dwPulseStep, Addr PulseWidth
        
        finit
        fld gdiprect.right
        fld PulseWidth
        fcom                ; compare ST(0) with the value of the real8_var variable
        fstsw ax            ; copy the Status Word containing the result to AX
        fwait               ; insure the previous instruction is completed
        sahf                ; transfer the condition codes to the CPU's flag register
        fstp st(0)          ; pop stack
        ja pulsewidth_greater    
        
        fld PulseWidth
        fstp gdiprect.right
    
pulsewidth_greater:    
        
        Invoke _MUI_ProgressBarPlusGetPulseColor, hWin
        mov PulseColor, eax
        
        Invoke GdipCreateSolidFill, PulseColor, Addr pBrush
        Invoke GdipFillRectangle, pGraphicsBuffer, pBrush, gdiprect.left, gdiprect.top, gdiprect.right, gdiprect.bottom
        Invoke GdipDeleteBrush, pBrush
    .ENDIF

    ;----------------------------------------------------------
    ; Border
    ;----------------------------------------------------------
    .IF BorderColor != 0
        Invoke GdipCreatePen1, BorderColor, FP4(1.0), UnitPixel, Addr pPen
        Invoke GdipDrawRectangleI, pGraphicsBuffer, pPen, rect.left, rect.top, rect.right, rect.bottom
        Invoke GdipDeletePen, pPen
    .ENDIF

    ;----------------------------------------------------------
    ; finish the double buffering, which ends with copying our layered bitmap to pGraphics (HDC)
    ;----------------------------------------------------------
    ;Invoke GdipDrawImageRectRectI, pGraphics, pBitmap, 0, 0, rect.right, rect.bottom, 0, 0, rect.right, rect.bottom, NULL, NULL, NULL, NULL
    ;Invoke GdipDrawImage, pGraphics, pBitmap, FP4(0.0), FP4(0.0)
    ;Invoke GdipDrawImageI, pGraphics, pBitmap, 0, 0
    Invoke MUIGDIPlusDoubleBufferFinish, hWin, pGraphics, pBitmap, pGraphicsBuffer 

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    .IF pGraphics != 0
        Invoke GdipDeleteGraphics, pGraphics
    .ENDIF

    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_ProgressBarPlusPaint ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPlusCalcWidth
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusCalcWidth PROC USES EBX hWin:DWORD, dwPercent:DWORD, lpProgressWidth:DWORD
    LOCAL rect:RECT
    LOCAL dwWidth:DWORD
    LOCAL nTmp:DWORD
    LOCAL ProgressWidth:REAL4

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
    fstp ProgressWidth
    
    mov ebx, lpProgressWidth
    mov eax, ProgressWidth
    mov [ebx], eax
    
    xor eax, eax
    ret
_MUI_ProgressBarPlusCalcWidth ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPlusCalcPulse
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusCalcPulse PROC USES EBX hWin:DWORD, dwPulseStep:DWORD, lpPulseWidth:DWORD
    LOCAL rect:RECT
    LOCAL dwWidth:DWORD
    LOCAL nTmp:DWORD
    LOCAL PulseWidth:REAL4
    
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
    fstp PulseWidth
    
    mov ebx, lpPulseWidth
    mov eax, PulseWidth
    mov [ebx], eax
    
    xor eax, eax
    ret
_MUI_ProgressBarPlusCalcPulse ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressBarPlusPulse
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusPulse PROC USES EBX hWin:DWORD
    LOCAL dwPercent:DWORD
    LOCAL dwPulseStep:DWORD
    LOCAL PulseWidth:REAL4
    LOCAL ProgressWidth:REAL4
    
    Invoke MUISetIntProperty, hWin, @ProgressPulseActive, TRUE
    
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusPercent
    mov dwPercent, eax
    Invoke MUIGetIntProperty, hWin, @ProgressPulseStep
    mov dwPulseStep, eax
    
    Invoke _MUI_ProgressBarPlusCalcWidth, hWin, dwPercent, Addr ProgressWidth
    Invoke _MUI_ProgressBarPlusCalcPulse, hWin, dwPulseStep, Addr PulseWidth
    
    Invoke InvalidateRect, hWin, NULL, FALSE
    Invoke UpdateWindow, hWin
    
    finit
    fld ProgressWidth
    fld PulseWidth
    fcom                ; compare ST(0) with the value of the real8_var variable
    fstsw ax            ; copy the Status Word containing the result to AX
    fwait               ; insure the previous instruction is completed
    sahf                ; transfer the condition codes to the CPU's flag register
    fstp st(0)          ; pop stack
    ja pulse_greater    
    jmp pulse_equ_orless
    
pulse_greater:    

    mov dwPulseStep, 0
    Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
    Invoke MUISetIntProperty, hWin, @ProgressPulseActive, FALSE
    jmp PlusPulseEnd
    
pulse_equ_orless:

    inc dwPulseStep
    .IF dwPulseStep >= PROGRESS_MAX_PULSE_STEP
        mov dwPulseStep, 0
        Invoke KillTimer, hWin, PROGRESS_TIMER_ID_PULSE
        Invoke MUISetIntProperty, hWin, @ProgressPulseActive, FALSE
    .ENDIF
    
PlusPulseEnd:
    Invoke MUISetIntProperty, hWin, @ProgressPulseStep, dwPulseStep
    Invoke InvalidateRect, hWin, NULL, FALSE
    Invoke UpdateWindow, hWin
    
    ret
_MUI_ProgressBarPlusPulse ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressSetPulseColors
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusSetPulseColors PROC USES EBX ECX EDX hWin:DWORD
    LOCAL ProgressBarColor:DWORD
    LOCAL pProgressPulseColors:DWORD
    LOCAL nPulseColor:DWORD
    LOCAL PulseColor:DWORD
    LOCAL clrRed:DWORD
    LOCAL clrGreen:DWORD
    LOCAL clrBlue:DWORD
    LOCAL clrAlpha:DWORD
    
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
    
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusProgressColor
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
    mov bl, ah
    mov clrAlpha, ebx
    
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
    .IF clrAlpha >= 255
        mov clrAlpha, 255
    .ENDIF
    
    mov eax, 0
    mov nPulseColor, 0
    .WHILE eax < PROGRESS_MAX_PULSE_STEP
        
        ; combine individual RGB back to DWORD
        xor edx, edx
        mov edx, clrAlpha
        xor ecx, ecx
        mov ecx, clrBlue
        mov ch, dl
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
_MUI_ProgressBarPlusSetPulseColors ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ProgressGetPulseColor
;------------------------------------------------------------------------------
_MUI_ProgressBarPlusGetPulseColor PROC USES EBX hWin:DWORD
    LOCAL ProgressBarColor:DWORD
    LOCAL pProgressPulseColors:DWORD
    LOCAL ProgressBarWidth:REAL4
    LOCAL SinglePulseWidth:REAL4
    LOCAL maxpulse:DWORD
    LOCAL dwPulseStep:DWORD
    LOCAL dwPercent:DWORD
    
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusProgressColor
    mov ProgressBarColor, eax
    
    Invoke MUIGetIntProperty, hWin, @ProgressPulseColors
    .IF eax == NULL
        mov eax, ProgressBarColor
        ret
    .ENDIF
    mov pProgressPulseColors, eax
    
    Invoke MUIGetExtProperty, hWin, @ProgressBarPlusPercent
    mov dwPercent, eax

    Invoke MUIGetIntProperty, hWin, @ProgressPulseStep
    mov dwPulseStep, eax

    Invoke _MUI_ProgressBarPlusCalcWidth, hWin, dwPercent, Addr ProgressBarWidth
    Invoke _MUI_ProgressBarPlusCalcPulse, hWin, 1, Addr SinglePulseWidth
    
    ;Invoke MUIGetIntProperty, hWin, @ProgressBarWidth
    ;mov ProgressBarWidth, eax
    
    ;Invoke _MUI_ProgressBarCalcPulse, hWin, 1
    ;mov SinglePulseWidth, eax
    
    ;PrintDec ProgressBarWidth
    ;PrintDec SinglePulseWidth
    
    finit
    fld ProgressBarWidth
    fld SinglePulseWidth
    fdiv
    fistp maxpulse
    
    ;inc maxpulse
    ;inc maxpulse
    ;PrintDec maxpulse
    
    
    ;mov pulse, eax
    ;PrintDec pulse
    ;mov eax, PROGRESS_MAX_PULSE_STEP
    ;sub eax, maxpulse
    ;add eax, pulse
    ;PrintDec eax
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
_MUI_ProgressBarPlusGetPulseColor ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarPlusSetMinMax
;------------------------------------------------------------------------------
MUIProgressBarPlusSetMinMax PROC hControl:DWORD, dwMin:DWORD, dwMax:DWORD
    Invoke MUISetExtProperty, hControl, @ProgressBarPlusMin, dwMin
    Invoke MUISetExtProperty, hControl, @ProgressBarPlusMax, dwMax
    ret
MUIProgressBarPlusSetMinMax ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarPlusSetPercent
;------------------------------------------------------------------------------
MUIProgressBarPlusSetPercent PROC hControl:DWORD, dwPercent:DWORD
    LOCAL PercentSmoothCurrent:DWORD
    LOCAL PercentSmoothMax:DWORD
    LOCAL dwOldWidth:DWORD
    LOCAL dwNewWidth:DWORD
    LOCAL dwCurrentWidth:DWORD

    Invoke MUIGetExtProperty, hControl, @ProgressBarPlusPercent
    mov PercentSmoothCurrent, eax
    .IF eax == dwPercent
        jmp SetPercentEnd
        ret
    .ENDIF
    
    mov eax, dwPercent
    .IF sdword ptr eax < 0 ; some error checking to make sure we are not below 0 or over 100 for our percentage
        mov eax, 0
    .ENDIF
    .IF sdword ptr eax > 100
        mov eax, 100
    .ENDIF
    mov PercentSmoothMax, eax
    
    mov eax, PercentSmoothCurrent
    .IF sdword ptr eax < PercentSmoothMax ; Going up - so we increment in our loop
        mov eax, PercentSmoothCurrent
        .WHILE sdword ptr eax <= PercentSmoothMax
            Invoke MUISetExtProperty, hControl, @ProgressBarPlusPercent, PercentSmoothCurrent
            Invoke InvalidateRect, hControl, NULL, TRUE ; redraw progress
            Invoke UpdateWindow, hControl
            Invoke Sleep, 5
            inc PercentSmoothCurrent
            mov eax, PercentSmoothCurrent
        .ENDW 

    .ELSE ; Going back down - so we decrement in our loop
        mov eax, PercentSmoothCurrent
        .WHILE sdword ptr eax >= PercentSmoothMax
            Invoke MUISetExtProperty, hControl, @ProgressBarPlusPercent, PercentSmoothCurrent
            Invoke InvalidateRect, hControl, NULL, TRUE ; redraw progress
            Invoke UpdateWindow, hControl
            Invoke Sleep, 5
            dec PercentSmoothCurrent
            mov eax, PercentSmoothCurrent
        .ENDW  
    .ENDIF
    
SetPercentEnd:
    
    Invoke MUIGetExtProperty, hControl, @ProgressBarPlusPulse
    .IF eax == TRUE
        .IF dwPercent == 0 || dwPercent >= 100
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
                Invoke SetTimer, hControl, PROGRESS_TIMER_ID_HEARTBEAT, PROGRESS_HEARTBEAT_TIME, NULL
            .ENDIF
        .ENDIF
    .ENDIF

    mov eax, dwPercent
    ret
MUIProgressBarPlusSetPercent ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarPlusGetPercent
;------------------------------------------------------------------------------
MUIProgressBarPlusGetPercent PROC hControl:DWORD
    Invoke MUIGetExtProperty, hControl, @ProgressBarPlusPercent
    ret
MUIProgressBarPlusGetPercent ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUIProgressBarPlusStep
;------------------------------------------------------------------------------
MUIProgressBarPlusStep PROC hControl:DWORD
    Invoke MUIGetExtProperty, hControl, @ProgressBarPlusPercent
    inc eax
    Invoke MUIProgressBarPlusSetPercent, hControl, eax
    ret
MUIProgressBarPlusStep ENDP

MUI_ALIGN
;-------------------------------------------------------------------------------------
; Convert normal rect structure to GDIRECT REAL4 rect structure.
; Pass Addr of dwRect struct (to convert from) & Addr of RealRect Struct to convert to
;-------------------------------------------------------------------------------------
_MUI_RectToRealRect PROC USES EBX EDX lpRect:DWORD, lpRealRect:DWORD
    mov ebx, lpRect
    mov edx, lpRealRect
    finit
    fild [ebx].RECT.left
    lea	eax, [edx].GDIPLUSRECT.left
    fstp real4 ptr [eax]
    fild [ebx].RECT.top
    lea	eax, [edx].GDIPLUSRECT.top
    fstp real4 ptr [eax]
    fild [ebx].RECT.right
    lea	eax, [edx].GDIPLUSRECT.right
    fstp real4 ptr [eax]
    fild [ebx].RECT.bottom
    lea	eax, [edx].GDIPLUSRECT.bottom
    fstp real4 ptr [eax]
    ret
_MUI_RectToRealRect endp






MODERNUI_LIBEND
