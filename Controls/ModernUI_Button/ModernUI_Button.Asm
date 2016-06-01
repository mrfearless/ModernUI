;======================================================================================================================================
;
; ModernUI Control - ModernUI_Button v1.0.0.0
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
include kernel32.inc
include user32.inc
include gdi32.inc
include gdiplus.inc
include ole32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib gdiplus.lib
includelib ole32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_Button.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_ButtonWndProc					        PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonInit					            PROTO :DWORD
_MUI_ButtonCleanup                          PROTO :DWORD
_MUI_ButtonPaint					        PROTO :DWORD

_MUI_ButtonPaintBackground                  PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintAccent                      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintText                        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintImages                      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintBorder                      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

_MUI_ButtonLoadBitmap                       PROTO :DWORD, :DWORD, :DWORD
_MUI_ButtonLoadIcon                         PROTO :DWORD, :DWORD, :DWORD
_MUI_ButtonLoadPng                          PROTO :DWORD, :DWORD, :DWORD

_MUI_ButtonGetImageSize                     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; External public properties
MUI_BUTTON_PROPERTIES				        STRUCT
    dwTextFont                              DD ?
    dwTextColor                             DD ? 
    dwTextColorAlt                          DD ? 
    dwTextColorSel                          DD ? 
    dwTextColorSelAlt                       DD ? 
    dwTextColorDisabled                     DD ? 
    dwBackColor                             DD ? 
    dwBackColorAlt                          DD ? 
    dwBackColorSel                          DD ? 
    dwBackColorSelAlt                       DD ? 
    dwBackColorDisabled                     DD ? 
    dwBorderColor                           DD ? 
    dwBorderColorAlt                        DD ? 
    dwBorderColorSel                        DD ? 
    dwBorderColorSelAlt                     DD ? 
    dwBorderColorDisabled                   DD ? 
    dwBorderStyle                           DD ? 
    dwAccentColor                           DD ? 
    dwAccentColorAlt                        DD ? 
    dwAccentColorSel                        DD ? 
    dwAccentColorSelAlt                     DD ? 
    dwAccentStyle                           DD ? 
    dwAccentStyleAlt                        DD ? 
    dwAccentStyleSel                        DD ? 
    dwAccentStyleSelAlt                     DD ? 
    dwImageType                             DD ? 
    dwImage                                 DD ? 
    dwImageAlt                              DD ? 
    dwImageSel                              DD ? 
    dwImageSelAlt                           DD ? 
    dwImageDisabled                         DD ? 
    dwNotifyTextFont                        DD ? 
    dwNotifyTextColor                       DD ? 
    dwNotifyBackColor                       DD ? 
    dwNotifyRound                           DD ? 
    dwNotifyImageType                       DD ? 
    dwNotifyImage                           DD ? 
    dwButtonNoteTextFont                    DD ?
    dwButtonNoteTextColor                   DD ?
    dwButtonNoteTextColorDisabled           DD ?
MUI_BUTTON_PROPERTIES				        ENDS

; Internal properties
_MUI_BUTTON_PROPERTIES				        STRUCT
	dwEnabledState						    DD ?
	dwMouseOver							    DD ?
	dwSelectedState                         DD ?
	dwMouseDown                             DD ?
	dwNotifyState                           DD ?
	lpszNotifyText                          DD ?
	lpszNoteText                            DD ?
	dwImageStream                           DD ?
	dwImageAltStream                        DD ?
	dwImageSelStream                        DD ?
	dwImageSelAltStream                     DD ?
	dwImageDisabledStream                   DD ?
	dwNotifyImageStream                     DD ?
_MUI_BUTTON_PROPERTIES				        ENDS


.CONST
ACCENTWIDTH                                 EQU 6d


; Internal properties
@ButtonEnabledState				            EQU 0
@ButtonMouseOver					        EQU 4
@ButtonSelectedState                        EQU 8
@ButtonMouseDown                            EQU 12
@ButtonNotifyState                          EQU 16
@ButtonszNotifyText                         EQU 20
@ButtonszNoteText                           EQU 24
@ButtonImageStream                          EQU 28
@ButtonImageAltStream                       EQU 32
@ButtonImageSelStream                       EQU 36
@ButtonImageSelAltStream                    EQU 40
@ButtonImageDisabledStream                  EQU 44
@ButtonNotifyImageStream                    EQU 48

; External public properties


.DATA
szMUIButtonClass					        DB 'ModernUI_Button',0 	        ; Class name for creating our ModernUI_Button control
szMUIButtonFont                             DB 'Segoe UI',0             	; Font used for ModernUI_Button text
hMUIButtonFont                              DD 0                        	; Handle to ModernUI_Button font (segoe ui)
hMUIButtonNotifyFont                        DD 0
hMUIButtonNoteFont                          DD 0


.DATA?
IFDEF DEBUG32
DbgVar                                      DD ?
ENDIF

.CODE
;-------------------------------------------------------------------------------------
; Set property for ModernUI_Button control
;-------------------------------------------------------------------------------------
MUIButtonSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIButtonSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for ModernUI_Button control
;-------------------------------------------------------------------------------------
MUIButtonGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIButtonGetProperty ENDP


;-------------------------------------------------------------------------------------
; MUIButtonRegister - Registers the ModernUI_Button control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Button
;-------------------------------------------------------------------------------------
MUIButtonRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIButtonClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIButtonClass
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
    	mov wc.lpfnWndProc, OFFSET _MUI_ButtonWndProc
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

MUIButtonRegister ENDP


;-------------------------------------------------------------------------------------
; MUIButtonCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUIButtonCreate PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	LOCAL hControl:DWORD
	LOCAL dwNewStyle:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

	Invoke MUIButtonRegister
	
    ; Modify styles appropriately - for visual controls no CS_HREDRAW CS_VREDRAW (causes flickering)
	; probably need WS_CHILD, WS_VISIBLE. Needs WS_CLIPCHILDREN. Non visual prob dont need any of these.

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
	
    Invoke CreateWindowEx, NULL, Addr szMUIButtonClass, lpszText, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
	mov hControl, eax
	.IF eax != NULL
		
	.ENDIF
	mov eax, hControl
    ret
MUIButtonCreate ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_ButtonWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL hParent:DWORD
    LOCAL rect:RECT
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
		; sets text of our control, delete if not required.
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName	
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
		Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_BUTTON_PROPERTIES ; internal properties
		Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_BUTTON_PROPERTIES ; external properties
		Invoke MUIGDIPlusStart ; for png resources if used
		Invoke _MUI_ButtonInit, hWin
		mov eax, 0
		ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_ButtonCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
		Invoke MUIFreeMemProperties, hWin, 4
		Invoke MUIGDIPlusFinish
		
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_ButtonPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIBS_HAND
        .IF eax == MUIBS_HAND
		    invoke LoadCursor, NULL, IDC_HAND
		    Invoke SetCursor, eax
        ;.ELSE
        ;    invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        ;Invoke SetCursor, eax

    .ELSEIF eax == WM_LBUTTONUP
		; simulates click on our control, delete if not required.
		Invoke GetDlgCtrlID, hWin
		mov ebx,eax
		Invoke GetParent, hWin
		Invoke PostMessage, eax, WM_COMMAND, ebx, hWin
		
		Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
        .IF eax == TRUE
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER  + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, FALSE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED	
        .ENDIF
        
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIBS_AUTOSTATE
        .IF eax == MUIBS_AUTOSTATE
            Invoke MUIGetIntProperty, hWin, @ButtonSelectedState
            .IF eax == FALSE
	            Invoke MUISetIntProperty, hWin, @ButtonSelectedState, TRUE
            .ELSE
                Invoke MUISetIntProperty, hWin, @ButtonSelectedState, FALSE
            .ENDIF
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIBS_PUSHBUTTON
        .IF eax == MUIBS_PUSHBUTTON
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax
            invoke MapWindowPoints, hWin, hParent, addr rect, 2        
            add rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, TRUE
        .ELSE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        .ENDIF

    .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUIGetIntProperty, hWin, @ButtonEnabledState
        .IF eax == TRUE   
    		Invoke MUISetIntProperty, hWin, @ButtonMouseOver , TRUE
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
        Invoke MUISetIntProperty, hWin, @ButtonMouseOver , FALSE
		Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
        .IF eax == TRUE		
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, FALSE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, FALSE
            ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @ButtonMouseOver , FALSE
		Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
        .IF eax == TRUE		
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, FALSE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, FALSE
            ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF
	
	.ELSEIF eax == WM_ENABLE
	    Invoke MUISetIntProperty, hWin, @ButtonEnabledState, wParam
	    Invoke InvalidateRect, hWin, NULL, TRUE
	    mov eax, 0
	    ret

    .ELSEIF eax == WM_SETFONT
        Invoke MUISetExtProperty, hWin, @ButtonTextFont, lParam
        .IF lParam == TRUE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF    
	
	; custom messages start here
	
	.ELSEIF eax == MUI_GETPROPERTY
		Invoke MUIGetExtProperty, hWin, wParam
		ret
		
	.ELSEIF eax == MUI_SETPROPERTY	
		Invoke MUISetExtProperty, hWin, wParam, lParam
		
		; by default set other similar properties when main one is set
		mov eax, wParam
		.IF eax == @ButtonTextColor
		    Invoke MUISetExtProperty, hWin, @ButtonTextColorAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonTextColorSel, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonTextColorSelAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonNotifyTextColor, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonNoteTextColor, lParam
 		
		.ELSEIF eax == @ButtonBackColor
		    Invoke MUISetExtProperty, hWin, @ButtonBackColorAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonBackColorSel, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonNotifyBackColor, lParam

		.ELSEIF eax == @ButtonBorderColor
		    Invoke MUISetExtProperty, hWin, @ButtonBorderColorAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonBorderColorSel, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonBorderColorSelAlt, lParam

		.ELSEIF eax == @ButtonAccentColor
		    Invoke MUISetExtProperty, hWin, @ButtonAccentColorAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonAccentColorSel, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonAccentColorSelAlt, lParam

		.ELSEIF eax == @ButtonAccentStyle
		    Invoke MUISetExtProperty, hWin, @ButtonAccentStyleAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonAccentStyleSel, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonAccentStyleSelAlt, lParam

		.ELSEIF eax == @ButtonImage
		    Invoke MUISetExtProperty, hWin, @ButtonImageAlt, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonImageSel, lParam
		    Invoke MUISetExtProperty, hWin, @ButtonImageSelAlt, lParam
		.ENDIF
		
		Invoke InvalidateRect, hWin, NULL, TRUE
		
		ret

	.ELSEIF eax == MUIBM_NOTIFYSETTEXT ; wParam = lpszNotifyText, lParam = Redraw TRUE/FALSE
	    Invoke MUISetIntProperty, hWin, @ButtonszNotifyText, wParam
	    .IF lParam == TRUE
	        Invoke InvalidateRect, hWin, NULL, TRUE
	    .ENDIF
	    ret
	    
	.ELSEIF eax == MUIBM_NOTIFY ; wParam = TRUE/FALSE, lParam = NULL
	    Invoke MUISetIntProperty, hWin, @ButtonNotifyState, wParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret
    
	.ELSEIF eax == MUIBM_NOTIFYSETFONT ; wParam = hFont, lParam = TRUE/FALSE to redraw control
	    Invoke MUISetExtProperty, hWin, @ButtonNotifyTextFont, lParam
	    .IF lParam == TRUE
	        Invoke InvalidateRect, hWin, NULL, TRUE
	    .ENDIF
	    ret
	    
	.ELSEIF eax == MUIBM_NOTIFYSETIMAGE ; wParam = dwImageType, lParam = Handle of Image
        .IF wParam == 0
            ret
        .ENDIF
        Invoke MUISetExtProperty, hWin, @ButtonNotifyImageType, wParam
        .IF lParam != 0
            Invoke MUISetExtProperty, hWin, @ButtonNotifyImage, lParam
        .ENDIF
        ret
    
	.ELSEIF eax == MUIBM_NOTIFYLOADIMAGE ; wParam = dwImageType, lParam = ResourceID
        .IF wParam == 0
            ret
        .ENDIF
        Invoke MUISetExtProperty, hWin, @ButtonNotifyImageType, wParam
        mov eax, wParam
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hWin, @ButtonNotifyImage, lParam
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hWin, @ButtonNotifyImage, lParam
        .ELSEIF eax == 3 ; png
            Invoke _MUI_ButtonLoadPng, hWin, @ButtonNotifyImage, lParam
        .ENDIF
        ret
    
	.ELSEIF eax == MUIBM_NOTESETTEXT ; wParam = lpszNoteText, lParam = TRUE/FALSE to redraw control
	    Invoke MUISetIntProperty, hWin, @ButtonszNoteText, wParam
	    .IF lParam == TRUE
	        Invoke InvalidateRect, hWin, NULL, TRUE
	    .ENDIF
	    ret	
    
	.ELSEIF eax == MUIBM_NOTESETFONT ; wParam = hFont, lParam = TRUE/FALSE to redraw control
	    Invoke MUISetExtProperty, hWin, @ButtonNoteTextFont, lParam
	    .IF lParam == TRUE
	        Invoke InvalidateRect, hWin, NULL, TRUE
	    .ENDIF
	    ret	
    
	.ELSEIF eax == MUIBM_GETSTATE ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
	    Invoke MUIGetIntProperty, hWin, @ButtonSelectedState
	    ret
	 
	.ELSEIF eax == MUIBM_SETSTATE ; wParam = TRUE/FALSE, lParam = NULL
	    Invoke MUISetIntProperty, hWin, @ButtonSelectedState, wParam
	    Invoke InvalidateRect, hWin, NULL, TRUE
	    ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_ButtonWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_ButtonInit PROC PRIVATE hControl:DWORD
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
        or dwStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle
    .ENDIF

    ;PrintDec dwStyle
    
    ; Set default initial external property values
    Invoke MUISetIntProperty, hControl, @ButtonEnabledState, TRUE

    Invoke MUISetExtProperty, hControl, @ButtonTextColor, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hControl, @ButtonTextColorAlt, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hControl, @ButtonTextColorSel, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hControl, @ButtonTextColorSelAlt, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hControl, @ButtonTextColorDisabled, MUI_RGBCOLOR(204,204,204)

    Invoke MUISetExtProperty, hControl, @ButtonBackColor, MUI_RGBCOLOR(255,255,255) ;MUI_RGBCOLOR(21,133,181)
    Invoke MUISetExtProperty, hControl, @ButtonBackColorAlt, MUI_RGBCOLOR(221,221,221)
    Invoke MUISetExtProperty, hControl, @ButtonBackColorSel, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hControl, @ButtonBackColorSelAlt, MUI_RGBCOLOR(221,221,221)
    Invoke MUISetExtProperty, hControl, @ButtonBackColorDisabled, MUI_RGBCOLOR(192,192,192)
    
    Invoke MUISetExtProperty, hControl, @ButtonBorderColor, MUI_RGBCOLOR(204,204,204)
    Invoke MUISetExtProperty, hControl, @ButtonBorderColorAlt, MUI_RGBCOLOR(204,204,204)
    Invoke MUISetExtProperty, hControl, @ButtonBorderColorSel, MUI_RGBCOLOR(27,161,226)
    Invoke MUISetExtProperty, hControl, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(27,161,226)
    Invoke MUISetExtProperty, hControl, @ButtonBorderColorDisabled, MUI_RGBCOLOR(204,204,204)
    
    Invoke MUISetExtProperty, hControl, @ButtonBorderStyle, MUIBBS_ALL
    
    Invoke MUISetExtProperty, hControl, @ButtonNotifyTextColor, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hControl, @ButtonNotifyBackColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hControl, @ButtonNoteTextColor, MUI_RGBCOLOR(96,96,96)
    Invoke MUISetExtProperty, hControl, @ButtonNoteTextColorDisabled, MUI_RGBCOLOR(204,204,204)

    .IF hMUIButtonFont == 0
    	mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
    	Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
    	Invoke CreateFontIndirect, Addr ncm.lfMessageFont
    	mov hFont, eax
	    Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
	    mov lfnt.lfHeight, -16d
	    ;mov lfnt.lfWeight, FW_BOLD
	    Invoke CreateFontIndirect, Addr lfnt
        mov hMUIButtonFont, eax
        
        mov lfnt.lfHeight, -12d
        mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUIButtonNotifyFont, eax
        
	    mov lfnt.lfHeight, -12d
	    mov lfnt.lfWeight, FW_NORMAL
	    Invoke CreateFontIndirect, Addr lfnt
        mov hMUIButtonNoteFont, eax
        
        Invoke DeleteObject, hFont
    .ENDIF

    Invoke MUISetExtProperty, hControl, @ButtonTextFont, hMUIButtonFont
    Invoke MUISetExtProperty, hControl, @ButtonNotifyTextFont, hMUIButtonNotifyFont
    Invoke MUISetExtProperty, hControl, @ButtonNoteTextFont, hMUIButtonNoteFont
    
    ret

_MUI_ButtonInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonCleanup - cleanup a few things before control is destroyed
;-------------------------------------------------------------------------------------
_MUI_ButtonCleanup PROC PRIVATE hControl:DWORD
    
    ; cleanup any stream handles if png where loaded as resources
    Invoke MUIGetIntProperty, hControl, @ButtonImageStream
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF
    Invoke MUIGetIntProperty, hControl, @ButtonImageAltStream
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF
    Invoke MUIGetIntProperty, hControl, @ButtonImageSelStream
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF
    Invoke MUIGetIntProperty, hControl, @ButtonImageSelAltStream
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF
    Invoke MUIGetIntProperty, hControl, @ButtonImageDisabledStream
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF
    Invoke MUIGetIntProperty, hControl, @ButtonNotifyImageStream
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF

    ret

_MUI_ButtonCleanup ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonPaint
;-------------------------------------------------------------------------------------
_MUI_ButtonPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL EnabledState:DWORD
    LOCAL MouseOver:DWORD
    LOCAL SelectedState:DWORD

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
    Invoke MUIGetIntProperty, hWin, @ButtonEnabledState
    mov EnabledState, eax
	Invoke MUIGetIntProperty, hWin, @ButtonMouseOver
    mov MouseOver, eax
	Invoke MUIGetIntProperty, hWin, @ButtonSelectedState
    mov SelectedState, eax    
	
	;----------------------------------------------------------
	; Background
	;----------------------------------------------------------
	Invoke _MUI_ButtonPaintBackground, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

	;----------------------------------------------------------
	; Accent
	;----------------------------------------------------------
    Invoke _MUI_ButtonPaintAccent, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

	;----------------------------------------------------------
	; Images
	;----------------------------------------------------------
    Invoke _MUI_ButtonPaintImages, hWin, hdc, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

	;----------------------------------------------------------
	; Text
	;----------------------------------------------------------
	Invoke _MUI_ButtonPaintText, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

	;----------------------------------------------------------
	; Border
	;----------------------------------------------------------
	Invoke _MUI_ButtonPaintBorder, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    Invoke SelectObject, hdcMem, hOldBitmap
    Invoke DeleteDC, hdcMem
    Invoke DeleteObject, hbmMem
    .IF hOldBitmap != 0
        Invoke DeleteObject, hOldBitmap
    .ENDIF		
     
    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_ButtonPaint ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonPaintBackground
;-------------------------------------------------------------------------------------
_MUI_ButtonPaintBackground PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColor        ; Normal back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorAlt     ; Mouse over back color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSel     ; Selected back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonBackColorDisabled        ; Disabled back color
    .ENDIF
    mov BackColor, eax
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    Invoke FillRect, hdc, lpRect, hBrush
    
    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF      
    
    ret

_MUI_ButtonPaintBackground ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonPaintAccent
;-------------------------------------------------------------------------------------
_MUI_ButtonPaintAccent PROC PRIVATE USES EBX hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL AccentColor:DWORD
    LOCAL AccentStyle:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hPen:DWORD
    LOCAL hOldPen:DWORD
    LOCAL AccentRect:RECT
    LOCAL rect:RECT
    LOCAL pt:POINT    
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentColor        ; Normal accent color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentColorAlt     ; Mouse over accent color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentColorSel     ; Selected accent color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentColorSelAlt  ; Selected mouse over accent color 
            .ENDIF
        .ENDIF
    .ELSE
        ret
    .ENDIF
    mov AccentColor, eax

    .IF AccentColor != 0

        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentStyle        ; Normal accent style
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleAlt     ; Mouse over accent style
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleSel     ; Selected accent style
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleSelAlt  ; Selected mouse over accent style
            .ENDIF
        .ENDIF
        mov AccentStyle, eax

        .IF AccentStyle != MUIBAS_NONE
        
            mov eax, AccentStyle
            AND eax, MUIBAS_LEFT
            .IF eax == MUIBAS_LEFT
                mov AccentRect.left, 0
                mov eax, ACCENTWIDTH
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, rect.bottom
                mov AccentRect.bottom, eax
                
                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hOldBrush, eax
                Invoke SetDCBrushColor, hdc, AccentColor
                Invoke FillRect, hdc, Addr AccentRect, hBrush
                
                .IF hOldBrush != 0
                    Invoke SelectObject, hdc, hOldBrush
                    Invoke DeleteObject, hOldBrush
                .ENDIF     
                .IF hBrush != 0
                    Invoke DeleteObject, hBrush
                .ENDIF
            .ENDIF 

            mov eax, AccentStyle
            AND eax, MUIBAS_TOP
            .IF eax == MUIBAS_TOP
                mov AccentRect.left, 0
                mov eax, rect.right
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, ACCENTWIDTH
                mov AccentRect.bottom, eax

                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hOldBrush, eax
                Invoke SetDCBrushColor, hdc, AccentColor
                Invoke FillRect, hdc, Addr AccentRect, hBrush
                
                .IF hOldBrush != 0
                    Invoke SelectObject, hdc, hOldBrush
                    Invoke DeleteObject, hOldBrush
                .ENDIF     
                .IF hBrush != 0
                    Invoke DeleteObject, hBrush
                .ENDIF
            .ENDIF
            
            mov eax, AccentStyle
            AND eax, MUIBAS_RIGHT
            .IF eax == MUIBAS_RIGHT
                mov eax, rect.right
                mov ebx, ACCENTWIDTH
                sub eax, ebx
                mov AccentRect.left, eax
                mov eax, rect.right
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, rect.bottom
                mov AccentRect.bottom, eax

                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hOldBrush, eax
                Invoke SetDCBrushColor, hdc, AccentColor
                Invoke FillRect, hdc, Addr AccentRect, hBrush
                
                .IF hOldBrush != 0
                    Invoke SelectObject, hdc, hOldBrush
                    Invoke DeleteObject, hOldBrush
                .ENDIF     
                .IF hBrush != 0
                    Invoke DeleteObject, hBrush
                .ENDIF
            .ENDIF
            
            mov eax, AccentStyle
            AND eax, MUIBAS_BOTTOM
            .IF eax == MUIBAS_BOTTOM
                mov AccentRect.left, 0
                mov eax, rect.right
                mov AccentRect.right, eax
                mov eax, rect.bottom
                mov ebx, ACCENTWIDTH
                sub eax, ebx
                mov AccentRect.top, eax
                mov eax, rect.bottom
                mov AccentRect.bottom, eax

                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hOldBrush, eax
                Invoke SetDCBrushColor, hdc, AccentColor
                Invoke FillRect, hdc, Addr AccentRect, hBrush
                
                .IF hOldBrush != 0
                    Invoke SelectObject, hdc, hOldBrush
                    Invoke DeleteObject, hOldBrush
                .ENDIF     
                .IF hBrush != 0
                    Invoke DeleteObject, hBrush
                .ENDIF
            .ENDIF
            
            mov eax, AccentStyle
            AND eax, MUIBAS_ALL
            .IF eax == MUIBAS_ALL
                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hOldBrush, eax
                Invoke SetDCBrushColor, hdc, AccentColor 
            
                mov AccentRect.left, 0
                mov eax, ACCENTWIDTH
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, rect.bottom
                mov AccentRect.bottom, eax
                Invoke FillRect, hdc, Addr AccentRect, hBrush

                mov AccentRect.left, 0
                mov eax, rect.right
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, ACCENTWIDTH
                mov AccentRect.bottom, eax
                Invoke FillRect, hdc, Addr AccentRect, hBrush
                
                mov eax, rect.right
                mov ebx, ACCENTWIDTH
                sub eax, ebx
                mov AccentRect.left, eax
                mov eax, rect.right
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, rect.bottom
                mov AccentRect.bottom, eax
                Invoke FillRect, hdc, Addr AccentRect, hBrush

                mov AccentRect.left, 0
                mov eax, rect.right
                mov AccentRect.right, eax
                mov eax, rect.bottom
                mov ebx, ACCENTWIDTH
                sub eax, ebx
                mov AccentRect.top, eax
                mov eax, rect.bottom
                mov AccentRect.bottom, eax
                Invoke FillRect, hdc, Addr AccentRect, hBrush

            .ENDIF
        .ENDIF
    .ENDIF

    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF

    ret

_MUI_ButtonPaintAccent ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonPaintText
;-------------------------------------------------------------------------------------
_MUI_ButtonPaintText PROC PRIVATE USES EBX hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwTextStyle:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hPen:DWORD
    LOCAL hOldPen:DWORD
    LOCAL hImage:DWORD
    LOCAL ImageType:DWORD
    LOCAL NotifyImageType:DWORD
    LOCAL hNotifyImage:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    LOCAL sz:_SIZE
    LOCAL bm:BITMAP
    LOCAL iinfo:ICONINFO
    LOCAL lpszNotifyText:DWORD
    LOCAL LenNotifyText:DWORD
    LOCAL szText[256]:BYTE

    Invoke CopyRect, Addr rect, lpRect
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColor        ; Normal back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorAlt     ; Mouse over back color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSel     ; Selected back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonBackColorDisabled        ; Disabled back color
    .ENDIF
    mov BackColor, eax    
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    Invoke MUIGetExtProperty, hWin, @ButtonTextFont        
    mov hFont, eax

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonTextColor        ; Normal text color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonTextColorAlt     ; Mouse over text color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonTextColorSel     ; Selected text color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonTextColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonTextColorDisabled        ; Disabled text color
    .ENDIF
    mov TextColor, eax
    
    Invoke MUIGetExtProperty, hWin, @ButtonImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonImage        ; Normal image
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonImageAlt     ; Mouse over image
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonImageSel     ; Selected image
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonImageSelAlt  ; Selected mouse over image 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonImageDisabled        ; Disabled image
    .ENDIF
    mov hImage, eax    

    mov rect.left, 4
    mov rect.top, 4
    sub rect.bottom, 4
    sub rect.right, 4
    
    .IF hImage != 0
        
        Invoke _MUI_ButtonGetImageSize, hWin, ImageType, hImage, Addr ImageWidth, Addr ImageHeight

        mov eax, ImageWidth
        add rect.left, eax
        add rect.left, 4d
        
        mov eax, dwStyle
        and eax, MUIBS_BOTTOM 
        .IF eax == MUIBS_BOTTOM
            mov eax, rect.bottom
            sub eax, 4d
            mov ebx, ImageHeight
            sub eax, ebx
            mov rect.top, eax
        .ELSE
            mov eax, rect.bottom
            shr eax, 1
            mov ebx, ImageHeight
            shr ebx, 1
            sub eax, ebx
            mov rect.top, eax
        .ENDIF        
        
    .ENDIF
    
    Invoke MUIGetExtProperty, hWin, @ButtonNotifyImageType        
    mov NotifyImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png

    .IF bEnabledState == TRUE
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyImage        ; Normal Notify image
    .ENDIF
    mov hNotifyImage, eax      
    
    .IF hNotifyImage != 0
        
        Invoke _MUI_ButtonGetImageSize, hWin, ImageType, hImage, Addr ImageWidth, Addr ImageHeight

        mov eax, ImageWidth
        sub rect.right, eax
        sub rect.right, 4d
        
    .ELSE
        ; get text extent of notify text?
    .ENDIF

    
	Invoke SelectObject, hdc, hFont
    mov hOldFont, eax
    Invoke GetWindowText, hWin, Addr szText, sizeof szText
    
    Invoke SetBkMode, hdc, OPAQUE
    Invoke SetBkColor, hdc, BackColor    
    Invoke SetTextColor, hdc, TextColor
    
    mov dwTextStyle, DT_SINGLELINE
    mov eax, dwStyle
    and eax, MUIBS_CENTER
    .IF eax == MUIBS_CENTER
        or dwTextStyle, DT_CENTER
    .ELSE
        or dwTextStyle, DT_LEFT
    .ENDIF
    
    mov eax, dwStyle
    and eax, MUIBS_BOTTOM 
    .IF eax == MUIBS_BOTTOM
        or dwTextStyle, DT_BOTTOM
    .ELSE ; center
        or dwTextStyle, DT_VCENTER
    .ENDIF
    
    Invoke DrawText, hdc, Addr szText, -1, Addr rect, dwTextStyle
    
    .IF hOldFont != 0
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
    
    ; Draw notify text
    Invoke MUIGetIntProperty, hWin, @ButtonNotifyState
    .IF eax == FALSE
        ret
    .ENDIF    
    
    Invoke MUIGetIntProperty, hWin, @ButtonszNotifyText
    .IF eax != 0
        mov lpszNotifyText, eax
        Invoke lstrlen, lpszNotifyText
        mov LenNotifyText, eax
        
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyTextFont
        mov hFont, eax
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyTextColor
        mov TextColor, eax
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyBackColor
        mov BackColor, eax
        
        Invoke GetTextExtentPoint32, hdc, lpszNotifyText, LenNotifyText, Addr sz
        Invoke CopyRect, Addr rect, lpRect
        
        add sz.x, 8d
        add sz.y, 4d
        
        mov eax, rect.right
        sub eax, 4
        sub eax, sz.x
        mov rect.left, eax

        mov eax, rect.right
        mov ebx, rect.left
        sub eax, ebx

;        .IF eax < 28d
;            mov eax, rect.right
;            sub eax, 28d
;            mov rect.left, eax
;        .ENDIF

        mov eax, dwStyle
        and eax, MUIBS_BOTTOM 
        .IF eax == MUIBS_BOTTOM
            mov eax, rect.bottom
            sub eax, 4d
            mov ebx, sz.y
            sub eax, ebx
            mov rect.top, eax
            sub rect.bottom, 4d
        .ELSE
            mov eax, rect.bottom
            shr eax, 1
            mov ebx, sz.y
            shr ebx, 1
            sub eax, ebx
            ;sub eax, 4d            
            mov rect.top, eax
            
            mov eax, rect.bottom
            shr eax, 1
            mov ebx, sz.y
            shr ebx, 1
            add eax, ebx
            ;add eax, 4d            
            mov rect.bottom, eax
            
        .ENDIF
        sub rect.right, 4d


	    Invoke SelectObject, hdc, hFont
        mov hOldFont, eax
        
        Invoke SetBkMode, hdc, OPAQUE
        Invoke SetBkColor, hdc, BackColor    
        Invoke SetTextColor, hdc, TextColor        

        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdc, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdc, BackColor
        
        Invoke GetStockObject, DC_PEN
        mov hPen, eax
        Invoke SelectObject, hdc, hPen
        mov hOldPen, eax         
        Invoke SetDCPenColor, hdc, BackColor
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyRound
        Invoke RoundRect, hdc, rect.left, rect.top, rect.right, rect.bottom, eax, eax
        
        Invoke DrawText, hdc, lpszNotifyText, LenNotifyText, Addr rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
        
        .IF hOldFont != 0
            Invoke SelectObject, hdc, hOldFont
            Invoke DeleteObject, hOldFont
        .ENDIF
        .IF hOldBrush != 0
            Invoke SelectObject, hdc, hOldBrush
            Invoke DeleteObject, hOldBrush
        .ENDIF     
        .IF hBrush != 0
            Invoke DeleteObject, hBrush
        .ENDIF
        .IF hOldPen != 0
            Invoke SelectObject, hdc, hOldPen
            Invoke DeleteObject, hOldPen
        .ENDIF     
        .IF hPen != 0
            Invoke DeleteObject, hPen
        .ENDIF            
        
    .ENDIF
    
    ret

_MUI_ButtonPaintText ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonPaintImages
;-------------------------------------------------------------------------------------
_MUI_ButtonPaintImages PROC PRIVATE USES EBX hWin:DWORD, hdcMain:DWORD, hdcDest:DWORD, lpRect:DWORD, bEnabledState, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL dwStyle:DWORD
    LOCAL ImageType:DWORD
    LOCAL hImage:DWORD
    LOCAL NotifyImageType:DWORD
    LOCAL hNotifyImage:DWORD    
    LOCAL hdcMem:HDC
    LOCAL hbmOld:DWORD
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL pBitmap:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    ;LOCAL bm:BITMAP
    ;LOCAL iinfo:ICONINFO
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    Invoke MUIGetExtProperty, hWin, @ButtonImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png
    
    Invoke MUIGetExtProperty, hWin, @ButtonNotifyImageType        
    mov NotifyImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png
    
    .IF ImageType == 0 && NotifyImageType == 0
        ret
    .ENDIF    
    
    .IF ImageType != 0
        .IF bEnabledState == TRUE
            .IF bSelectedState == FALSE
                .IF bMouseOver == FALSE
                    Invoke MUIGetExtProperty, hWin, @ButtonImage        ; Normal image
                .ELSE
                    Invoke MUIGetExtProperty, hWin, @ButtonImageAlt     ; Mouse over image
                .ENDIF
            .ELSE
                .IF bMouseOver == FALSE
                    Invoke MUIGetExtProperty, hWin, @ButtonImageSel     ; Selected image
                .ELSE
                    Invoke MUIGetExtProperty, hWin, @ButtonImageSelAlt  ; Selected mouse over image 
                .ENDIF
            .ENDIF
        .ELSE
            Invoke MUIGetExtProperty, hWin, @ButtonImageDisabled        ; Disabled image
        .ENDIF
        mov hImage, eax
    .ELSE
        mov hImage, 0
    .ENDIF
    
    .IF hImage != 0
    
        Invoke CopyRect, Addr rect, lpRect
        
        Invoke _MUI_ButtonGetImageSize, hWin, ImageType, hImage, Addr ImageWidth, Addr ImageHeight
        
        mov pt.x, 4d
        mov pt.y, 4d
        mov eax, dwStyle
        and eax, MUIBS_BOTTOM 
        .IF eax == MUIBS_BOTTOM
            mov eax, rect.bottom
            sub eax, 4d
            mov ebx, ImageHeight
            sub eax, ebx
            mov pt.y, eax
        .ELSE
            mov eax, rect.bottom
            shr eax, 1
            mov ebx, ImageHeight
            shr ebx, 1
            sub eax, ebx
            
            mov pt.y, eax
        .ENDIF
        
        mov eax, ImageType
        .IF eax == 1 ; bitmap
            
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
            
        .ELSEIF eax == 2 ; icon
            Invoke DrawIconEx, hdcDest, pt.x, pt.y, hImage, 0, 0, 0, 0, DI_NORMAL
        
        .ELSEIF eax == 3 ; png
            Invoke GdipCreateFromHDC, hdcDest, Addr pGraphics
            
            Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
            Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer            
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
        
        .ENDIF
    
    .ENDIF 

    
    Invoke MUIGetIntProperty, hWin, @ButtonNotifyState
    .IF eax == FALSE
        ret
    .ENDIF


    ; Notify Image
    .IF NotifyImageType != 0
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyImage        ; Normal Notify image
        mov hNotifyImage, eax
    .ELSE
        ret
    .ENDIF
    
    .IF hNotifyImage != 0
        
        Invoke CopyRect, Addr rect, lpRect
        
        Invoke _MUI_ButtonGetImageSize, hWin, NotifyImageType, hNotifyImage, Addr ImageWidth, Addr ImageHeight
        
        mov eax, rect.right
        sub eax, 4
        mov ebx, ImageWidth
        sub eax, ebx
        mov pt.x, eax

        mov eax, dwStyle
        and eax, MUIBS_BOTTOM 
        .IF eax == MUIBS_BOTTOM
            mov eax, rect.bottom
            sub eax, 4d
            mov ebx, ImageHeight
            sub eax, ebx
            mov pt.y, eax
        .ELSE
            mov eax, rect.bottom
            shr eax, 1
            mov ebx, ImageHeight
            shr ebx, 1
            sub eax, ebx
            mov pt.y, eax
        .ENDIF


        mov eax, NotifyImageType
        .IF eax == 1 ; bitmap
            
            Invoke CreateCompatibleDC, hdcMain
            mov hdcMem, eax
            Invoke SelectObject, hdcMem, hNotifyImage
            mov hbmOld, eax
    
            Invoke BitBlt, hdcDest, pt.x, pt.y, ImageWidth, ImageHeight, hdcMem, 0, 0, SRCCOPY
    
            Invoke SelectObject, hdcMem, hbmOld
            Invoke DeleteDC, hdcMem
            .IF hbmOld != 0
                Invoke DeleteObject, hbmOld
            .ENDIF
            
        .ELSEIF eax == 2 ; icon
            Invoke DrawIconEx, hdcDest, pt.x, pt.y, hNotifyImage, 0, 0, 0, 0, DI_NORMAL
        
        .ELSEIF eax == 3 ; png
            Invoke GdipCreateFromHDC, hdcMain, Addr pGraphics
            
            Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
            Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer            
            Invoke GdipDrawImageI, pGraphicsBuffer, hNotifyImage, 0, 0
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
        
        .ENDIF
    
    .ENDIF     
    
    
    
    ret

_MUI_ButtonPaintImages ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonPaintBorder
;-------------------------------------------------------------------------------------
_MUI_ButtonPaintBorder PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BorderColor:DWORD
    LOCAL BorderStyle:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hPen:DWORD
    LOCAL hOldPen:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColor        ; Normal text color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColorAlt     ; Mouse over text color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColorSel     ; Selected text color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonBorderColorDisabled        ; Disabled text color
    .ENDIF
    mov BorderColor, eax

    .IF BorderColor != 0
        Invoke MUIGetExtProperty, hWin, @ButtonBorderStyle
        mov BorderStyle, eax

        .IF BorderStyle != MUIBBS_NONE
            mov eax, BorderStyle
            and eax, MUIBBS_ALL
            .IF eax == MUIBBS_ALL
                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hOldBrush, eax
                Invoke SetDCBrushColor, hdc, BorderColor
                Invoke FrameRect, hdc, lpRect, hBrush
            .ELSE
                Invoke CreatePen, PS_SOLID, 1, BorderColor
                mov hPen, eax
                Invoke SelectObject, hdc, hPen
                mov hOldPen, eax 
                ;Invoke InflateRect, Addr rect, -1, 0
                
                Invoke CopyRect, Addr rect, lpRect
                
                mov eax, BorderStyle
                and eax, MUIBBS_TOP
                .IF eax == MUIBBS_TOP
                    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.top
                .ENDIF
                mov eax, BorderStyle
                and eax, MUIBBS_RIGHT
                .IF eax == MUIBBS_RIGHT
                    dec rect.right                
                    Invoke MoveToEx, hdc, rect.right, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.right
                .ENDIF
                mov eax, BorderStyle
                and eax, MUIBBS_BOTTOM
                .IF eax == MUIBBS_BOTTOM
                    dec rect.bottom
                    Invoke MoveToEx, hdc, rect.left, rect.bottom, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.bottom
                .ENDIF
                mov eax, BorderStyle
                and eax, MUIBBS_LEFT
                .IF eax == MUIBBS_LEFT
                    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.left, rect.bottom
                .ENDIF
                .IF hOldPen != 0
                    Invoke SelectObject, hdc, hOldPen
                    Invoke DeleteObject, hOldPen
                .ENDIF
                .IF hPen != 0
                    Invoke DeleteObject, hPen
                .ENDIF

            .ENDIF
        .ENDIF
    .ENDIF

    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF      
    
    ret

_MUI_ButtonPaintBorder ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonGetImageSize
;-------------------------------------------------------------------------------------
_MUI_ButtonGetImageSize PROC PRIVATE USES EBX hWin:DWORD, dwImageType:DWORD, hImage:DWORD, lpdwImageWidth:DWORD, lpdwImageHeight:DWORD
    LOCAL bm:BITMAP
    LOCAL iinfo:ICONINFO
    LOCAL nImageWidth:DWORD
    LOCAL nImageHeight:DWORD

    mov eax, dwImageType
    .IF eax == MUIBIT_NONE
        mov eax, 0
        mov ebx, lpdwImageWidth
        mov [ebx], eax
        mov ebx, lpdwImageHeight
        mov [ebx], eax    
        mov eax, FALSE
        ret
        
    .ELSEIF eax == MUIBIT_BMP ; bitmap/icon
        Invoke GetObject, hImage, SIZEOF bm, Addr bm
        mov eax, bm.bmWidth
        mov ebx, lpdwImageWidth
        mov [ebx], eax
        mov eax, bm.bmHeight
        mov ebx, lpdwImageHeight
        mov [ebx], eax
    
    .ELSEIF eax == MUIBIT_ICO ; icon    
        Invoke GetIconInfo, hImage, Addr iinfo ; get icon information
        mov eax, iinfo.hbmColor ; bitmap info of icon has width/height
        .IF eax != NULL
            Invoke GetObject, iinfo.hbmColor, SIZEOF bm, Addr bm
            mov eax, bm.bmWidth
            mov ebx, lpdwImageWidth
            mov [ebx], eax
            mov eax, bm.bmHeight
            mov ebx, lpdwImageHeight
            mov [ebx], eax
        .ELSE ; Icon has no color plane, image width/height data stored in mask
            mov eax, iinfo.hbmMask
            .IF eax != NULL
                Invoke GetObject, iinfo.hbmMask, SIZEOF bm, Addr bm
                mov eax, bm.bmWidth
                mov ebx, lpdwImageWidth
                mov [ebx], eax
                mov eax, bm.bmHeight
                shr eax, 1 ;bmp.bmHeight / 2;
                mov ebx, lpdwImageHeight
                mov [ebx], eax                
            .ENDIF
        .ENDIF
    
    .ELSEIF eax == MUIBIT_PNG ; png
        Invoke GdipGetImageWidth, hImage, Addr nImageWidth
        Invoke GdipGetImageHeight, hImage, Addr nImageHeight
        mov eax, nImageWidth
        mov ebx, lpdwImageWidth
        mov [ebx], eax
        mov eax, nImageHeight
        mov ebx, lpdwImageHeight
        mov [ebx], eax
    .ENDIF
    
    mov eax, TRUE
    ret

_MUI_ButtonGetImageSize ENDP



;--------------------------------------------------------------------------------------------------------------------------------------
; Other PUBLIC function wrappers - most equate to same as custom messages
;--------------------------------------------------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------
; MUIButtonGetState
;-------------------------------------------------------------------------------------
MUIButtonGetState PROC PUBLIC hControl:DWORD
    Invoke SendMessage, hControl, MUIBM_GETSTATE, 0, 0
    ret
MUIButtonGetState ENDP

;-------------------------------------------------------------------------------------
; MUIButtonSetState
;-------------------------------------------------------------------------------------
MUIButtonSetState PROC PUBLIC hControl:DWORD, bState:DWORD
    Invoke SendMessage, hControl, MUIBM_SETSTATE, bState, 0
    ret
MUIButtonSetState ENDP

;-------------------------------------------------------------------------------------
; MUIButtonLoadImages - Loads images from resource ids and stores the handles in the
; appropriate property.
;-------------------------------------------------------------------------------------
MUIButtonLoadImages PROC PUBLIC hControl:DWORD, dwImageType:DWORD, dwResIDImage:DWORD, dwResIDImageAlt:DWORD, dwResIDImageSel:DWORD, dwResIDImageSelAlt:DWORD, dwResIDImageDisabled:DWORD

    .IF dwImageType == 0
        ret
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @ButtonImageType, dwImageType

    .IF dwResIDImage != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImage, dwResIDImage
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImage, dwResIDImage
        .ELSEIF eax == 3 ; png
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImage, dwResIDImage
        .ENDIF
    .ENDIF

    .IF dwResIDImageAlt != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageAlt, dwResIDImageAlt
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageAlt, dwResIDImageAlt
        .ELSEIF eax == 3 ; png
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageAlt, dwResIDImageAlt
        .ENDIF
    .ENDIF

    .IF dwResIDImageSel != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageSel, dwResIDImageSel
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageSel, dwResIDImageSel
        .ELSEIF eax == 3 ; png
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageSel, dwResIDImageSel
        .ENDIF
    .ENDIF

    .IF dwResIDImageSelAlt != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageSelAlt, dwResIDImageSelAlt
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageSelAlt, dwResIDImageSelAlt
        .ELSEIF eax == 3 ; png
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageSelAlt, dwResIDImageSelAlt
        .ENDIF
    .ENDIF

    .IF dwResIDImageDisabled != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 3 ; png
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageDisabled, dwResIDImageDisabled
        .ENDIF
    .ENDIF
    
    Invoke InvalidateRect, hControl, NULL, TRUE
    
    ret
MUIButtonLoadImages ENDP


;-------------------------------------------------------------------------------------
; MUIButtonSetImages - Sets the property handles for image types
;-------------------------------------------------------------------------------------
MUIButtonSetImages PROC PUBLIC hControl:DWORD, dwImageType:DWORD, hImage:DWORD, hImageAlt:DWORD, hImageSel:DWORD, hImageSelAlt:DWORD, hImageDisabled:DWORD

    .IF dwImageType == 0
        ret
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @ButtonImageType, dwImageType

    .IF hImage != 0
        Invoke MUISetExtProperty, hControl, @ButtonImage, hImage
    .ENDIF

    .IF hImageAlt != 0
        Invoke MUISetExtProperty, hControl, @ButtonImageAlt, hImageAlt
    .ENDIF

    .IF hImageSel != 0
        Invoke MUISetExtProperty, hControl, @ButtonImageSel, hImageSel
    .ENDIF

    .IF hImageSelAlt != 0
        Invoke MUISetExtProperty, hControl, @ButtonImageSelAlt, hImageSelAlt
    .ENDIF

    .IF hImageDisabled != 0
        Invoke MUISetExtProperty, hControl, @ButtonImageDisabled, hImageDisabled
    .ENDIF
    
    Invoke InvalidateRect, hControl, NULL, TRUE
    
    ret

MUIButtonSetImages ENDP

;-------------------------------------------------------------------------------------
; MUIButtonNotifySetText
;-------------------------------------------------------------------------------------
MUIButtonNotifySetText PROC PUBLIC hControl:DWORD, lpszNotifyText:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYSETTEXT, lpszNotifyText, bRedraw
    ret
MUIButtonNotifySetText ENDP

;-------------------------------------------------------------------------------------
; MUIButtonNotifyLoadImage
;-------------------------------------------------------------------------------------
MUIButtonNotifyLoadImage PROC PUBLIC hControl:DWORD, dwImageType:DWORD, dwResIDNotifyImage:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYLOADIMAGE, dwImageType, dwResIDNotifyImage
    ret
MUIButtonNotifyLoadImage ENDP

;-------------------------------------------------------------------------------------
; MUIButtonNotifySetImage
;-------------------------------------------------------------------------------------
MUIButtonNotifySetImage PROC PUBLIC hControl:DWORD, dwImageType:DWORD, hNotifyImage:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYSETIMAGE, dwImageType, hNotifyImage
    ret
MUIButtonNotifySetImage ENDP

;-------------------------------------------------------------------------------------
; MUIButtonNotifySetFont
;-------------------------------------------------------------------------------------
MUIButtonNotifySetFont PROC PUBLIC hControl:DWORD, hFont:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYSETFONT, hFont, bRedraw
    ret
MUIButtonNotifySetFont ENDP

;-------------------------------------------------------------------------------------
; MUIButtonNotify
;-------------------------------------------------------------------------------------
MUIButtonNotify PROC PUBLIC hControl:DWORD, bNotify:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFY, bNotify, 0 
    ret
MUIButtonNotify ENDP

;-------------------------------------------------------------------------------------
; MUIButtonNoteSetText
;-------------------------------------------------------------------------------------
MUIButtonNoteSetText PROC PUBLIC hControl:DWORD, lpszNoteText:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTESETTEXT, lpszNoteText, bRedraw
    ret
MUIButtonNoteSetText ENDP

;-------------------------------------------------------------------------------------
; MUIButtonNoteSetFont
;-------------------------------------------------------------------------------------
MUIButtonNoteSetFont PROC PUBLIC hControl:DWORD, hFont:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTESETFONT, hFont, bRedraw
    ret
MUIButtonNoteSetFont ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonLoadBitmap - returns in eax handle to bitmap loaded from resource
;-------------------------------------------------------------------------------------
_MUI_ButtonLoadBitmap PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResBitmap:DWORD
    LOCAL hinstance:DWORD

    .IF idResBitmap == NULL
        mov eax, FALSE
        ret
    .ENDIF
    Invoke GetModuleHandle, NULL
    mov hinstance, eax
    
	Invoke LoadBitmap, hinstance, idResBitmap
    Invoke MUISetExtProperty, hWin, dwProperty, eax
	mov eax, TRUE
    
    ret

_MUI_ButtonLoadBitmap ENDP


;-------------------------------------------------------------------------------------
; _MUI_ButtonLoadIcon - returns in eax handle to icon loaded from resource
;-------------------------------------------------------------------------------------
_MUI_ButtonLoadIcon PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResIcon:DWORD
    LOCAL hinstance:DWORD

    .IF idResIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

	Invoke LoadImage, hinstance, idResIcon, IMAGE_ICON, 0, 0, 0
    Invoke MUISetExtProperty, hWin, dwProperty, eax

	mov eax, TRUE

    ret

_MUI_ButtonLoadIcon ENDP


;-------------------------------------------------------------------------------------
; Load JPG/PNG from resource using GDI+
;   Actually, this function can load any image format supported by GDI+
;
; by: Chris Vega
;
; Addendum KSR 2014 : Needs OLE32 include and lib for CreateStreamOnHGlobal and 
; GetHGlobalFromStream calls. Underlying stream needs to be left open for the life of
; the bitmap or corruption of png occurs. store png as RCDATA in resource file.
;-------------------------------------------------------------------------------------
_MUI_ButtonLoadPng PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResPng:DWORD
	local rcRes:HRSRC
	local hResData:HRSRC
	local pResData:HANDLE
	local sizeOfRes:DWORD
	local hbuffer:HANDLE
	local pbuffer:DWORD
	local pIStream:DWORD
	local hIStream:DWORD
    LOCAL hinstance:DWORD
    LOCAL pBitmapFromStream:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax

	; ------------------------------------------------------------------
	; STEP 1: Find the resource
	; ------------------------------------------------------------------
	invoke	FindResource, hinstance, idResPng, RT_RCDATA
	or 		eax, eax
	jnz		@f
	jmp		_MUI_ButtonLoadPng@Close
@@:	mov		rcRes, eax
	
	; ------------------------------------------------------------------
	; STEP 2: Load the resource
	; ------------------------------------------------------------------
	invoke	LoadResource, hinstance, rcRes
	or		eax, eax
	jnz		@f
	ret		; Resource was not loaded
@@:	mov		hResData, eax

	; ------------------------------------------------------------------
	; STEP 3: Create a stream to contain our loaded resource
	; ------------------------------------------------------------------
	invoke	SizeofResource, hinstance, rcRes
	or		eax, eax
	jnz		@f
	jmp		_MUI_ButtonLoadPng@Close
@@:	mov		sizeOfRes, eax
	
	invoke	LockResource, hResData
	or		eax, eax
	jnz		@f
	jmp		_MUI_ButtonLoadPng@Close
@@:	mov		pResData, eax

	invoke	GlobalAlloc, GMEM_MOVEABLE, sizeOfRes
	or		eax, eax
	jnz		@f
	jmp		_MUI_ButtonLoadPng@Close
@@:	mov		hbuffer, eax

	invoke	GlobalLock, hbuffer
	mov		pbuffer, eax
	
	invoke	RtlMoveMemory, pbuffer, hResData, sizeOfRes
	invoke	CreateStreamOnHGlobal, pbuffer, FALSE, addr pIStream
	or		eax, eax
	jz		@f
	jmp		_MUI_ButtonLoadPng@Close
@@:	

	; ------------------------------------------------------------------
	; STEP 4: Create an image object from stream
	; ------------------------------------------------------------------
	invoke	GdipCreateBitmapFromStream, pIStream, Addr pBitmapFromStream
	
	; ------------------------------------------------------------------
	; STEP 5: Free all used locks and resources
	; ------------------------------------------------------------------
	invoke	GetHGlobalFromStream, pIStream, addr hIStream ; had to uncomment as corrupts pngs if left in, googling shows underlying stream needs to be left open for the life of the bitmap
	;invoke	GlobalFree, hIStream
	invoke	GlobalUnlock, hbuffer
	invoke	GlobalFree, hbuffer

    Invoke MUISetExtProperty, hWin, dwProperty, pBitmapFromStream
    
    mov eax, dwProperty
    .IF eax == @ButtonImage
        Invoke MUISetIntProperty, hWin, @ButtonImageStream, hIStream
    .ELSEIF eax == @ButtonImageAlt
        Invoke MUISetIntProperty, hWin, @ButtonImageAltStream, hIStream
    .ELSEIF eax == @ButtonImageSel
        Invoke MUISetIntProperty, hWin, @ButtonImageSelStream, hIStream
    .ELSEIF eax == @ButtonImageSelAlt
        Invoke MUISetIntProperty, hWin, @ButtonImageSelAltStream, hIStream
    .ELSEIF eax == @ButtonImageDisabled
        Invoke MUISetIntProperty, hWin, @ButtonImageDisabledStream, hIStream
    .ELSEIF eax == @ButtonNotifyImage
        Invoke MUISetIntProperty, hWin, @ButtonNotifyImageStream, hIStream
    .ENDIF

	mov eax, TRUE
	
_MUI_ButtonLoadPng@Close:
	ret
_MUI_ButtonLoadPng endp



























END
