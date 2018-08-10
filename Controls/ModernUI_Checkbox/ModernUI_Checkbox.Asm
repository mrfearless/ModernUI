;======================================================================================================================================
;
; ModernUI Control - ModernUI_Checkbox v1.0.0.0
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

;MUI_USEGDIPLUS EQU 1 ; comment out of you dont require png (gdiplus) support

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

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
include ole32.inc
ENDIF

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

IFDEF MUI_USEGDIPLUS
includelib gdiplus.lib
includelib ole32.lib
ENDIF

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_Checkbox.inc
include ModernUI_Checkbox_Icons.asm

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_CheckboxWndProc                    PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CheckboxInit                       PROTO :DWORD
_MUI_CheckboxCleanup                    PROTO :DWORD
_MUI_CheckboxSetColors                  PROTO :DWORD, :DWORD
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

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
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
UNKNOWN STRUCT
   QueryInterface   DWORD ?
   AddRef           DWORD ?
   Release          DWORD ?
UNKNOWN ENDS

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
szMUICheckboxClass                      DB 'ModernUI_Checkbox',0            ; Class name for creating our ModernUI_Checkbox control
szMUICheckboxFont                       DB 'Segoe UI',0                     ; Font used for ModernUI_Checkbox text
hMUICheckboxFont                        DD 0                                ; Handle to ModernUI_Checkbox font (segoe ui)

  ; File M:\GitProjects\ModernUI\icons\Dark\16px\mui_checkbox_tick_16x16.ico opened at 1150 bytes


hDefault_icoMUICheckboxTick             DD 0
hDefault_icoMUICheckboxEmpty            DD 0
hDefault_icoMUICheckboxDisabledTick     DD 0
hDefault_icoMUICheckboxDisabledEmpty    DD 0
hDefault_icoMUIRadioTick                DD 0
hDefault_icoMUIRadioEmpty               DD 0
hDefault_icoMUIRadioDisabledTick        DD 0
hDefault_icoMUIRadioDisabledEmpty       DD 0


.CODE

align 4

;-------------------------------------------------------------------------------------
; Set property for ModernUI_Checkbox control
;-------------------------------------------------------------------------------------
MUICheckboxSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUICheckboxSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for ModernUI_Checkbox control
;-------------------------------------------------------------------------------------
MUICheckboxGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUICheckboxGetProperty ENDP


;-------------------------------------------------------------------------------------
; MUICheckboxRegister - Registers the ModernUI_Checkbox control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Checkbox
;-------------------------------------------------------------------------------------
MUICheckboxRegister PROC PUBLIC
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


;-------------------------------------------------------------------------------------
; MUICheckboxCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUICheckboxCreate PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_CheckboxWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
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
        and eax, MUICS_HAND
        .IF eax == MUICS_HAND
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
            Invoke MUISetIntProperty, hWin, @CheckboxMouseOver , TRUE
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
        
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_CheckboxWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_CheckboxInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_CheckboxInit PROC PRIVATE hWin:DWORD
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
    .IF hDefault_icoMUICheckboxTick == 0
        Invoke MUICreateIconFromMemory, Addr icoMUICheckboxTick, 0
        mov hDefault_icoMUICheckboxTick, eax
    .ENDIF
    .IF hDefault_icoMUICheckboxEmpty == 0
        Invoke MUICreateIconFromMemory, Addr icoMUICheckboxEmpty, 0
        mov hDefault_icoMUICheckboxEmpty, eax
    .ENDIF
    .IF hDefault_icoMUIRadioTick == 0
        Invoke MUICreateIconFromMemory, Addr icoMUIRadioTick, 0
        mov hDefault_icoMUIRadioTick, eax
    .ENDIF
    .IF hDefault_icoMUIRadioEmpty == 0
        Invoke MUICreateIconFromMemory, Addr icoMUIRadioEmpty, 0
        mov hDefault_icoMUIRadioEmpty, eax
    .ENDIF
    .IF hDefault_icoMUIRadioDisabledEmpty == 0
        Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledEmpty, 0
        mov hDefault_icoMUIRadioDisabledEmpty, eax
    .ENDIF
    .IF hDefault_icoMUIRadioDisabledTick == 0
        Invoke MUICreateIconFromMemory, Addr icoMUIRadioDisabledTick, 0
        mov hDefault_icoMUIRadioDisabledTick, eax
    .ENDIF
    .IF hDefault_icoMUICheckboxDisabledEmpty == 0
        Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledEmpty, 0
        mov hDefault_icoMUICheckboxDisabledEmpty, eax
    .ENDIF
    .IF hDefault_icoMUICheckboxDisabledTick == 0
        Invoke MUICreateIconFromMemory, Addr icoMUICheckboxDisabledTick, 0
        mov hDefault_icoMUICheckboxDisabledTick, eax
    .ENDIF    
    
    Invoke MUISetExtProperty, hWin, @CheckboxImageType, MUICIT_ICO


    mov eax, dwStyle
    and eax, MUICS_RADIO
    .IF eax == MUICS_RADIO
        Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUIRadioEmpty
        Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUIRadioEmpty
        Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUIRadioTick
        Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUIRadioTick
        Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUIRadioDisabledEmpty
        Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUIRadioDisabledTick
    .ELSE
        Invoke MUISetExtProperty, hWin, @CheckboxImage, hDefault_icoMUICheckboxEmpty
        Invoke MUISetExtProperty, hWin, @CheckboxImageAlt, hDefault_icoMUICheckboxEmpty
        Invoke MUISetExtProperty, hWin, @CheckboxImageSel, hDefault_icoMUICheckboxTick
        Invoke MUISetExtProperty, hWin, @CheckboxImageSelAlt, hDefault_icoMUICheckboxTick
        Invoke MUISetExtProperty, hWin, @CheckboxImageDisabled, hDefault_icoMUICheckboxDisabledEmpty
        Invoke MUISetExtProperty, hWin, @CheckboxImageDisabledSel, hDefault_icoMUICheckboxDisabledTick
    .ENDIF
    ret

_MUI_CheckboxInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_CheckboxCleanup - cleanup a few things before control is destroyed
;-------------------------------------------------------------------------------------
_MUI_CheckboxCleanup PROC PRIVATE hWin:DWORD
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxSetColors - Set colors on init or syscolorchange if MUIBS_THEME style used
;-------------------------------------------------------------------------------------
_MUI_CheckboxSetColors PROC PRIVATE hWin:DWORD, bInit:DWORD

    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUICS_THEME
    .IF eax == MUICS_THEME
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
    ret
_MUI_CheckboxSetColors ENDP


;-------------------------------------------------------------------------------------
; _MUI_CheckboxButtonDown - Mouse button down or keyboard down from vk_space
;-------------------------------------------------------------------------------------
_MUI_CheckboxButtonDown PROC PRIVATE hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL rect:RECT    

    Invoke GetFocus
    .IF eax != hWin
        Invoke SetFocus, hWin
        Invoke MUISetIntProperty, hWin, @CheckboxFocusedState, FALSE
    .ENDIF

    Invoke MUISetIntProperty, hWin, @CheckboxMouseDown, TRUE
    Invoke InvalidateRect, hWin, NULL, TRUE

    ret
_MUI_CheckboxButtonDown ENDP


;-------------------------------------------------------------------------------------
; _MUI_CheckboxButtonUp - Mouse button up or keyboard up from vk_space
;-------------------------------------------------------------------------------------
_MUI_CheckboxButtonUp PROC PRIVATE hWin:DWORD
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
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @CheckboxSelectedState
    .IF eax == FALSE
        Invoke MUISetIntProperty, hWin, @CheckboxSelectedState, TRUE
    .ELSE
        Invoke MUISetIntProperty, hWin, @CheckboxSelectedState, FALSE
    .ENDIF
    Invoke InvalidateRect, hWin, NULL, TRUE
    ret
_MUI_CheckboxButtonUp ENDP


;-------------------------------------------------------------------------------------
; _MUI_CheckboxPaint
;-------------------------------------------------------------------------------------
_MUI_CheckboxPaint PROC PRIVATE hWin:DWORD
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

    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _MUI_CheckboxPaintBackground, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Images
    ;----------------------------------------------------------
    Invoke _MUI_CheckboxPaintImages, hWin, hdc, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Text
    ;----------------------------------------------------------
    Invoke _MUI_CheckboxPaintText, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Focused state
    ;----------------------------------------------------------
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxPaintBackground
;-------------------------------------------------------------------------------------
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxPaintText
;-------------------------------------------------------------------------------------
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxPaintImages
;-------------------------------------------------------------------------------------
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxPaintFocusRect
;-------------------------------------------------------------------------------------
_MUI_CheckboxPaintFocusRect PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD, bFocusedState:DWORD
    LOCAL rect:RECT

    .IF bFocusedState == FALSE
        ret
    .ENDIF

    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUICS_NOFOCUSRECT
    .IF eax == MUICS_NOFOCUSRECT
        ret
    .ENDIF

    Invoke CopyRect, Addr rect, lpRect
    Invoke InflateRect, Addr rect, MUI_CHECKBOX_FOCUSRECT_OFFSET, MUI_CHECKBOX_FOCUSRECT_OFFSET
    Invoke DrawFocusRect, hdc, Addr rect
 
    ret
_MUI_CheckboxPaintFocusRect ENDP


;-------------------------------------------------------------------------------------
; _MUI_CheckboxSetPropertyEx
;-------------------------------------------------------------------------------------
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


;-------------------------------------------------------------------------------------
; MUICheckboxLoadImages - Loads images from resource ids and stores the handles in the
; appropriate property.
;-------------------------------------------------------------------------------------
MUICheckboxLoadImages PROC PUBLIC hControl:DWORD, dwImageType:DWORD, dwResIDImage:DWORD, dwResIDImageAlt:DWORD, dwResIDImageSel:DWORD, dwResIDImageSelAlt:DWORD, dwResIDImageDisabled:DWORD, dwResIDImageDisabledSel:DWORD

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


;-------------------------------------------------------------------------------------
; MUICheckboxSetImages - Sets the property handles for image types
;-------------------------------------------------------------------------------------
MUICheckboxSetImages PROC PUBLIC hControl:DWORD, dwImageType:DWORD, hImage:DWORD, hImageAlt:DWORD, hImageSel:DWORD, hImageSelAlt:DWORD, hImageDisabled:DWORD, hImageDisabledSel:DWORD

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


;-------------------------------------------------------------------------------------
; MUICheckboxGetState
;-------------------------------------------------------------------------------------
MUICheckboxGetState PROC PUBLIC hControl:DWORD
    Invoke SendMessage, hControl, MUICM_GETSTATE, 0, 0
    ret
MUICheckboxGetState ENDP

;-------------------------------------------------------------------------------------
; MUICheckboxSetState
;-------------------------------------------------------------------------------------
MUICheckboxSetState PROC PUBLIC hControl:DWORD, bState:DWORD
    Invoke SendMessage, hControl, MUICM_SETSTATE, bState, 0
    ret
MUICheckboxSetState ENDP


;-------------------------------------------------------------------------------------
; _MUI_CheckboxLoadBitmap - if succesful, loads specified bitmap resource into the specified
; external property and returns TRUE in eax, otherwise FALSE.
;-------------------------------------------------------------------------------------
_MUI_CheckboxLoadBitmap PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResBitmap:DWORD
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxLoadIcon - if succesful, loads specified icon resource into the specified
; external property and returns TRUE in eax, otherwise FALSE.
;-------------------------------------------------------------------------------------
_MUI_CheckboxLoadIcon PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResIcon:DWORD
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
IFDEF MUI_USEGDIPLUS
_MUI_CheckboxLoadPng PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResPng:DWORD
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


;-------------------------------------------------------------------------------------
; _MUI_CheckboxPngReleaseIStream - releases png stream handle
;-------------------------------------------------------------------------------------
IFDEF MUI_USEGDIPLUS
_MUI_CheckboxPngReleaseIStream PROC hIStream:DWORD
    
    mov eax, hIStream
    push    eax
    mov     eax,DWORD PTR [eax]
    call    IStream.IUnknown.Release[eax]                               ; release the stream
    ret

_MUI_CheckboxPngReleaseIStream ENDP
ENDIF





END
