;==============================================================================
;
; ModernUI Control - ModernUI_Button
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

;MUI_DONTUSEGDIPLUS EQU 1 ; exclude (gdiplus) support

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

include ModernUI_Button.inc

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_ButtonWndProc                          PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonInit                             PROTO :DWORD
_MUI_ButtonCleanup                          PROTO :DWORD
_MUI_ButtonSetColors                        PROTO :DWORD, :DWORD

_MUI_ButtonPaint                            PROTO :DWORD
_MUI_ButtonPaintBrush                       PROTO :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintBackground                  PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintAccent                      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintText                        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintImages                      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintBorder                      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonPaintFocusRect                   PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_ButtonCalcPositions                    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

_MUI_ButtonButtonDown                       PROTO :DWORD ; WM_LBUTTONDOWN, WM_KEYDOWN + VK_SPACE
_MUI_ButtonButtonUp                         PROTO :DWORD ; WM_LBUTTONUP, WM_KEYUP + VK_SPACE


_MUI_ButtonLoadBitmap                       PROTO :DWORD, :DWORD, :DWORD
_MUI_ButtonLoadIcon                         PROTO :DWORD, :DWORD, :DWORD
IFDEF MUI_USEGDIPLUS
_MUI_ButtonLoadPng                          PROTO :DWORD, :DWORD, :DWORD
ENDIF
;_MUI_ButtonGetImageSize                     PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

IFDEF MUI_USEGDIPLUS
_MUI_ButtonPngReleaseIStream                PROTO :DWORD
ENDIF
_MUI_ButtonSetPropertyEx                    PROTO :DWORD, :DWORD, :DWORD


_MUI_ButtonUpdateBrushOrg                   PROTO :DWORD


;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External properties
IFNDEF MUI_BUTTON_PROPERTIES
MUI_BUTTON_PROPERTIES                       STRUCT
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
    dwBackColorTo                           DD ? ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorAltTo                        DD ? ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorSelTo                        DD ? ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorSelAltTo                     DD ? ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorDisabledTo                   DD ? ; Colorref, Gradient color to, -1 = not using gradients
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
    dwRightImage                            DD ?
    dwRightImageAlt                         DD ?
    dwRightImageSel                         DD ?
    dwRightImageSelAlt                      DD ?
    dwRightImageDisabled                    DD ?        
    dwNotifyTextFont                        DD ? 
    dwNotifyTextColor                       DD ? 
    dwNotifyBackColor                       DD ? 
    dwNotifyRound                           DD ? 
    dwNotifyImageType                       DD ? 
    dwNotifyImage                           DD ? 
    dwButtonNoteTextFont                    DD ?
    dwButtonNoteTextColor                   DD ?
    dwButtonNoteTextColorDisabled           DD ?
    dwButtonPaddingLeftIndent               DD ?
    dwButtonPaddingGeneral                  DD ?
    dwButtonPaddingStyle                    DD ?
    dwButtonPaddingTextImage                DD ?  
    dwButtonDllInstance                     DD ? ; Set to hInstance of dll before calling MUIButtonLoadImages or MUIButtonNotifyLoadImage if used within a dll
    dwButtonParam                           DD ?
MUI_BUTTON_PROPERTIES                       ENDS
ENDIF

; Internal properties
_MUI_BUTTON_PROPERTIES                      STRUCT
    dwEnabledState                          DD ?
    dwMouseOver                             DD ?
    dwSelectedState                         DD ?
    dwFocusedState                          DD ?
    dwMouseDown                             DD ?
    dwNotifyState                           DD ?
    lpszNotifyText                          DD ?
    lpszNoteText                            DD ?
    dwImageStream                           DD ?
    dwImageAltStream                        DD ?
    dwImageSelStream                        DD ?
    dwImageSelAltStream                     DD ?
    dwImageDisabledStream                   DD ?
    dwRightImageStream                      DD ?
    dwRightImageAltStream                   DD ?
    dwRightImageSelStream                   DD ?
    dwRightImageSelAltStream                DD ?
    dwRightImageDisabledStream              DD ?    
    dwNotifyImageStream                     DD ?
    dwImageXposition                        DD ?
    dwImageYposition                        DD ?
    dwRightImageXposition                   DD ?
    dwRightImageYposition                   DD ?
    dwNotifyImageXposition                  DD ?
    dwNotifyImageYposition                  DD ?
    dwTextXposition                         DD ?
    dwTextYposition                         DD ?
    dwNoteXposition                         DD ?
    dwNoteYposition                         DD ?
    dwButtonRecalcPositions                 DD ? ; set to TRUE in init and when properties change and/or wm_size, wm_settext, wm_setfont ? not sure if to implement or just calc on each wm_paint call
    dwDPI                                   DD ?
    dwBackBufferBitmap                      DD ?
    dwBrushBitmap                           DD ?
    dwBrush                                 DD ?
    dwBrushOrgX                             DD ?
    dwBrushOrgY                             DD ?
    dwBrushOrgOriginalX                     DD ?
    dwBrushOrgOriginalY                     DD ?
    dwBrushPos                              DD ?
_MUI_BUTTON_PROPERTIES                      ENDS

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
WM_DPICHANGED EQU 02E0h
MUI_BUTTON_ACCENTWIDTH_DEFAULT              EQU 6d ; default width of accent (accent is the small extra area that gives button an extra highlight)
MUI_BUTTON_FOCUSRECT_OFFSET                 EQU -2 ; change this to higher negative value to shrink focus rect within button

; Internal properties
@ButtonEnabledState                         EQU 0
@ButtonMouseOver                            EQU 4
@ButtonSelectedState                        EQU 8
@ButtonFocusedState                         EQU 12
@ButtonMouseDown                            EQU 16
@ButtonNotifyState                          EQU 20
@ButtonszNotifyText                         EQU 24
@ButtonszNoteText                           EQU 28
@ButtonImageStream                          EQU 32
@ButtonImageAltStream                       EQU 36
@ButtonImageSelStream                       EQU 40
@ButtonImageSelAltStream                    EQU 44
@ButtonImageDisabledStream                  EQU 48
@ButtonRightImageStream                     EQU 52
@ButtonRightImageAltStream                  EQU 56
@ButtonRightImageSelStream                  EQU 60
@ButtonRightImageSelAltStream               EQU 64
@ButtonRightImageDisabledStream             EQU 68  
@ButtonNotifyImageStream                    EQU 72
@ButtonImageXposition                       EQU 76
@ButtonImageYposition                       EQU 80
@ButtonRightImageXposition                  EQU 84
@ButtonRightImageYposition                  EQU 88
@ButtonNotifyImageXposition                 EQU 92
@ButtonNotifyImageYposition                 EQU 96
@ButtonTextXposition                        EQU 100
@ButtonTextYposition                        EQU 104
@ButtonNoteXposition                        EQU 108
@ButtonNoteYposition                        EQU 112
@ButtonRecalcPositions                      EQU 116
@ButtonDPI                                  EQU 120
@ButtonBackBufferBitmap                     EQU 124
@ButtonBrushBitmap                          EQU 128
@ButtonBrush                                EQU 132
@ButtonBrushOrgX                            EQU 136
@ButtonBrushOrgY                            EQU 140
@ButtonBrushOrgOriginalX                    EQU 144
@ButtonBrushOrgOriginalY                    EQU 148
@ButtonBrushPos                             EQU 152
; External properties


.DATA
ALIGN 4
szMUIButtonClass                            DB 'ModernUI_Button',0          ; Class name for creating our ModernUI_Button control
szMUIButtonFont                             DB 'Segoe UI',0                 ; Font used for ModernUI_Button text
hMUIButtonFont                              DD 0                            ; Handle to ModernUI_Button font (segoe ui)
hMUIButtonNotifyFont                        DD 0
hMUIButtonNoteFont                          DD 0


.DATA?
IFDEF DEBUG32
DbgVar                                      DD ?
ENDIF

.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_Button control
;------------------------------------------------------------------------------
MUIButtonSetProperty PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIButtonSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_Button control
;------------------------------------------------------------------------------
MUIButtonGetProperty PROC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIButtonGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonRegister - Registers the ModernUI_Button control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Button
;------------------------------------------------------------------------------
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


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUIButtonCreate PROC hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    ;LOCAL DPIRect:RECT
    ;LOCAL bScaled:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUIButtonRegister

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN ;or WS_TABSTOP
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN ;or WS_TABSTOP
        ;PrintText 'MUIButtonCreate setting style to WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN'
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN ;or WS_TABSTOP
    .ENDIF
    
    ; DPI Scale position and size
;    mov eax, xpos
;    mov DPIRect.left, eax
;    mov eax, ypos
;    mov DPIRect.top, eax
;    mov eax, controlwidth
;    mov DPIRect.right, eax
;    mov eax, controlheight
;    mov DPIRect.bottom, eax
;    Invoke MUIDPIScaleRect, Addr DPIRect ; eax returns TRUE if scaling was done/required
;    mov bScaled, eax
    ;PrintDec bScaled
    
    ;Invoke CreateWindowEx, NULL, Addr szMUIButtonClass, lpszText, dwNewStyle, DPIRect.left, DPIRect.top, DPIRect.right, DPIRect.bottom, hWndParent, dwResourceID, hinstance, NULL
    Invoke CreateWindowEx, NULL, Addr szMUIButtonClass, lpszText, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        ;PrintDec hControl
;        .IF bScaled == TRUE
;            ;PrintText 'scalefont'
;            Invoke SendMessage, hControl, WM_GETFONT, 0, 0
;            Invoke MUIDPIScaleFont, eax
;            .IF eax != 0
;                Invoke SendMessage, hControl, WM_SETFONT, eax, TRUE
;            .ENDIF
;            Invoke MUISetIntProperty, hControl, @ButtonDPI, TRUE
;        .ENDIF
    .ENDIF
    mov eax, hControl
    ret
MUIButtonCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_ButtonWndProc PROC USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
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
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGDIPlusStart ; for png resources if used
        ENDIF
        Invoke _MUI_ButtonInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_ButtonCleanup, hWin
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
        Invoke _MUI_ButtonPaint, hWin
        mov eax, 0
        ret

;    .ELSEIF eax == WM_SIZE
;        Invoke GetWindowLong, hWin, 0
;        .IF eax != 0 ; grab parent background
;            Invoke MUIGetIntProperty, hWin, @ButtonBackBufferBitmap
;            .IF eax == 0
;                Invoke _MUI_ButtonGetBackgroundBitmap, hWin
;                Invoke MUISetIntProperty, hWin, @ButtonBackBufferBitmap, eax
;            .ENDIF
;        .ENDIF

    .ELSEIF eax == WM_MOVE
        Invoke GetWindowLong, hWin, 0
        .IF eax != 0
            Invoke MUIGetIntProperty, hWin, @ButtonBrush
            .IF eax != 0
                Invoke MUIGetIntProperty, hWin, @ButtonBrushPos
                .IF eax == 0
                    Invoke _MUI_ButtonUpdateBrushOrg, hWin
                .ENDIF
            .ENDIF
        .ENDIF

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIBS_HAND
        .IF eax == MUIBS_HAND
            invoke LoadCursor, NULL, IDC_HAND
        .ELSE
            invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
        mov eax, 0
        ret        

;    .ELSEIF eax == WM_GETDLGCODE
;        mov eax, DLGC_WANTALLKEYS or DLGC_WANTTAB
;        ret

    .ELSEIF eax == WM_KEYUP
        mov eax, wParam
        .IF eax == VK_SPACE
            IFDEF DEBUG32
                ;PrintText 'WM_KEYUP VK_SPACE'
            ENDIF
            Invoke _MUI_ButtonButtonUp, hWin
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
            IFDEF DEBUG32
                ;PrintText 'WM_KEYDOWN VK_SPACE'
            ENDIF        
            Invoke _MUI_ButtonButtonDown, hWin
        .ENDIF

    .ELSEIF eax == WM_LBUTTONUP
        Invoke _MUI_ButtonButtonUp, hWin

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke _MUI_ButtonButtonDown, hWin

    .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUIGetIntProperty, hWin, @ButtonEnabledState
        .IF eax == TRUE   
            Invoke MUISetIntProperty, hWin, @ButtonMouseOver, TRUE
            .IF eax != TRUE
                ;Invoke ShowWindow, hWin, SW_HIDE
                Invoke InvalidateRect, hWin, NULL, TRUE
                ;Invoke ShowWindow, hWin, SW_SHOW
                mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
                mov TE.dwFlags, TME_LEAVE
                mov eax, hWin
                mov TE.hwndTrack, eax
                mov TE.dwHoverTime, NULL
                Invoke TrackMouseEvent, Addr TE
            .ENDIF
        .ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        ;Invoke MUISetIntProperty, hWin, @ButtonFocusedState, FALSE
        Invoke MUIGetIntProperty, hWin, @ButtonFocusedState
        .IF eax == FALSE
            Invoke MUISetIntProperty, hWin, @ButtonMouseOver, FALSE
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
        .IF eax == TRUE     
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, FALSE
            ;Invoke ShowWindow, hWin, SW_HIDE
            Invoke InvalidateRect, hWin, NULL, TRUE
            ;Invoke ShowWindow, hWin, SW_SHOW            
        .ELSE
            ;Invoke ShowWindow, hWin, SW_HIDE
            Invoke InvalidateRect, hWin, NULL, TRUE
            ;Invoke ShowWindow, hWin, SW_SHOW
            ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF
    
    .ELSEIF eax == WM_SETFOCUS
        Invoke MUISetIntProperty, hWin, @ButtonFocusedState, TRUE
        Invoke MUISetIntProperty, hWin, @ButtonMouseOver, TRUE
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov eax, 0
        ret

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @ButtonFocusedState, FALSE
        Invoke MUISetIntProperty, hWin, @ButtonMouseOver, FALSE
        Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
        .IF eax == TRUE     
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, FALSE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, TRUE
            ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF
        mov eax, 0
        ret
    
    
;    .ELSEIF eax == WM_DPICHANGED ; 0x02E0
;        Invoke MUIGetIntProperty,  hWin, @ButtonDPI
;        .IF eax == TRUE
;            Invoke CopyRect, Addr rect, lParam
;            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOZORDER
;            
;            Invoke SendMessage, hWin, WM_GETFONT, 0, 0
;            Invoke MUIDPIScaleFont, eax
;            .IF eax != 0
;                Invoke SendMessage, hWin, WM_SETFONT, eax, TRUE
;            .ENDIF
;            
;            ; todo, adjust and store scaled value for accent width, text indent for x, y and image ident for x, y and padding between text and image
;            
;        .ENDIF
;        mov eax, 0
;        ret
    
    ; todo - weird issue, focus on one button, click and hold, tab to next button - tab order reverses like as if shift-tab was pressed.
    
    .ELSEIF eax == WM_ENABLE
        Invoke MUISetIntProperty, hWin, @ButtonEnabledState, wParam
        ;Invoke ShowWindow, hWin, SW_HIDE
        Invoke InvalidateRect, hWin, NULL, TRUE
        ;Invoke ShowWindow, hWin, SW_SHOW
        mov eax, 0

    .ELSEIF eax == WM_SETTEXT
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ;Invoke ShowWindow, hWin, SW_HIDE
        Invoke InvalidateRect, hWin, NULL, TRUE
        ;Invoke ShowWindow, hWin, SW_SHOW
        ret

    .ELSEIF eax == WM_SETFONT
        Invoke MUISetExtProperty, hWin, @ButtonTextFont, wParam
        .IF lParam == TRUE
            Invoke ShowWindow, hWin, SW_HIDE
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke ShowWindow, hWin, SW_SHOW
        .ENDIF
    
    .ELSEIF eax == WM_SYSCOLORCHANGE
        Invoke _MUI_ButtonSetColors, hWin, FALSE
        ret
    
    ; https://www.quppa.net/blog/2013/01/02/retrieving-windows-8-theme-colours/
    ;.ELSEIF eax == WM_SETTINGCHANGE
        ; lParam points to string with value:
        ; "ImmersiveColorSet" or
        ; "WindowsThemeElement" if high contrast mode enabled
        ;ret

    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        ; by default set other similar properties when main one is set
        Invoke _MUI_ButtonSetPropertyEx, hWin, wParam, lParam
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
        Invoke InvalidateRect, hWin, NULL, TRUE
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
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_ButtonLoadPng, hWin, @ButtonNotifyImage, lParam
            ENDIF
        
        .ENDIF
        Invoke InvalidateRect, hWin, NULL, TRUE
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
        ;Invoke UpdateWindow, hWin
        ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_ButtonWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonInit - set initial default values
;------------------------------------------------------------------------------
_MUI_ButtonInit PROC hWin:DWORD
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
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN ;or WS_TABSTOP
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN ;or WS_TABSTOP
        ;PrintText '_MUI_ButtonInit setting style to WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN'
        or dwStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN ;or WS_TABSTOP
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
    
    ;PrintDec dwStyle
    
    ; Set default initial internal property values
    mov eax, dwStyle
    and eax, WS_DISABLED
    .IF eax == WS_DISABLED
        Invoke MUISetIntProperty, hWin, @ButtonEnabledState, FALSE
    .ELSE
        Invoke MUISetIntProperty, hWin, @ButtonEnabledState, TRUE
    .ENDIF
    Invoke MUISetIntProperty, hWin, @ButtonFocusedState, FALSE
    Invoke MUISetIntProperty, hWin, @ButtonMouseDown, FALSE

    ; Set default initial external color property values
    Invoke _MUI_ButtonSetColors, hWin, TRUE

    Invoke MUISetExtProperty, hWin, @ButtonPaddingLeftIndent, 0
    Invoke MUISetExtProperty, hWin, @ButtonPaddingGeneral, 4d
    Invoke MUISetExtProperty, hWin, @ButtonPaddingStyle, MUIBPS_ALL
    Invoke MUISetExtProperty, hWin, @ButtonPaddingTextImage, 8    
    
    Invoke MUISetExtProperty, hWin, @ButtonDllInstance, 0
    

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

    Invoke MUISetExtProperty, hWin, @ButtonTextFont, hMUIButtonFont
    Invoke MUISetExtProperty, hWin, @ButtonNotifyTextFont, hMUIButtonNotifyFont
    Invoke MUISetExtProperty, hWin, @ButtonNoteTextFont, hMUIButtonNoteFont

    ret
_MUI_ButtonInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonCleanup - cleanup a few things before control is destroyed
;------------------------------------------------------------------------------
_MUI_ButtonCleanup PROC hWin:DWORD
    LOCAL ImageType:DWORD
    LOCAL hIStreamImage:DWORD
    LOCAL hIStreamImageAlt:DWORD
    LOCAL hIStreamImageSel:DWORD
    LOCAL hIStreamImageSelAlt:DWORD
    LOCAL hIStreamImageDisabled:DWORD
    LOCAL hIStreamNotify:DWORD
    LOCAL hImage:DWORD
    LOCAL hImageAlt:DWORD
    LOCAL hImageSel:DWORD
    LOCAL hImageSelAlt:DWORD
    LOCAL hImageDisabled:DWORD
    LOCAL hImageNotify:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, MUIBS_KEEPIMAGES
    .IF eax == MUIBS_KEEPIMAGES
        ret
    .ENDIF
    
    IFDEF DEBUG32
    PrintText '_MUI_ButtonCleanup'
    ENDIF
    ; cleanup any stream handles if png where loaded as resources
    Invoke MUIGetExtProperty, hWin, @ButtonImageType
    mov ImageType, eax

    .IF ImageType == 0
        ret
    .ENDIF
    
    .IF ImageType == 3
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGetIntProperty, hWin, @ButtonImageStream
        mov hIStreamImage, eax
        .IF eax != 0
            Invoke _MUI_ButtonPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @ButtonImageAltStream
        mov hIStreamImageAlt, eax
        .IF eax != 0 && eax != hIStreamImage
            Invoke _MUI_ButtonPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @ButtonImageSelStream
        mov hIStreamImageSel, eax
        .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt
            Invoke _MUI_ButtonPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @ButtonImageSelAltStream
        mov hIStreamImageSelAlt, eax
        .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt && eax != hIStreamImageSel
            Invoke _MUI_ButtonPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hWin, @ButtonImageDisabledStream
        mov hIStreamImageDisabled, eax
        .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt && eax != hIStreamImageSel && eax != hIStreamImageSelAlt 
            Invoke _MUI_ButtonPngReleaseIStream, eax
        .ENDIF
        
        IFDEF DEBUG32
        ; check to see if handles are cleared.
        PrintText '_MUI_ButtonCleanup::IStream Handles cleared'
        ENDIF
        
        ENDIF        
    .ENDIF

    Invoke MUIGetExtProperty, hWin, @ButtonImage
    mov hImage, eax
    .IF eax != 0
        .IF ImageType != 3
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @ButtonImageAlt
    mov hImageAlt, eax
    .IF eax != 0 && eax != hImage
        .IF ImageType != 3
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF    
    Invoke MUIGetExtProperty, hWin, @ButtonImageSel
    mov hImageSel, eax
    .IF eax != 0 && eax != hImage && eax != hImageAlt
        .IF ImageType != 3
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF    
    Invoke MUIGetExtProperty, hWin, @ButtonImageSelAlt
    mov hImageSelAlt, eax
    .IF eax != 0 && eax != hImage && eax != hImageAlt && eax != hImageSel
        .IF ImageType != 3
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @ButtonImageDisabled
    mov hImageDisabled, eax
    .IF eax != 0 && eax != hImage && eax != hImageAlt && eax != hImageSel && eax != hImageSelAlt
        .IF ImageType != 3
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF
    

       
    IFDEF DEBUG32
    PrintText '_MUI_ButtonCleanup::Image Handles cleared'
    ENDIF
    Invoke MUIGetExtProperty, hWin, @ButtonNotifyImageType
    mov ImageType, eax
    .IF ImageType == 0
        ret
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @ButtonNotifyImage
    .IF eax != 0 && eax != hImage && eax != hImageAlt && eax != hImageSel && eax != hImageSelAlt && eax != hImageDisabled
        .IF ImageType != 3
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            
            Invoke MUIGetIntProperty, hWin, @ButtonNotifyImageStream
            .IF eax != 0 && eax != hIStreamImage && eax != hIStreamImageAlt && eax != hIStreamImageSel && eax != hIStreamImageSelAlt && eax != hIStreamImageDisabled
                Invoke GlobalFree, eax
            .ENDIF
            IFDEF DEBUG32
            PrintText '_MUI_ButtonCleanup::Notify IStream Handle cleared'
            ENDIF
            
            ENDIF 
        .ENDIF
    .ENDIF
    
    Invoke MUIGetIntProperty, hWin, @ButtonBrushBitmap
    .IF eax != 0
        Invoke DeleteObject, eax
    .ENDIF
    
    IFDEF DEBUG32
    PrintText '_MUI_ButtonCleanup::Notify Image Handles cleared'
    ENDIF
    ret

_MUI_ButtonCleanup ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonSetColors - Set colors on init or syscolorchange if MUIBS_THEME 
; style used.
;------------------------------------------------------------------------------
_MUI_ButtonSetColors PROC hWin:DWORD, bInit:DWORD

    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUIBS_THEME
    .IF eax == MUIBS_THEME
        ; Set color property values based on system colors
        Invoke GetSysColor, COLOR_BTNTEXT
        Invoke MUISetExtProperty, hWin, @ButtonTextColor, eax
        Invoke GetSysColor, COLOR_BTNTEXT
        Invoke MUISetExtProperty, hWin, @ButtonTextColorAlt, eax
        Invoke GetSysColor, COLOR_HIGHLIGHT 
        Invoke MUISetExtProperty, hWin, @ButtonTextColorSel, eax
        Invoke GetSysColor, COLOR_BTNTEXT
        Invoke MUISetExtProperty, hWin, @ButtonTextColorSelAlt, eax
        Invoke GetSysColor, COLOR_GRAYTEXT
        Invoke MUISetExtProperty, hWin, @ButtonTextColorDisabled, eax
        
        Invoke GetSysColor, COLOR_BTNFACE
        Invoke MUISetExtProperty, hWin, @ButtonBackColor, eax
        Invoke GetSysColor, COLOR_BTNFACE
        Invoke MUISetExtProperty, hWin, @ButtonBackColorAlt, eax
        Invoke GetSysColor, COLOR_BTNFACE
        Invoke MUISetExtProperty, hWin, @ButtonBackColorSel, eax
        Invoke GetSysColor, COLOR_BTNFACE
        Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAlt, eax
        Invoke GetSysColor, COLOR_SCROLLBAR
        Invoke MUISetExtProperty, hWin, @ButtonBackColorDisabled, eax

        Invoke MUISetExtProperty, hWin, @ButtonBorderStyle, MUIBBS_ALL
        Invoke GetSysColor, COLOR_SCROLLBAR
        Invoke MUISetExtProperty, hWin, @ButtonBorderColor, eax
        Invoke GetSysColor, COLOR_HIGHLIGHT
        Invoke MUISetExtProperty, hWin, @ButtonBorderColorAlt, eax
        Invoke GetSysColor, COLOR_HIGHLIGHT
        Invoke MUISetExtProperty, hWin, @ButtonBorderColorSel, eax
        Invoke GetSysColor, COLOR_HIGHLIGHT
        Invoke MUISetExtProperty, hWin, @ButtonBorderColorSelAlt, eax
        Invoke GetSysColor, COLOR_SCROLLBAR
        sub eax, 001C1C1Ch
        and eax, 00ffffffh
        .IF sdword ptr eax <= 0
            Invoke GetSysColor, COLOR_SCROLLBAR
        .ENDIF
        Invoke MUISetExtProperty, hWin, @ButtonBorderColorDisabled, eax
        
        Invoke MUISetExtProperty, hWin, @ButtonAccentColor, -1
        Invoke MUISetExtProperty, hWin, @ButtonAccentColorAlt, -1
        Invoke MUISetExtProperty, hWin, @ButtonAccentColorSel, -1
        Invoke MUISetExtProperty, hWin, @ButtonAccentColorSelAlt, -1        
        
    .ELSE
        .IF bInit == TRUE
            ; Set color property values based on custom values
            Invoke MUISetExtProperty, hWin, @ButtonTextColor, MUI_RGBCOLOR(51,51,51)
            Invoke MUISetExtProperty, hWin, @ButtonTextColorAlt, MUI_RGBCOLOR(51,51,51)
            Invoke MUISetExtProperty, hWin, @ButtonTextColorSel, MUI_RGBCOLOR(51,51,51)
            Invoke MUISetExtProperty, hWin, @ButtonTextColorSelAlt, MUI_RGBCOLOR(51,51,51)
            Invoke MUISetExtProperty, hWin, @ButtonTextColorDisabled, MUI_RGBCOLOR(204,204,204)
        
            Invoke MUIGetParentBackgroundColor, hWin
            .IF eax == -1 ; if background was NULL then try a color as default
                Invoke GetSysColor, COLOR_WINDOW
            .ENDIF
            Invoke MUISetExtProperty, hWin, @ButtonBackColor, eax ;MUI_RGBCOLOR(255,255,255)
        
            ;Invoke MUISetExtProperty, hWin, @ButtonBackColor, MUI_RGBCOLOR(255,255,255) ;MUI_RGBCOLOR(21,133,181)
            Invoke MUISetExtProperty, hWin, @ButtonBackColorAlt, MUI_RGBCOLOR(221,221,221)
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSel, MUI_RGBCOLOR(255,255,255)
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAlt, MUI_RGBCOLOR(221,221,221)
            Invoke MUISetExtProperty, hWin, @ButtonBackColorDisabled, MUI_RGBCOLOR(192,192,192)
            
            Invoke MUISetExtProperty, hWin, @ButtonBackColorTo, -1
            Invoke MUISetExtProperty, hWin, @ButtonBackColorAltTo, -1
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSelTo, -1
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAltTo, -1
            Invoke MUISetExtProperty, hWin, @ButtonBackColorDisabledTo, -1
            
            Invoke MUISetExtProperty, hWin, @ButtonBorderStyle, MUIBBS_ALL
            Invoke MUISetExtProperty, hWin, @ButtonBorderColor, MUI_RGBCOLOR(204,204,204)
            Invoke MUISetExtProperty, hWin, @ButtonBorderColorAlt, MUI_RGBCOLOR(27,161,226);MUI_RGBCOLOR(120,183,203)
            Invoke MUISetExtProperty, hWin, @ButtonBorderColorSel, MUI_RGBCOLOR(27,161,226)
            Invoke MUISetExtProperty, hWin, @ButtonBorderColorSelAlt, MUI_RGBCOLOR(27,161,226)
            Invoke MUISetExtProperty, hWin, @ButtonBorderColorDisabled, MUI_RGBCOLOR(204,204,204)
    
            Invoke MUISetExtProperty, hWin, @ButtonAccentColor, -1
            Invoke MUISetExtProperty, hWin, @ButtonAccentColorAlt, -1
            Invoke MUISetExtProperty, hWin, @ButtonAccentColorSel, -1
            Invoke MUISetExtProperty, hWin, @ButtonAccentColorSelAlt, -1
        
            Invoke MUISetExtProperty, hWin, @ButtonNotifyTextColor, MUI_RGBCOLOR(51,51,51)
            Invoke MUISetExtProperty, hWin, @ButtonNotifyBackColor, MUI_RGBCOLOR(255,255,255)
            Invoke MUISetExtProperty, hWin, @ButtonNoteTextColor, MUI_RGBCOLOR(96,96,96)
            Invoke MUISetExtProperty, hWin, @ButtonNoteTextColorDisabled, MUI_RGBCOLOR(204,204,204)
        .ENDIF
    .ENDIF
    ret

_MUI_ButtonSetColors ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonButtonDown - Mouse button down or keyboard down from vk_space
;------------------------------------------------------------------------------
_MUI_ButtonButtonDown PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL rect:RECT    

    IFDEF DEBUG32
        PrintText '_MUI_ButtonButtonDown'
    ENDIF

    Invoke GetFocus
    .IF eax != hWin
        Invoke SetFocus, hWin
        Invoke MUISetIntProperty, hWin, @ButtonFocusedState, FALSE
    .ENDIF

    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUIBS_PUSHBUTTON
    .IF eax == MUIBS_PUSHBUTTON
        Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
        .IF eax == FALSE
            Invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax
            invoke MapWindowPoints, hWin, hParent, addr rect, 2        
            add rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, TRUE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF
    .ELSE
        Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
        .IF eax == FALSE
            Invoke MUISetIntProperty, hWin, @ButtonMouseDown, TRUE
        .ENDIF
        Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF
    ret
_MUI_ButtonButtonDown ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonButtonUp - Mouse button up or keyboard up from vk_space
;------------------------------------------------------------------------------
_MUI_ButtonButtonUp PROC hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL wID:DWORD
    LOCAL rect:RECT
    
    IFDEF DEBUG32
        PrintText '_MUI_ButtonButtonUp'
    ENDIF

    Invoke MUIGetIntProperty, hWin, @ButtonMouseDown
    .IF eax == TRUE
        Invoke GetDlgCtrlID, hWin
        mov wID,eax
        Invoke GetParent, hWin
        mov hParent, eax
        Invoke PostMessage, hParent, WM_COMMAND, wID, hWin ; simulates click on our control    

        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIBS_PUSHBUTTON
        .IF eax == MUIBS_PUSHBUTTON
            Invoke GetClientRect, hWin, addr rect
            Invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER  + SWP_FRAMECHANGED
        .ENDIF
        
        Invoke MUISetIntProperty, hWin, @ButtonMouseDown, FALSE

        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUIBS_AUTOSTATE
        .IF eax == MUIBS_AUTOSTATE
            Invoke MUIGetIntProperty, hWin, @ButtonSelectedState
            .IF eax == FALSE
                Invoke MUISetIntProperty, hWin, @ButtonSelectedState, TRUE
            .ELSE
                Invoke MUISetIntProperty, hWin, @ButtonSelectedState, FALSE
            .ENDIF
        .ENDIF        
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ELSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        Invoke InvalidateRect, hWin, NULL, TRUE
    .ENDIF
    ret
_MUI_ButtonButtonUp ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaint
;------------------------------------------------------------------------------
_MUI_ButtonPaint PROC hWin:DWORD
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
    LOCAL BackColor:DWORD
    LOCAL hBackBrush:DWORD
    LOCAL FocusedState:DWORD

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Get some property values
    ;---------------------------------------------------------- 
    Invoke GetClientRect, hWin, Addr rect
    Invoke MUIGetIntProperty, hWin, @ButtonEnabledState
    mov EnabledState, eax
    Invoke MUIGetIntProperty, hWin, @ButtonMouseOver
    mov MouseOver, eax
    Invoke MUIGetIntProperty, hWin, @ButtonSelectedState
    mov SelectedState, eax
    Invoke MUIGetIntProperty, hWin, @ButtonFocusedState
    mov FocusedState, eax
    Invoke MUIGetIntProperty, hWin, @ButtonBrush
    mov hBackBrush, eax

    .IF EnabledState == TRUE
        .IF SelectedState == FALSE
            .IF MouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColor        ; Normal back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorAlt     ; Mouse over back color
            .ENDIF
        .ELSE
            .IF MouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSel     ; Selected back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonBackColorDisabled        ; Disabled back color
    .ENDIF
    mov BackColor, eax

    .IF BackColor != -1 ; Not transparent, back color provided

        ;----------------------------------------------------------
        ; Setup Double Buffering
        ;----------------------------------------------------------
        Invoke CreateCompatibleDC, hdc
        mov hdcMem, eax
        Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
        mov hbmMem, eax
        Invoke SelectObject, hdcMem, hbmMem
        mov hOldBitmap, eax
    
        ;----------------------------------------------------------
        ; Background
        ;----------------------------------------------------------
        Invoke _MUI_ButtonPaintBackground, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState
    
        ;----------------------------------------------------------
        ; Accent
        ;----------------------------------------------------------
        Invoke _MUI_ButtonPaintAccent, hWin, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState
    
        ;----------------------------------------------------------
        ; calc positions for text and images
        ;----------------------------------------------------------    
        ;Invoke _MUI_ButtonCalcPositions, hWin, hdc, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState
    
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
        ; Focused state
        ;----------------------------------------------------------
        Invoke _MUI_ButtonPaintFocusRect, hWin, hdcMem, Addr rect, FocusedState
        
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

    .ELSE ; Transparent background
    
        ;----------------------------------------------------------
        ; Setup Double Buffering
        ;----------------------------------------------------------
        Invoke CreateCompatibleDC, hdc
        mov hdcMem, eax
        
        .IF hBackBrush != 0
            Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
            mov hbmMem, eax
        .ELSE
            Invoke MUIGetParentBackgroundBitmap, hWin
            mov hbmMem, eax
        .ENDIF
            Invoke SelectObject, hdcMem, hbmMem
            mov hOldBitmap, eax
        ;.ELSE
        ;    mov hbmMem, 0
        ;    mov hOldBitmap, 0
        ;.ENDIF
        
        ;----------------------------------------------------------
        ; Brush
        ;----------------------------------------------------------
        Invoke _MUI_ButtonPaintBrush, hWin, hdcMem, Addr rect
    
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
        ; Focused state
        ;----------------------------------------------------------
        Invoke _MUI_ButtonPaintFocusRect, hWin, hdcMem, Addr rect, FocusedState

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
        .IF hbmMem != 0
            Invoke SelectObject, hdcMem, hbmMem
            Invoke DeleteObject, hbmMem
        .ENDIF
        Invoke DeleteDC, hdcMem

    .ENDIF
    
    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_ButtonPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaintBackground
;------------------------------------------------------------------------------
_MUI_ButtonPaintBackground PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BackColor:DWORD
    LOCAL BackColorTo:DWORD
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
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @ButtonBackColor                ; fallback to default Normal back color
    .ENDIF
    mov BackColor, eax
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorTo      ; Normal back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorAltTo   ; Mouse over back color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelTo   ; Selected back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelAltTo; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonBackColorDisabledTo      ; Disabled back color
    .ENDIF
    mov BackColorTo, eax
    
    .IF BackColorTo == -1
        Invoke MUIGDIPaintFill, hdc, lpRect, BackColor
    .ELSE
        Invoke MUIGDIPaintGradient, hdc, lpRect, BackColor, BackColorTo, MUIPGS_VERT
    .ENDIF
    
    ret
_MUI_ButtonPaintBackground ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaintBrush
;------------------------------------------------------------------------------
_MUI_ButtonPaintBrush PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL hBackBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL dwXOrg:DWORD
    LOCAL dwYOrg:DWORD
    LOCAL rect:RECT
    
    Invoke MUIGetIntProperty, hWin, @ButtonBrush
    .IF eax == 0
        ret
    .ENDIF
    mov hBackBrush, eax

    Invoke MUIGetIntProperty, hWin, @ButtonBrushOrgX
    mov dwXOrg, eax
    Invoke MUIGetIntProperty, hWin, @ButtonBrushOrgY
    mov dwYOrg, eax
    
    ;Invoke CopyRect, Addr rect, lpRect
    
    Invoke MUIGDIPaintBrush, hdc, lpRect, hBackBrush, dwXOrg, dwYOrg

;    Invoke CopyRect, Addr rect, lpRect
;
;    Invoke SelectObject, hdc, hBackBrush
;    mov hOldBrush, eax
;    ;Invoke SetBrushOrgEx, hdc, 0, 0, 0; //Set the brush origin (relative placement)
;    Invoke SetBrushOrgEx, hdc, dwXOrg, dwYOrg, 0; //Set the brush origin (relative placement)     
;    Invoke FillRect, hdc, Addr rect, hBackBrush
;    Invoke SetBrushOrgEx, hdc, 0, 0, 0; //Set the brush origin (relative placement)
;    .IF hOldBrush != 0
;        Invoke SelectObject, hdc, hOldBrush
;        Invoke DeleteObject, hOldBrush
;    .ENDIF

    ret
_MUI_ButtonPaintBrush ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaintAccent
;------------------------------------------------------------------------------
_MUI_ButtonPaintAccent PROC USES EBX hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
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

    .IF AccentColor != -1 ; not transparent
        
        Invoke CopyRect, Addr rect, lpRect
        
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
                mov eax, MUI_BUTTON_ACCENTWIDTH_DEFAULT
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
                mov eax, MUI_BUTTON_ACCENTWIDTH_DEFAULT
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
                mov ebx, MUI_BUTTON_ACCENTWIDTH_DEFAULT
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
                mov ebx, MUI_BUTTON_ACCENTWIDTH_DEFAULT
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
                mov eax, MUI_BUTTON_ACCENTWIDTH_DEFAULT
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, rect.bottom
                mov AccentRect.bottom, eax
                Invoke FillRect, hdc, Addr AccentRect, hBrush

                mov AccentRect.left, 0
                mov eax, rect.right
                mov AccentRect.right, eax
                mov AccentRect.top, 0
                mov eax, MUI_BUTTON_ACCENTWIDTH_DEFAULT
                mov AccentRect.bottom, eax
                Invoke FillRect, hdc, Addr AccentRect, hBrush
                
                mov eax, rect.right
                mov ebx, MUI_BUTTON_ACCENTWIDTH_DEFAULT
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
                mov ebx, MUI_BUTTON_ACCENTWIDTH_DEFAULT
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


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonCalcPositions - calculate x, y positions of images, text etc
;------------------------------------------------------------------------------
_MUI_ButtonCalcPositions PROC USES EBX hWin:DWORD, hdcMain:DWORD, hdcDest:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL dwStyle:DWORD
    LOCAL hImage:DWORD
    LOCAL ImageType:DWORD
    LOCAL NotifyImageType:DWORD
    LOCAL hNotifyImage:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    LOCAL sz:_SIZE
    LOCAL lpszNotifyText:DWORD
    LOCAL LenNotifyText:DWORD
    LOCAL szText[256]:BYTE
    LOCAL xpos:DWORD
    LOCAL ypos:DWORD
    LOCAL paddingstyle:DWORD
    LOCAL padding:DWORD
    LOCAL indent:DWORD

    mov xpos, 0
    mov ypos, 0

    Invoke CopyRect, Addr rect, lpRect
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax

    ;--------------------------------------------------------------
    ; Padding & Indent
    ;--------------------------------------------------------------
    
    mov eax, dwStyle
    and eax, MUIBS_BOTTOM 
    .IF eax != MUIBS_BOTTOM    
        Invoke MUIGetExtProperty, hWin, @ButtonPaddingLeftIndent
        .IF eax > 0
            add xpos, eax ; add indent to xpos
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @ButtonPaddingGeneral
        .IF eax > 0
            mov padding, eax
            
            Invoke MUIGetExtProperty, hWin, @ButtonPaddingStyle
            mov paddingstyle, eax
            
            .IF eax != MUIBPS_NONE
                mov eax, paddingstyle
                and eax, MUIBPS_LEFT
                .IF eax == MUIBPS_LEFT
                    mov eax, padding
                    add xpos, eax
                .ENDIF
    
                mov eax, paddingstyle
                and eax, MUIBPS_TOP
                .IF eax == MUIBPS_TOP
                    mov eax, padding
                    add ypos, eax
                .ENDIF
    
                mov eax, paddingstyle
                and eax, MUIBPS_RIGHT
                .IF eax == MUIBPS_RIGHT
                    mov eax, padding
                    sub rect.right, eax
                .ENDIF
    
                mov eax, paddingstyle
                and eax, MUIBPS_BOTTOM
                .IF eax == MUIBPS_BOTTOM
                    mov eax, padding
                    sub rect.bottom, eax
                .ENDIF
            .ENDIF
    
        .ENDIF
    .ENDIF
    
    ;--------------------------------------------------------------
    ; Image position
    ;--------------------------------------------------------------
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

    .IF hImage != 0
        
        Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight
        ;Invoke _MUI_ButtonGetImageSize, hWin, ImageType, hImage, Addr ImageWidth, Addr ImageHeight
        
        mov eax, dwStyle
        and eax, MUIBS_BOTTOM 
        .IF eax == MUIBS_BOTTOM
        
            Invoke MUIGetExtProperty, hWin, @ButtonPaddingGeneral
            .IF eax > 0
                mov padding, eax
                add ypos, eax
            .ENDIF        
        
            mov eax, rect.right
            mov ebx, ImageWidth
            sub eax, ebx
            shr eax, 1 ; div by 1
            mov xpos, eax
        .ELSE
            mov eax, rect.bottom
            mov ebx, ImageHeight
            sub eax, ebx
            shr ebx, 1
            add ypos, eax
        .ENDIF         
    .ENDIF
    Invoke MUISetIntProperty, hWin, @ButtonImageXposition, xpos
    Invoke MUISetIntProperty, hWin, @ButtonImageYposition, ypos
    

    ;--------------------------------------------------------------
    ; Text position
    ;--------------------------------------------------------------
    .IF hImage != 0
        mov eax, ImageWidth
        add xpos, eax
        Invoke MUIGetExtProperty, hWin, @ButtonPaddingTextImage
        add xpos, eax
    .ENDIF
    Invoke MUISetIntProperty, hWin, @ButtonTextXposition, xpos
    Invoke MUISetIntProperty, hWin, @ButtonTextYposition, ypos


    mov eax, dwStyle
    and eax, MUIBS_BOTTOM 
    .IF eax != MUIBS_BOTTOM

        ;--------------------------------------------------------------
        ; Note text position
        ;--------------------------------------------------------------
        Invoke MUISetIntProperty, hWin, @ButtonNoteXposition, xpos
        
        ; ypos based on getextent of ypos + (text height *2 - textnote height)
        ;Invoke MUISetIntProperty, hWin, @ButtonNoteYposition, ypos
        
        ;--------------------------------------------------------------
        ; Notify Image Position
        ;--------------------------------------------------------------
        ; decide on notify image position based on property? after text + a small bit of padding
        ; or before right image (+ small padding) or right side if no right image?
        Invoke MUISetIntProperty, hWin, @ButtonNotifyImageXposition, xpos
        Invoke MUISetIntProperty, hWin, @ButtonNotifyImageYposition, ypos
        
        
        
        ;--------------------------------------------------------------
        ; Right Image Position
        ;--------------------------------------------------------------
        .IF bEnabledState == TRUE
            .IF bSelectedState == FALSE
                .IF bMouseOver == FALSE
                    Invoke MUIGetExtProperty, hWin, @ButtonRightImage        ; Normal image
                .ELSE
                    Invoke MUIGetExtProperty, hWin, @ButtonRightImageAlt     ; Mouse over image
                .ENDIF
            .ELSE
                .IF bMouseOver == FALSE
                    Invoke MUIGetExtProperty, hWin, @ButtonRightImageSel     ; Selected image
                .ELSE
                    Invoke MUIGetExtProperty, hWin, @ButtonRightImageSelAlt  ; Selected mouse over image 
                .ENDIF
            .ENDIF
        .ELSE
            Invoke MUIGetExtProperty, hWin, @ButtonRightImageDisabled        ; Disabled image
        .ENDIF
        mov hImage, eax    
    
        .IF hImage != 0
            Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight
            ;Invoke _MUI_ButtonGetImageSize, hWin, ImageType, hImage, Addr ImageWidth, Addr ImageHeight
            
            mov eax, rect.right
            sub eax, ImageWidth
            mov xpos, eax
            
            mov eax, rect.bottom
            mov ebx, ImageHeight
            sub eax, ebx
            shr ebx, 1
            add ypos, eax
            
            Invoke MUISetIntProperty, hWin, @ButtonRightImageXposition, xpos
            Invoke MUISetIntProperty, hWin, @ButtonRightImageYposition, ypos            
            
        .ELSE
            Invoke MUISetIntProperty, hWin, @ButtonRightImageXposition, 0
            Invoke MUISetIntProperty, hWin, @ButtonRightImageYposition, 0    
        .ENDIF

    .ELSE
        Invoke MUISetIntProperty, hWin, @ButtonNoteXposition, 0
        Invoke MUISetIntProperty, hWin, @ButtonNoteYposition, 0    
        Invoke MUISetIntProperty, hWin, @ButtonNotifyImageXposition, 0
        Invoke MUISetIntProperty, hWin, @ButtonNotifyImageYposition, 0    
        Invoke MUISetIntProperty, hWin, @ButtonRightImageXposition, 0
        Invoke MUISetIntProperty, hWin, @ButtonRightImageYposition, 0     
    .ENDIF
    
    ret

_MUI_ButtonCalcPositions ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaintText
;------------------------------------------------------------------------------
_MUI_ButtonPaintText PROC USES EBX hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL BackColorTo:DWORD
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
    LOCAL lpszNotifyText:DWORD
    LOCAL LenNotifyText:DWORD
    LOCAL szText[256]:BYTE
    LOCAL LenText:DWORD

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
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @ButtonBackColor                ; fallback to default Normal back color
    .ENDIF    
    mov BackColor, eax    
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorTo      ; Normal back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorAltTo   ; Mouse over back color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelTo   ; Selected back color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelAltTo; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonBackColorDisabledTo      ; Disabled back color
    .ENDIF
    mov BackColorTo, eax
    
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
    .IF eax == 0 ; try to get default text color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @ButtonTextColor                ; fallback to default Normal text color
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
    
    Invoke lstrlen, Addr szText
    mov LenText, eax
    
    mov rect.left, 8
    ;mov rect.top, 4
    ;sub rect.bottom, 4
    sub rect.right, 4
    
    .IF hImage != 0
        
        Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight
        ;Invoke _MUI_ButtonGetImageSize, hWin, ImageType, hImage, Addr ImageWidth, Addr ImageHeight

        mov eax, ImageWidth
        add rect.left, eax
        add rect.left, 8d
        
        mov eax, dwStyle
        and eax, MUIBS_BOTTOM 
        .IF eax == MUIBS_BOTTOM
            ;mov eax, rect.bottom
            ;sub eax, 4d
            ;mov ebx, ImageHeight
            ;sub eax, ebx
            ;mov rect.top, eax
            Invoke CopyRect, Addr rect, lpRect
            mov eax, rect.bottom
            shr eax, 1
            ;mov ebx, ImageHeight
            ;shr ebx, 1
            ;add eax, ebx
            mov rect.top, eax

            
        .ELSE
        
;            Invoke GetTextExtentPoint32, hdc, Addr szText, LenText, Addr sz
;
;            mov eax, rect.bottom
;            shr eax, 1
;            mov ebx, sz.y
;            shr ebx, 1
;            sub eax, ebx
;            mov rect.top, eax
;            
;            mov eax, rect.bottom
;            shr eax, 1
;            mov ebx, sz.y
;            shr ebx, 1
;            add eax, ebx
;            mov rect.bottom, eax
        
            ;mov eax, rect.bottom
            ;shr eax, 1
            ;mov ebx, ImageHeight
            ;shr ebx, 1
            ;sub eax, ebx
            ;mov rect.top, eax
        .ENDIF        
        
    .ENDIF
    
    Invoke MUIGetExtProperty, hWin, @ButtonNotifyImageType        
    mov NotifyImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png

    .IF bEnabledState == TRUE
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyImage        ; Normal Notify image
    .ENDIF
    mov hNotifyImage, eax      
    
    .IF hNotifyImage != 0
        
        Invoke MUIGetImageSize, hNotifyImage, NotifyImageType, Addr ImageWidth, Addr ImageHeight
        ;Invoke _MUI_ButtonGetImageSize, hWin, NotifyImageType, hNotifyImage, Addr ImageWidth, Addr ImageHeight
        ;PrintDec ImageWidth
        mov eax, ImageWidth
        sub rect.right, eax
        sub rect.right, 4d
        ;PrintDec rect.right
    .ENDIF

    
    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax
    Invoke GetWindowText, hWin, Addr szText, sizeof szText

    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    
    mov eax, BackColor
    .IF eax != -1 ; not transparent
        .IF BackColorTo == -1 || eax == BackColorTo
            Invoke SetBkMode, hdc, OPAQUE
            Invoke SetBkColor, hdc, BackColor
        .ELSE
            Invoke SetBkMode, hdc, TRANSPARENT
        .ENDIF
    .ELSE 
        Invoke SetBkMode, hdc, TRANSPARENT
    .ENDIF
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
        or dwTextStyle, DT_CENTER or DT_VCENTER;DT_BOTTOM
    .ELSE ; center
        or dwTextStyle, DT_VCENTER
    .ENDIF
    
    Invoke DrawText, hdc, Addr szText, -1, Addr rect, dwTextStyle
    
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
        .IF eax != 0
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
            ;Invoke SetBkColor, hdc, BackColor    
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
        .ENDIF
    .ENDIF
    
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

    ret

_MUI_ButtonPaintText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaintImages
;------------------------------------------------------------------------------
_MUI_ButtonPaintImages PROC USES EBX hWin:DWORD, hdcMain:DWORD, hdcDest:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
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
        .IF eax == 0 ; try to get default image if none others have a valid handle
            Invoke MUIGetExtProperty, hWin, @ButtonImage                ; fallback to default Normal image
        .ENDIF
        mov hImage, eax
    .ELSE
        mov hImage, 0
    .ENDIF
    
    .IF hImage != 0
    
        Invoke CopyRect, Addr rect, lpRect
        
        Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight
        ;Invoke _MUI_ButtonGetImageSize, hWin, ImageType, hImage, Addr ImageWidth, Addr ImageHeight
        
        mov pt.x, 8d
        mov pt.y, 4d
        mov eax, dwStyle
        and eax, MUIBS_BOTTOM 
        .IF eax == MUIBS_BOTTOM
            ;mov eax, rect.bottom
            ;sub eax, 4d
            ;mov ebx, ImageHeight
            ;sub eax, ebx
            
            ; take a 1/4 from bottom
            mov eax, rect.bottom
            shr eax, 2
            sub rect.bottom, eax
            
            ; center based on image height and new height (bottom)
            mov eax, rect.bottom
            shr eax, 1
            mov ebx, ImageHeight
            shr ebx, 1
            sub eax, ebx
            mov pt.y, eax
            
            mov eax, rect.right
            shr eax, 1
            mov ebx, ImageWidth
            shr ebx, 1
            sub eax, ebx
            mov pt.x, eax
            
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
            IFDEF MUI_USEGDIPLUS
;            PrintText 'hImage'
;            PrintDec ImageWidth
;            PrintDec ImageHeight
;            PrintDec pt.x
;            PrintDec pt.y        
        
        
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

    
    Invoke MUIGetIntProperty, hWin, @ButtonNotifyState
    .IF eax == FALSE
        ret
    .ENDIF

    Invoke MUIGetExtProperty, hWin, @ButtonNotifyImageType        
    mov NotifyImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png

    ; Notify Image
    .IF NotifyImageType != 0
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyImage        ; Normal Notify image
        mov hNotifyImage, eax
    .ELSE
        ret
    .ENDIF
    

    
    .IF hNotifyImage != 0
        
        Invoke CopyRect, Addr rect, lpRect
        
        Invoke MUIGetImageSize, hNotifyImage, NotifyImageType, Addr ImageWidth, Addr ImageHeight
        ;Invoke _MUI_ButtonGetImageSize, hWin, NotifyImageType, hNotifyImage, Addr ImageWidth, Addr ImageHeight
        
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
            IFDEF MUI_USEGDIPLUS
;            PrintText 'hNotifyImage'
;            PrintDec ImageWidth
;            PrintDec ImageHeight
;            PrintDec pt.x
;            PrintDec pt.y
        
            Invoke GdipCreateFromHDC, hdcDest, Addr pGraphics
            
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
            ENDIF
        .ENDIF
    
    .ENDIF     
    
    
    
    ret

_MUI_ButtonPaintImages ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaintBorder
;------------------------------------------------------------------------------
_MUI_ButtonPaintBorder PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
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
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColor        ; Normal border color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColorAlt     ; Mouse over border color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColorSel     ; Selected border color
            .ELSE
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColorSelAlt  ; Selected mouse over border color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @ButtonBorderColorDisabled        ; Disabled border color
    .ENDIF
    mov BorderColor, eax
    
    Invoke MUIGetExtProperty, hWin, @ButtonBorderStyle
    mov BorderStyle, eax
    
    Invoke MUIGDIPaintFrame, hdc, lpRect, BorderColor, BorderStyle

    ret
_MUI_ButtonPaintBorder ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonPaintFocusRect
;------------------------------------------------------------------------------
_MUI_ButtonPaintFocusRect PROC hWin:DWORD, hdc:DWORD, lpRect:DWORD, bFocusedState:DWORD
    ;LOCAL hPen:DWORD
    ;LOCAL hOldPen:DWORD
    LOCAL rect:RECT
    ;LOCAL pt:POINT
    ;LOCAL old_rop:DWORD
        
    ;PrintText '_MUI_ButtonPaintFocusRect'
    
    .IF bFocusedState == FALSE
        ret
    .ENDIF

    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, MUIBS_NOFOCUSRECT
    .IF eax == MUIBS_NOFOCUSRECT
        ret
    .ENDIF
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    and eax, WS_TABSTOP
    .IF eax != WS_TABSTOP
        ret
    .ENDIF    

    Invoke CopyRect, Addr rect, lpRect
    Invoke InflateRect, Addr rect, MUI_BUTTON_FOCUSRECT_OFFSET, MUI_BUTTON_FOCUSRECT_OFFSET
    Invoke DrawFocusRect, hdc, Addr rect

;    Invoke CreatePen, PS_DOT, 1, MUI_RGBCOLOR(0,0,0) ;
;    mov hPen, eax
;    Invoke SelectObject, hdc, hPen
;    mov hOldPen, eax 
;    Invoke SetROP2, hdc, R2_XORPEN
;    mov old_rop, eax
;    
;    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
;    Invoke LineTo, hdc, rect.right, rect.top
;    ;dec rect.right
;    ;inc rect.bottom                
;    Invoke MoveToEx, hdc, rect.right, rect.top, Addr pt
;    Invoke LineTo, hdc, rect.right, rect.bottom
;    ;inc rect.right
;    ;dec rect.bottom
;    Invoke MoveToEx, hdc, rect.left, rect.bottom, Addr pt
;    Invoke LineTo, hdc, rect.right, rect.bottom
;    ;inc rect.bottom
;    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
;    Invoke LineTo, hdc, rect.left, rect.bottom
;    ;.IF old_rop != 0
;    ;    Invoke SetROP2, hdc, old_rop
;    ;.ENDIF
;    .IF hOldPen != 0
;        Invoke SelectObject, hdc, hOldPen
;        Invoke DeleteObject, hOldPen
;    .ENDIF
;    .IF hPen != 0
;        Invoke DeleteObject, hPen
;    .ENDIF    
    ret
_MUI_ButtonPaintFocusRect ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonSetPropertyEx
;------------------------------------------------------------------------------
_MUI_ButtonSetPropertyEx PROC USES EBX hWin:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    
    mov eax, dwProperty
    .IF eax == @ButtonTextFont || eax == @ButtonNoteTextFont || eax == @ButtonNotifyTextFont
        .IF dwPropertyValue != 0
            Invoke MUISetExtProperty, hWin, dwProperty, dwPropertyValue
            ret
        .ENDIF    
    .ENDIF
    
    Invoke MUISetExtProperty, hWin, dwProperty, dwPropertyValue
    
    mov eax, dwProperty
    .IF eax == @ButtonTextColor ; set other text colors to this if they are not set
        Invoke MUIGetExtProperty, hWin, @ButtonTextColorAlt
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonTextColorAlt, dwPropertyValue
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @ButtonTextColorSel
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonTextColorSel, dwPropertyValue
        .ENDIF
        ; except this, if sel has a color, then use this for selalt if it has a value
        Invoke MUIGetExtProperty, hWin, @ButtonTextColorSelAlt
        .IF eax == 0
            Invoke MUIGetExtProperty, hWin, @ButtonTextColorSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonTextColorSelAlt, dwPropertyValue
            .ELSE
                Invoke MUISetExtProperty, hWin, @ButtonTextColorSelAlt, eax
            .ENDIF
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @ButtonNotifyTextColor
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonNotifyTextColor, dwPropertyValue
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @ButtonNoteTextColor
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonNoteTextColor, dwPropertyValue
        .ENDIF
    
    .ELSEIF eax == @ButtonTextColorSel
        Invoke MUIGetExtProperty, hWin, @ButtonTextColorSelAlt
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonTextColorSelAlt, dwPropertyValue
        .ENDIF
    
    .ELSEIF eax == @ButtonBackColor
    
        .IF dwPropertyValue == -1 ; set all other related properties to same value
            Invoke MUISetExtProperty, hWin, @ButtonBackColorAlt, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSel, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAlt, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBackColorDisabled, dwPropertyValue
        .ELSE
            Invoke MUIGetExtProperty, hWin, @ButtonBackColorAlt
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonBackColorAlt, dwPropertyValue
            .ENDIF
            Invoke MUIGetExtProperty, hWin, @ButtonBackColorSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonBackColorSel, dwPropertyValue
            .ENDIF
            ; except this, if sel has a color, then use this for selalt if it has a value
            Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelAlt
            .IF eax == 0
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSel
                .IF eax == 0
                    Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAlt, dwPropertyValue
                .ELSE
                    Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAlt, eax
                .ENDIF
            .ENDIF
            Invoke MUIGetExtProperty, hWin, @ButtonNotifyBackColor
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonNotifyBackColor, dwPropertyValue
            .ENDIF
        .ENDIF

    .ELSEIF eax == @ButtonBackColorTo
    
        .IF dwPropertyValue == -1 ; set all other related properties to same value
            Invoke MUISetExtProperty, hWin, @ButtonBackColorAltTo, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSelTo, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAltTo, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBackColorDisabledTo, dwPropertyValue
        .ELSE
            Invoke MUIGetExtProperty, hWin, @ButtonBackColorAltTo
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonBackColorAltTo, dwPropertyValue
            .ENDIF
            Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelTo
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonBackColorSelTo, dwPropertyValue
            .ENDIF
            ; except this, if sel has a color, then use this for selalt if it has a value
            Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelAltTo
            .IF eax == 0
                Invoke MUIGetExtProperty, hWin, @ButtonBackColorSelTo
                .IF eax == 0
                    Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAltTo, dwPropertyValue
                .ELSE
                    Invoke MUISetExtProperty, hWin, @ButtonBackColorSelAltTo, eax
                .ENDIF
            .ENDIF
        .ENDIF

    .ELSEIF eax == @ButtonBorderColor
    
        .IF dwPropertyValue == -1 ; set all other related properties to same value
            Invoke MUISetExtProperty, hWin, @ButtonBorderColorAlt, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBorderColorSel, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonBorderColorSelAlt, dwPropertyValue
        .ELSE    
            Invoke MUIGetExtProperty, hWin, @ButtonBorderColorAlt
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonBorderColorAlt, dwPropertyValue
            .ENDIF
            Invoke MUIGetExtProperty, hWin, @ButtonBorderColorSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonBorderColorSel, dwPropertyValue
            .ENDIF
            ; except this, if sel has a color, then use this for selalt if it has a value
            Invoke MUIGetExtProperty, hWin, @ButtonBorderColorSelAlt
            .IF eax == 0
                Invoke MUIGetExtProperty, hWin, @ButtonBorderColorSel
                .IF eax == 0
                    Invoke MUISetExtProperty, hWin, @ButtonBorderColorSelAlt, dwPropertyValue
                .ELSE
                    Invoke MUISetExtProperty, hWin, @ButtonBorderColorSelAlt, eax
                .ENDIF
            .ENDIF
            
            ; if setting border color and style was previously set to none, change to all borders
            Invoke MUIGetExtProperty, hWin, @ButtonBorderStyle
            .IF eax == MUIBBS_NONE
                Invoke MUISetExtProperty, hWin, @ButtonBorderStyle, MUIBBS_ALL
            .ENDIF
        .ENDIF

    .ELSEIF eax == @ButtonBorderColorAlt
        ; if setting border color and style was previously set to none, change to all borders
        Invoke MUIGetExtProperty, hWin, @ButtonBorderStyle
        .IF eax == MUIBBS_NONE
            Invoke MUISetExtProperty, hWin, @ButtonBorderStyle, MUIBBS_ALL
        .ENDIF

    .ELSEIF eax == @ButtonBorderColorSel
        ; if setting border color and style was previously set to none, change to all borders
        Invoke MUIGetExtProperty, hWin, @ButtonBorderStyle
        .IF eax == MUIBBS_NONE
            Invoke MUISetExtProperty, hWin, @ButtonBorderStyle, MUIBBS_ALL
        .ENDIF

    .ELSEIF eax == @ButtonBorderColorSelAlt
        ; if setting border color and style was previously set to none, change to all borders
        Invoke MUIGetExtProperty, hWin, @ButtonBorderStyle
        .IF eax == MUIBBS_NONE
            Invoke MUISetExtProperty, hWin, @ButtonBorderStyle, MUIBBS_ALL
        .ENDIF

    .ELSEIF eax == @ButtonAccentColor
    
        .IF dwPropertyValue == -1 ; set all other related properties to same value
            Invoke MUISetExtProperty, hWin, @ButtonAccentColorAlt, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonAccentColorSel, dwPropertyValue
            Invoke MUISetExtProperty, hWin, @ButtonAccentColorSelAlt, dwPropertyValue
        .ELSE
            Invoke MUIGetExtProperty, hWin, @ButtonAccentColorAlt
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonAccentColorAlt, dwPropertyValue
            .ENDIF
            Invoke MUIGetExtProperty, hWin, @ButtonAccentColorSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonAccentColorSel, dwPropertyValue
            .ENDIF
            ; except this, if sel has a color, then use this for selalt if it has a value
            Invoke MUIGetExtProperty, hWin, @ButtonAccentColorSelAlt
            .IF eax == 0
                Invoke MUIGetExtProperty, hWin, @ButtonAccentColorSel
                .IF eax == 0
                    Invoke MUISetExtProperty, hWin, @ButtonAccentColorSelAlt, dwPropertyValue
                .ELSE
                    Invoke MUISetExtProperty, hWin, @ButtonAccentColorSelAlt, eax
                .ENDIF
            .ENDIF
            
            ; if setting accent color and style was previously set to none, change to default
            Invoke MUIGetExtProperty, hWin, @ButtonAccentStyle
            .IF eax == MUIBAS_NONE
                Invoke MUISetExtProperty, hWin, @ButtonAccentStyle, MUIBAS_LEFT
            .ENDIF
        .ENDIF

    .ELSEIF eax == @ButtonAccentColorAlt
        ; if setting accent color and style was previously set to none, change to default
        Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleAlt
        .IF eax == MUIBAS_NONE
            Invoke MUISetExtProperty, hWin, @ButtonAccentStyleAlt, MUIBAS_LEFT
        .ENDIF

    .ELSEIF eax == @ButtonAccentColorSel
        ; if setting accent color and style was previously set to none, change to default
        Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleSel
        .IF eax == MUIBAS_NONE
            Invoke MUISetExtProperty, hWin, @ButtonAccentStyleSel, MUIBAS_LEFT
        .ENDIF

    .ELSEIF eax == @ButtonAccentColorSelAlt
        ; if setting accent color and style was previously set to none, change to default
        Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleSelAlt
        .IF eax == MUIBAS_NONE
            Invoke MUISetExtProperty, hWin, @ButtonAccentStyleSelAlt, MUIBAS_LEFT
        .ENDIF

    .ELSEIF eax == @ButtonAccentStyle
        Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleAlt
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonAccentStyleAlt, dwPropertyValue
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleSel
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonAccentStyleSel, dwPropertyValue
        .ENDIF
        ; except this, if sel has a color, then use this for selalt if it has a value
        Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleSelAlt
        .IF eax == 0
            Invoke MUIGetExtProperty, hWin, @ButtonAccentStyleSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonAccentStyleSelAlt, dwPropertyValue
            .ELSE
                Invoke MUISetExtProperty, hWin, @ButtonAccentStyleSelAlt, eax
            .ENDIF
        .ENDIF      


    

    .ELSEIF eax == @ButtonImage
        Invoke MUIGetExtProperty, hWin, @ButtonImageAlt
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonImageAlt, dwPropertyValue
        .ENDIF
        Invoke MUIGetExtProperty, hWin, @ButtonImageSel
        .IF eax == 0
            Invoke MUISetExtProperty, hWin, @ButtonImageSel, dwPropertyValue
        .ENDIF
        ; except this, if sel has a color, then use this for selalt if it has a value
        Invoke MUIGetExtProperty, hWin, @ButtonImageSelAlt
        .IF eax == 0
            Invoke MUIGetExtProperty, hWin, @ButtonImageSel
            .IF eax == 0
                Invoke MUISetExtProperty, hWin, @ButtonImageSelAlt, dwPropertyValue
            .ELSE
                Invoke MUISetExtProperty, hWin, @ButtonImageSelAlt, eax
            .ENDIF
        .ENDIF          
    .ENDIF

    ret
_MUI_ButtonSetPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonUpdateBrushOrg - Updates brush org for relative brush after a 
; control has moved
;------------------------------------------------------------------------------
_MUI_ButtonUpdateBrushOrg PROC hWin:DWORD
    LOCAL rect:RECT
    LOCAL x:DWORD
    LOCAL y:DWORD
    LOCAL dwBrushOrgX:DWORD
    LOCAL dwBrushOrgY:DWORD
    
    Invoke MUIGetIntProperty, hWin, @ButtonBrushOrgOriginalX
    mov dwBrushOrgX, eax

    Invoke MUIGetIntProperty, hWin, @ButtonBrushOrgOriginalY
    mov dwBrushOrgY, eax
    
    Invoke MUIGetParentRelativeWindowRect, hWin, Addr rect
        
    mov eax, rect.left
    sub eax, dwBrushOrgX
    neg eax
    mov x, eax
        
    mov eax, rect.top
    sub eax, dwBrushOrgY
    neg eax
    mov y, eax

    Invoke MUISetIntProperty, hWin, @ButtonBrushOrgX, x
    Invoke MUISetIntProperty, hWin, @ButtonBrushOrgY, y
    Invoke InvalidateRect, hWin, NULL, FALSE
    ret
_MUI_ButtonUpdateBrushOrg ENDP


;-------------------------------------------------------------------------------------------------------------------------------
; Other function wrappers - most equate to same as custom messages
;-------------------------------------------------------------------------------------------------------------------------------


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonGetState
;------------------------------------------------------------------------------
MUIButtonGetState PROC hControl:DWORD
    Invoke SendMessage, hControl, MUIBM_GETSTATE, 0, 0
    ret
MUIButtonGetState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonSetState
;------------------------------------------------------------------------------
MUIButtonSetState PROC hControl:DWORD, bState:DWORD
    Invoke SendMessage, hControl, MUIBM_SETSTATE, bState, 0
    ret
MUIButtonSetState ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonLoadImages - Loads images from resource ids and stores the handles 
; in the appropriate property.
;------------------------------------------------------------------------------
MUIButtonLoadImages PROC hControl:DWORD, dwImageType:DWORD, dwResIDImage:DWORD, dwResIDImageAlt:DWORD, dwResIDImageSel:DWORD, dwResIDImageSelAlt:DWORD, dwResIDImageDisabled:DWORD

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
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImage, dwResIDImage
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageAlt != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageAlt, dwResIDImageAlt
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageAlt, dwResIDImageAlt
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageAlt, dwResIDImageAlt
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageSel != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageSel, dwResIDImageSel
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageSel, dwResIDImageSel
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageSel, dwResIDImageSel
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageSelAlt != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageSelAlt, dwResIDImageSelAlt
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageSelAlt, dwResIDImageSelAlt
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageSelAlt, dwResIDImageSelAlt
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageDisabled != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_ButtonLoadBitmap, hControl, @ButtonImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_ButtonLoadIcon, hControl, @ButtonImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_ButtonLoadPng, hControl, @ButtonImageDisabled, dwResIDImageDisabled
            ENDIF
        .ENDIF
    .ENDIF
    
    Invoke InvalidateRect, hControl, NULL, TRUE
    
    ret
MUIButtonLoadImages ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonSetImages - Sets the property handles for image types
;------------------------------------------------------------------------------
MUIButtonSetImages PROC hControl:DWORD, dwImageType:DWORD, hImage:DWORD, hImageAlt:DWORD, hImageSel:DWORD, hImageSelAlt:DWORD, hImageDisabled:DWORD

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


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonNotifySetText
;------------------------------------------------------------------------------
MUIButtonNotifySetText PROC hControl:DWORD, lpszNotifyText:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYSETTEXT, lpszNotifyText, bRedraw
    ret
MUIButtonNotifySetText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonNotifyLoadImage
;------------------------------------------------------------------------------
MUIButtonNotifyLoadImage PROC hControl:DWORD, dwImageType:DWORD, dwResIDNotifyImage:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYLOADIMAGE, dwImageType, dwResIDNotifyImage
    ret
MUIButtonNotifyLoadImage ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonNotifySetImage
;------------------------------------------------------------------------------
MUIButtonNotifySetImage PROC hControl:DWORD, dwImageType:DWORD, hNotifyImage:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYSETIMAGE, dwImageType, hNotifyImage
    ret
MUIButtonNotifySetImage ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonNotifySetFont
;------------------------------------------------------------------------------
MUIButtonNotifySetFont PROC hControl:DWORD, hFont:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFYSETFONT, hFont, bRedraw
    ret
MUIButtonNotifySetFont ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonNotify
;------------------------------------------------------------------------------
MUIButtonNotify PROC hControl:DWORD, bNotify:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTIFY, bNotify, 0 
    ret
MUIButtonNotify ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonNoteSetText
;------------------------------------------------------------------------------
MUIButtonNoteSetText PROC hControl:DWORD, lpszNoteText:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTESETTEXT, lpszNoteText, bRedraw
    ret
MUIButtonNoteSetText ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonNoteSetFont
;------------------------------------------------------------------------------
MUIButtonNoteSetFont PROC hControl:DWORD, hFont:DWORD, bRedraw:DWORD
    Invoke SendMessage, hControl, MUIBM_NOTESETFONT, hFont, bRedraw
    ret
MUIButtonNoteSetFont ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonSetAllProperties - Set all properties at once from long poiner to a 
; MUI_BUTTON_PROPERTIES structure.
;------------------------------------------------------------------------------
MUIButtonSetAllProperties PROC USES EBX ECX hControl:DWORD, lpMUIBUTTONPROPERTIES:DWORD, dwSizeMUIBP:DWORD
    LOCAL lpdwExternalProperties:DWORD
    
    Invoke GetWindowLong, hControl, MUI_EXTERNAL_PROPERTIES ; 4
    .IF eax == 0
        mov eax, FALSE
        ret
    .ENDIF
    mov lpdwExternalProperties, eax
    
    mov eax, dwSizeMUIBP
    .IF eax != SIZEOF MUI_BUTTON_PROPERTIES
        mov eax, FALSE
        ret
    .ENDIF
    
    mov ecx, lpdwExternalProperties
    mov ebx, lpMUIBUTTONPROPERTIES
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwTextFont
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwTextFont, eax 
    .ENDIF
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwTextColor
    mov [ecx].MUI_BUTTON_PROPERTIES.dwTextColor, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwTextColorAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwTextColorAlt, eax    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwTextColorSel
    mov [ecx].MUI_BUTTON_PROPERTIES.dwTextColorSel, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwTextColorSelAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwTextColorSelAlt, eax    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwTextColorDisabled
    mov [ecx].MUI_BUTTON_PROPERTIES.dwTextColorDisabled, eax      
        
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColor
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColor, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorAlt, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorSel
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorSel, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorSelAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorSelAlt, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorDisabled
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorDisabled, eax    
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorTo
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorTo, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorAltTo
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorAltTo, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorSelTo
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorSelTo, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorSelAltTo
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorSelAltTo, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBackColorDisabledTo
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBackColorDisabledTo, eax    
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBorderColor
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBorderColor, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBorderColorAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBorderColorAlt, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBorderColorSel
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBorderColorSel, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBorderColorSelAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBorderColorSelAlt, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBorderColorDisabled
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBorderColorDisabled, eax
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwBorderStyle
    mov [ecx].MUI_BUTTON_PROPERTIES.dwBorderStyle, eax

    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentColor
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentColor, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentColorAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentColorAlt, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentColorSel
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentColorSel, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentColorSelAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentColorSelAlt, eax

    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentStyle
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentStyle, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentStyleAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentStyleAlt, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentStyleSel
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentStyleSel, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwAccentStyleSelAlt
    mov [ecx].MUI_BUTTON_PROPERTIES.dwAccentStyleSelAlt, eax
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwImageType
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwImageType, eax
    .ENDIF
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwImage
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwImage, eax
    .ENDIF
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwRightImage
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwRightImage, eax
    .ENDIF
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwNotifyTextFont
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwNotifyTextFont, eax
    .ENDIF
    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwNotifyTextColor
    mov [ecx].MUI_BUTTON_PROPERTIES.dwNotifyTextColor, eax    
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwNotifyBackColor
    mov [ecx].MUI_BUTTON_PROPERTIES.dwNotifyBackColor, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwNotifyRound
    mov [ecx].MUI_BUTTON_PROPERTIES.dwNotifyRound, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwNotifyImageType
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwNotifyImageType, eax
    .ENDIF
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwNotifyImage
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwNotifyImage, eax
    .ENDIF
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonNoteTextFont
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonNoteTextFont, eax
    .ENDIF
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonNoteTextColor
    mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonNoteTextColor, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonNoteTextColorDisabled
    mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonNoteTextColorDisabled, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonPaddingLeftIndent
    mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonPaddingLeftIndent, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonPaddingGeneral
    mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonPaddingGeneral, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonPaddingStyle
    mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonPaddingStyle, eax
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonPaddingTextImage
    .IF eax != NULL
        mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonPaddingTextImage, eax
    .ENDIF
    mov eax, [ebx].MUI_BUTTON_PROPERTIES.dwButtonDllInstance
    mov [ecx].MUI_BUTTON_PROPERTIES.dwButtonDllInstance, eax
    ;Invoke RtlMoveMemory, lpdwInternalProperties, lpMUIBUTTONPROPERTIES, SIZEOF MUI_BUTTON_PROPERTIES

    ; check default values: text colors
    Invoke MUIGetExtProperty, hControl, @ButtonTextColorAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonTextColor
        Invoke MUISetExtProperty, hControl, @ButtonTextColorAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonTextColorSel
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonTextColor
        Invoke MUISetExtProperty, hControl, @ButtonTextColorSel, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonTextColorSelAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonTextColorSel
        Invoke MUISetExtProperty, hControl, @ButtonTextColorSelAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonTextColorDisabled
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonTextColor
        Invoke MUISetExtProperty, hControl, @ButtonTextColorDisabled, eax
    .ENDIF
    
    ; check default values: back colors
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColor
        Invoke MUISetExtProperty, hControl, @ButtonBackColorAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorSel
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColor
        Invoke MUISetExtProperty, hControl, @ButtonBackColorSel, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorSelAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColorSel
        Invoke MUISetExtProperty, hControl, @ButtonBackColorSelAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorDisabled
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColor
        Invoke MUISetExtProperty, hControl, @ButtonBackColorDisabled, eax
    .ENDIF

    ; check default values: back colors to
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorAltTo
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColorTo
        Invoke MUISetExtProperty, hControl, @ButtonBackColorAltTo, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorSelTo
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColorTo
        Invoke MUISetExtProperty, hControl, @ButtonBackColorSelTo, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorSelAltTo
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColorSelTo
        Invoke MUISetExtProperty, hControl, @ButtonBackColorSelAltTo, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBackColorDisabledTo
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBackColorTo
        Invoke MUISetExtProperty, hControl, @ButtonBackColorDisabledTo, eax
    .ENDIF

    ; check default values: border colors
    Invoke MUIGetExtProperty, hControl, @ButtonBorderColorAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBorderColor
        Invoke MUISetExtProperty, hControl, @ButtonBorderColorAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBorderColorSel
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBorderColor
        Invoke MUISetExtProperty, hControl, @ButtonBorderColorSel, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBorderColorSelAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBorderColorSel
        Invoke MUISetExtProperty, hControl, @ButtonBorderColorSelAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonBorderColorDisabled
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonBorderColor
        Invoke MUISetExtProperty, hControl, @ButtonBorderColorDisabled, eax
    .ENDIF

    ; check default values: accent colors
    Invoke MUIGetExtProperty, hControl, @ButtonAccentColorAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonAccentColor
        Invoke MUISetExtProperty, hControl, @ButtonAccentColorAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonAccentColorSel
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonAccentColor
        Invoke MUISetExtProperty, hControl, @ButtonAccentColorSel, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonAccentColorSelAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonAccentColorSel
        Invoke MUISetExtProperty, hControl, @ButtonAccentColorSelAlt, eax
    .ENDIF

    ; check default values: accent styles
    Invoke MUIGetExtProperty, hControl, @ButtonAccentStyleAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonAccentStyle
        Invoke MUISetExtProperty, hControl, @ButtonAccentStyleAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonAccentStyleSel
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonAccentStyle
        Invoke MUISetExtProperty, hControl, @ButtonAccentStyleSel, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonAccentStyleSelAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonAccentStyleSel
        Invoke MUISetExtProperty, hControl, @ButtonAccentStyleSelAlt, eax
    .ENDIF
    
    ; check default values: images
    Invoke MUIGetExtProperty, hControl, @ButtonImageAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonImage
        Invoke MUISetExtProperty, hControl, @ButtonImageAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonImageSel
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonImage
        Invoke MUISetExtProperty, hControl, @ButtonImageSel, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonImageSelAlt
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonImageSel
        Invoke MUISetExtProperty, hControl, @ButtonImageSelAlt, eax
    .ENDIF
    Invoke MUIGetExtProperty, hControl, @ButtonImageDisabled
    .IF eax == 0
        Invoke MUIGetExtProperty, hControl, @ButtonImage
        Invoke MUISetExtProperty, hControl, @ButtonImageDisabled, eax
    .ENDIF
    
    mov eax, TRUE
    
    ret

MUIButtonSetAllProperties ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonSetBackBrush - Set a background brush for button - used for buttons
; that have @ButtonBackColor set to -1 for transparency type effect.
; dwBrushPos: 0 = brush position is relative to control's position, and adjusted
; by x and y (typically 0,0 tho) - if brush image is set to parent's 0,0 then 
; control will capture and paint the part of the brush that is relative to it's 
; background position. Otherwise if dwBrushPos = 1 then its an absolute position 
; in a brush/bitmap
;
; If dwBrushPos is relative, then sizing/moving will readjust the brush offset
; to use for background
;------------------------------------------------------------------------------
MUIButtonSetBackBrush PROC hControl:DWORD, hBrush:DWORD, dwBrushOrgX:DWORD, dwBrushOrgY:DWORD, dwBrushPos:DWORD
    LOCAL rect:RECT
    LOCAL x:DWORD
    LOCAL y:DWORD
    
    mov eax, dwBrushPos
    .IF eax == 0 ; brush position is relative to control's position, and adjusted by x and y 
        Invoke MUIGetParentRelativeWindowRect, hControl, Addr rect
        
        mov eax, rect.left
        sub eax, dwBrushOrgX
        neg eax
        mov x, eax
        
        mov eax, rect.top
        sub eax, dwBrushOrgY
        neg eax
        mov y, eax
        
    .ELSE ; brush position is absolute, but adjusted by x and y as specified
        
        mov eax, dwBrushOrgX
        neg eax
        mov x, eax
        
        mov eax, dwBrushOrgY
        neg eax
        mov y, eax
        
    .ENDIF
    
    Invoke MUISetIntProperty, hControl, @ButtonBrush, hBrush
    Invoke MUISetIntProperty, hControl, @ButtonBrushOrgOriginalX, dwBrushOrgX
    Invoke MUISetIntProperty, hControl, @ButtonBrushOrgOriginalY, dwBrushOrgY
    Invoke MUISetIntProperty, hControl, @ButtonBrushOrgX, x
    Invoke MUISetIntProperty, hControl, @ButtonBrushOrgY, y
    Invoke MUISetIntProperty, hControl, @ButtonBrushPos, dwBrushPos
    Invoke InvalidateRect, hControl, NULL, FALSE
    ret
MUIButtonSetBackBrush ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIButtonLoadBackBrush
;------------------------------------------------------------------------------
MUIButtonLoadBackBrush PROC hControl:DWORD, idResBitmap:DWORD, dwBrushOrgX:DWORD, dwBrushOrgY:DWORD, dwBrushPos:DWORD
    LOCAL hinstance:DWORD
    LOCAL hBrushBitmap:DWORD
    LOCAL hBrush:DWORD
    
    .IF idResBitmap == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hControl, @ButtonDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax
    
    Invoke LoadBitmap, hinstance, idResBitmap
    mov hBrushBitmap, eax
    Invoke MUISetIntProperty, hControl, @ButtonBrushBitmap, hBrushBitmap
    
    Invoke CreatePatternBrush, hBrushBitmap
    mov hBrush, eax
    
    Invoke MUIButtonSetBackBrush, hControl, hBrush, dwBrushOrgX, dwBrushOrgY, dwBrushPos
    
    ret
MUIButtonLoadBackBrush ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonLoadIcon - if succesful, loads specified bitmap resource into the 
; specified external property and returns TRUE in eax, otherwise FALSE.
;------------------------------------------------------------------------------
_MUI_ButtonLoadBitmap PROC hWin:DWORD, dwProperty:DWORD, idResBitmap:DWORD
    LOCAL hinstance:DWORD
    LOCAL dwStyle:DWORD
    LOCAL bKeepImages:DWORD
    
    .IF idResBitmap == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hWin, @ButtonDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, MUIBS_KEEPIMAGES
    .IF eax == MUIBS_KEEPIMAGES
        mov bKeepImages, TRUE
    .ELSE
        mov bKeepImages, FALSE
    .ENDIF

    Invoke MUIGetExtProperty, hWin, dwProperty
    .IF eax != 0 ; image handle already in use, delete object?
        .IF bKeepImages == FALSE
            Invoke DeleteObject, eax
        .ENDIF
    .ENDIF

    Invoke LoadBitmap, hinstance, idResBitmap
    Invoke MUISetExtProperty, hWin, dwProperty, eax
    mov eax, TRUE
    
    ret

_MUI_ButtonLoadBitmap ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_ButtonLoadIcon - if succesful, loads specified icon resource into the 
; specified external property and returns TRUE in eax, otherwise FALSE.
;------------------------------------------------------------------------------
_MUI_ButtonLoadIcon PROC hWin:DWORD, dwProperty:DWORD, idResIcon:DWORD
    LOCAL hinstance:DWORD
    LOCAL dwStyle:DWORD
    LOCAL bKeepImages:DWORD
    
    .IF idResIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @ButtonDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, MUIBS_KEEPIMAGES
    .IF eax == MUIBS_KEEPIMAGES
        mov bKeepImages, TRUE
    .ELSE
        mov bKeepImages, FALSE
    .ENDIF

    Invoke MUIGetExtProperty, hWin, dwProperty
    .IF eax != 0 ; image icon handle already in use, delete object?
        .IF bKeepImages == FALSE
            Invoke DeleteObject, eax
        .ENDIF
    .ENDIF

    .IF bKeepImages == FALSE
        Invoke LoadImage, hinstance, idResIcon, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
    .ELSE
        Invoke LoadImage, hinstance, idResIcon, IMAGE_ICON, 0, 0, LR_SHARED
    .ENDIF
    Invoke MUISetExtProperty, hWin, dwProperty, eax

    mov eax, TRUE

    ret

_MUI_ButtonLoadIcon ENDP



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
_MUI_ButtonLoadPng PROC hWin:DWORD, dwProperty:DWORD, idResPng:DWORD
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
    LOCAL dwStyle:DWORD
    LOCAL bKeepImages:DWORD    

    Invoke MUIGetExtProperty, hWin, @ButtonDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, MUIBS_KEEPIMAGES
    .IF eax == MUIBS_KEEPIMAGES
        mov bKeepImages, TRUE
    .ELSE
        mov bKeepImages, FALSE
    .ENDIF

    Invoke MUIGetExtProperty, hWin, dwProperty
    .IF eax != 0 ; image icon handle already in use, delete object?
        .IF bKeepImages == FALSE
            Invoke _MUI_ButtonPngReleaseIStream, eax        
        .ENDIF
    .ENDIF

    ; ------------------------------------------------------------------
    ; STEP 1: Find the resource
    ; ------------------------------------------------------------------
    invoke  FindResource, hinstance, idResPng, RT_RCDATA
    or      eax, eax
    jnz     @f
    jmp     _MUI_ButtonLoadPng@Close
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
    jmp     _MUI_ButtonLoadPng@Close
@@: mov     sizeOfRes, eax
    
    invoke  LockResource, hResData
    or      eax, eax
    jnz     @f
    jmp     _MUI_ButtonLoadPng@Close
@@: mov     pResData, eax

    invoke  GlobalAlloc, GMEM_MOVEABLE, sizeOfRes
    or      eax, eax
    jnz     @f
    jmp     _MUI_ButtonLoadPng@Close
@@: mov     hbuffer, eax

    invoke  GlobalLock, hbuffer
    mov     pbuffer, eax
    
    invoke  RtlMoveMemory, pbuffer, hResData, sizeOfRes
    invoke  CreateStreamOnHGlobal, pbuffer, TRUE, addr pIStream
    or      eax, eax
    jz      @f
    jmp     _MUI_ButtonLoadPng@Close
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
ENDIF


;------------------------------------------------------------------------------
; _MUI_ButtonPngReleaseIStream - releases png stream handle
;------------------------------------------------------------------------------
IFDEF MUI_USEGDIPLUS
MUI_ALIGN
_MUI_ButtonPngReleaseIStream PROC hIStream:DWORD
    
    mov eax, hIStream
    push    eax
    mov     eax,DWORD PTR [eax]
    call    IStream.IUnknown.Release[eax]                               ; release the stream
    ret

_MUI_ButtonPngReleaseIStream ENDP
ENDIF






















MODERNUI_LIBEND
