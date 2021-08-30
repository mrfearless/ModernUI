;==============================================================================
;
; ModernUI Control - ModernUI_Checkbox
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

MUI_DONTUSEGDIPLUS EQU 1 ; exclude (gdiplus) support

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

include ModernUI_Checkbox.inc
include ModernUI_Checkbox_Icons.asm
include ModernUI_Radio_Icons.asm

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_CheckboxWndProc                    PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CheckboxInit                       PROTO :DWORD
_MUI_CheckboxCleanup                    PROTO :DWORD
_MUI_CheckboxSetColors                  PROTO :DWORD, :DWORD
_MUI_SetTheme                           PROTO :DWORD, :DWORD, :DWORD
_MUI_CheckboxPaint                      PROTO :DWORD

_MUI_CheckboxPaintBackground            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CheckboxPaintText                  PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CheckboxPaintImages                PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CheckboxPaintFocusRect             PROTO :DWORD, :DWORD, :DWORD, :DWORD

_MUI_CheckboxButtonDown                 PROTO :DWORD ; WM_LBUTTONDOWN, WM_KEYDOWN + VK_SPACE
_MUI_CheckboxButtonUp                   PROTO :DWORD ; WM_LBUTTONUP, WM_KEYUP + VK_SPACE

_MUI_CheckboxLoadBitmap                 PROTO :DWORD, :DWORD, :DWORD
_MUI_CheckboxLoadIcon                   PROTO :DWORD, :DWORD, :DWORD
IFDEF MUI_USEGDIPLUS
_MUI_CheckboxLoadPng                    PROTO :DWORD, :DWORD, :DWORD
ENDIF

IFDEF MUI_USEGDIPLUS
_MUI_CheckboxPngReleaseIStream          PROTO :DWORD
ENDIF
_MUI_CheckboxSetPropertyEx              PROTO :DWORD, :DWORD, :DWORD

;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
IFNDEF MUI_CHECKBOX_PROPERTIES
MUI_CHECKBOX_PROPERTIES                 STRUCT
    dwTextFont                          DD ?       ; hFont
    dwTextColor                         DD ?       ; Colorref
    dwTextColorAlt                      DD ?       ; Colorref
    dwTextColorSel                      DD ?       ; Colorref
    dwTextColorSelAlt                   DD ?       ; Colorref
    dwTextColorDisabled                 DD ?       ; Colorref
    dwBackColor                         DD ?       ; Colorref
    dwImageType                         DD ?       ; image type
    dwImage                             DD ?       ; hImage for empty checkbox
    dwImageAlt                          DD ?       ; hImage for empty checkbox when mouse moves over checkbox
    dwImageSel                          DD ?       ; hImage for checkbox with checkmark
    dwImageSelAlt                       DD ?       ; hImage for checkbox with checkmark when mouse moves over checkbox
    dwImageDisabled                     DD ?       ; hImage for disabled empty checkbox
    dwImageDisabledSel                  DD ?       ; hImage for disabled checkbox with checkmark
    dwCheckboxDllInstance               DD ?
    dwCheckboxParam                     DD ?
MUI_CHECKBOX_PROPERTIES                 ENDS
ENDIF

; Internal properties
_MUI_CHECKBOX_PROPERTIES                STRUCT
    dwEnabledState                      DD ?
    dwMouseOver                         DD ?
    dwSelectedState                     DD ?
    dwFocusedState                      DD ?
    dwMouseDown                         DD ?    
    dwImageStream                       DD ?
    dwImageAltStream                    DD ?
    dwImageSelStream                    DD ?
    dwImageSelAltStream                 DD ?
    dwImageDisabledStream               DD ?
    dwImageDisabledSelStream            DD ?
_MUI_CHECKBOX_PROPERTIES                ENDS

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
MUI_CHECKBOX_FOCUSRECT_OFFSET           EQU -2 ; change this to higher negative value to shrink focus rect within checkbox


; Internal properties
@CheckboxEnabledState                   EQU 0
@CheckboxMouseOver                      EQU 4
@CheckboxSelectedState                  EQU 8
@CheckboxFocusedState                   EQU 12
@CheckboxMouseDown                      EQU 16
@CheckboxImageStream                    EQU 20
@CheckboxImageAltStream                 EQU 24
@CheckboxImageSelStream                 EQU 28
@CheckboxImageSelAltStream              EQU 32
@CheckboxImageDisabledStream            EQU 36
@CheckboxImageDisabledSelStream         EQU 40

; External public properties


.DATA
ALIGN 4
szMUICheckboxClass                      DB 'ModernUI_Checkbox',0            ; Class name for creating our ModernUI_Checkbox control
szMUICheckboxFont                       DB 'Segoe UI',0                     ; Font used for ModernUI_Checkbox text
hMUICheckboxFont                        DD 0                                ; Handle to ModernUI_Checkbox font (segoe ui)


; (D) dark color icons for light backgrounds (default):
hDefault_icoMUICheckboxTickD            DD 0 ; selected - icoMUICheckboxTick
hDefault_icoMUICheckboxEmptyD           DD 0 ; default - icoMUICheckboxEmpty
hDefault_icoMUICheckboxDisabledTickD    DD 0
hDefault_icoMUICheckboxDisabledEmptyD   DD 0
hDefault_icoMUICheckboxAltTickD         DD 0 ; selected alt - icoMUICheckboxAltTick
hDefault_icoMUICheckboxAltEmptyD        DD 0 ; default alt - icoMUICheckboxAltEmpty

hDefault_icoMUIRadioTickD               DD 0 ; selected
hDefault_icoMUIRadioEmptyD              DD 0 ; default
hDefault_icoMUIRadioDisabledTickD       DD 0
hDefault_icoMUIRadioDisabledEmptyD      DD 0
hDefault_icoMUIRadioAltTickD            DD 0 ; selected alt - icoMUIRadioAltTick
hDefault_icoMUIRadioAltEmptyD           DD 0 ; default alt - icoMUIRadioAltEmpty

; (L) light color icons for dark backgrounds:
hDefault_icoMUICheckboxTickL            DD 0 ; selected - icoMUICheckboxTickL
hDefault_icoMUICheckboxEmptyL           DD 0 ; default - icoMUICheckboxEmptyL
hDefault_icoMUICheckboxDisabledTickL    DD 0
hDefault_icoMUICheckboxDisabledEmptyL   DD 0
hDefault_icoMUICheckboxAltTickL         DD 0 ; selected alt - icoMUICheckboxAltTickL
hDefault_icoMUICheckboxAltEmptyL        DD 0 ; default alt - icoMUICheckboxAltEmptyL

hDefault_icoMUIRadioTickL               DD 0 ; selected
hDefault_icoMUIRadioEmptyL              DD 0 ; default
hDefault_icoMUIRadioDisabledTickL       DD 0
hDefault_icoMUIRadioDisabledEmptyL      DD 0
hDefault_icoMUIRadioAltTickL            DD 0 ; selected alt - icoMUIRadioAltTickL
hDefault_icoMUIRadioAltEmptyL           DD 0 ; default alt - icoMUIRadioAltEmptyL

.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_Checkbox control
;------------------------------------------------------------------------------
MUICheckboxSetProperty PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUICheckboxSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_Checkbox control
;------------------------------------------------------------------------------
MUICheckboxGetProperty PROC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUICheckboxGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICheckboxRegister - Registers the ModernUI_Checkbox control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Checkbox
;------------------------------------------------------------------------------
MUICheckboxRegister PROC 
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUICheckboxClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUICheckboxClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MUI_CheckboxWndProc
        mov wc.lpfnWndProc, eax
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

MUICheckboxRegister ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICheckboxCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUICheckboxCreate PROC hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUICheckboxRegister
    
    ; Modify styles appropriately - for visual controls no CS_HREDRAW CS_VREDRAW (causes flickering)
    ; probably need WS_CHILD, WS_VISIBLE. Needs WS_CLIPCHILDREN. Non visual prob dont need any of these.

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
    
    Invoke CreateWindowEx, NULL, Addr szMUICheckboxClass, lpszText, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        ;PrintDec hControl
    .ENDIF
    mov eax, hControl
    ret
MUICheckboxCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_CheckboxWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL hParent:DWORD
    LOCAL rect:RECT
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName   
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_CHECKBOX_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_CHECKBOX_PROPERTIES ; external properties
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGDIPlusStart ; for png resources if used
        ENDIF
        Invoke _MUI_CheckboxInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_CheckboxCleanup, hWin
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
        Invoke _MUI_CheckboxPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUICBS_HAND
        .IF eax == MUICBS_HAND
            invoke LoadCursor, NULL, IDC_HAND
        .ELSE
            invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
        mov eax, 0
        ret   

    .ELSEIF eax == WM_KEYUP
        mov eax, wParam
        .IF eax == VK_SPACE
            Invoke _MUI_CheckboxButtonUp, hWin
;        .ELSEIF eax == VK_TAB
;            Invoke GetParent, hWin
;            mov hParent, eax
;            Invoke GetAsyncKeyState, VK_SHIFT
;            .IF eax != 0
;                Invoke GetWindow, hWin, GW_HWNDPREV
;            .ELSE
;                Invoke GetWindow, hWin, GW_HWNDNEXT
;            .ENDIF
;            .IF eax != 0
;                Invoke SetFocus, eax
;            .ENDIF
        .ENDIF

    .ELSEIF eax == WM_KEYDOWN
        mov eax, wParam
        .IF eax == VK_SPACE
            Invoke _MUI_CheckboxButtonDown, hWin
        .ENDIF

    .ELSEIF eax == WM_LBUTTONUP
        Invoke _MUI_CheckboxButtonUp, hWin

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MUI_CheckboxButtonDown, hWin


;    .ELSEIF eax == WM_LBUTTONUP
;        ; simulates click on our control, delete if not required.
;        Invoke GetParent, hWin
;        mov hParent, eax
;        Invoke GetDlgCtrlID, hWin
;        Invoke PostMessage, hParent, WM_COMMAND, eax, hWin
;
;        Invoke MUIGetIntProperty, hWin, @CheckboxSelectedState
;        .IF eax == FALSE
;            Invoke MUISetIntProperty, hWin, @CheckboxSelectedState, TRUE
;        .ELSE
;            Invoke MUISetIntProperty, hWin, @CheckboxSelectedState, FALSE
;        .ENDIF
;        Invoke InvalidateRect, hWin, NULL, TRUE


   .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUIGetIntProperty, hWin, @CheckboxEnabledState
        .IF eax == TRUE   
            Invoke MUISetIntProperty, hWin, @CheckboxMouseOver, TRUE
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
        Invoke MUIGetIntProperty, hWin, @CheckboxFocusedState
        .IF eax == FALSE
            Invoke MUISetIntProperty, hWin, @CheckboxMouseOver, FALSE
        .ENDIF
        Invoke MUISetIntProperty, hWin, @CheckboxMouseDown, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE

    .ELSEIF eax == WM_SETFOCUS
        Invoke MUISetIntProperty, hWin, @CheckboxFocusedState, TRUE
        Invoke MUISetIntProperty, hWin, @CheckboxMouseOver, TRUE
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov eax, 0
        ret

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @CheckboxFocusedState, FALSE
        Invoke MUISetIntProperty, hWin, @CheckboxMouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov eax, 0
        ret        

    .ELSEIF eax == WM_ENABLE
        Invoke MUISetIntProperty, hWin, @CheckboxEnabledState, wParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov eax, 0

    .ELSEIF eax == WM_SETTEXT
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret

    .ELSEIF eax == WM_SETFONT
        Invoke MUISetExtProperty, hWin, @CheckboxTextFont, wParam
        .IF lParam == TRUE
            Invoke ShowWindow, hWin, SW_HIDE
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke ShowWindow, hWin, SW_SHOW
        .ENDIF
    
    .ELSEIF eax == WM_SYSCOLORCHANGE
        Invoke _MUI_CheckboxSetColors, hWin, FALSE
        ret

    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        ;Invoke MUISetExtProperty, hWin, wParam, lParam
        ; by default set other similar properties when main one is set
        Invoke _MUI_CheckboxSetPropertyEx, hWin, wParam, lParam
        Invoke InvalidateRect, hWin, NULL, TRUE     
        ret

    .ELSEIF eax == MUICM_GETSTATE ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
        Invoke MUIGetIntProperty, hWin, @CheckboxSelectedState
        ret
     
    .ELSEIF eax == MUICM_SETSTATE ; wParam = TRUE/FALSE, lParam = NULL
        Invoke MUISetIntProperty, hWin, @CheckboxSelectedState, wParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret
    
    .ELSEIF eax == MUICM_SETTHEME ; wParam = TRUE for dark theme, FALSE for light theme, lParam = TRUE for redraw now
        Invoke _MUI_SetTheme, hWin, wParam, lParam
        ret
    
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_CheckboxWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxInit - set initial default values
;------------------------------------------------------------------------------
_MUI_CheckboxInit PROC hWin:DWORD
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
        or dwStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF


    ; Set default initial internal property values
    mov eax, dwStyle
    and eax, WS_DISABLED
    .IF eax == WS_DISABLED
        Invoke MUISetIntProperty, hWin, @CheckboxEnabledState, FALSE
    .ELSE
        Invoke MUISetIntProperty, hWin, @CheckboxEnabledState, TRUE
    .ENDIF    

    ; Set default initial external property values
    Invoke _MUI_CheckboxSetColors, hWin, TRUE

    Invoke MUISetExtProperty, hWin, @CheckboxDllInstance, 0
    ;Invoke MUISetExtProperty, hWin, @CheckboxImageType, MUICIT_NONE


    .IF hMUICheckboxFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hFont, eax
        Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
        mov lfnt.lfHeight, -16d
        ;mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUICheckboxFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke MUISetExtProperty, hWin, @CheckboxTextFont, hMUICheckboxFont


    ; create default icons for use if user hasnt specified any images
    Invoke MUISetExtProperty, hWin, @CheckboxImageType, MUICIT_ICO

    mov eax, dwStyle
    and eax, MUICBS_RADIO
    .IF eax == MUICBS_RADIO
        ; Default radio icons
        mov eax, dwStyle
        and eax, MUICBS_THEMEDARK
        .IF eax == MUICBS_THEMEDARK ; light color icons for dark background
            .IF hDefault_icoMUIRadioEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioEmptyL, 0
                mov hDefault_icoMUIRadioEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltEmptyL, 0
                mov hDefault_icoMUIRadioAltEmptyL, eax
            .ENDIF               
            .IF hDefault_icoMUIRadioTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioTickL, 0
                mov hDefault_icoMUIRadioTickL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltTickL, 0
                mov hDefault_icoMUIRadioAltTickL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledEmptyL, 0
                mov hDefault_icoMUIRadioDisabledEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledTickL, 0
                mov hDefault_icoMUIRadioDisabledTickL, eax
            .ENDIF    
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUIRadioEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUIRadioAltEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUIRadioTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUIRadioAltTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUIRadioDisabledEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUIRadioDisabledTickL
        .ELSE ; dark color icons for light background
            .IF hDefault_icoMUIRadioEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioEmptyD, 0
                mov hDefault_icoMUIRadioEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltEmptyD, 0
                mov hDefault_icoMUIRadioAltEmptyD, eax
            .ENDIF               
            .IF hDefault_icoMUIRadioTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioTickD, 0
                mov hDefault_icoMUIRadioTickD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltTickD, 0
                mov hDefault_icoMUIRadioAltTickD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledEmptyD, 0
                mov hDefault_icoMUIRadioDisabledEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledTickD, 0
                mov hDefault_icoMUIRadioDisabledTickD, eax
            .ENDIF    
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUIRadioEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUIRadioAltEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUIRadioTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUIRadioAltTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUIRadioDisabledEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUIRadioDisabledTickD
        .ENDIF
    .ELSE
        ; Default check icons
        mov eax, dwStyle
        and eax, MUICBS_THEMEDARK
        .IF eax == MUICBS_THEMEDARK ; light color icons for dark background
            .IF hDefault_icoMUICheckboxEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxEmptyL, 0
                mov hDefault_icoMUICheckboxEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltEmptyL, 0
                mov hDefault_icoMUICheckboxAltEmptyL, eax
            .ENDIF             
            .IF hDefault_icoMUICheckboxTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxTickL, 0
                mov hDefault_icoMUICheckboxTickL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltTickL, 0
                mov hDefault_icoMUICheckboxAltTickL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledEmptyL, 0
                mov hDefault_icoMUICheckboxDisabledEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledTickL, 0
                mov hDefault_icoMUICheckboxDisabledTickL, eax
            .ENDIF
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUICheckboxEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUICheckboxAltEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUICheckboxTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUICheckboxAltTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUICheckboxDisabledEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUICheckboxDisabledTickL
        .ELSE ; dark color icons for light background
            .IF hDefault_icoMUICheckboxEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxEmptyD, 0
                mov hDefault_icoMUICheckboxEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltEmptyD, 0
                mov hDefault_icoMUICheckboxAltEmptyD, eax
            .ENDIF             
            .IF hDefault_icoMUICheckboxTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxTickD, 0
                mov hDefault_icoMUICheckboxTickD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltTickD, 0
                mov hDefault_icoMUICheckboxAltTickD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledEmptyD, 0
                mov hDefault_icoMUICheckboxDisabledEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledTickD, 0
                mov hDefault_icoMUICheckboxDisabledTickD, eax
            .ENDIF
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUICheckboxEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUICheckboxAltEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUICheckboxTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUICheckboxAltTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUICheckboxDisabledEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUICheckboxDisabledTickD
        .ENDIF
    .ENDIF
    ret

_MUI_CheckboxInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxCleanup - cleanup a few things before control is destroyed
;------------------------------------------------------------------------------
_MUI_CheckboxCleanup PROC hWin:DWORD
    LOCAL ImageType:DWORD
    LOCAL hIStreamImage:DWORD
    LOCAL hIStreamImageAlt:DWORD
    LOCAL hIStreamImageSel:DWORD
    LOCAL hIStreamImageSelAlt:DWORD
    LOCAL hIStreamImageDisabled:DWORD
    LOCAL hIStreamImageDisabledSel:DWORD
    LOCAL hImage:DWORD
    LOCAL hImageAlt:DWORD
    LOCAL hImageSel:DWORD
    LOCAL hImageSelAlt:DWORD
    LOCAL hImageDisabled:DWORD
    LOCAL hImageDisabledSel:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    IFDEF DEBUG32
    PrintText '_MUI_CheckboxCleanup'
    ENDIF
    ; cleanup any stream handles if png where loaded as resources
    Invoke MUIGetExtProperty, hWin, @CheckboxImageType
    mov ImageType, eax

    .IF ImageType == MUICIT_NONE
        ret
    .ENDIF
    
    .IF ImageType == MUICIT_PNG
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGetIntProperty, hWin, @CheckboxImageStream
        mov hIStreamImage, eax
        .IF eax != 0
            Invoke _MUI_CheckboxPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @CheckboxImageAltStream
        mov hIStreamImageAlt, eax
        .IF eax != 0 && eax != hIStreamImage
            Invoke _MUI_CheckboxPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @CheckboxImageSelStream
        mov hIStreamImageSel, eax
        .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt
            Invoke _MUI_CheckboxPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @CheckboxImageSelAltStream
        mov hIStreamImageSelAlt, eax
        .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt && eax != hIStreamImageSel
            Invoke _MUI_CheckboxPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @CheckboxImageDisabledStream
        mov hIStreamImageDisabled, eax
        .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt && eax != hIStreamImageSel && eax != hIStreamImageSelAlt 
            Invoke _MUI_CheckboxPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @CheckboxImageDisabledSelStream
        mov hIStreamImageDisabledSel, eax
        .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt && eax != hIStreamImageSel && eax != hIStreamImageSelAlt && eax != hIStreamImageDisabled
            Invoke _MUI_CheckboxPngReleaseIStream, eax
        .ENDIF

        
        IFDEF DEBUG32
        ; check to see if handles are cleared.
        PrintText '_MUI_CheckboxCleanup::IStream Handles cleared'
        ENDIF
        
        ENDIF        
    .ENDIF

    Invoke MUIGetExtProperty, hWin, @CheckboxImage
    mov hImage, eax
    .IF eax != 0
        .IF ImageType != MUICIT_PNG
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @CheckboxImageAlt
    mov hImageAlt, eax
    .IF eax != 0 && eax != hImage
        .IF ImageType != MUICIT_PNG
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF    
    Invoke MUIGetExtProperty, hWin, @CheckboxImageSel
    mov hImageSel, eax
    .IF eax != 0 && eax != hImage && eax != hImageAlt
        .IF ImageType != MUICIT_PNG
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF    
    Invoke MUIGetExtProperty, hWin, @CheckboxImageSelAlt
    mov hImageSelAlt, eax
    .IF eax != 0 && eax != hImage && eax != hImageAlt && eax != hImageSel
        .IF ImageType != MUICIT_PNG
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @CheckboxImageDisabled
    mov hImageDisabled, eax
    .IF eax != 0 && eax != hImage && eax != hImageAlt && eax != hImageSel && eax != hImageSelAlt
        .IF ImageType != MUICIT_PNG
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @CheckboxImageDisabledSel
    mov hImageDisabledSel, eax
    .IF eax != 0 && eax != hImage && eax != hImageAlt && eax != hImageSel && eax != hImageSelAlt && eax != hImageDisabled
        .IF ImageType != MUICIT_PNG
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF

       
    IFDEF DEBUG32
    PrintText '_MUI_CheckboxCleanup::Image Handles cleared'
    ENDIF

    ret

_MUI_CheckboxCleanup ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxSetColors - Set colors on init or syscolorchange if MUIBS_THEME 
; style used
;------------------------------------------------------------------------------
_MUI_CheckboxSetColors PROC hWin:DWORD, bInit:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, MUICBS_THEME
    .IF eax == MUICBS_THEME
        ; Set color property values based on system colors
        Invoke GetSysColor, COLOR_BTNTEXT
        Invoke MUISetExtProperty, hWin, @CheckboxTextColor, eax
        Invoke GetSysColor, COLOR_HOTLIGHT
        Invoke MUISetExtProperty, hWin, @CheckboxTextColorAlt, eax
        Invoke GetSysColor, COLOR_HIGHLIGHT
        Invoke MUISetExtProperty, hWin, @CheckboxTextColorSel, eax
        Invoke GetSysColor, COLOR_HOTLIGHT
        Invoke MUISetExtProperty, hWin, @CheckboxTextColorSelAlt, eax
        Invoke GetSysColor, COLOR_GRAYTEXT
        Invoke MUISetExtProperty, hWin, @CheckboxTextColorDisabled, eax


        Invoke GetSysColor, COLOR_WINDOW
        Invoke MUISetExtProperty, hWin, @CheckboxBackColor, eax

    .ELSE

        .IF bInit == TRUE
        
            mov eax, dwStyle
            and eax, MUICBS_THEMEDARK
            .IF eax == MUICBS_THEMEDARK
                Invoke MUISetExtProperty, hWin, @CheckboxTextColor, MUI_RGBCOLOR(240,240,240)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorAlt, MUI_RGBCOLOR(43,178,243)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorSel, MUI_RGBCOLOR(240,240,240)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorSelAlt, MUI_RGBCOLOR(43,178,243)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorDisabled, MUI_RGBCOLOR(160,160,160)
                Invoke MUISetExtProperty, hWin, @CheckboxBackColor, MUI_RGBCOLOR(45,45,48)
            .ELSE
                ; Set color property values based on custom values
                Invoke MUISetExtProperty, hWin, @CheckboxTextColor, MUI_RGBCOLOR(51,51,51)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorAlt, MUI_RGBCOLOR(41,122,185)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorSel, MUI_RGBCOLOR(51,51,51)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorSelAlt, MUI_RGBCOLOR(41,122,185)
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorDisabled, MUI_RGBCOLOR(204,204,204)
            
                Invoke MUIGetParentBackgroundColor, hWin
                .IF eax == -1 ; if background was NULL then try a color as default
                    Invoke GetSysColor, COLOR_WINDOW
                .ENDIF
                Invoke MUISetExtProperty, hWin, @CheckboxBackColor, eax
                ;Invoke MUISetExtProperty, hWin, @CheckboxBackColor, MUI_RGBCOLOR(240,240,240) ;MUI_RGBCOLOR(21,133,181)
            .ENDIF
        .ENDIF
    .ENDIF
    ret
_MUI_CheckboxSetColors ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SetTheme - Set Theme. bTheme = TRUE for dark theme, FALSE for light theme
;------------------------------------------------------------------------------
_MUI_SetTheme PROC PROC hWin:DWORD, bTheme:DWORD, bRedraw:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax

    mov eax, dwStyle
    and eax, MUICBS_RADIO
    .IF eax == MUICBS_RADIO
    
        ; Default radio icons
        .IF bTheme == TRUE ; Radio icons: light color icons for dark background
            .IF hDefault_icoMUIRadioEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioEmptyL, 0
                mov hDefault_icoMUIRadioEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltEmptyL, 0
                mov hDefault_icoMUIRadioAltEmptyL, eax
            .ENDIF               
            .IF hDefault_icoMUIRadioTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioTickL, 0
                mov hDefault_icoMUIRadioTickL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltTickL, 0
                mov hDefault_icoMUIRadioAltTickL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledEmptyL, 0
                mov hDefault_icoMUIRadioDisabledEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledTickL, 0
                mov hDefault_icoMUIRadioDisabledTickL, eax
            .ENDIF    
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUIRadioEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUIRadioAltEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUIRadioTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUIRadioAltTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUIRadioDisabledEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUIRadioDisabledTickL
        
        .ELSE ; bTheme == FALSE ; Radio icons: dark color icons for light background
        
            .IF hDefault_icoMUIRadioEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioEmptyD, 0
                mov hDefault_icoMUIRadioEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltEmptyD, 0
                mov hDefault_icoMUIRadioAltEmptyD, eax
            .ENDIF               
            .IF hDefault_icoMUIRadioTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioTickD, 0
                mov hDefault_icoMUIRadioTickD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioAltTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioAltTickD, 0
                mov hDefault_icoMUIRadioAltTickD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledEmptyD, 0
                mov hDefault_icoMUIRadioDisabledEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUIRadioDisabledTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledTickD, 0
                mov hDefault_icoMUIRadioDisabledTickD, eax
            .ENDIF    
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUIRadioEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUIRadioAltEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUIRadioTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUIRadioAltTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUIRadioDisabledEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUIRadioDisabledTickD
        .ENDIF
        
    .ELSE ; eax == MUICBS_CHECK
    
        ; Default check icons
        .IF bTheme == TRUE ; Check icons: light color icons for dark background
            .IF hDefault_icoMUICheckboxEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxEmptyL, 0
                mov hDefault_icoMUICheckboxEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltEmptyL, 0
                mov hDefault_icoMUICheckboxAltEmptyL, eax
            .ENDIF             
            .IF hDefault_icoMUICheckboxTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxTickL, 0
                mov hDefault_icoMUICheckboxTickL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltTickL, 0
                mov hDefault_icoMUICheckboxAltTickL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledEmptyL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledEmptyL, 0
                mov hDefault_icoMUICheckboxDisabledEmptyL, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledTickL == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledTickL, 0
                mov hDefault_icoMUICheckboxDisabledTickL, eax
            .ENDIF
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUICheckboxEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUICheckboxAltEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUICheckboxTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUICheckboxAltTickL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUICheckboxDisabledEmptyL
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUICheckboxDisabledTickL
            
        .ELSE ; bTheme == FALSE ; Check icons: dark color icons for light background
        
            .IF hDefault_icoMUICheckboxEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxEmptyD, 0
                mov hDefault_icoMUICheckboxEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltEmptyD, 0
                mov hDefault_icoMUICheckboxAltEmptyD, eax
            .ENDIF             
            .IF hDefault_icoMUICheckboxTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxTickD, 0
                mov hDefault_icoMUICheckboxTickD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxAltTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxAltTickD, 0
                mov hDefault_icoMUICheckboxAltTickD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledEmptyD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledEmptyD, 0
                mov hDefault_icoMUICheckboxDisabledEmptyD, eax
            .ENDIF
            .IF hDefault_icoMUICheckboxDisabledTickD == 0
                Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledTickD, 0
                mov hDefault_icoMUICheckboxDisabledTickD, eax
            .ENDIF
            Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUICheckboxEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUICheckboxAltEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUICheckboxTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUICheckboxAltTickD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUICheckboxDisabledEmptyD
            Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUICheckboxDisabledTickD
        .ENDIF
    .ENDIF    
    
    ; Set actual style flag based on bTheme
    .IF bTheme == TRUE
        mov eax, dwStyle
        and eax, MUICBS_THEMEDARK
        .IF eax != MUICBS_THEMEDARK
            or dwStyle, MUICBS_THEMEDARK
            Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
        .ENDIF
    .ELSE    
        mov eax, dwStyle
        and eax, MUICBS_THEMEDARK
        .IF eax == MUICBS_THEMEDARK
            and dwStyle,(-1 xor MUICBS_THEMEDARK)
            Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
        .ENDIF
    .ENDIF
    
    .IF bRedraw == TRUE
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF
    
    ret
_MUI_SetTheme ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxButtonDown - Mouse button down or keyboard down from vk_space
;------------------------------------------------------------------------------
_MUI_CheckboxButtonDown PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL rect:RECT    

    Invoke GetFocus
    .IF eax != hWin
        Invoke SetFocus, hWin
        Invoke MUISetIntProperty, hWin, @CheckboxFocusedState, FALSE
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @CheckboxMouseDown
    .IF eax == FALSE
        Invoke MUISetIntProperty, hWin, @CheckboxMouseDown, TRUE
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF

    ret
_MUI_CheckboxButtonDown ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxButtonUp - Mouse button up or keyboard up from vk_space
;------------------------------------------------------------------------------
_MUI_CheckboxButtonUp PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL wID:DWORD
    LOCAL rect:RECT

    Invoke MUIGetIntProperty, hWin, @CheckboxMouseDown
    .IF eax == TRUE
        Invoke GetDlgCtrlID, hWin
        mov wID,eax
        Invoke GetParent, hWin
        mov hParent, eax
        Invoke PostMessage, hParent, WM_COMMAND, wID, hWin ; simulates click on our control
        
        Invoke MUISetIntProperty, hWin, @CheckboxMouseDown, FALSE
        
        Invoke MUIGetIntProperty, hWin, @CheckboxSelectedState
        .IF eax == FALSE
            Invoke MUISetIntProperty, hWin, @CheckboxSelectedState, TRUE
        .ELSE
            Invoke MUISetIntProperty, hWin, @CheckboxSelectedState, FALSE
        .ENDIF
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF
    ret
_MUI_CheckboxButtonUp ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxPaint
;------------------------------------------------------------------------------
_MUI_CheckboxPaint PROC hWin:DWORD
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
    LOCAL FocusedState:DWORD
    LOCAL SavedDChdcMem:DWORD

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
    Invoke MUIGetIntProperty, hWin, @CheckboxEnabledState
    mov EnabledState, eax
    Invoke MUIGetIntProperty, hWin, @CheckboxMouseOver
    mov MouseOver, eax
    Invoke MUIGetIntProperty, hWin, @CheckboxSelectedState
    mov SelectedState, eax
    Invoke MUIGetIntProperty, hWin, @CheckboxFocusedState
    mov FocusedState, eax    
    
    Invoke SaveDC, hdcMem ; save hdcmem for focus rect
    mov SavedDChdcMem, eax ; otherwise color of focus is off 
    
    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _MUI_CheckboxPaintBackground, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Images
    ;----------------------------------------------------------
    Invoke _MUI_CheckboxPaintImages, hWin, hdcMem, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Text
    ;----------------------------------------------------------
    Invoke _MUI_CheckboxPaintText, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Focused state
    ;----------------------------------------------------------
    Invoke RestoreDC, hdcMem, SavedDChdcMem
    Invoke _MUI_CheckboxPaintFocusRect, hWin, hdcMem, Addr rect, FocusedState

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
_MUI_CheckboxPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxPaintBackground
;------------------------------------------------------------------------------
_MUI_CheckboxPaintBackground PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    
    Invoke MUIGetExtProperty, hWin, @CheckboxBackColor
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

_MUI_CheckboxPaintBackground ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxPaintText
;------------------------------------------------------------------------------
_MUI_CheckboxPaintText PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwTextStyle:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hImage:DWORD
    LOCAL ImageType:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL rect:RECT
    LOCAL szText[256]:BYTE
    ;LOCAL LenText:DWORD

    Invoke CopyRect, Addr rect, lpRect

    Invoke MUIGetExtProperty, hWin, @CheckboxBackColor
    mov BackColor, eax
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    Invoke MUIGetExtProperty, hWin, @CheckboxTextFont        
    mov hFont, eax

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @CheckboxTextColor        ; Normal text color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @CheckboxTextColorAlt     ; Mouse over text color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @CheckboxTextColorSel     ; Selected text color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @CheckboxTextColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @CheckboxTextColorDisabled        ; Disabled text color
    .ENDIF
    .IF eax == 0 ; try to get default text color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @CheckboxTextColor                ; fallback to default Normal text color
    .ENDIF  
    mov TextColor, eax


    Invoke MUIGetExtProperty, hWin, @CheckboxImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @CheckboxImage        ; Normal image
            .ELSE
                Invoke MUIGetExtProperty, hWin, @CheckboxImageAlt     ; Mouse over image
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @CheckboxImageSel     ; Selected image
            .ELSE
                Invoke MUIGetExtProperty, hWin, @CheckboxImageSelAlt  ; Selected mouse over image 
            .ENDIF
        .ENDIF
    .ELSE
        .IF bSelectedState == FALSE
            Invoke MUIGetExtProperty, hWin, @CheckboxImageDisabled        ; Disabled image
        .ELSE
            Invoke MUIGetExtProperty, hWin, @CheckboxImageDisabledSel        ; Disabled image
        .ENDIF
    .ENDIF
    mov hImage, eax    
    
    ;Invoke lstrlen, Addr szText
    ;mov LenText, eax
    
    mov rect.left, 8
    ;mov rect.top, 4
    ;sub rect.bottom, 4
    sub rect.right, 4
    
    .IF hImage != 0
        
        Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight

        mov eax, ImageWidth
        add rect.left, eax
        add rect.left, 8d

    .ENDIF

    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax
    Invoke GetWindowText, hWin, Addr szText, sizeof szText

    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor

    
    Invoke SetBkMode, hdc, OPAQUE
    Invoke SetBkColor, hdc, BackColor    
    Invoke SetTextColor, hdc, TextColor


    Invoke DrawText, hdc, Addr szText, -1, Addr rect, DT_SINGLELINE or DT_LEFT or DT_VCENTER
    
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
    
    ret

_MUI_CheckboxPaintText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxPaintImages
;------------------------------------------------------------------------------
_MUI_CheckboxPaintImages PROC PRIVATE USES EBX hWin:DWORD, hdcMain:DWORD, hdcDest:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL dwStyle:DWORD
    LOCAL ImageType:DWORD
    LOCAL hImage:DWORD
    LOCAL hdcMem:HDC
    LOCAL hbmOld:DWORD
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL pBitmap:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    Invoke MUIGetExtProperty, hWin, @CheckboxImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png

    .IF ImageType == 0
        ret
    .ENDIF    
    
    .IF ImageType != 0
        .IF bEnabledState == TRUE
            .IF bSelectedState == FALSE
                .IF bMouseOver == FALSE
                    Invoke MUIGetExtProperty, hWin, @CheckboxImage        ; Normal image
                .ELSE
                    Invoke MUIGetExtProperty, hWin, @CheckboxImageAlt     ; Mouse over image
                .ENDIF
            .ELSE
                .IF bMouseOver == FALSE
                    Invoke MUIGetExtProperty, hWin, @CheckboxImageSel     ; Selected image
                .ELSE
                    Invoke MUIGetExtProperty, hWin, @CheckboxImageSelAlt  ; Selected mouse over image 
                .ENDIF
            .ENDIF
        .ELSE
            .IF bSelectedState == FALSE
                Invoke MUIGetExtProperty, hWin, @CheckboxImageDisabled        ; Disabled image
            .ELSE
                Invoke MUIGetExtProperty, hWin, @CheckboxImageDisabledSel     ; Disabled image
            .ENDIF
        .ENDIF
        .IF eax == 0 ; try to get default image if none others have a valid handle
            Invoke MUIGetExtProperty, hWin, @CheckboxImage                ; fallback to default Normal image
        .ENDIF
        mov hImage, eax
    .ELSE
        mov hImage, 0
    .ENDIF
    
    .IF hImage != 0
    
        Invoke CopyRect, Addr rect, lpRect
        Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight
        
        mov pt.x, 8d
        mov pt.y, 4d

        mov eax, rect.bottom
        shr eax, 1
        mov ebx, ImageHeight
        shr ebx, 1
        sub eax, ebx
        
        mov pt.y, eax

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
            IFDEF MUI_USEGDIPLUS
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
            ENDIF
        .ENDIF
    
    .ENDIF 

    ret

_MUI_CheckboxPaintImages ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxPaintFocusRect
;------------------------------------------------------------------------------
_MUI_CheckboxPaintFocusRect PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD, bFocusedState:DWORD
    LOCAL rect:RECT

    .IF bFocusedState == FALSE
        ret
    .ENDIF

    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUICBS_NOFOCUSRECT
    .IF eax == MUICBS_NOFOCUSRECT
        ret
    .ENDIF

    Invoke CopyRect, Addr rect, lpRect
    Invoke InflateRect, Addr rect, MUI_CHECKBOX_FOCUSRECT_OFFSET, MUI_CHECKBOX_FOCUSRECT_OFFSET
    Invoke DrawFocusRect, hdc, Addr rect
 
    ret
_MUI_CheckboxPaintFocusRect ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxSetPropertyEx
;------------------------------------------------------------------------------
_MUI_CheckboxSetPropertyEx PROC PRIVATE USES EBX hWin:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    
    mov eax, dwProperty
    .IF eax == @CheckboxTextFont
        .IF dwPropertyValue != 0
            Invoke MUISetExtProperty, hWin, dwProperty, dwPropertyValue 
        .ENDIF    
    .ELSE
        Invoke MUISetExtProperty, hWin, dwProperty, dwPropertyValue
    .ENDIF
    
    mov eax, dwProperty
    .IF eax == @CheckboxTextColor ; set other text colors to this if they are not set
        Invoke MUIGetExtProperty, hWin, @CheckboxTextColorAlt
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @CheckboxTextColorAlt, dwPropertyValue
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @CheckboxTextColorSel
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @CheckboxTextColorSel, dwPropertyValue
        .ENDIF
        ; except this, if sel has a color, then use this for selalt if it has a value
        Invoke MUIGetExtProperty, hWin, @CheckboxTextColorSelAlt
        .IF eax == 0
            Invoke MUIGetExtProperty, hWin, @CheckboxTextColorSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorSelAlt, dwPropertyValue
            .ELSE
                Invoke MUISetExtProperty, hWin, @CheckboxTextColorSelAlt, eax
            .ENDIF
        .ENDIF
    
    .ELSEIF eax == @CheckboxTextColorSel
        Invoke MUIGetExtProperty, hWin, @CheckboxTextColorSelAlt
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @CheckboxTextColorSelAlt, dwPropertyValue
        .ENDIF

    .ELSEIF eax == @CheckboxImage
        Invoke MUIGetExtProperty, hWin, @CheckboxImageAlt
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, dwPropertyValue
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @CheckboxImageSel
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @CheckboxImageSel, dwPropertyValue
        .ENDIF
        ; except this, if sel has a color, then use this for selalt if it has a value
        Invoke MUIGetExtProperty, hWin, @CheckboxImageSelAlt
        .IF eax == 0
            Invoke MUIGetExtProperty, hWin, @CheckboxImageSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, dwPropertyValue
            .ELSE
                Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, eax
            .ENDIF
        .ENDIF          
    .ENDIF

    ret
_MUI_CheckboxSetPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICheckboxLoadImages - Loads images from resource ids and stores the handles
; in the appropriate property.
;------------------------------------------------------------------------------
MUICheckboxLoadImages PROC hControl:DWORD, dwImageType:DWORD, dwResIDImage:DWORD, dwResIDImageAlt:DWORD, dwResIDImageSel:DWORD, dwResIDImageSelAlt:DWORD, dwResIDImageDisabled:DWORD, dwResIDImageDisabledSel:DWORD

    .IF dwImageType == 0
        ret
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @CheckboxImageType, dwImageType

    .IF dwResIDImage != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_CheckboxLoadBitmap, hControl, @CheckboxImage, dwResIDImage
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_CheckboxLoadIcon, hControl, @CheckboxImage, dwResIDImage
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_CheckboxLoadPng, hControl, @CheckboxImage, dwResIDImage
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageAlt != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_CheckboxLoadBitmap, hControl, @CheckboxImageAlt, dwResIDImageAlt
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_CheckboxLoadIcon, hControl, @CheckboxImageAlt, dwResIDImageAlt
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_CheckboxLoadPng, hControl, @CheckboxImageAlt, dwResIDImageAlt
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageSel != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_CheckboxLoadBitmap, hControl, @CheckboxImageSel, dwResIDImageSel
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_CheckboxLoadIcon, hControl, @CheckboxImageSel, dwResIDImageSel
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_CheckboxLoadPng, hControl, @CheckboxImageSel, dwResIDImageSel
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageSelAlt != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_CheckboxLoadBitmap, hControl, @CheckboxImageSelAlt, dwResIDImageSelAlt
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_CheckboxLoadIcon, hControl, @CheckboxImageSelAlt, dwResIDImageSelAlt
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_CheckboxLoadPng, hControl, @CheckboxImageSelAlt, dwResIDImageSelAlt
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageDisabled != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_CheckboxLoadBitmap, hControl, @CheckboxImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_CheckboxLoadIcon, hControl, @CheckboxImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_CheckboxLoadPng, hControl, @CheckboxImageDisabled, dwResIDImageDisabled
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageDisabledSel != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_CheckboxLoadBitmap, hControl, @CheckboxImageDisabledSel, dwResIDImageDisabledSel
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_CheckboxLoadIcon, hControl, @CheckboxImageDisabledSel, dwResIDImageDisabledSel
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_CheckboxLoadPng, hControl, @CheckboxImageDisabledSel, dwResIDImageDisabledSel
            ENDIF
        .ENDIF
    .ENDIF
    
    Invoke InvalidateRect, hControl, NULL, TRUE
    
    ret
MUICheckboxLoadImages ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICheckboxSetImages - Sets the property handles for image types
;------------------------------------------------------------------------------
MUICheckboxSetImages PROC hControl:DWORD, dwImageType:DWORD, hImage:DWORD, hImageAlt:DWORD, hImageSel:DWORD, hImageSelAlt:DWORD, hImageDisabled:DWORD, hImageDisabledSel:DWORD

    .IF dwImageType == 0
        ret
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @CheckboxImageType, dwImageType

    .IF hImage != 0
        Invoke MUISetExtProperty, hControl, @CheckboxImage, hImage
    .ENDIF

    .IF hImageAlt != 0
        Invoke MUISetExtProperty, hControl, @CheckboxImageAlt, hImageAlt
    .ENDIF

    .IF hImageSel != 0
        Invoke MUISetExtProperty, hControl, @CheckboxImageSel, hImageSel
    .ENDIF

    .IF hImageSelAlt != 0
        Invoke MUISetExtProperty, hControl, @CheckboxImageSelAlt, hImageSelAlt
    .ENDIF

    .IF hImageDisabled != 0
        Invoke MUISetExtProperty, hControl, @CheckboxImageDisabled, hImageDisabled
    .ENDIF

    .IF hImageDisabledSel != 0
        Invoke MUISetExtProperty, hControl, @CheckboxImageDisabledSel, hImageDisabledSel
    .ENDIF
    
    Invoke InvalidateRect, hControl, NULL, TRUE
    
    ret

MUICheckboxSetImages ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICheckboxGetState
;------------------------------------------------------------------------------
MUICheckboxGetState PROC hControl:DWORD
    Invoke SendMessage, hControl, MUICM_GETSTATE, 0, 0
    ret
MUICheckboxGetState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICheckboxSetState
;------------------------------------------------------------------------------
MUICheckboxSetState PROC hControl:DWORD, bState:DWORD
    Invoke SendMessage, hControl, MUICM_SETSTATE, bState, 0
    ret
MUICheckboxSetState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICheckboxSetTheme
;------------------------------------------------------------------------------
MUICheckboxSetTheme PROC hControl:DWORD, bTheme:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUICM_SETTHEME, bTheme, bRedraw
    ret
MUICheckboxSetTheme ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxLoadBitmap - if succesful, loads specified bitmap resource into 
; the specified external property and returns TRUE in eax, otherwise FALSE.
;------------------------------------------------------------------------------
_MUI_CheckboxLoadBitmap PROC hWin:DWORD, dwProperty:DWORD, idResBitmap:DWORD
    LOCAL hinstance:DWORD

    .IF idResBitmap == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hWin, @CheckboxDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax
    
    Invoke LoadBitmap, hinstance, idResBitmap
    Invoke MUISetExtProperty, hWin, dwProperty, eax
    mov eax, TRUE
    
    ret

_MUI_CheckboxLoadBitmap ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CheckboxLoadIcon - if succesful, loads specified icon resource into the 
; specified external property and returns TRUE in eax, otherwise FALSE.
;------------------------------------------------------------------------------
_MUI_CheckboxLoadIcon PROC hWin:DWORD, dwProperty:DWORD, idResIcon:DWORD
    LOCAL hinstance:DWORD

    .IF idResIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @CheckboxDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    Invoke LoadImage, hinstance, idResIcon, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
    Invoke MUISetExtProperty, hWin, dwProperty, eax

    mov eax, TRUE

    ret

_MUI_CheckboxLoadIcon ENDP


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
_MUI_CheckboxLoadPng PROC hWin:DWORD, dwProperty:DWORD, idResPng:DWORD
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

    Invoke MUIGetExtProperty, hWin, @CheckboxDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    ; ------------------------------------------------------------------
    ; STEP 1: Find the resource
    ; ------------------------------------------------------------------
    invoke  FindResource, hinstance, idResPng, RT_RCDATA
    or      eax, eax
    jnz     @f
    jmp     _MUI_CheckboxLoadPng@Close
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
    jmp     _MUI_CheckboxLoadPng@Close
@@: mov     sizeOfRes, eax
    
    invoke  LockResource, hResData
    or      eax, eax
    jnz     @f
    jmp     _MUI_CheckboxLoadPng@Close
@@: mov     pResData, eax

    invoke  GlobalAlloc, GMEM_MOVEABLE, sizeOfRes
    or      eax, eax
    jnz     @f
    jmp     _MUI_CheckboxLoadPng@Close
@@: mov     hbuffer, eax

    invoke  GlobalLock, hbuffer
    mov     pbuffer, eax
    
    invoke  RtlMoveMemory, pbuffer, hResData, sizeOfRes
    invoke  CreateStreamOnHGlobal, pbuffer, TRUE, addr pIStream
    or      eax, eax
    jz      @f
    jmp     _MUI_CheckboxLoadPng@Close
@@: 

    ; ------------------------------------------------------------------
    ; STEP 4: Create an image object from stream
    ; ------------------------------------------------------------------
    invoke  GdipCreateBitmapFromStream, pIStream, Addr pBitmapFromStream
    
    ; ------------------------------------------------------------------
    ; STEP 5: Free all used locks and resources
    ; ------------------------------------------------------------------
    invoke  GetHGlobalFromStream, pIStream, addr hIStream ; had to uncomment as corrupts pngs if left in, googling shows underlying stream needs to be left open for the life of the bitmap
    ;invoke GlobalFree, hIStream
    invoke  GlobalUnlock, hbuffer
    invoke  GlobalFree, hbuffer

    Invoke MUISetExtProperty, hWin, dwProperty, pBitmapFromStream
    ;PrintDec dwProperty
    ;PrintDec pBitmapFromStream
    
    mov eax, dwProperty
    .IF eax == @CheckboxImage
        Invoke MUISetIntProperty, hWin, @CheckboxImageStream, hIStream
    .ELSEIF eax == @CheckboxImageAlt
        Invoke MUISetIntProperty, hWin, @CheckboxImageAltStream, hIStream
    .ELSEIF eax == @CheckboxImageSel
        Invoke MUISetIntProperty, hWin, @CheckboxImageSelStream, hIStream
    .ELSEIF eax == @CheckboxImageSelAlt
        Invoke MUISetIntProperty, hWin, @CheckboxImageSelAltStream, hIStream
    .ELSEIF eax == @CheckboxImageDisabled
        Invoke MUISetIntProperty, hWin, @CheckboxImageDisabledStream, hIStream
    .ELSEIF eax == @CheckboxImageDisabledSel
        Invoke MUISetIntProperty, hWin, @CheckboxImageDisabledSelStream, hIStream
    .ENDIF

    mov eax, TRUE
    
_MUI_CheckboxLoadPng@Close:
    ret
_MUI_CheckboxLoadPng endp
ENDIF


;------------------------------------------------------------------------------
; _MUI_CheckboxPngReleaseIStream - releases png stream handle
;------------------------------------------------------------------------------
IFDEF MUI_USEGDIPLUS
MUI_ALIGN
_MUI_CheckboxPngReleaseIStream PROC hIStream:DWORD
    
    mov eax, hIStream
    push    eax
    mov     eax,DWORD PTR [eax]
    call    IStream.IUnknown.Release[eax]                               ; release the stream
    ret

_MUI_CheckboxPngReleaseIStream ENDP
ENDIF





MODERNUI_LIBEND
