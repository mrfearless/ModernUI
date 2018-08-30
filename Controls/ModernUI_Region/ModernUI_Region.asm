;==============================================================================
;
; ModernUI Control - ModernUI_Region
;
; Copyright (c) 2018 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
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
;include uxtheme.inc
;includelib uxtheme.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_Region.inc

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_ButtonButtonWndProc                PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_RegionButtonInit                   PROTO :DWORD
_MUI_RegionButtonPaint                  PROTO :DWORD
_MUI_RegionButtonPaintBackground        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_RegionButtonPaintBorder            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_RegionButtonNotify                 PROTO :DWORD, :DWORD

;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
IFNDEF MUI_REGIONBUTTON_PROPERTIES
MUI_REGIONBUTTON_PROPERTIES             STRUCT
    dwBackColor                         DD ? 
    dwBackColorAlt                      DD ? 
    dwBackColorSel                      DD ? 
    dwBackColorSelAlt                   DD ? 
    dwBackColorDisabled                 DD ?
    dwBorderColor                       DD ? 
    dwBorderColorAlt                    DD ? 
    dwBorderColorSel                    DD ? 
    dwBorderColorSelAlt                 DD ? 
    dwBorderColorDisabled               DD ? 
    dwBorderStyle                       DD ?
    dwUserData                          DD ?                            
MUI_REGIONBUTTON_PROPERTIES             ENDS
ENDIF

; Internal properties
_MUI_REGIONBUTTON_PROPERTIES            STRUCT
    dwEnabledState                      DD ?
    dwMouseOver                         DD ?
    dwSelectedState                     DD ?
    dwMouseDown                         DD ?
    dwRegionHandle                      DD ?
_MUI_REGIONBUTTON_PROPERTIES            ENDS


IFNDEF MUIRB_NOTIFY                     ; Notification Message Structure for RegionButton
MUIRB_NOTIFY                            STRUCT
    hdr                                 NMHDR <0,0,0>
    lParam                              DD 0
MUIRB_NOTIFY                            ENDS
ENDIF


.CONST
; Internal properties
@RegionButtonEnabledState               EQU 0
@RegionButtonMouseOver                  EQU 4
@RegionButtonSelectedState              EQU 8
@RegionButtonMouseDown                  EQU 12
@RegionButtonRegionHandle               EQU 16
; move RBNM to internal var alloced mem at start


; External public properties


.DATA
ALIGN 4
szMUIRegionButtonClass                  DB 'ModernUI_RegionButton',0    ; Class name for creating our ModernUI_RegionButton control
RBNM                                    MUIRB_NOTIFY <>


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
        mov eax, DLGC_WANTARROWS ;DLGC_WANTALLKEYS ;DLGC_WANTMESSAGE or 
        ret

    .ELSEIF eax == WM_KEYDOWN
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
            .IF eax == VK_UP || eax == VK_DOWN || eax == VK_LEFT || eax == VK_RIGHT
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


;    .ELSEIF eax == WM_MOVE
;        Invoke GetParent, hWin
;        mov hParent, eax
;        Invoke GetWindowRect, hWin, Addr rect
;        Invoke MapWindowPoints, HWND_DESKTOP, hParent, Addr rect, 2
;        mov eax, rect.left
;        mov xPos, eax
;        mov eax, rect.top
;        mov yPos, eax
;        mov eax, 0
;       ;PrintDec xPos
;       ;PrintDec yPos
        

    .ELSEIF eax == WM_LBUTTONUP
        ; simulates click on our control, delete if not required.
        Invoke GetDlgCtrlID, hWin
        mov ebx,eax
        Invoke GetParent, hWin
        Invoke PostMessage, eax, WM_COMMAND, ebx, hWin
        Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_CLICKED
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
                Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER  + SWP_FRAMECHANGED
                Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, FALSE
            .ELSE
                Invoke InvalidateRect, hWin, NULL, TRUE
                Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
            .ENDIF
        .ELSE
            Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, FALSE
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        .ENDIF
        
    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, TRUE
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIRB_PUSHBUTTON
        .IF eax == MUIRB_PUSHBUTTON
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax
            invoke MapWindowPoints, hWin, hParent, addr rect, 2        
            add rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @RegionButtonMouseDown, TRUE
        .ELSE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        .ENDIF
        

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
                Invoke _MUI_RegionButtonNotify, hWin, MUIRBN_MOUSEOVER
                Invoke InvalidateRect, hWin, NULL, TRUE
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
                Invoke InvalidateRect, hWin, NULL, FALSE
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
        Invoke MUIRegionButtonSetBitmap, hWin, wParam
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

    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColor, MUI_RGBCOLOR(1,1,1)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorAlt, MUI_RGBCOLOR(39,168,205)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorSel, MUI_RGBCOLOR(128,128,128)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorSelAlt, MUI_RGBCOLOR(140,140,140)
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderColorDisabled, MUI_RGBCOLOR(204,204,204)
    
    Invoke MUISetExtProperty, hControl, @RegionButtonBorderSize, 0   
    Invoke MUISetIntProperty, hControl, @RegionButtonRegionHandle, 0


;    Invoke ExtCreateRegion, NULL, REGION_CENTRAL_AFRICA_DATA_SIZE, Addr REGION_CENTRAL_AFRICA_DATA
;    mov hRgn, eax
;    .IF eax == NULL
;        PrintText 'ExtCreateRegion Failed'
;    .ENDIF
;    Invoke GetRgnBox, hRgn, Addr rect
;    inc rect.right
;    Invoke SetWindowPos, hControl, NULL, 0, 0, rect.right, rect.bottom, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING  or SWP_NOMOVE ;SWP_NOCOPYBITS    or SWP_NOREDRAW
;    Invoke SetWindowRgn, hControl, hRgn, TRUE
;    
;    Invoke ExtCreateRegion, NULL, REGION_CENTRAL_AFRICA_DATA_SIZE, Addr REGION_CENTRAL_AFRICA_DATA
;    mov hRegionHandle, eax
;    
;    Invoke MUISetIntProperty, hControl, @RegionButtonRegionHandle, hRegionHandle
;    
;    
;    PrintDec rect.right
;    PrintDec rect.bottom
;    PrintDec hRgn
;    PrintDec hRegionHandle
    
    

    ret

_MUI_RegionButtonInit ENDP


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
; MUIRegionButtonSetBitmap - Sets region of control based on bitmap passed to it
;------------------------------------------------------------------------------
MUIRegionButtonSetBitmap PROC PUBLIC USES EBX ECX EDX hControl:DWORD, hBitmap:DWORD
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

MUIRegionButtonSetBitmap ENDP


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
_MUI_RegionButtonPaintBackground PROC PRIVATE hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
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


    Invoke MUIGetExtProperty, hControl, @RegionButtonBorderSize
    mov BorderSize, eax

    .IF sdword ptr BorderSize > 0
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdc, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdc, BorderColor
        Invoke MUIGetIntProperty, hControl, @RegionButtonRegionHandle
        mov hRgn, eax
        Invoke FrameRgn, hdc, hRgn, hBrush, BorderSize, BorderSize
        .IF eax == 0
            ;PrintText 'FrameRgn failed'
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








END
