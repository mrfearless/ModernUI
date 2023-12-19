;==============================================================================
;
; ModernUI Control - ModernUI_Region
;
; Copyright (c) 2023 by fearless
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
include masm32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib masm32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_Region.inc

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_ButtonButtonWndProc        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_RegionButtonInit           PROTO :DWORD
_MUI_RegionButtonPaint          PROTO :DWORD
_MUI_RegionButtonPaintBackground PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_RegionButtonPaintBorder    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_RegionButtonNotify         PROTO :DWORD, :DWORD

_MUI_PolygonAdjust              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_PolygonInflate             PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_PolygonCentroid            PROTO :DWORD, :DWORD, :DWORD

_MUI_PrintPolygonString         PROTO :DWORD, :DWORD

_MUI_ConvertTextToPoints        PROTO :DWORD, :DWORD

_MUI_RegionButtonDown           PROTO :DWORD ; WM_LBUTTONDOWN, WM_KEYDOWN + VK_SPACE
_MUI_RegionButtonUp             PROTO :DWORD ; WM_LBUTTONUP, WM_KEYUP + VK_SPACE


_MUI_CustomStateGetColor        PROTO :DWORD, :DWORD, :DWORD
_MUI_CustomStateGetBorderColor  PROTO :DWORD, :DWORD, :DWORD
_MUI_CustomStateGetBorderSize   PROTO :DWORD, :DWORD, :DWORD
_MUI_CustomStateGetStateFlag    PROTO :DWORD, :DWORD


;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
IFNDEF MUI_REGIONBUTTON_PROPERTIES
MUI_REGIONBUTTON_PROPERTIES     STRUCT
    dwBackColor                 DD ?    ; COLORREF. Back color.
    dwBackColorAlt              DD ?    ; COLORREF. Back color when mouse hovers over control.
    dwBackColorSel              DD ?    ; COLORREF. Back color when selected state = TRUE.
    dwBackColorSelAlt           DD ?    ; COLORREF. Back color when selected state = TRUE and mouse hovers over control.
    dwBackColorDisabled         DD ?    ; COLORREF. Back color when control is disabled.
    dwBorderColor               DD ?    ; COLORREF. Border color.
    dwBorderColorAlt            DD ?    ; COLORREF. Border color when mouse hovers over control.
    dwBorderColorSel            DD ?    ; COLORREF. Border color when selected state = TRUE.
    dwBorderColorSelAlt         DD ?    ; COLORREF. Border color when selected state = TRUE and mouse hovers over control.
    dwBorderColorDisabled       DD ?    ; COLORREF. Border color when control is disabled.
    dwBorderSize                DD ?    ; DWORD. Border size, 0 = disabled/no border (default)
    dwBorderSizeAlt             DD ?    ; DWORD. Border size when mouse hovers over, 0 = disabled/no border (default)
    dwBorderSizeSel             DD ?    ; DWORD. Border size when selected state = TRUE, 0 = disabled/no border (default)
    dwBorderSizeSelAlt          DD ?    ; DWORD. Border size when selected state = TRUE and mouse hovers over, 0 = disabled/no border (default)
    dwBorderSizeDisabled        DD ?    ; DWORD. Border size when control is disabled, 0 = disabled/no border (default)
    dwUserData                  DD ?    ; DWORD. User defined dword data
MUI_REGIONBUTTON_PROPERTIES     ENDS
ENDIF

; Internal properties
_MUI_REGIONBUTTON_PROPERTIES    STRUCT
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
    dwSelectedState             DD ?
    dwMouseDown                 DD ?
    dwRegionHandle              DD ?
    dwBitmap                    DD ?
    dwBitmapBrush               DD ?
    dwBitmapBrushOrgX           DD ?
    dwBitmapBrushOrgY           DD ?
    dwBitmapBrushBlend          DD ?    ; Level of transparency
    dwCustomStatesTotal         DD ?    ; Total no of custom states
    dwCustomState               DD ?    ; Current custom state index
    dwCustomStatesArray         DD ?    ; Max 32 
_MUI_REGIONBUTTON_PROPERTIES    ENDS


IFNDEF MUIRB_NOTIFY                     ; Notification Message Structure for RegionButton
MUIRB_NOTIFY                    STRUCT
    hdr                         NMHDR <0,0,0>
    lParam                      DD 0
MUIRB_NOTIFY                    ENDS
ENDIF

IFNDEF MUI_REGIONBUTTON_STATE
MUI_REGIONBUTTON_STATE          STRUCT
    dwColor                     DD ?    ; Color of region button
    dwColorAlt                  DD ?    ; Color of region button when mouse moves over
    dwBorderColor               DD ?    ; Border color of region button
    dwBorderColorAlt            DD ?    ; Border color of region button when mouse moves over
    dwBorderSize                DD ?    ; Border width of region button
    dwBorderSizeAlt             DD ?    ; Border width of region button when mouse moves over
    dwStateFlag                 DD ?    ; Determines behaviour of state
MUI_REGIONBUTTON_STATE          ENDS
ENDIF


.CONST
MUIRB_MAX_CUSTOM_STATES         EQU 32


; Internal properties
@RegionButtonEnabledState       EQU 0
@RegionButtonMouseOver          EQU 4
@RegionButtonSelectedState      EQU 8
@RegionButtonMouseDown          EQU 12
@RegionButtonRegionHandle       EQU 16
@RegionButtonBitmap             EQU 20
@RegionButtonBitmapBrush        EQU 24
@RegionButtonBitmapBrushOrgX    EQU 28
@RegionButtonBitmapBrushOrgY    EQU 32
@RegionButtonBitmapBrushBlend   EQU 36
@RegionButtonCustomStatesTotal  EQU 40
@RegionButtonCustomState        EQU 44
@RegionButtonCustomStatesArray  EQU 48 

; move RBNM to internal var alloced mem at start


; External public properties


.DATA
ALIGN 4
szMUIRegionButtonClass          DB 'ModernUI_RegionButton',0    ; Class name for creating our ModernUI_RegionButton control
RBNM                            MUIRB_NOTIFY <>
szPrintPolygonLineStart         DB 'POINT <',0
szPrintPolygonOpenAngleBracket  DB '<',0
szPrintPolygonCloseAngleBracket DB '>',0
szPrintPolygonComma             DB ",",0
szPrintPolygonSpace             DB " ",0
szPrintPolygonCRLF              DB 13,10,0

szPolypointsString              DB 4096 DUP (0)

.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for RegionButton control
;------------------------------------------------------------------------------
MUIRegionButtonSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIRegionButtonSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for RegionButton control
;------------------------------------------------------------------------------
MUIRegionButtonGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIRegionButtonGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonRegister - Registers the RegionButton control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as RegionButton
;------------------------------------------------------------------------------
MUIRegionButtonRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIRegionButtonClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIRegionButtonClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_RegionButtonWndProc
        ;Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, NULL
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

MUIRegionButtonRegister ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUIRegionButtonCreate PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUIRegionButtonRegister
    
    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
    
    Invoke CreateWindowEx, NULL, Addr szMUIRegionButtonClass, lpszText, dwNewStyle, xpos, ypos, 0, 0, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        
    .ENDIF
    mov eax, hControl
    ret
MUIRegionButtonCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_RegionButtonWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL rect:RECT
    LOCAL hParent:DWORD
    LOCAL pt:POINT
    LOCAL xPos:DWORD
    LOCAL yPos:DWORD
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        ; sets text of our control, delete if not required.
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_REGIONBUTTON_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_REGIONBUTTON_PROPERTIES ; external properties
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGDIPlusStart ; for png resources if used
        ENDIF       
        Invoke _MUI_RegionButtonInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
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
        Invoke _MUI_RegionButtonPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_HAND ; check if the SBBS_HAND style flag was specified
        .IF eax == MUIRB_HAND ; if so we change cursor to hand
            invoke LoadCursor, NULL, IDC_HAND
        .ELSE
            invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
        mov eax, 0
        ret  

;    .ELSEIF eax == WM_NCHITTEST
;        Invoke GetWindowLong, hWin, GWL_STYLE
;        and eax, MUIRB_MOVE ; check if the SBBS_HAND style flag was specified
;        .IF eax == MUIRB_MOVE
;            Invoke MUIGetIntProperty, hWin, @RegionButtonMouseDown
;            .IF eax == TRUE
;                mov eax, HTCAPTION
;                ret
;            .ENDIF
;        .ENDIF
;        Invoke DefWindowProc, hWin, WM_NCHITTEST, wParam, lParam
;        ret
        

    .ELSEIF eax == WM_GETDLGCODE
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_MOVE ; check if the MUIRB_MOVE style flag was specified
        .IF eax == MUIRB_MOVE    
            mov eax, DLGC_WANTARROWS ;DLGC_WANTALLKEYS ;DLGC_WANTMESSAGE or 
            ret
        .ELSE
            mov eax, 0
        .ENDIF

    .ELSEIF eax == WM_KEYUP
        mov eax, wParam
        .IF eax == VK_SPACE
            Invoke _MUI_RegionButtonUp, hWin
        .ENDIF

    .ELSEIF eax == WM_KEYDOWN
        mov eax, wParam
        .IF eax == VK_SPACE
            Invoke _MUI_RegionButtonDown, hWin
        .ELSEIF eax == VK_UP || eax == VK_DOWN || eax == VK_LEFT || eax == VK_RIGHT
            Invoke GetWindowLong, hWin, GWL_STYLE
            and eax, MUIRB_MOVE ; check if the MUIRB_MOVE style flag was specified
            .IF eax == MUIRB_MOVE
                Invoke GetParent, hWin
                mov hParent, eax
                Invoke GetWindowRect, hWin, Addr rect
                Invoke MapWindowPoints, HWND_DESKTOP, hParent, Addr rect, 2
                mov eax, rect.left
                mov xPos, eax
                mov eax, rect.top
                mov yPos, eax
    
                mov eax, wParam
                .IF eax == VK_UP
                    dec yPos
                .ELSEIF eax == VK_DOWN
                    inc yPos
                .ELSEIF eax == VK_LEFT
                    dec xPos
                .ELSEIF eax == VK_RIGHT
                    inc xPos
                .ENDIF
                Invoke SetWindowPos, hWin, NULL, xPos, yPos, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOSENDCHANGING
            .ENDIF
        .ENDIF

    .ELSEIF eax == WM_LBUTTONUP
        Invoke _MUI_RegionButtonUp, hWin

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MUI_RegionButtonDown, hWin


   .ELSEIF eax == WM_MOUSEMOVE
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_MOUSEMOVEPARENT
        .IF eax == MUIRB_MOUSEMOVEPARENT
            Invoke GetParent, hWin
            mov hParent, eax
            mov eax, lParam
            and eax, 0FFFFh
            mov rect.left, eax
            mov eax, lParam
            shr eax, 16d
            mov rect.top, eax
            Invoke MapWindowPoints, hWin, hParent, Addr rect, 2
            ;PrintDec rect.left
            ;PrintDec rect.top
            mov ebx, rect.top
            shl ebx, 16
            mov eax, rect.left
            mov bx, ax
            Invoke PostMessage, hParent, WM_MOUSEMOVE, wParam, ebx
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @RegionButtonEnabledState
        .IF eax == TRUE
            Invoke MUISetIntProperty, hWin, @RegionButtonMouseOver, TRUE
            .IF eax != TRUE
                Invoke InvalidateRect, hWin, NULL, TRUE
                Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_MOUSEOVER
                mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
                mov TE.dwFlags, TME_LEAVE
                mov eax, hWin
                mov TE.hwndTrack, eax
                mov TE.dwHoverTime, NULL
                Invoke TrackMouseEvent, Addr TE
            .ELSE
                Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_MOUSEOVER
            .ENDIF
        .ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        Invoke MUISetIntProperty, hWin, @RegionButtonMouseOver, FALSE
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_PUSHBUTTON
        .IF eax == MUIRB_PUSHBUTTON        
            Invoke MUIGetIntProperty, hWin, @RegionButtonMouseDown
            .IF eax == TRUE     
                invoke GetClientRect, hWin, addr rect
                Invoke GetParent, hWin
                mov hParent, eax            
                invoke MapWindowPoints, hWin, hParent, addr rect, 2   
                sub rect.top, 1
                Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
                Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, FALSE
            .ELSE
                Invoke InvalidateRect, hWin, NULL, TRUE
                ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
            .ENDIF
        .ELSE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
        ;Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_MOUSELEAVE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_MOUSEACTIVATE
        Invoke SetFocus, hWin
        mov eax, MA_ACTIVATE
        ret

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @RegionButtonMouseOver, FALSE
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_PUSHBUTTON
        .IF eax == MUIRB_PUSHBUTTON         
             Invoke MUIGetIntProperty, hWin, @RegionButtonMouseDown
            .IF eax == TRUE     
                invoke GetClientRect, hWin, addr rect
                Invoke GetParent, hWin
                mov hParent, eax            
                invoke MapWindowPoints, hWin, hParent, addr rect, 2   
                sub rect.top, 1
                Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
                Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, FALSE
            .ELSE
                Invoke InvalidateRect, hWin, NULL, FALSE
                ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
            .ENDIF
        .ELSE
            Invoke InvalidateRect, hWin, NULL, FALSE
            ;Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
        Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_MOUSELEAVE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_ENABLE
        Invoke MUISetIntProperty, hWin, @RegionButtonEnabledState, wParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        .IF wParam == TRUE
            Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_ENABLED
        .ELSE
            Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_DISABLED
        .ENDIF
        mov eax, 0
    
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY
        Invoke MUISetExtProperty, hWin, wParam, lParam
        
        mov eax, wParam
        .IF eax == @RegionButtonBorderSize ; set other border sizes as well
            Invoke MUISetExtProperty, hWin, @RegionButtonBorderSizeAlt, lParam
            Invoke MUISetExtProperty, hWin, @RegionButtonBorderSizeSel, lParam
            Invoke MUISetExtProperty, hWin, @RegionButtonBorderSizeSelAlt, lParam
            Invoke MUISetExtProperty, hWin, @RegionButtonBorderSizeDisabled, lParam       
        .ENDIF
        
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret

    .ELSEIF eax == MUIRB_GETSTATE ; wParam = NULL, lParam = NULL. EAX = dwState
        Invoke MUIGetIntProperty, hWin, @RegionButtonSelectedState
        ret
     
    .ELSEIF eax == MUIRB_SETSTATE ; wParam = TRUE/FALSE, lParam = NULL
        Invoke MUISetIntProperty, hWin, @RegionButtonSelectedState, wParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        .IF wParam == TRUE
            Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_SELECTED
        .ELSE
            Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_UNSELECTED
        .ENDIF
        ret
    
    .ELSEIF eax == MUIRB_SETREGION
        Invoke MUIRegionButtonSetRegion, hWin, wParam, lParam
        ret
        
    .ELSEIF eax == MUIRB_SETBITMAP
        Invoke MUIRegionButtonSetRegionBitmap, hWin, wParam
        ret        
    
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_RegionButtonWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonInit - set initial default values
;------------------------------------------------------------------------------
_MUI_RegionButtonInit PROC PRIVATE hControl:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwPoints:DWORD
    LOCAL ptrPoints:DWORD
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
        mov dwStyle, eax
        Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle
    .ENDIF
    
    ; Set default initial external property values     
    Invoke MUISetIntProperty, hControl, @RegionButtonEnabledState, TRUE
    Invoke MUISetIntProperty, hControl, @RegionButtonSelectedState, FALSE
    Invoke MUISetIntProperty, hControl, @RegionButtonMouseOver, FALSE
    Invoke MUISetIntProperty, hControl, @RegionButtonMouseDown, FALSE    

    Invoke MUISetExtProperty, hControl, @RegionButtonBackColor, MUI_RGBCOLOR(197,204,206)
    Invoke MUISetExtProperty, hControl, @RegionButtonBackColorAlt, MUI_RGBCOLOR(165,203,214)
    Invoke MUISetExtProperty, hControl, @RegionButtonBackColorSel, MUI_RGBCOLOR(21,133,181)
    Invoke MUISetExtProperty, hControl, @RegionButtonBackColorSelAlt, MUI_RGBCOLOR(93,193,222)
    Invoke MUISetExtProperty, hControl, @RegionButtonBackColorDisabled, MUI_RGBCOLOR(255,255,255)

    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColor, MUI_RGBCOLOR(190,190,190) ;MUI_RGBCOLOR(92,92,92) ; MUI_RGBCOLOR(150,163,167) ; MUI_RGBCOLOR(138,153,157) ;MUI_RGBCOLOR(1,1,1)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorAlt, MUI_RGBCOLOR(39,168,205);MUI_RGBCOLOR(39,39,39) ;MUI_RGBCOLOR(39,168,205)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorSel, MUI_RGBCOLOR(39,168,205)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorSelAlt, MUI_RGBCOLOR(39,168,205)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorDisabled, MUI_RGBCOLOR(204,204,204)
    
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderSize, 1
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderSizeAlt, 1
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderSizeSel, 1
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderSizeSelAlt, 1
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderSizeDisabled, 1
    Invoke MUISetIntProperty, hControl, @RegionButtonRegionHandle, 0
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmap, 0
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrush, 0
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrushOrgX, 0
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrushOrgY, 0
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrushBlend, 0

    Invoke MUISetIntProperty, hControl, @RegionButtonCustomStatesTotal, 0
    Invoke MUISetIntProperty, hControl, @RegionButtonCustomState, -1
    Invoke MUISetIntProperty, hControl, @RegionButtonCustomStatesArray, 0


    Invoke _MUI_ConvertTextToPoints, hControl, Addr dwPoints
    .IF eax != NULL
        mov ptrPoints, eax
        Invoke MUIRegionButtonSetRegionPoly, hControl, ptrPoints, dwPoints, 0, 0, 0, 0
    .ENDIF

    ret
_MUI_RegionButtonInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonDown - Mouse button down or keyboard down from vk_space
;------------------------------------------------------------------------------
_MUI_RegionButtonDown PROC PRIVATE hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL rect:RECT    

    IFDEF DEBUG32
        PrintText '_MUI_RegionButtonDown'
    ENDIF

;    Invoke GetFocus
;    .IF eax != hWin
;        Invoke SetFocus, hWin
;        Invoke MUISetIntProperty, hWin, @RegionButtonFocusedState, FALSE
;    .ENDIF

    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUIRB_PUSHBUTTON
    .IF eax == MUIRB_PUSHBUTTON
        Invoke MUIGetIntProperty, hWin, @RegionButtonMouseDown
        .IF eax == FALSE
            Invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax
            invoke MapWindowPoints, hWin, hParent, addr rect, 2        
            add rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, TRUE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
    .ELSE
        Invoke MUIGetIntProperty, hWin, @RegionButtonMouseDown
        .IF eax == FALSE
            Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, TRUE
        .ENDIF
        ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF
    ret
_MUI_RegionButtonDown ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonUp - Mouse button up or keyboard up from vk_space
;------------------------------------------------------------------------------
_MUI_RegionButtonUp PROC PRIVATE hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL wID:DWORD
    LOCAL rect:RECT
    
    IFDEF DEBUG32
        PrintText '_MUI_RegionButtonUp'
    ENDIF

    Invoke MUIGetIntProperty, hWin, @RegionButtonMouseDown
    .IF eax == TRUE
        Invoke GetDlgCtrlID, hWin
        mov wID,eax
        Invoke GetParent, hWin
        mov hParent, eax
        Invoke PostMessage, hParent, WM_COMMAND, wID, hWin ; simulates click on our control    
        
        Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_CLICKED
        
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_PUSHBUTTON
        .IF eax == MUIRB_PUSHBUTTON
            Invoke GetClientRect, hWin, addr rect
            Invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER  + SWP_FRAMECHANGED
        .ENDIF
        
        Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, FALSE

        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_AUTOSTATE
        .IF eax == MUIRB_AUTOSTATE
            Invoke MUIGetIntProperty, hWin, @RegionButtonSelectedState
            .IF eax == FALSE
                Invoke MUISetIntProperty, hWin, @RegionButtonSelectedState, TRUE
                ;Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_SELECTED
            .ELSE
                Invoke MUISetIntProperty, hWin, @RegionButtonSelectedState, FALSE
                ;Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_UNSELECTED
            .ENDIF
        .ENDIF        
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ELSE
        ;Invoke InvalidateRect, hWin, NULL, TRUE
        ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF
    ret
_MUI_RegionButtonUp ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonSetRegion - Sets region of control based on binary region data
;------------------------------------------------------------------------------
MUIRegionButtonSetRegion PROC PUBLIC hControl:DWORD, ptrRegionData:DWORD, dwRegionDataSize:DWORD
    LOCAL hRgn:DWORD
    LOCAL hRegionHandle:DWORD
    LOCAL rect:RECT

    Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
    mov hRgn, eax
    .IF eax == NULL
        ret
    .ENDIF

    Invoke MUIGetIntProperty, hControl, @RegionButtonRegionHandle
    mov hRegionHandle, eax
    .IF hRegionHandle != 0
        Invoke SetWindowRgn, hControl, NULL, FALSE
        Invoke DeleteObject, hRegionHandle
        Invoke MUISetIntProperty, hControl, @RegionButtonRegionHandle, 0
    .ENDIF
    
    Invoke GetRgnBox, hRgn, Addr rect
    inc rect.right
    
    Invoke SetWindowPos, hControl, NULL, 0, 0, rect.right, rect.bottom, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOMOVE ;SWP_NOCOPYBITS or SWP_NOREDRAW
    Invoke SetWindowRgn, hControl, hRgn, TRUE
    
    Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
    mov hRegionHandle, eax
    
    Invoke MUISetIntProperty, hControl, @RegionButtonRegionHandle, hRegionHandle
    
    mov eax, hRegionHandle
    ret

MUIRegionButtonSetRegion ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonSetRegionPoly - Sets region of control based on polygon point 
; data
;
; if dwPolyType == MUIRBP_SINGLE, then dwPolyDataCount = no of point entries
; in array pointed to by ptrPolyData
;
; if dwPolyType == MUIRBP_MULTIPLE, then dwPolyDataCount = no of MUIRB_POLY 
; array entries to combine, pointed to by ptrPolyData
; useful for say maps with multiple polygons that represent an island, that
; require all polygons to be combined into a region. 
;
; dwXAdjust and dwYAdjust optional adjust left and top co-ords of control
;
;------------------------------------------------------------------------------
MUIRegionButtonSetRegionPoly PROC PUBLIC USES EBX hControl:DWORD, ptrPolyData:DWORD, dwPolyDataCount:DWORD, dwPolyType:DWORD, dwXAdjust:DWORD, dwYAdjust:DWORD, lpBoundsRect:DWORD
    LOCAL hRgn:DWORD
    LOCAL hRgnCopy:DWORD
    LOCAL hWinRgn:DWORD
    LOCAL pPolyData:DWORD
    LOCAL pPolyDataNew:DWORD
    LOCAL pPolyCurrent:DWORD
    LOCAL dwPolyCount:DWORD
    LOCAL dwPolyCurrent:DWORD
    LOCAL dwCounter:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL rect:RECT
    LOCAL newpos:RECT
    LOCAL boundsrect:RECT

    ;-----------------------------------------------------
    ; if rect is 0,0,0,0 set left and top to max value
    ;-----------------------------------------------------
    .IF lpBoundsRect != 0
        Invoke CopyRect, Addr boundsrect, lpBoundsRect
        .IF boundsrect.left == 0 && boundsrect.top == 0 && boundsrect.right == 0 && boundsrect.bottom == 0
            mov boundsrect.left, 7FFFFFFFh
            mov boundsrect.top, 7FFFFFFFh
        .ENDIF
    .ENDIF
    ;-----------------------------------------------------


    ;-----------------------------------------------------
    ; Get existing region copy if it exists and delete it
    ;-----------------------------------------------------
    Invoke MUIGetIntProperty, hControl, @RegionButtonRegionHandle
    mov hRgnCopy, eax
    .IF hRgnCopy != 0
        Invoke SetWindowRgn, hControl, NULL, FALSE
        Invoke DeleteObject, hRgnCopy
        Invoke MUISetIntProperty, hControl, @RegionButtonRegionHandle, 0
    .ENDIF
    ;-----------------------------------------------------


    .IF dwPolyType == 0 || dwPolyType == 1 ; Single polygon to create

        ;-----------------------------------------------------
        ; Create initial polygon to get rgnbox of polygon
        ; Adjust polygon to reset regions to 0, 0 of control
        ;-----------------------------------------------------
        Invoke CreatePolygonRgn, ptrPolyData, dwPolyDataCount, WINDING
        mov hRgn, eax
        Invoke GetRgnBox, hRgn, Addr newpos
        Invoke DeleteObject, hRgn
        Invoke _MUI_PolygonAdjust, ptrPolyData, dwPolyDataCount, newpos.left, newpos.top, TRUE
        mov pPolyDataNew, eax
        ;Invoke _MUI_PolygonInflate, pPolyDataNew, dwPolyDataCount, 1, FALSE
        ;-----------------------------------------------------

        ;Invoke _MUI_PrintPolygonString, pPolyDataNew, dwPolyDataCount

        .IF pPolyDataNew != 0
            ;PrintText 'Adjusted points'
            Invoke CreatePolygonRgn, pPolyDataNew, dwPolyDataCount, WINDING
            mov hRgnCopy, eax
            Invoke CreatePolygonRgn, pPolyDataNew, dwPolyDataCount, WINDING
            mov hWinRgn, eax
            Invoke GlobalFree, pPolyDataNew
        .ELSE
            ;PrintText 'Original points'
            Invoke CreatePolygonRgn, ptrPolyData, dwPolyDataCount, WINDING
            mov hRgnCopy, eax
            Invoke CreatePolygonRgn, ptrPolyData, dwPolyDataCount, WINDING
            mov hWinRgn, eax
        .ENDIF


    .ELSE;IF dwPolyType == MUIRBP_MULTIPLE ; group of polygons to create

        ;-----------------------------------------------------
        ; Create initial polygon to get rgnbox of PolyPolygon
        ; Adjust PolyPolygon to reset regions to 0, 0 of control
        ;-----------------------------------------------------
        Invoke CreatePolyPolygonRgn, ptrPolyData, dwPolyDataCount, dwPolyType, WINDING
        mov hRgn, eax
        Invoke GetRgnBox, hRgn, Addr newpos
        Invoke DeleteObject, hRgn
        
        ; Calc total points to adjust
        mov dwPolyCurrent, 0
        mov ebx, dwPolyDataCount
        mov eax, 0
        mov dwCounter, 0
        .WHILE eax < dwPolyType
            mov eax, [ebx]
            add dwPolyCurrent, eax
            add ebx, SIZEOF DWORD
            inc dwCounter
            mov eax, dwCounter
        .ENDW
        Invoke _MUI_PolygonAdjust, ptrPolyData, dwPolyCurrent, newpos.left, newpos.top, TRUE
        mov pPolyDataNew, eax
        ;-----------------------------------------------------

        .IF pPolyDataNew != 0
            ;PrintText 'Adjusted CreatePolyPolygonRgn points'
            Invoke CreatePolyPolygonRgn, pPolyDataNew, dwPolyDataCount, dwPolyType, WINDING
            mov hRgnCopy, eax
            Invoke CreatePolyPolygonRgn, pPolyDataNew, dwPolyDataCount, dwPolyType, WINDING
            mov hWinRgn, eax
            Invoke GlobalFree, pPolyDataNew
        .ELSE
            ;PrintText 'Original CreatePolyPolygonRgn points'
            Invoke CreatePolyPolygonRgn, ptrPolyData, dwPolyDataCount, dwPolyType, WINDING
            mov hRgnCopy, eax
            Invoke CreatePolyPolygonRgn, ptrPolyData, dwPolyDataCount, dwPolyType, WINDING
            mov hWinRgn, eax
        .ENDIF

    .ENDIF


    ;-----------------------------------------------------
    ; Adjust control's position by dwXAdjust and dwYAdjust
    ;----------------------------------------------------- 
    mov eax, dwXAdjust
    .IF sdword ptr eax < 0 ; negative
        neg eax
        sub newpos.left, eax
        sub newpos.right, eax
    .ELSE
        add newpos.left, eax
        add newpos.right, eax
    .ENDIF
    mov eax, dwYAdjust
    .IF sdword ptr eax < 0
        neg eax
        sub newpos.bottom, eax
        sub newpos.top, eax
    .ELSE
        add newpos.bottom, eax
        add newpos.top, eax
    .ENDIF
    ;-----------------------------------------------------


    ;-----------------------------------------------------
    ; Get width and height of control based on polygons 
    ; created position
    ;-----------------------------------------------------
    mov eax, newpos.right
    sub eax, newpos.left
    mov dwWidth, eax
    mov eax, newpos.bottom
    sub eax, newpos.top
    mov dwHeight, eax
    inc newpos.right
    ;-----------------------------------------------------


    ;-----------------------------------------------------
    ; Set control's position - adjusted by dwXAdjust and 
    ; dwYAdjust above previously and set control's final
    ; window region based on created polygon(s) and 
    ; save region handle copy for later use ie FrameRgn.
    ;-----------------------------------------------------
    Invoke SetWindowPos, hControl, NULL, newpos.left, newpos.top, dwWidth, dwHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING ;or SWP_NOMOVE ;SWP_NOCOPYBITS or SWP_NOREDRAW    
    Invoke SetWindowRgn, hControl, hWinRgn, TRUE
    Invoke MUISetIntProperty, hControl, @RegionButtonRegionHandle, hRgnCopy    
    ;-----------------------------------------------------
    

    ;-----------------------------------------------------
    ; Calculate max bounds of all controls using this
    ; function and copy rect back to lpRect
    ;-----------------------------------------------------
    .IF lpBoundsRect != 0
        Invoke GetWindowRect, hControl, Addr rect
        mov eax, rect.left
        .IF sdword ptr eax < boundsrect.left
            mov boundsrect.left, eax
        .ENDIF
        mov eax, rect.top
        .IF sdword ptr eax < boundsrect.top
            mov boundsrect.top, eax
        .ENDIF
        mov eax, rect.right
        .IF eax > boundsrect.right
            mov boundsrect.right, eax
        .ENDIF
        mov eax, rect.bottom
        .IF eax > boundsrect.bottom
            mov boundsrect.bottom, eax
        .ENDIF
        Invoke CopyRect, lpBoundsRect, Addr boundsrect
    .ENDIF
    ;-----------------------------------------------------


    mov eax, hRgnCopy ; return copy of region handle
    ret
MUIRegionButtonSetRegionPoly ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Adjust the position of a polygon by x and y. Optionally creates a new polygon
; points array if bNewPolygon == TRUE, otherwise replaces original points with
; the adjustments. New polygon array can be freed with GlobalFree when not 
; required anymore.
; Returns NULL if error or pointer to polgon points array (can be new array of
; points) if bNewPolygon == TRUE, otherwise it is the original ptrPolyData.
;------------------------------------------------------------------------------
_MUI_PolygonAdjust PROC USES EBX EDI ESI ptrPolyData:DWORD, dwPolyDataCount:DWORD, dwXAdjust:DWORD, dwYAdjust:DWORD, bNewPolygon:DWORD
    LOCAL pTempPolyData:DWORD
    LOCAL dwCurrentPoint:DWORD
    
    .IF bNewPolygon == TRUE
        mov eax, dwPolyDataCount
        mov ebx, SIZEOF POINT
        mul ebx
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax == NULL
            ret
        .ENDIF
        mov pTempPolyData, eax
    .ELSE
        mov eax, ptrPolyData
        mov pTempPolyData, eax
    .ENDIF

    ; loop through poly points, adjust x, y
    mov esi, ptrPolyData
    mov edi, pTempPolyData    
    mov eax, 0
    mov dwCurrentPoint, 0
    .WHILE eax < dwPolyDataCount
        
        mov eax, [esi]
        sub eax, dwXAdjust
        mov [edi], eax
        mov eax, [esi+4]
        sub eax, dwYAdjust
        mov [edi+4], eax
        
        add edi, SIZEOF POINT
        add esi, SIZEOF POINT
        inc dwCurrentPoint
        mov eax, dwCurrentPoint
    .ENDW

    mov eax, pTempPolyData
    ret
_MUI_PolygonAdjust ENDP


;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
_MUI_PolygonInflate PROC USES EBX EDX EDI ESI ptrPolyData:DWORD, dwPolyDataCount:DWORD, dwInflate:DWORD, bNewPolygon:DWORD
    LOCAL pTempPolyData:DWORD
    LOCAL dwCurrentPoint:DWORD
    LOCAL center:POINT
    LOCAL sumx:DWORD
    LOCAL sumy:DWORD
    LOCAL inflate:DWORD
    
    .IF bNewPolygon == TRUE
        mov eax, dwPolyDataCount
        mov ebx, SIZEOF POINT
        mul ebx
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
        .IF eax == NULL
            ret
        .ENDIF
        mov pTempPolyData, eax
    .ELSE
        mov eax, ptrPolyData
        mov pTempPolyData, eax
    .ENDIF

    Invoke _MUI_PolygonCentroid, ptrPolyData, dwPolyDataCount, Addr center
    ; loop through poly points to get center x, y from sum x and sum y div by count of points
;    mov esi, ptrPolyData
;    mov sumx, 0
;    mov sumy, 0
;    mov eax, 0
;    mov dwCurrentPoint, 0
;    .WHILE eax < dwPolyDataCount
;        mov eax, [esi]
;        add sumx, eax
;        mov eax, [esi+4]
;        add sumy, eax
;        add esi, SIZEOF POINT
;        inc dwCurrentPoint
;        mov eax, dwCurrentPoint
;    .ENDW
;    
;    xor edx, edx
;    mov eax, sumx
;    mov ecx, dwPolyDataCount
;    div ecx
;    mov center.x, eax
;    
;    xor edx, edx
;    mov eax, sumy
;    mov ecx, dwPolyDataCount
;    div ecx
;    mov center.y, eax    
    
    IFDEF DEBUG32
        PrintDec center.x
        PrintDec center.y
    ENDIF
    
    ; loop through poly points, adjust x, y
    mov esi, ptrPolyData
    mov edi, pTempPolyData
    mov eax, 0
    mov dwCurrentPoint, 0
    .WHILE eax < dwPolyDataCount
        
        mov eax, [esi]
        .IF eax < center.x
            sub eax, dwInflate
        .ELSEIF eax > center.x
            add eax, dwInflate
        .ENDIF
        mov [edi], eax
        
        mov eax, [esi+4]
        .IF eax < center.y
            sub eax, dwInflate
        .ELSEIF eax > center.y
            add eax, dwInflate
        .ENDIF
        mov [edi+4], eax
        
        add edi, SIZEOF POINT
        add esi, SIZEOF POINT
        inc dwCurrentPoint
        mov eax, dwCurrentPoint
    .ENDW

    mov eax, pTempPolyData
    ret
_MUI_PolygonInflate ENDP


;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
_MUI_PrintPolygonString PROC USES EBX EDI ESI ptrPolyData:DWORD, dwPolyDataCount:DWORD
    LOCAL dwCurrentPoint:DWORD
    LOCAL dwCurrentCoords:DWORD
    ;LOCAL szPolypointsString:DWORD
    LOCAL dwCoord:DWORD
    LOCAL szCoord[8]:BYTE
    
;    mov ebx, dwPolyDataCount
;    mov eax, 38d
;    mul ebx
;    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
;    .IF eax == NULL
;        ret
;    .ENDIF
;    mov szPolypointsString, eax
    
    Invoke RtlZeroMemory, Addr szPolypointsString, SIZEOF szPolypointsString
    
    mov esi, ptrPolyData
    mov eax, 0
    mov dwCurrentPoint, 0
    mov dwCurrentCoords, 0
    .WHILE eax < dwPolyDataCount
        
        .IF dwCurrentCoords == 0
            Invoke szCatStr, Addr szPolypointsString, Addr szPrintPolygonLineStart
        .ELSE
            Invoke szCatStr, Addr szPolypointsString, Addr szPrintPolygonOpenAngleBracket
        .ENDIF
        
        mov eax, [esi]
        mov dwCoord, eax
        Invoke dwtoa, dwCoord, Addr szCoord
        Invoke szCatStr, Addr szPolypointsString, Addr szCoord
        Invoke szCatStr, Addr szPolypointsString, Addr szPrintPolygonComma
        
        mov eax, [esi+4]
        mov dwCoord, eax
        Invoke dwtoa, dwCoord, Addr szCoord
        Invoke szCatStr, Addr szPolypointsString, Addr szCoord
        Invoke szCatStr, Addr szPolypointsString, Addr szPrintPolygonCloseAngleBracket
        Invoke szCatStr, Addr szPolypointsString, Addr szPrintPolygonSpace
        
        
        inc dwCurrentCoords
        .IF dwCurrentCoords > 10
            Invoke szCatStr, Addr szPolypointsString, Addr szPrintPolygonCRLF
            mov dwCurrentCoords, 0
        .ENDIF
        
        add esi, SIZEOF POINT
        inc dwCurrentPoint
        mov eax, dwCurrentPoint
    .ENDW
    
    IFDEF DEBUG32
        ;lea eax, szPolypointsString
        ;PrintStringByAddr eax
        PrintString szPolypointsString
    ENDIF
    
    ;Invoke GlobalFree, szPolypointsString
    ret

_MUI_PrintPolygonString ENDP


_MUI_PolygonCentroid PROC USES EBX ECX EDX EDI ESI ptrPolyData:DWORD, dwPolyDataCount:DWORD, lpdwCentroid:DWORD
    LOCAL dwCurrentPoint:DWORD
    LOCAL dwMaxPoints:DWORD
    LOCAL centroid:POINT
    LOCAL signedarea:DWORD
    LOCAL x0:DWORD
    LOCAL y0:DWORD
    LOCAL x1:DWORD
    LOCAL y1:DWORD
    LOCAL x0y1:DWORD
    LOCAL x1y0:DWORD
    LOCAL a:DWORD
    
    mov eax, dwPolyDataCount
    dec eax
    mov dwMaxPoints, eax

    mov esi, ptrPolyData
    mov signedarea, 0
    mov centroid.x, 0
    mov centroid.y, 0
    mov eax, 0
    mov dwCurrentPoint, 0
    .WHILE eax < dwPolyDataCount
        .IF eax == dwMaxPoints
            mov eax, [esi]
            mov x0, eax
            mov eax, [esi+4]
            mov y0, eax
            mov esi, ptrPolyData
            mov eax, [esi]
            mov x1, eax
            mov eax, [esi+4]
            mov y1, eax
        .ELSE
            mov eax, [esi]
            mov x0, eax
            mov eax, [esi+4]
            mov y0, eax
            
            mov eax, [esi+8]
            mov x1, eax
            mov eax, [esi+12]
            mov y1, eax
        .ENDIF

        mov eax, x0
        mov ebx, y1
        mul ebx
        mov x0y1, eax
        ;PrintDec x0y1
        
        mov eax, x1
        mov ebx, y0
        mul ebx
        mov x1y0, eax
        ;PrintDec x1y0
        
        mov eax, x1y0
        mov ebx, x0y1
        sub eax, ebx
        mov a, eax
        ;PrintDec a
        add signedarea, eax
        ;PrintDec signedarea
        
        mov eax, x0
        add eax, x1
        mov ebx, a
        mul ebx
        add centroid.x, eax
        
        mov eax, y0
        add eax, y1
        mov ebx, a
        mul ebx
        add centroid.y, eax

        add esi, SIZEOF POINT
        inc dwCurrentPoint
        mov eax, dwCurrentPoint
    .ENDW

    mov eax, signedarea
    shr eax, 1 ; * 0.5
    mov signedarea, eax

    mov eax, 6
    mov ebx, signedarea
    mul ebx
    mov ecx, eax
    mov eax, centroid.x
    xor edx, edx
    div ecx
    mov centroid.x, eax
    
    mov eax, 6
    mov ebx, signedarea
    mul ebx
    mov ecx, eax
    mov eax, centroid.y
    xor edx, edx
    div ecx
    mov centroid.y, eax

    .IF lpdwCentroid != 0
        mov ebx, lpdwCentroid
        mov eax, centroid.x
        mov [ebx], eax
        mov eax, centroid.y
        mov [ebx+4], eax
    .ENDIF
    ;PrintDec centroid.x
    ;PrintDec centroid.y

    ret
_MUI_PolygonCentroid ENDP



MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonSetRegionBitmap - Sets region of control based on bitmap passed to it
;------------------------------------------------------------------------------
MUIRegionButtonSetRegionBitmap PROC PUBLIC USES EBX ECX EDX hControl:DWORD, hBitmap:DWORD
    LOCAL hdc:HDC
    LOCAL hMemDC:HDC
    LOCAL rect:RECT
    LOCAL hRegion:HRGN
    LOCAL hRgnTmp:HRGN
    LOCAL bmp:BITMAP
    LOCAL pixel:DWORD
    LOCAL crTransparent:COLORREF
    LOCAL cont:DWORD
    LOCAL dwRegionDataSize:DWORD

    Invoke GetObject, hBitmap, SIZEOF bmp, ADDR bmp

    Invoke CreateCompatibleDC, hdc          
    mov hMemDC, eax
    Invoke SelectObject, hMemDC, hBitmap

    mov crTransparent, 00ffffffh
    Invoke CreateRectRgn, 0, 0, bmp.bmWidth, bmp.bmHeight
    mov hRegion, eax
    mov ebx, 0 ;Y
    mov ecx, 0 ;X
    .WHILE (ebx < bmp.bmHeight)
        .WHILE (ecx < bmp.bmWidth)
            .WHILE (ecx < bmp.bmWidth)
                push ecx
                push ebx
                Invoke GetPixel, hMemDC, ecx, ebx
                pop ebx
                pop ecx
                mov pixel, eax
                .IF (eax == crTransparent)
                    .BREAK
                .ENDIF
                inc ecx
                mov cont, ecx
            .ENDW
            mov edx, ecx ;salvo il pixel più a sinistra
            push edx
            .WHILE (ecx < bmp.bmWidth)
                push ecx
                push ebx
                Invoke GetPixel, hMemDC, ecx, ebx
                pop ebx
                pop ecx
                mov pixel, eax
                .IF (eax != crTransparent)
                    .BREAK
                .ENDIF
                inc ecx
                mov cont, ecx
            .ENDW
            mov eax, ebx
            inc eax
            pop edx
            ;dec edx
            push ecx
            inc ecx
            inc ecx
            Invoke CreateRectRgn, edx, ebx, ecx, eax
            pop ecx
            mov hRgnTmp, eax
            Invoke CombineRgn, hRegion, hRegion, hRgnTmp, RGN_DIFF
            .IF (eax == ERROR)
                ;Invoke MessageBox, NULL, ADDR Error, ADDR Error, MB_OK
            .ENDIF
            Invoke DeleteObject, hRgnTmp
            mov ecx, cont
        .ENDW
        mov ecx, 0
        inc ebx
    .ENDW
    
    Invoke GetRegionData, hRegion, 0, NULL ; Get region data size
    mov dwRegionDataSize, eax
    
    
    ;applico la Region alla finestra
    Invoke SetWindowRgn, hControl, hRegion, TRUE
    Invoke DeleteDC, hMemDC


    ret

MUIRegionButtonSetRegionBitmap ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonSetBrush - Sets a bitmap brush to use for painting background
;
; if lpBoundsRect is not NULL, calculates x and y BrushOrg based on
; control's window co-ords vs boundrect of region button collection which is
; calculated via MUIRegionButtonSetRegionPoly
;------------------------------------------------------------------------------
MUIRegionButtonSetBrush PROC USES EBX hControl:DWORD, hBrush:DWORD, lpBoundsRect:DWORD, dwBlendLevel:DWORD
    LOCAL x:DWORD
    LOCAL y:DWORD
    LOCAL nWidth:DWORD
    LOCAL nHeight:DWORD
    LOCAL rect:RECT
    LOCAL boundsrect:RECT

    .IF lpBoundsRect != 0
        Invoke CopyRect, Addr boundsrect, lpBoundsRect
        mov eax, boundsrect.right
        sub eax, boundsrect.left
        mov eax, nWidth
        mov eax, boundsrect.bottom
        sub eax, boundsrect.top
        mov eax, nHeight
        
        Invoke GetWindowRect, hControl, Addr rect
        mov eax, rect.left
        sub eax, boundsrect.left
        neg eax
        
        ;mov ebx, nWidth
        ;sub eax, ebx
        ;sub eax, 50
        mov x, eax
        mov eax, rect.top
        sub eax, boundsrect.top
        neg eax
;        mov eax, nHeight
;        sub eax, ebx
        mov y, eax
    .ELSE
        mov x, 0
        mov y, 0
    .ENDIF
    ;PrintDec x
    ;PrintDec y

    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrush, hBrush
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrushOrgX, x
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrushOrgY, y
    Invoke MUISetIntProperty, hControl, @RegionButtonBitmapBrushBlend, dwBlendLevel
    Invoke InvalidateRect, hControl, NULL, FALSE

    mov eax, TRUE
    ret
MUIRegionButtonSetBrush ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonPaint
;------------------------------------------------------------------------------
_MUI_RegionButtonPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:HBITMAP
    LOCAL hBitmap:HBITMAP
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
    Invoke MUIGetIntProperty, hWin, @RegionButtonEnabledState
    mov EnabledState, eax
    Invoke MUIGetIntProperty, hWin, @RegionButtonMouseOver
    mov MouseOver, eax
    Invoke MUIGetIntProperty, hWin, @RegionButtonSelectedState
    mov SelectedState, eax  

    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _MUI_RegionButtonPaintBackground, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Border
    ;----------------------------------------------------------
    Invoke _MUI_RegionButtonPaintBorder, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

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
_MUI_RegionButtonPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonPaintBackground - Paints the background of the control
;------------------------------------------------------------------------------
_MUI_RegionButtonPaintBackground PROC hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hBitmap:DWORD
    LOCAL dwXOrg:DWORD
    LOCAL dwYOrg:DWORD
    LOCAL dwBlend:DWORD
    LOCAL rect:RECT
    
    Invoke CopyRect, Addr rect, lpRect
    
    Invoke MUIGetIntProperty, hControl, @RegionButtonBitmapBrush
    mov hBitmap, eax
    Invoke MUIGetIntProperty, hControl, @RegionButtonBitmapBrushBlend
    mov dwBlend, eax
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                mov dwBlend, 0
                Invoke MUIGetExtProperty, hControl, @RegionButtonBackColor        ; Normal back color
            .ELSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBackColorAlt     ; Mouse over back color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBackColorSel     ; Selected back color
            .ELSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBackColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hControl, @RegionButtonBackColorDisabled        ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hControl, @RegionButtonBackColor                ; fallback to default Normal back color
    .ENDIF
    mov BackColor, eax
    
    .IF hBitmap != NULL

        Invoke MUIGetIntProperty, hControl, @RegionButtonBitmapBrushOrgX
        mov dwXOrg, eax
        Invoke MUIGetIntProperty, hControl, @RegionButtonBitmapBrushOrgY
        mov dwYOrg, eax
        
        mov eax, hBitmap
        ;Invoke CreatePatternBrush, hBitmap
        mov hBrush, eax
        Invoke SelectObject, hdc, hBrush
        mov hOldBrush, eax
        ;Invoke SetBrushOrgEx, hdc, 0, 0, 0; //Set the brush origin (relative placement)
        Invoke SetBrushOrgEx, hdc, dwXOrg, dwYOrg, 0; //Set the brush origin (relative placement)     
        Invoke FillRect, hdc, Addr rect, hBrush
        Invoke SetBrushOrgEx, hdc, 0, 0, 0; //Set the brush origin (relative placement)
        .IF hOldBrush != 0
            Invoke SelectObject, hdc, hOldBrush
            Invoke DeleteObject, hOldBrush
        .ENDIF

        .IF dwBlend > 0
            Invoke MUIGDIBlend, hControl, hdc, BackColor, dwBlend
        .ENDIF 
        
    .ELSE

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

    .ENDIF
    ret
_MUI_RegionButtonPaintBackground ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonPaintBorder - Paints the border surrounding the control
;------------------------------------------------------------------------------
_MUI_RegionButtonPaintBorder PROC PRIVATE hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BorderColor:DWORD
    LOCAL BorderSize:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hRgn:DWORD
    LOCAL rect:RECT

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderColor        ; Normal border color
            .ELSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderColorAlt     ; Mouse over border color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderColorSel     ; Selected border color
            .ELSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderColorSelAlt  ; Selected mouse over border color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hControl, @RegionButtonBorderColorDisabled        ; Disabled border color
    .ENDIF
    mov BorderColor, eax

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderSize
            .ELSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderSizeAlt
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderSizeSel
            .ELSE
                Invoke MUIGetExtProperty, hControl, @RegionButtonBorderSizeSelAlt
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hControl, @RegionButtonBorderSizeDisabled
    .ENDIF
    mov BorderSize, eax

    .IF sdword ptr BorderSize > 0
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdc, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdc, BorderColor
        Invoke MUIGetIntProperty, hControl, @RegionButtonRegionHandle
        mov hRgn, eax
        ;Invoke SetPolyFillMode, hdc, WINDING
        Invoke FrameRgn, hdc, hRgn, hBrush, BorderSize, BorderSize

        .IF hOldBrush != 0
            Invoke SelectObject, hdc, hOldBrush
            Invoke DeleteObject, hOldBrush
        .ENDIF     
        .IF hBrush != 0
            Invoke DeleteObject, hBrush
        .ENDIF

    .ENDIF
    ret
_MUI_RegionButtonPaintBorder ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonGetState - Returns in eax TRUE of FALSE if control is selected 
; or not
;------------------------------------------------------------------------------
MUIRegionButtonGetState PROC PUBLIC hControl:DWORD
    Invoke SendMessage, hControl, MUIRB_GETSTATE, 0, 0
    ret
MUIRegionButtonGetState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonSetState - Set control to selected state (TRUE) or not (FALSE)
;------------------------------------------------------------------------------
MUIRegionButtonSetState PROC PUBLIC hControl:DWORD, bState:DWORD
    Invoke SendMessage, hControl, MUIRB_SETSTATE, bState, 0
    ret
MUIRegionButtonSetState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_RegionButtonNotify - Notifies parent with WM_NOTIFY message
;------------------------------------------------------------------------------
_MUI_RegionButtonNotify PROC hControl:DWORD, dwNotifyMsg:DWORD
    LOCAL hParent:DWORD
    LOCAL idControl:DWORD
    
    LOCAL lParam:DWORD
    
    Invoke MUIGetExtProperty, hControl, @RegionButtonUserData
    mov lParam, eax
    
    Invoke GetParent, hControl
    mov hParent, eax

    mov eax, hControl
    mov RBNM.hdr.hwndFrom, eax
    mov eax, dwNotifyMsg
    mov RBNM.hdr.code, eax
    mov eax, lParam
    mov RBNM.lParam, eax
    
    Invoke GetDlgCtrlID, hControl
    mov idControl, eax

    .IF hParent != NULL
        Invoke PostMessage, hParent, WM_NOTIFY, idControl, Addr RBNM
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF    
    
    ret

_MUI_RegionButtonNotify ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ConvertTextToPoints - convert caption text to points to create a polygon
; Returns in eax pointer to points array and lpdwPoints will contain count of
; the points in the points array, or NULL and lpdwPoints will be 0
; if mismatch in coord points, then lpdwPoints will be -1
;
; Text can be in the following formats:
; 360.34 205.77 353.41 211.73 347.72 211.69
; 680 125, 671 127, 668 115
; <347,139>, <347,128>, <348,123>
;------------------------------------------------------------------------------
_MUI_ConvertTextToPoints PROC USES EBX EDI ESI hControl:DWORD, lpdwPoints:DWORD
    LOCAL dwLenText:DWORD
    LOCAL ptrText:DWORD
    LOCAL dwPoints:DWORD
    LOCAL ptrPoints:DWORD
    LOCAL dwCurrentPoint:DWORD
    LOCAL ptrCurrentPoint:DWORD
    LOCAL pos:DWORD
    LOCAL bNumbersFound:DWORD
    LOCAL bXorY:DWORD
    LOCAL szCoord[8]:BYTE
    LOCAL dwCoord:DWORD
    
    Invoke GetWindowTextLength, hControl
    .IF eax == 0
        mov ebx, lpdwPoints
        mov [ebx], eax
        ret
    .ENDIF
    add eax, 4
    mov dwLenText, eax
    
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, dwLenText
    .IF eax == NULL
        mov ebx, lpdwPoints
        mov [ebx], eax
        ret
    .ENDIF 
    mov ptrText, eax
    
    mov eax, dwLenText
    shl eax, 1 ; div by 2 - estimate of no of points required
    mov ebx, SIZEOF POINT
    mul ebx
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax == NULL
        mov ebx, lpdwPoints
        mov [ebx], eax
        ret
    .ENDIF
    mov ptrPoints, eax
    mov ptrCurrentPoint, eax

    Invoke GetWindowText, hControl, ptrText, dwLenText
    .IF eax == 0
        mov ebx, lpdwPoints
        mov [ebx], eax
        ret
    .ENDIF
    mov dwLenText, eax
    
    ; loop through text, get count of points
    mov bXorY, FALSE ; start with x = FALSE, y = TRUE, toggle each numbers found
    mov dwPoints, 0
    mov bNumbersFound, FALSE
    mov esi, ptrText
    lea edi, szCoord
    mov eax, 0
    mov pos, 0
    .WHILE eax <= dwLenText
        
        mov esi, ptrText
        add esi, pos
        
        movzx eax, byte ptr [esi]
        .IF al == 0
            .IF bNumbersFound == TRUE
                mov bNumbersFound, FALSE
                mov byte ptr [edi], 0
                Invoke atol, Addr szCoord
                mov dwCoord, eax
                .IF bXorY == FALSE ; x
                    mov ebx, ptrCurrentPoint
                    mov eax, dwCoord
                    mov [ebx].POINT.x, eax
                    mov bXorY, TRUE
                .ELSE ; y
                    mov ebx, ptrCurrentPoint
                    mov eax, dwCoord
                    mov [ebx].POINT.y, eax
                    mov bXorY, FALSE
                    inc dwPoints
                    add ptrCurrentPoint, SIZEOF POINT
                .ENDIF
            .ENDIF        
            .BREAK
            
        .ELSEIF al >= "0" && al <= "9"
            .IF bNumbersFound == FALSE
                mov bNumbersFound, TRUE
                lea edi, szCoord
            .ENDIF
            mov byte ptr [edi], al
            inc edi
            inc pos
            
        .ELSEIF al == '.' ; skip decimals
            inc esi
            inc pos
            movzx eax, byte ptr [esi]
            .WHILE al >= "0" && al <= "9" && al != 0
                inc esi
                inc pos
                movzx eax, byte ptr [esi]
            .ENDW
            .IF bNumbersFound == TRUE
                mov bNumbersFound, FALSE
                mov byte ptr [edi], 0
                Invoke atol, Addr szCoord
                mov dwCoord, eax
                .IF bXorY == FALSE ; x
                    mov ebx, ptrCurrentPoint
                    mov eax, dwCoord
                    mov [ebx].POINT.x, eax
                    mov bXorY, TRUE
                .ELSE ; y
                    mov ebx, ptrCurrentPoint
                    mov eax, dwCoord
                    mov [ebx].POINT.y, eax
                    mov bXorY, FALSE
                    inc dwPoints
                    add ptrCurrentPoint, SIZEOF POINT
                .ENDIF
            .ENDIF
        
        .ELSE ; skip all chars except no's
        
            .IF bNumbersFound == TRUE
                mov bNumbersFound, FALSE
                mov byte ptr [edi], 0
                Invoke atol, Addr szCoord
                mov dwCoord, eax
                .IF bXorY == FALSE ; x
                    mov ebx, ptrCurrentPoint
                    mov eax, dwCoord
                    mov [ebx].POINT.x, eax
                    mov bXorY, TRUE
                .ELSE ; y
                    mov ebx, ptrCurrentPoint
                    mov eax, dwCoord
                    mov [ebx].POINT.y, eax
                    mov bXorY, FALSE
                    inc dwPoints
                    add ptrCurrentPoint, SIZEOF POINT
                .ENDIF
            .ENDIF
            inc pos
            
        .ENDIF
        mov eax, pos
    .ENDW

    Invoke GlobalFree, ptrText
    
    mov eax, dwPoints
    and eax, 1
    .IF eax == 1 ; odd no, so missing a y coord somewhere
        Invoke GlobalFree, ptrPoints
        mov ebx, lpdwPoints
        mov eax, -1
        mov [ebx], eax
        mov eax, 0
        ret
    .ENDIF
    
    mov ebx, lpdwPoints
    mov eax, dwPoints
    mov [ebx], eax    
    mov eax, ptrPoints
    ret
_MUI_ConvertTextToPoints ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtomCustomStates
; Allocates the custom states array and copies data to it, and sets initial
; state to 0
;------------------------------------------------------------------------------
MUIRegionButtomCustomStates PROC USES EBX hControl:DWORD, lpCustomStatesArray:DWORD, dwTotalCustomStates:DWORD
    LOCAL ptrCustomStatesArray:DWORD
    LOCAL dwSizeArray:DWORD
    
    .IF hControl == NULL || lpCustomStatesArray == NULL || dwTotalCustomStates == 0
        mov eax, FALSE
        ret
    .ENDIF
    
    .IF dwTotalCustomStates >= MUIRB_MAX_CUSTOM_STATES
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @RegionButtonCustomStatesArray
    mov ptrCustomStatesArray, eax
    .IF ptrCustomStatesArray != 0
        Invoke GlobalFree, ptrCustomStatesArray
    .ENDIF
 
    mov eax, dwTotalCustomStates
    mov ebx, SIZEOF MUI_REGIONBUTTON_STATE
    mul ebx
    mov dwSizeArray, eax
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, dwSizeArray
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov ptrCustomStatesArray, eax    
    
    
    Invoke RtlMoveMemory, ptrCustomStatesArray, lpCustomStatesArray, dwSizeArray
    Invoke MUISetIntProperty, hControl, @RegionButtonCustomStatesArray, ptrCustomStatesArray
    Invoke MUISetIntProperty, hControl, @RegionButtonCustomStatesTotal, dwTotalCustomStates
    Invoke MUISetIntProperty, hControl, @RegionButtonCustomState, 0

    ret
MUIRegionButtomCustomStates ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonGetCustomState. Index or array or -1
;------------------------------------------------------------------------------
MUIRegionButtonGetCustomState PROC hControl:DWORD
    .IF hControl == NULL
        mov eax, -1
        ret
    .ENDIF
    Invoke MUIGetIntProperty, hControl, @RegionButtonCustomState
    ret
MUIRegionButtonGetCustomState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIRegionButtonSetCustomState. -1 or last state selected.
;------------------------------------------------------------------------------
MUIRegionButtonSetCustomState PROC hControl:DWORD, dwStateIndex:DWORD
    LOCAL dwCustomStatesTotal:DWORD
    .IF hControl == NULL
        mov eax, -1
        ret
    .ENDIF
    
    mov eax, dwStateIndex
    .IF eax >= MUIRB_MAX_CUSTOM_STATES
        mov eax, -1
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @RegionButtonCustomStatesTotal
    mov dwCustomStatesTotal, eax
    .IF eax > dwCustomStatesTotal 
        mov eax, -1
        ret
    .ENDIF
    Invoke MUISetIntProperty, hControl, @RegionButtonCustomState, dwStateIndex
    ret
MUIRegionButtonSetCustomState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CustomStateGetColor
;------------------------------------------------------------------------------
_MUI_CustomStateGetColor PROC USES EBX hControl:DWORD, dwStateIndex:DWORD, bAlt:DWORD
    LOCAL ptrCustomStatesArray:DWORD

    Invoke MUIGetIntProperty, hControl, @RegionButtonCustomStatesArray
    mov ptrCustomStatesArray, eax
    
    mov eax, dwStateIndex
    mov ebx, SIZEOF MUI_REGIONBUTTON_STATE
    mul ebx
    add eax, ptrCustomStatesArray
    mov ebx, eax

    .IF bAlt == FALSE
        mov eax, [ebx].MUI_REGIONBUTTON_STATE.dwColor
    .ELSE
        mov eax, [ebx].MUI_REGIONBUTTON_STATE.dwColorAlt
    .ENDIF
    ret
_MUI_CustomStateGetColor ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CustomStateGetBorderColor
;------------------------------------------------------------------------------
_MUI_CustomStateGetBorderColor PROC hControl:DWORD, dwStateIndex:DWORD, bAlt:DWORD
    LOCAL ptrCustomStatesArray:DWORD

    Invoke MUIGetIntProperty, hControl, @RegionButtonCustomStatesArray
    mov ptrCustomStatesArray, eax
    
    mov eax, dwStateIndex
    mov ebx, SIZEOF MUI_REGIONBUTTON_STATE
    mul ebx
    add eax, ptrCustomStatesArray
    mov ebx, eax

    .IF bAlt == FALSE
        mov eax, [ebx].MUI_REGIONBUTTON_STATE.dwBorderColor
    .ELSE
        mov eax, [ebx].MUI_REGIONBUTTON_STATE.dwBorderColorAlt
    .ENDIF
    ret
_MUI_CustomStateGetBorderColor ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CustomStateGetBorderSize
;------------------------------------------------------------------------------
_MUI_CustomStateGetBorderSize PROC hControl:DWORD, dwStateIndex:DWORD, bAlt:DWORD
    LOCAL ptrCustomStatesArray:DWORD

    Invoke MUIGetIntProperty, hControl, @RegionButtonCustomStatesArray
    mov ptrCustomStatesArray, eax
    
    mov eax, dwStateIndex
    mov ebx, SIZEOF MUI_REGIONBUTTON_STATE
    mul ebx
    add eax, ptrCustomStatesArray
    mov ebx, eax

    .IF bAlt == FALSE
        mov eax, [ebx].MUI_REGIONBUTTON_STATE.dwBorderSize
    .ELSE
        mov eax, [ebx].MUI_REGIONBUTTON_STATE.dwBorderSizeAlt
    .ENDIF
    ret
_MUI_CustomStateGetBorderSize ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CustomStateGetStateFlag
;------------------------------------------------------------------------------
_MUI_CustomStateGetStateFlag PROC hControl:DWORD, dwStateIndex:DWORD
    LOCAL ptrCustomStatesArray:DWORD

    Invoke MUIGetIntProperty, hControl, @RegionButtonCustomStatesArray
    mov ptrCustomStatesArray, eax
    
    mov eax, dwStateIndex
    mov ebx, SIZEOF MUI_REGIONBUTTON_STATE
    mul ebx
    add eax, ptrCustomStatesArray
    mov ebx, eax
    mov eax, [ebx].MUI_REGIONBUTTON_STATE.dwStateFlag    

    ret
_MUI_CustomStateGetStateFlag ENDP

MODERNUI_LIBEND










