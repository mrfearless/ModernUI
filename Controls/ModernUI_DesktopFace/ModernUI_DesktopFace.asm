;======================================================================================================================================
;
; ModernUI Control - ModernUI_DesktopFace v1.0.0.0
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

include ModernUI_DesktopFace.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_DesktopFaceWndProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_DesktopFaceInit					PROTO :DWORD, :DWORD
_MUI_DesktopFacePaint					PROTO :DWORD
_MUI_DesktopFacePaintBackground         PROTO :DWORD, :DWORD, :DWORD
_MUI_DesktopFacePaintImage              PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_DesktopFaceSetInitialPosition      PROTO :DWORD
_MUI_DesktopFaceSetSize                 PROTO :DWORD
_MUI_DesktopFaceFadeWindow              PROTO :DWORD, :DWORD
_MUI_DesktopFacePopWindow               PROTO :DWORD, :DWORD
_MUI_DesktopFaceApplyPopRegion          PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_DesktopFaceNotifyParent            PROTO :DWORD, :DWORD, :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; External public properties
MUI_DESKTOPFACE_PROPERTIES				STRUCT
    dwDesktopFaceImageType              DD ?
    dwDesktopFaceImage                  DD ?
    dwDesktopFaceRegion                 DD ?
    dwDesktopFaceOpacity                DD ?
    dwDesktopFaceFadeStepIn             DD ?
    dwDesktopFaceFadeStepOut            DD ?
    dwDesktopFacePopStepIn              DD ?
    dwDesktopFacePopStepOut             DD ?
MUI_DESKTOPFACE_PROPERTIES				ENDS

; Internal properties
_MUI_DESKTOPFACE_PROPERTIES				STRUCT
	dwDesktopFaceParent                 DD ?
	dwFadeAlphaLevel                    DD ?
	dwInitialPositionSet                DD ?
	dwWidth                             DD ?
	dwHeight                            DD ?
	dwXPos                              DD ?
	dwYPos                              DD ?
	dwPopHeight                         DD ?
	dwVisible                           DD ?
_MUI_DESKTOPFACE_PROPERTIES				ENDS

IFNDEF MUIDF_NOTIFY                     ; Notification Message Structure for ModernUI_DesktopFace
MUIDF_NOTIFY                            STRUCT
    hdr                                 NMHDR <>
    lParam                              DD ?
MUIDF_NOTIFY                            ENDS
ENDIF


.CONST
; Internal properties
@DesktopFaceParent                      EQU 0
@DesktopFaceFadeAlphaLevel				EQU 4
@DesktopFaceInitialPositionSet          EQU 8
@DesktopFaceWidth                       EQU 12
@DesktopFaceHeight                      EQU 16
@DesktopFaceXPos                        EQU 20
@DesktopFaceYPos                        EQU 24
@DesktopFacePopHeight                   EQU 28
@DesktopFaceVisible                     EQU 32

DF_TIMER_FADEIN                         EQU 0
DF_TIMER_FADEOUT                        EQU 1
DF_TIMER_POPIN                          EQU 2
DF_TIMER_POPOUT                         EQU 3

DF_FADESTEP                             EQU 8
DF_FADESTEP_OUT                         EQU 16
DF_POPSTEP                              EQU 8
DF_POPSTEP_OUT                          EQU 16

; External public properties


.DATA
ALIGN 4
szMUIDesktopFaceClass					DB 'ModernUI_DesktopFace',0 	; Class name for creating our ModernUI_DesktopFace control
DFNM                                    MUIDF_NOTIFY <>

.CODE



MUI_ALIGN
;-------------------------------------------------------------------------------------
; Set property for ModernUI_DesktopFace control
;-------------------------------------------------------------------------------------
MUIDesktopFaceSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIDesktopFaceSetProperty ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; Get property for ModernUI_DesktopFace control
;-------------------------------------------------------------------------------------
MUIDesktopFaceGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIDesktopFaceGetProperty ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; MUIDesktopFaceRegister - Registers the ModernUI_DesktopFace control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_DesktopFace
;-------------------------------------------------------------------------------------
MUIDesktopFaceRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIDesktopFaceClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIDesktopFaceClass
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
    	mov wc.lpfnWndProc, OFFSET _MUI_DesktopFaceWndProc
    	Invoke LoadCursor, NULL, IDC_ARROW
    	mov wc.hCursor, eax
    	mov wc.hIcon, 0
    	mov wc.hIconSm, 0
    	mov wc.lpszMenuName, NULL
    	mov wc.hbrBackground, NULL
    	mov wc.style, CS_DBLCLKS ;or CS_OWNDC
        mov wc.cbClsExtra, 0
    	mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
    	Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

MUIDesktopFaceRegister ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; MUIDesktopFaceCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUIDesktopFaceCreate PROC PRIVATE hWndParent:DWORD, xpos:DWORD, ypos:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

	Invoke MUIDesktopFaceRegister
	
    mov eax, dwStyle
    mov dwNewStyle, eax
    or dwNewStyle, WS_POPUP
    and dwNewStyle, (-1 xor WS_CHILD)
	
    Invoke CreateWindowEx,  0 , Addr szMUIDesktopFaceClass, 0, dwNewStyle, xpos, ypos, 0, 0, hWndParent, NULL, hinstance, NULL ;WS_EX_TOOLWINDOW or
	mov hControl, eax
	.IF eax != NULL
		
	.ENDIF
	mov eax, hControl
    ret
MUIDesktopFaceCreate ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; _MUI_DesktopFaceWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_DesktopFaceWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL msg:MSG
    LOCAL rect:RECT
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
    
        Invoke GetWindowLong, hWin, GWL_STYLE
        or eax, WS_CLIPCHILDREN or WS_CLIPSIBLINGS
        and eax, (-1 xor WS_POPUP)
        and eax, (-1 xor WS_CHILD)
        Invoke SetWindowLong, hWin, GWL_STYLE, eax ;WS_CHILD or  WS_CLIPSIBLINGS ; WS_VISIBLE
        
        Invoke GetWindowLong, hWin, GWL_EXSTYLE
        or eax, WS_EX_LAYERED or WS_EX_TOPMOST or WS_EX_TOOLWINDOW ;or WS_EX_TRANSPARENT ;or WS_EX_TOOLWINDOW 
        Invoke SetWindowLong, hWin, GWL_EXSTYLE, eax        
        ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
		Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_DESKTOPFACE_PROPERTIES ; internal properties
		Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_DESKTOPFACE_PROPERTIES ; external properties
        mov ebx, lParam
        mov eax, (CREATESTRUCT PTR [ebx]).hWndParent		
		Invoke _MUI_DesktopFaceInit, hWin, eax
		mov eax, 0
		ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke MUIFreeMemProperties, hWin, 0
		Invoke MUIFreeMemProperties, hWin, 4
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_DesktopFacePaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax == WM_GETDLGCODE
        mov eax, DLGC_WANTALLKEYS
        ret
    
    .ELSEIF eax == WM_KEYDOWN
        Invoke _MUI_DesktopFaceNotifyParent, hWin, MUIDFN_KEYPRESS, wParam
        .IF eax == 0
            .IF wParam == VK_ESCAPE
                Invoke ShowWindow, hWin, SW_HIDE
            .ENDIF
        .ENDIF
        mov eax, 0
        ret

    .ELSEIF eax == WM_LBUTTONUP
;        Invoke GetWindowRect, hWin, Addr rect
;        mov eax, rect.left
;        Invoke MUISetIntProperty, hWin, @DesktopFaceXPos, eax
;        mov eax, rect.top
;        Invoke MUISetIntProperty, hWin, @DesktopFaceYPos, eax     
        mov eax, 0
        ret		

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MUI_DesktopFaceNotifyParent, hWin, MUIDFN_LEFTCLICK, NULL
        Invoke PostMessage, hWin, WM_NCLBUTTONDOWN, HTCAPTION, NULL
      
        mov eax, 0
        ret

    .ELSEIF eax == WM_LBUTTONDBLCLK
        Invoke _MUI_DesktopFaceNotifyParent, hWin, MUIDFN_DOUBLECLICK, NULL
        mov eax, 0
        ret		

    .ELSEIF eax == WM_RBUTTONDOWN
        Invoke _MUI_DesktopFaceNotifyParent, hWin, MUIDFN_RIGHTCLICK, NULL
        mov eax, 0
        ret	

    .ELSEIF eax == WM_TIMER
        mov eax, wParam
        .IF eax == DF_TIMER_FADEIN ; fade in our window
            Invoke _MUI_DesktopFaceFadeWindow, hWin, TRUE
            
	    .ELSEIF eax == DF_TIMER_FADEOUT ; fade out our window
	        Invoke _MUI_DesktopFaceFadeWindow, hWin, FALSE
        
        .ELSEIF eax == DF_TIMER_POPIN ; pop in our window
            Invoke _MUI_DesktopFacePopWindow, hWin, TRUE
            
        .ELSEIF eax == DF_TIMER_POPOUT ; pop out our window
            Invoke _MUI_DesktopFacePopWindow, hWin, FALSE
            
	    .ENDIF

    .ELSEIF eax == WM_SHOWWINDOW
        .IF wParam == TRUE
            ;PrintText 'WM_SHOWWINDOW'
            Invoke KillTimer, hWin, DF_TIMER_FADEOUT
            Invoke KillTimer, hWin, DF_TIMER_POPOUT
            ;PrintText 'MUIDesktopFaceShow show'
            Invoke GetWindowRect, hWin, Addr rect
            mov eax, rect.left
            Invoke MUISetIntProperty, hWin, @DesktopFaceXPos, eax
            mov eax, rect.top
            Invoke MUISetIntProperty, hWin, @DesktopFaceYPos, eax        
            
            
            Invoke MUISetIntProperty, hWin, @DesktopFaceFadeAlphaLevel, 0
            Invoke SetWindowPos, hWin, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOSENDCHANGING or SWP_NOCOPYBITS	 ;SWP_NOZORDER or 
            ;Invoke ShowWindow, hWin, SW_SHOW
            Invoke SetTimer, hWin, DF_TIMER_FADEIN, 10, NULL ; set timer to fade in window
            
            Invoke GetWindowLong, hWin, GWL_STYLE
            and eax, MUIDFS_POPIN
            .IF eax == MUIDFS_POPIN
                Invoke MUISetIntProperty, hWin, @DesktopFacePopHeight, 0
                Invoke SetTimer, hWin, DF_TIMER_POPIN, 10, NULL ; set timer to pop in window
            .ENDIF
            Invoke _MUI_DesktopFaceNotifyParent, hWin, MUIDFN_SHOW, NULL        

            ;Invoke MUIDesktopFaceShow, hWin, TRUE
            ;Invoke MUISetIntProperty, hWin, @DesktopFaceVisible, TRUE
        .ELSE
        
            Invoke GetWindowRect, hWin, Addr rect
            mov eax, rect.left
            Invoke MUISetIntProperty, hWin, @DesktopFaceXPos, eax
            mov eax, rect.top
            Invoke MUISetIntProperty, hWin, @DesktopFaceYPos, eax             
        
            ;Invoke MUIDesktopFaceShow, hWin, FALSE
            ;Invoke MUISetIntProperty, hWin, @DesktopFaceVisible, FALSE
        .ENDIF
        mov eax, 0
        ret
	
;	.ELSEIF eax == WM_WINDOWPOSCHANGING
;	    PrintText 'WM_WINDOWPOSCHANGING'
;	    mov ebx, lParam
;	    mov eax, (WINDOWPOS ptr [ebx]).x
;	    PrintDec eax
;	    mov eax, (WINDOWPOS ptr [ebx]).y
;	    PrintDec eax
	
	
	; custom messages start here
	
	.ELSEIF eax == MUI_GETPROPERTY
		Invoke MUIGetExtProperty, hWin, wParam
		ret
		
	.ELSEIF eax == MUI_SETPROPERTY	
		Invoke MUISetExtProperty, hWin, wParam, lParam
		
		mov eax, wParam
		.IF eax == @DesktopFaceImage && lParam != 0
		    Invoke MUIGetExtProperty, hWin, @DesktopFaceImageType
		    .IF eax != MUIDFIT_NONE
		        Invoke _MUI_DesktopFaceSetSize, hWin
		    .ENDIF
		
		.ELSEIF eax == @DesktopFaceImageType && lParam != 0
		    Invoke MUIGetExtProperty, hWin, @DesktopFaceImage
		    .IF eax != 0
		        Invoke _MUI_DesktopFaceSetSize, hWin
		    .ENDIF
		    
		.ELSEIF eax == @DesktopFaceRegion
		    Invoke SetWindowRgn, hWin, NULL, FALSE
		    Invoke _MUI_DesktopFaceSetSize, hWin
		    Invoke MUISetRegionFromResource, hWin, lParam, NULL, TRUE
		    Invoke InvalidateRgn, hWin, NULL, TRUE
		    Invoke InvalidateRect, hWin, NULL, TRUE
		.ENDIF
		
		ret
		
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_DesktopFaceWndProc ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; _MUI_DesktopFaceInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_DesktopFaceInit PROC PRIVATE hControl:DWORD, hWndParent:DWORD
    LOCAL ncm:NONCLIENTMETRICS
    LOCAL lfnt:LOGFONT
    LOCAL hFont:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hControl
    mov hParent, eax
    
    ; get style and check it is our default at least
;    mov eax, WS_EX_LAYERED or WS_EX_TOOLWINDOW
;    Invoke SetWindowLong, hControl, GWL_EXSTYLE, eax
;
;    Invoke GetWindowLong, hControl, GWL_STYLE
;    mov dwStyle, eax
;    or eax, WS_CHILD
;    and eax, (-1 xor WS_POPUP)
;    Invoke SetWindowLong, hControl, GWL_STYLE, eax 
    ;and eax, WS_POPUP or WS_VISIBLE
    ;.IF eax != WS_POPUP or WS_VISIBLE
    ;    mov eax, dwStyle
    ;    or eax, WS_POPUP or WS_VISIBLE
    ;    mov dwStyle, eax
    ;    Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle
    ;.ENDIF
    
    
    Invoke GetClassLong, hControl, GCL_STYLE
    and eax,(-1 xor CS_DROPSHADOW)
    Invoke SetClassLong, hControl, GCL_STYLE, eax
    Invoke MUISetIntProperty, hControl, @DesktopFaceVisible, FALSE
    Invoke MUISetIntProperty, hControl, @DesktopFaceFadeAlphaLevel, 0
    Invoke MUISetIntProperty, hControl, @DesktopFaceParent, hWndParent
    Invoke MUISetIntProperty, hControl, @DesktopFaceInitialPositionSet, FALSE
    Invoke MUISetExtProperty, hControl, @DesktopFaceOpacity, 255d

    mov eax, DF_FADESTEP
    Invoke MUISetExtProperty, hControl, @DesktopFaceFadeStepIn, eax
    mov eax, DF_FADESTEP_OUT
    Invoke MUISetExtProperty, hControl, @DesktopFaceFadeStepOut, eax
    mov eax, DF_POPSTEP
    Invoke MUISetExtProperty, hControl, @DesktopFacePopStepIn, eax
    mov eax, DF_POPSTEP_OUT
    Invoke MUISetExtProperty, hControl, @DesktopFacePopStepOut, eax    
    
    
    
    ;Invoke _MUI_DesktopFaceSetInitialPosition, hControl
    
    ret

_MUI_DesktopFaceInit ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; _MUI_DesktopFacePaint
;-------------------------------------------------------------------------------------
_MUI_DesktopFacePaint PROC PRIVATE hWin:DWORD
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
    ; Background
    ;----------------------------------------------------------
    ;Invoke _MUI_DesktopFacePaintBackground, hWin, hdcMem, Addr rect

	;----------------------------------------------------------
	; Draw image
	;----------------------------------------------------------
	Invoke _MUI_DesktopFacePaintImage, hWin, hdc, hdcMem, Addr rect

    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    Invoke DeleteDC, hdcMem
    Invoke DeleteObject, hbmMem
    .IF hOldBitmap != 0
        Invoke DeleteObject, hOldBitmap
    .ENDIF		
    
    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_DesktopFacePaint ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; _MUI_DesktopFacePaintBackground
;-------------------------------------------------------------------------------------
_MUI_DesktopFacePaintBackground PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD

    Invoke GetStockObject, NULL_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke FillRect, hdc, lpRect, hBrush

    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF      
    ret

_MUI_DesktopFacePaintBackground ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; _MUI_DesktopFacePaintImage - Paint image
;-------------------------------------------------------------------------------------
_MUI_DesktopFacePaintImage PROC hWin:DWORD, hdc:DWORD, hdcMem:DWORD, lpRect:DWORD
    LOCAL hdcBmpMem:HDC
    LOCAL hbmOld:DWORD
    LOCAL rect:RECT
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL pBitmap:DWORD    
    LOCAL ImageType:DWORD
    LOCAL hImage:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD   
    
    Invoke CopyRect, Addr rect, lpRect
    
    Invoke MUIGetExtProperty, hWin, @DesktopFaceImage
    mov hImage, eax
    Invoke MUIGetExtProperty, hWin, @DesktopFaceImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png
    Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight	    

    mov eax, ImageType
    .IF eax == 1 ; bitmap
        Invoke CreateCompatibleDC, hdc
        mov hdcBmpMem, eax
        Invoke SelectObject, hdcBmpMem, hImage
        mov hbmOld, eax
        Invoke BitBlt, hdcMem, 0, 0, ImageWidth, ImageHeight, hdcBmpMem, 0, 0, SRCCOPY
        Invoke SelectObject, hdcBmpMem, hbmOld
        Invoke DeleteDC, hdcBmpMem
        .IF hbmOld != 0
            Invoke DeleteObject, hbmOld
        .ENDIF
        
    .ELSEIF eax == 2 ; icon
        Invoke DrawIconEx, hdcMem, 0, 0, hImage, ImageWidth, ImageHeight, 0, 0, DI_NORMAL
    
    .ELSEIF eax == 3 ; png
        IFDEF MUI_USEGDIPLUS
;            PrintText 'hImage'
;            PrintDec ImageWidth
;            PrintDec ImageHeight
;            PrintDec pt.x
;            PrintDec pt.y        

        Invoke GdipCreateFromHDC, hdcMem, Addr pGraphics
        Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
        Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer            
        Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
        Invoke GdipDrawImageRectI, pGraphics, pBitmap, 0, 0, ImageWidth, ImageHeight
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

_MUI_DesktopFacePaintImage ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; set initial position of control if x y are set to 0 and flag indicates position
;------------------------------------------------------------------------------
_MUI_DesktopFaceSetInitialPosition PROC USES EBX hWin:DWORD
    LOCAL hMonitor:DWORD
    LOCAL lpmi:MONITORINFOEX
    LOCAL workrect:RECT
    LOCAL winrect:RECT
    LOCAL nWidth:DWORD
    LOCAL nHeight:DWORD
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwPos:DWORD
 
    Invoke MUIGetExtProperty, hWin, @DesktopFaceImage
    .IF eax == 0
        ret
    .ENDIF

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax    
    and eax, MUIDFS_POS_VERT_BOTTOM or MUIDFS_POS_VERT_TOP or MUIDFS_POS_VERT_CENTER or MUIDFS_POS_HORZ_LEFT or MUIDFS_POS_HORZ_CENTER or MUIDFS_POS_HORZ_RIGHT
    mov dwPos, eax
    
    Invoke GetWindowRect, hWin, Addr winrect
    .IF winrect.left != 0 && winrect.top != 0 && dwPos == 0
        ret ; position set by user
    .ENDIF    
    
    ; defaults just in case
    mov eax, winrect.left
    mov nLeft, eax
    mov eax, winrect.top
    mov nTop, eax
    
    Invoke MonitorFromWindow, hWin, MONITOR_DEFAULTTONEAREST
    mov hMonitor, eax
    
    mov lpmi.cbSize, SIZEOF MONITORINFOEX
    Invoke GetMonitorInfo, hMonitor, Addr lpmi
    
    Invoke CopyRect, Addr workrect, Addr lpmi.rcWork
    mov eax, winrect.right
    mov ebx, winrect.left
    sub eax, ebx
    mov nWidth, eax
    
    mov eax, winrect.bottom
    mov ebx, winrect.top
    sub eax, ebx
    mov nHeight, eax    

    mov eax, dwPos
    and eax, MUIDFS_POS_VERT_TOP or MUIDFS_POS_VERT_BOTTOM or MUIDFS_POS_VERT_CENTER
    .IF eax == MUIDFS_POS_VERT_TOP
        mov nTop, 0
    .ELSEIF eax == MUIDFS_POS_VERT_BOTTOM
        mov eax, workrect.bottom
        mov ebx, nHeight
        sub eax, ebx
        mov nTop, eax
    .ELSEIF eax == MUIDFS_POS_VERT_CENTER
        mov eax, workrect.bottom
        mov ebx, workrect.top
        sub eax, ebx
        shr eax, 1 ; div by 2
        mov ebx, nHeight
        shr ebx, 1 ; div by 2
        sub eax, ebx
        mov nTop, eax
    .ELSE
        ;PrintText 'Unknown v position'
        ;PrintDec dwPos
    .ENDIF

    mov eax, dwPos
    and eax, MUIDFS_POS_HORZ_LEFT or MUIDFS_POS_HORZ_CENTER or MUIDFS_POS_HORZ_RIGHT
    .IF eax == MUIDFS_POS_HORZ_LEFT
        mov nLeft, 0
    .ELSEIF eax == MUIDFS_POS_HORZ_RIGHT
        mov eax, workrect.right
        mov ebx, nWidth
        sub eax, ebx
        mov nLeft, eax
        dec nLeft
    .ELSEIF eax == MUIDFS_POS_HORZ_CENTER
        mov eax, workrect.right
        mov ebx, workrect.left
        sub eax, ebx
        shr eax, 1 ; div by 2
        mov ebx, nWidth
        shr ebx, 1 ; div by 2
        sub eax, ebx
        mov nLeft, eax
    .ELSE
        ;PrintText 'Unknown h position'
        ;PrintDec dwPos        
    .ENDIF
    

    
    IFDEF DEBUG32
    ;PrintDec nLeft
    ;PrintDec nTop
    ;PrintDec nWidth
    ;PrintDec nHeight
    ENDIF
    
    Invoke SetWindowPos, hWin, HWND_TOPMOST, nLeft, nTop, 0, 0, SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE
    Invoke MUISetIntProperty, hWin, @DesktopFaceXPos, nLeft
    Invoke MUISetIntProperty, hWin, @DesktopFaceYPos, nTop
    
    ;PrintText 'Initial'
    ;PrintDec nLeft
    ;PrintDec nTop
    
    Invoke MUISetIntProperty, hWin, @DesktopFaceInitialPositionSet, TRUE

    ret

_MUI_DesktopFaceSetInitialPosition ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Set size of control based on image size used
;------------------------------------------------------------------------------
_MUI_DesktopFaceSetSize PROC USES EBX hWin:DWORD
    LOCAL ImageType:DWORD
    LOCAL hImage:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    
    mov ImageWidth, 0
    mov ImageHeight, 0
    
    Invoke MUIGetExtProperty, hWin, @DesktopFaceImage
    mov hImage, eax
    Invoke MUIGetExtProperty, hWin, @DesktopFaceImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png
    
    Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight

    Invoke SetWindowPos, hWin, HWND_TOPMOST, 0, 0, ImageWidth, ImageHeight, SWP_NOOWNERZORDER or SWP_NOMOVE or SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE or SWP_NOCOPYBITS
    Invoke MUISetIntProperty, hWin, @DesktopFaceWidth, ImageWidth
    Invoke MUISetIntProperty, hWin, @DesktopFaceHeight, ImageHeight
    
    Invoke MUIGetIntProperty, hWin, @DesktopFaceInitialPositionSet
    .IF eax == FALSE
        Invoke _MUI_DesktopFaceSetInitialPosition, hWin
    .ENDIF
    ret
_MUI_DesktopFaceSetSize ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_DesktopFaceFadeWindow - fade in/out window
;------------------------------------------------------------------------------
_MUI_DesktopFaceFadeWindow PROC hWin:DWORD, bFadeIn:DWORD
    LOCAL dwAlphaLevel:DWORD
    LOCAL dwFadeStep:DWORD

    .IF bFadeIn == TRUE
        Invoke MUIGetIntProperty, hWin, @DesktopFaceFadeAlphaLevel
        .IF eax >= 255
            Invoke SetLayeredWindowAttributes, hWin, 0, 255d, LWA_ALPHA
            Invoke KillTimer, hWin, DF_TIMER_FADEIN
        .ELSE 
            mov dwAlphaLevel, eax
            Invoke MUIGetExtProperty, hWin, @DesktopFaceOpacity
            .IF dwAlphaLevel >= eax
                Invoke SetLayeredWindowAttributes, hWin, 0, eax, LWA_ALPHA
                Invoke KillTimer, hWin, DF_TIMER_FADEIN
            .ELSE
                Invoke MUIGetExtProperty, hWin, @DesktopFaceFadeStepIn
                mov dwFadeStep, eax
                Invoke SetLayeredWindowAttributes, hWin, 0, dwAlphaLevel, LWA_ALPHA
                mov eax, dwAlphaLevel
                add eax, dwFadeStep;DF_FADESTEP;32d
                Invoke MUISetIntProperty, hWin, @DesktopFaceFadeAlphaLevel, eax
            .ENDIF
        .ENDIF
    
    .ELSE ; fade out

        Invoke MUIGetIntProperty, hWin, @DesktopFaceFadeAlphaLevel
        .IF sdword ptr eax <= 0
            Invoke SetLayeredWindowAttributes, hWin, 0, 0, LWA_ALPHA
            Invoke KillTimer, hWin, DF_TIMER_FADEOUT
            Invoke ShowWindow, hWin, SW_HIDE
        .ELSE
            mov dwAlphaLevel, eax
            .IF sdword ptr dwAlphaLevel <= 0
                Invoke SetLayeredWindowAttributes, hWin, 0, 0, LWA_ALPHA
                Invoke KillTimer, hWin, DF_TIMER_FADEOUT
                Invoke ShowWindow, hWin, SW_HIDE
            .ELSE
                Invoke MUIGetExtProperty, hWin, @DesktopFaceFadeStepOut
                mov dwFadeStep, eax            
                Invoke SetLayeredWindowAttributes, hWin, 0, dwAlphaLevel, LWA_ALPHA
                mov eax, dwAlphaLevel
                sub eax, dwFadeStep;DF_FADESTEP_OUT;32d
                Invoke MUISetIntProperty, hWin, @DesktopFaceFadeAlphaLevel, eax
            .ENDIF
        .ENDIF
    .ENDIF
    ret

_MUI_DesktopFaceFadeWindow ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_DesktopFaceFadeWindow - fade in/out window
;------------------------------------------------------------------------------
_MUI_DesktopFacePopWindow PROC USES EBX hWin:DWORD, bPopIn:DWORD
    LOCAL dwPopHeight:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL dwXPos:DWORD
    LOCAL dwYPos:DWORD
    LOCAL dwPopStep:DWORD

    Invoke MUIGetIntProperty, hWin, @DesktopFaceXPos
    mov dwXPos, eax
    Invoke MUIGetIntProperty, hWin, @DesktopFaceYPos
    mov dwYPos, eax
    Invoke MUIGetIntProperty, hWin, @DesktopFaceHeight
    mov dwHeight, eax
    Invoke MUIGetIntProperty, hWin, @DesktopFaceWidth
    mov dwWidth, eax
    Invoke MUIGetIntProperty, hWin, @DesktopFacePopHeight
    mov dwPopHeight, eax    

    ;PrintDec dwHeight
    ;PrintDec dwWidth

    .IF bPopIn == TRUE

        mov eax, dwHeight
        .IF dwPopHeight >= eax
            Invoke SetWindowPos, hWin, HWND_TOPMOST, dwXPos, dwYPos, dwWidth, dwHeight, SWP_NOOWNERZORDER or SWP_NOZORDER or SWP_NOCOPYBITS;or SWP_NOSENDCHANGING or SWP_NOACTIVATE or SWP_NOCOPYBITS	
            Invoke KillTimer, hWin, DF_TIMER_POPIN
            Invoke MUIGetExtProperty, hWin, @DesktopFaceRegion
            .IF eax != NULL
                Invoke MUISetRegionFromResource, hWin, eax, NULL, TRUE
            .ENDIF
       
            
        .ELSE
            mov eax, dwHeight
            mov ebx, dwPopHeight
            sub eax, ebx
            add eax, dwYPos
            
            Invoke SetWindowPos, hWin, HWND_TOPMOST, dwXPos, eax, dwWidth, dwPopHeight, SWP_NOOWNERZORDER or SWP_NOZORDER or SWP_NOCOPYBITS;or SWP_NOSENDCHANGING or SWP_NOACTIVATE or SWP_NOCOPYBITS
            Invoke _MUI_DesktopFaceApplyPopRegion, hWin, dwWidth, dwHeight, dwPopHeight
            ;Invoke MUIGetExtProperty, hWin, @DesktopFaceRegion
            ;.IF eax != NULL
            ;    Invoke MUISetRegionFromResource, hWin, eax, NULL, FALSE
            ;.ENDIF
            ;Invoke InvalidateRect, hWin, NULL, TRUE
            ;Invoke UpdateWindow, hWin
            
            Invoke MUIGetExtProperty, hWin, @DesktopFacePopStepIn
            mov dwPopStep, eax              
            
            mov eax, dwPopHeight
            add eax, dwPopStep;DF_POPSTEP; 8d
            Invoke MUISetIntProperty, hWin, @DesktopFacePopHeight, eax
         
            
        .ENDIF    
    
    .ELSE
        
        mov eax, dwHeight
        .IF sdword ptr dwPopHeight <= 0
            Invoke SetWindowPos, hWin, HWND_TOPMOST, dwXPos, dwYPos, dwWidth, 0, SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE or SWP_NOCOPYBITS
            Invoke KillTimer, hWin, DF_TIMER_POPOUT
            ;Invoke MUISetRegionFromResource, hWin, NULL, NULL, FALSE
            Invoke ShowWindow, hWin, SW_HIDE
        .ELSE
            mov eax, dwHeight
            mov ebx, dwPopHeight
            sub eax, ebx
            add eax, dwYPos
            Invoke SetWindowPos, hWin, HWND_TOPMOST, dwXPos, eax, dwWidth, dwPopHeight, SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE or SWP_NOCOPYBITS
            Invoke _MUI_DesktopFaceApplyPopRegion, hWin, dwWidth, dwHeight, dwPopHeight
            ;Invoke InvalidateRect, hWin, NULL, TRUE
            
            Invoke MUIGetExtProperty, hWin, @DesktopFacePopStepOut
            mov dwPopStep, eax                  
            
            mov eax, dwPopHeight
            sub eax, dwPopStep ;DF_POPSTEP_OUT ;8d
            Invoke MUISetIntProperty, hWin, @DesktopFacePopHeight, eax
        .ENDIF    
    .ENDIF


    ret
_MUI_DesktopFacePopWindow ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_DesktopFaceApplyPopRegion
;------------------------------------------------------------------------------
_MUI_DesktopFaceApplyPopRegion PROC USES EBX hControl:DWORD, dwWidth:DWORD, dwHeight:DWORD, dwPopHeight:DWORD
    LOCAL hinstance:DWORD
    LOCAL ptrRegion:DWORD
    LOCAL dwRegionSize:DWORD
    LOCAL hRegion:DWORD
    LOCAL hRgnCut:DWORD
    LOCAL dwResRgnID:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax
    
    Invoke MUIGetExtProperty, hControl, @DesktopFaceRegion
    .IF eax == 0
        ret
    .ENDIF
    mov dwResRgnID, eax
    
    Invoke MUILoadRegionFromResource, hinstance, dwResRgnID, Addr ptrRegion, Addr dwRegionSize
    .IF eax == TRUE
        Invoke ExtCreateRegion, NULL, dwRegionSize, ptrRegion
        mov hRegion, eax
        
        ;mov eax, dwHeight
        ;mov ebx, dwPopHeight
        ;sub eax, ebx
        
        ;PrintDec dwPopHeight
        ;PrintDec dwWidth
        ;PrintDec eax
    
        Invoke CreateRectRgn, 0, dwPopHeight, dwWidth, dwHeight
        mov hRgnCut, eax
        Invoke CombineRgn, hRegion, hRegion, hRgnCut, RGN_DIFF
        Invoke SetWindowRgn, hControl, hRegion, FALSE
    .ENDIF
    ;Invoke InvalidateRgn, hControl, NULL, TRUE
    ;Invoke InvalidateRect, hControl, NULL, TRUE
    ;Invoke UpdateWindow, hControl
    ret

_MUI_DesktopFaceApplyPopRegion ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Notify Parent
;------------------------------------------------------------------------------
_MUI_DesktopFaceNotifyParent PROC hControl:DWORD, dwNotifyMsg:DWORD, lParam:DWORD
    LOCAL hParent:DWORD
    LOCAL idControl:DWORD
    
    Invoke MUIGetIntProperty, hControl, @DesktopFaceParent
    mov hParent, eax
    .IF hParent == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke GetDlgCtrlID, hControl
    mov idControl, eax
    mov DFNM.hdr.idFrom, eax
    mov eax, hControl
    mov DFNM.hdr.hwndFrom, eax
    mov eax, dwNotifyMsg
    mov DFNM.hdr.code, eax
    mov eax, lParam
    mov DFNM.lParam, eax

    ; Sent notification
    .IF dwNotifyMsg == MUIDFN_KEYPRESS
        Invoke SendMessage, hParent, WM_NOTIFY, idControl, Addr DFNM
    .ELSE
        Invoke PostMessage, hParent, WM_NOTIFY, idControl, Addr DFNM
        mov eax, TRUE
    .ENDIF
 
    ret
_MUI_DesktopFaceNotifyParent ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Set Region
;------------------------------------------------------------------------------
MUIDesktopFaceSetRegion PROC hControl:DWORD, dwRgnResID:DWORD
    Invoke MUIDesktopFaceSetProperty, hControl, @DesktopFaceRegion, dwRgnResID
    ret
MUIDesktopFaceSetRegion ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Set Opacity
;------------------------------------------------------------------------------
MUIDesktopFaceSetOpacity PROC hControl:DWORD, dwOpacity:DWORD
    Invoke MUIDesktopFaceSetProperty, hControl, @DesktopFaceOpacity, dwOpacity
    Invoke SetLayeredWindowAttributes, hControl, 0, dwOpacity, LWA_ALPHA
    ret
MUIDesktopFaceSetOpacity ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Set Image
;------------------------------------------------------------------------------
MUIDesktopFaceSetImage PROC hControl:DWORD, dwImageType:DWORD, dwImageHandle:DWORD
    Invoke MUIDesktopFaceSetProperty, hControl, @DesktopFaceImageType, dwImageType
    Invoke MUIDesktopFaceSetProperty, hControl, @DesktopFaceImage, dwImageHandle
    ret
MUIDesktopFaceSetImage ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Show/hide
;------------------------------------------------------------------------------
MUIDesktopFaceShow PROC hControl:DWORD, bShow:DWORD
    LOCAL dwHeight:DWORD
    LOCAL dwWidth:DWORD
    LOCAL rect:RECT
    
    .IF bShow == TRUE
        Invoke IsWindowVisible, hControl
        ;Invoke MUIGetIntProperty, hControl, @DesktopFaceVisible
        .IF eax == TRUE
            ret
        .ENDIF
        Invoke ShowWindow, hControl, SW_SHOW
        
        
;        Invoke KillTimer, hControl, DF_TIMER_FADEOUT
;        Invoke KillTimer, hControl, DF_TIMER_POPOUT
;        
;        ;PrintText 'MUIDesktopFaceShow show'
;        Invoke GetWindowRect, hControl, Addr rect
;        ;PrintDec rect.left
;        ;PrintDec rect.top
;        mov eax, rect.left
;        Invoke MUISetIntProperty, hControl, @DesktopFaceXPos, eax
;        mov eax, rect.top
;        Invoke MUISetIntProperty, hControl, @DesktopFaceYPos, eax        
;        
;        
;        Invoke MUISetIntProperty, hControl, @DesktopFaceFadeAlphaLevel, 0
;        Invoke SetWindowPos, hControl, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or SWP_NOSENDCHANGING or SWP_NOCOPYBITS	 ;SWP_NOZORDER or 
;        Invoke ShowWindow, hControl, SW_SHOW
;        Invoke SetTimer, hControl, DF_TIMER_FADEIN, 10, NULL ; set timer to fade in window
;        
;        Invoke GetWindowLong, hControl, GWL_STYLE
;        and eax, MUIDFS_POPIN
;        .IF eax == MUIDFS_POPIN
;            Invoke MUISetIntProperty, hControl, @DesktopFacePopHeight, 0
;            Invoke SetTimer, hControl, DF_TIMER_POPIN, 10, NULL ; set timer to pop in window
;        .ENDIF
;        Invoke _MUI_DesktopFaceNotifyParent, hControl, MUIDFN_SHOW, NULL
        
    .ELSE

       ; Invoke IsWindowVisible, hControl
        ;Invoke MUIGetIntProperty, hControl, @DesktopFaceVisible
        ;.IF eax == FALSE
        ;    ret
        ;.ENDIF        
        
        Invoke KillTimer, hControl, DF_TIMER_FADEIN
        Invoke KillTimer, hControl, DF_TIMER_POPIN

        Invoke GetWindowRect, hControl, Addr rect
        ;PrintDec rect.left
        ;PrintDec rect.top
        mov eax, rect.left
        Invoke MUISetIntProperty, hControl, @DesktopFaceXPos, eax
        mov eax, rect.top
        Invoke MUISetIntProperty, hControl, @DesktopFaceYPos, eax       
        
        ; PrintText 'MUIDesktopFaceShow hide'
        ;Invoke GetWindowRect, hControl, Addr rect
        ;PrintDec rect.left
        ;PrintDec rect.top        
        
        
        Invoke MUIGetExtProperty, hControl, @DesktopFaceOpacity
        Invoke MUISetIntProperty, hControl, @DesktopFaceFadeAlphaLevel, eax
        Invoke SetTimer, hControl, DF_TIMER_FADEOUT, 10, NULL ; set timer to fade out window

        Invoke GetWindowLong, hControl, GWL_STYLE
        and eax, MUIDFS_POPOUT
        .IF eax == MUIDFS_POPOUT
            Invoke MUIGetIntProperty, hControl, @DesktopFaceHeight
            Invoke MUISetIntProperty, hControl, @DesktopFacePopHeight, eax
            Invoke SetTimer, hControl, DF_TIMER_POPOUT, 10, NULL ; set timer to pop out window
        .ENDIF
        Invoke _MUI_DesktopFaceNotifyParent, hControl, MUIDFN_HIDE, NULL
        
    .ENDIF
    ret

MUIDesktopFaceShow ENDP





END
