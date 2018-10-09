;==============================================================================
;
; ModernUI Control - ModernUI_Tooltip
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
include comctl32.inc
include gdi32.inc
;include msimg32.inc
includelib kernel32.lib
includelib user32.lib
includelib comctl32.lib
includelib gdi32.lib
;includelib msimg32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_Tooltip.inc

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_TooltipWndProc                 PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TooltipInit                    PROTO :DWORD, :DWORD, :DWORD
_MUI_TooltipPaint                   PROTO :DWORD
_MUI_TooltipPaintBackground         PROTO :DWORD, :DWORD, :DWORD
_MUI_TooltipPaintText               PROTO :DWORD, :DWORD, :DWORD
_MUI_TooltipPaintTextAndTitle       PROTO :DWORD, :DWORD, :DWORD
_MUI_TooltipPaintBorder             PROTO :DWORD, :DWORD, :DWORD
_MUI_TooltipSize                    PROTO :DWORD, :DWORD, :DWORD
_MUI_TooltipSetPosition             PROTO :DWORD
_MUI_TooltipCheckWidthMultiline     PROTO :DWORD
_MUI_TooltipCheckTextMultiline      PROTO :DWORD, :DWORD
_MUI_TooltipParentSubclass          PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
MUI_TOOLTIP_PROPERTIES          STRUCT
    dwTooltipFont               DD ?
    dwTooltipTextColor          DD ?
    dwTooltipBackColor          DD ?
    dwTooltipBorderColor        DD ?
    dwTooltipShowDelay          DD ?
    dwTooltipShowTimeout        DD ?
    dwTooltipInfoTitleText      DD ?
    dwTooltipOffsetX            DD ?
    dwTooltipOffsetY            DD ?
MUI_TOOLTIP_PROPERTIES          ENDS

; Internal properties
_MUI_TOOLTIP_PROPERTIES         STRUCT
    dwTooltipHandle             DD ?
    dwMouseOver                 DD ?
    dwParent                    DD ?
    dwTooltipHoverTime          DD ?
    dwTooltipWidth              DD ?
    dwTooltipTitleFont          DD ?    
    dwMultiline                 DD ?
    dwPaddingWidth              DD ?
    dwPaddingHeight             DD ?
    dwTooltipTitleText          DD ?
_MUI_TOOLTIP_PROPERTIES         ENDS


.CONST
MUI_TOOLTIP_SHOW_DELAY          EQU 1000 ; default time to show tooltip (in ms)


; Internal properties
@TooltipHandle                  EQU 0   ; Used in subclass
@TooltipMouseOver               EQU 4   ; Used in subclass
@TooltipParent                  EQU 8   ; Used in subclass
@TooltipHoverTime               EQU 12  ; Used in subclass
@TooltipWidth                   EQU 16  ; User specified width of tooltip
@TooltipTitleFont               EQU 20  ; hFont for TitleText
@TooltipMultiline               EQU 24  ; If tooltip is multiline text
@TooltipPaddingWidth            EQU 28  ; Padding width based on font and text height
@TooltipPaddingHeight           EQU 32  ; Padding width based on font and text height
@TooltipTitleText               EQU 36  ; pointer to memory allocated for tooltip text title string

.DATA
ALIGN 4
szMUITooltipClass               DB 'ModernUI_Tooltip',0     ; Class name for creating our ModernUI_Tooltip control
szMUITooltipFont                DB 'Segoe UI',0             ; Font used for ModernUI_Tooltip
hMUITooltipFont                 DD 0                        ; handle of font for tooltip text (global)
hMUITooltipInfoTitleFont        DD 0                        ; handle of font for tooltip text title (global)

szMUITooltipText                DB 2048 DUP (0)             ; buffer for text (global)
dwFadeInAlphaLevel              DD 0                        ; alpha level (global)

.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_Tooltip control
;------------------------------------------------------------------------------
MUITooltipSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUITooltipSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_Tooltip control
;------------------------------------------------------------------------------
MUITooltipGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUITooltipGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUITooltipRegister - Registers the ModernUI_Tooltip control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Tooltip
;------------------------------------------------------------------------------
MUITooltipRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUITooltipClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUITooltipClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MUI_TooltipWndProc
    	mov wc.lpfnWndProc, eax 
    	invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, CS_SAVEBITS or CS_DROPSHADOW ;NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
        Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

MUITooltipRegister ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUITooltipCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUITooltipCreate PROC PRIVATE hWndBuddyControl:DWORD, lpszText:DWORD, dwWidth:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    .IF hWndBuddyControl == NULL
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUITooltipRegister
    
    mov eax, dwStyle
    mov dwNewStyle, eax
    or dwNewStyle, WS_CLIPSIBLINGS or WS_POPUP
    and dwNewStyle, (-1 xor WS_CHILD)

    Invoke CreateWindowEx, WS_EX_TOOLWINDOW, Addr szMUITooltipClass, lpszText, dwNewStyle, 0, 0, dwWidth, 0, hWndBuddyControl, NULL, hinstance, NULL
    mov hControl, eax
    ;PrintDec hControl
    .IF eax != NULL
        
    .ENDIF
    mov eax, hControl
    ret
MUITooltipCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_TooltipWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL rect:RECT
    LOCAL sz:POINT
    LOCAL hParent:DWORD
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        ; force style of our tooltip control to remove popup and add child
        Invoke GetWindowLong, hWin, GWL_STYLE
        or eax, WS_CHILD or WS_CLIPSIBLINGS
        and eax, (-1 xor WS_POPUP)
        Invoke SetWindowLong, hWin, GWL_STYLE, eax ;WS_CHILD or  WS_CLIPSIBLINGS ; WS_VISIBLE
        
        ; If fade in style flag is set we enable layered window for us to use transparency to fade in
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUITTS_FADEIN
        .IF eax == MUITTS_FADEIN
            Invoke GetWindowLong, hWin, GWL_EXSTYLE
            or eax, WS_EX_TOOLWINDOW or WS_EX_LAYERED
            Invoke SetWindowLong, hWin, GWL_EXSTYLE, eax
        .ENDIF
        
        ; set tooltip text
        mov ebx, lParam
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName   
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_TOOLTIP_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_TOOLTIP_PROPERTIES ; external properties
        mov ebx, lParam
        mov eax, (CREATESTRUCT PTR [ebx]).hWndParent
        mov ebx, (CREATESTRUCT PTR [ebx]).lpszName
        Invoke _MUI_TooltipInit, hWin, eax, ebx
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4
        mov eax, 0
        ret        
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_TooltipPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUISetIntProperty, hWin, @TooltipMouseOver, FALSE
        Invoke ShowWindow, hWin, FALSE

    .ELSEIF eax == WM_SETTEXT
        Invoke _MUI_TooltipCheckTextMultiline, hWin, lParam
        .IF eax == TRUE
            Invoke GetWindowLong, hWin, 0 ; check property structures where allocated
            .IF eax != 0
                Invoke _MUI_TooltipSize, hWin, TRUE, lParam
            .ENDIF
        .ELSE
            Invoke GetWindowLong, hWin, 0 ; check property structures where allocated
            .IF eax != 0
                Invoke _MUI_TooltipSize, hWin, FALSE, lParam
            .ENDIF
        .ENDIF
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret
        
    .ELSEIF eax == WM_SETFONT
        Invoke MUISetExtProperty, hWin, @TooltipFont, lParam
        .IF lParam == TRUE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF            
    
    .ELSEIF eax == WM_SHOWWINDOW
        .IF wParam == TRUE
            Invoke _MUI_TooltipSetPosition, hWin
            
            ; Check if fade in effect is to be shown
            Invoke GetWindowLong, hWin, GWL_STYLE
            and eax, MUITTS_FADEIN
            .IF eax == MUITTS_FADEIN            
                mov dwFadeInAlphaLevel, 0
                Invoke SetTimer, hWin, hWin, 10, NULL
            
            .ELSE
                Invoke GetWindowLong, hWin, GWL_STYLE
                and eax, MUITTS_TIMEOUT
                .IF eax == MUITTS_TIMEOUT
                    Invoke MUIGetExtProperty, hWin, @TooltipShowTimeout
                    .IF eax != 0
                        Invoke SetTimer, hWin, 1, eax, NULL
                    .ELSE ; set default timeout
                        Invoke GetDoubleClickTime
                        mov ebx, 10
                        mul ebx
                        Invoke SetTimer, hWin, 1, eax, NULL                    
                    .ENDIF
                .ENDIF
            .ENDIF    
            ;Invoke SetTimer, hWin, hWin, 200, NULL
        .ELSE
            ; Check if fade in effect is enabled, thus set to 0 transparency for hiding
            Invoke GetWindowLong, hWin, GWL_STYLE
            and eax, MUITTS_FADEIN
            .IF eax == MUITTS_FADEIN         
                mov dwFadeInAlphaLevel, 0
                Invoke SetLayeredWindowAttributes, hWin, 0, dwFadeInAlphaLevel, LWA_ALPHA
            .ENDIF
            
        .ENDIF
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_TIMER
        mov eax, wParam
        .IF eax == hWin
            ; fade in our tooltip window 
            .IF dwFadeInAlphaLevel >= 255d
                Invoke SetLayeredWindowAttributes, hWin, 0, 255d, LWA_ALPHA
                Invoke KillTimer, hWin, hWin
                
                Invoke GetWindowLong, hWin, GWL_STYLE
                and eax, MUITTS_TIMEOUT
                .IF eax == MUITTS_TIMEOUT
                    Invoke MUIGetExtProperty, hWin, @TooltipShowTimeout
                    .IF eax != 0
                        Invoke SetTimer, hWin, 1, eax, NULL
                    .ELSE ; set default timeout
                        Invoke GetDoubleClickTime
                        mov ebx, 10
                        mul ebx
                        Invoke SetTimer, hWin, 1, eax, NULL                    
                    .ENDIF
                .ENDIF
            .ELSE
                Invoke SetLayeredWindowAttributes, hWin, 0, dwFadeInAlphaLevel, LWA_ALPHA
                add dwFadeInAlphaLevel, 32d
            .ENDIF    

        .ELSEIF eax == 1
            Invoke ShowWindow, hWin, SW_HIDE
        .ENDIF
    
;    .ELSEIF eax == WM_TIMER
;        Invoke MUIGetIntProperty, hWin, @TooltipParent
;        mov hParent, eax
;        Invoke GetWindowRect, hParent, Addr rect
;        Invoke GetCursorPos, Addr sz
;        ;PrintDec sz.x
;        ;PrintDec sz.y
;        Invoke PtInRect, Addr rect, sz.x, sz.y
;        .IF eax == 0 ; not in rect
;            Invoke KillTimer, hWin, hWin
;            Invoke MUISetIntProperty, hWin, @TooltipMouseOver, FALSE
;            Invoke ShowWindow, hWin, FALSE
;        .ENDIF
    
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        Invoke MUISetExtProperty, hWin, wParam, lParam
        
        mov eax, wParam
        .IF eax == @TooltipShowDelay
            Invoke MUISetIntProperty, hWin, @TooltipHoverTime, lParam
        .ELSEIF eax == @TooltipInfoTitleText
            ;Invoke MUISetIntProperty, hWin, @TooltipMultiline, TRUE
            ; todo - change size of tooltip to reflect multine with title
            ;Invoke _MUI_TooltipSize, hControl, TRUE
            ;Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke GetWindowText, hWin, Addr szMUITooltipText, SIZEOF szMUITooltipText
            Invoke MUIGetIntProperty, hWin, @TooltipMultiline
            Invoke _MUI_TooltipSize, hWin, eax, Addr szMUITooltipText
            Invoke InvalidateRect, hWin, NULL, TRUE
            
        .ENDIF
        
        ret
        
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_TooltipWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipInit - set initial default values
;------------------------------------------------------------------------------
_MUI_TooltipInit PROC USES EBX hWin:DWORD, hWndParent:DWORD, lpszText:DWORD
    LOCAL ncm:NONCLIENTMETRICS
    LOCAL lfnt:LOGFONT
    LOCAL hFont:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwClassStyle:DWORD
    LOCAL dwShowDelay:DWORD
    LOCAL dwShowTimeout:DWORD

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, MUITTS_NODROPSHADOW
    .IF eax == MUITTS_NODROPSHADOW
        Invoke GetClassLong, hWin, GCL_STYLE
        mov dwClassStyle, eax
        and eax, CS_DROPSHADOW
        .IF eax == CS_DROPSHADOW
            and dwClassStyle,(-1 xor CS_DROPSHADOW)
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
        .ENDIF
    .ENDIF

    Invoke GetDoubleClickTime
    mov dwShowDelay, eax
    mov ebx, 10
    mul ebx
    mov dwShowTimeout, eax

    ; Set default initial internal property values  
    Invoke MUISetIntProperty, hWin, @TooltipHandle, hWin   
    Invoke MUISetIntProperty, hWin, @TooltipParent, hWndParent
    Invoke MUISetIntProperty, hWin, @TooltipHoverTime, dwShowDelay ;MUI_TOOLTIP_SHOW_DELAY

    ; Set default initial external property values 
    Invoke MUISetExtProperty, hWin, @TooltipTextColor, MUI_RGBCOLOR(51,51,51) ;MUI_RGBCOLOR(242,242,242) ; MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hWin, @TooltipBackColor, MUI_RGBCOLOR(242,241,208) ;MUI_RGBCOLOR(242,241,208) ;MUI_RGBCOLOR(25,25,25) ;MUI_RGBCOLOR(242,241,208)
    Invoke MUISetExtProperty, hWin, @TooltipBorderColor, MUI_RGBCOLOR(190,190,190) ;MUI_RGBCOLOR(0,0,0) ;MUI_RGBCOLOR(190,190,190)
    Invoke MUISetExtProperty, hWin, @TooltipShowDelay, dwShowDelay ;MUI_TOOLTIP_SHOW_DELAY
    Invoke MUISetExtProperty, hWin, @TooltipShowTimeout, dwShowTimeout
    Invoke MUISetExtProperty, hWin, @TooltipOffsetX, 0
    Invoke MUISetExtProperty, hWin, @TooltipOffsetY, 0

   .IF hMUITooltipFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hMUITooltipFont, eax
    .ENDIF
    Invoke MUISetExtProperty, hWin, @TooltipFont, hMUITooltipFont

    .IF hMUITooltipInfoTitleFont == 0
        Invoke GetObject, hMUITooltipFont, SIZEOF lfnt, Addr lfnt 
        mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUITooltipInfoTitleFont, eax
    .ENDIF
    Invoke MUISetIntProperty, hWin, @TooltipTitleFont, hMUITooltipInfoTitleFont
    
    Invoke MUISetIntProperty, hWin, @TooltipMouseOver, FALSE
    Invoke GetWindowLong, hWin, 0 ; pointer to internal properties structure
    Invoke SetWindowSubclass, hWndParent, Addr _MUI_TooltipParentSubclass, 1, eax  
    
    Invoke _MUI_TooltipCheckWidthMultiline, hWin
    .IF eax == FALSE
        Invoke _MUI_TooltipCheckTextMultiline, hWin, lpszText
    .ENDIF
    Invoke _MUI_TooltipSize, hWin, eax, lpszText

    ret
_MUI_TooltipInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipPaint
;------------------------------------------------------------------------------
_MUI_TooltipPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL lpszTitleText:DWORD

    Invoke IsWindowVisible, hWin
    .IF eax == 0
        ret
    .ENDIF

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
    Invoke MUIGetExtProperty, hWin, @TooltipInfoTitleText
    mov lpszTitleText, eax

    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _MUI_TooltipPaintBackground, hWin, hdcMem, Addr rect

    ;----------------------------------------------------------
    ; Border
    ;----------------------------------------------------------
    Invoke _MUI_TooltipPaintBorder, hWin, hdcMem, Addr rect

    ;----------------------------------------------------------
    ; Text
    ;----------------------------------------------------------
    .IF lpszTitleText == 0
        Invoke _MUI_TooltipPaintText, hWin, hdcMem, Addr rect
    .ELSE
        Invoke _MUI_TooltipPaintTextAndTitle, hWin, hdcMem, Addr rect
    .ENDIF

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
_MUI_TooltipPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipPaintBackground
;------------------------------------------------------------------------------
_MUI_TooltipPaintBackground PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL LogBrush:LOGBRUSH
    
    Invoke MUIGetExtProperty, hWin, @TooltipBackColor        ; Normal back color
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

_MUI_TooltipPaintBackground ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipPaintText
;------------------------------------------------------------------------------
_MUI_TooltipPaintText PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL LenText:DWORD    
    LOCAL dwTextStyle:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwPaddingWidth:DWORD
    LOCAL dwPaddingHeight:DWORD
    LOCAL rect:RECT
    LOCAL bMultiline:DWORD

    
    Invoke CopyRect, Addr rect, lpRect
    
    Invoke MUIGetExtProperty, hWin, @TooltipFont        
    mov hFont, eax
 
    Invoke MUIGetExtProperty, hWin, @TooltipBackColor        ; Normal back color
    mov BackColor, eax    

    Invoke MUIGetExtProperty, hWin, @TooltipTextColor        ; Normal text color
    mov TextColor, eax
    
    Invoke MUIGetIntProperty, hWin, @TooltipPaddingWidth
    mov dwPaddingWidth, eax
    
    Invoke MUIGetIntProperty, hWin, @TooltipPaddingHeight
    mov dwPaddingHeight, eax
    
    Invoke MUIGetIntProperty, hWin, @TooltipMultiline
    mov bMultiline, eax
    
    Invoke GetWindowText, hWin, Addr szMUITooltipText, SIZEOF szMUITooltipText
    .IF eax == 0
        ret
    .ENDIF
    ;Invoke lstrlen, Addr szText
    mov LenText, eax
    
    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax

    Invoke SetBkMode, hdc, OPAQUE
    Invoke SetBkColor, hdc, BackColor
    Invoke SetTextColor, hdc, TextColor

    mov eax, dwPaddingWidth
    shr eax, 1
    add rect.left, eax ;9d
    sub rect.right, eax
    
    mov eax, dwPaddingHeight
    shr eax, 1
    add rect.top, eax
    sub rect.bottom, eax

    .IF bMultiline == TRUE
        mov dwTextStyle, DT_LEFT or DT_WORDBREAK
    .ELSE
        mov dwTextStyle, DT_SINGLELINE or DT_LEFT or DT_VCENTER
    .ENDIF
    Invoke DrawText, hdc, Addr szMUITooltipText, LenText, Addr rect, dwTextStyle
    
    .IF hOldFont != 0
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
    
    ret
_MUI_TooltipPaintText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipPaintTextAndTitle
;------------------------------------------------------------------------------
_MUI_TooltipPaintTextAndTitle PROC PRIVATE USES EBX hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL hFont:DWORD
    LOCAL hTitleFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL LenText:DWORD    
    LOCAL dwTextStyle:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwPaddingWidth:DWORD
    LOCAL dwPaddingHeight:DWORD
    LOCAL rect:RECT
    LOCAL bMultiline:DWORD
    LOCAL sizetitletext:POINT
    LOCAL lpszTitleText:DWORD

    Invoke CopyRect, Addr rect, lpRect
    
    Invoke MUIGetExtProperty, hWin, @TooltipFont        
    mov hFont, eax
 
    Invoke MUIGetExtProperty, hWin, @TooltipBackColor        ; Normal back color
    mov BackColor, eax    

    Invoke MUIGetExtProperty, hWin, @TooltipTextColor        ; Normal text color
    mov TextColor, eax
    
    Invoke MUIGetIntProperty, hWin, @TooltipPaddingWidth
    mov dwPaddingWidth, eax
    
    Invoke MUIGetIntProperty, hWin, @TooltipPaddingHeight
    mov dwPaddingHeight, eax
    
    Invoke MUIGetIntProperty, hWin, @TooltipMultiline
    mov bMultiline, eax

    Invoke SetBkMode, hdc, OPAQUE
    Invoke SetBkColor, hdc, BackColor
    Invoke SetTextColor, hdc, TextColor

    mov eax, dwPaddingWidth
    shr eax, 1
    add rect.left, eax
    sub rect.right, eax

    ; Draw Title
    Invoke MUIGetExtProperty, hWin, @TooltipInfoTitleText
    mov lpszTitleText, eax
    .IF eax != 0
        Invoke lstrlen, lpszTitleText
        mov LenText, eax
        .IF eax != 0
        
            Invoke MUIGetIntProperty, hWin, @TooltipTitleFont
            mov hTitleFont, eax
        
            Invoke SelectObject, hdc, hTitleFont
            mov hOldFont, eax
            
            mov eax, dwPaddingHeight
            shr eax, 1
            add rect.top, eax            
            
            Invoke GetTextExtentPoint32, hdc, lpszTitleText, LenText, Addr sizetitletext
            mov ebx, dwPaddingHeight
            shr ebx, 1            
            add ebx, sizetitletext.y
            mov eax, rect.bottom
            sub eax, ebx
            sub rect.bottom, eax

            mov dwTextStyle, DT_SINGLELINE or DT_LEFT or DT_VCENTER
            Invoke DrawText, hdc, lpszTitleText, LenText, Addr rect, dwTextStyle        
    
            .IF hOldFont != 0
                Invoke SelectObject, hdc, hOldFont
                Invoke DeleteObject, hOldFont
            .ENDIF    
            
            ; adjust rect for drawing tooltip text now
            Invoke CopyRect, Addr rect, lpRect
            
            mov eax, dwPaddingWidth
            shr eax, 1
            add rect.left, eax
            sub rect.right, eax
            
            mov eax, dwPaddingHeight
            shr eax, 1
            add rect.top, eax            
            mov eax, sizetitletext.y
            add eax, 4
            add rect.top, eax            

        .ELSE
            mov eax, dwPaddingHeight
            shr eax, 1
            add rect.top, eax
            sub rect.bottom, eax        
        .ENDIF
    
    .ELSE
        mov eax, dwPaddingHeight
        shr eax, 1
        add rect.top, eax
        sub rect.bottom, eax
    .ENDIF
    
    ; Draw main tooltip text
    Invoke GetWindowText, hWin, Addr szMUITooltipText, SIZEOF szMUITooltipText
    .IF eax == 0
        ret
    .ENDIF
    ;Invoke lstrlen, Addr szText
    mov LenText, eax
    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax

    .IF bMultiline == TRUE
        mov dwTextStyle, DT_LEFT or DT_WORDBREAK
    .ELSE
        mov dwTextStyle, DT_SINGLELINE or DT_LEFT or DT_VCENTER
    .ENDIF
    Invoke DrawText, hdc, Addr szMUITooltipText, LenText, Addr rect, dwTextStyle
    
    .IF hOldFont != 0
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
    ret
_MUI_TooltipPaintTextAndTitle ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipPaintBorder
;------------------------------------------------------------------------------
_MUI_TooltipPaintBorder PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL BorderColor:DWORD
    LOCAL BorderStyle:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL rect:RECT
    
    Invoke MUIGetExtProperty, hWin, @TooltipBorderColor
    
    ;mov eax, MUI_RGBCOLOR(190,190,190)
    mov BorderColor, eax
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BorderColor
    Invoke FrameRect, hdc, lpRect, hBrush
    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF      
    
    ret

_MUI_TooltipPaintBorder ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipSize - sets the size of our tooltip control based on text and title
;------------------------------------------------------------------------------
_MUI_TooltipSize PROC PRIVATE USES EBX hWin:DWORD, bMultiline:DWORD, lpszText:DWORD
    LOCAL hdc:HDC
    LOCAL sizetext:POINT
    LOCAL sizetitletext:POINT
    LOCAL rect:RECT
    LOCAL FinalRect:RECT
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL LenText:DWORD
    LOCAL dwPaddingWidth:DWORD
    LOCAL dwPaddingHeight:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL lpszTitleText:DWORD
    
    ;PrintText '_MUI_TooltipSize'
    
    ;nvoke GetWindowText, hWin, Addr szText, SIZEOF szText
    .IF lpszText == 0
        ret
    .ENDIF    
    Invoke lstrlen, lpszText
    mov LenText, eax
    .IF eax == 0
        ret
    .ENDIF
    
    mov sizetitletext.x, 0
    mov sizetitletext.y, 0
    mov sizetext.x, 0
    mov sizetext.y, 0

    mov FinalRect.left,0
    mov FinalRect.top,0
    mov FinalRect.right,0
    mov FinalRect.bottom,0
    
    Invoke GetClientRect, hWin, Addr rect
    mov eax, rect.right
    mov dwWidth, eax
    ;PrintDec dwWidth
    
    Invoke GetDC, hWin
    mov hdc, eax
    
    ; Get title text height and width
    mov lpszTitleText, 0
    Invoke MUIGetExtProperty, hWin, @TooltipInfoTitleText
    .IF eax != 0
        mov lpszTitleText, eax
        Invoke lstrlen, lpszTitleText
        mov LenText, eax
        .IF eax != 0
            Invoke MUIGetIntProperty, hWin, @TooltipTitleFont
            mov hFont, eax
            .IF eax == 0
                Invoke MUIGetExtProperty, hWin, @TooltipFont
                mov hFont, eax
                .IF eax == 0
                    Invoke SendMessage, hWin, WM_GETFONT, 0, 0
                    mov hFont, eax
                .ENDIF
            .ENDIF
            Invoke SelectObject, hdc, hFont
            mov hOldFont, eax
            Invoke GetTextExtentPoint32, hdc, lpszTitleText, LenText, Addr sizetitletext
            .IF hOldFont != 0
                Invoke SelectObject, hdc, hOldFont
                Invoke DeleteObject, hOldFont
            .ENDIF                
        .ENDIF
    .ENDIF

    ; Get main text height and width
    Invoke lstrlen, lpszText
    mov LenText, eax    
    Invoke MUIGetExtProperty, hWin, @TooltipFont
    mov hFont, eax
    .IF eax == 0
        Invoke SendMessage, hWin, WM_GETFONT, 0, 0
        mov hFont, eax
    .ENDIF
    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax
    Invoke GetTextExtentPoint32, hdc, lpszText, LenText, Addr sizetext
    .IF hOldFont != 0
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF  

    ; calc final rect size
    
    mov eax, sizetext.y
    ;shr eax, 1
    and eax, 0FFFFFFFEh
    mov dwPaddingHeight, eax
    add eax, 4
    mov dwPaddingWidth, eax
    ;PrintDec dwPaddingWidth
    ;PrintDec dwPaddingHeight
    
    Invoke MUISetIntProperty, hWin, @TooltipPaddingWidth, dwPaddingWidth
    Invoke MUISetIntProperty, hWin, @TooltipPaddingHeight, dwPaddingHeight

    
    mov eax, dwWidth 
    .IF eax == 0 && bMultiline == FALSE ;sdword ptr eax > sizetext.x
        
        mov eax, sizetext.x
        .IF eax > sizetitletext.x
            mov eax, sizetext.x
        .ELSE
            mov eax, sizetitletext.x
        .ENDIF
        add eax, dwPaddingWidth
        mov dwWidth, eax

        mov eax, sizetext.y
        ;add eax, dwPadding
        add eax, dwPaddingHeight
        .IF lpszTitleText != 0
            add eax, sizetitletext.y
            add eax, 4
        .ENDIF
        mov dwHeight, eax
        
        
    .ELSEIF eax == 0 && bMultiline == TRUE
        ;PrintText 'dwWidth == 0 && bMultiline == TRUE'
;        mov eax, dwPaddingWidth
;        shr eax, 1
;        mov FinalRect.left, eax
;        
;        mov eax, dwPaddingHeight
;        shr eax, 1
;        mov FinalRect.top, eax
        
        mov eax, 250d
        ;sub eax, dwPaddingWidth
        mov FinalRect.right, eax
        mov FinalRect.bottom, 0
        
        Invoke DrawText, hdc, lpszText, LenText, Addr FinalRect, DT_CALCRECT or DT_WORDBREAK
        
;        mov eax, dwPaddingHeight
;        shr eax, 1
;        add eax, FinalRect.bottom
;        sub eax, 4
        mov dwHeight, eax

        mov eax, dwPaddingWidth
        shr eax, 1
        add eax, FinalRect.right
        mov dwWidth, eax
    
    .ELSEIF sdword ptr eax > 0 && bMultiline == FALSE
        mov eax, sizetext.x
        .IF eax > sizetitletext.x
            mov eax, sizetext.x
        .ELSE
            mov eax, sizetitletext.x
        .ENDIF
        add eax, dwPaddingWidth
        mov dwWidth, eax

        mov eax, sizetext.y
        add eax, dwPaddingHeight
        .IF lpszTitleText != 0
            add eax, sizetitletext.y
            add eax, 4
        .ENDIF
        mov dwHeight, eax
     
    .ELSEIF sdword ptr eax > 0 && bMultiline == TRUE
        ;PrintText 'dwWidth > 0 && bMultiline == TRUE'
    
;        mov eax, dwPaddingWidth
;        shr eax, 1
;        mov FinalRect.left, eax
;        
;        mov eax, dwPaddingHeight
;        shr eax, 1
;        .IF lpszTitleText != 0
;            add eax, sizetitletext.y
;            add eax, 4
;        .ENDIF
;        mov FinalRect.top, eax
;        
;        mov ebx, dwPaddingWidth
;        shr ebx, 1
        mov eax, dwWidth
;        sub eax, ebx
        mov FinalRect.right, eax
        mov FinalRect.bottom, 0
        
        Invoke DrawText, hdc, lpszText, LenText, Addr FinalRect, DT_CALCRECT or DT_WORDBREAK

        .IF lpszTitleText != 0
            add eax, sizetitletext.y
            add eax, 4
        .ENDIF
;        mov eax, dwPaddingHeight
;        shr eax, 1
;        add eax, FinalRect.bottom
;        sub eax, 4
        mov dwHeight, eax
        
        mov eax, dwPaddingWidth
        shr eax, 1
        add eax, FinalRect.right
        mov dwWidth, eax
    
    .ENDIF
    
    ;PrintDec dwWidth
    ;PrintDec dwHeight
    



    
    
    
    Invoke ReleaseDC, hWin, hdc
    
    ;mov eax, sz.x
    ;add eax, 18d
    ;mov rect.right, eax
    ;mov eax, sz.y
    ;add eax, 12d
    ;mov rect.bottom, eax
    
    ;Invoke SetWindowPos, hWin, HWND_TOP, 0, 0, rect.right, rect.bottom,  SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOZORDER or SWP_NOMOVE
    Invoke SetWindowPos, hWin, HWND_TOP, 0, 0, dwWidth, dwHeight,  SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOZORDER or SWP_NOMOVE
    
    
    ;.IF eax != 0 ; check WM_CREATE has set out property structures (otherwise call from WM_SETTEXT will crash)
        Invoke _MUI_TooltipSetPosition, hWin
    ;.ENDIF
    
    ret

_MUI_TooltipSize ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets position of the tooltip relative to buddy control or mouse position
;------------------------------------------------------------------------------
_MUI_TooltipSetPosition PROC USES EBX hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    LOCAL rect:RECT
    LOCAL tiprect:RECT
    LOCAL pt:POINT
    LOCAL dwPos:DWORD
    LOCAL dwOffsetX:DWORD
    LOCAL dwOffsetY:DWORD
    LOCAL hMonitor:DWORD
    LOCAL lpmi:MONITORINFOEX
    LOCAL workrect:RECT
    LOCAL bNegOffsetX:DWORD
    LOCAL bNegOffsetY:DWORD

    mov bNegOffsetX, FALSE
    mov bNegOffsetY, FALSE

    Invoke MUIGetIntProperty, hWin, @TooltipParent
    mov hParent, eax

    Invoke MUIGetExtProperty, hWin, @TooltipOffsetX
    mov dwOffsetX, eax
    Invoke MUIGetExtProperty, hWin, @TooltipOffsetY
    mov dwOffsetY, eax    

    Invoke MonitorFromWindow, hParent, MONITOR_DEFAULTTONEAREST
    mov hMonitor, eax
    mov lpmi.cbSize, SIZEOF MONITORINFOEX
    Invoke GetMonitorInfo, hMonitor, Addr lpmi
    Invoke CopyRect, Addr workrect, Addr lpmi.rcWork

    Invoke GetWindowRect, hParent, Addr rect
    Invoke GetClientRect, hWin, Addr tiprect

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    ;PrintDec dwStyle
    and eax, MUITTS_POS_RIGHT or MUITTS_POS_ABOVE or MUITTS_POS_LEFT or MUITTS_POS_MOUSE
    ;PrintDec eax
    mov dwPos, eax
;    .IF eax == 0 ; MUITTS_POS_BELOW
;        mov eax, rect.bottom
;        mov ebx, rect.top
;        sub eax, ebx
;        add eax, 2
;        add rect.top, eax
;        
;    .ELSEIF eax == MUITTS_POS_RIGHT
;        mov eax, rect.right
;        add eax, 2
;        mov rect.left, eax
;        
;    .ELSEIF eax == MUITTS_POS_ABOVE
;        mov eax, tiprect.bottom
;        ;mov ebx, tiprect.top
;        ;sub eax, ebx
;        add eax, 2
;        sub rect.top, eax
;    
;    .ELSEIF eax == MUITTS_POS_LEFT
;        mov eax, tiprect.right
;        ;mov ebx, tiprect.left
;        ;sub eax, ebx
;        add eax, 2
;        sub rect.left, eax
;    
;    .ELSEIF eax == MUITTS_POS_MOUSE
;        Invoke GetCursorPos, Addr pt
;        ;Invoke ScreenToClient, hParent, Addr pt
;        mov eax, pt.x
;        add eax, 8
;        mov rect.left, eax
;        mov eax, pt.y
;        add eax, 8
;        mov rect.top, eax
;    
;    .ELSE
;        ;PrintText 'Unknown Pos'
;    
;    .ENDIF

    ; check tip can be seen in placement in relation to workrect
    mov eax, dwPos
    .IF eax == MUITTS_POS_BELOW ; if bottom > workrect.bottom we swap to top
        mov eax, rect.top
        add eax, tiprect.bottom
        .IF eax > workrect.bottom
            mov eax, tiprect.bottom
            add eax, 2
            sub rect.top, eax
            mov bNegOffsetY, TRUE
        .ELSE
            mov eax, rect.bottom
            mov ebx, rect.top
            sub eax, ebx
            add eax, 2
            add rect.top, eax            
        .ENDIF

    .ELSEIF eax == MUITTS_POS_RIGHT ; if right > workrect.right we swap to left 
        mov eax, rect.left
        add eax, tiprect.right
        .IF eax > workrect.right
            mov eax, tiprect.right
            add eax, 2
            sub rect.left, eax
            mov bNegOffsetX, TRUE
        .ELSE
            mov eax, rect.right
            add eax, 2
            mov rect.left, eax        
        .ENDIF

    .ELSEIF eax == MUITTS_POS_LEFT ; if left < 0 we swap to right
        mov eax, rect.left
        sub eax, tiprect.right
        .IF sdword ptr eax < 0
            mov eax, rect.right
            add eax, 2
            mov rect.left, eax
            mov bNegOffsetX, TRUE
        .ELSE
            mov eax, tiprect.right
            add eax, 2
            sub rect.left, eax
        .ENDIF

    .ELSEIF eax == MUITTS_POS_ABOVE ; if top < 0 we swap to bottom
        mov eax, rect.top
        sub eax, tiprect.bottom
        .IF sdword ptr eax < 0
            mov eax, rect.bottom
            mov ebx, rect.top
            sub eax, ebx
            add eax, 2
            add rect.top, eax
            mov bNegOffsetY, TRUE
        .ELSE
            mov eax, tiprect.bottom
            add eax, 2
            sub rect.top, eax
        .ENDIF

    .ELSEIF eax == MUITTS_POS_MOUSE ; check all
        Invoke GetCursorPos, Addr pt
        ;Invoke ScreenToClient, hParent, Addr pt
        mov eax, pt.x
        add eax, 8
        add eax, tiprect.right
        .IF eax > workrect.right
            mov eax, pt.x
            sub eax, 8
            sub eax, tiprect.right
            mov rect.left, eax
            mov bNegOffsetX, TRUE
        .ELSE
            mov eax, pt.x
            add eax, 8
            mov rect.left, eax
        .ENDIF

        mov eax, pt.y
        add eax, 8
        add eax, tiprect.bottom
        .IF eax > workrect.bottom
            mov eax, pt.y
            sub eax, 8
            sub eax, tiprect.bottom
            mov rect.top, eax
            mov bNegOffsetY, TRUE
        .ELSE
            mov eax, pt.y
            add eax, 8
            mov rect.top, eax
        .ENDIF

    .ENDIF
    
    .IF dwOffsetX != 0
        mov eax, rect.left
        .IF bNegOffsetX == TRUE
            sub eax, dwOffsetX
        .ELSE
            add eax, dwOffsetX
        .ENDIF
        mov rect.left, eax
    .ENDIF
    .IF dwOffsetY != 0
        mov eax, rect.top
        .IF bNegOffsetY == TRUE
            sub eax, dwOffsetY
        .ELSE
            add eax, dwOffsetY
        .ENDIF
        mov rect.top, eax
    .ENDIF

    Invoke SetWindowPos, hWin, HWND_TOP, rect.left, rect.top, 0, 0,  SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOZORDER or SWP_NOSIZE
    ret
_MUI_TooltipSetPosition ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Returns TRUE if width > 0 (assumes multiline usage)
;------------------------------------------------------------------------------
_MUI_TooltipCheckWidthMultiline PROC USES EBX hWin:DWORD
    LOCAL rect:RECT
    LOCAL bMultiline:DWORD

    mov bMultiline, FALSE
    Invoke GetClientRect, hWin, Addr rect
    mov eax, rect.right
    .IF eax != 0 
        Invoke MUISetIntProperty, hWin, @TooltipMultiline, TRUE
        mov bMultiline, TRUE
    .ENDIF
    mov eax, bMultiline
    ret
_MUI_TooltipCheckWidthMultiline ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Returns TRUE if CR LF found in string, otherwise returns FALSE
;------------------------------------------------------------------------------
_MUI_TooltipCheckTextMultiline PROC USES EBX hWin:DWORD, lpszText:DWORD
    LOCAL lenText:DWORD
    LOCAL Cnt:DWORD
    LOCAL bMultiline:DWORD

    .IF lpszText == 0
        ret
    .ENDIF
    Invoke lstrlen, lpszText
    mov lenText, eax

    mov bMultiline, FALSE
    mov ebx, lpszText
    mov Cnt, 0
    mov eax, 0
    .WHILE eax < lenText
        movzx eax, byte ptr [ebx]
        .IF al == 0
            mov bMultiline, FALSE
            .BREAK
        .ELSEIF al == 10 || al == 13
            Invoke MUISetIntProperty, hWin, @TooltipMultiline, TRUE
            mov bMultiline, TRUE
            .BREAK 
        .ENDIF
        inc ebx
        inc Cnt
        mov eax, Cnt
    .ENDW
    mov eax, bMultiline
    ret
_MUI_TooltipCheckTextMultiline ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_TooltipParentSubclass - sublcass buddy/parent of the tooltip
;------------------------------------------------------------------------------
_MUI_TooltipParentSubclass PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL TE:TRACKMOUSEEVENT

    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Addr _MUI_TooltipParentSubclass, uIdSubclass
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam 
        ret

    .ELSEIF eax == WM_MOUSEMOVE
        mov ebx, dwRefData
        mov eax, (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwMouseOver
        .IF eax == FALSE
            mov eax, TRUE
            mov (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwMouseOver, eax
            mov eax, (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwTooltipHandle
            ;Invoke ShowWindow, eax, TRUE
            ;Invoke AnimateWindow, eax, 200, AW_BLEND
            mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
            mov TE.dwFlags, TME_LEAVE or TME_HOVER
            mov eax, hWin
            mov TE.hwndTrack, eax
            mov eax, (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwTooltipHoverTime
            mov TE.dwHoverTime, eax;HOVER_DEFAULT ;NULL
            Invoke TrackMouseEvent, Addr TE
        .ENDIF

    .ELSEIF eax == WM_MOUSEHOVER
        mov ebx, dwRefData
        mov eax, (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwMouseOver

        .IF eax == TRUE
            mov eax, TRUE
            mov (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwMouseOver, eax
            mov eax, (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwTooltipHandle
            Invoke ShowWindow, eax, TRUE
            ;Invoke AnimateWindow, eax, 200, AW_BLEND
            mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
            mov TE.dwFlags, TME_LEAVE
            mov eax, hWin
            mov TE.hwndTrack, eax
            mov TE.dwHoverTime, HOVER_DEFAULT ;NULL
            Invoke TrackMouseEvent, Addr TE
        .ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        mov ebx, dwRefData
        mov eax, (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwTooltipHandle
        Invoke ShowWindow, eax, FALSE
        ;Invoke AnimateWindow, eax, 200, AW_BLEND or AW_HIDE
        mov eax, FALSE
        mov (_MUI_TOOLTIP_PROPERTIES ptr [ebx]).dwMouseOver, eax        

    .ENDIF
    Invoke DefSubclassProc, hWin, uMsg, wParam, lParam         
    ret
_MUI_TooltipParentSubclass ENDP

























END
