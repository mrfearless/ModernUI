;======================================================================================================================================
;
; ModernUI Control - ModernUI_CaptionBar v1.0.0.2
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

IFNDEF LIBEND
    LIBEND TEXTEQU <END>
ELSE
    LIBEND TEXTEQU <>
ENDIF


;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------


_MUI_CaptionBarWndProc                      PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CaptionBarInit                         PROTO :DWORD
_MUI_CaptionBarPaint                        PROTO :DWORD
_MUI_CaptionBarReposition                   PROTO :DWORD
_MUI_CaptionBarParentSubClassProc           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CaptionBarSetSysButtonProperty         PROTO :DWORD, :DWORD, :DWORD

_MUI_CreateCaptionBarSysButtons             PROTO :DWORD, :DWORD
_MUI_CreateSysButton                        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SysButtonWndProc                       PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SysButtonInit                          PROTO :DWORD
_MUI_SysButtonCleanup                       PROTO :DWORD
_MUI_SysButtonPaint                         PROTO :DWORD
_MUI_SysButtonGetIconSize                   PROTO :DWORD, :DWORD, :DWORD

_MUI_ApplyMUIStyleToDialog                  PROTO :DWORD, :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; CaptionBar External Properties
MUI_CAPTIONBAR_PROPERTIES                   STRUCT
    dwTextColor                             DD ?
    dwTextFont                              DD ?
    dwBackColor                             DD ?
    dwSysButtonTextRollColor                DD ?
    dwSysButtonBackRollColor                DD ?
    dwSysButtonsWidth                       DD ? ; defaults to 32
    dwSysButtonsHeight                      DD ? ; defaults to 28
    dwBtnIcoMin                             DD ?
    dwBtnIcoMinAlt                          DD ?
    dwBtnIcoMax                             DD ?
    dwBtnIcoMaxAlt                          DD ?
    dwBtnIcoRes                             DD ?
    dwBtnIcoResAlt                          DD ?
    dwBtnIcoClose                           DD ?
    dwBtnIcoCloseAlt                        DD ?
    dwDllInstance                           DD ?
MUI_CAPTIONBAR_PROPERTIES                   ENDS

; CaptionBar Internal Poperties
_MUI_CAPTIONBAR_PROPERTIES                  STRUCT
    dwEnabledState                          DD ?
    dwMouseOver                             DD ?
    hSysButtonClose                         DD ?
    hSysButtonMax                           DD ?
    hSysButtonRes                           DD ?
    hSysButtonMin                           DD ?
    dwNoMoveWindow                          DD ?
    dwUseIcons                              DD ?
_MUI_CAPTIONBAR_PROPERTIES                  ENDS

; SysButton External Properties
MUI_SYSBUTTON_PROPERTIES                    STRUCT
    dwTextColor                             DD ?
    dwTextRollColor                         DD ?
    dwBackColor                             DD ?
    dwBackRollColor                         DD ?
    dwSysButtonType                         DD ?
    dwIco                                   DD ?
    dwIcoAlt                                DD ?
MUI_SYSBUTTON_PROPERTIES                    ENDS

; SysButton Internal Properties
_MUI_SYSBUTTON_PROPERTIES                   STRUCT
    dwSysButtonFont                         DD ?
    dwEnabledState                          DD ?
    dwMouseOver                             DD ?
    dwUseIcons                              DD ?    
_MUI_SYSBUTTON_PROPERTIES                   ENDS


.CONST
MUI_DEFAULT_CAPTION_HEIGHT                  EQU 32d
MUI_SYSBUTTON_WIDTH                         EQU 32d
MUI_SYSBUTTON_HEIGHT                        EQU 28d


; CaptionBar Internal Properties
@CaptionBarEnabledState                     EQU 0
@CaptionBarMouseOver                        EQU 4
@CaptionBar_hSysButtonClose                 EQU 8
@CaptionBar_hSysButtonMax                   EQU 12
@CaptionBar_hSysButtonRes                   EQU 16
@CaptionBar_hSysButtonMin                   EQU 20
@CaptionBarNoMoveWindow                     EQU 24
@CaptionBarUseIcons                         EQU 28

; SysButton Internal Properties
@SysButtonFont                              EQU 0
@SysButtonEnabledState                      EQU 4
@SysButtonMouseOver                         EQU 8
@SysButtonUseIcons                          EQU 12

; SysButton External Properties
@SysButtonTextColor                         EQU 0 
@SysButtonTextRollColor                     EQU 4
@SysButtonBackColor                         EQU 8
@SysButtonBackRollColor                     EQU 12
@SysButtonType                              EQU 16
@SysButtonIco                               EQU 20
@SysButtonIcoAlt                            EQU 24

.DATA
szMUICaptionBarClass                        DB 'ModernUI_CaptionBar',0  ; Class name for our CaptionBar control
szMUISysButtonClass                         DB 'ModernUI_SysButton',0   ; Class name for our system buttons (min/max/restore or close buttons)
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
; MUICaptionBarRegister - Registers the ModernUI_CaptionBar control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_CaptionBar
;-------------------------------------------------------------------------------------
MUICaptionBarRegister PROC PUBLIC
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
        mov wc.style, CS_DBLCLKS ;NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
        Invoke RegisterClassEx, addr wc
    .ENDIF
    ret

MUICaptionBarRegister ENDP


;-------------------------------------------------------------------------------------
; MUICaptionBarCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUICaptionBarCreate PROC PUBLIC USES EBX hWndParent:DWORD, lpszCaptionText:DWORD, dwCaptionHeight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL rect:RECT
    LOCAL dwControlStyle:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax
    
    Invoke MUICaptionBarRegister
    
    ; Modify styles appropriately - for visual controls no CS_HREDRAW CS_VREDRAW (causes flickering)
    ; probably need WS_CHILD, WS_VISIBLE. Needs WS_CLIPCHILDREN.
    mov eax, dwStyle
    or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    mov dwControlStyle, eax

    Invoke GetWindowRect, hWndParent, Addr rect
    mov eax, rect.right
    mov ebx, rect.left
    sub eax, ebx
    
    Invoke CreateWindowEx, NULL, Addr szMUICaptionBarClass, lpszCaptionText, dwControlStyle, 0, 0, eax, dwCaptionHeight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        
    .ENDIF
    mov eax, hControl
    ret
MUICaptionBarCreate ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarWndProc - Main processing window for our CaptionBar control
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
        ; sets text of our CaptionBar
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName
        ; Set main window title
        Invoke SetWindowText, hParent, (CREATESTRUCT PTR [ebx]).lpszName
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_CAPTIONBAR_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_CAPTIONBAR_PROPERTIES ; external properties
        Invoke _MUI_CaptionBarInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == 1 ; close button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_CLOSE, 0
            ;Invoke SendMessage, eax, WM_CLOSE, 0, 0
            ret
        .ELSEIF eax == 2 ; max button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_MAXIMIZE, 0
            ;Invoke ShowWindow, eax, SW_MAXIMIZE
            Invoke _MUI_CaptionBarReposition, hWin
            ret            
        .ELSEIF eax == 3 ; res button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_RESTORE, 0
            ;Invoke ShowWindow, eax, SW_RESTORE
            Invoke _MUI_CaptionBarReposition, hWin
            ret
        .ELSEIF eax == 4 ; min button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_MINIMIZE, 0
            ;Invoke ShowWindow, eax, SW_MINIMIZE
            ret
        .ENDIF
        xor eax, eax
        ret

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_CaptionBarPaint, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_LBUTTONDBLCLK
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUICS_NOMAXBUTTON
        .IF eax != MUICS_NOMAXBUTTON  
            ; only needed if max/res button is present, otherwise doubleclick caption bar should do nothing. 
            Invoke GetParent, hWin
            mov hParent, eax
            Invoke GetWindowPlacement, hParent, Addr wp
            .IF wp.showCmd == SW_SHOWNORMAL    
                Invoke ShowWindow, hParent, SW_MAXIMIZE
                Invoke _MUI_CaptionBarReposition, hWin
                ret
            .ELSEIF wp.showCmd == SW_SHOWMAXIMIZED
                Invoke ShowWindow, hParent, SW_RESTORE
                Invoke _MUI_CaptionBarReposition, hWin
                ret
            .ELSE
                mov eax, 0
            .ENDIF
        .ELSE
            mov eax, 0
        .ENDIF

    .ELSEIF eax == WM_NCHITTEST
        Invoke MUIGetIntProperty, hWin, @CaptionBarNoMoveWindow
        .IF eax == FALSE
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_NCLBUTTONDOWN, HTCAPTION, 0
        .ENDIF

   .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUIGetIntProperty, hWin, @CaptionBarEnabledState
        .IF eax == TRUE   
            Invoke MUISetIntProperty, hWin, @CaptionBarMouseOver , TRUE
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
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseOver , FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseOver , FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
    
    .ELSEIF eax == WM_SIZE
        Invoke _MUI_CaptionBarReposition, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SETTEXT
        Invoke GetParent, hWin
        mov hParent, eax
         ; sets text of our CaptionBar
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ; Set main window title
        Invoke SetWindowText, hParent, lParam
        Invoke InvalidateRect, hWin, NULL, FALSE
        mov eax, TRUE
        ret
    
    ; custom messages start here
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY
        Invoke MUISetExtProperty, hWin, wParam, lParam
        
        ; also set child system button properties as well if they apply
        Invoke _MUI_CaptionBarSetSysButtonProperty, hWin, wParam, lParam
        
        .IF wParam == @CaptionBarBtnWidth || wParam == @CaptionBarBtnHeight
            Invoke _MUI_CaptionBarReposition, hWin
        .ENDIF
        ret
        
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret


    ret
_MUI_CaptionBarWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarParentSubClassProc - Subclass for caption bar parent window 
; dwRefData is the handle to our CaptionBar control in this subclass proc
;-------------------------------------------------------------------------------------
_MUI_CaptionBarParentSubClassProc PROC PRIVATE hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL wp:WINDOWPLACEMENT
    LOCAL dwStyle:DWORD
    
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Addr _MUI_CaptionBarParentSubClassProc, uIdSubclass ; remove subclass before control destroyed.
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        ret
    
    ; Handle resize of dialog/window and invalidate it if we are painting a border via MUIPaintBackground
    .ELSEIF eax == WM_NCCALCSIZE
        Invoke InvalidateRect, hWin, NULL, TRUE
    
    .ELSEIF eax == WM_THEMECHANGED || eax == WM_DWMCOMPOSITIONCHANGED
        ;PrintText 'WM_THEMECHANGED || WM_DWMCOMPOSITIONCHANGED'
        Invoke GetWindowLong, dwRefData, GWL_STYLE
        mov dwStyle, eax
        and eax, MUICS_WINNOMUISTYLE
        .IF eax != MUICS_WINNOMUISTYLE
            ; use dropshadow - unless MUICS_WINNODROPSHADOW is specified
            mov eax, dwStyle
            and eax, MUICS_WINNODROPSHADOW
            .IF eax == MUICS_WINNODROPSHADOW
                Invoke _MUI_ApplyMUIStyleToDialog, hWin, FALSE
            .ELSE
                Invoke _MUI_ApplyMUIStyleToDialog, hWin, TRUE
            .ENDIF
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke UpdateWindow, hWin
        .ENDIF
    
    ; If user pulls caption down whilst maximized this will be caught by this handler and we can adjust the CaptionBar control to reflect the 
    ; restore state it will be in. Or if user programmatically changes window this should catch it as well.
    .ELSEIF eax == WM_SIZE
        mov eax, wParam
        .IF eax == SIZE_MAXIMIZED
            Invoke SendMessage, dwRefData, WM_SIZE, 0, 0 ; force reposition of CaptionBar and its child controls
        .ELSEIF eax == SIZE_RESTORED
            Invoke SendMessage, dwRefData, WM_SIZE, 0, 0 ; force reposition of CaptionBar and its child controls
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
    
    ; Apply ModernUI style to window/dialog - unless MUICS_WINNOMUISTYLE is specified
    mov eax, dwStyle
    and eax, MUICS_WINNOMUISTYLE
    .IF eax != MUICS_WINNOMUISTYLE
        
        ; use dropshadow - unless MUICS_WINNODROPSHADOW is specified
        mov eax, dwStyle
        and eax, MUICS_WINNODROPSHADOW
        .IF eax == MUICS_WINNODROPSHADOW
            Invoke _MUI_ApplyMUIStyleToDialog, hParent, FALSE
        .ELSE
            Invoke _MUI_ApplyMUIStyleToDialog, hParent, TRUE
        .ENDIF
    .ENDIF
    
    ; Allow caption bar to be clicked and held to move window?
    mov eax, dwStyle
    and eax, MUICS_NOMOVEWINDOW
    .IF eax == MUICS_NOMOVEWINDOW    
        Invoke MUISetIntProperty, hCaptionBar, @CaptionBarNoMoveWindow, TRUE
    .ELSE
        Invoke MUISetIntProperty, hCaptionBar, @CaptionBarNoMoveWindow, FALSE
    .ENDIF
    
    ; Check if to use icons or not?
    mov eax, dwStyle
    and eax, MUICS_USEICONSFORBUTTONS
    .IF eax == MUICS_USEICONSFORBUTTONS  
        Invoke MUISetIntProperty, hCaptionBar, @CaptionBarUseIcons, TRUE
    .ELSE
        Invoke MUISetIntProperty, hCaptionBar, @CaptionBarUseIcons, FALSE
    .ENDIF
    
    ; Set default initial external property values     
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarTextColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(21,133,181)
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarBtnWidth, MUI_SYSBUTTON_WIDTH ;32d
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarBtnHeight, MUI_SYSBUTTON_HEIGHT ;28d
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarDllInstance, 0
    
    .IF hMUICaptionBarFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hFont, eax
        Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
        mov lfnt.lfHeight, -12d
        mov lfnt.lfWeight, FW_NORMAL ;FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUICaptionBarFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke MUISetExtProperty, hCaptionBar, @CaptionBarTextFont, hMUICaptionBarFont

    Invoke _MUI_CreateCaptionBarSysButtons, hCaptionBar, hParent
    
    ; 26/07/2016 - needed to remove as some dialogs without max/res would show up with artifact drawing if border drawn
    ;mov eax, dwStyle
    ;and eax, MUICS_NOMAXBUTTON
    ;.IF eax != MUICS_NOMAXBUTTON
        ; only need to subclass to handle catching restore/maximize - no need if max/res button is not present 
        Invoke SetWindowSubclass, hParent, Addr _MUI_CaptionBarParentSubClassProc, hCaptionBar, hCaptionBar
    ;.ENDIF

    ret

_MUI_CaptionBarInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarPaint - main CaptionBar painting
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
    
    Invoke MUIGetIntProperty, hWin, @CaptionBarMouseOver
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


    mov eax, dwStyle
    and eax, MUICS_NOCAPTIONTITLETEXT
    .IF eax != MUICS_NOCAPTIONTITLETEXT
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
    LOCAL dwSysButtonWidth:DWORD
    LOCAL dwSysButtonHeight:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwUseIcons:DWORD
    
    
    Invoke GetWindowRect, hCaptionBar, Addr rect
    
    Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnWidth
    mov dwSysButtonWidth, eax
    mov dwLeftOffset, eax ;32d ; start with width of first button
    Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnHeight
    mov dwSysButtonHeight, eax
    
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBarUseIcons
    mov dwUseIcons, eax
    
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
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysCloseButton, eax, 0, dwSysButtonWidth, dwSysButtonHeight, 1 ; 32d, 24d, 1  
        mov hSysButtonClose, eax
        
        ; check if red button style is supplied, if so we override colors for this button
        mov eax, dwStyle
        and eax, MUICS_REDCLOSEBUTTON
        .IF eax == MUICS_REDCLOSEBUTTON
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextRollColor, MUI_RGBCOLOR(255,255,255)
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackRollColor, MUI_RGBCOLOR(166,26,32)
        .ENDIF
        
        .IF dwUseIcons == TRUE
            Invoke MUISetIntProperty, hSysButtonClose, @SysButtonUseIcons, TRUE
        .ELSE
            Invoke MUISetIntProperty, hSysButtonClose, @SysButtonUseIcons, FALSE
        .ENDIF
        mov eax, dwSysButtonWidth
        add dwLeftOffset, eax ;32d
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
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysMaxButton, xpos, 0, dwSysButtonWidth, dwSysButtonHeight, 2 ;32d, 24d, 2
        mov hSysButtonMax, eax
        
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysResButton, xpos, 0, dwSysButtonWidth, dwSysButtonHeight, 3 ;32d, 24d, 3
        mov hSysButtonRes, eax
        mov eax, dwSysButtonWidth
        add dwLeftOffset, eax ;32d
        ; hide max/res button depending on current window placement
        Invoke GetWindowPlacement, hCaptionBarParent, Addr wp
        .IF wp.showCmd == SW_SHOWNORMAL
            Invoke ShowWindow, hSysButtonRes, SW_HIDE
        .ELSE
            Invoke ShowWindow, hSysButtonMax, SW_HIDE
        .ENDIF
        
        .IF dwUseIcons == TRUE
            Invoke MUISetIntProperty, hSysButtonMax, @SysButtonUseIcons, TRUE
            Invoke MUISetIntProperty, hSysButtonRes, @SysButtonUseIcons, TRUE
        .ELSE
            Invoke MUISetIntProperty, hSysButtonMax, @SysButtonUseIcons, FALSE
            Invoke MUISetIntProperty, hSysButtonRes, @SysButtonUseIcons, FALSE
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
        Invoke _MUI_CreateSysButton, hCaptionBar, Addr szMUISysMinButton, eax, 0, dwSysButtonWidth, dwSysButtonHeight, 4 ;32d, 24d, 4
        mov hSysButtonMin, eax
        mov eax, dwSysButtonWidth
        add dwLeftOffset, eax ;32d
        
        .IF dwUseIcons == TRUE
            Invoke MUISetIntProperty, hSysButtonMin, @SysButtonUseIcons, TRUE
        .ELSE
            Invoke MUISetIntProperty, hSysButtonMin, @SysButtonUseIcons, FALSE
        .ENDIF        
        
    .ELSE
        mov hSysButtonMin, 0
    .ENDIF

    ; save handles to child system buttons in our internal properties of CaptionBar
    Invoke MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose, hSysButtonClose
    Invoke MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax, hSysButtonMax
    Invoke MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes, hSysButtonRes
    Invoke MUISetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin, hSysButtonMin

    ret

_MUI_CreateCaptionBarSysButtons ENDP


;-------------------------------------------------------------------------------------
; _MUI_CaptionBarReposition - Reposition window and child system buttons after main
; window resizes - called via SendMessage, hControl, WM_SIZE, 0, 0
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
    LOCAL dwSysButtonWidth:DWORD
    LOCAL dwSysButtonHeight:DWORD    
    LOCAL hParent:DWORD
    LOCAL rect:RECT
    LOCAL dwStyle:DWORD
    
    ;todo, if MUICS_WINNOMUISTYLE applied (ie in radasm dialog editor) then we should just set pos to 0,0, and client width

    Invoke GetWindowLong, hCaptionBar, GWL_STYLE
    mov dwStyle, eax
 
    
    Invoke GetParent, hCaptionBar
    mov hParent, eax

    Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnWidth
    mov dwSysButtonWidth, eax
    mov dwLeftOffset, eax ;32d
    Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnHeight
    mov dwSysButtonHeight, eax

    Invoke GetClientRect, hCaptionBar, Addr rect
    mov eax, rect.bottom
    mov dwCaptionHeight, eax
    .IF sdword ptr eax < 6
        mov dwCaptionHeight, MUI_DEFAULT_CAPTION_HEIGHT
    .ENDIF
    
    Invoke GetWindowPlacement, hParent, Addr wp

    mov eax, dwStyle
    and eax, MUICS_WINNOMUISTYLE
    .IF eax == MUICS_WINNOMUISTYLE
        Invoke GetClientRect, hParent, Addr rect
    .ELSE       
        Invoke GetWindowRect, hParent, Addr rect
    .ENDIF
    mov eax, rect.right
    mov ebx, rect.left
    sub eax, ebx
    mov dwClientWidth, eax
    mov eax, rect.bottom
    mov ebx, rect.top
    sub eax, ebx
    mov dwClientHeight, eax
    
    mov TotalItems, 0
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose
    mov hSysButtonClose, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax
    mov hSysButtonMax, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes
    mov hSysButtonRes, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin
    mov hSysButtonMin, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF

    Invoke BeginDeferWindowPos, TotalItems
    mov hDefer, eax
    ; have to move this caption bar first, so that child controls can be moved inside of the new width (cant use defer on this window)
    .IF wp.showCmd == SW_SHOWNORMAL
        sub dwClientWidth, 2
        Invoke SetWindowPos, hCaptionBar, NULL, 1, 1, dwClientWidth, dwCaptionHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING  ;SWP_NOCOPYBITS     or SWP_NOREDRAW
    .ELSE
        Invoke SetWindowPos, hCaptionBar, NULL, 1, 1, dwClientWidth, dwCaptionHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING  ;SWP_NOCOPYBITS     or SWP_NOREDRAW
    .ENDIF 

    .IF hSysButtonClose != NULL
        mov eax, dwClientWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonClose, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER  or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING ;or SWP_NOCOPYBITS
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonClose, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING
            mov hDefer, eax    
        .ENDIF
        mov eax, dwSysButtonWidth
        add dwLeftOffset, eax ;32d
    .ENDIF

    .IF hSysButtonMax != NULL && hSysButtonRes != NULL
        mov eax, dwClientWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonMax, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING    
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonMax, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER  or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING
            mov hDefer, eax 
        .ENDIF

        mov eax, dwClientWidth
        sub eax, dwLeftOffset        
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonRes, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING    
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonRes, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING
            mov hDefer, eax  
        .ENDIF
        mov eax, dwSysButtonWidth
        add dwLeftOffset, eax ;32d
    .ENDIF
    
    .IF hSysButtonMin != NULL
        mov eax, dwClientWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonMin, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING    
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonMin, NULL, eax, 0, 0, 0, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOSIZE ;or SWP_NOSENDCHANGING
            mov hDefer, eax  
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
; _MUI_CaptionBarSetSysButtonProperty - Sets the system button properties from the message
; MUIM_SETPROPERTY set to the parent CaptionBar control 
;-------------------------------------------------------------------------------------
_MUI_CaptionBarSetSysButtonProperty PROC PRIVATE USES EBX hCaptionBar:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwSysButtonWidth:DWORD
    LOCAL dwSysButtonHeight:DWORD

    .IF dwProperty == @CaptionBarTextFont
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose
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
        .ELSEIF eax == @CaptionBarBtnIcoClose
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIco, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnIcoCloseAlt
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIcoAlt, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnWidth
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonClose, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonClose, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ENDIF
    .ENDIF
    
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax
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
        .ELSEIF eax == @CaptionBarBtnIcoMax
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonIco, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnIcoMaxAlt
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonIcoAlt, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnWidth
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonMax, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonMax, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE         
        .ENDIF
    .ENDIF
    
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes
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
        .ELSEIF eax == @CaptionBarBtnIcoRes
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonIco, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnIcoResAlt
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonIcoAlt, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnWidth
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonRes, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonRes, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE          
        .ENDIF
    .ENDIF
    
    Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin
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
        .ELSEIF eax == @CaptionBarBtnIcoMin
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonIco, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnIcoMinAlt
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonIcoAlt, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnWidth
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonMin, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonMin, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE        
        .ENDIF
    .ENDIF
    
    ret
_MUI_CaptionBarSetSysButtonProperty ENDP


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
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_SYSBUTTON_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_SYSBUTTON_PROPERTIES ; external properties
        Invoke _MUI_SysButtonInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_SysButtonCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4   
        
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
        Invoke MUISetIntProperty, hWin, @SysButtonMouseOver, TRUE
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
        Invoke MUISetIntProperty, hWin, @SysButtonMouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @SysButtonMouseOver, FALSE
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
    Invoke MUISetIntProperty, hSysButton, @SysButtonFont, hMUISysButtonFont

    ret

_MUI_SysButtonInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_SysButtonCleanup - cleanup some stuff on control being destroyed
;-------------------------------------------------------------------------------------
_MUI_SysButtonCleanup PROC PRIVATE hSysButton:DWORD
    
    Invoke GetParent, hSysButton
    Invoke GetWindowLong, eax, GWL_STYLE
    and eax, MUICS_KEEPICONS
    .IF eax == MUICS_KEEPICONS
        ret
    .ENDIF

    Invoke MUIGetIntProperty, hSysButton, @SysButtonUseIcons
    .IF eax == TRUE    
        Invoke MUIGetExtProperty, hSysButton, @SysButtonIco
        .IF eax != NULL
            Invoke DestroyIcon, eax
        .ENDIF
         Invoke MUIGetExtProperty, hSysButton, @SysButtonIcoAlt
        .IF eax != NULL
            Invoke DestroyIcon, eax
        .ENDIF
    .ENDIF
    ret

_MUI_SysButtonCleanup ENDP


;-------------------------------------------------------------------------------------
; _MUI_SysButtonPaint - System button painting
;-------------------------------------------------------------------------------------
_MUI_SysButtonPaint PROC PRIVATE USES EBX hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL pt:POINT
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
    LOCAL UseIcons:DWORD
    LOCAL hIcon:DWORD
    LOCAL nIcoWidth:DWORD
    LOCAL nIcoHeight:DWORD
    LOCAL szText[16]:BYTE
    
    ; null some vars
    mov hFont, 0
    mov hOldFont, 0
    mov hBrush, 0
    mov hOldBrush, 0
    mov hIcon, 0
    mov nIcoWidth, 0
    mov nIcoHeight, 0
    
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
    Invoke MUIGetIntProperty, hWin, @SysButtonMouseOver
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
    Invoke MUIGetIntProperty, hWin, @SysButtonFont             ; Marlett font
    mov hFont, eax
    
    Invoke MUIGetIntProperty, hWin, @SysButtonUseIcons
    mov UseIcons, eax
    .IF UseIcons == TRUE
        .IF MouseOver == 0
            Invoke MUIGetExtProperty, hWin, @SysButtonIco
        .ELSE
            Invoke MUIGetExtProperty, hWin, @SysButtonIcoAlt
            .IF eax == NULL ; try to get ordinary icon handle
                Invoke MUIGetExtProperty, hWin, @SysButtonIco
            .ENDIF
        .ENDIF
        mov hIcon, eax
    .ENDIF

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

    .IF UseIcons == FALSE || hIcon == NULL
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

    .ELSE
        ;----------------------------------------------------------
        ; Draw Icon
        ;----------------------------------------------------------
        
        ; get icon width and height and center it in our client
        Invoke MUIGetImageSize, hIcon, MUIIT_ICO, Addr nIcoWidth, Addr nIcoHeight
        ;Invoke _MUI_SysButtonGetIconSize, hIcon, Addr nIcoWidth, Addr nIcoHeight
        
        mov eax, rect.right
        shr eax, 1
        mov ebx, nIcoWidth
        shr ebx, 1
        sub eax, ebx
        mov pt.x, eax
                
        mov eax, rect.bottom
        shr eax, 1
        mov ebx, nIcoHeight
        shr ebx, 1
        sub eax, ebx
        mov pt.y, eax

        Invoke DrawIconEx, hdcMem, pt.x, pt.y, hIcon, 0, 0, NULL, NULL, DI_NORMAL

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

_MUI_SysButtonPaint ENDP


;-------------------------------------------------------------------------------------
; Applies the ModernUI style to a dialog to make it a captionless, borderless form. 
; User can manually change a form in a resource editor to have the following style
; flags: WS_POPUP or WS_VISIBLE and optionally with DS_CENTER /DS_CENTERMOUSE / 
; WS_CLIPCHILDREN / WS_CLIPSIBLINGS / WS_MINIMIZE / WS_MAXIMIZE
;-------------------------------------------------------------------------------------
_MUI_ApplyMUIStyleToDialog PROC PUBLIC hWin:DWORD, dwDropShadow:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwNewStyle:DWORD
    LOCAL dwClassStyle:DWORD
    
    mov dwNewStyle, WS_POPUP
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    and eax, DS_CENTER
    .IF eax == DS_CENTER
        or dwNewStyle, DS_CENTER
    .ENDIF
    
    mov eax, dwStyle
    and eax, DS_CENTERMOUSE
    .IF eax == DS_CENTERMOUSE
        or dwNewStyle, DS_CENTERMOUSE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_VISIBLE
    .IF eax == WS_VISIBLE
        or dwNewStyle, WS_VISIBLE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_MINIMIZE
    .IF eax == WS_MINIMIZE
        or dwNewStyle, WS_MINIMIZE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_MAXIMIZE
    .IF eax == WS_MAXIMIZE
        or dwNewStyle, WS_MAXIMIZE
    .ENDIF        

    mov eax, dwStyle
    and eax, WS_CLIPSIBLINGS
    .IF eax == WS_CLIPSIBLINGS
        or dwNewStyle, WS_CLIPSIBLINGS
    .ENDIF        
    
    or dwNewStyle, WS_CLIPCHILDREN

    Invoke SetWindowLong, hWin, GWL_STYLE, dwNewStyle
    
    ; Set dropshadow on or off on our dialog
    
    Invoke GetClassLong, hWin, GCL_STYLE
    mov dwClassStyle, eax
    
    .IF dwDropShadow == TRUE
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax != CS_DROPSHADOW
            or dwClassStyle, CS_DROPSHADOW
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
        .ENDIF
    .ELSE    
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax == CS_DROPSHADOW
            and dwClassStyle,(-1 xor CS_DROPSHADOW)
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
        .ENDIF
    .ENDIF

    ; remove any menu that might have been assigned via class registration - for modern ui look
    Invoke GetMenu, hWin
    .IF eax != NULL
        Invoke SetMenu, hWin, NULL
    .ENDIF
    
    ret

_MUI_ApplyMUIStyleToDialog ENDP


;-------------------------------------------------------------------------------------
; _MUI_SysButtonGetIconSize
;-------------------------------------------------------------------------------------
;_MUI_SysButtonGetIconSize PROC PRIVATE USES EBX hIcon:DWORD, lpdwIconWidth:DWORD, lpdwIconHeight:DWORD
;    LOCAL bm:BITMAP
;    LOCAL iinfo:ICONINFO
;
;    Invoke GetIconInfo, hIcon, Addr iinfo ; get icon information
;    mov eax, iinfo.hbmColor ; bitmap info of icon has width/height
;    .IF eax != NULL
;        Invoke GetObject, iinfo.hbmColor, SIZEOF bm, Addr bm
;        mov eax, bm.bmWidth
;        mov ebx, lpdwIconWidth
;        mov [ebx], eax
;        mov eax, bm.bmHeight
;        mov ebx, lpdwIconHeight
;        mov [ebx], eax
;    .ELSE ; Icon has no color plane, image width/height data stored in mask
;        mov eax, iinfo.hbmMask
;        .IF eax != NULL
;            Invoke GetObject, iinfo.hbmMask, SIZEOF bm, Addr bm
;            mov eax, bm.bmWidth
;            mov ebx, lpdwIconWidth
;            mov [ebx], eax
;            mov eax, bm.bmHeight
;            shr eax, 1 ;bmp.bmHeight / 2;
;            mov ebx, lpdwIconHeight
;            mov [ebx], eax                
;        .ENDIF
;    .ENDIF
;    ; free up color and mask icons created by the GetIconInfo function
;    mov eax, iinfo.hbmColor
;    .IF eax != NULL
;        Invoke DeleteObject, eax
;    .ENDIF
;    mov eax, iinfo.hbmMask
;    .IF eax != NULL
;        Invoke DeleteObject, eax
;    .ENDIF
;
;    mov eax, TRUE
;    ret
;
;_MUI_SysButtonGetIconSize ENDP


;-------------------------------------------------------------------------------------
; MUICaptionBarLoadIcons
;-------------------------------------------------------------------------------------
MUICaptionBarLoadIcons PROC PUBLIC hCaptionBar:DWORD, idResMin:DWORD, idResMinAlt:DWORD, idResMax:DWORD, idResMaxAlt:DWORD, idResRes:DWORD, idResResAlt:DWORD, idResClose:DWORD, idResCloseAlt:DWORD 
    LOCAL hinstance:DWORD
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    
    Invoke MUIGetExtProperty, hCaptionBar, @CaptionBarDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax
    
    .IF idResMin != NULL || idResMinAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin
        mov hSysButtonMin, eax
        
        .IF idResMin != NULL
            Invoke LoadImage, hinstance, idResMin, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonIco, eax
        .ENDIF
        .IF idResMinAlt != NULL
            Invoke LoadImage, hinstance, idResMinAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF

    .IF idResMax != NULL || idResMaxAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax
        mov hSysButtonMax, eax
        
        .IF idResMax != NULL
            Invoke LoadImage, hinstance, idResMax, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonIco, eax
        .ENDIF
        .IF idResMaxAlt != NULL
            Invoke LoadImage, hinstance, idResMaxAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF

    .IF idResRes != NULL || idResResAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes
        mov hSysButtonRes, eax
        
        .IF idResRes != NULL
            Invoke LoadImage, hinstance, idResRes, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonIco, eax
        .ENDIF
        .IF idResResAlt != NULL
            Invoke LoadImage, hinstance, idResResAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF
    
    .IF idResClose != NULL || idResCloseAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose
        mov hSysButtonClose, eax
        
        .IF idResClose != NULL
            Invoke LoadImage, hinstance, idResClose, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIco, eax
        .ENDIF
        .IF idResClose != NULL
            Invoke LoadImage, hinstance, idResCloseAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF
    

    mov eax, TRUE
    ret

MUICaptionBarLoadIcons ENDP


;-------------------------------------------------------------------------------------
; MUICaptionBarLoadIcons - version for loading from DLL's that have the icon resources
;-------------------------------------------------------------------------------------
MUICaptionBarLoadIconsDll PROC PUBLIC hCaptionBar:DWORD, hInst:DWORD, idResMin:DWORD, idResMinAlt:DWORD, idResMax:DWORD, idResMaxAlt:DWORD, idResRes:DWORD, idResResAlt:DWORD, idResClose:DWORD, idResCloseAlt:DWORD 
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    
    .IF idResMin != NULL || idResMinAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMin
        mov hSysButtonMin, eax
        
        .IF idResMin != NULL
            Invoke LoadImage, hInst, idResMin, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonIco, eax
        .ENDIF
        .IF idResMinAlt != NULL
            Invoke LoadImage, hInst, idResMinAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF

    .IF idResMax != NULL || idResMaxAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonMax
        mov hSysButtonMax, eax
        
        .IF idResMax != NULL
            Invoke LoadImage, hInst, idResMax, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonIco, eax
        .ENDIF
        .IF idResMaxAlt != NULL
            Invoke LoadImage, hInst, idResMaxAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF

    .IF idResRes != NULL || idResResAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonRes
        mov hSysButtonRes, eax
        
        .IF idResRes != NULL
            Invoke LoadImage, hInst, idResRes, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonIco, eax
        .ENDIF
        .IF idResResAlt != NULL
            Invoke LoadImage, hInst, idResResAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF
    
    .IF idResClose != NULL || idResCloseAlt != NULL
        Invoke MUIGetIntProperty, hCaptionBar, @CaptionBar_hSysButtonClose
        mov hSysButtonClose, eax
        
        .IF idResClose != NULL
            Invoke LoadImage, hInst, idResClose, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIco, eax
        .ENDIF
        .IF idResClose != NULL
            Invoke LoadImage, hInst, idResCloseAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIcoAlt, eax
        .ENDIF
    .ENDIF
    

    mov eax, TRUE
    ret

MUICaptionBarLoadIconsDll ENDP







LIBEND
