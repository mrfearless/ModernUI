;======================================================================================================================================
;
; ModernUI Control - ModernUI_Text v1.0.0.0
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

include ModernUI_Text.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_TextWndProc                PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TextInit                   PROTO :DWORD
_MUI_TextPaint                  PROTO :DWORD
_MUI_TextPaintBackground        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TextPaintText              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TextCheckMultiline         PROTO :DWORD, :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; External public properties
MUI_TEXT_PROPERTIES             STRUCT
    dwTextFont                  DD ?
    dwTextColor                 DD ?
    dwTextColorAlt              DD ?
    dwTextColorDisabled         DD ?
    dwTextBackColor             DD ?
    dwTextBackColorAlt          DD ?
    dwTextBackColorDisabled     DD ?
MUI_TEXT_PROPERTIES             ENDS

; Internal properties
_MUI_TEXT_PROPERTIES            STRUCT
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
_MUI_TEXT_PROPERTIES            ENDS


.CONST
; Internal properties
@TextEnabledState               EQU 0
@TextMouseOver                  EQU 4

; External public properties


.DATA
szLorumIpsumText                DB "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. " 
                                DB "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. " 
                                DB "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. " 
                                DB "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",0
                                
szMUITextClass                  DB 'ModernUI_Text',0    ; Class name for creating our ModernUI_Text control
szMUITextFont                   DB 'Segoe UI',0                ; Font used for ModernUI_Text text

MUITextFont                     DD 0

szMUITextFontSegoe              DB 'Segoe UI',0 
szMUITextFontTahoma             DB 'Tahoma',0
szMUITextFontSans               DB 'MS Sans Serif',0
szMUITextFontArial              DB 'Arial',0
szMUITextFontTimes              DB 'Times New Roman',0
szMUITextFontCourier            DB 'Courier New',0
szMUITextFontVerdana            DB 'Verdana',0





;hMUITextFontDefault             DD 0                           ; Handle to ModernUI_Text font (segoe ui)
;hMUITextFontHeader              DD 0  ; 46px
;hMUITextFontSubHeader           DD 0  ; 34px
;hMUITextFontTitle               DD 0  ; 24px
;hMUITextFontSubTitle            DD 0  ; 20px
;hMUITextFontBodyTitle           DD 0  ; 15px
;hMUITextFontBody                DD 0  ; 15px
;hMUITextFontCaption             DD 0  ; 12px


.CODE
;-------------------------------------------------------------------------------------
; Set property for ModernUI_Text control
;-------------------------------------------------------------------------------------
MUITextSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUITextSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for ModernUI_Text control
;-------------------------------------------------------------------------------------
MUITextGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUITextGetProperty ENDP


;-------------------------------------------------------------------------------------
; MUITextRegister - Registers the ModernUI_Text control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Text
;-------------------------------------------------------------------------------------
MUITextRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUITextClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUITextClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MUI_TextWndProc
    	mov wc.lpfnWndProc, eax 
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

MUITextRegister ENDP


;-------------------------------------------------------------------------------------
; MUITextCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUITextCreate PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUITextRegister
    
    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
    
    Invoke CreateWindowEx, NULL, Addr szMUITextClass, lpszText, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        
    .ENDIF
    mov eax, hControl
    ret
MUITextCreate ENDP



;-------------------------------------------------------------------------------------
; _MUI_TextWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_TextWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        ; sets text of our control, delete if not required.
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName   
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_TEXT_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_TEXT_PROPERTIES ; external properties
        Invoke _MUI_TextInit, hWin
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
        Invoke _MUI_TextPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUITS_HAND
        .IF eax == MUITS_HAND
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
        Invoke MUIGetIntProperty, hWin, @TextEnabledState
        .IF eax == TRUE   
            Invoke MUISetIntProperty, hWin, @TextMouseOver, TRUE
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
        Invoke MUISetIntProperty, hWin, @TextMouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @TextMouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_ENABLE
        Invoke MUISetIntProperty, hWin, @TextEnabledState, wParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov eax, 0

    .ELSEIF eax == WM_SETTEXT
        Invoke _MUI_TextCheckMultiline, hWin, lParam
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret
        
    .ELSEIF eax == WM_SETFONT
        Invoke MUISetExtProperty, hWin, @TextFont, lParam
        .IF lParam == TRUE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF            
    
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        Invoke MUISetExtProperty, hWin, wParam, lParam
        ret
        
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_TextWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_TextInit PROC PRIVATE hControl:DWORD
    LOCAL lfnt:LOGFONT
    LOCAL hFont:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwFontSize:DWORD
    LOCAL dwFontFamily:DWORD
    LOCAL dwFontHeight:DWORD
    LOCAL dwFontWeight:DWORD
    
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
     
    ; Set default initial external property values  
    Invoke MUISetIntProperty, hControl, @TextEnabledState, TRUE   
    Invoke MUISetExtProperty, hControl, @TextColor, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hControl, @TextColorAlt, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hControl, @TextColorDisabled, MUI_RGBCOLOR(204,204,204)
    Invoke MUISetExtProperty, hControl, @TextBackColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hControl, @TextBackColorAlt, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hControl, @TextBackColorDisabled, MUI_RGBCOLOR(192,192,192)
    
    mov eax, dwStyle
    and eax, 0F0h
    mov dwFontFamily, eax
 
    .IF eax == MUITS_FONT_SEGOE
        lea eax, szMUITextFontSegoe
    .ELSEIF eax == MUITS_FONT_TAHOMA
        lea eax, szMUITextFontTahoma
    .ELSEIF eax == MUITS_FONT_SANS
        lea eax, szMUITextFontSans
    .ELSEIF eax == MUITS_FONT_ARIAL
        lea eax, szMUITextFontArial
    .ELSEIF eax == MUITS_FONT_TIMES
        lea eax, szMUITextFontTimes
    .ELSEIF eax == MUITS_FONT_COURIER
        lea eax, szMUITextFontCourier
    .ELSEIF eax == MUITS_FONT_VERDANA    
        lea eax, szMUITextFontVerdana
    .ELSE
        lea eax, szMUITextFontSegoe
    .ENDIF
    mov MUITextFont, eax
    
    mov eax, dwStyle
    and eax, 15d
    mov dwFontSize, eax

    .IF eax == MUITS_DEFAULT ; 8px
        Invoke MUIPointSizeToLogicalUnit, hControl, 8
        mov dwFontHeight, eax
        mov dwFontWeight, FW_NORMAL

    .ELSEIF eax == MUITS_HEADER ; 46px
        Invoke MUIPointSizeToLogicalUnit, hControl, 46d
        mov dwFontHeight, eax
        mov dwFontWeight, FW_BOLD

    .ELSEIF eax == MUITS_SUBHEADER ; 34px
        Invoke MUIPointSizeToLogicalUnit, hControl, 34d
        mov dwFontHeight, eax
        mov dwFontWeight, FW_SEMIBOLD

    .ELSEIF eax == MUITS_TITLE; 24px
        Invoke MUIPointSizeToLogicalUnit, hControl, 24d
        mov dwFontHeight, eax
        mov dwFontWeight, FW_MEDIUM

    .ELSEIF eax == MUITS_SUBTITLE; 20px
        Invoke MUIPointSizeToLogicalUnit, hControl, 20d
        mov dwFontHeight, eax
        mov dwFontWeight, FW_NORMAL

    .ELSEIF eax == MUITS_BODYTITLE; 15px
        Invoke MUIPointSizeToLogicalUnit, hControl, 15d
        mov dwFontHeight, eax
        mov dwFontWeight, FW_SEMIBOLD
        
    .ELSEIF eax == MUITS_BODY ; 15px
        Invoke MUIPointSizeToLogicalUnit, hControl, 15d
        mov dwFontHeight, eax
        mov dwFontWeight, FW_NORMAL
        
    .ELSEIF eax == MUITS_CAPTION ; 12px
        Invoke MUIPointSizeToLogicalUnit, hControl, 12d
        mov dwFontHeight, eax
        mov dwFontWeight, FW_NORMAL
    
    .ELSE
        Invoke MUIPointSizeToLogicalUnit, hControl, 8
        mov dwFontHeight, eax
        mov dwFontWeight, FW_NORMAL
    
    .ENDIF
    
    Invoke CreateFont, dwFontHeight, 0,0,0, dwFontWeight, 0,0,0,0,0,0, PROOF_QUALITY, FF_SWISS, MUITextFont
    mov hFont, eax
    Invoke MUISetExtProperty, hControl, @TextFont, hFont
    ret

_MUI_TextInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextPaint
;-------------------------------------------------------------------------------------
_MUI_TextPaint PROC PRIVATE hWin:DWORD
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
    Invoke MUIGetIntProperty, hWin, @TextEnabledState
    mov EnabledState, eax
    Invoke MUIGetIntProperty, hWin, @TextMouseOver
    mov MouseOver, eax
    
    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _MUI_TextPaintBackground, hWin, hdcMem, Addr rect, EnabledState, MouseOver

    ;----------------------------------------------------------
    ; Text
    ;----------------------------------------------------------
    Invoke _MUI_TextPaintText, hWin, hdcMem, Addr rect, EnabledState, MouseOver

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
_MUI_TextPaint ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextPaintBackground
;-------------------------------------------------------------------------------------
_MUI_TextPaintBackground PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL LogBrush:LOGBRUSH
    
    .IF bEnabledState == TRUE
        .IF bMouseOver == FALSE
            Invoke MUIGetExtProperty, hWin, @TextBackColor        ; Normal back color
        .ELSE
            Invoke MUIGetExtProperty, hWin, @TextBackColorAlt     ; Mouse over back color
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @TextBackColorDisabled        ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @TextBackColor                ; fallback to default Normal back color
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

_MUI_TextPaintBackground ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextPaintText
;-------------------------------------------------------------------------------------
_MUI_TextPaintText PROC PRIVATE USES EBX hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    ;LOCAL hBrush:DWORD
    ;LOCAL hOldBrush:DWORD    
    LOCAL LenText:DWORD    
    LOCAL dwTextStyle:DWORD
    LOCAL dwStyle:DWORD
    LOCAL rect:RECT
    LOCAL szText[2048]:BYTE
    
    Invoke CopyRect, Addr rect, lpRect

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    Invoke MUIGetExtProperty, hWin, @TextFont        
    mov hFont, eax

    .IF bEnabledState == TRUE
        .IF bMouseOver == FALSE
            Invoke MUIGetExtProperty, hWin, @TextBackColor        ; Normal back color
        .ELSE
            Invoke MUIGetExtProperty, hWin, @TextBackColorAlt     ; Mouse over back color
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @TextBackColorDisabled        ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @TextBackColor                ; fallback to default Normal back color
    .ENDIF    
    mov BackColor, eax    

    .IF bEnabledState == TRUE
        .IF bMouseOver == FALSE
            Invoke MUIGetExtProperty, hWin, @TextColor        ; Normal text color
        .ELSE
            Invoke MUIGetExtProperty, hWin, @TextColorAlt     ; Mouse over text color
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @TextColorDisabled        ; Disabled text color
    .ENDIF
    .IF eax == 0 ; try to get default text color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @TextColor                ; fallback to default Normal text color
    .ENDIF  
    mov TextColor, eax
    
    Invoke GetWindowText, hWin, Addr szText, SIZEOF szText
    
    Invoke lstrlen, Addr szText
    mov LenText, eax
    
    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax

    Invoke SetBkMode, hdc, OPAQUE
    Invoke SetBkColor, hdc, BackColor
    Invoke SetTextColor, hdc, TextColor

    mov eax, dwStyle
    and eax, MUITS_SINGLELINE
    .IF eax == MUITS_SINGLELINE
        mov dwTextStyle, DT_SINGLELINE
    .ELSE
        mov dwTextStyle, DT_WORDBREAK or DT_EDITCONTROL
    .ENDIF
    mov eax, dwStyle
    and eax, (MUITS_ALIGN_CENTER or MUITS_ALIGN_RIGHT)
    .IF eax == MUITS_ALIGN_CENTER
        or dwTextStyle, DT_CENTER
    .ELSEIF eax == MUITS_ALIGN_RIGHT
        or dwTextStyle, DT_RIGHT
    .ELSE
        or dwTextStyle, DT_LEFT
    .ENDIF

    Invoke DrawText, hdc, Addr szText, LenText, Addr rect, dwTextStyle
    
    .IF hOldFont != 0
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
;    .IF hOldBrush != 0
;        Invoke SelectObject, hdc, hOldBrush
;        Invoke DeleteObject, hOldBrush
;    .ENDIF     
;    .IF hBrush != 0
;        Invoke DeleteObject, hBrush
;    .ENDIF
    
    ret
_MUI_TextPaintText ENDP


;-------------------------------------------------------------------------------------
; Returns TRUE if CR LF found in string, otherwise returns FALSE
;-------------------------------------------------------------------------------------
_MUI_TextCheckMultiline PROC USES EBX hControl:DWORD, lpszText:DWORD
    LOCAL lenText:DWORD
    LOCAL Cnt:DWORD
    LOCAL bMultiline:DWORD
    LOCAL dwStyle:DWORD
    
    ;PrintText '_MUI_TextCheckMultiline'
    
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
            mov bMultiline, TRUE
            .BREAK 
        .ENDIF
        inc ebx
        inc Cnt
        mov eax, Cnt
    .ENDW

    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax  
    mov eax, dwStyle
    .IF bMultiline == FALSE
        or eax, MUITS_SINGLELINE
    .ELSE
        and eax, (-1 xor MUITS_SINGLELINE)
    .ENDIF
    mov dwStyle, eax
    Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle

    mov eax, bMultiline
    ret

_MUI_TextCheckMultiline ENDP







END
