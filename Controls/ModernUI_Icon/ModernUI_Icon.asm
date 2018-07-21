;======================================================================================================================================
;
; ModernUI Control - ModernUI_Icon v1.0.0.0
;
; Copyright (c) 2018 by fearless
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
;include msimg32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
;includelib msimg32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_Icon.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_IconWndProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_IconInit					PROTO :DWORD
_MUI_IconPaint					PROTO :DWORD
_MUI_IconSetRegion              PROTO :DWORD, :DWORD, :DWORD
_MUI_IconLoadRegionFromRes      PROTO :DWORD, :DWORD, :DWORD, :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; External public properties
MUI_ICON_PROPERTIES				STRUCT
	dwIconBackColor				DD ?
    dwIconUnselected            DD ?
    dwIconUnselectedAlt         DD ?
    dwIconSelected              DD ?
    dwIconSelectedAlt        	DD ?
    dwIconDisabled              DD ?
MUI_ICON_PROPERTIES				ENDS

; Internal properties
_MUI_ICON_PROPERTIES			STRUCT
	dwEnabledState				DD ?
	dwMouseOver					DD ?
	dwSelectedState             DD ?
	dwIconRegion                DD ?
	dwMouseDown                 DD ?
_MUI_ICON_PROPERTIES			ENDS


.CONST
; Internal properties
@IconEnabledState				EQU 0
@IconMouseOver					EQU 4
@IconSelectedState              EQU 8
@IconRegion                     EQU 12
@IconMouseDown                  EQU 16

; External public properties


.DATA
szMUIIconClass					DB 'ModernUI_Icon',0 	; Class name for creating our ModernUI_Icon control


.CODE

align 4

;-------------------------------------------------------------------------------------
; Set property for ModernUI_Icon control
;-------------------------------------------------------------------------------------
MUIIconSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIIconSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for ModernUI_Icon control
;-------------------------------------------------------------------------------------
MUIIconGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIIconGetProperty ENDP


;-------------------------------------------------------------------------------------
; MUIIconRegister - Registers the ModernUI_Icon control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Icon
;-------------------------------------------------------------------------------------
MUIIconRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIIconClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIIconClass
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
    	mov wc.lpfnWndProc, OFFSET _MUI_IconWndProc
    	;Invoke LoadCursor, NULL, IDC_ARROW
    	mov wc.hCursor, NULL;eax
    	mov wc.hIcon, 0
    	mov wc.hIconSm, 0
    	mov wc.lpszMenuName, NULL
    	mov wc.hbrBackground, NULL
    	mov wc.style, 0
        mov wc.cbClsExtra, 0
    	mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
    	Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

MUIIconRegister ENDP


;-------------------------------------------------------------------------------------
; MUIIconCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUIIconCreate PROC PRIVATE hWndParent:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	LOCAL hControl:DWORD
	LOCAL dwNewStyle:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

	Invoke MUIIconRegister
	
    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF	
	
    Invoke CreateWindowEx, WS_EX_TRANSPARENT, Addr szMUIIconClass, NULL, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
	mov hControl, eax
	.IF eax != NULL
		
	.ENDIF
	mov eax, hControl
    ret
MUIIconCreate ENDP


;-------------------------------------------------------------------------------------
; _MUI_IconWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_IconWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL rect:RECT
    LOCAL hParent:DWORD
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
		; sets text of our control, delete if not required.
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName	
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
		Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_ICON_PROPERTIES ; internal properties
		Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_ICON_PROPERTIES ; external properties
		Invoke _MUI_IconInit, hWin
		mov eax, 0
		ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke MUIFreeMemProperties, hWin, 0
		Invoke MUIFreeMemProperties, hWin, 4
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_IconPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIIS_HAND
        .IF eax == MUIIS_HAND
            Invoke LoadCursor, NULL, IDC_HAND
        .ELSE
            Invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
        mov eax, 0
        ret        

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIIS_PUSHBUTTON
        .IF eax == MUIIS_PUSHBUTTON
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax
            Invoke MapWindowPoints, hWin, hParent, addr rect, 2        
            add rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @IconMouseDown, TRUE
        .ELSE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        .ENDIF

    .ELSEIF eax == WM_LBUTTONUP
		; simulates click on our control, delete if not required.
		Invoke GetDlgCtrlID, hWin
		mov ebx,eax
		Invoke GetParent, hWin
		Invoke PostMessage, eax, WM_COMMAND, ebx, hWin
		
        Invoke MUIGetIntProperty, hWin, @IconMouseDown
        .IF eax == TRUE
            Invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            Invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER  + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @IconMouseDown, FALSE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF		
		

   .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUIGetIntProperty, hWin, @IconEnabledState
        .IF eax == TRUE   
    		Invoke MUISetIntProperty, hWin, @IconMouseOver, TRUE
    		.IF eax != TRUE
    		    Invoke ShowWindow, hWin, SW_HIDE
    		    Invoke InvalidateRect, hWin, NULL, TRUE
    		    Invoke ShowWindow, hWin, SW_SHOW
    		    mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
    		    mov TE.dwFlags, TME_LEAVE
    		    mov eax, hWin
    		    mov TE.hwndTrack, eax
    		    mov TE.dwHoverTime, NULL
    		    Invoke TrackMouseEvent, Addr TE
    		.ENDIF
        .ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        Invoke MUISetIntProperty, hWin, @IconMouseOver, FALSE
		Invoke ShowWindow, hWin, SW_HIDE
		Invoke InvalidateRect, hWin, NULL, TRUE
		Invoke ShowWindow, hWin, SW_SHOW
		Invoke LoadCursor, NULL, IDC_ARROW
		Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @IconMouseOver, FALSE
		Invoke InvalidateRect, hWin, NULL, TRUE
		Invoke LoadCursor, NULL, IDC_ARROW
		Invoke SetCursor, eax
	
	; custom messages start here
	
	.ELSEIF eax == MUI_GETPROPERTY
		Invoke MUIGetExtProperty, hWin, wParam
		ret
		
	.ELSEIF eax == MUI_SETPROPERTY	
		Invoke MUISetExtProperty, hWin, wParam, lParam
		Invoke InvalidateRect, hWin, NULL, TRUE
		ret

    .ELSEIF eax == MUIIM_SETREGION
        Invoke MUIIconSetRegion, hWin, wParam
        ret

    .ELSEIF eax == MUIIM_GETSTATE ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
        Invoke MUIGetIntProperty, hWin, @IconSelectedState
        ret
     
    .ELSEIF eax == MUIIM_SETSTATE ; wParam = TRUE/FALSE, lParam = NULL
        Invoke MUISetIntProperty, hWin, @IconSelectedState, wParam
        Invoke ShowWindow, hWin, SW_HIDE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke ShowWindow, hWin, SW_SHOW
        ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_IconWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_IconInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_IconInit PROC PRIVATE hControl:DWORD
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
    and eax, WS_CHILD or WS_VISIBLE ;or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE ;or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE ;or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle
    .ENDIF

    ; Set default initial external property values    
    Invoke MUISetIntProperty, hControl, @IconEnabledState, TRUE
    Invoke MUIGetParentBackgroundColor, hControl
    ;.IF eax == -1 ; if background was NULL then try a color as default
    ;    Invoke GetSysColor, COLOR_WINDOW
    ;.ENDIF
    Invoke MUISetExtProperty, hControl, @IconBackColor, eax ;MUI_RGBCOLOR(21,133,181)


    ret

_MUI_IconInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_IconPaint
;-------------------------------------------------------------------------------------
_MUI_IconPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hPen:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hOldPen:DWORD
    LOCAL MouseOver:DWORD
    LOCAL BackColor:DWORD
    LOCAL SelectedState:DWORD
    LOCAL EnabledState:DWORD
	LOCAL hIcon:DWORD

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax

	;----------------------------------------------------------
	; Get some property values
	;----------------------------------------------------------	
	; Use Invoke _MUIGetProperty, hWin, 4, @Property 
	; to get property required: text, back, border colors etc
	; save them to local vars for processing later in function
	;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect

    Invoke MUIGetIntProperty, hWin, @IconEnabledState
    mov EnabledState, eax    
	Invoke MUIGetIntProperty, hWin, @IconMouseOver
    mov MouseOver, eax
    Invoke MUIGetIntProperty, hWin, @IconSelectedState
    mov SelectedState, eax    
    Invoke MUIGetExtProperty, hWin, @IconBackColor
    mov BackColor, eax

    .IF EnabledState == TRUE
        .IF SelectedState == FALSE
            .IF MouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @IconUnselected
            .ELSE
                Invoke MUIGetExtProperty, hWin, @IconUnselectedAlt
                .IF eax == 0
                    Invoke MUIGetExtProperty, hWin, @IconUnselected
                .ENDIF
            .ENDIF
        .ELSE
            .IF MouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @IconSelected
                .IF eax == 0
                    Invoke MUIGetExtProperty, hWin, @IconUnselected
                .ENDIF
            .ELSE
                Invoke MUIGetExtProperty, hWin, @IconSelectedAlt
                .IF eax == 0
                    Invoke MUIGetExtProperty, hWin, @IconSelected
                .ENDIF
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @IconDisabled
    .ENDIF

    ; if no icon available
    mov hIcon, eax
    .IF hIcon == 0
        Invoke EndPaint, hWin, Addr ps
        ret
    .ENDIF

	.IF BackColor != -1 ; not transparent

        ;----------------------------------------------------------
        ; Setup Double Buffering if Back Color is not 0
        ;----------------------------------------------------------	
    	Invoke CreateCompatibleDC, hdc
    	mov hdcMem, eax
    	Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    	mov hbmMem, eax
    	Invoke SelectObject, hdcMem, hbmMem
    	mov hOldBitmap, eax

 	    ;----------------------------------------------------------
 	    ; Fill background
 	    ;----------------------------------------------------------
 	    Invoke GetStockObject, DC_BRUSH
 	    mov hBrush, eax
  	    Invoke SetDCBrushColor, hdcMem, BackColor
 	    Invoke FillRect, hdcMem, Addr rect, hBrush

 	    ;----------------------------------------------------------
 	    ; Draw Icon to mem dc
 	    ;----------------------------------------------------------
        Invoke DrawIconEx, hdcMem, rect.left, rect.top, hIcon, 0, 0, 0, 0, DI_NORMAL

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
        .IF hOldBrush != 0
            Invoke DeleteObject, hOldBrush
        .ENDIF        
        .IF hBrush != 0
            Invoke DeleteObject, hBrush
        .ENDIF

    .ELSE ; transparent background
    
 	    ;----------------------------------------------------------
 	    ; Draw Icon direct to hdc, to try to make as transparent
 	    ; as possible with combination of WS_EX_TRANSPARENT flag
 	    ;----------------------------------------------------------    
        ;Invoke SetBkMode, hdc, OPAQUE
        ;Invoke ValidateRgn, hWin, NULL;, FALSE
        ;Invoke ValidateRect, hWin, NULL

 	    Invoke GetStockObject, NULL_BRUSH
 	    mov hBrush, eax
        Invoke FillRect, hdc, Addr rect, hBrush
        Invoke DrawIconEx, hdc, rect.left, rect.top, hIcon, 0, 0, 0, 0, DI_NORMAL
        
        .IF hBrush != 0
            Invoke DeleteObject, hBrush
        .ENDIF        

    .ENDIF

    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_IconPaint ENDP


;-------------------------------------------------------------------------------------
; _MUI_IconLoadRegionFromRes - Loads region from resource
;-------------------------------------------------------------------------------------
_MUI_IconLoadRegionFromRes PROC USES EBX hInstance:DWORD, idRgnRes:DWORD, lpRegion:DWORD, lpdwSizeRegion:DWORD
    LOCAL hRes:DWORD

    ; Load region
    Invoke FindResource, hInstance, idRgnRes, RT_RCDATA ; load rng image as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInstance, hRes
        .IF eax != 0
            .IF lpdwSizeRegion != NULL
                mov ebx, lpdwSizeRegion
                mov [ebx], eax
            .ELSE
                mov eax, FALSE
                ret
            .ENDIF
            Invoke LoadResource, hInstance, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    .IF lpRegion != NULL
                        mov ebx, lpRegion
                        mov [ebx], eax
                        mov eax, TRUE
                    .ELSE
                        mov eax, FALSE
                    .ENDIF
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, FALSE
    .ENDIF    
    ret

_MUI_IconLoadRegionFromRes ENDP


;-------------------------------------------------------------------------------------
; _MUI_IconSetRegion - Sets region of control based on binary region data
;-------------------------------------------------------------------------------------
_MUI_IconSetRegion PROC PRIVATE hControl:DWORD, ptrRegionData:DWORD, dwRegionDataSize:DWORD
    LOCAL hRgn:DWORD
    LOCAL hRegionHandle:DWORD
    LOCAL rect:RECT

    Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
    mov hRgn, eax
    .IF eax == NULL
        ret
    .ENDIF

    Invoke MUIGetIntProperty, hControl, @IconRegion
    mov hRegionHandle, eax
    .IF hRegionHandle != 0
        Invoke SetWindowRgn, hControl, NULL, FALSE
        Invoke DeleteObject, hRegionHandle
        Invoke MUISetIntProperty, hControl, @IconRegion, 0
    .ENDIF
    
    Invoke GetRgnBox, hRgn, Addr rect
    inc rect.right
    
    Invoke SetWindowPos, hControl, NULL, 0, 0, rect.right, rect.bottom, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOMOVE ;SWP_NOCOPYBITS or SWP_NOREDRAW
    Invoke SetWindowRgn, hControl, hRgn, TRUE
    
    Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
    mov hRegionHandle, eax
    
    Invoke MUISetIntProperty, hControl, @IconRegion, hRegionHandle
    
    mov eax, hRegionHandle
    ret

_MUI_IconSetRegion ENDP


;-------------------------------------------------------------------------------------
; MUIIconSetRegion - Loads region from resource and sets region of control based on binary region data
;-------------------------------------------------------------------------------------
MUIIconSetRegion PROC hControl:DWORD, idRgnRes:DWORD
    LOCAL pRegion:DWORD
    LOCAL dwSizeRegion:DWORD
    LOCAL hinstance:DWORD

    .IF hControl == NULL || idRgnRes == NULL
        mov eax, FALSE
        ret
    .ENDIF

    Invoke GetModuleHandle, NULL
    mov hinstance, eax
    
    Invoke _MUI_IconLoadRegionFromRes, hinstance, idRgnRes, Addr pRegion, Addr dwSizeRegion
    .IF eax == TRUE
        Invoke _MUI_IconSetRegion, hControl, pRegion, dwSizeRegion
    .ENDIF

    ret
MUIIconSetRegion ENDP


;-------------------------------------------------------------------------------------
; MUIIconGetState
;-------------------------------------------------------------------------------------
MUIIconGetState PROC PUBLIC hControl:DWORD
    Invoke SendMessage, hControl, MUIIM_GETSTATE, 0, 0
    ret
MUIIconGetState ENDP


;-------------------------------------------------------------------------------------
; MUIIconSetState
;-------------------------------------------------------------------------------------
MUIIconSetState PROC PUBLIC hControl:DWORD, bState:DWORD
    Invoke SendMessage, hControl, MUIIM_SETSTATE, bState, 0
    ret
MUIIconSetState ENDP


;-------------------------------------------------------------------------------------
; MUIIconSetIcons - Sets the property handles for icons types
;-------------------------------------------------------------------------------------
MUIIconSetIcons PROC PUBLIC hControl:DWORD, hIcon:DWORD, hIconAlt:DWORD, hIconSel:DWORD, hIconSelAlt:DWORD, hIconDisabled:DWORD

    .IF hIcon != 0
        Invoke MUISetExtProperty, hControl, @IconUnselected, hIcon
    .ENDIF

    .IF hIconAlt != 0
        Invoke MUISetExtProperty, hControl, @IconUnselectedAlt, hIconAlt
    .ENDIF

    .IF hIconSel != 0
        Invoke MUISetExtProperty, hControl, @IconSelected, hIconSel
    .ENDIF

    .IF hIconSelAlt != 0
        Invoke MUISetExtProperty, hControl, @IconSelectedAlt, hIconSelAlt
    .ENDIF

    .IF hIconDisabled != 0
        Invoke MUISetExtProperty, hControl, @IconDisabled, hIconDisabled
    .ENDIF
    
    Invoke ShowWindow, hControl, SW_HIDE
    Invoke InvalidateRect, hControl, NULL, TRUE
    Invoke ShowWindow, hControl, SW_SHOW

    ret
MUIIconSetIcons ENDP




END
