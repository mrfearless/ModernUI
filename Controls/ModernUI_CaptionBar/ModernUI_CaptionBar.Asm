;======================================================================================================================================
;
; ModernUI Control - ModernUI_CaptionBar v1.0.0.0
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
include comctl32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_CaptionBar.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_CreateCaptionBarWndProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CaptionBarInit                         PROTO :DWORD
_MUI_CaptionBarPaint					    PROTO :DWORD
_MUI_CaptionBarReposition                   PROTO :DWORD
_MUI_CaptionBarParentSubClassProc           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CaptionBarSetSysButtonColor            PROTO :DWORD, :DWORD, :DWORD

_MUI_CreateCaptionBarSysButtons             PROTO :DWORD, :DWORD
_MUI_CreateSysButton                        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SysButtonWndProc                       PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SysButtonInit                          PROTO :DWORD
_MUI_SysButtonPaint                         PROTO :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; CaptionBar External Properties
MUI_CAPTIONBAR_PROPERTIES				    STRUCT
	dwTextColor							    DD ?
	dwTextFont							    DD ?
	dwBackColor							    DD ?
	dwSysButtonTextRollColor                DD ?
	dwSysButtonBackRollColor                DD ?
MUI_CAPTIONBAR_PROPERTIES				    ENDS

; CaptionBar Internal Poperties
_MUI_CAPTIONBAR_PROPERTIES				    STRUCT
	dwEnabledState						    DD ?
	dwMouseOver							    DD ?
	hSysButtonClose                         DD ?
	hSysButtonMax                           DD ?
	hSysButtonRes                           DD ?
	hSysButtonMin                           DD ?
_MUI_CAPTIONBAR_PROPERTIES				    ENDS

; SysButton External Properties
MUI_SYSBUTTON_PROPERTIES                    STRUCT
	dwTextColor							    DD ?
	dwTextRollColor                         DD ?
	dwBackColor							    DD ?
	dwBackRollColor                         DD ?
    dwSysButtonType                         DD ?	
MUI_SYSBUTTON_PROPERTIES                    ENDS

; SysButton Internal Properties
_MUI_SYSBUTTON_PROPERTIES                   STRUCT
    dwSysButtonFont						    DD ?
	dwEnabledState						    DD ?
	dwMouseOver							    DD ?
_MUI_SYSBUTTON_PROPERTIES                   ENDS


.CONST
; CaptionBar Internal Properties
@CaptionBarEnabledState				        EQU 0
@CaptionBarMouseOver					    EQU 4
@CaptionBar_hSysButtonClose                 EQU 8
@CaptionBar_hSysButtonMax                   EQU 12
@CaptionBar_hSysButtonRes                   EQU 16
@CaptionBar_hSysButtonMin                   EQU 20

; SysButton Internal Properties
@SysButtonFont                              EQU 0
@SysButtonEnabledState						EQU 4
@SysButtonMouseOver							EQU 8

; SysButton External Properties
@SysButtonTextColor							EQU 0 
@SysButtonTextRollColor                     EQU 4
@SysButtonBackColor							EQU 8
@SysButtonBackRollColor                     EQU 12
@SysButtonType                              EQU 16

.DATA
szMUICaptionBarClass					    DB 'ModernUICaptionBar',0   ; Class name for our CaptionBar control
szMUISysButtonClass                         DB 'ModernUISysButton',0    ; Class name for our system buttons (min/max/restore or close buttons)
szMUISysButtonFont                          DB 'Marlett',0              ; System font used for drawing min/max/restore/close glyphs from marlett font
szMUICaptionBarFont                         DB 'Segoe UI',0             ; Font used for caption text
hMUISysButtonFont                           DD 0                        ; Handle to system button font (marlett)
hMUICaptionBarFont                          DD 0                        ; Handle to caption button font (segoe ui)
szMUISysMinButton                           DB '0',0                    ; Minimize button glyph from Marlett font
szMUISysMaxButton                           DB '1',0                    ; Maximize button glyph from Marlett font
szMUISysResButton                           DB '2',0                    ; Restore button glyph from Marlett font
szMUISysCloseButton                         DB 'r',0                    ; Close/exit button glyph from Marlett font
szMUISysResizeGrip                          DB 'o',0                    ; Resize grip button glyph from Marlett font

.CODE

;-------------------------------------------------------------------------------------
; Set property for CaptionBar control
;-------------------------------------------------------------------------------------
MUICaptionBarSetProperty PROC PUBLIC hCaptionBar:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hCaptionBar, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUICaptionBarSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for CaptionBar control
;-------------------------------------------------------------------------------------
MUICaptionBarGetProperty PROC PUBLIC hCaptionBar:DWORD, dwProperty:DWORD
    Invoke SendMessage, hCaptionBar, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUICaptionBarGetProperty ENDP


;-------------------------------------------------------------------------------------
; MUIRegisterCaptionBar - Registers the ModernUI_CaptionBar control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_CaptionBar
;-------------------------------------------------------------------------------------
MUIRegisterCaptionBar PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx, hinstance, Addr szMUICaptionBarClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUICaptionBarClass
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
    	mov wc.lpfnWndProc, OFFSET _MUI_CaptionBarWndProc
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

MUIRegisterCaptionBar ENDP


;-------------------------------------------------------------------------------------
; MUICreateCaptionBar - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUICreateCaptionBar PROC PUBLIC USES EBX hWndParent:DWORD, lpszCaptionText:DWORD, dwCaptionHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL hinstance:DWORD
	LOCAL hControl:DWORD
	LOCAL rect:RECT
	LOCAL dwControlStyle:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax
	
	Invoke MUIRegisterCaptionBar
    
    Invoke GetWindowRect, hWndParent, Addr rect
    mov eax, rect.right
    mov ebx, rect.left
    sub eax, ebx
    
    ; Modify styles appropriately - for visual controls no CS_HREDRAW CS_VREDRAW (causes flickering)
	; probably need WS_CHILD, WS_VISIBLE. Needs WS_CLIPCHILDREN. Non visual prob dont need any of these.
	mov eax, dwStyle
	or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
	mov dwControlStyle, eax
	
    Invoke CreateWindowEx, NULL, Addr szMUICaptionBarClass, lpszCaptionText, dwControlStyle, 0, 0, eax, dwCaptionHeight, hWndParent, dwResourceID, hinstance, NULL
	mov hControl, eax
	.IF eax != NULL
		;Invoke _MUISetIntProperty, hControl, @CaptionBarStyle, dwStyle
		;Invoke _MUISetIntProperty, hControl, @CaptionBar_hCaptionBarParent, hWndParent
		;Invoke _MUI_CreateCaptionBarSysButtons, hControl, hWndParent
		;Invoke SetWindowText, hWndParent, lpszCaptionText
		
		; Subclass parent window to allow us to handle sizing stuff
        ;Invoke SetWindowSubclass, hWndParent, Addr _MUI_CaptionBarParentSubClassProc, 0, hControl
		
	.ENDIF
	mov eax, hControl
    ret
MUICreateCaptionBar ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_CaptionBarWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL wp:WINDOWPLACEMENT
    LOCAL hParent:DWORD
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        Invoke GetParent, hWin
        mov hParent, eax
        mov ebx, lParam
		; sets text of our control, delete if not required.
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName
        ; Set main window title
        Invoke SetWindowText, hParent, (CREATESTRUCT PTR [ebx]).lpszName
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
		Invoke _MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_CAPTIONBAR_PROPERTIES ; internal properties
		Invoke _MUIAllocMemProperties, hWin, 4, SIZEOF MUI_CAPTIONBAR_PROPERTIES ; external properties
		Invoke _MUI_CaptionBarInit, hWin
		mov eax, 0
		ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUIFreeMemProperties, hWin, 0
		Invoke _MUIFreeMemProperties, hWin, 4

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == 1 ; close button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_CLOSE, 0, 0
            ret
        .ELSEIF eax == 2 ; max button
            Invoke GetParent, hWin
            Invoke ShowWindow, eax, SW_MAXIMIZE
            Invoke _MUI_CaptionBarReposition, hWin
            ret            
        .ELSEIF eax == 3 ; res button
            Invoke GetParent, hWin
            Invoke ShowWindow, eax, SW_RESTORE
            Invoke _MUI_CaptionBarReposition, hWin
            ret
        .ELSEIF eax == 4 ; min button
            Invoke GetParent, hWin
            Invoke ShowWindow, eax, SW_MINIMIZE
            ret
        .ENDIF

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_CaptionBarPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax == WM_NCHITTEST
        Invoke GetParent, hWin
        Invoke SendMessage, eax, WM_NCLBUTTONDOWN, HTCAPTION, 0

   .ELSEIF eax == WM_MOUSEMOVE
        Invoke _MUIGetIntProperty, hWin, @CaptionBarEnabledState
        .IF eax == TRUE   
    		Invoke _MUISetIntProperty, hWin, @CaptionBarMouseOver , TRUE
    		.IF eax != TRUE
    		    Invoke InvalidateRect, hWin, NULL, TRUE
    		    mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
    		    mov TE.dwFlags, TME_LEAVE
    		    mov eax, hWin
    		    mov TE.hwndTrack, eax
    		    mov TE.dwHoverTime, NULL
    		    Invoke TrackMouseEvent, Addr TE
    		.ENDIF
        .ENDIF
        
    .ELSEIF eax == WM_MOUSELEAVE
        Invoke _MUISetIntProperty, hWin, @CaptionBarMouseOver , FALSE
		Invoke InvalidateRect, hWin, NULL, TRUE
		Invoke LoadCursor, NULL, IDC_ARROW
		Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke _MUISetIntProperty, hWin, @CaptionBarMouseOver , FALSE
		Invoke InvalidateRect, hWin, NULL, TRUE
		Invoke LoadCursor, NULL, IDC_ARROW
		Invoke SetCursor, eax
	
	.ELSEIF eax == WM_SIZE
	    Invoke _MUI_CaptionBarReposition, hWin
	    mov eax, 0
	    ret
	
	; custom messages start here
	
	.ELSEIF eax == MUI_GETPROPERTY
		Invoke MUIGetExtProperty, hWin, wParam
		ret
		
	.ELSEIF eax == MUI_SETPROPERTY
		Invoke MUISetExtProperty, hWin, wParam, lParam
		
		; also set child system button colors as well
		Invoke _MUI_CaptionBarSetSysButtonColor, hWin, wParam, lParam
		ret
		
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret


    ret
_MUI_CaptionBarWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarParentSubClassProc - Subclass for caption bar parent window 
;-------------------------------------------------------------------------------------
_MUI_CaptionBarParentSubClassProc PROC PRIVATE hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL hParent:DWORD
    LOCAL wp:WINDOWPLACEMENT
    
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Addr _MUI_CaptionBarParentSubClassProc, uIdSubclass
        ret
        
    .ELSEIF eax == WM_SIZE
        mov eax, wParam
        .IF eax == SIZE_MAXIMIZED
            Invoke SendMessage, dwRefData, WM_SIZE, 0, 0
        .ELSEIF eax == SIZE_RESTORED
            Invoke SendMessage, dwRefData, WM_SIZE, 0, 0
        .ENDIF
    .ENDIF
    
    Invoke DefSubclassProc, hWin, uMsg, wParam, lParam 
    ret        
_MUI_CaptionBarParentSubClassProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_CaptionBarInit PROC PRIVATE hCaptionBar:DWORD
    LOCAL ncm:NONCLIENTMETRICS
    LOCAL lfnt:LOGFONT
    LOCAL hFont:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hCaptionBar
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hCaptionBar, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hCaptionBar, GWL_STYLE, dwStyle
    .ENDIF
    ;PrintDec dwStyle
    
    ; Set default initial external property values     
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarTextColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(21,133,181)
    
    .IF hMUICaptionBarFont == 0
    	mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
    	Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
    	Invoke CreateFontIndirect, Addr ncm.lfMessageFont
    	mov hFont, eax
	    Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
	    mov lfnt.lfHeight, -12d
	    mov lfnt.lfWeight, FW_BOLD
	    Invoke CreateFontIndirect, Addr lfnt
        mov hMUICaptionBarFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarTextFont, hMUICaptionBarFont

    Invoke _MUI_CreateCaptionBarSysButtons, hCaptionBar, hParent
    
    Invoke SetWindowSubclass, hParent, Addr _MUI_CaptionBarParentSubClassProc, 0, hCaptionBar

    ret

_MUI_CaptionBarInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarPaint
;-------------------------------------------------------------------------------------
_MUI_CaptionBarPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL MouseOver:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL dwStyle:DWORD
    LOCAL szText[256]:BYTE    

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
	; Get properties
	;----------------------------------------------------------
	;Invoke _MUIGetIntProperty, hWin, @CaptionBarStyle
	;mov dwStyle, eax
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax	
	
	Invoke _MUIGetIntProperty, hWin, @CaptionBarMouseOver
    mov MouseOver, eax
    Invoke MUIGetExtProperty, hWin, @CaptionBarTextColor        ; normal text color
    mov TextColor, eax
    Invoke MUIGetExtProperty, hWin, @CaptionBarBackColor        ; normal back color
    mov BackColor, eax
    Invoke MUIGetExtProperty, hWin, @CaptionBarTextFont        
    mov hFont, eax
	
	;----------------------------------------------------------
	; Fill background
	;----------------------------------------------------------
    Invoke SetBkMode, hdcMem, OPAQUE
    Invoke SetBkColor, hdcMem, BackColor
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    Invoke SetDCBrushColor, hdcMem, BackColor
    Invoke FillRect, hdcMem, Addr rect, hBrush

	;----------------------------------------------------------
	; Draw Text
	;----------------------------------------------------------
	Invoke SelectObject, hdcMem, hFont
    mov hOldFont, eax
    Invoke GetWindowText, hWin, Addr szText, sizeof szText
    Invoke SetTextColor, hdcMem, TextColor
    
    mov eax, dwStyle
    and eax, MUICS_CENTER
    .IF eax == MUICS_CENTER
        Invoke DrawText, hdcMem, Addr szText, -1, Addr rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
    .ELSE
        add rect.left, 6d
        Invoke DrawText, hdcMem, Addr szText, -1, Addr rect, DT_SINGLELINE or DT_LEFT or DT_VCENTER
        sub rect.left, 6d
    .ENDIF

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
    .IF hOldFont != 0
        Invoke DeleteObject, hOldFont
    .ENDIF
    .IF hOldBrush != 0
        Invoke DeleteObject, hOldBrush
    .ENDIF        
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    
    Invoke EndPaint, hWin, Addr ps
	

    ret
_MUI_CaptionBarPaint ENDP


;-------------------------------------------------------------------------------------
; _MUI_CreateCaptionBarSysButtons - create all specified system buttons
;-------------------------------------------------------------------------------------
_MUI_CreateCaptionBarSysButtons PROC PRIVATE USES EBX hCaptionBar:DWORD, hCaptionBarParent:DWORD
    LOCAL wp:WINDOWPLACEMENT
    LOCAL dwLeftOffset:DWORD
    LOCAL rect:RECT
    LOCAL xpos:DWORD
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    LOCAL dwStyle:DWORD
    
    mov dwLeftOffset, 32d ; start with width of first button
    Invoke GetWindowRect, hCaptionBar, Addr rect
    
    Invoke GetWindowLong, hCaptionBar, GWL_STYLE
    mov dwStyle, eax
    
    mov eax, dwStyle
    and eax, MUICS_NOCLOSEBUTTON
    .IF eax != MUICS_NOCLOSEBUTTON
        ; create close button
        mov eax, rect.right
        mov ebx, rect.left
        sub eax, ebx
        sub eax, dwLeftOffset
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysCloseButton, eax, 0, 32d, 24d, 1
        mov hSysButtonClose, eax
        
        ; check if red button style is supplied, if so we override colors for this button
        mov eax, dwStyle
        and eax, MUICS_REDCLOSEBUTTON
        .IF eax == MUICS_REDCLOSEBUTTON
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextRollColor, MUI_RGBCOLOR(255,255,255)
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackRollColor, MUI_RGBCOLOR(166,26,32)
        .ENDIF
        
        add dwLeftOffset, 32d
    .ELSE
        mov hSysButtonClose, 0
    .ENDIF    
    
    mov eax, dwStyle
    and eax, MUICS_NOMAXBUTTON
    .IF eax != MUICS_NOMAXBUTTON
        ; create max and restore buttons
        mov eax, rect.right
        mov ebx, rect.left
        sub eax, ebx
        sub eax, dwLeftOffset
        mov xpos, eax
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysMaxButton, xpos, 0, 32d, 24d, 2
        mov hSysButtonMax, eax
        
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysResButton, xpos, 0, 32d, 24d, 3
        mov hSysButtonRes, eax
        add dwLeftOffset, 32d
        ; hide max/res button depending on current window placement
        Invoke GetWindowPlacement, hCaptionBarParent, Addr wp
        .IF wp.showCmd == SW_SHOWNORMAL
            Invoke ShowWindow, hSysButtonRes, SW_HIDE
        .ELSE
            Invoke ShowWindow, hSysButtonMax, SW_HIDE
        .ENDIF
    .ELSE
        mov hSysButtonMax, 0
        mov hSysButtonRes, 0
    .ENDIF
    
    mov eax, dwStyle
    and eax, MUICS_NOMINBUTTON
    .IF eax != MUICS_NOMINBUTTON
        ; create min button
        mov eax, rect.right
        mov ebx, rect.left
        sub eax, ebx
        sub eax, dwLeftOffset
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysMinButton, eax, 0, 32d, 24d, 4
        mov hSysButtonMin, eax
        add dwLeftOffset, 32d    
    .ELSE
        mov hSysButtonMin, 0
    .ENDIF

    ; save handles to child system buttons in our internal properties of CaptionBar
    Invoke _MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose, hSysButtonClose
    Invoke _MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax, hSysButtonMax
    Invoke _MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes, hSysButtonRes
    Invoke _MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin, hSysButtonMin

    ret

_MUI_CreateCaptionBarSysButtons ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarReposition - Reposition window and child system buttons after main
; window resizes - call WM_SIZE
;-------------------------------------------------------------------------------------
_MUI_CaptionBarReposition PROC PRIVATE USES EBX hCaptionBar:DWORD
    LOCAL wp:WINDOWPLACEMENT
    LOCAL hDefer:DWORD
    LOCAL dwClientWidth:DWORD
    LOCAL dwClientHeight:DWORD
    LOCAL TotalItems:DWORD
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    LOCAL dwCaptionHeight:DWORD
    LOCAL dwLeftOffset:DWORD
    LOCAL hParent:DWORD
    LOCAL rect:RECT

    Invoke GetParent, hCaptionBar
    mov hParent, eax

    mov dwLeftOffset, 32d
    Invoke GetClientRect, hCaptionBar, Addr rect
    mov eax, rect.bottom
    mov dwCaptionHeight, eax
    
    Invoke GetWindowRect, hParent, Addr rect
    mov eax, rect.right
    mov ebx, rect.left
    sub eax, ebx
    mov dwClientWidth, eax
    mov eax, rect.bottom
    mov ebx, rect.top
    sub eax, ebx
    mov dwClientHeight, eax
    
    mov TotalItems, 0
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose
    mov hSysButtonClose, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax
    mov hSysButtonMax, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes
    mov hSysButtonRes, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin
    mov hSysButtonMin, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF

    Invoke BeginDeferWindowPos, TotalItems
    mov hDefer, eax
    ; have to move this caption bar first, so that child controls can be moved inside of the new width (cant use defer on this window)
    Invoke SetWindowPos, hCaptionBar, NULL, 0, 0, dwClientWidth, dwCaptionHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING	 ;SWP_NOCOPYBITS	 or SWP_NOREDRAW 

    .IF hSysButtonClose != NULL
        mov eax, dwClientWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonClose, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER  or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	;or SWP_NOCOPYBITS
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonClose, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	
        .ENDIF
        add dwLeftOffset, 32d
    .ENDIF

    .IF hSysButtonMax != NULL && hSysButtonRes != NULL
        mov eax, dwClientWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonMax, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonMax, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER  or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	
        .ENDIF

        mov eax, dwClientWidth
        sub eax, dwLeftOffset        
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonRes, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonRes, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	
        .ENDIF        
        add dwLeftOffset, 32d
    .ENDIF
    
    .IF hSysButtonMin != NULL
        mov eax, dwClientWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonMin, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonMin, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING	
        .ENDIF
    .ENDIF

    .IF hDefer != NULL
        Invoke EndDeferWindowPos, hDefer
    .ENDIF    

    Invoke InvalidateRect, hCaptionBar, NULL, TRUE

    Invoke GetWindowPlacement, hParent, Addr wp
    .IF wp.showCmd == SW_SHOWNORMAL
        Invoke ShowWindow, hSysButtonRes, SW_HIDE
        Invoke ShowWindow, hSysButtonMax, SW_SHOW
    .ELSE
        Invoke ShowWindow, hSysButtonMax, SW_HIDE
        Invoke ShowWindow, hSysButtonRes, SW_SHOW
    .ENDIF
    
    ret

_MUI_CaptionBarReposition ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarSetSysButtonColor - Sets the system button colors from the message
; MUIM_SETPROPERTY set to the parent CaptionBar control 
;-------------------------------------------------------------------------------------
_MUI_CaptionBarSetSysButtonColor PROC PRIVATE USES EBX hCaptionBar:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    LOCAL dwStyle:DWORD

    .IF dwProperty == @CaptionBarTextFont
        ret
    .ENDIF
    
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose
    mov hSysButtonClose, eax
    .IF eax != NULL
        mov eax, dwProperty
        .IF eax == @CaptionBarTextColor
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBackColor
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnTxtRollColor || eax == @CaptionBarBtnBckRollColor
        
            Invoke GetWindowLong, hCaptionBar, GWL_STYLE
            mov dwStyle, eax        
            ;Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBarStyle
            and eax, MUICS_REDCLOSEBUTTON
            .IF eax == MUICS_REDCLOSEBUTTON
                Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextRollColor, MUI_RGBCOLOR(255,255,255)
                Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackRollColor, MUI_RGBCOLOR(166,26,32)
            .ELSE
                mov eax, dwProperty
                .IF eax == @CaptionBarBtnTxtRollColor
                    Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextRollColor, dwPropertyValue
                .ELSEIF eax == @CaptionBarBtnBckRollColor
                    Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackRollColor, dwPropertyValue
                .ENDIF
            .ENDIF   
        .ENDIF
    .ENDIF
    
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax
    mov hSysButtonMax, eax
    .IF eax != NULL
        mov eax, dwProperty
        .IF eax == @CaptionBarTextColor
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonTextColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBackColor
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonBackColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnTxtRollColor
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonTextRollColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBckRollColor
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonBackRollColor, dwPropertyValue
        .ENDIF
    .ENDIF
    
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes
    mov hSysButtonRes, eax
    .IF eax != NULL
        mov eax, dwProperty
        .IF eax == @CaptionBarTextColor
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonTextColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBackColor
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonBackColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnTxtRollColor
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonTextRollColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBckRollColor
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonBackRollColor, dwPropertyValue
        .ENDIF
    .ENDIF
    
    Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin
    mov hSysButtonMin, eax
    .IF eax != NULL
        mov eax, dwProperty
        .IF eax == @CaptionBarTextColor
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonTextColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBackColor
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonBackColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnTxtRollColor
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonTextRollColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBckRollColor
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonBackRollColor, dwPropertyValue
        .ENDIF
    .ENDIF
    
    ret
_MUI_CaptionBarSetSysButtonColor ENDP


;-------------------------------------------------------------------------------------
; _MUI_CreateSysButton - create a system button (min, max, restore or close button)
;-------------------------------------------------------------------------------------
_MUI_CreateSysButton PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUISysButtonClass,addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUISysButtonClass
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
    	mov wc.lpfnWndProc, OFFSET _MUI_SysButtonWndProc
    	Invoke LoadCursor, NULL, IDC_ARROW
    	mov wc.hCursor, eax
    	mov wc.hIcon, 0
    	mov wc.hIconSm, 0
    	mov wc.lpszMenuName, NULL
    	mov wc.hbrBackground, NULL
    	mov wc.style, NULL
        mov wc.cbClsExtra, 0
    	mov wc.cbWndExtra, 8
    	Invoke RegisterClassEx, addr wc
    .ENDIF   
    Invoke CreateWindowEx, NULL, Addr szMUISysButtonClass, lpszText, WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL ;WS_EX_TRANSPARENT needed only for click through or WS_CLIPSIBLINGS
    ret

_MUI_CreateSysButton ENDP


;-------------------------------------------------------------------------------------
; _MUI_SysButtonWndProc - Main processing window for system buttons: min/max/res/close 
;-------------------------------------------------------------------------------------
_MUI_SysButtonWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL wp:WINDOWPLACEMENT
    
    mov eax,uMsg
    .IF eax == WM_CREATE
		Invoke _MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_SYSBUTTON_PROPERTIES ; internal properties
		Invoke _MUIAllocMemProperties, hWin, 4, SIZEOF MUI_SYSBUTTON_PROPERTIES ; external properties
		Invoke _MUI_SysButtonInit, hWin
		mov eax, 0
		ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUIGetIntProperty, hWin, @SysButtonFont
        .IF eax != 0
            Invoke DeleteObject, eax
        .ENDIF
        Invoke _MUIFreeMemProperties, hWin, 0
		Invoke _MUIFreeMemProperties, hWin, 4   
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_SysButtonPaint, hWin
        mov eax, 0
        ret
   
    .ELSEIF eax == WM_LBUTTONUP
		Invoke GetDlgCtrlID, hWin
		mov ebx,eax
		Invoke GetParent, hWin
		Invoke PostMessage, eax, WM_COMMAND, ebx, hWin
   
   .ELSEIF eax == WM_MOUSEMOVE
        Invoke _MUISetIntProperty, hWin, @SysButtonMouseOver, TRUE
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
        Invoke _MUISetIntProperty, hWin, @SysButtonMouseOver, FALSE
		Invoke InvalidateRect, hWin, NULL, TRUE
		Invoke LoadCursor, NULL, IDC_ARROW
		Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke _MUISetIntProperty, hWin, @SysButtonMouseOver, FALSE
		Invoke InvalidateRect, hWin, NULL, TRUE
		Invoke LoadCursor, NULL, IDC_ARROW
		Invoke SetCursor, eax
		
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_SysButtonWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_SysButtonInit - default intial values for properties for SysButton
;-------------------------------------------------------------------------------------
_MUI_SysButtonInit PROC PRIVATE hSysButton:DWORD

    ; Set default initial external property values     
    Invoke MUISetExtProperty, hSysButton, @SysButtonTextColor, MUI_RGBCOLOR(228,228,228)
    Invoke MUISetExtProperty, hSysButton, @SysButtonTextRollColor, MUI_RGBCOLOR(0,0,0)
    Invoke MUISetExtProperty, hSysButton, @SysButtonBackColor, MUI_RGBCOLOR(21,133,181)
    Invoke MUISetExtProperty, hSysButton, @SysButtonBackRollColor, MUI_RGBCOLOR(138,194,218)
    

    .IF hMUISysButtonFont == 0
        Invoke CreateFont, -10, 0, 0, 0, FW_THIN, FALSE, FALSE, FALSE, SYMBOL_CHARSET, 0, 0, 0, 0, Addr szMUISysButtonFont
        mov hMUISysButtonFont, eax
    .ENDIF
    
    ; Set internal property for font for system buttons 
    Invoke _MUISetIntProperty, hSysButton, @SysButtonFont, hMUISysButtonFont

    ret

_MUI_SysButtonInit ENDP


;-------------------------------------------------------------------------------------
; Main system button painting
;-------------------------------------------------------------------------------------
_MUI_SysButtonPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL MouseOver:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL szText[16]:BYTE
    
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
	; Get properties
	;----------------------------------------------------------
	Invoke _MUIGetIntProperty, hWin, @SysButtonMouseOver
    mov MouseOver, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hWin, @SysButtonTextColor        ; normal text color
    .ELSE
        Invoke MUIGetExtProperty, hWin, @SysButtonTextRollColor    ; mouseover text color
    .ENDIF
    mov TextColor, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hWin, @SysButtonBackColor        ; normal back color
    .ELSE
        Invoke MUIGetExtProperty, hWin, @SysButtonBackRollColor    ; mouseover back color
    .ENDIF
    mov BackColor, eax
    Invoke _MUIGetIntProperty, hWin, @SysButtonFont             ; Marlett font
    mov hFont, eax

	;----------------------------------------------------------
	; Fill background
	;----------------------------------------------------------    
    Invoke SetBkMode, hdcMem, OPAQUE
    Invoke SetBkColor, hdcMem, BackColor
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    Invoke SetDCBrushColor, hdcMem, BackColor
    Invoke FillRect, hdcMem, Addr rect, hBrush

	;----------------------------------------------------------
	; Draw Text
	;----------------------------------------------------------
	Invoke SelectObject, hdcMem, hFont
    mov hOldFont, eax
    ;PrintDec hFont
    ;PrintDec hOldFont
    Invoke GetWindowText, hWin, Addr szText, sizeof szText
    Invoke SetTextColor, hdcMem, TextColor
    Invoke DrawText, hdcMem, Addr szText, -1, Addr rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER

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
    .IF hOldFont != 0
       Invoke DeleteObject, hOldFont
    .ENDIF
    .IF hOldBrush != 0
        Invoke DeleteObject, hOldBrush
    .ENDIF        
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    
    Invoke EndPaint, hWin, Addr ps
    ret

_MUI_SysButtonPaint ENDP























END
