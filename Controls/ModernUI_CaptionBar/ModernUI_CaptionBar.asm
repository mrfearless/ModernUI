;==============================================================================
;
; ModernUI Control - ModernUI_CaptionBar
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
include comctl32.inc
;include masm32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
;includelib masm32.lib

IFDEF MUI_USEGDIPLUS
ECHO MUI_USEGDIPLUS
include gdiplus.inc
include ole32.inc
includelib gdiplus.lib
includelib ole32.lib
ELSE
ECHO MUI_DONTUSEGDIPLUS
ENDIF

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_CaptionBar.inc

;IFNDEF LIBEND
;    LIBEND TEXTEQU <END>
;ELSE
;    LIBEND TEXTEQU <>
;ENDIF


;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------


_MUI_CaptionBarWndProc          PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CaptionBarInit             PROTO :DWORD
_MUI_CaptionBarCleanup          PROTO :DWORD
_MUI_CaptionBarPaint            PROTO :DWORD
_MUI_CaptionBarPaintBackground  PROTO :DWORD, :DWORD, :DWORD
_MUI_CaptionBarPaintImage       PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CaptionBarReposition       PROTO :DWORD
_MUI_CaptionBarParentSubClassProc PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD


_MUI_CaptionBarBackLoadBitmap   PROTO :DWORD, :DWORD, :DWORD
_MUI_CaptionBarBackLoadIcon     PROTO :DWORD, :DWORD, :DWORD

_MUI_CreateCaptionBarSysButtons PROTO :DWORD, :DWORD
_MUI_CreateSysButton            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SysButtonWndProc           PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SysButtonInit              PROTO :DWORD
_MUI_SysButtonCleanup           PROTO :DWORD
_MUI_SysButtonPaint             PROTO :DWORD
_MUI_SysButtonSetPropertyEx     PROTO :DWORD, :DWORD, :DWORD

_MUI_ApplyMUIStyleToDialog      PROTO :DWORD, :DWORD


_MUI_CreateCapButton            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CapButtonWndProc           PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CapButtonInit              PROTO :DWORD
_MUI_CapButtonCleanup           PROTO :DWORD
_MUI_CapButtonPaint             PROTO :DWORD
_MUI_CapButtonsReposition       PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_CapButtonSetPropertyEx     PROTO :DWORD, :DWORD, :DWORD


_CBP_MouseOverBorders           PROTO :DWORD, :DWORD


;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; CaptionBar External Properties
IFNDEF MUI_CAPTIONBAR_PROPERTIES
MUI_CAPTIONBAR_PROPERTIES       STRUCT
    dwTextColor                 DD ?    ; RGBCOLOR. Text color for captionbar text and system buttons (min/max/restore/close)
    dwTextFont                  DD ?    ; hFont. Font for captionbar text
    dwBackColor                 DD ?    ; RGBCOLOR. Background color of captionbar and system buttons (min/max/restore/close)
    dwBackImageType             DD ?    ; DWORD. Image Type - One of the following: MUICBIT_NONE,MUICBIT_BMP, MUICBIT_ICO, MUICBIT_PNG
    dwBackImage                 DD ?    ; hImage. Image to display in captionbar background.
    dwBackImageOffsetX          DD ?    ; DWORD. Offset x +/- to set position of hImage
    dwBackImageOffsetY          DD ?    ; DWORD. Offset y +/- to set position of hImage    
    dwButtonTextRollColor       DD ?    ; RGBCOLOR. Text color for system buttons (min/max/restore/close) when mouse moves over button
    dwButtonBackRollColor       DD ?    ; RGBCOLOR. Background color for system buttons (min/max/restore/close) when mouse moves over button
    dwButtonBorderColor         DD ?    ; RGBCOLOR. Border color for system buttons (min/max/restore/close). 0 = use same as @CaptionBarBackColor
    dwButtonBorderRollColor     DD ?    ; RGBCOLOR. Border color for system buttons (min/max/restore/close) when mouse moves over button. 0 = use @CaptionBarBtnBckRollColor  
    dwButtonsWidth              DD ?    ; DWORD. System buttons width. Defaults = 32px
    dwButtonsHeight             DD ?    ; DWORD. System buttons height. Defaults = 28px
    dwButtonsOffsetX            DD ?    ; DWORD. Offset y +/- to set position of system buttons (min/max/restore/close) in relation to right of captionbar
    dwButtonsOffsetY            DD ?    ; DWORD. Offset y + to set position of system buttons (min/max/restore/close) in relation to top of captionbar    
    dwBtnIcoMin                 DD ?    ; hIcon. For minimize button
    dwBtnIcoMinAlt              DD ?    ; hIcon. For minimize button when mouse moves over button
    dwBtnIcoMax                 DD ?    ; hIcon. For maximize button
    dwBtnIcoMaxAlt              DD ?    ; hIcon. For maximize button when mouse moves over button
    dwBtnIcoRes                 DD ?    ; hIcon. For restore button
    dwBtnIcoResAlt              DD ?    ; hIcon. For restore button when mouse moves over button
    dwBtnIcoClose               DD ?    ; hIcon. For close button
    dwBtnIcoCloseAlt            DD ?    ; hIcon. For close button when mouse moves over button
    dwWindowBackColor           DD ?    ; RGBCOLOR. If -1 = No painting of window/dialog background, handled by user or default system.
    dwWindowBorderColor         DD ?    ; RGBCOLOR. If -1 = No border. if WindowBackColor != -1 then color of border to paint on window.    
    dwDllInstance               DD ?    ; hInstance. For loading resources (icons) - normally set to 0 (current module) but when resources are in a dll set this before calling MUICaptionBarLoadIcons
    dwCaptionBarParam           DD ?    ; DWORD. Custom user data
MUI_CAPTIONBAR_PROPERTIES       ENDS
ENDIF

; CaptionBar Internal Poperties
_MUI_CAPTIONBAR_PROPERTIES      STRUCT
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
    dwMouseDown                 DD ? 
    hSysButtonClose             DD ?
    hSysButtonMax               DD ?
    hSysButtonRes               DD ?
    hSysButtonMin               DD ?
    dwNoMoveWindow              DD ?
    dwUseIcons                  DD ?
    dwButtonsLeftOffset         DD ? ; calced left offset of all buttons including x offsets
    dwTotalButtons              DD ?
    dwButtonArray               DD ?    
_MUI_CAPTIONBAR_PROPERTIES      ENDS

; SysButton External Properties
IFNDEF MUI_SYSBUTTON_PROPERTIES
MUI_SYSBUTTON_PROPERTIES        STRUCT
    dwTextColor                 DD ?
    dwTextRollColor             DD ?
    dwBackColor                 DD ?
    dwBackRollColor             DD ?
    dwBorderColor               DD ?
    dwBorderRollColor           DD ?
    dwIco                       DD ?
    dwIcoAlt                    DD ?
    dwParam                     DD ?
    dwResourceID                DD ?
MUI_SYSBUTTON_PROPERTIES        ENDS
ENDIF

; SysButton Internal Properties
_MUI_SYSBUTTON_PROPERTIES       STRUCT
    dwSysButtonFont             DD ?
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
    dwUseIcons                  DD ?
_MUI_SYSBUTTON_PROPERTIES       ENDS

IFNDEF MUI_CAPBUTTON_PROPERTIES
MUI_CAPBUTTON_PROPERTIES        STRUCT  
    dwTextColor                 DD ?    ; RGBCOLOR
    dwTextRollColor             DD ?    ; RGBCOLOR
    dwBackColor                 DD ?    ; RGBCOLOR. Color of back of button.
    dwBackRollColor             DD ?    ; RGBCOLOR. Color of back of button when mouse moves over.
    dwBorderColor               DD ?    ; RGBCOLOR. Color of border of button. 0 = use same as dwBackColor
    dwBorderRollColor           DD ?    ; RGBCOLOR. Color of border of button when mouse moves over. 0 = use same as dwBackRollColor
    dwIco                       DD ?    ; hIcon. Handle of icon to use for button
    dwIcoAlt                    DD ?    ; hIcon. Handle of icon to use for button when mouse moves over it
    dwParam                     DD ?    ; DWORD. Custom user data. Passed as wNotifyCode (HIWORD of wParam) in WM_COMMAND
    dwResourceID                DD ?    ; DWORD. Resource ID for button    
MUI_CAPBUTTON_PROPERTIES        ENDS
ENDIF

_MUI_CAPBUTTON_PROPERTIES       STRUCT
    dwSysButtonFont             DD ?
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
    dwWidth                     DD ?
_MUI_CAPBUTTON_PROPERTIES       ENDS

.CONST

; Resource IDs for System Buttons: Min, Max, Restore and Close
; IDs for custom buttons are 1 to (MUI_SYSBUTTON_CLOSE-4)
MUI_SYSBUTTON_CLS_ID                        EQU 0FFFFh
MUI_SYSBUTTON_MAX_ID                        EQU (MUI_SYSBUTTON_CLS_ID -1)
MUI_SYSBUTTON_RES_ID                        EQU (MUI_SYSBUTTON_CLS_ID -2)
MUI_SYSBUTTON_MIN_ID                        EQU (MUI_SYSBUTTON_CLS_ID -3)

MUI_BORDER_SIZE                             EQU 8d
MUI_CAPTIONBAR_IMAGETEXT_PADDING            EQU 10d ; Padding space between end of image and start of text
MUI_CAPTIONBAR_TEXTLEFT_PADDING             EQU 6d  ; Padding space from left of ModernUI_CaptionBar to start of text if no image present
MUI_DEFAULT_CAPTION_HEIGHT                  EQU 32d ; Default height of caption bar control
MUI_SYSBUTTON_WIDTH                         EQU 32d ; Default width of system buttons
MUI_SYSBUTTON_HEIGHT                        EQU 28d ; Default height of system buttons
MUI_SYSBUTTONS_SPACING                      EQU 0   ; Spacing between each system button
MUI_SYSCAPBUTTON_SPACING                    EQU 12  ; Spacing between system buttons and capbuttons
MUI_CAPBUTTON_MAX                           EQU 8   ; Max no of capbuttons
MUI_CAPBUTTON_TEXT_PADDING                  EQU 3   ; Padding space from left of capbutton to start of text (if any text) 
MUI_CAPBUTTON_IMAGETEXT_PADDING             EQU 3   ; Padding space between end of image and start of text in capbutton 
MUI_CAPBUTTONS_SPACING                      EQU 4   ; Spacing between each capbutton
MUI_CAPBUTTON_TEXT_MAX                      EQU 32  ; Default max length of captionbutton text

; CaptionBar Internal Properties
@CaptionBarEnabledState                     EQU 0
@CaptionBarMouseOver                        EQU 4
@CaptionBarMouseDown                        EQU 8
@CaptionBar_hSysButtonClose                 EQU 12
@CaptionBar_hSysButtonMax                   EQU 16
@CaptionBar_hSysButtonRes                   EQU 20
@CaptionBar_hSysButtonMin                   EQU 24
@CaptionBarNoMoveWindow                     EQU 28
@CaptionBarUseIcons                         EQU 32
@CaptionBarButtonsLeftOffset                EQU 36
@CaptionBarTotalButtons                     EQU 40
@CaptionBarButtonArray                      EQU 44

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
@SysButtonBorderColor                       EQU 16
@SysButtonBorderRollColor                   EQU 20
@SysButtonIco                               EQU 24
@SysButtonIcoAlt                            EQU 28
@SysButtonParam                             EQU 32
@SysButtonResourceID                        EQU 36


; CapButton Internal Properties
@CapButtonFont                              EQU 0
@CapButtonEnabledState                      EQU 4
@CapButtonMouseOver                         EQU 8
@CapButtonWidth                             EQU 12






.DATA
ALIGN 4
szMUICaptionBarClass                        DB 'ModernUI_CaptionBar',0  ; Class name for our CaptionBar control
szMUISysButtonClass                         DB 'ModernUI_SysButton',0   ; Class name for our system buttons (min/max/restore or close buttons)
szMUICapButtonClass                         DB 'ModernUI_CapButton',0   ; Class name for our custom captionbar buttons (shown before system buttons)
szMUISysButtonFont                          DB 'Marlett',0              ; System font used for drawing min/max/restore/close glyphs from marlett font
szMUICapButtonFont                          DB 'Segoe UI',0             ; Font used for drawing custom captionbar buttons
szMUICaptionBarFont                         DB 'Segoe UI',0             ; Font used for caption text
hMUICaptionBarFont                          DD 0                        ; Handle to caption button font (segoe ui)
hMUISysButtonFont                           DD 0                        ; Handle to system button font (marlett)
hMUICapButtonFont                           DD 0                        ; Handle to capbutton font
szMUISysMinButton                           DB '0',0                    ; Minimize button glyph from Marlett font
szMUISysMaxButton                           DB '1',0                    ; Maximize button glyph from Marlett font
szMUISysResButton                           DB '2',0                    ; Restore button glyph from Marlett font
szMUISysCloseButton                         DB 'r',0                    ; Close/exit button glyph from Marlett font
szMUISysResizeGrip                          DB 'o',0                    ; Resize grip button glyph from Marlett font


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for CaptionBar control
;------------------------------------------------------------------------------
MUICaptionBarSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUICaptionBarSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for CaptionBar control
;------------------------------------------------------------------------------
MUICaptionBarGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUICaptionBarGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICaptionBarRegister - Registers the ModernUI_CaptionBar control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_CaptionBar
;------------------------------------------------------------------------------
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


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICaptionBarCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
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


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarWndProc - Main processing window for our CaptionBar control
;------------------------------------------------------------------------------
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
        Invoke _MUI_CaptionBarCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == MUI_SYSBUTTON_CLS_ID ; close button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_CLOSE, 0
            ;Invoke SendMessage, eax, WM_CLOSE, 0, 0
            ret
        .ELSEIF eax == MUI_SYSBUTTON_MAX_ID ; max button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_MAXIMIZE, 0
            ;Invoke ShowWindow, eax, SW_MAXIMIZE
            Invoke _MUI_CaptionBarReposition, hWin
            ret            
        .ELSEIF eax == MUI_SYSBUTTON_RES_ID ; res button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_RESTORE, 0
            ;Invoke ShowWindow, eax, SW_RESTORE
            Invoke _MUI_CaptionBarReposition, hWin
            ret
        .ELSEIF eax == MUI_SYSBUTTON_MIN_ID ; min button
            Invoke GetParent, hWin
            Invoke SendMessage, eax, WM_SYSCOMMAND, SC_MINIMIZE, 0
            ;Invoke ShowWindow, eax, SW_MINIMIZE
            ret
        .ELSE ; pass on any WM_COMMANDS back to parent - Main window proc for processing
            Invoke GetParent, hWin
            Invoke PostMessage, eax, WM_COMMAND, wParam, lParam ; useful for hosted controls inside CaptionBar
        .ENDIF
        xor eax, eax
        ret
    
    .ELSEIF eax == WM_NOTIFY ; pass on any WM_NOTIFY back to parent - Main window proc for notifications
        Invoke GetParent, hWin
        Invoke PostMessage, eax, WM_NOTIFY, wParam, lParam ; useful for hosted controls inside CaptionBar
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

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseDown, TRUE
        
    .ELSEIF eax == WM_LBUTTONUP
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseDown, FALSE
        
    .ELSEIF eax == WM_NCHITTEST
        ; https://github.com/mrfearless/ModernUI/issues/7
        ; add additonal logic to prevent wine sticky (until ESC pressed) of the mouse cursor on the caption

        Invoke MUIGetIntProperty, hWin, @CaptionBarMouseDown
        .IF eax == TRUE ; mouse is actually down
            Invoke MUIGetIntProperty, hWin, @CaptionBarNoMoveWindow
            .IF eax == FALSE
                Invoke GetParent, hWin
                Invoke SendMessage, eax, WM_NCLBUTTONDOWN, HTCAPTION, 0
            .ENDIF
        .ELSE ; otherwise we didnt detect mouse down ourselves, so no sticky move of caption hopefully
            ; do we need to force it to nowhere?
            ;Invoke GetParent, hWin
            ;Invoke SendMessage, eax, WM_NCLBUTTONDOWN, HTNOWHERE, 0
        .ENDIF

   .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUIGetIntProperty, hWin, @CaptionBarEnabledState
        .IF eax == TRUE   
            Invoke MUISetIntProperty, hWin, @CaptionBarMouseOver, TRUE
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
        Invoke GetParent, hWin
        Invoke PostMessage, eax, WM_MOUSEMOVE, wParam, lParam ; pass mousemove to parent        
        
    .ELSEIF eax == WM_MOUSELEAVE
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseOver, FALSE
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseDown, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseOver, FALSE
        Invoke MUISetIntProperty, hWin, @CaptionBarMouseDown, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
    
    .ELSEIF eax == WM_SIZE
        Invoke _MUI_CaptionBarReposition, hWin
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SETTEXT ; todo check style to see if it should set caption text
        Invoke GetParent, hWin
        mov hParent, eax
         ; sets text of our CaptionBar
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        ; Set main window title
        Invoke SetWindowText, hParent, lParam
        Invoke InvalidateRect, hWin, NULL, FALSE
        mov eax, TRUE
        ret
    
    .ELSEIF eax == WM_SETICON
        Invoke MUISetExtProperty, hWin, @CaptionBarBackImageType, MUICBIT_ICO
        Invoke MUISetExtProperty, hWin, @CaptionBarBackImage, lParam
        Invoke InvalidateRect, hWin, NULL, FALSE
        ret
    
    ; custom messages start here
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY
        Invoke MUISetExtProperty, hWin, wParam, lParam
        
        ; also set child system button properties as well if they apply
        Invoke _MUI_SysButtonSetPropertyEx, hWin, wParam, lParam
        ; also set child CapButton properties as well if they apply
        Invoke _MUI_CapButtonSetPropertyEx, hWin, wParam, lParam

        mov eax, wParam
        .IF eax == @CaptionBarBtnWidth || eax == @CaptionBarBtnHeight || eax == @CaptionBarBtnOffsetX || eax == @CaptionBarBtnOffsetY
            Invoke _MUI_CaptionBarReposition, hWin
        .ELSEIF eax == @CaptionBarBackImageOffsetX || eax == @CaptionBarBackImageOffsetY
            Invoke InvalidateRect, hWin, NULL, FALSE
        .ELSEIF eax == @CaptionBarWindowBorderColor 
            .IF lParam == -1
                Invoke GetWindowLong, hWin, GWL_STYLE
                or eax, MUICS_NOBORDER ; no border color, so set no border style on as we want pos 0,0
            .ELSE
                Invoke GetWindowLong, hWin, GWL_STYLE
                and eax, (-1 xor MUICS_NOBORDER) ; we have border color so set no border style off as we want pos 1,1
            .ENDIF
            Invoke SetWindowLong, hWin, GWL_STYLE, eax
            Invoke _MUI_CaptionBarReposition, hWin
        .ELSEIF eax == @CaptionBarWindowBackColor
            Invoke GetParent, hWin
            Invoke InvalidateRect, eax, NULL, TRUE
        .ENDIF
        ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret
_MUI_CaptionBarWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarParentSubClassProc - Subclass for caption bar parent window 
; dwRefData is the handle to our CaptionBar control in this subclass proc
;------------------------------------------------------------------------------
_MUI_CaptionBarParentSubClassProc PROC PRIVATE hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL wp:WINDOWPLACEMENT
    LOCAL dwStyle:DWORD
    LOCAL BackColor:DWORD
    
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Addr _MUI_CaptionBarParentSubClassProc, uIdSubclass ; remove subclass before control destroyed.
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        ret
    
    ; Handle resize of dialog/window and invalidate it if we are painting a border via MUIPaintBackground
    .ELSEIF eax == WM_NCCALCSIZE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        ret
    
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
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam


    .ELSEIF eax == WM_ERASEBKGND
        Invoke MUIGetExtProperty, dwRefData, @CaptionBarWindowBackColor
        .IF eax == -1
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            ret
        .ELSE
            ;PrintText 'Parent WM_ERASEBKGND'
            mov eax, 1
            ret
        .ENDIF

    .ELSEIF eax == WM_PAINT
        Invoke MUIGetExtProperty, dwRefData, @CaptionBarWindowBackColor
        .IF eax == -1
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam         
            ret
        .ELSE
            ;PrintText 'Parent WM_PAINT'
            mov BackColor, eax
            Invoke MUIGetExtProperty, dwRefData, @CaptionBarWindowBorderColor
            Invoke MUIPaintBackground, hWin, BackColor, eax
            ret
        .ENDIF
    
;    .ELSEIF eax == WM_NCHITTEST
;        mov eax, HTTRANSPARENT
;        ret

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke GetWindowLong, dwRefData, GWL_STYLE
        and eax, MUICS_WINSIZE
        .IF eax == MUICS_WINSIZE    
            Invoke _CBP_MouseOverBorders, hWin, TRUE
            .IF eax != 0
                .IF eax == 1 ; left
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTLEFT, 0
                .ELSEIF eax == 2 ; top
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTTOP, 0
                .ELSEIF eax == 3 ; right
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTRIGHT, 0
                .ELSEIF eax == 4 ; bottom
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTBOTTOM, 0
                .ELSEIF eax == 5 ; NW
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTTOPLEFT, 0
                .ELSEIF eax == 6 ; NE
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTTOPRIGHT, 0
                .ELSEIF eax == 7 ; SW
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTBOTTOMLEFT, 0
                .ELSEIF eax == 8 ; SE
                    Invoke SendMessage, hWin, WM_NCLBUTTONDOWN, HTBOTTOMRIGHT, 0
                .ENDIF
                ; todo investigate weird artifacts on resizing, its like parts of the dropshadow are showing, or maybe its the border?
                ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED ;or SWP_NOSENDCHANGING
                ;Invoke InvalidateRect, hWin, NULL, TRUE
                ;Invoke UpdateWindow, hWin
            .ENDIF
        .ENDIF
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        ret        

;    .ELSEIF eax == WM_LBUTTONUP ; click on window, move over min, then close, then back to window, and release click - grey colored squares?
;        Invoke GetWindowLong, dwRefData, GWL_STYLE
;        mov dwStyle, eax
;        and eax, MUICS_WINSIZE
;        .IF eax == MUICS_WINSIZE
;            Invoke InvalidateRect, hWin, NULL, TRUE
;        .ENDIF
;        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
;        ret

    .ELSEIF eax == WM_MOUSEMOVE
        Invoke GetWindowLong, dwRefData, GWL_STYLE
        and eax, MUICS_WINSIZE
        .IF eax == MUICS_WINSIZE 
            Invoke _CBP_MouseOverBorders, hWin, TRUE
        .ENDIF
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam

;    .ELSEIF eax == WM_SETICON
;        Invoke MUISetExtProperty, dwRefData, @CaptionBarBackImageType, MUICBIT_ICO
;        Invoke MUISetExtProperty, dwRefData, @CaptionBarBackImage, lParam
;        Invoke InvalidateRect, dwRefData, NULL, FALSE
;        Invoke DefSubclassProc, hWin, uMsg, ICON_SMALL, lParam
;        ret
    
    ; If user pulls caption down whilst maximized this will be caught by this handler and we can adjust the CaptionBar control to reflect the 
    ; restore state it will be in. Or if user programmatically changes window this should catch it as well.
    .ELSEIF eax == WM_SIZE
        mov eax, wParam
        .IF eax == SIZE_MAXIMIZED
            Invoke SendMessage, dwRefData, WM_SIZE, 0, 0 ; force reposition of CaptionBar and its child controls
        .ELSEIF eax == SIZE_RESTORED
            Invoke SendMessage, dwRefData, WM_SIZE, 0, 0 ; force reposition of CaptionBar and its child controls
        .ENDIF
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
    
    .ELSE
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
        ret
    .ENDIF

    ret        
_MUI_CaptionBarParentSubClassProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _CBP_MouseOverBorders - set initial default values
;------------------------------------------------------------------------------
; precalc rects? store somewhere for checking later on, recalc on resize
_CBP_MouseOverBorders PROC hWin:DWORD, bShowCursor:DWORD
    LOCAL dwPos:DWORD
    LOCAL winrect:RECT
    LOCAL borderleft:RECT
    LOCAL bordertop:RECT
    LOCAL borderright:RECT
    LOCAL borderbottom:RECT
    LOCAL cornernw:RECT
    LOCAL cornerne:RECT
    LOCAL cornersw:RECT
    LOCAL cornerse:RECT
    LOCAL pt:POINT
    
    Invoke GetWindowRect, hWin, Addr winrect
    Invoke GetCursorPos, Addr pt
    Invoke CopyRect, Addr borderleft, Addr winrect
    Invoke CopyRect, Addr bordertop, Addr winrect
    Invoke CopyRect, Addr borderright, Addr winrect
    Invoke CopyRect, Addr borderbottom, Addr winrect
    Invoke CopyRect, Addr cornernw, Addr winrect
    Invoke CopyRect, Addr cornerne, Addr winrect
    Invoke CopyRect, Addr cornersw, Addr winrect
    Invoke CopyRect, Addr cornerse, Addr winrect
    
    
    mov eax, borderleft.left
    add eax, MUI_BORDER_SIZE
    mov borderleft.right, eax
    add borderleft.top, MUI_BORDER_SIZE
    sub borderleft.bottom, MUI_BORDER_SIZE
    
    mov eax, bordertop.top
    add eax, MUI_BORDER_SIZE
    mov bordertop.bottom, eax
    add bordertop.left, MUI_BORDER_SIZE
    sub bordertop.right, MUI_BORDER_SIZE
   
    mov eax, borderright.right
    sub eax, MUI_BORDER_SIZE
    mov borderright.left, eax
    add borderright.top, MUI_BORDER_SIZE
    sub borderright.bottom, MUI_BORDER_SIZE
    
    mov eax, borderbottom.bottom
    sub eax, MUI_BORDER_SIZE
    mov borderbottom.top, eax
    add borderbottom.left, MUI_BORDER_SIZE
    sub borderbottom.right, MUI_BORDER_SIZE
    
    ; Corner NW
    mov eax, cornernw.left
    add eax, MUI_BORDER_SIZE
    mov cornernw.right, eax
    mov eax, cornernw.top
    add eax, MUI_BORDER_SIZE
    mov cornernw.bottom, eax
    
    ; Corner NE
    mov eax, cornerne.right
    sub eax, MUI_BORDER_SIZE
    mov cornerne.left, eax
    mov eax, cornerne.top
    add eax, MUI_BORDER_SIZE
    mov cornerne.bottom, eax
    
    ; Corner SW
    mov eax, cornersw.left
    add eax, MUI_BORDER_SIZE
    mov cornersw.right, eax
    mov eax, cornersw.bottom
    sub eax, MUI_BORDER_SIZE
    mov cornersw.top, eax
    
    ; Corner SE
    mov eax, cornerse.right
    sub eax, MUI_BORDER_SIZE
    mov cornerse.left, eax
    mov eax, cornerse.bottom
    sub eax, MUI_BORDER_SIZE
    mov cornerse.top, eax
    
    mov dwPos, 0
    Invoke PtInRect, Addr borderleft, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'leftborder'
        mov dwPos, 1
    .ENDIF
    
    Invoke PtInRect, Addr bordertop, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'topborder'
        mov dwPos, 2
    .ENDIF
    
    Invoke PtInRect, Addr borderright, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'rightborder'
        mov dwPos, 3
    .ENDIF
    
    Invoke PtInRect, Addr borderbottom, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'bottomborder'
        mov dwPos, 4
    .ENDIF
    
    Invoke PtInRect, Addr cornernw, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'NW'
        mov dwPos, 5
    .ENDIF
    
    Invoke PtInRect, Addr cornerne, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'NE'
        mov dwPos, 6
    .ENDIF
    
    Invoke PtInRect, Addr cornersw, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'SW'
        mov dwPos, 7
    .ENDIF
    
    Invoke PtInRect, Addr cornerse, pt.x, pt.y
    .IF eax == TRUE
        ;PrintText 'SE'
        mov dwPos, 8
    .ENDIF
    
    .IF bShowCursor == TRUE
        mov eax, dwPos
        .IF eax == 1
            Invoke LoadCursor, NULL, IDC_SIZEWE
        .ELSEIF eax == 2 
            Invoke LoadCursor, NULL, IDC_SIZENS
        .ELSEIF eax == 3
            Invoke LoadCursor, NULL, IDC_SIZEWE
        .ELSEIF eax == 4
            Invoke LoadCursor, NULL, IDC_SIZENS
        .ELSEIF eax == 5 ; NW
            Invoke LoadCursor, NULL, IDC_SIZENWSE
        .ELSEIF eax == 6 ; NE
            Invoke LoadCursor, NULL, IDC_SIZENESW
        .ELSEIF eax == 7 ; SW
            Invoke LoadCursor, NULL, IDC_SIZENESW
        .ELSEIF eax == 8 ; SE
            Invoke LoadCursor, NULL, IDC_SIZENWSE
        .ELSE
            Invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
    .ENDIF
    
    mov eax, dwPos
    ret

_CBP_MouseOverBorders ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarInit - set initial default values
;------------------------------------------------------------------------------
_MUI_CaptionBarInit PROC PRIVATE USES EBX hWin:DWORD
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
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF

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
        Invoke MUISetIntProperty, hWin, @CaptionBarNoMoveWindow, TRUE
    .ELSE
        Invoke MUISetIntProperty, hWin, @CaptionBarNoMoveWindow, FALSE
    .ENDIF

    ; Check if to use icons or not?
    mov eax, dwStyle
    and eax, MUICS_USEICONSFORBUTTONS
    .IF eax == MUICS_USEICONSFORBUTTONS  
        Invoke MUISetIntProperty, hWin, @CaptionBarUseIcons, TRUE
    .ELSE
        Invoke MUISetIntProperty, hWin, @CaptionBarUseIcons, FALSE
    .ENDIF

    ; Set default initial external property values     
    Invoke MUISetExtProperty, hWin, @CaptionBarTextColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hWin, @CaptionBarBackColor, MUI_RGBCOLOR(27,161,226);MUI_RGBCOLOR(21,133,181)
    Invoke MUISetExtProperty, hWin, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(61,61,61)
    Invoke MUISetExtProperty, hWin, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(87,193,244) 
    Invoke MUISetExtProperty, hWin, @CaptionBarBtnWidth, MUI_SYSBUTTON_WIDTH ;32d
    Invoke MUISetExtProperty, hWin, @CaptionBarBtnHeight, MUI_SYSBUTTON_HEIGHT ;28d
    Invoke MUISetExtProperty, hWin, @CaptionBarDllInstance, 0
    Invoke MUISetExtProperty, hWin, @CaptionBarBackImageOffsetX, 0
    Invoke MUISetExtProperty, hWin, @CaptionBarBackImageOffsetY, 0
    Invoke MUISetExtProperty, hWin, @CaptionBarBtnOffsetX, 0
    Invoke MUISetExtProperty, hWin, @CaptionBarBtnOffsetY, 0
    Invoke MUISetExtProperty, hWin, @CaptionBarWindowBackColor, -1
    Invoke MUISetExtProperty, hWin, @CaptionBarWindowBorderColor, -1

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
    Invoke MUISetExtProperty, hWin, @CaptionBarTextFont, hMUICaptionBarFont

    Invoke _MUI_CreateCaptionBarSysButtons, hWin, hParent
    ; 26/07/2016 - needed to remove as some dialogs without max/res would show up with artifact drawing if border drawn
    ;mov eax, dwStyle
    ;and eax, MUICS_NOMAXBUTTON
    ;.IF eax != MUICS_NOMAXBUTTON
        ; only need to subclass to handle catching restore/maximize - no need if max/res button is not present 
        Invoke SetWindowSubclass, hParent, Addr _MUI_CaptionBarParentSubClassProc, hWin, hWin
    ;.ENDIF
    
    ; alloc space for capbuttons
    mov eax, SIZEOF DWORD
    mov ebx, MUI_CAPBUTTON_MAX
    mul ebx
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, eax
    .IF eax != 0
        Invoke MUISetIntProperty, hWin, @CaptionBarButtonArray, eax
    .ENDIF
    
    ret
_MUI_CaptionBarInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarCleanup - cleanup a few things before control is destroyed
;------------------------------------------------------------------------------
_MUI_CaptionBarCleanup PROC PRIVATE hWin:DWORD
    LOCAL ImageType:DWORD
    LOCAL hImage:DWORD

    IFDEF DEBUG32
    PrintText '_MUI_CaptionBarCleanup'
    ENDIF

    Invoke MUIGetExtProperty, hWin, @CaptionBarBackImageType
    mov ImageType, eax

    .IF ImageType == 0
        ret
    .ENDIF

    Invoke MUIGetExtProperty, hWin, @CaptionBarBackImage
    mov hImage, eax
    .IF eax != 0
        .IF ImageType != 3
            Invoke DeleteObject, eax
        ;.ELSE
        ;    IFDEF MUI_USEGDIPLUS
        ;    Invoke GdipDisposeImage, eax
        ;    ENDIF
        .ENDIF
    .ENDIF


    Invoke MUIGetIntProperty, hWin, @CaptionBarButtonArray
    .IF eax != 0
        Invoke GlobalFree, eax
    .ENDIF


    ret
_MUI_CaptionBarCleanup ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarPaint - main CaptionBar painting
;------------------------------------------------------------------------------
_MUI_CaptionBarPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL textrect:RECT
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
    LOCAL dwBtnHeight:DWORD
    LOCAL dwOffsetY:DWORD
    LOCAL dwOffsetX:DWORD
    LOCAL dwImageWidth:DWORD
    LOCAL szText[256]:BYTE    

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect
    Invoke CopyRect, Addr textrect, Addr rect
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
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
    mov dwBtnHeight, eax
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnOffsetY
    .IF eax != 0
        .IF sdword ptr eax < 0
            neg eax
        .ENDIF    
    .ELSE
        mov eax, 0
    .ENDIF
    mov dwOffsetY, eax
    Invoke MUIGetExtProperty, hWin, @CaptionBarBackImageOffsetX
    .IF eax != 0
        .IF sdword ptr eax < 0
            neg eax
        .ENDIF    
    .ELSE
        mov eax, 0
    .ENDIF
    mov dwOffsetX, eax
    
    ;----------------------------------------------------------
    ; Fill background
    ;----------------------------------------------------------
    Invoke _MUI_CaptionBarPaintBackground, hWin, hdcMem, Addr rect

    ;----------------------------------------------------------
    ; Image (if any)
    ;----------------------------------------------------------
    Invoke _MUI_CaptionBarPaintImage, hWin, hdc, hdcMem, Addr rect
    mov dwImageWidth, eax

    ;----------------------------------------------------------
    ; Draw Text
    ;----------------------------------------------------------
    Invoke SetBkMode, hdcMem, OPAQUE
    Invoke SetBkColor, hdcMem, BackColor
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, BackColor
    ;Invoke FillRect, hdcMem, Addr rect, hBrush
    mov eax, dwStyle
    and eax, MUICS_NOCAPTIONTITLETEXT
    .IF eax != MUICS_NOCAPTIONTITLETEXT

        Invoke SelectObject, hdcMem, hFont
        mov hOldFont, eax
        Invoke GetWindowText, hWin, Addr szText, sizeof szText
        Invoke SetTextColor, hdcMem, TextColor

        mov eax, dwBtnHeight
        add eax, dwOffsetY
        add eax, dwOffsetY
        mov textrect.bottom, eax
        mov eax, dwImageWidth
        add eax, dwOffsetX
        add textrect.left, eax

        mov eax, dwStyle
        and eax, MUICS_CENTER
        .IF eax == MUICS_CENTER
            Invoke DrawText, hdcMem, Addr szText, -1, Addr textrect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
        .ELSE ; MUICS_LEFT
            .IF dwImageWidth != 0
                add textrect.left, MUI_CAPTIONBAR_IMAGETEXT_PADDING
            .ELSE
                add textrect.left, MUI_CAPTIONBAR_TEXTLEFT_PADDING
            .ENDIF
            Invoke DrawText, hdcMem, Addr szText, -1, Addr textrect, DT_SINGLELINE or DT_LEFT or DT_VCENTER
            ;.IF dwImageWidth != 0
            ;    sub textrect.left, MUI_CAPTIONBAR_IMAGETEXT_PADDING
            ;.ELSE
            ;    sub textrect.left, MUI_CAPTIONBAR_TEXTLEFT_PADDING
            ;.ENDIF
        .ENDIF
    .ENDIF
    
    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    .IF hOldBrush != 0
        Invoke SelectObject, hdcMem, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    .IF hOldFont != 0
        Invoke SelectObject, hdcMem, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem

    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_CaptionBarPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarPaintBackground
;------------------------------------------------------------------------------
_MUI_CaptionBarPaintBackground PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD
    LOCAL hdcMem:DWORD
    LOCAL hBufferBitmap:DWORD
    LOCAL rect:RECT
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD

    ;----------------------------------------------------------
    ; Get Properties & Other Stuff
    ;----------------------------------------------------------
    Invoke MUIGetExtProperty, hWin, @CaptionBarBackColor
    mov BackColor, eax
    Invoke GetClientRect, hWin, Addr rect
    Invoke CopyRect, Addr rect, lpRect

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke MUIGDIDoubleBufferStart, hWin, hdc, Addr hdcMem, Addr rect, Addr hBufferBitmap 

    ;----------------------------------------------------------
    ; Fill Background
    ;----------------------------------------------------------   
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    Invoke SetDCBrushColor, hdcMem, BackColor
    Invoke FillRect, hdcMem, Addr rect, hBrush

    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Finish Double Buffering & Cleanup
    ;----------------------------------------------------------    
    Invoke MUIGDIDoubleBufferFinish, hdcMem, hBufferBitmap, 0, 0, hBrush, 0

    ret
_MUI_CaptionBarPaintBackground ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarPaintImage. Returns in eax ImageWidth if image painted, or 0
;------------------------------------------------------------------------------
_MUI_CaptionBarPaintImage PROC PRIVATE hWin:DWORD, hdcMain:DWORD, hdcDest:DWORD, lpRect:DWORD
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
    LOCAL dwOffsetX:DWORD
    LOCAL dwOffsetY:DWORD
    
    Invoke MUIGetExtProperty, hWin, @CaptionBarBackImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png
    
    .IF ImageType == 0
        mov eax, 0
        ret
    .ENDIF
    
    Invoke MUIGetExtProperty, hWin, @CaptionBarBackImage
    mov hImage, eax    
    
    .IF hImage != 0
        
        Invoke MUIGetExtProperty, hWin, @CaptionBarBackImageOffsetX
        mov dwOffsetX, eax
        Invoke MUIGetExtProperty, hWin, @CaptionBarBackImageOffsetY
        mov dwOffsetY, eax
        Invoke CopyRect, Addr rect, lpRect
        Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight

        mov pt.x, 1
        mov pt.y, 1
        
        .IF dwOffsetX != 0
            mov eax, dwOffsetX
            .IF sdword ptr eax < 0
                mov eax, pt.x
                sub eax, dwOffsetX
            .ELSE
                mov eax, pt.x
                add eax, dwOffsetX
            .ENDIF
            mov pt.x, eax
        .ENDIF
        .IF dwOffsetY != 0
            mov eax, dwOffsetY
            .IF sdword ptr eax < 0
                mov eax, pt.y
                sub eax, dwOffsetY
            .ELSE
                mov eax, pt.y
                add eax, dwOffsetY
            .ENDIF
            mov pt.y, eax
        .ENDIF
        
        mov eax, ImageType
        .IF eax == MUICBIT_BMP ; bitmap
            
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
            
        .ELSEIF eax == MUICBIT_ICO ; icon
            Invoke DrawIconEx, hdcDest, pt.x, pt.y, hImage, 0, 0, 0, 0, DI_NORMAL
        
;        .ELSEIF eax == MUICBIT_PNG ; png
;            IFDEF MUI_USEGDIPLUS
;
;            Invoke GdipCreateFromHDC, hdcDest, Addr pGraphics
;            
;            Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
;            Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer            
;            Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
;            Invoke GdipDrawImageRectI, pGraphics, pBitmap, pt.x, pt.y, ImageWidth, ImageHeight
;            .IF pBitmap != NULL
;                Invoke GdipDisposeImage, pBitmap
;            .ENDIF
;            .IF pGraphicsBuffer != NULL
;                Invoke GdipDeleteGraphics, pGraphicsBuffer
;            .ENDIF
;            .IF pGraphics != NULL
;                Invoke GdipDeleteGraphics, pGraphics
;            .ENDIF
;            ENDIF
        .ELSE
            mov eax, 0
            ret
        .ENDIF
        mov eax, ImageWidth ; success returns imagewidth in eax
        ret

    .ENDIF     
    mov eax, 0
    ret
_MUI_CaptionBarPaintImage ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CreateCaptionBarSysButtons - create all specified system buttons
;------------------------------------------------------------------------------
_MUI_CreateCaptionBarSysButtons PROC PRIVATE hWin:DWORD, hCaptionBarParent:DWORD
    LOCAL wp:WINDOWPLACEMENT
    LOCAL dwClientWidth:DWORD
    LOCAL dwLeftOffset:DWORD
    LOCAL dwTopOffset:DWORD
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

    Invoke GetWindowRect, hWin, Addr rect
    mov dwTopOffset, 0
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnWidth
    mov dwSysButtonWidth, eax
    mov dwLeftOffset, 0;eax ;32d ; start with width of first button
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
    mov dwSysButtonHeight, eax
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnOffsetX
    .IF eax != 0
        add dwLeftOffset, eax
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnOffsetY
    .IF eax != 0
        add dwTopOffset, eax
    .ENDIF
    Invoke MUIGetIntProperty, hWin, @CaptionBarUseIcons
    mov dwUseIcons, eax

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax

    mov eax, rect.right
    sub eax, rect.left
    mov dwClientWidth, eax    
    
    mov eax, dwStyle
    and eax, MUICS_NOCLOSEBUTTON
    .IF eax != MUICS_NOCLOSEBUTTON
        ; create close button
        mov eax, dwClientWidth
        sub eax, dwSysButtonWidth ;dwLeftOffset
        Invoke _MUI_CreateSysButton, hWin, Addr szMUISysCloseButton, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, MUI_SYSBUTTON_CLS_ID ; 32d, 24d, 1  
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
        add eax, MUI_SYSBUTTONS_SPACING
        add dwLeftOffset, eax ;32d
    .ELSE
        mov hSysButtonClose, 0
    .ENDIF    

    mov eax, dwStyle
    and eax, MUICS_NOMAXBUTTON
    .IF eax != MUICS_NOMAXBUTTON
        ; create max and restore buttons
        mov eax, dwClientWidth
        sub eax, dwSysButtonWidth
        sub eax, dwLeftOffset
        mov xpos, eax
        Invoke _MUI_CreateSysButton, hWin, Addr szMUISysMaxButton, xpos, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, MUI_SYSBUTTON_MAX_ID ;32d, 24d, 2
        mov hSysButtonMax, eax

        Invoke _MUI_CreateSysButton, hWin, Addr szMUISysResButton, xpos, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, MUI_SYSBUTTON_RES_ID ;32d, 24d, 3
        mov hSysButtonRes, eax
        mov eax, dwSysButtonWidth
        add eax, MUI_SYSBUTTONS_SPACING
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
        mov eax, dwClientWidth
        sub eax, dwSysButtonWidth
        sub eax, dwLeftOffset
        Invoke _MUI_CreateSysButton, hWin, Addr szMUISysMinButton, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, MUI_SYSBUTTON_MIN_ID ;32d, 24d, 4
        mov hSysButtonMin, eax
        mov eax, dwSysButtonWidth
        add eax, MUI_SYSBUTTONS_SPACING
        add dwLeftOffset, eax ;32d
        
        .IF dwUseIcons == TRUE
            Invoke MUISetIntProperty, hSysButtonMin, @SysButtonUseIcons, TRUE
        .ELSE
            Invoke MUISetIntProperty, hSysButtonMin, @SysButtonUseIcons, FALSE
        .ENDIF        
        
    .ELSE
        mov hSysButtonMin, 0
    .ENDIF
    ;PrintText '_MUI_CreateCaptionBarSysButtons'
    ;PrintDec dwLeftOffset
    Invoke MUISetIntProperty, hWin, @CaptionBarButtonsLeftOffset, dwLeftOffset

    ; save handles to child system buttons in our internal properties of CaptionBar
    Invoke MUISetIntProperty, hWin, @CaptionBar_hSysButtonClose, hSysButtonClose
    Invoke MUISetIntProperty, hWin, @CaptionBar_hSysButtonMax, hSysButtonMax
    Invoke MUISetIntProperty, hWin, @CaptionBar_hSysButtonRes, hSysButtonRes
    Invoke MUISetIntProperty, hWin, @CaptionBar_hSysButtonMin, hSysButtonMin
    ret
_MUI_CreateCaptionBarSysButtons ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarReposition - Reposition window and child system buttons after 
; main window resizes - called via SendMessage, hControl, WM_SIZE, 0, 0
;------------------------------------------------------------------------------
_MUI_CaptionBarReposition PROC PRIVATE hWin:DWORD
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
    LOCAL dwTopOffset:DWORD
    LOCAL dwSysButtonWidth:DWORD
    LOCAL dwSysButtonHeight:DWORD    
    LOCAL hParent:DWORD
    LOCAL rect:RECT
    LOCAL dwStyle:DWORD
    LOCAL bBorder:DWORD

    ;todo, if MUICS_WINNOMUISTYLE applied (ie in radasm dialog editor) then we should just set pos to 0,0, and client width
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax

    Invoke GetParent, hWin
    mov hParent, eax

    mov dwTopOffset, 0
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnWidth
    mov dwSysButtonWidth, eax
    mov dwLeftOffset, 0;eax ;32d
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
    mov dwSysButtonHeight, eax
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnOffsetX
    .IF eax != 0
        .IF sdword ptr eax < 0
            neg eax
        .ENDIF
        add dwLeftOffset, eax
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnOffsetY
    .IF eax != 0
        .IF sdword ptr eax < 0
            neg eax
        .ENDIF    
        add dwTopOffset, eax
    .ENDIF

    Invoke GetClientRect, hWin, Addr rect
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
    sub eax, rect.left
    mov dwClientWidth, eax
    mov eax, rect.bottom
    sub eax, rect.top
    mov dwClientHeight, eax

    mov eax, dwStyle
    and eax, MUICS_NOBORDER
    .IF eax == MUICS_NOBORDER
        mov bBorder, FALSE
    .ELSE
        mov bBorder, TRUE
    .ENDIF


    mov TotalItems, 0
    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonClose
    mov hSysButtonClose, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonMax
    mov hSysButtonMax, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonRes
    mov hSysButtonRes, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonMin
    mov hSysButtonMin, eax
    .IF eax != NULL
        inc TotalItems
    .ENDIF
    Invoke MUIGetIntProperty, hWin, @CaptionBarTotalButtons
    .IF eax != 0
        add TotalItems, eax
    .ENDIF

    Invoke BeginDeferWindowPos, TotalItems
    mov hDefer, eax
    ; have to move this caption bar first, so that child controls can be moved inside of the new width (cant use defer on this window)
    .IF wp.showCmd == SW_SHOWNORMAL
        .IF bBorder == TRUE
            sub dwClientWidth, 2
            mov eax, 1
        .ELSE
            mov eax, 0
        .ENDIF
        Invoke SetWindowPos, hWin, NULL, eax, eax, dwClientWidth, dwCaptionHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING
    .ELSE
        .IF bBorder == TRUE
            sub dwClientWidth, 2
            mov eax, 1
        .ELSE
            mov eax, 0
        .ENDIF    
        Invoke SetWindowPos, hWin, NULL, eax, eax, dwClientWidth, dwCaptionHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING
    .ENDIF 

    .IF hSysButtonClose != NULL
        mov eax, dwClientWidth
        sub eax, dwSysButtonWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonClose, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER  or SWP_NOACTIVATE ;or SWP_NOSIZE
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonClose, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE
            mov hDefer, eax    
        .ENDIF
        mov eax, dwSysButtonWidth
        add eax, MUI_SYSBUTTONS_SPACING
        add dwLeftOffset, eax ;32d
    .ENDIF

    .IF hSysButtonMax != NULL && hSysButtonRes != NULL
        mov eax, dwClientWidth
        sub eax, dwSysButtonWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonMax, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING    
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonMax, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER  or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING
            mov hDefer, eax 
        .ENDIF

        mov eax, dwClientWidth
        sub eax, dwSysButtonWidth
        sub eax, dwLeftOffset        
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonRes, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING    
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonRes, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING
            mov hDefer, eax  
        .ENDIF
        mov eax, dwSysButtonWidth
        add eax, MUI_SYSBUTTONS_SPACING
        add dwLeftOffset, eax ;32d
    .ENDIF

    .IF hSysButtonMin != NULL
        mov eax, dwClientWidth
        sub eax, dwSysButtonWidth
        sub eax, dwLeftOffset
        .IF hDefer == NULL
            Invoke SetWindowPos, hSysButtonMin, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING    
        .ELSE
            Invoke DeferWindowPos, hDefer, hSysButtonMin, NULL, eax, dwTopOffset, dwSysButtonWidth, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING
            mov hDefer, eax  
        .ENDIF
        mov eax, dwSysButtonWidth
        add eax, MUI_SYSBUTTONS_SPACING
        add dwLeftOffset, eax ;32d        
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @CaptionBarTotalButtons
    .IF eax != 0
        Invoke _MUI_CapButtonsReposition, hWin, hDefer, dwTopOffset, dwLeftOffset, dwClientWidth
    .ELSE
        ;PrintText '_MUI_CaptionBarReposition'
        ;PrintDec dwLeftOffset
        Invoke MUISetIntProperty, hWin, @CaptionBarButtonsLeftOffset, dwLeftOffset
    .ENDIF

    .IF hDefer != NULL
        Invoke EndDeferWindowPos, hDefer
    .ENDIF    

    Invoke InvalidateRect, hWin, NULL, TRUE

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


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SysButtonSetPropertyEx - Sets the system button properties from the 
; message MUIM_SETPROPERTY set to the parent CaptionBar control 
;------------------------------------------------------------------------------
_MUI_SysButtonSetPropertyEx PROC PRIVATE hWin:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
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

    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonClose
    mov hSysButtonClose, eax
    .IF eax != NULL
        mov eax, dwProperty
        .IF eax == @CaptionBarTextColor
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBackColor
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnTxtRollColor || eax == @CaptionBarBtnBckRollColor || eax == @CaptionBarBtnBorderRollColor
            Invoke GetWindowLong, hWin, GWL_STYLE
            mov dwStyle, eax        
            ;Invoke _MUIGetIntProperty, hCaptionBar, @CaptionBarStyle
            and eax, MUICS_REDCLOSEBUTTON
            .IF eax == MUICS_REDCLOSEBUTTON
                Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextRollColor, MUI_RGBCOLOR(255,255,255)
                Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackRollColor, MUI_RGBCOLOR(166,26,32)
                Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBorderRollColor, MUI_RGBCOLOR(166,26,32)
            .ELSE
                mov eax, dwProperty
                .IF eax == @CaptionBarBtnTxtRollColor
                    Invoke MUISetExtProperty, hSysButtonClose, @SysButtonTextRollColor, dwPropertyValue
                .ELSEIF eax == @CaptionBarBtnBckRollColor
                    Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBackRollColor, dwPropertyValue
                .ELSEIF eax == @CaptionBarBtnBorderRollColor
                    Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBorderRollColor, dwPropertyValue
                .ENDIF
            .ENDIF
        .ELSEIF eax == @CaptionBarBtnIcoClose
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIco, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnIcoCloseAlt
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonIcoAlt, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnWidth
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonClose, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonClose, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        
        .ELSEIF eax == @CaptionBarBtnBorderColor
            Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBorderColor, dwPropertyValue
        ;.ELSEIF eax == @CaptionBarBtnBorderRollColor
        ;    Invoke MUISetExtProperty, hSysButtonClose, @SysButtonBorderRollColor, dwPropertyValue
        .ENDIF
        Invoke InvalidateRect, hSysButtonClose, NULL, TRUE
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonMax
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
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonMax, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonMax, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE         
        .ELSEIF eax == @CaptionBarBtnBorderColor
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonBorderColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBorderRollColor
            Invoke MUISetExtProperty, hSysButtonMax, @SysButtonBorderRollColor, dwPropertyValue        
        .ENDIF
        Invoke InvalidateRect, hSysButtonMax, NULL, TRUE
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonRes
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
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonRes, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonRes, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE          
        .ELSEIF eax == @CaptionBarBtnBorderColor
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonBorderColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBorderRollColor
            Invoke MUISetExtProperty, hSysButtonRes, @SysButtonBorderRollColor, dwPropertyValue            
        .ENDIF
        Invoke InvalidateRect, hSysButtonRes, NULL, TRUE
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @CaptionBar_hSysButtonMin
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
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
            mov dwSysButtonHeight, eax
            Invoke SetWindowPos, hSysButtonMin, NULL, 0, 0, dwPropertyValue, dwSysButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE
        .ELSEIF eax == @CaptionBarBtnHeight
            Invoke MUIGetExtProperty, hWin, @CaptionBarBtnWidth
            mov dwSysButtonWidth, eax
            Invoke SetWindowPos, hSysButtonMin, NULL, 0, 0, dwSysButtonWidth, dwPropertyValue, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE        
        .ELSEIF eax == @CaptionBarBtnBorderColor
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonBorderColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBorderRollColor
            Invoke MUISetExtProperty, hSysButtonMin, @SysButtonBorderRollColor, dwPropertyValue           
        .ENDIF
        Invoke InvalidateRect, hSysButtonMin, NULL, TRUE
    .ENDIF
    
    ;todo set custom button props
    
    ret
_MUI_SysButtonSetPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CreateSysButton - create system button (min, max, restore or close)
;------------------------------------------------------------------------------
_MUI_CreateSysButton PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hSysButton:DWORD

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
    mov hSysButton, eax
    .IF eax != 0
        Invoke MUISetExtProperty, hSysButton, @SysButtonResourceID, dwResourceID
    .ENDIF
    mov eax, hSysButton
    ret

_MUI_CreateSysButton ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SysButtonWndProc - Main processing for system buttons: min/max/res/close 
;------------------------------------------------------------------------------
_MUI_SysButtonWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
     
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


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SysButtonInit - default intial values for properties for SysButton
;------------------------------------------------------------------------------
_MUI_SysButtonInit PROC PRIVATE hSysButton:DWORD
    LOCAL hParent:DWORD

    Invoke GetParent, hSysButton
    mov hParent, eax

    Invoke MUIGetExtProperty, hParent, @CaptionBarTextColor
    Invoke MUISetExtProperty, hSysButton, @SysButtonTextColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnTxtRollColor
    Invoke MUISetExtProperty, hSysButton, @SysButtonTextRollColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBackColor
    Invoke MUISetExtProperty, hSysButton, @SysButtonBackColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnBckRollColor
    Invoke MUISetExtProperty, hSysButton, @SysButtonBackRollColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnBorderColor
    Invoke MUISetExtProperty, hSysButton, @SysButtonBorderColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnBorderRollColor
    Invoke MUISetExtProperty, hSysButton, @SysButtonBorderRollColor, eax

;    Invoke MUISetExtProperty, hSysButton, @SysButtonTextColor, MUI_RGBCOLOR(255,255,255);MUI_RGBCOLOR(228,228,228)
;    Invoke MUISetExtProperty, hSysButton, @SysButtonTextRollColor, MUI_RGBCOLOR(61,61,61) ;MUI_RGBCOLOR(0,0,0)
;    Invoke MUISetExtProperty, hSysButton, @SysButtonBackColor, MUI_RGBCOLOR(27,161,226) ;MUI_RGBCOLOR(21,133,181)
;    Invoke MUISetExtProperty, hSysButton, @SysButtonBackRollColor, MUI_RGBCOLOR(87,193,244) ;MUI_RGBCOLOR(138,194,218)
;    Invoke MUISetExtProperty, hSysButton, @SysButtonBorderColor, 0
;    Invoke MUISetExtProperty, hSysButton, @SysButtonBorderRollColor, 0  

    .IF hMUISysButtonFont == 0
        Invoke CreateFont, -10, 0, 0, 0, FW_THIN, FALSE, FALSE, FALSE, SYMBOL_CHARSET, 0, 0, 0, 0, Addr szMUISysButtonFont
        mov hMUISysButtonFont, eax
    .ENDIF
    
    ; Set internal property for font for system buttons 
    Invoke MUISetIntProperty, hSysButton, @SysButtonFont, hMUISysButtonFont

    ret

_MUI_SysButtonInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SysButtonCleanup - cleanup some stuff on control being destroyed
;------------------------------------------------------------------------------
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


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SysButtonPaint - System button painting
;------------------------------------------------------------------------------
_MUI_SysButtonPaint PROC PRIVATE USES EBX hSysButton:DWORD
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
    LOCAL BorderColor:DWORD
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

    Invoke BeginPaint, hSysButton, Addr ps
    mov hdc, eax
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hSysButton, Addr rect
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax

    ;----------------------------------------------------------
    ; Get properties
    ;----------------------------------------------------------
    Invoke MUIGetIntProperty, hSysButton, @SysButtonMouseOver
    mov MouseOver, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hSysButton, @SysButtonTextColor        ; normal text color
    .ELSE
        Invoke MUIGetExtProperty, hSysButton, @SysButtonTextRollColor    ; mouseover text color
    .ENDIF
    mov TextColor, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hSysButton, @SysButtonBackColor        ; normal back color
    .ELSE
        Invoke MUIGetExtProperty, hSysButton, @SysButtonBackRollColor    ; mouseover back color
    .ENDIF
    mov BackColor, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hSysButton, @SysButtonBorderColor      ; normal border color
    .ELSE
        Invoke MUIGetExtProperty, hSysButton, @SysButtonBorderRollColor  ; mouseover border color
    .ENDIF
    mov BorderColor, eax
    
    Invoke MUIGetIntProperty, hSysButton, @SysButtonFont             ; Marlett font
    mov hFont, eax
    
    Invoke MUIGetIntProperty, hSysButton, @SysButtonUseIcons
    mov UseIcons, eax
    .IF UseIcons == TRUE
        .IF MouseOver == 0
            Invoke MUIGetExtProperty, hSysButton, @SysButtonIco
        .ELSE
            Invoke MUIGetExtProperty, hSysButton, @SysButtonIcoAlt
            .IF eax == NULL ; try to get ordinary icon handle
                Invoke MUIGetExtProperty, hSysButton, @SysButtonIco
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
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, BackColor
    Invoke FillRect, hdcMem, Addr rect, hBrush

    ;----------------------------------------------------------
    ; Draw border
    ;----------------------------------------------------------   
   .IF BorderColor != 0
        .IF hOldBrush != 0
            Invoke SelectObject, hdcMem, hOldBrush
            Invoke DeleteObject, hOldBrush
        .ENDIF        
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdcMem, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdcMem, BorderColor
        Invoke FrameRect, hdcMem, Addr rect, hBrush
    .ENDIF

    .IF UseIcons == FALSE || hIcon == NULL
        ;----------------------------------------------------------
        ; Draw Text
        ;----------------------------------------------------------
        Invoke SelectObject, hdcMem, hFont
        mov hOldFont, eax
        ;PrintDec hFont
        ;PrintDec hOldFont
        Invoke GetWindowText, hSysButton, Addr szText, sizeof szText
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
    .IF hOldBrush != 0
        Invoke SelectObject, hdcMem, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    .IF hOldFont != 0
        Invoke SelectObject, hdcMem, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem

    Invoke EndPaint, hSysButton, Addr ps
    ret
_MUI_SysButtonPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Applies the ModernUI style to a dialog to make it a captionless, borderless 
; form. User can manually change a form in a resource editor to have the 
; following style flags: WS_POPUP or WS_VISIBLE and optionally with DS_CENTER, 
; DS_CENTERMOUSE, WS_CLIPCHILDREN, WS_CLIPSIBLINGS, WS_MINIMIZE, WS_MAXIMIZE
;------------------------------------------------------------------------------
_MUI_ApplyMUIStyleToDialog PROC PUBLIC hWin:DWORD, dwDropShadow:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwNewStyle:DWORD
    LOCAL dwBasicOldStyle:DWORD
    LOCAL dwClassStyle:DWORD

    ;PrintText '_MUI_ApplyMUIStyleToDialog'
    mov dwNewStyle, WS_POPUP
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    ;and eax, 0FFFF0000h ; remove any custom styles we set for captionbar
    mov dwBasicOldStyle, eax
    
    mov eax, dwStyle
    and eax, DS_CENTER
    .IF eax == DS_CENTER
        or dwNewStyle, DS_CENTER
    .ENDIF
    
    mov eax, dwStyle
    and eax, DS_CENTERMOUSE
    .IF eax == DS_CENTERMOUSE
        or dwNewStyle, DS_CENTERMOUSE
    .ENDIF
    
;    mov eax, dwStyle
;    and eax, DS_SETFONT
;    .IF eax == DS_SETFONT
;        or dwNewStyle, DS_SETFONT
;    .ENDIF    
;    
;    mov eax, dwStyle
;    and eax, DS_3DLOOK
;    .IF eax == DS_3DLOOK
;        or dwNewStyle, DS_3DLOOK
;    .ENDIF      
    
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
    
    mov eax, dwStyle
    and eax, WS_CLIPCHILDREN
    .IF eax == WS_CLIPCHILDREN
        or dwNewStyle, WS_CLIPCHILDREN
    .ENDIF
    
    ; If user has already set dialog/window to the right style, then no need to set it again
    mov eax, dwNewStyle
    ;and eax, 0FFFF0000h ; remove any custom styles we set for captionbar
    ;PrintDec dwNewStyle
    ;PrintDec dwBasicOldStyle
    .IF eax == dwBasicOldStyle ; no major changes, so dont set new style
    .ELSE
        ;PrintText 'Setting New Style'
        Invoke SetWindowLong, hWin, GWL_STYLE, dwNewStyle
        ; Set WS_EX_COMPOSITED as well?
        Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED or SWP_NOSENDCHANGING
    .ENDIF
    
    ; Set dropshadow on or off on our dialog
    Invoke GetClassLong, hWin, GCL_STYLE
    mov dwClassStyle, eax
    
    .IF dwDropShadow == TRUE
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax != CS_DROPSHADOW
            or dwClassStyle, CS_DROPSHADOW
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
            ;PrintText 'Setting DropShadow Class Style'
        .ENDIF
    .ELSE    
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax == CS_DROPSHADOW
            and dwClassStyle,(-1 xor CS_DROPSHADOW)
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
            ;PrintText 'Removing DropShadow Class Style'
        .ENDIF
    .ENDIF

    ; remove any menu that might have been assigned via class registration - for modern ui look
    Invoke GetMenu, hWin
    .IF eax != NULL
        ;PrintText 'Removing Menu'
        Invoke SetMenu, hWin, NULL
    .ENDIF
    ret
_MUI_ApplyMUIStyleToDialog ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICaptionBarLoadIcons
;------------------------------------------------------------------------------
MUICaptionBarLoadIcons PROC PUBLIC hControl:DWORD, idResMin:DWORD, idResMinAlt:DWORD, idResMax:DWORD, idResMaxAlt:DWORD, idResRes:DWORD, idResResAlt:DWORD, idResClose:DWORD, idResCloseAlt:DWORD 
    LOCAL hinstance:DWORD
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    
    Invoke MUIGetExtProperty, hControl, @CaptionBarDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax
    
    .IF idResMin != NULL || idResMinAlt != NULL
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonMin
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
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonMax
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
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonRes
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
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonClose
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


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICaptionBarLoadIcons - version for loading from DLL's that have the icon 
; resources.
;------------------------------------------------------------------------------
MUICaptionBarLoadIconsDll PROC PUBLIC hControl:DWORD, hInst:DWORD, idResMin:DWORD, idResMinAlt:DWORD, idResMax:DWORD, idResMaxAlt:DWORD, idResRes:DWORD, idResResAlt:DWORD, idResClose:DWORD, idResCloseAlt:DWORD 
    LOCAL hSysButtonClose:DWORD
    LOCAL hSysButtonMax:DWORD
    LOCAL hSysButtonRes:DWORD
    LOCAL hSysButtonMin:DWORD
    
    .IF idResMin != NULL || idResMinAlt != NULL
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonMin
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
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonMax
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
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonRes
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
        Invoke MUIGetIntProperty, hControl, @CaptionBar_hSysButtonClose
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


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarBackLoadBitmap - if succesful, loads specified bitmap resource
; into the specified external property and returns TRUE in eax, otherwise FALSE
;------------------------------------------------------------------------------
_MUI_CaptionBarBackLoadBitmap PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResBitmap:DWORD
    LOCAL hinstance:DWORD

    .IF idResBitmap == NULL
        mov eax, FALSE
        ret
    .ENDIF

    Invoke MUIGetExtProperty, hWin, @CaptionBarDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    Invoke MUIGetExtProperty, hWin, dwProperty
    .IF eax != 0 ; image handle already in use, delete object?
        Invoke DeleteObject, eax
    .ENDIF

    Invoke LoadBitmap, hinstance, idResBitmap
    Invoke MUISetExtProperty, hWin, dwProperty, eax
    mov eax, TRUE

    ret
_MUI_CaptionBarBackLoadBitmap ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CaptionBarBackLoadIcon - if succesful, loads specified icon resource 
; into the specified external property and returns TRUE in eax, otherwise FALSE
;------------------------------------------------------------------------------
_MUI_CaptionBarBackLoadIcon PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResIcon:DWORD
    LOCAL hinstance:DWORD

    .IF idResIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF
    Invoke MUIGetExtProperty, hWin, @CaptionBarDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    Invoke MUIGetExtProperty, hWin, dwProperty
    .IF eax != 0 ; image icon handle already in use, delete object?
        Invoke DeleteObject, eax
    .ENDIF

    Invoke LoadImage, hinstance, idResIcon, IMAGE_ICON, 0, 0, 0 ;LR_SHARED

    Invoke MUISetExtProperty, hWin, dwProperty, eax

    mov eax, TRUE
    ret
_MUI_CaptionBarBackLoadIcon ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICaptionBarLoadBackImage - Loads images from resource ids and stores the 
; handles in the appropriate property.
;------------------------------------------------------------------------------
MUICaptionBarLoadBackImage PROC PUBLIC hControl:DWORD, dwImageType:DWORD, dwResIDImage:DWORD

    .IF dwImageType == 0
        ret
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @CaptionBarBackImageType, dwImageType

    .IF dwResIDImage != 0
        mov eax, dwImageType
        .IF eax == MUICBIT_BMP ; bitmap
            Invoke _MUI_CaptionBarBackLoadBitmap, hControl, @CaptionBarBackImage, dwResIDImage
        .ELSEIF eax == MUICBIT_ICO ; icon
            Invoke _MUI_CaptionBarBackLoadIcon, hControl, @CaptionBarBackImage, dwResIDImage
        ;.ELSEIF eax == MUICBIT_PNG ; png
        ;    IFDEF MUI_USEGDIPLUS
        ;    Invoke _MUI_ButtonLoadPng, hControl, @ButtonImage, dwResIDImage
        ;    ENDIF
        .ENDIF
    .ENDIF

    Invoke InvalidateRect, hControl, NULL, TRUE

    ret
MUICaptionBarLoadBackImage ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CreateCapButton - create a custom capbutton
;------------------------------------------------------------------------------
_MUI_CreateCapButton PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hCapButton:DWORD

    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUICapButtonClass,addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUICapButtonClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_CapButtonWndProc
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
    Invoke CreateWindowEx, NULL, Addr szMUICapButtonClass, lpszText, WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hCapButton, eax
    .IF eax != 0
        Invoke MUISetExtProperty, hCapButton, @CapButtonResourceID, dwResourceID
        
    .ENDIF
    ;PrintDec hCapButton
    mov eax, hCapButton
    ret

_MUI_CreateCapButton ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CapButtonWndProc - Main processing window for custom capbuttons 
;------------------------------------------------------------------------------
_MUI_CapButtonWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    
    mov eax,uMsg
    .IF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_CAPBUTTON_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_CAPBUTTON_PROPERTIES ; external properties
        Invoke _MUI_CapButtonInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_CapButtonCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4   
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_CapButtonPaint, hWin
        mov eax, 0
        ret
   
    .ELSEIF eax == WM_LBUTTONUP
        Invoke GetDlgCtrlID, hWin
        mov ebx,eax
        Invoke GetParent, hWin
        Invoke PostMessage, eax, WM_COMMAND, ebx, hWin
   
   .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUISetIntProperty, hWin, @CapButtonMouseOver, TRUE
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
        Invoke MUISetIntProperty, hWin, @CapButtonMouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @CapButtonMouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax
        
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_CapButtonWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CapButtonInit - default intial values for properties for CapButton
;------------------------------------------------------------------------------
_MUI_CapButtonInit PROC PRIVATE hCapButton:DWORD
    LOCAL hParent:DWORD
    
    Invoke GetParent, hCapButton
    mov hParent, eax
    
    Invoke MUIGetExtProperty, hParent, @CaptionBarTextColor
    Invoke MUISetExtProperty, hCapButton, @CapButtonTextColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnTxtRollColor
    Invoke MUISetExtProperty, hCapButton, @CapButtonTextRollColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBackColor
    Invoke MUISetExtProperty, hCapButton, @CapButtonBackColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnBckRollColor
    Invoke MUISetExtProperty, hCapButton, @CapButtonBackRollColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnBorderColor
    Invoke MUISetExtProperty, hCapButton, @CapButtonBorderColor, eax
    Invoke MUIGetExtProperty, hParent, @CaptionBarBtnBorderRollColor
    Invoke MUISetExtProperty, hCapButton, @CapButtonBorderRollColor, eax

    .IF hMUICapButtonFont == 0
        Invoke CreateFont, -10, 0, 0, 0, FW_THIN, FALSE, FALSE, FALSE, SYMBOL_CHARSET, 0, 0, 0, 0, Addr szMUISysButtonFont
        mov hMUICapButtonFont, eax
    .ENDIF
    
    ; Set internal property for font for system buttons 
    Invoke MUISetIntProperty, hCapButton, @CapButtonFont, hMUICapButtonFont

    ret

_MUI_CapButtonInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CapButtonCleanup - cleanup some stuff on control being destroyed
;------------------------------------------------------------------------------
_MUI_CapButtonCleanup PROC PRIVATE hCapButton:DWORD
    
    Invoke GetParent, hCapButton
    Invoke GetWindowLong, eax, GWL_STYLE
    and eax, MUICS_KEEPICONS
    .IF eax == MUICS_KEEPICONS
        ret
    .ENDIF
  
    Invoke MUIGetExtProperty, hCapButton, @CapButtonIco
    .IF eax != NULL
        Invoke DestroyIcon, eax
    .ENDIF
     Invoke MUIGetExtProperty, hCapButton, @CapButtonIcoAlt
    .IF eax != NULL
        Invoke DestroyIcon, eax
    .ENDIF

    ret

_MUI_CapButtonCleanup ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CapButtonPaint - Custom captionbutton painting
;------------------------------------------------------------------------------
_MUI_CapButtonPaint PROC PRIVATE USES EBX hCapButton:DWORD
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
    LOCAL BorderColor:DWORD
    LOCAL UseIcons:DWORD
    LOCAL hIcon:DWORD
    LOCAL nIcoWidth:DWORD
    LOCAL nIcoHeight:DWORD
    LOCAL nTextLength:DWORD
    LOCAL szText[MUI_CAPBUTTON_TEXT_MAX]:BYTE

    ; null some vars
    mov hFont, 0
    mov hOldFont, 0
    mov hBrush, 0
    mov hOldBrush, 0
    mov hIcon, 0
    mov nIcoWidth, 0
    mov nIcoHeight, 0

    Invoke BeginPaint, hCapButton, Addr ps
    mov hdc, eax
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hCapButton, Addr rect
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax

    ;----------------------------------------------------------
    ; Get properties
    ;----------------------------------------------------------
    Invoke MUIGetIntProperty, hCapButton, @CapButtonMouseOver
    mov MouseOver, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hCapButton, @CapButtonTextColor        ; normal text color
    .ELSE
        Invoke MUIGetExtProperty, hCapButton, @CapButtonTextRollColor    ; mouseover text color
    .ENDIF
    mov TextColor, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hCapButton, @CapButtonBackColor        ; normal back color
    .ELSE
        Invoke MUIGetExtProperty, hCapButton, @CapButtonBackRollColor    ; mouseover back color
    .ENDIF
    mov BackColor, eax
    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hCapButton, @CapButtonBorderColor      ; normal border color
    .ELSE
        Invoke MUIGetExtProperty, hCapButton, @CapButtonBorderRollColor  ; mouseover border color
    .ENDIF
    mov BorderColor, eax
    
    Invoke MUIGetIntProperty, hCapButton, @CapButtonFont
    mov hFont, eax

    .IF MouseOver == 0
        Invoke MUIGetExtProperty, hCapButton, @CapButtonIco
    .ELSE
        Invoke MUIGetExtProperty, hCapButton, @CapButtonIcoAlt
        .IF eax == NULL ; try to get ordinary icon handle
            Invoke MUIGetExtProperty, hCapButton, @CapButtonIco
        .ENDIF
    .ENDIF
    mov hIcon, eax

    ;----------------------------------------------------------
    ; Fill background
    ;----------------------------------------------------------    
    Invoke SetBkMode, hdcMem, OPAQUE
    Invoke SetBkColor, hdcMem, BackColor
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, BackColor
    Invoke FillRect, hdcMem, Addr rect, hBrush

    ;----------------------------------------------------------
    ; Draw border
    ;----------------------------------------------------------   
   .IF BorderColor != 0
        .IF hOldBrush != 0
            Invoke SelectObject, hdcMem, hOldBrush
            Invoke DeleteObject, hOldBrush
        .ENDIF        
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdcMem, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdcMem, BorderColor
        Invoke FrameRect, hdcMem, Addr rect, hBrush
    .ENDIF

    Invoke GetWindowText, hCapButton, Addr szText, sizeof szText
    mov nTextLength, eax
    
    ;PrintDec nTextLength
    
    ;----------------------------------------------------------
    ; Draw Icon & Text
    ;----------------------------------------------------------
    .IF hIcon == NULL && nTextLength == 0 ; neither

    .ELSEIF hIcon != NULL && nTextLength != 0 ; both

        Invoke MUIGetImageSize, hIcon, MUIIT_ICO, Addr nIcoWidth, Addr nIcoHeight
        mov eax, MUI_CAPBUTTON_TEXT_PADDING
        mov pt.x, eax
        mov eax, rect.bottom
        shr eax, 1
        mov ebx, nIcoHeight
        shr ebx, 1
        sub eax, ebx
        mov pt.y, eax
        Invoke DrawIconEx, hdcMem, pt.x, pt.y, hIcon, 0, 0, NULL, NULL, DI_NORMAL
    
        Invoke SelectObject, hdcMem, hFont
        mov hOldFont, eax
        Invoke SetTextColor, hdcMem, TextColor
        mov eax, nIcoWidth
        add rect.left, eax
        add rect.left, MUI_CAPBUTTON_TEXT_PADDING
        add rect.left, MUI_CAPBUTTON_IMAGETEXT_PADDING
        Invoke DrawText, hdcMem, Addr szText, -1, Addr rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
        mov eax, nIcoWidth
        sub rect.left, eax
        sub rect.left, MUI_CAPBUTTON_TEXT_PADDING
        sub rect.left, MUI_CAPBUTTON_IMAGETEXT_PADDING

    .ELSEIF hIcon == NULL && nTextLength != 0 ; only text

        Invoke SelectObject, hdcMem, hFont
        mov hOldFont, eax
        Invoke SetTextColor, hdcMem, TextColor
        add rect.left, MUI_CAPBUTTON_TEXT_PADDING
        Invoke DrawText, hdcMem, Addr szText, -1, Addr rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
        sub rect.left, MUI_CAPBUTTON_TEXT_PADDING

    .ELSEIF hIcon != NULL && nTextLength == 0 ; only icon

        Invoke MUIGetImageSize, hIcon, MUIIT_ICO, Addr nIcoWidth, Addr nIcoHeight
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
    .IF hOldBrush != 0
        Invoke SelectObject, hdcMem, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    .IF hOldFont != 0
        Invoke SelectObject, hdcMem, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem

    Invoke EndPaint, hCapButton, Addr ps
    ret
_MUI_CapButtonPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Reposition the capbuttons if there is any
;------------------------------------------------------------------------------
_MUI_CapButtonsReposition PROC USES EBX hWin:DWORD, hDefer:DWORD, dwTopOffset:DWORD, dwLeftOffset:DWORD, dwClientWidth:DWORD
    LOCAL TotalButtons:DWORD
    LOCAL nCurrentButton:DWORD
    LOCAL hCapButton:DWORD
    LOCAL ptrButtonArray:DWORD
    LOCAL ptrButtonEntry:DWORD
    LOCAL dwTotalLeftOffset:DWORD
    LOCAL dwButtonWidth:DWORD
    LOCAL dwButtonHeight:DWORD
    LOCAL xpos:DWORD

    Invoke MUIGetIntProperty, hWin, @CaptionBarTotalButtons
    .IF eax == 0
        ret
    .ENDIF
    mov TotalButtons, eax
    
    Invoke MUIGetIntProperty, hWin, @CaptionBarButtonArray
    .IF eax == 0
        ret
    .ENDIF
    mov ptrButtonArray, eax
    mov ptrButtonEntry, eax

    Invoke MUIGetExtProperty, hWin, @CaptionBarBtnHeight
    mov dwButtonHeight, eax    
    
    mov eax, dwLeftOffset
    add eax, MUI_SYSCAPBUTTON_SPACING
    mov xpos, eax

    mov eax, 0
    mov nCurrentButton, 0
    .WHILE eax < TotalButtons
        mov ebx, ptrButtonEntry
        mov eax, [ebx]
        mov hCapButton, eax

        .IF hCapButton != NULL
            
            Invoke MUIGetIntProperty, hCapButton, @CapButtonWidth
            .IF eax == 0 ; use default if 0, != 0 is for text and icon buttons
                Invoke MUIGetExtProperty, hWin, @CaptionBarBtnWidth
            .ENDIF
            mov dwButtonWidth, eax
        
            mov eax, dwClientWidth
            sub eax, xpos
            sub eax, dwButtonWidth
            
            .IF hDefer == NULL
                Invoke SetWindowPos, hCapButton, NULL, eax, dwTopOffset, dwButtonWidth, dwButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING ;or SWP_NOCOPYBITS
            .ELSE
                Invoke DeferWindowPos, hDefer, hCapButton, NULL, eax, dwTopOffset, dwButtonWidth, dwButtonHeight, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE ;or SWP_NOSIZE ;or SWP_NOSENDCHANGING
                mov hDefer, eax    
            .ENDIF
            mov eax, dwButtonWidth
            add eax, MUI_CAPBUTTONS_SPACING
            add xpos, eax ;32d
        .ENDIF            

        add ptrButtonEntry, SIZEOF DWORD
        inc nCurrentButton
        mov eax, nCurrentButton
    .ENDW

    Invoke MUISetIntProperty, hWin, @CaptionBarButtonsLeftOffset, xpos
    
    ret

_MUI_CapButtonsReposition ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_CapButtonSetPropertyEx - set capbtn props when captionbar props set
;------------------------------------------------------------------------------
_MUI_CapButtonSetPropertyEx PROC PRIVATE USES EBX hWin:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL TotalButtons:DWORD
    LOCAL nCurrentButton:DWORD
    LOCAL hCapButton:DWORD
    LOCAL ptrButtonArray:DWORD
    LOCAL ptrButtonEntry:DWORD

    .IF dwProperty == @CaptionBarTextFont
        ret
    .ENDIF
    
    mov eax, dwProperty ; only interested in certain properties to forward on
    .IF eax != @CaptionBarTextColor || eax != @CaptionBarBtnTxtRollColor || eax != @CaptionBarBackColor || eax != @CaptionBarBtnBckRollColor || eax != @CaptionBarBtnBorderColor || eax != @CaptionBarBtnBorderRollColor
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hWin, @CaptionBarTotalButtons
    .IF eax == 0
        ret
    .ENDIF
    mov TotalButtons, eax    
    
    Invoke MUIGetIntProperty, hWin, @CaptionBarButtonArray
    .IF eax == 0
        ret
    .ENDIF
    mov ptrButtonArray, eax
    mov ptrButtonEntry, eax
    
    mov eax, 0
    mov nCurrentButton, 0
    .WHILE eax < TotalButtons    
        mov ebx, ptrButtonEntry
        mov eax, [ebx]
        mov hCapButton, eax

        mov eax, dwProperty
        .IF eax == @CaptionBarTextColor
            Invoke MUISetExtProperty, hCapButton, @CapButtonTextColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnTxtRollColor
            Invoke MUISetExtProperty, hCapButton, @CapButtonTextRollColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBackColor
            Invoke MUISetExtProperty, hCapButton, @CapButtonBackColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBckRollColor
            Invoke MUISetExtProperty, hCapButton, @CapButtonBackRollColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBorderColor
            Invoke MUISetExtProperty, hCapButton, @CapButtonBorderColor, dwPropertyValue
        .ELSEIF eax == @CaptionBarBtnBorderRollColor
            Invoke MUISetExtProperty, hCapButton, @CapButtonBorderRollColor, dwPropertyValue
        .ENDIF
        
        add ptrButtonEntry, SIZEOF DWORD
        inc nCurrentButton
        mov eax, nCurrentButton
    .ENDW
    ret
_MUI_CapButtonSetPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUICaptionBarAddButton - add custom button to caption bar
;------------------------------------------------------------------------------
MUICaptionBarAddButton PROC PUBLIC USES EBX hControl:DWORD, lpszButtonText:DWORD, dwResourceID:DWORD, dwResIDImage:DWORD, dwResIDImageAlt:DWORD
    LOCAL hinstance:DWORD
    LOCAL hCustomButton:DWORD
    LOCAL dwClientWidth:DWORD
    LOCAL dwButtonWidth:DWORD
    LOCAL dwButtonHeight:DWORD
    LOCAL dwNoButtons:DWORD
    LOCAL hParent:DWORD
    LOCAL hImage:DWORD
    LOCAL hImageAlt:DWORD
    LOCAL dwTopOffset:DWORD
    LOCAL dwLeftOffset:DWORD
    LOCAL xpos:DWORD
    LOCAL hdc:DWORD
    LOCAL nLenButtonText:DWORD
    LOCAL nIcoWidth:DWORD
    LOCAL hOldFont:DWORD
    LOCAL ptrButtonArray:DWORD
    LOCAL sz:POINT
    LOCAL rect:RECT

    
    .IF (dwResIDImage == 0 && dwResIDImageAlt == 0) || dwResourceID == NULL || hControl == NULL
        mov eax, NULL
        ret
    .ENDIF
    

    Invoke MUIGetExtProperty, hControl, @CaptionBarDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax
    .IF dwResIDImage != NULL
        Invoke LoadImage, hinstance, dwResIDImage, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
    .ELSE
        mov eax, 0
    .ENDIF
    mov hImage, eax
    .IF dwResIDImageAlt != NULL
        Invoke LoadImage, hinstance, dwResIDImageAlt, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
    .ELSE
        .IF hImage != NULL
            mov eax, hImage
        .ELSE
            mov eax, 0
        .ENDIF
    .ENDIF
    mov hImageAlt, eax

    Invoke GetParent, hControl
    mov hParent, eax

    Invoke GetWindowRect, hParent, Addr rect
    mov eax, rect.right
    sub eax, rect.left
    mov dwClientWidth, eax

    ; calc left offset etc
    mov dwTopOffset, 0
    Invoke MUIGetIntProperty, hControl, @CaptionBarButtonsLeftOffset
    add eax, MUI_SYSCAPBUTTON_SPACING
    mov dwLeftOffset, eax

    Invoke MUIGetExtProperty, hControl, @CaptionBarBtnWidth
    mov dwButtonWidth, eax
    Invoke MUIGetExtProperty, hControl, @CaptionBarBtnHeight
    mov dwButtonHeight, eax
    Invoke MUIGetExtProperty, hControl, @CaptionBarBtnOffsetY
    .IF eax != 0
        .IF sdword ptr eax < 0
            neg eax
        .ENDIF    
        add dwTopOffset, eax
    .ENDIF

    
    ; calc width based on text content if text available
    .IF lpszButtonText != NULL 
    
        .IF hMUICapButtonFont == 0
            Invoke CreateFont, -10, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, 0, 0, 0, 0, 0, Addr szMUICapButtonFont
            mov hMUICapButtonFont, eax
        .ENDIF    
    
        ;Invoke szLen, lpszButtonText
        Invoke lstrlen, lpszButtonText
        mov nLenButtonText, eax
        Invoke GetDC, hControl
        mov hdc, eax
        Invoke SelectObject, hdc, hMUICapButtonFont
        mov hOldFont, eax
        Invoke GetTextExtentPoint32, hdc, lpszButtonText, nLenButtonText, Addr sz
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
        Invoke ReleaseDC, hControl, hdc

        .IF hImage == NULL && hImageAlt == NULL
            mov eax, sz.x
            add eax, MUI_CAPBUTTON_TEXT_PADDING
            add eax, MUI_CAPBUTTON_TEXT_PADDING
        .ELSE

            Invoke MUIGetImageSize, hImage, MUIIT_ICO, Addr nIcoWidth, 0

            mov eax, sz.x
            add eax, MUI_CAPBUTTON_TEXT_PADDING
            add eax, nIcoWidth
            add eax, MUI_CAPBUTTON_IMAGETEXT_PADDING
            add eax, MUI_CAPBUTTON_TEXT_PADDING
        .ENDIF
        mov dwButtonWidth, eax
    
    .ENDIF
    mov eax, dwClientWidth
    sub eax, dwLeftOffset
    sub eax, dwButtonWidth
    mov xpos, eax
    
    Invoke _MUI_CreateCapButton, hControl, lpszButtonText, xpos, dwTopOffset, dwButtonWidth, dwButtonHeight, dwResourceID
    mov hCustomButton, eax
    .IF eax != 0
        Invoke MUISetExtProperty, hCustomButton, @SysButtonIco, hImage
        Invoke MUISetExtProperty, hCustomButton, @SysButtonIcoAlt, hImageAlt
        
        .IF lpszButtonText == 0
            Invoke MUISetIntProperty, hCustomButton, @CapButtonWidth, 0
        .ELSE
            Invoke MUISetIntProperty, hCustomButton, @CapButtonWidth, dwButtonWidth
        .ENDIF
        

        ; update leftoffset with dwButtonWidth
        mov eax, dwLeftOffset
        add eax, dwButtonWidth
        Invoke MUISetIntProperty, hControl, @CaptionBarButtonsLeftOffset, eax

        Invoke MUIGetIntProperty, hControl, @CaptionBarButtonArray ; something gone wrong if 0
        .IF eax == 0
            mov eax, NULL
            ret
        .ENDIF
        mov ptrButtonArray, eax
        
        Invoke MUIGetIntProperty, hControl, @CaptionBarTotalButtons
        mov dwNoButtons, eax
        inc eax
        
        Invoke MUISetIntProperty, hControl, @CaptionBarTotalButtons, eax
        mov eax, dwNoButtons
        mov ebx, SIZEOF DWORD
        mul ebx
        add eax, ptrButtonArray
        mov ebx, eax
        mov eax, hCustomButton
        mov [ebx], eax

    .ENDIF
    mov eax, hCustomButton
    ret
MUICaptionBarAddButton ENDP







END
;LIBEND
