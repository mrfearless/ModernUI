;==============================================================================
;
; ModernUI Control - ModernUI_Spinner
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

IFDEF MUI_USEGDIPLUS
ECHO MUI_USEGDIPLUS
include gdiplus.inc
include ole32.inc
includelib gdiplus.lib
includelib ole32.lib
ELSE
ECHO MUI_DONTUSEGDIPLUS
ENDIF

include ModernUI_Spinner.inc

SPINNER_USE_TIMERQUEUE                 EQU 1 ; comment out to use WM_SETIMER instead of TimerQueue
;SPINNER_USE_MMTIMER                    EQU 1 ; comment out to use WM_SETIMER or TimerQueue - otherwise overrides WM_SETIMER and TimerQueue

IFDEF SPINNER_USE_MMTIMER
include winmm.inc
includelib winmm.lib
ECHO *** ModernUI_Spinner - Using Multimedia Timer ***
ELSE
IFDEF SPINNER_USE_TIMERQUEUE
ECHO *** ModernUI_Spinner - Using TimerQueue ***
ELSE
ECHO *** ModernUI_Spinner - Using WM_TIMER ***
ENDIF
ENDIF

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_SpinnerWndProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SpinnerInit					PROTO :DWORD
_MUI_SpinnerCleanup					PROTO :DWORD
_MUI_SpinnerPaint					PROTO :DWORD
_MUI_SpinnerPaintBackground         PROTO :DWORD, :DWORD, :DWORD
_MUI_SpinnerPaintImages             PROTO :DWORD, :DWORD, :DWORD, :DWORD
;_MUI_SpinnerPaintBorder             PROTO :DWORD, :DWORD, :DWORD
_MUI_SpinnerFrame                   PROTO :DWORD
_MUI_SpinnerNextFrameIndex          PROTO :DWORD
IFDEF MUI_USEGDIPLUS
_MUI_SpinnerLoadPng                 PROTO :DWORD, :DWORD
ENDIF
_MUI_SpinnerRotateCenterImage       PROTO :DWORD,:REAL4 ; hImage, fAngle
IFDEF SPINNER_USE_MMTIMER
_MUI_SpinnerMMTimerProc             PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ELSE
IFDEF SPINNER_USE_TIMERQUEUE
_MUI_SpinnerTimerProc               PROTO :DWORD, :DWORD
ENDIF
ENDIF


;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
MUI_SPINNER_PROPERTIES				STRUCT
	dwSpinnerBackColor				DD ?
	dwSpinnerSpeed                  DD ?
    dwSpinnerDllInstance            DD ?
MUI_SPINNER_PROPERTIES				ENDS

; Internal properties
_MUI_SPINNER_PROPERTIES				STRUCT
	dwMouseOver						DD ?
    dwSpinnerTotalFrames            DD ?
    dwSpinnerFrameIndex             DD ?
    dwSpinnerFramesArray            DD ?  ; points to array of SPINNER_FRAME structures for handle to each spinner step image
    dwSpinnerImageType              DD ?  ; BMP, ICO or PNG
    IFDEF SPINNER_USE_MMTIMER
    hTimer                          DD ?
    ELSE
    IFDEF SPINNER_USE_TIMERQUEUE
    bUseTimerQueue                  DD ?
    hQueue                          DD ?
    hTimer                          DD ?
    ENDIF
    ENDIF
_MUI_SPINNER_PROPERTIES				ENDS

SPINNER_FRAME                       STRUCT
    hImage                          DD ?
SPINNER_FRAME                       ENDS

IFDEF MUI_USEGDIPLUS
IFNDEF UNKNOWN
UNKNOWN STRUCT
   QueryInterface   DWORD ?
   AddRef           DWORD ?
   Release          DWORD ?
UNKNOWN ENDS
ENDIF

IFNDEF IStream
IStream STRUCT
IUnknown            UNKNOWN <>
Read                DWORD ?
Write               DWORD ?
Seek                DWORD ?
SetSize             DWORD ?
CopyTo              DWORD ?
Commit              DWORD ?
Revert              DWORD ?
LockRegion          DWORD ?
UnlockRegion        DWORD ?
Stat                DWORD ?
Clone               DWORD ?
IStream ENDS
ENDIF
ENDIF

.CONST
SPINNER_MAX_FRAMES                  EQU 60
SPINNER_TIME_INTERVAL_MIN           EQU 10
SPINNER_TIME_INTERVAL               EQU 80 ; Milliseconds for timer firing

; Internal properties
@SpinnerMouseOver					EQU 0
@SpinnerTotalFrames                 EQU 4
@SpinnerFrameIndex                  EQU 8
@SpinnerFramesArray                 EQU 12
@SpinnerImageType                   EQU 16
IFDEF SPINNER_USE_MMTIMER
@SpinnerTimer                       EQU 20
ELSE
IFDEF SPINNER_USE_TIMERQUEUE
@SpinnerUseTimerQueue               EQU 20
@SpinnerQueue                       EQU 24
@SpinnerTimer                       EQU 28
ENDIF
ENDIF

.DATA
szMUISpinnerClass					DB 'ModernUI_Spinner',0 	    ; Class name for creating our Spinner control



.CODE

MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_Spinner control
;------------------------------------------------------------------------------
MUISpinnerSetProperty PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUISpinnerSetProperty ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_Spinner control
;------------------------------------------------------------------------------
MUISpinnerGetProperty PROC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUISpinnerGetProperty ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerRegister - Registers the ModernUI_Spinner control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as Spinner
;------------------------------------------------------------------------------
MUISpinnerRegister PROC 
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUISpinnerClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUISpinnerClass
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
    	mov wc.lpfnWndProc, OFFSET _MUI_SpinnerWndProc
    	;Invoke LoadCursor, NULL, IDC_ARROW
    	mov wc.hCursor, NULL ;eax
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
MUISpinnerRegister ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUISpinnerCreate PROC hWndParent:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	LOCAL hControl:DWORD
	LOCAL dwNewStyle:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

	Invoke MUISpinnerRegister
	
    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_CLIPCHILDREN
    .ENDIF	
	
    Invoke CreateWindowEx, NULL, Addr szMUISpinnerClass, NULL, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
	mov hControl, eax
	.IF eax != NULL
		
	.ENDIF
	mov eax, hControl
    ret
MUISpinnerCreate ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_SpinnerWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
		; sets text of our control, delete if not required.
        ;Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName	
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
		Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_SPINNER_PROPERTIES ; internal properties
		Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_SPINNER_PROPERTIES ; external properties
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGDIPlusStart ; for png resources if used
        ENDIF
		Invoke _MUI_SpinnerInit, hWin
		mov eax, 0
		ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_SpinnerCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
		Invoke MUIFreeMemProperties, hWin, 4
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGDIPlusFinish
        ENDIF
		mov eax, 0
		ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_SpinnerPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUISPNS_HAND
        .IF eax == MUISPNS_HAND
            invoke LoadCursor, NULL, IDC_HAND
        .ELSE
            invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
        mov eax, 0
        ret    

    .ELSEIF eax == WM_LBUTTONUP
		; simulates click on our control, delete if not required.
		Invoke GetDlgCtrlID, hWin
		mov ebx,eax
		Invoke GetParent, hWin
		Invoke PostMessage, eax, WM_COMMAND, ebx, hWin

   .ELSEIF eax == WM_MOUSEMOVE
		Invoke MUISetIntProperty, hWin, @SpinnerMouseOver, TRUE
		.IF eax != TRUE
		    Invoke InvalidateRect, hWin, NULL, TRUE
		    mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
		    mov TE.dwFlags, TME_LEAVE
		    mov eax, hWin
		    mov TE.hwndTrack, eax
		    mov TE.dwHoverTime, NULL
		    Invoke TrackMouseEvent, Addr TE
		.ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        Invoke MUISetIntProperty, hWin, @SpinnerMouseOver, FALSE
		Invoke InvalidateRect, hWin, NULL, TRUE
;		Invoke LoadCursor, NULL, IDC_ARROW
;		Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @SpinnerMouseOver, FALSE
		Invoke InvalidateRect, hWin, NULL, TRUE
;		Invoke LoadCursor, NULL, IDC_ARROW
;		Invoke SetCursor, eax
	
	.ELSEIF eax == WM_TIMER
	    mov eax, wParam
	    .IF eax == hWin
	        Invoke _MUI_SpinnerNextFrameIndex, hWin
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke UpdateWindow, hWin
	    .ENDIF
	    
	; custom messages start here
	.ELSEIF eax == MUISPNM_ADDFRAME ; wParam = dwImageType, lParam = hImage
	    Invoke MUISpinnerAddFrame, hWin, wParam, lParam
	    ret
	.ELSEIF eax == MUISPNM_LOADFRAME; wParam = dwImageType, lParam = idResImage
	    Invoke MUISpinnerLoadFrame, hWin, wParam, lParam
	    ret
	.ELSEIF eax == MUISPNM_ENABLE   ; wParam & lParam = NULL
	    Invoke MUISpinnerEnable, hWin
	    ret
	.ELSEIF eax == MUISPNM_DISABLE  ; wParam & lParam = NULL
	    Invoke MUISpinnerDisable, hWin
	    ret
	.ELSEIF eax == MUISPNM_RESET    ; wParam & lParam = NULL
	    Invoke MUISpinnerReset, hWin
	    ret
	.ELSEIF eax == MUISPNM_PAUSE    ; wParam & lParam = NULL
	    Invoke MUISpinnerPause, hWin
	    ret
	.ELSEIF eax == MUISPNM_RESUME   ; wParam & lParam = NULL
	    Invoke MUISpinnerResume, hWin
	    ret
	.ELSEIF eax == MUISPNM_SPEED    ; wParam = dwMillisecSpeed	
	    Invoke MUISpinnerSpeed, hWin, wParam
	    ret
	.ELSEIF eax == MUI_GETPROPERTY
		Invoke MUIGetExtProperty, hWin, wParam
		ret
	.ELSEIF eax == MUI_SETPROPERTY
	    mov eax, wParam
	    .IF eax == @SpinnerSpeed
            .IF lParam == 0
                mov eax, SPINNER_TIME_INTERVAL
            .ELSEIF sdword ptr lParam < 10
                mov eax, SPINNER_TIME_INTERVAL_MIN
            .ELSE
                mov eax, lParam
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, eax	
	    .ELSE
		    Invoke MUISetExtProperty, hWin, wParam, lParam
		.ENDIF
		ret
		
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_SpinnerWndProc ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerInit - set initial default values
;------------------------------------------------------------------------------
_MUI_SpinnerInit PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hWin
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_CLIPCHILDREN ;or WS_VISIBLE 
    .IF eax != WS_CHILD or WS_CLIPCHILDREN ;or WS_VISIBLE 
        mov eax, dwStyle
        or eax, WS_CHILD or WS_CLIPCHILDREN ;or WS_VISIBLE 
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
    ;PrintDec dwStyle
    
    ; Set default initial external property values     
    
    Invoke MUIGetParentBackgroundColor, hWin
    .IF eax == -1 ; if background was NULL then try a color as default
        Invoke GetSysColor, COLOR_WINDOW
    .ENDIF
    Invoke MUISetExtProperty, hWin, @SpinnerBackColor, eax ;MUI_RGBCOLOR(255,255,255)
    ;Invoke MUISetExtProperty, hWin, @SpinnerBackColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hWin, @SpinnerSpeed, SPINNER_TIME_INTERVAL
    
    IFDEF SPINNER_USE_MMTIMER
    Invoke MUISetIntProperty, hWin, @SpinnerTimer, 0
    ELSE
    IFDEF SPINNER_USE_TIMERQUEUE
    Invoke MUISetIntProperty, hWin, @SpinnerUseTimerQueue, TRUE
    Invoke MUISetIntProperty, hWin, @SpinnerQueue, 0
    Invoke MUISetIntProperty, hWin, @SpinnerTimer, 0
    ENDIF
    ENDIF
    
    ; Alloc memory for max frames
    mov eax, SPINNER_MAX_FRAMES
    mov ebx, SIZEOF SPINNER_FRAME
    mul ebx
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax != NULL
        Invoke MUISetIntProperty, hWin, @SpinnerFramesArray, eax
    .ENDIF

    mov eax, TRUE
    ret
_MUI_SpinnerInit ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerCleanup - cleanup
;------------------------------------------------------------------------------
_MUI_SpinnerCleanup PROC USES EBX hWin:DWORD
    LOCAL pSpinnerFramesArray:DWORD
    LOCAL pCurrentFrame:DWORD
    LOCAL TotalFrames:DWORD
    LOCAL FrameIndex:DWORD
    LOCAL ImageType:DWORD
    LOCAL hImage:DWORD
    
    Invoke KillTimer, hWin, hWin
    
    Invoke MUIGetIntProperty, hWin, @SpinnerImageType
    mov ImageType, eax    
    
    Invoke MUIGetIntProperty, hWin, @SpinnerFramesArray
    .IF eax != NULL
        mov pSpinnerFramesArray, eax
        mov pCurrentFrame, eax
        
        Invoke MUIGetIntProperty, hWin, @SpinnerTotalFrames
        mov TotalFrames, eax
        
        mov FrameIndex, 0
        mov eax, 0
        .WHILE eax < TotalFrames
            mov ebx, pCurrentFrame
            
            mov eax, [ebx].SPINNER_FRAME.hImage ; get bitmap handle and delete object if it exists
            
            .IF eax != NULL
                mov hImage, eax
                
                mov eax, ImageType
                .IF eax == MUISPIT_BMP
                    ;PrintText 'Deleteing bitmap'
                    .IF hImage != NULL
                        Invoke DeleteObject, hImage
                    .ENDIF
                .ELSEIF eax == MUISPIT_ICO
                    .IF hImage != NULL
                        Invoke DestroyIcon, hImage
                    .ENDIF
                .ELSEIF eax == MUISPIT_PNG
                    IFDEF MUI_USEGDIPLUS
                    .IF hImage != NULL
                        Invoke GdipDisposeImage, hImage
                    .ENDIF
                    ENDIF
                .ENDIF
            .ENDIF
            
            add pCurrentFrame, SIZEOF SPINNER_FRAME
            inc FrameIndex
            mov eax, FrameIndex
        .ENDW
    
        Invoke GlobalFree, pSpinnerFramesArray
    
    .ENDIF
    ret
_MUI_SpinnerCleanup ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerNextFrameIndex - sets the next frame index to use for painting
;------------------------------------------------------------------------------
_MUI_SpinnerNextFrameIndex PROC USES EBX hWin:DWORD
    LOCAL TotalFrames:DWORD
    LOCAL NextFrame:DWORD

    Invoke MUIGetIntProperty, hWin, @SpinnerTotalFrames
    .IF eax == 0
        ret
    .ENDIF
    mov TotalFrames, eax
    
    Invoke MUIGetIntProperty, hWin, @SpinnerFrameIndex
    inc eax
    .IF eax >= TotalFrames
        mov eax, 0
    .ENDIF
    mov NextFrame, eax
    Invoke MUISetIntProperty, hWin, @SpinnerFrameIndex, NextFrame
    
    ret
_MUI_SpinnerNextFrameIndex ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerPaint
;------------------------------------------------------------------------------
_MUI_SpinnerPaint PROC hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax

    ;----------------------------------------------------------
    ; Get some property values
    ;---------------------------------------------------------- 
    Invoke GetClientRect, hWin, Addr rect

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax

    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _MUI_SpinnerPaintBackground, hWin, hdcMem, Addr rect
    
    ;----------------------------------------------------------
    ; Images
    ;----------------------------------------------------------
    Invoke _MUI_SpinnerPaintImages, hWin, hdc, hdcMem, Addr rect

    ;----------------------------------------------------------
    ; Border
    ;----------------------------------------------------------
    ;Invoke _MUI_SpinnerPaintBorder, hWin, hdcMem, Addr rect
    
    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY
    
    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem
    
    Invoke EndPaint, hWin, Addr ps
    
    ret
_MUI_SpinnerPaint ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerPaintBackground
;------------------------------------------------------------------------------
_MUI_SpinnerPaintBackground PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL rect:RECT

    Invoke CopyRect, Addr rect, lpRect
    inc rect.bottom ; rect needs to be increased for FillRect call
    inc rect.right ; rect needs to be increased for FillRect call
    
    Invoke MUIGetExtProperty, hWin, @SpinnerBackColor
    mov BackColor, eax
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    Invoke FillRect, hdc, Addr rect, hBrush
    
    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF      
    
    ret
_MUI_SpinnerPaintBackground ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerPaintImages
;------------------------------------------------------------------------------
_MUI_SpinnerPaintImages PROC USES EBX hWin:DWORD, hdcMain:DWORD, hdcDest:DWORD, lpRect:DWORD
    LOCAL hdcMem:HDC
    LOCAL hbmOld:DWORD
    LOCAL hImage:DWORD
    LOCAL ImageType:DWORD
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL pBitmap:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    
    Invoke MUIGetIntProperty, hWin, @SpinnerImageType
    .IF eax == 0
        ret
    .ENDIF
    mov ImageType, eax
    
    Invoke _MUI_SpinnerFrame, hWin
    .IF eax == 0
        ret
    .ENDIF
    mov hImage, eax

    
    Invoke CopyRect, Addr rect, lpRect
    Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight
    
    mov eax, rect.right
    shr eax, 1
    mov ebx, ImageWidth
    shr ebx, 1
    sub eax, ebx
    .IF sdword ptr eax < 0
        mov eax, 0
    .ENDIF
    mov pt.x, eax
    mov eax, rect.bottom
    shr eax, 1
    mov ebx, ImageHeight
    shr ebx, 1
    sub eax, ebx
    .IF sdword ptr eax < 0
        mov eax, 0
    .ENDIF
    mov pt.y, eax
    
    
    mov eax, ImageType
    .IF eax == MUISPIT_BMP ; bitmap
        
        Invoke CreateCompatibleDC, hdcMain
        mov hdcMem, eax
        Invoke SelectObject, hdcMem, hImage
        mov hbmOld, eax

        Invoke BitBlt, hdcDest, pt.x, pt.y, ImageWidth, ImageHeight, hdcMem, 0, 0, SRCCOPY

        Invoke SelectObject, hdcMem, hbmOld
        Invoke DeleteDC, hdcMem
        .IF hbmOld != 0
            Invoke DeleteObject, hbmOld
        .ENDIF
        
    .ELSEIF eax == MUISPIT_ICO ; icon
        Invoke DrawIconEx, hdcDest, pt.x, pt.y, hImage, 0, 0, 0, 0, DI_NORMAL
    
    .ELSEIF eax == MUISPIT_PNG ; png
        IFDEF MUI_USEGDIPLUS
        Invoke GdipCreateFromHDC, hdcDest, Addr pGraphics
        Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
        Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer
        
        Invoke GdipSetPixelOffsetMode, pGraphics, PixelOffsetModeHighQuality
        Invoke GdipSetPixelOffsetMode, pGraphicsBuffer, PixelOffsetModeHighQuality
        Invoke GdipSetPageUnit, pGraphics, UnitPixel
        Invoke GdipSetPageUnit, pGraphicsBuffer, UnitPixel
        Invoke GdipSetSmoothingMode, pGraphics, SmoothingModeAntiAlias
        Invoke GdipSetSmoothingMode, pGraphicsBuffer, SmoothingModeAntiAlias
        Invoke GdipSetInterpolationMode, pGraphics, InterpolationModeHighQualityBicubic
        Invoke GdipSetInterpolationMode, pGraphicsBuffer, InterpolationModeHighQualityBicubic
        
        Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
        Invoke GdipDrawImageRectI, pGraphics, pBitmap, pt.x, pt.y, ImageWidth, ImageHeight
        .IF pBitmap != NULL
            Invoke GdipDisposeImage, pBitmap
        .ENDIF
        .IF pGraphicsBuffer != NULL
            Invoke GdipDeleteGraphics, pGraphicsBuffer
        .ENDIF
        .IF pGraphics != NULL
            Invoke GdipDeleteGraphics, pGraphics
        .ENDIF
        ENDIF
    .ENDIF    

    ret
_MUI_SpinnerPaintImages ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerPaintBorder
;------------------------------------------------------------------------------
_MUI_SpinnerPaintBorder PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD
;    LOCAL BorderColor:DWORD
;    LOCAL hBrush:DWORD
;    LOCAL hOldBrush:DWORD
;    
;    ;Invoke MUIGetExtProperty, hWin, @SpinnerBorderColor
;    mov eax, -1
;    mov BorderColor, eax
;    
;    .IF BorderColor != -1
;        Invoke GetStockObject, DC_BRUSH
;        mov hBrush, eax
;        Invoke SelectObject, hdc, eax
;        mov hOldBrush, eax
;        Invoke SetDCBrushColor, hdc, BorderColor
;        Invoke FrameRect, hdc, lpRect, hBrush
;        
;        .IF hOldBrush != 0
;            Invoke SelectObject, hdc, hOldBrush
;            Invoke DeleteObject, hOldBrush
;        .ENDIF     
;        .IF hBrush != 0
;            Invoke DeleteObject, hBrush
;        .ENDIF                
;    .ENDIF
    ret
_MUI_SpinnerPaintBorder ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SpinnerFrame - gets the current frame image handle
;------------------------------------------------------------------------------
_MUI_SpinnerFrame PROC USES EBX hWin:DWORD
    LOCAL pSpinnerFramesArray:DWORD
    
    Invoke MUIGetIntProperty, hWin, @SpinnerTotalFrames
    .IF eax == 0
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hWin, @SpinnerFramesArray
    mov pSpinnerFramesArray, eax
    
    Invoke MUIGetIntProperty, hWin, @SpinnerFrameIndex
    mov ebx, SIZEOF SPINNER_FRAME
    mul ebx
    add eax, pSpinnerFramesArray
    mov ebx, eax
    mov eax, [ebx] ; handle to bitmap 
    
    ret
_MUI_SpinnerFrame ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerEnable
;------------------------------------------------------------------------------
MUISpinnerEnable PROC hControl:DWORD
    LOCAL dwTimeInterval:DWORD
    IFDEF SPINNER_USE_MMTIMER
    LOCAL hTimer:DWORD
    ELSE
    IFDEF SPINNER_USE_TIMERQUEUE
    LOCAL hQueue:DWORD
    LOCAL hTimer:DWORD
    ENDIF
    ENDIF
    
    .IF hControl == NULL
        xor eax, eax
        ret
    .ENDIF
    
    Invoke ShowWindow, hControl, SW_SHOWNORMAL;SW_SHOWNA
    Invoke MUIGetExtProperty, hControl, @SpinnerSpeed
    .IF eax == 0
        Invoke MUISetIntProperty, hControl, @SpinnerSpeed, SPINNER_TIME_INTERVAL
        mov eax, SPINNER_TIME_INTERVAL
    .ENDIF
    mov dwTimeInterval, eax    
    
    Invoke InvalidateRect, hControl, NULL, TRUE
   
    IFDEF SPINNER_USE_MMTIMER
    
        Invoke MUIGetIntProperty, hControl, @SpinnerTimer
        mov hTimer, eax
        .IF hTimer != 0
            Invoke timeKillEvent, hTimer
        .ENDIF
    
        Invoke timeSetEvent, dwTimeInterval, 0, Addr _MUI_SpinnerMMTimerProc, hControl, TIME_PERIODIC
        mov hTimer, eax
        .IF eax != 0 ; success
            Invoke MUISetIntProperty, hControl, @SpinnerTimer, hTimer
        .ELSE ; fallback to WM_TIMER style
            Invoke MUISetIntProperty, hControl, @SpinnerTimer, 0
            Invoke SetTimer, hControl, hControl, dwTimeInterval, NULL
        .ENDIF

    ELSE
        IFDEF SPINNER_USE_TIMERQUEUE
        
            Invoke MUIGetIntProperty, hControl, @SpinnerUseTimerQueue
            .IF eax == TRUE
                Invoke MUIGetIntProperty, hControl, @SpinnerQueue
                mov hQueue, eax
                Invoke MUIGetIntProperty, hControl, @SpinnerTimer
                mov hTimer, eax
                .IF hQueue != NULL ; re-use existing hQueue
                    Invoke ChangeTimerQueueTimer, hQueue, hTimer, dwTimeInterval, dwTimeInterval
                    .IF eax == 0 ; failed 
                        Invoke DeleteTimerQueueEx, hQueue, FALSE
                        Invoke MUISetIntProperty, hControl, @SpinnerQueue, 0
                        Invoke MUISetIntProperty, hControl, @SpinnerTimer, 0
                        Invoke MUISetIntProperty, hControl, @SpinnerUseTimerQueue, FALSE
                        Invoke SetTimer, hControl, hControl, dwTimeInterval, NULL
                    .ENDIF
                .ELSE ; Try to create TimerQueue 
                    Invoke CreateTimerQueue
                    .IF eax != NULL
                        mov hQueue, eax
                        Invoke CreateTimerQueueTimer, Addr hTimer, hQueue, Addr _MUI_SpinnerTimerProc, hControl, dwTimeInterval, dwTimeInterval, 0
                        .IF eax == 0 ; failed, so fall back to WM_TIMER usage
                            Invoke DeleteTimerQueueEx, hQueue, FALSE
                            Invoke MUISetIntProperty, hControl, @SpinnerQueue, 0
                            Invoke MUISetIntProperty, hControl, @SpinnerTimer, 0
                            Invoke MUISetIntProperty, hControl, @SpinnerUseTimerQueue, FALSE
                            Invoke SetTimer, hControl, hControl, dwTimeInterval, NULL
                        .ELSE ; Success! - so save TimerQueue handles for re-use
                            IFDEF DEBUG32
                            PrintText 'Using QueueTimer'
                            ENDIF
                            Invoke MUISetIntProperty, hControl, @SpinnerQueue, hQueue
                            Invoke MUISetIntProperty, hControl, @SpinnerTimer, hTimer
                        .ENDIF
                    .ELSE ; failed, so fall back to WM_TIMER usage
                        Invoke MUISetIntProperty, hControl, @SpinnerUseTimerQueue, FALSE
                        Invoke SetTimer, hControl, hControl, dwTimeInterval, NULL
                    .ENDIF
                .ENDIF
            .ELSE  ; Not using TimerQueue, previous failure?, so fall back to WM_TIMER usage
                Invoke SetTimer, hControl, hControl, dwTimeInterval, NULL
            .ENDIF
        
        ELSE ; compiled define says to use WM_TIMER instead
        
            Invoke SetTimer, hControl, hControl, dwTimeInterval, NULL
            
        ENDIF
    ENDIF
    
    mov eax, TRUE
    ret
MUISpinnerEnable ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerDisable
;------------------------------------------------------------------------------
MUISpinnerDisable PROC hControl:DWORD
    IFDEF SPINNER_USE_MMTIMER
    LOCAL hTimer:DWORD
    ELSE
    IFDEF SPINNER_USE_TIMERQUEUE
    LOCAL hQueue:DWORD
    LOCAL hTimer:DWORD
    ENDIF
    ENDIF
    
    .IF hControl == NULL
        xor eax, eax
        ret
    .ENDIF
    
    Invoke ShowWindow, hControl, SW_HIDE
    
    IFDEF SPINNER_USE_MMTIMER
    
        Invoke MUIGetIntProperty, hControl, @SpinnerTimer
        mov hTimer, eax
        .IF hTimer != 0
            Invoke timeKillEvent, hTimer
            .IF eax == MMSYSERR_INVALPARAM
                Invoke KillTimer, hControl, hControl
            .ENDIF
        .ENDIF

    ELSE
        IFDEF SPINNER_USE_TIMERQUEUE
        
            Invoke MUIGetIntProperty, hControl, @SpinnerUseTimerQueue
            .IF eax == TRUE
                Invoke MUIGetIntProperty, hControl, @SpinnerQueue
                mov hQueue, eax
                Invoke MUIGetIntProperty, hControl, @SpinnerTimer
                mov hTimer, eax
                .IF hQueue != NULL
                    Invoke ChangeTimerQueueTimer, hQueue, hTimer, INFINITE, 0
                    .IF eax == 0 ; failed, fall back to use KillTimer for WM_TIMER usage
                        Invoke DeleteTimerQueueEx, hQueue, FALSE
                        Invoke MUISetIntProperty, hControl, @SpinnerQueue, 0
                        Invoke MUISetIntProperty, hControl, @SpinnerTimer, 0
                        Invoke MUISetIntProperty, hControl, @SpinnerUseTimerQueue, FALSE
                        Invoke KillTimer, hControl, hControl
                    .ENDIF
                .ELSE ; fall back to use KillTimer for WM_TIMER usage
                    Invoke MUISetIntProperty, hControl, @SpinnerUseTimerQueue, FALSE
                    Invoke KillTimer, hControl, hControl
                .ENDIF
            .ELSE ; Not using TimerQueue, previous failure? back to use KillTimer for WM_TIMER usage
                Invoke KillTimer, hControl, hControl
            .ENDIF
            
        ELSE ; compiled define says to use WM_TIMER instead
        
            Invoke KillTimer, hControl, hControl
            
        ENDIF
    ENDIF

    Invoke InvalidateRect, hControl, NULL, TRUE    
    
    mov eax, TRUE
    ret
MUISpinnerDisable ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerPause
;------------------------------------------------------------------------------
MUISpinnerPause PROC hControl:DWORD
    IFDEF SPINNER_USE_MMTIMER
    LOCAL hTimer:DWORD
    ELSE
    IFDEF SPINNER_USE_TIMERQUEUE
    LOCAL hQueue:DWORD
    LOCAL hTimer:DWORD
    ENDIF
    ENDIF
    
    .IF hControl == NULL
        xor eax, eax
        ret
    .ENDIF
    
    IFDEF SPINNER_USE_MMTIMER
    
        Invoke MUIGetIntProperty, hControl, @SpinnerTimer
        mov hTimer, eax
        .IF hTimer != 0
            Invoke timeKillEvent, hTimer
            .IF eax == MMSYSERR_INVALPARAM
                Invoke KillTimer, hControl, hControl
            .ENDIF
        .ENDIF

    ELSE
        IFDEF SPINNER_USE_TIMERQUEUE
        
            Invoke MUIGetIntProperty, hControl, @SpinnerUseTimerQueue
            .IF eax == TRUE
                Invoke MUIGetIntProperty, hControl, @SpinnerQueue
                mov hQueue, eax
                Invoke MUIGetIntProperty, hControl, @SpinnerTimer
                mov hTimer, eax
                .IF hQueue != NULL
                    Invoke ChangeTimerQueueTimer, hQueue, hTimer, INFINITE, 0
                    .IF eax == 0 ; failed, fall back to use KillTimer for WM_TIMER usage
                        Invoke DeleteTimerQueueEx, hQueue, FALSE
                        Invoke MUISetIntProperty, hControl, @SpinnerQueue, 0
                        Invoke MUISetIntProperty, hControl, @SpinnerTimer, 0
                        Invoke MUISetIntProperty, hControl, @SpinnerUseTimerQueue, FALSE
                        Invoke KillTimer, hControl, hControl
                    .ENDIF
                .ELSE ; fall back to use KillTimer for WM_TIMER usage
                    Invoke MUISetIntProperty, hControl, @SpinnerUseTimerQueue, FALSE
                    Invoke KillTimer, hControl, hControl
                .ENDIF
            .ELSE ; Not using TimerQueue, previous failure? back to use KillTimer for WM_TIMER usage
                Invoke KillTimer, hControl, hControl
            .ENDIF
            
        ELSE ; compiled define says to use WM_TIMER instead
        
            Invoke KillTimer, hControl, hControl
            
        ENDIF
    ENDIF
    mov eax, TRUE
    ret
MUISpinnerPause ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerResume
;------------------------------------------------------------------------------
MUISpinnerResume PROC hControl:DWORD
    Invoke MUISpinnerEnable, hControl
    ret
MUISpinnerResume ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerReset - reset step to 0 or angle to 0
;------------------------------------------------------------------------------
MUISpinnerReset PROC hControl:DWORD
    .IF hControl == NULL
        xor eax, eax
        ret
    .ENDIF

    Invoke MUISetIntProperty, hControl, @SpinnerFrameIndex, 0

    mov eax, TRUE
    ret
MUISpinnerReset ENDP

;------------------------------------------------------------------------------
; MUISpinnerReset - reset step to 0 or angle to 0
;------------------------------------------------------------------------------
MUISpinnerSpeed PROC hControl:DWORD, dwMillisecSpeed:DWORD
    .IF dwMillisecSpeed == 0
        mov eax, SPINNER_TIME_INTERVAL
    .ELSEIF sdword ptr dwMillisecSpeed < 10
        mov eax, SPINNER_TIME_INTERVAL_MIN
    .ELSE
        mov eax, dwMillisecSpeed
    .ENDIF
    Invoke MUISetExtProperty, hControl, @SpinnerSpeed, eax
    ret
MUISpinnerSpeed ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerAddFrame - Adds an image frame to the spinner control
;
; Returns: TRUE if success, FALSE otherwise
;------------------------------------------------------------------------------
MUISpinnerAddFrame PROC USES EBX hControl:DWORD, dwImageType:DWORD, hImage:DWORD
    LOCAL TotalFrames:DWORD
    LOCAL pSpinnerFramesArray:DWORD
    LOCAL pCurrentFrame:DWORD
    LOCAL dwSize:DWORD

    IFDEF DEBUG32
    ;PrintText 'MUISpinnerAddFrame'
    ENDIF

    .IF hControl == NULL || dwImageType == NULL || hImage == NULL 
        xor eax, eax
        ret
    .ENDIF

    Invoke MUIGetIntProperty, hControl, @SpinnerTotalFrames
    .IF eax == SPINNER_MAX_FRAMES
        xor eax, eax
        ret
    .ENDIF
    mov TotalFrames, eax
    
    Invoke MUIGetIntProperty, hControl, @SpinnerFramesArray
    .IF eax == NULL
        xor eax, eax
        ret
    .ENDIF
    mov pSpinnerFramesArray, eax    
    
    mov eax, TotalFrames
    mov ebx, SIZEOF SPINNER_FRAME
    mul ebx
    add eax, pSpinnerFramesArray
    mov pCurrentFrame, eax

    mov ebx, pCurrentFrame
    mov eax, hImage
    mov [ebx], eax
    
    Invoke MUISetIntProperty, hControl, @SpinnerImageType, dwImageType
    inc TotalFrames
    Invoke MUISetIntProperty, hControl, @SpinnerTotalFrames, TotalFrames
    
    mov eax, TRUE
    ret
MUISpinnerAddFrame ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerAddFrames - Process an array of image handles and add them to the 
; spinner control as image frames
; 
; Returns: TRUE if success, FALSE otherwise
;------------------------------------------------------------------------------
MUISpinnerAddFrames PROC USES EBX EDX hControl:DWORD, dwCount:DWORD, dwImageType:DWORD, lpArrayImageHandles:DWORD
    LOCAL Index:DWORD

    .IF hControl == NULL || dwCount == NULL || dwImageType == NULL || lpArrayImageHandles == NULL
        xor eax, eax
        ret
    .ENDIF

    mov ebx, lpArrayImageHandles
    mov Index, 0
    mov eax, 0
    .WHILE eax < dwCount
        mov eax, [ebx]
        .IF eax != NULL
            Invoke MUISpinnerAddFrame, hControl, dwImageType, eax
            .IF eax == FALSE
                xor eax, eax
                ret
            .ENDIF
        .ENDIF
        add ebx, SIZEOF DWORD
        inc Index
        mov eax, Index
    .ENDW

    mov eax, TRUE
    ret
MUISpinnerAddFrames ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerLoadFrame - Loads a resource as an image frame to the spinner control
;
; Returns: TRUE if success, FALSE otherwise
;------------------------------------------------------------------------------
MUISpinnerLoadFrame PROC hControl:DWORD, dwImageType:DWORD, idResImage:DWORD
    LOCAL hinstance:DWORD
    LOCAL hImage:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MUISpinnerLoadFrame'
    ENDIF
    
    .IF hControl == NULL || idResImage == NULL ||  dwImageType == 0
        xor eax, eax
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @SpinnerDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax    
    
    mov eax, dwImageType
    .IF eax == MUISPIT_BMP
        Invoke LoadBitmap, hinstance, idResImage
    .ELSEIF eax == MUISPIT_ICO
        Invoke LoadImage, hinstance, idResImage, IMAGE_ICON, 0, 0, 0
    .ELSEIF eax == MUISPIT_PNG
        IFDEF MUI_USEGDIPLUS
        Invoke _MUI_SpinnerLoadPng, hinstance, idResImage
        ENDIF
    .ELSE
        xor eax, eax
        ret
    .ENDIF
    .IF eax == NULL
        xor eax, eax
        ret
    .ENDIF
    mov hImage, eax

    Invoke MUISpinnerAddFrame, hControl, dwImageType, hImage
    .IF eax == FALSE
        xor eax, eax
        ret
    .ENDIF
    
    mov eax, TRUE
    ret
MUISpinnerLoadFrame ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerLoadFrames - Process an array of resource ids and load the resource
; and add them to the spinner control as image frames
;
; Returns: TRUE if success, FALSE otherwise
;------------------------------------------------------------------------------
MUISpinnerLoadFrames PROC USES EBX EDX hControl:DWORD, dwCount:DWORD, dwImageType:DWORD, lpArrayResourceIDs:DWORD
    LOCAL Index:DWORD
    
    .IF hControl == NULL || dwCount == NULL || dwImageType == NULL || lpArrayResourceIDs == NULL
        xor eax, eax
        ret
    .ENDIF

    mov ebx, lpArrayResourceIDs
    mov Index, 0
    mov eax, 0
    .WHILE eax < dwCount
        mov eax, [ebx]
        .IF eax != NULL
            Invoke MUISpinnerLoadFrame, hControl, dwImageType, eax
            .IF eax == FALSE
                xor eax, eax
                ret
            .ENDIF
        .ENDIF
        add ebx, SIZEOF DWORD
        inc Index
        mov eax, Index
    .ENDW
    
    mov eax, TRUE
    ret
MUISpinnerLoadFrames ENDP

IFDEF MUI_USEGDIPLUS
MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerAddImage
;------------------------------------------------------------------------------
MUISpinnerAddImage PROC hControl:DWORD, hImage:DWORD, dwNoFramesToCreate:DWORD, bReverse:DWORD
    LOCAL BackColor:DWORD
    LOCAL nFrame:DWORD
    LOCAL hFrame:DWORD
    LOCAL fAngle:REAL4
    LOCAL slice:REAL4
    
    IFDEF DEBUG32
    ;PrintText 'MUISpinnerAddImage'
    ENDIF
    
    .IF hControl == NULL || hImage == NULL || dwNoFramesToCreate == 0
        xor eax, eax
        ret
    .ENDIF

    ; calc slice of pie required for each frame
    finit
    fld FP4(360.0)
    fild dwNoFramesToCreate
    fdiv
    fstp slice
    
    ; init angle at 0 
    .IF bReverse == TRUE
        fld FP4(360.0)
    .ELSE
        fld FP4(0.0)
    .ENDIF
    fstp fAngle
    
    mov nFrame, 0
    mov eax, 0
    .WHILE eax < dwNoFramesToCreate
        Invoke _MUI_SpinnerRotateCenterImage, hImage, fAngle
        mov hFrame, eax
        
        Invoke MUISpinnerAddFrame, hControl, MUISPIT_PNG, hFrame
        .IF eax == FALSE
            xor eax, eax
            ret
        .ENDIF
        
        finit
        fld fAngle
        .IF bReverse == TRUE
            fsub slice
        .ELSE
            fadd slice
        .ENDIF
        fstp fAngle
        
        inc nFrame
        mov eax, nFrame
    .ENDW
    
    mov eax, TRUE
    ret
MUISpinnerAddImage ENDP
ENDIF

IFDEF MUI_USEGDIPLUS
MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerLoadImage
;------------------------------------------------------------------------------
MUISpinnerLoadImage PROC hControl:DWORD, idResImage:DWORD, dwNoFramesToCreate:DWORD, bReverse:DWORD
    LOCAL hinstance:DWORD
    LOCAL hImage:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MUISpinnerLoadImage'
    ENDIF
    
    .IF hControl == NULL || idResImage == NULL || dwNoFramesToCreate == 0
        xor eax, eax
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @SpinnerDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax   
    
    Invoke _MUI_SpinnerLoadPng, hinstance, idResImage
    mov hImage, eax

    Invoke MUISpinnerAddImage, hControl, hImage, dwNoFramesToCreate, bReverse
    .IF eax == FALSE
        xor eax, eax
        ret
    .ENDIF
    
    mov eax, TRUE
    ret
MUISpinnerLoadImage ENDP
ENDIF

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerAddSpriteSheet
;------------------------------------------------------------------------------
MUISpinnerAddSpriteSheet PROC USES ECX EDX hControl:DWORD, dwSpriteCount:DWORD, dwImageType:DWORD, hImageSpriteSheet:DWORD, bReverse:DWORD
    LOCAL hImageSpriteSheetOld:DWORD
    LOCAL hIcoSpriteSheet:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL FrameWidth:DWORD
    LOCAL FrameHeight:DWORD
    LOCAL nFrame:DWORD
    LOCAL hFrame:DWORD
    LOCAL hFrameOld:DWORD
    LOCAL x:DWORD
    LOCAL y:DWORD
    LOCAL hdc:DWORD
    LOCAL hdcFrame:DWORD
    LOCAL hdcSpriteSheet:DWORD
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsFrame:DWORD
    LOCAL pFrame:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MUISpinnerAddSpriteSheet'
    ENDIF
    
    .IF hControl == NULL || dwImageType == NULL || dwSpriteCount == 0 || hImageSpriteSheet == NULL
        xor eax, eax
        ret
    .ENDIF
    
    Invoke MUIGetImageSize, hImageSpriteSheet, dwImageType, Addr ImageWidth, Addr ImageHeight
    
    ;--------------------------------------------------------------------------
    ; Calc frame width
    ;--------------------------------------------------------------------------
    xor edx, edx
    mov eax, ImageWidth
    mov ecx, dwSpriteCount
    div ecx
    mov FrameWidth, eax
    mov eax, ImageHeight
    mov FrameHeight, eax

    Invoke GetDC, hControl
    mov hdc, eax

    ;--------------------------------------------------------------------------
    ; Get spritesheet image and create a dc + bitmap to store our sprite frame
    ;--------------------------------------------------------------------------
    mov eax, dwImageType
    .IF eax == MUISPIT_BMP
        Invoke CreateCompatibleDC, hdc
        mov hdcSpriteSheet, eax
        Invoke SelectObject, hdcSpriteSheet, hImageSpriteSheet
        mov hImageSpriteSheetOld, eax
        Invoke CreateCompatibleDC, hdc
        mov hdcFrame, eax
    .ELSEIF eax == MUISPIT_ICO
        Invoke CreateCompatibleDC, hdc
        mov hdcSpriteSheet, eax
        Invoke CreateCompatibleBitmap, hdc, ImageWidth, ImageHeight
        mov hIcoSpriteSheet, eax
        Invoke SelectObject, hdcSpriteSheet, hIcoSpriteSheet
        mov hImageSpriteSheetOld, eax
        Invoke CreateCompatibleDC, hdc
        mov hdcFrame, eax
        Invoke DrawIconEx, hdcSpriteSheet, 0, 0, hImageSpriteSheet, 0, 0, 0, 0, DI_NORMAL
    .ELSEIF eax == MUISPIT_PNG
        mov pGraphics, 0
        mov pGraphicsFrame, 0
        mov pFrame, 0
        Invoke GdipCreateFromHDC, hdc, Addr pGraphics
    .ENDIF

    ;--------------------------------------------------------------------------
    ; Cut each frame from spritesheet to hFrame and add to spinner
    ;--------------------------------------------------------------------------
    .IF bReverse == TRUE
        mov eax, ImageWidth
        sub eax, FrameWidth
        mov x, eax
        mov y, 0
        mov eax, dwSpriteCount
        mov nFrame, eax
        .WHILE eax > 0
            mov eax, dwImageType
            .IF eax == MUISPIT_BMP || eax == MUISPIT_ICO
                Invoke CreateCompatibleBitmap, hdc, FrameWidth, FrameHeight
                mov hFrame, eax
                Invoke SelectObject, hdcFrame, hFrame
                mov hFrameOld, eax
                Invoke BitBlt, hdcFrame, 0, 0, FrameWidth, FrameHeight, hdcSpriteSheet, x, y, SRCCOPY
                Invoke MUISpinnerAddFrame, hControl, MUISPIT_BMP, hFrame
                Invoke SelectObject, hdcFrame, hFrameOld
            .ELSEIF eax == MUISPIT_PNG
                Invoke GdipCreateBitmapFromGraphics, FrameWidth, FrameHeight, pGraphics, Addr pFrame
                Invoke GdipGetImageGraphicsContext, pFrame, Addr pGraphicsFrame
                Invoke GdipSetPixelOffsetMode, pGraphicsFrame, PixelOffsetModeHighQuality
                Invoke GdipSetPageUnit, pGraphicsFrame, UnitPixel
                Invoke GdipSetSmoothingMode, pGraphicsFrame, SmoothingModeAntiAlias
                Invoke GdipSetInterpolationMode, pGraphicsFrame, InterpolationModeHighQualityBicubic
                Invoke GdipDrawImageRectRectI, pGraphicsFrame, hImageSpriteSheet, 0, 0, FrameWidth, FrameHeight, x, y, FrameWidth, FrameHeight, UnitPixel, NULL, NULL, NULL
                Invoke MUISpinnerAddFrame, hControl, MUISPIT_PNG, pFrame
                .IF pGraphicsFrame != NULL
                    Invoke GdipDeleteGraphics, pGraphicsFrame
                .ENDIF
            .ENDIF
            mov eax, FrameWidth
            sub x, eax
            dec nFrame
            mov eax, nFrame
        .ENDW
    .ELSE
        mov x, 0
        mov y, 0    
        mov eax, 0
        mov nFrame, eax
        .WHILE eax < dwSpriteCount
            mov eax, dwImageType
            .IF eax == MUISPIT_BMP || eax == MUISPIT_ICO
                Invoke CreateCompatibleBitmap, hdc, FrameWidth, FrameHeight
                mov hFrame, eax
                Invoke SelectObject, hdcFrame, hFrame
                mov hFrameOld, eax
                Invoke BitBlt, hdcFrame, 0, 0, FrameWidth, FrameHeight, hdcSpriteSheet, x, y, SRCCOPY
                Invoke MUISpinnerAddFrame, hControl, MUISPIT_BMP, hFrame
                Invoke SelectObject, hdcFrame, hFrameOld
            .ELSEIF eax == MUISPIT_PNG
                Invoke GdipCreateBitmapFromGraphics, FrameWidth, FrameHeight, pGraphics, Addr pFrame
                Invoke GdipGetImageGraphicsContext, pFrame, Addr pGraphicsFrame
                Invoke GdipSetPixelOffsetMode, pGraphicsFrame, PixelOffsetModeHighQuality
                Invoke GdipSetPageUnit, pGraphicsFrame, UnitPixel
                Invoke GdipSetSmoothingMode, pGraphicsFrame, SmoothingModeAntiAlias
                Invoke GdipSetInterpolationMode, pGraphicsFrame, InterpolationModeHighQualityBicubic
                Invoke GdipDrawImageRectRectI, pGraphicsFrame, hImageSpriteSheet, 0, 0, FrameWidth, FrameHeight, x, y, FrameWidth, FrameHeight, UnitPixel, NULL, NULL, NULL
                Invoke MUISpinnerAddFrame, hControl, MUISPIT_PNG, pFrame
                .IF pGraphicsFrame != NULL
                    Invoke GdipDeleteGraphics, pGraphicsFrame
                .ENDIF 
            .ENDIF
            mov eax, FrameWidth
            add x, eax
            inc nFrame
            mov eax, nFrame
        .ENDW
    .ENDIF
    
    ;--------------------------------------------------------------------------
    ; Tidy up
    ;--------------------------------------------------------------------------
    mov eax, dwImageType
    .IF eax == MUISPIT_BMP || eax == MUISPIT_ICO
        Invoke SelectObject, hdcSpriteSheet, hImageSpriteSheetOld
        Invoke DeleteObject, hImageSpriteSheetOld
    .ELSEIF eax == MUISPIT_PNG
        .IF pGraphicsFrame != NULL
            Invoke GdipDeleteGraphics, pGraphicsFrame
        .ENDIF
        .IF pGraphics != NULL
            Invoke GdipDeleteGraphics, pGraphics
        .ENDIF
    .ENDIF
    
    Invoke ReleaseDC, hControl, hdc
    mov eax, TRUE
    ret
MUISpinnerAddSpriteSheet ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; MUISpinnerLoadSpriteSheet
;------------------------------------------------------------------------------
MUISpinnerLoadSpriteSheet PROC hControl:DWORD, dwSpriteCount:DWORD, dwImageType:DWORD, idResSpriteSheet:DWORD, bReverse:DWORD
    LOCAL hinstance:DWORD
    LOCAL hImage:DWORD
    
    IFDEF DEBUG32
    ;PrintText 'MUISpinnerLoadSpriteSheet'
    ENDIF
    
    .IF hControl == NULL || idResSpriteSheet == NULL ||  dwImageType == 0 || dwSpriteCount == 0
        xor eax, eax
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @SpinnerDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax    
    
    mov eax, dwImageType
    .IF eax == MUISPIT_BMP
        Invoke LoadBitmap, hinstance, idResSpriteSheet
    .ELSEIF eax == MUISPIT_ICO
        Invoke LoadImage, hinstance, idResSpriteSheet, IMAGE_ICON, 0, 0, 0
    .ELSEIF eax == MUISPIT_PNG
        IFDEF MUI_USEGDIPLUS
        Invoke _MUI_SpinnerLoadPng, hinstance, idResSpriteSheet
        ENDIF
    .ELSE
        xor eax, eax
        ret
    .ENDIF
    .IF eax == NULL
        xor eax, eax
        ret
    .ENDIF
    mov hImage, eax

    Invoke MUISpinnerAddSpriteSheet, hControl, dwSpriteCount, dwImageType, hImage, bReverse
    .IF eax == FALSE
        xor eax, eax
        ret
    .ENDIF
    
    mov eax, TRUE
    ret
MUISpinnerLoadSpriteSheet ENDP 



;------------------------------------------------------------------------------
; Load JPG/PNG from resource using GDI+
;   Actually, this function can load any image format supported by GDI+
;
; by: Chris Vega
;
; Addendum KSR 2014 : Needs OLE32 include and lib for CreateStreamOnHGlobal and 
; GetHGlobalFromStream calls. Underlying stream needs to be left open for the 
; life of the bitmap or corruption of png occurs. store png as RCDATA in 
; resource file.
;------------------------------------------------------------------------------
IFDEF MUI_USEGDIPLUS
MUI_ALIGN
_MUI_SpinnerLoadPng PROC hinstance:DWORD, idResPng:DWORD
    local rcRes:HRSRC
    local hResData:HRSRC
    local pResData:HANDLE
    local sizeOfRes:DWORD
    local hResBuffer:HANDLE
    local pResBuffer:DWORD
    local pIStream:DWORD
    local hIStream:DWORD
    LOCAL pImage:DWORD
    LOCAL pBitmapFromStream:DWORD
    LOCAL pGraphics:DWORD
    LOCAL dwImageWidth:DWORD
    LOCAL dwImageHeight:DWORD  

    ; ------------------------------------------------------------------
    ; STEP 1: Find the resource
    ; ------------------------------------------------------------------
    invoke  FindResource, hinstance, idResPng, RT_RCDATA
    or      eax, eax
    jnz     @f
    jmp     _MUISpinnerLoadPng@Close
@@: mov     rcRes, eax
    
    ; ------------------------------------------------------------------
    ; STEP 2: Load the resource
    ; ------------------------------------------------------------------
    invoke  LoadResource, hinstance, rcRes
    or      eax, eax
    jnz     @f
    ret     ; Resource was not loaded
@@: mov     hResData, eax
    
    ; ------------------------------------------------------------------
    ; STEP 3: Create a stream to contain our loaded resource
    ; ------------------------------------------------------------------
    invoke  SizeofResource, hinstance, rcRes
    or      eax, eax
    jnz     @f
    jmp     _MUISpinnerLoadPng@Close
@@: mov     sizeOfRes, eax
    
    invoke  LockResource, hResData
    or      eax, eax
    jnz     @f
    jmp     _MUISpinnerLoadPng@Close
@@: mov     pResData, eax

    invoke  GlobalAlloc, GMEM_MOVEABLE, sizeOfRes
    or      eax, eax
    jnz     @f
    jmp     _MUISpinnerLoadPng@Close
@@: mov     hResBuffer, eax

    invoke  GlobalLock, hResBuffer
    mov     pResBuffer, eax
    
    invoke  RtlMoveMemory, pResBuffer, hResData, sizeOfRes
    invoke  CreateStreamOnHGlobal, pResBuffer, TRUE, Addr pIStream
    or      eax, eax
    jz      @f
    jmp     _MUISpinnerLoadPng@Close
@@: 

    ; ------------------------------------------------------------------
    ; STEP 4: Create an image object from stream
    ; ------------------------------------------------------------------
    invoke  GdipCreateBitmapFromStream, pIStream, Addr pBitmapFromStream
    invoke  GetHGlobalFromStream, pIStream, Addr hIStream
    
    ; ------------------------------------------------------------------
    ; STEP 5: Copy stream bitmap image to new ARGB 32bpp bitmap image
    ; ------------------------------------------------------------------
    mov pGraphics, 0
    Invoke GdipGetImageWidth, pBitmapFromStream, Addr dwImageWidth
    Invoke GdipGetImageHeight, pBitmapFromStream, Addr dwImageHeight    
    Invoke GdipCreateBitmapFromScan0, dwImageWidth, dwImageHeight, 0, PixelFormat32bppARGB, 0, Addr pImage
    Invoke GdipGetImageGraphicsContext, pImage, Addr pGraphics
    Invoke GdipDrawImageI, pGraphics, pBitmapFromStream, 0, 0
    
    ; ------------------------------------------------------------------
    ; STEP 6: Free all used locks and resources
    ; ------------------------------------------------------------------
    .IF pGraphics != NULL
        Invoke GdipDeleteGraphics, pGraphics
    .ENDIF
    Invoke GlobalUnlock, hResBuffer
    Invoke GlobalFree, pResBuffer
    
    ; ------------------------------------------------------------------
    ; STEP 7: Set property and return pImage
    ; ------------------------------------------------------------------
    mov eax, pImage

_MUISpinnerLoadPng@Close:
    ret
_MUI_SpinnerLoadPng endp
ENDIF

;-------------------------------------------------------------------------------------
; _MUI_SpinnerRotateCenterImage
;-------------------------------------------------------------------------------------
_MUI_SpinnerRotateCenterImage PROC hImage:DWORD, fAngle:REAL4
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL matrix:DWORD
    LOCAL pBitmap:DWORD
    LOCAL pBrush:DWORD
    LOCAL dwImageWidth:DWORD
    LOCAL dwImageHeight:DWORD
    LOCAL dwX:SDWORD
    LOCAL dwY:SDWORD
    LOCAL x:REAL4
    LOCAL y:REAL4
    LOCAL xneg:REAL4
    LOCAL yneg:REAL4
    LOCAL angle:REAL4

    ;---------------------------------------------------------------------------------
    ; Create new image based on hImage and rotate this new image 
    ;---------------------------------------------------------------------------------
    mov pGraphics, 0
    mov pGraphicsBuffer, 0
    mov matrix, 0
    mov pBitmap, 0
    mov pBrush, 0
    
    Invoke MUIGetImageSize, hImage, MUIIT_PNG, Addr dwImageWidth, Addr dwImageHeight
    Invoke GdipGetImageGraphicsContext, hImage, Addr pGraphics
    Invoke GdipCreateBitmapFromGraphics, dwImageWidth, dwImageHeight, pGraphics, Addr pBitmap 
    Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer
    
    Invoke GdipSetPixelOffsetMode, pGraphicsBuffer, PixelOffsetModeHighQuality
    Invoke GdipSetPageUnit, pGraphicsBuffer, UnitPixel
    Invoke GdipSetSmoothingMode, pGraphicsBuffer, SmoothingModeAntiAlias
    Invoke GdipSetInterpolationMode, pGraphicsBuffer, InterpolationModeHighQualityBicubic
    
    ;---------------------------------------------------------------------------------
    ; Check if angle is 180, if it is then do a flip instead of rotating
    ; (fixes the speed wobble issue when 180.0 is the angle)
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(180.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_180
    jmp angle_is_not_180
    
angle_is_180:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, Rotate180FlipNone
    jmp tidyup

angle_is_not_180:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 90, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(90.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_90
    jmp angle_is_not_90
    
angle_is_90:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, Rotate90FlipNone
    jmp tidyup

angle_is_not_90:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 270, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(270.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_270
    jmp angle_is_not_270
    
angle_is_270:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, Rotate270FlipNone
    jmp tidyup

angle_is_not_270:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 360, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(360.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_360
    jmp angle_is_not_360
    
angle_is_360:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
    ;Invoke GdipImageRotateFlip, pBitmap, RotateNoneFlipNone
    jmp tidyup

angle_is_not_360:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 0, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(0.0)   ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_0
    jmp angle_is_not_0
    
angle_is_0:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
    ;Invoke GdipImageRotateFlip, pBitmap, RotateNoneFlipNone
    jmp tidyup

angle_is_not_0:


    ;---------------------------------------------------------------------------------
    ; Do the actual rotation, calc Translate x, y position for GdipTranslateMatrix to
    ; rotate at image center. Calc the negative of x, y to restore
    ; the origin for drawing with GdipDrawImage
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    
    fild dwImageWidth
    fld FP4(2.0)
    fdiv
    fstp x
    
    fild dwImageHeight
    fld FP4(2.0)
    fdiv
    fstp y
    
    fld x
    fld FP4(-1.0)
    fmul
    fstp xneg
    
    fld y
    fld FP4(-1.0)
    fmul
    fstp yneg
    
    fld xneg
    fistp dwX
    
    fld yneg
    fistp dwY
    
    finit
    ;Invoke GdipTranslateWorldTransform, pGraphicsBuffer, x, y, MatrixOrderPrepend ;%MatrixOrderAppend)
    ;Invoke GdipRotateWorldTransform, pGraphicsBuffer, fAngle, MatrixOrderPrepend;MatrixOrderAppend;%MatrixOrderPrepend)
    
    Invoke GdipResetWorldTransform, pGraphicsBuffer
    Invoke GdipCreateMatrix, Addr matrix
    Invoke GdipTranslateMatrix, matrix, x, y, MatrixOrderPrepend
    Invoke GdipRotateMatrix, matrix, fAngle, MatrixOrderPrepend
    Invoke GdipSetWorldTransform, pGraphicsBuffer, matrix
    
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, dwX, dwY, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL    
    
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, xneg, yneg
    Invoke GdipResetWorldTransform, pGraphicsBuffer

tidyup:
    ;---------------------------------------------------------------------------------
    ; Delete buffers and return our new rotated image
    ;---------------------------------------------------------------------------------
    .IF matrix != NULL
        Invoke GdipDeleteMatrix, matrix
    .ENDIF
    .IF pBrush != NULL
        Invoke GdipDeleteBrush, pBrush
    .ENDIF
    .IF pGraphicsBuffer != NULL
        Invoke GdipDeleteGraphics, pGraphicsBuffer
    .ENDIF
    .IF pGraphics != NULL
        Invoke GdipDeleteGraphics, pGraphics
    .ENDIF

    mov eax, pBitmap
    ret
_MUI_SpinnerRotateCenterImage endp

;------------------------------------------------------------------------------
; _MUI_SpinnerTimerProc for TimerQueue
;------------------------------------------------------------------------------
IFDEF SPINNER_USE_TIMERQUEUE
MUI_ALIGN
_MUI_SpinnerTimerProc PROC USES EBX lpParam:DWORD, TimerOrWaitFired:DWORD
    ; lpParam is hControl
    Invoke _MUI_SpinnerNextFrameIndex, lpParam
    Invoke InvalidateRect, lpParam, NULL, TRUE
    Invoke UpdateWindow, lpParam
    ret
_MUI_SpinnerTimerProc ENDP
ENDIF

;------------------------------------------------------------------------------
; _MUI_SpinnerMMTimerProc for Multimedia Timer
;------------------------------------------------------------------------------
IFDEF SPINNER_USE_MMTIMER
MUI_ALIGN
_MUI_SpinnerMMTimerProc PROC uTimerID:DWORD, uMsg:DWORD, dwUser:DWORD, dw1:DWORD, dw2:DWORD
    ; dwUser is hControl
    Invoke _MUI_SpinnerNextFrameIndex, dwUser
    Invoke InvalidateRect, dwUser, NULL, TRUE
    Invoke UpdateWindow, dwUser
    ret
_MUI_SpinnerMMTimerProc ENDP
ENDIF

MODERNUI_LIBEND










