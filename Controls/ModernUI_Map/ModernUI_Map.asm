;==============================================================================
;
; ModernUI Control - ModernUI_Map
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
;
; Intersection lines doesnt work, had to disable for the moment. Maybe someone 
; else can figure out how to draw intersection lines over the map without the 
; lines clipping everything black.
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

include ModernUI_Region.inc
includelib ModernUI_Region.lib

include ModernUI_Map.inc
include ModernUI_MapRegionData.inc

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_MapWndProc                    PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_MapInit                       PROTO :DWORD
_MUI_MapCleanup                    PROTO :DWORD
_MUI_MapPaint                      PROTO :DWORD
_MUI_MapPaintBackground            PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_MapPaintImage                 PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_MapPaintBorder                PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_MapCreateMapButtons           PROTO :DWORD, :DWORD
_MUI_MapButtonCreate               PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD  
_MUI_MapNotifyParent               PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_MapLoadBitmap                 PROTO :DWORD, :DWORD, :DWORD
_MUI_MapLoadIcon                   PROTO :DWORD, :DWORD, :DWORD
_MUI_MapDrawIntersectionLines      PROTO :DWORD, :DWORD, :DWORD
IFDEF MUI_USEGDIPLUS
_MUI_MapLoadPng                    PROTO :DWORD, :DWORD, :DWORD
ENDIF
IFDEF MUI_USEGDIPLUS
_MUI_MapPngReleaseIStream          PROTO :DWORD
ENDIF


_MUI_MapOverlayRegister            PROTO
_MUI_MapOverlayCreate              PROTO :DWORD
_MUI_MapOverlayWndProc             PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_MapOverlayPaint               PROTO :DWORD
_MUI_MapOverlayCoordLines          PROTO :DWORD, :DWORD, :DWORD, :DWORD

;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
IFNDEF MUI_MAP_PROPERTIES
MUI_MAP_PROPERTIES                 STRUCT
    dwMapTextColor                 DD ?
    dwMapTextFont                  DD ?
    dwMapBackColor                 DD ?
    dwMapBackColorDisabled         DD ?
    dwMapBorderColor               DD ?
    dwMapBorderColorDisabled       DD ?
    dwMapBackImageType             DD ?
    dwMapBackImage                 DD ?
    dwMapBackImageDisabled         DD ? 
    dwMapButtonBackColor           DD ? 
    dwMapButtonBackColorAlt        DD ? 
    dwMapButtonBackColorSel        DD ? 
    dwMapButtonBackColorSelAlt     DD ? 
    dwMapButtonBackColorDisabled   DD ?
    dwMapButtonBorderColor         DD ? 
    dwMapButtonBorderColorAlt      DD ? 
    dwMapButtonBorderColorSel      DD ? 
    dwMapButtonBorderColorSelAlt   DD ? 
    dwMapButtonBorderColorDisabled DD ? 
    dwMapButtonBorderStyle         DD ?
    dwMapButtonUserData            DD ? 
MUI_MAP_PROPERTIES                 ENDS
ENDIF

; Internal properties
_MUI_MAP_PROPERTIES                STRUCT
    dwEnabledState                 DD ?
    dwMouseOver                    DD ?
    dwNoMapButtons                 DD ?
    dwPtrMapButtonArray            DD ?
    dwMapBackImageStream           DD ?
    dwMapBackImageDisabledStream   DD ?
    dwMapOverlayHandle             DD ?
_MUI_MAP_PROPERTIES                ENDS

IFNDEF MUIRB_NOTIFY                ; Notification Message Structure for RegionButton
MUIRB_NOTIFY                       STRUCT
    hdr                            NMHDR <0,0,0>
    lParam                         DD 0
MUIRB_NOTIFY                       ENDS
ENDIF

IFNDEF MUIM_ITEM                   ; Map Item for use with MUIM_NOTIFY and WM_NOTIFY
MUIM_ITEM                          STRUCT
    idMapButton                    DD 0
    hMapButton                     DD 0
    lParam                         DD 0    
MUIM_ITEM                          ENDS
ENDIF

IFNDEF MUIM_NOTIFY                  ; Noticiation Message Structure for Map
MUIM_NOTIFY                        STRUCT
    hdr                            NMHDR <>
    mapitem                        MUIM_ITEM <0,0,0>
MUIM_NOTIFY                        ENDS
ENDIF

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
; Internal properties
@MapEnabledState                   EQU 0
@MapMouseOver                      EQU 4
@MapButtons                        EQU 8
@MapButtonsArray                   EQU 12
@MapBackImageStream                EQU 16
@MapBackImageDisabledStream        EQU 20
@MapOverlayHandle                  EQU 24
; External public properties


.DATA
ALIGN 4
szMUIMapOverlayClass               DB 'ModernUI_MapOverlay',0   ; Class name for creating our ModernUI_MapOverlay control
szMUIMapClass                      DB 'ModernUI_Map',0          ; Class name for creating our ModernUI_Map control
szMUIMapFont                       DB 'Segoe UI',0              ; Font used for ModernUI_Map text
hMUIMapFont                        DD 0                         ; Handle to ModernUI_Map font (segoe ui)
MNM                                MUIM_NOTIFY <>

.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_Map control
;------------------------------------------------------------------------------
MUIMapSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUIMapSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_Map control
;------------------------------------------------------------------------------
MUIMapGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUIMapGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIMapRegister - Registers the ModernUI_Map control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Map
;------------------------------------------------------------------------------
MUIMapRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIMapClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIMapClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_MapWndProc
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
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

MUIMapRegister ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIMapCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUIMapCreate PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUIMapRegister
    
    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
    
    Invoke CreateWindowEx, NULL, Addr szMUIMapClass, lpszText, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        
    .ENDIF
    mov eax, hControl
    ret
MUIMapCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_MapWndProc PROC PRIVATE USES EBX ECX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL hParent:DWORD
    LOCAL hMapOverlay:DWORD
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
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_MAP_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_MAP_PROPERTIES ; external properties
        Invoke _MUI_MapInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_MapCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4
        mov eax, 0
        ret
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_MapPaint, hWin
        mov eax, 0
        ret

;    .ELSEIF eax == WM_LBUTTONUP
;       ; simulates click on our control, delete if not required.
;       Invoke GetDlgCtrlID, hWin
;       mov ebx,eax
;       Invoke GetParent, hWin
;       Invoke PostMessage, eax, WM_COMMAND, ebx, hWin
;
   .ELSEIF eax == WM_MOUSEMOVE
        mov eax, lParam
        and eax, 0FFFFh
        mov xPos, eax
        mov eax, lParam
        shr eax, 16d
        mov yPos, eax
        
        ;Invoke MUIGetIntProperty, hWin, @MapOverlayHandle
        ;mov hMapOverlay, eax
        ;Invoke InvalidateRect, hMapOverlay, NULL, TRUE
        ;Invoke _MUI_MapOverlayCoordLines, hMapOverlay, NULL, xPos, yPos
        ;Invoke _MUI_MapOverlayPaint, hMapOverlay
    ;   PrintDec xPos
    ;   PrintDec yPos
    ;    Invoke _MUI_MapDrawIntersectionLines, hWin, xPos, yPos
    
    
;        Invoke MUIGetIntProperty, hWin, @MapEnabledState
;        .IF eax == TRUE   
;           Invoke MUISetIntProperty, hWin, @MapMouseOver, TRUE
;           .IF eax != TRUE
;               Invoke InvalidateRect, hWin, NULL, TRUE
;               mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
;               mov TE.dwFlags, TME_LEAVE
;               mov eax, hWin
;               mov TE.hwndTrack, eax
;               mov TE.dwHoverTime, NULL
;               Invoke TrackMouseEvent, Addr TE
;           ;.ELSE
;           ;    Invoke _MUI_MapNotifyParent, hWin, hWin, MUIMN_MOUSEOVER, 0
;           .ENDIF
;        .ENDIF
;
;    .ELSEIF eax == WM_MOUSELEAVE
;        Invoke MUISetIntProperty, hWin, @MapMouseOver , FALSE
;       Invoke InvalidateRect, hWin, NULL, TRUE
;       Invoke _MUI_MapNotifyParent, hWin, hWin, MUIMN_MOUSELEAVE, 0
;       Invoke LoadCursor, NULL, IDC_ARROW
;       Invoke SetCursor, eax

;    .ELSEIF eax == WM_GETDLGCODE
;        mov eax, DLGC_WANTALLKEYS
;        ret
;
;    .ELSEIF eax == WM_KEYDOWN
;        mov eax, wParam
;        .IF eax == VK_UP
;            PrintText 'VK_UP'
;        .ELSEIF eax == VK_DOWN
;            PrintText 'VK_DOWN'
;        .ELSEIF eax == VK_LEFT
;            PrintText 'VK_LEFT'
;        .ELSEIF eax == VK_RIGHT
;            PrintText 'VK_RIGHT'
;        .ENDIF
;

    .ELSEIF eax == WM_COMMAND
        ;PrintText 'WM_COMMAND'
        Invoke GetDlgCtrlID, hWin
        mov ebx,eax
        ;PrintDec ebx
        ;PrintDec wParam
        mov eax, wParam
        and eax, 0FFFFh
        shl eax, 16d
        ;PrintDec eax
        mov ax, bx 
        mov ebx, eax 
        ;PrintDec ebx       
        
        Invoke GetParent, hWin
        mov hParent, eax
        Invoke PostMessage, hParent, WM_COMMAND, ebx, hWin    
        

    .ELSEIF eax == WM_NOTIFY
        mov ecx, lParam
        mov eax, (MUIRB_NOTIFY ptr [ecx]).hdr.hwndFrom
        mov ebx, (MUIRB_NOTIFY ptr [ecx]).hdr.code
        mov ecx, (MUIRB_NOTIFY ptr [ecx]).lParam
        
        Invoke _MUI_MapNotifyParent, hWin, eax, ebx, ecx


    .ELSEIF eax == WM_MOUSEACTIVATE
        Invoke SetFocus, hWin
        mov eax, MA_ACTIVATE
        ret
;
;    .ELSEIF eax == WM_KILLFOCUS
;        Invoke MUISetIntProperty, hWin, @MapMouseOver , FALSE
;       Invoke InvalidateRect, hWin, NULL, TRUE
;       Invoke LoadCursor, NULL, IDC_ARROW
;       Invoke SetCursor, eax
    
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

_MUI_MapWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapInit - set initial default values
;------------------------------------------------------------------------------
_MUI_MapInit PROC PRIVATE hControl:DWORD
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
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle
    .ENDIF
    ;PrintDec dwStyle
    
    ; Set default initial external property values 
    Invoke MUISetIntProperty, hControl, @MapEnabledState, TRUE    
    Invoke MUISetExtProperty, hControl, @MapTextColor, MUI_RGBCOLOR(0,0,0)
    Invoke MUISetExtProperty, hControl, @MapBackColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hControl, @MapBorderColor, MUI_RGBCOLOR(96,96,96)
    
    .IF hMUIMapFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hFont, eax
        Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
        mov lfnt.lfHeight, -12d
        mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hMUIMapFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke MUISetExtProperty, hControl, @MapTextFont, hMUIMapFont
    
    
    ;PrintText '_MUI_MapInit:_MUI_MapCreateMapButtons'
    Invoke _MUI_MapCreateMapButtons, hControl, dwStyle
    
    ;PrintText '_MUI_MapInit:_MUI_MapOverlayCreate'
    ;Invoke _MUI_MapOverlayCreate, hControl
    ;PrintDec eax
    ;Invoke MUISetIntProperty, hControl, @MapOverlayHandle, eax
    ret

_MUI_MapInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapCleanup - cleanup stuff
;------------------------------------------------------------------------------
_MUI_MapCleanup PROC PRIVATE hControl:DWORD
    LOCAL ImageType:DWORD
    LOCAL hIStreamImage:DWORD
    LOCAL hIStreamImageDisabled:DWORD
    LOCAL hImage:DWORD
    LOCAL hImageDisabled:DWORD
    LOCAL dwStyle:DWORD
    LOCAL pMapButtonArray:DWORD
    
    ; unallocate map button array memory
    Invoke MUIGetIntProperty, hControl, @MapButtonsArray
    mov pMapButtonArray, eax
    .IF pMapButtonArray != 0
        Invoke GlobalFree, pMapButtonArray
    .ENDIF
    
    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax
    and eax, MUIMS_KEEPIMAGES
    .IF eax == MUIMS_KEEPIMAGES
        ret
    .ENDIF
    
    IFDEF DEBUG32
    PrintText '_MUI_MapCleanup'
    ENDIF
    ; cleanup any stream handles if png where loaded as resources
    Invoke MUIGetExtProperty, hControl, @MapBackImageType
    mov ImageType, eax

    .IF ImageType == 0
        ret
    .ENDIF
    
    .IF ImageType == 3
        IFDEF MUI_USEGDIPLUS
        Invoke MUIGetIntProperty, hControl, @MapBackImageStream
        mov hIStreamImage, eax
        .IF eax != 0
            Invoke _MUI_MapPngReleaseIStream, eax
        .ENDIF
        Invoke MUIGetIntProperty, hControl, @MapBackImageDisabledStream
        mov hIStreamImageDisabled, eax
        .IF eax != 0 && eax != hIStreamImage 
            Invoke _MUI_MapPngReleaseIStream, eax
        .ENDIF
        
        IFDEF DEBUG32
        ; check to see if handles are cleared.
        PrintText '_MUI_MapCleanup::IStream Handles cleared'
        ENDIF
        
        ENDIF        
    .ENDIF

    Invoke MUIGetExtProperty, hControl, @MapBackImage
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
    Invoke MUIGetExtProperty, hControl, @MapBackImageDisabled
    mov hImageDisabled, eax
    .IF eax != 0 && eax != hImage
        .IF ImageType != 3
            Invoke DeleteObject, eax
        .ELSE
            IFDEF MUI_USEGDIPLUS
            Invoke GdipDisposeImage, eax
            ENDIF
        .ENDIF
    .ENDIF

    IFDEF DEBUG32
    PrintText '_MUI_MapCleanup::Image Handles cleared'
    ENDIF

    ret

_MUI_MapCleanup ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapDrawIntersectionLines
;------------------------------------------------------------------------------
_MUI_MapDrawIntersectionLines PROC hControl:DWORD, dwXpos:DWORD, dwYpos:DWORD
    LOCAL hdc:DWORD
    LOCAL rectx:RECT
    LOCAL recty:RECT
    LOCAL rect:RECT
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD 
    LOCAL BackColor:DWORD
    LOCAL hRgn:DWORD  
    LOCAL hRgnX:DWORD
    LOCAL hRgnY:DWORD 
    
    Invoke GetDC, hControl
    mov hdc, eax
    
    Invoke GetClientRect, hControl, Addr rect
    
    Invoke CopyRect, Addr rectx, Addr rect
    Invoke CopyRect, Addr recty, Addr rect
    
    mov eax, dwXpos
    mov rectx.left, eax
    inc eax
    mov rectx.right, eax
    
    mov eax, dwYpos
    mov recty.top, eax
    inc eax
    mov recty.bottom, eax
    
    mov BackColor, 0
    
    ;Invoke InvalidateRect, hControl, NULL, TRUE
    
    Invoke CreateRectRgn, 0, 0, 0, 0
    mov hRgn, eax
    
    Invoke CreateRectRgn, rectx.left, rectx.top, rectx.right, rectx.bottom
    mov hRgnX, eax
    
    Invoke CreateRectRgn, recty.left, recty.top, recty.right, recty.bottom
    mov hRgnY, eax
    
    Invoke CombineRgn, hRgn, hRgnX, hRgnY, RGN_OR
    Invoke SelectClipRgn, hdc, hRgn
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    
    Invoke FrameRect, hdc, Addr rectx, hBrush
     
    Invoke FrameRect, hdc, Addr recty, hBrush

    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF   
    
    Invoke DeleteObject, hRgnX
    Invoke DeleteObject, hRgnY
    
    Invoke ReleaseDC, hControl, hdc
    
    ret

_MUI_MapDrawIntersectionLines ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapPaint
;------------------------------------------------------------------------------
_MUI_MapPaint PROC PRIVATE hControl:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL EnabledState:DWORD
    
    Invoke BeginPaint, hControl, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hControl, Addr rect
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax
    
    ;----------------------------------------------------------
    ; Get some property values
    ;---------------------------------------------------------- 
    Invoke MUIGetIntProperty, hControl, @MapEnabledState
    mov EnabledState, eax

    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _MUI_MapPaintBackground, hControl, hdcMem, Addr rect, EnabledState

    ;----------------------------------------------------------
    ; Background Image
    ;----------------------------------------------------------
    Invoke _MUI_MapPaintImage, hControl, hdc, hdcMem, Addr rect, EnabledState

    ;----------------------------------------------------------
    ; Border
    ;----------------------------------------------------------
    Invoke _MUI_MapPaintBorder, hControl, hdcMem, Addr rect, EnabledState

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
     
    Invoke EndPaint, hControl, Addr ps

    ret
_MUI_MapPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapPaintBackground - Paints the background of the Map control
;------------------------------------------------------------------------------
_MUI_MapPaintBackground PROC PRIVATE hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD

    .IF bEnabledState == TRUE
        Invoke MUIGetExtProperty, hControl, @MapBackColor                         ; normal back color
    .ELSE
        Invoke MUIGetExtProperty, hControl, @MapBackColorDisabled                 ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hControl, @MapBackColor                         ; fallback to default Normal back color
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
_MUI_MapPaintBackground ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapPaintImage
;------------------------------------------------------------------------------
_MUI_MapPaintImage PROC PRIVATE USES EBX hControl:DWORD, hdcMain:DWORD, hdcDest:DWORD, lpRect:DWORD, bEnabledState:DWORD
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
    
    Invoke MUIGetExtProperty, hControl, @MapBackImageType        
    mov ImageType, eax ; 0 = none, 1 = bitmap, 2 = icon, 3 = png

    .IF ImageType == 0
        ret
    .ENDIF    
    
    .IF ImageType != 0
        .IF bEnabledState == TRUE
            Invoke MUIGetExtProperty, hControl, @MapBackImage                ; Normal image
        .ELSE
            Invoke MUIGetExtProperty, hControl, @MapBackImageDisabled        ; Disabled image
        .ENDIF
        mov hImage, eax
    .ELSE
        mov hImage, 0
    .ENDIF

    ;PrintDec hImage
    
    .IF hImage != 0
        Invoke MUIGetImageSize, hImage, ImageType, Addr ImageWidth, Addr ImageHeight
        
        Invoke GetClientRect, hControl, Addr rect
        
        ;PrintDec ImageWidth
        ;PrintDec ImageHeight
        
        mov eax, ImageType
        .IF eax == 1 ; bitmap
            ;PrintText 'bitmap'
            Invoke CreateCompatibleDC, hdcMain
            mov hdcMem, eax
            Invoke SelectObject, hdcMem, hImage ;
            mov hbmOld, eax
            ;Invoke GetClientRect, hControl, Addr rect
            Invoke BitBlt, hdcDest, 0, 0, ImageWidth, ImageHeight, hdcMem, 0, 0, SRCCOPY ;ImageWidth, ImageHeight
    
            Invoke SelectObject, hdcMem, hbmOld
            Invoke DeleteDC, hdcMem
            .IF hbmOld != 0
                Invoke DeleteObject, hbmOld
            .ENDIF
            
        .ELSEIF eax == 2 ; icon
            Invoke DrawIconEx, hdcDest, 0, 0, hImage, 0, 0, 0, 0, DI_NORMAL
        
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke GdipCreateFromHDC, hdcDest, Addr pGraphics
            
            Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
            Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer            
            Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
            Invoke GdipDrawImageRectI, pGraphics, pBitmap, 0, 0, ImageWidth, ImageHeight
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

_MUI_MapPaintImage ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapPaintBorder - Paints the border surrounding the Map control
;------------------------------------------------------------------------------
_MUI_MapPaintBorder PROC PRIVATE hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD
    LOCAL BorderColor:DWORD
    LOCAL BorderSize:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL rect:RECT

    .IF bEnabledState == TRUE
        Invoke MUIGetExtProperty, hControl, @MapBorderColor                     ; normal border color
    .ELSE
        Invoke MUIGetExtProperty, hControl, @MapBorderColorDisabled             ; Disabled border color
    .ENDIF
    mov BorderColor, eax

    .IF BorderColor != 0
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdc, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdc, BorderColor
        Invoke FrameRect, hdc, lpRect, hBrush
    .ENDIF

    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF     
    ret
_MUI_MapPaintBorder ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapCreateMapButtons - Creates map buttons
;------------------------------------------------------------------------------
_MUI_MapCreateMapButtons PROC PRIVATE USES EBX hControl:DWORD, dwStyle:DWORD
    LOCAL hMapButton:DWORD
    LOCAL pMapButtonArray:DWORD
    LOCAL ptrMapButtonRecord:DWORD
    
    ; create map buttons based on the style indicated
    ; alloc memory for the total amount of buttons to create
    ; create each button by calling _MUI_MapButtonCreate and update map button array
    ; set individual properties for each button based on defaults 
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, (MUIMB_MAX * 4)
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov pMapButtonArray, eax
    mov ptrMapButtonRecord, eax
    
    Invoke MUISetIntProperty, hControl, @MapButtonsArray, pMapButtonArray
    
    mov eax, dwStyle
    and eax, MUIMS_WORLD or MUIMS_EUROPE or MUIMS_USA or MUIMS_BRITISHISLES or MUIMS_UK_IND or MUIMS_UK_IRELAND_IND
    ;PrintDec eax
    .IF eax == MUIMS_WORLD
        ;PrintText 'MUIMS_WORLD'
    .ELSEIF eax == MUIMS_EUROPE
        ;PrintText 'MUIMS_EUROPE'
    .ELSEIF eax == MUIMS_USA
        ;PrintText 'MUIMS_USA'
    .ELSEIF eax == MUIMS_BRITISHISLES
        ;PrintText 'MUIMS_BRITISHISLES'
    .ELSEIF eax == MUIMS_UK_IND
        ;PrintText 'MUIMS_UK_IND'
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Ireland"), REGION_IRELAND_X, REGION_IRELAND_Y, MUIMB_IRELAND, MUIRB_MOUSEMOVEPARENT or MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_IRELAND_DATA, REGION_IRELAND_SIZE
        Invoke EnableWindow, hMapButton, FALSE
        Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColorDisabled, MUI_RGBCOLOR(180,180,180)
        Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBorderColorDisabled, MUI_RGBCOLOR(64,64,64)
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_IRELAND*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Scotland"), REGION_SCOTLAND_X, REGION_SCOTLAND_Y, MUIMB_SCOTLAND, MUIRB_MOUSEMOVEPARENT or MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_SCOTLAND_DATA, REGION_SCOTLAND_SIZE
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_SCOTLAND*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("England"), REGION_ENGLAND_X, REGION_ENGLAND_Y, MUIMB_ENGLAND, MUIRB_MOUSEMOVEPARENT or MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_ENGLAND_DATA, REGION_ENGLAND_SIZE
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_ENGLAND*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Wales"), REGION_WALES_X, REGION_WALES_Y, MUIMB_WALES, MUIRB_MOUSEMOVEPARENT or MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_WALES_DATA, REGION_WALES_SIZE
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_WALES*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Northern Ireland"), REGION_NIRELAND_X, REGION_NIRELAND_Y, MUIMB_NORTHERN_IRELAND, MUIRB_MOUSEMOVEPARENT or MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_NORTHERN_IRELAND_DATA, REGION_NORTHERN_IRELAND_SIZE
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_NORTHERN_IRELAND*4], eax        
    
    .ELSEIF eax == MUIMS_UK_IRELAND_IND
        ;PrintText 'MUIMS_UK_IRELAND_IND'
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Ireland"), REGION_IRELAND_X, REGION_IRELAND_Y, MUIMB_IRELAND, MUIRB_MOUSEMOVEPARENT or  MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        ;PrintDec hMapButton
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_IRELAND_DATA, REGION_IRELAND_SIZE
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_IRELAND*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Scotland"), REGION_SCOTLAND_X, REGION_SCOTLAND_Y, MUIMB_SCOTLAND, MUIRB_MOUSEMOVEPARENT or  MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_SCOTLAND_DATA, REGION_SCOTLAND_SIZE
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColor, MUI_RGBCOLOR(156,194,202)
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColorAlt, MUI_RGBCOLOR(181,206,231)
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_SCOTLAND*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("England"), REGION_ENGLAND_X, REGION_ENGLAND_Y, MUIMB_ENGLAND, MUIRB_MOUSEMOVEPARENT or  MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_ENGLAND_DATA, REGION_ENGLAND_SIZE
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColor, MUI_RGBCOLOR(175,156,202)
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColorAlt, MUI_RGBCOLOR(205,181,231)
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_ENGLAND*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Wales"), REGION_WALES_X, REGION_WALES_Y, MUIMB_WALES, MUIRB_MOUSEMOVEPARENT or MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_WALES_DATA, REGION_WALES_SIZE
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColor, MUI_RGBCOLOR(202,156,173)
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColorAlt, MUI_RGBCOLOR(231,181,197)
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_WALES*4], eax
        
        Invoke _MUI_MapButtonCreate, hControl, CTEXT("Northern Ireland"), REGION_NIRELAND_X, REGION_NIRELAND_Y, MUIMB_NORTHERN_IRELAND, MUIRB_MOUSEMOVEPARENT or MUIRB_HAND or WS_CHILD or WS_VISIBLE
        mov hMapButton, eax
        Invoke MUIRegionButtonSetRegion, hMapButton, Addr REGION_NORTHERN_IRELAND_DATA, REGION_NORTHERN_IRELAND_SIZE
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColor, MUI_RGBCOLOR(202,202,156)
        ;Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColorAlt, MUI_RGBCOLOR(231,231,181)
        mov ebx, ptrMapButtonRecord
        mov eax, hMapButton
        mov dword ptr [ebx+MUIMB_NORTHERN_IRELAND*4], eax
        
    .ENDIF
    
    ;DbgDump ptrMapButtonRecord, (170 * 4)
    mov eax, TRUE
    ret

_MUI_MapCreateMapButtons ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapButtonCreate - Creates a map button
;------------------------------------------------------------------------------
_MUI_MapButtonCreate PROC hControl:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL hMapButton:DWORD
    
    Invoke MUIRegionButtonCreate, hControl, lpszText, xpos, ypos, dwResourceID, dwStyle
    mov hMapButton, eax
    
    Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColor, MUI_RGBCOLOR(156,202,163)
    Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBackColorAlt, MUI_RGBCOLOR(181,231,189)
    Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBorderColor, MUI_RGBCOLOR(64,64,64)
    Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBorderColorAlt, MUI_RGBCOLOR(19,84,29) ;19,84,29
    Invoke MUIRegionButtonSetProperty, hMapButton, @RegionButtonBorderSize, 1
    
    mov eax, hMapButton
    ret

_MUI_MapButtonCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapButtonsAllSetProperty - sets property for all map buttons
;------------------------------------------------------------------------------
_MUI_MapButtonsAllSetProperty PROC

    ret
    
_MUI_MapButtonsAllSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIMapButtonSetProperty - Sets property for specific map button
;------------------------------------------------------------------------------
MUIMapButtonSetProperty PROC hControl:DWORD, dwMapButtonID:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL hMapButton:DWORD
    Invoke MUIMapButtonGetHandle, hControl, dwMapButtonID
    .IF eax == NULL
        ret
    .ENDIF
    mov hMapButton, eax
    Invoke MUIRegionButtonSetProperty, hMapButton, dwProperty, dwPropertyValue
    ret
MUIMapButtonSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIMapButtonGetProperty - Gets property for specific map button
;------------------------------------------------------------------------------
MUIMapButtonGetProperty PROC hControl:DWORD, dwMapButtonID:DWORD, dwProperty:DWORD
    LOCAL hMapButton:DWORD
    Invoke MUIMapButtonGetHandle, hControl, dwMapButtonID
    .IF eax == NULL
        ret
    .ENDIF
    mov hMapButton, eax
    Invoke MUIRegionButtonGetProperty, hMapButton, dwProperty
    ret
MUIMapButtonGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIMapButtonGetHandle - Gets handle for specific map button
;------------------------------------------------------------------------------
MUIMapButtonGetHandle PROC USES EBX hControl:DWORD, dwMapButtonID:DWORD
    LOCAL pMapButtonArray:DWORD

    Invoke MUIGetIntProperty, hControl, @MapButtonsArray
    mov pMapButtonArray, eax

    mov eax, dwMapButtonID
    .IF eax > MUIMB_MAX
        mov eax, NULL
        ret
    .ENDIF

    mov ebx, pMapButtonArray
    mov eax, dword ptr [ebx+eax*4]
    ret
MUIMapButtonGetHandle ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapNotifyParent - Notify Parent when mouse over / leave of map button
;------------------------------------------------------------------------------
_MUI_MapNotifyParent PROC hControl:DWORD, hMapButton:DWORD, dwNotifyMsg:DWORD, lParam:DWORD
    LOCAL hParent:DWORD
    LOCAL idControl:DWORD
    LOCAL idMapButton:DWORD
    
    
    Invoke GetParent, hControl
    mov hParent, eax

    Invoke GetDlgCtrlID, hControl
    mov idControl, eax
    mov eax, hControl
    mov MNM.hdr.hwndFrom, eax
    mov eax, idControl
    mov MNM.hdr.idFrom, eax
    mov eax, dwNotifyMsg
    mov MNM.hdr.code, eax

    ; Get MapButton Info
    Invoke GetDlgCtrlID, hMapButton
    mov idMapButton, eax
    mov eax, idMapButton
    mov MNM.mapitem.idMapButton, eax
    mov eax, hMapButton
    mov MNM.mapitem.hMapButton, eax
    mov eax, lParam
    mov MNM.mapitem.lParam, eax

    ; Sent notification
    .IF hParent != NULL
        Invoke PostMessage, hParent, WM_NOTIFY, idControl, Addr MNM
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF    
    ret

_MUI_MapNotifyParent ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIMapLoadImages - Loads images from resource ids and stores the handles in 
; the appropriate property.
;------------------------------------------------------------------------------
MUIMapLoadImages PROC PUBLIC hControl:DWORD, dwImageType:DWORD, dwResIDImage:DWORD, dwResIDImageDisabled:DWORD

    .IF dwImageType == 0
        ret
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @MapBackImageType, dwImageType

    .IF dwResIDImage != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_MapLoadBitmap, hControl, @MapBackImage, dwResIDImage
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_MapLoadIcon, hControl, @MapBackImage, dwResIDImage
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_MapLoadPng, hControl, @MapBackImage, dwResIDImage
            ENDIF
        .ENDIF
    .ENDIF

    .IF dwResIDImageDisabled != 0
        mov eax, dwImageType
        .IF eax == 1 ; bitmap
            Invoke _MUI_MapLoadBitmap, hControl, @MapBackImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 2 ; icon
            Invoke _MUI_MapLoadIcon, hControl, @MapBackImageDisabled, dwResIDImageDisabled
        .ELSEIF eax == 3 ; png
            IFDEF MUI_USEGDIPLUS
            Invoke _MUI_MapLoadPng, hControl, @MapBackImageDisabled, dwResIDImageDisabled
            ENDIF
        .ENDIF
    .ENDIF
    
    Invoke InvalidateRect, hControl, NULL, TRUE
    
    ret
MUIMapLoadImages ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIMapSetImages - Sets the property handles for image types
;------------------------------------------------------------------------------
MUIMapSetImages PROC PUBLIC hControl:DWORD, dwImageType:DWORD, hImage:DWORD, hImageDisabled:DWORD

    .IF dwImageType == 0
        ret
    .ENDIF
    
    Invoke MUISetExtProperty, hControl, @MapBackImageType, dwImageType

    .IF hImage != 0
        Invoke MUISetExtProperty, hControl, @MapBackImage, hImage
    .ENDIF

    .IF hImageDisabled != 0
        Invoke MUISetExtProperty, hControl, @MapBackImageDisabled, hImageDisabled
    .ENDIF
    
    Invoke InvalidateRect, hControl, NULL, TRUE
    
    ret

MUIMapSetImages ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapLoadBitmap - if succesful, loads specified bitmap resource into the 
; specified external property and returns TRUE in eax, otherwise FALSE.
;------------------------------------------------------------------------------
_MUI_MapLoadBitmap PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResBitmap:DWORD
    LOCAL hinstance:DWORD

    .IF idResBitmap == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    ;Invoke MUIGetExtProperty, hWin, @MapDllInstance
    ;.IF eax == 0
        Invoke GetModuleHandle, NULL
    ;.ENDIF
    mov hinstance, eax
    
    Invoke LoadBitmap, hinstance, idResBitmap
    Invoke MUISetExtProperty, hWin, dwProperty, eax
    mov eax, TRUE
    
    ret

_MUI_MapLoadBitmap ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapLoadIcon - if succesful, loads specified icon resource into the 
; specified external property and returns TRUE in eax, otherwise FALSE.
;------------------------------------------------------------------------------
_MUI_MapLoadIcon PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResIcon:DWORD
    LOCAL hinstance:DWORD

    .IF idResIcon == NULL
        mov eax, FALSE
        ret
    .ENDIF
    ;Invoke MUIGetExtProperty, hWin, @MapDllInstance
    ;.IF eax == 0
        Invoke GetModuleHandle, NULL
    ;.ENDIF
    mov hinstance, eax

    Invoke LoadImage, hinstance, idResIcon, IMAGE_ICON, 0, 0, 0 ;LR_SHARED
    Invoke MUISetExtProperty, hWin, dwProperty, eax

    mov eax, TRUE

    ret

_MUI_MapLoadIcon ENDP


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
_MUI_MapLoadPng PROC PRIVATE hWin:DWORD, dwProperty:DWORD, idResPng:DWORD
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

    ;Invoke MUIGetExtProperty, hWin, @MapDllInstance
    ;.IF eax == 0
        Invoke GetModuleHandle, NULL
    ;.ENDIF
    mov hinstance, eax

    ; ------------------------------------------------------------------
    ; STEP 1: Find the resource
    ; ------------------------------------------------------------------
    invoke  FindResource, hinstance, idResPng, RT_RCDATA
    or      eax, eax
    jnz     @f
    jmp     _MUI_MapLoadPng@Close
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
    jmp     _MUI_MapLoadPng@Close
@@: mov     sizeOfRes, eax
    
    invoke  LockResource, hResData
    or      eax, eax
    jnz     @f
    jmp     _MUI_MapLoadPng@Close
@@: mov     pResData, eax

    invoke  GlobalAlloc, GMEM_MOVEABLE, sizeOfRes
    or      eax, eax
    jnz     @f
    jmp     _MUI_MapLoadPng@Close
@@: mov     hbuffer, eax

    invoke  GlobalLock, hbuffer
    mov     pbuffer, eax
    
    invoke  RtlMoveMemory, pbuffer, hResData, sizeOfRes
    invoke  CreateStreamOnHGlobal, pbuffer, TRUE, addr pIStream
    or      eax, eax
    jz      @f
    jmp     _MUI_MapLoadPng@Close
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
    .IF eax == @MapBackImage
        Invoke MUISetIntProperty, hWin, @MapBackImageStream, hIStream
    .ELSEIF eax == @MapBackImageDisabled
        Invoke MUISetIntProperty, hWin, @MapBackImageDisabledStream, hIStream
    .ENDIF

    mov eax, TRUE
    
_MUI_MapLoadPng@Close:
    ret
_MUI_MapLoadPng endp
ENDIF

;------------------------------------------------------------------------------
; _MUI_MapPngReleaseIStream - releases png stream handle
;------------------------------------------------------------------------------
IFDEF MUI_USEGDIPLUS
MUI_ALIGN
_MUI_MapPngReleaseIStream PROC hIStream:DWORD
    
    mov eax, hIStream
    push    eax
    mov     eax,DWORD PTR [eax]
    call    IStream.IUnknown.Release[eax]                               ; release the stream
    ret

_MUI_MapPngReleaseIStream ENDP
ENDIF





MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapOverlayRegister - Registers the ModernUI_MapOverlay control
;------------------------------------------------------------------------------
_MUI_MapOverlayRegister PROC PRIVATE
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUIMapOverlayClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUIMapOverlayClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_MapOverlayWndProc
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, CS_PARENTDC ;NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 0
        Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

_MUI_MapOverlayRegister ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapOverlayCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
_MUI_MapOverlayCreate PROC PRIVATE hWndParent:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL rect:RECT
    
    ;PrintText '_MUI_MapOverlayCreate'
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke _MUI_MapOverlayRegister

    Invoke GetClientRect, hWndParent, Addr rect
    
    Invoke CreateWindowEx, WS_EX_TRANSPARENT, Addr szMUIMapOverlayClass, NULL, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS, 0, 0, rect.right, rect.bottom, hWndParent, 1, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
    ;    PrintDec hControl
    .ENDIF
    mov eax, hControl
    ret
_MUI_MapOverlayCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapOverlayWndProc - Main processing window for our overlay control
;------------------------------------------------------------------------------
_MUI_MapOverlayWndProc PROC PRIVATE USES EBX ECX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL hParent:DWORD
    LOCAL xPos:DWORD
    LOCAL yPos:DWORD
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        mov eax, 0
        ret    
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

   .ELSEIF eax == WM_MOUSEMOVE
        mov eax, lParam
        and eax, 0FFFFh
        mov xPos, eax
        mov eax, lParam
        shr eax, 16d
        mov yPos, eax
        Invoke _MUI_MapOverlayCoordLines, hWin, NULL, xPos, yPos

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_MapOverlayPaint, hWin
        mov eax, 0
        ret
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_MapOverlayWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_MapOverlayPaint - paint overlay control
;------------------------------------------------------------------------------
_MUI_MapOverlayPaint PROC PRIVATE hControl:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    
    Invoke BeginPaint, hControl, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    ;Invoke GetClientRect, hControl, Addr rect
    ;Invoke CreateCompatibleDC, hdc
    ;mov hdcMem, eax
    ;Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    ;mov hbmMem, eax
    ;Invoke SelectObject, hdcMem, hbmMem
    ;mov hOldBitmap, eax

    ;invoke SetBkMode, hdc, TRANSPARENT
    ;invoke SetBkMode, hdcMem, TRANSPARENT

    ;Invoke GetStockObject, NULL_BRUSH
   ; mov BackColor, eax
    
    ;Invoke GetStockObject, DC_BRUSH
    ;mov hBrush, eax
    ;Invoke SelectObject, hdc, eax
    ;mov hOldBrush, eax
    ;Invoke SetDCBrushColor, hdcMem, BackColor
    ;Invoke FillRect, hdc, Addr rect, hBrush
    
    Invoke _MUI_MapOverlayCoordLines, hControl, hdc, 0, 0

    
    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    ;Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    
    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF    
    
    ;Invoke SelectObject, hdcMem, hOldBitmap
    ;Invoke DeleteDC, hdcMem
    ;Invoke DeleteObject, hbmMem
    .IF hOldBitmap != 0
        Invoke DeleteObject, hOldBitmap
    .ENDIF      

    Invoke EndPaint, hControl, Addr ps
    ret

_MUI_MapOverlayPaint ENDP


MUI_ALIGN
_MUI_MapOverlayCoordLines PROC PRIVATE hControl:DWORD, hdcMain:DWORD, dwXpos:DWORD, dwYpos:DWORD
    LOCAL rectx:RECT
    LOCAL recty:RECT
    LOCAL rect:RECT
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD 
    LOCAL BackColor:DWORD
    LOCAL hRgn:DWORD  
    LOCAL hRgnX:DWORD
    LOCAL hRgnY:DWORD 
    LOCAL hFillRgn:DWORD
    LOCAL pt:POINT
    LOCAL hdc:DWORD

    .IF hdcMain == NULL
        Invoke GetDC, hControl
    .ELSE
        mov eax, hdcMain
    .ENDIF
    mov hdc, eax
    
    Invoke GetClientRect, hControl, Addr rect
    Invoke CopyRect, Addr rectx, Addr rect
    Invoke CopyRect, Addr recty, Addr rect
    
    ;Invoke GetCursorPos, Addr pt
    ;Invoke MapWindowPoints, HWND_DESKTOP, hControl, Addr pt, 1
    ;Invoke ScreenToClient, hControl, Addr pt
    
    
    ;PrintDec dwXpos
    ;PrintDec dwYpos
    ;PrintDec pt.x
    ;PrintDec pt.y
    
    mov eax, dwXpos
    mov rectx.left, eax
    inc eax
    mov rectx.right, eax
    
    mov eax, dwYpos
    mov recty.top, eax
    inc eax
    mov recty.bottom, eax
    
    mov BackColor, 0
    
    ;Invoke InvalidateRect, hControl, NULL, TRUE
    ;invoke SetBkMode, hdc, TRANSPARENT
    
    Invoke SelectClipRgn, hdc, NULL
    
    Invoke CreateRectRgn, rect.left, rect.top, rect.right, rect.bottom
    mov hRgn, eax
    
    ;Invoke ExcludeClipRect, hdc, rect.left, rect.top, rect.right, rect.bottom
    ;mov hRgn, eax
    
    Invoke CreateRectRgn, rectx.left, rectx.top, rectx.right, rectx.bottom
    mov hRgnX, eax
    Invoke CombineRgn, hRgn, hRgn, hRgnX, RGN_XOR
   
    
    Invoke CreateRectRgn, recty.left, recty.top, recty.right, recty.bottom
    mov hRgnY, eax
    Invoke CombineRgn, hRgn, hRgn, hRgnY, RGN_XOR
    
    ;Invoke ExcludeClipRect, hdc, rectx.left, rectx.top, rectx.right, rectx.bottom
    ;mov hRgnX, eax
    ;Invoke CombineRgn, hRgn, hRgn, hRgnX, RGN_AND
    ;Invoke InvertRgn, hdc, hRgnX
    
    ;Invoke ExcludeClipRect, hdc, recty.left, recty.top, recty.right, recty.bottom
    ;mov hRgnY, eax
    ;Invoke InvertRgn, hdc, hRgnY
    ;Invoke CombineRgn, hRgn, hRgn, hRgnY, RGN_DIFF
    
    ;Invoke CombineRgn, hRgn, hRgnX, hRgnY, RGN_DIFF    
    
    
    ;Invoke CombineRgn, hRgn, hRgn, hRgnX, RGN_XOR
    ;Invoke InvertRgn, hdc, hRgnX
    ;Invoke SelectClipRgn, hdc, hRgnX

    


    Invoke CreateRectRgn, 0,0,0,0 ;rect.left, rect.top, rect.right, rect.bottom
    mov hFillRgn, eax
    Invoke CombineRgn, hFillRgn, hFillRgn, hRgn, RGN_XOR
    Invoke SelectClipRgn, hdc, hFillRgn

     

    Invoke GetStockObject, NULL_BRUSH
   ; mov BackColor, eax
    
    ;Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    ;Invoke SetDCBrushColor, hdcMem, BackColor
    Invoke FillRect, hdc, Addr rect, hBrush
    
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    
    Invoke FillRgn, hdc, hFillRgn, hBrush ;hBGBrush);
    
    ;Invoke FrameRect, hdc, Addr rectx, hBrush
     
    ;Invoke FrameRect, hdc, Addr recty, hBrush
    
    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    
    ;
    Invoke DeleteObject, hFillRgn
    Invoke DeleteObject, hRgn
    Invoke DeleteObject, hRgnX
    Invoke DeleteObject, hRgnY    
    
    
    
    .IF hdcMain == NULL
        Invoke ReleaseDC, hControl, hdc
    .ENDIF    
    ret

_MUI_MapOverlayCoordLines ENDP



END
