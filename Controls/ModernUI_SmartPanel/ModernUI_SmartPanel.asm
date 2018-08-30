;==============================================================================
;
; ModernUI Control - ModernUI_SmartPanel
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
include gdi32.inc
include comctl32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_SmartPanel.inc

;------------------------------------------------------------------------------
; Prototypes for internal use
;------------------------------------------------------------------------------
_MUI_SmartPanelWndProc                  PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SmartPanelInit                     PROTO :DWORD
_MUI_SmartPanelCleanup                  PROTO :DWORD
;_MUI_SmartPanelPaint                    PROTO :DWORD
_MUI_SmartPanelGetPanelHandle           PROTO :DWORD, :DWORD
_MUI_SmartPanelNavNotify                PROTO :DWORD, :DWORD, :DWORD
_MUI_SmartPanelSlidePanels              PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SmartPanelSlidePanelsLeft          PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SmartPanelSlidePanelsRight         PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SP_ResizePanels                    PROTO :DWORD
_MUI_SP_DialogSubClassProc              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_SP_DialogPaintBackground           PROTO :DWORD, :DWORD

;------------------------------------------------------------------------------
; Structures for internal use
;------------------------------------------------------------------------------
; External public properties
MUI_SMARTPANEL_PROPERTIES               STRUCT
    dwPanelsColor                       DD ?
    dwBorderColor                       DD ?    
    dwDllInstance                       DD ?
    dwParam                             DD ?
MUI_SMARTPANEL_PROPERTIES               ENDS

; Internal properties
_MUI_SMARTPANEL_PROPERTIES              STRUCT
    dwEnabledState                      DD ?
    dwMouseOver                         DD ?
    dwCurrentPanel                      DD ?
    dwTotalPanels                       DD ?
    dwPanelsArray                       DD ?
    lpdwIsDlgMsgVar                     DD ?
    hBitmap                             DD ?
    uIdSubclassCounter                  DD ?
_MUI_SMARTPANEL_PROPERTIES              ENDS

IFNDEF MUISP_ITEM ; SmartPanel Notification Item / Panel information
MUISP_ITEM                              STRUCT
    iItem                               DD 0 ; index of dialog in array
    lParam                              DD 0 ; not used currently
    hPanel                              DD 0 ; handle to dialog panel
    clrRGB                              DD -1 ; RGBCOLOR of panel background, -1 = not using 
MUISP_ITEM                              ENDS
ENDIF

IFNDEF NM_MUISMARTPANEL ; Notification Message Structure for SmartPanel
NM_MUISMARTPANEL                        STRUCT
    hdr                                 NMHDR <>
    itemOld                             MUISP_ITEM <>
    itemNew                             MUISP_ITEM <>
NM_MUISMARTPANEL                        ENDS
ENDIF


.CONST
IFNDEF MUISPN_SELCHANGED
MUISPN_SELCHANGED                       EQU 0 ; Used with WM_NOTIFY. wParam is a NM_MUISMARTPANEL struct
ENDIF

SlideSlow                               EQU 0
SlideNormal                             EQU 1
SlideFast                               EQU 2
SlideVFast                              EQU 3


; Internal properties
@SmartPanelEnabledState                 EQU 0
@SmartPanelMouseOver                    EQU 4
@SmartPanelCurrentPanel                 EQU 8
@SmartPanelTotalPanels                  EQU 12
@SmartPanelPanelsArray                  EQU 16
@SmartPanellpdwIsDlgMsgVar              EQU 20
@SmartPanelBitmap                       EQU 24
@SPSubclassCounter                      EQU 28
; External public properties


.DATA
ALIGN 4
szMUISmartPanelClass                    DB 'ModernUI_SmartPanel',0  ; Class name for creating our ModernUI_SmartPanel control
SPNM                                    NM_MUISMARTPANEL <> ; Notification data passed via WM_NOTIFY


.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Set property for ModernUI_SmartPanel control
;------------------------------------------------------------------------------
MUISmartPanelSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUISmartPanelSetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get property for ModernUI_SmartPanel control
;------------------------------------------------------------------------------
MUISmartPanelGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUISmartPanelGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelRegister - Registers the ModernUI_SmartPanel control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_SmartPanel
;------------------------------------------------------------------------------
MUISmartPanelRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUISmartPanelClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUISmartPanelClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _MUI_SmartPanelWndProc
        Invoke LoadCursor, NULL, IDC_ARROW
        mov wc.hCursor, eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style,  NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
        Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

MUISmartPanelRegister ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelCreate - Returns handle in eax of newly created control
;------------------------------------------------------------------------------
MUISmartPanelCreate PROC PRIVATE hWndParent:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUISmartPanelRegister
    
    ; Modify styles appropriately - for visual controls no CS_HREDRAW CS_VREDRAW (causes flickering)
    ; probably need WS_CHILD, WS_VISIBLE. Needs WS_CLIPCHILDREN. Non visual prob dont need any of these.

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, DS_CONTROL or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != DS_CONTROL or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, DS_CONTROL or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
    
    Invoke CreateWindowEx, WS_EX_CONTROLPARENT, Addr szMUISmartPanelClass, NULL, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        
    .ENDIF
    mov eax, hControl
    ret
MUISmartPanelCreate ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelWndProc - Main processing window for our control
;------------------------------------------------------------------------------
_MUI_SmartPanelWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        ; sets text of our control, delete if not required.
        ;Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName   
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_SMARTPANEL_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_SMARTPANEL_PROPERTIES ; external properties
        Invoke _MUI_SmartPanelInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke _MUI_SmartPanelCleanup, hWin
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4
        mov eax, 0
        ret
    
    .ELSEIF eax == WM_SIZE
        ; Check if _MUI_SMARTPANEL_PROPERTIES ; internal properties available
        Invoke GetWindowLong, hWin, 0
        .IF eax != 0 ; Yes they are
            Invoke _MUI_SP_ResizePanels, hWin ; resize all panel dialogs to same size as smartpanel
        .ENDIF
        mov eax, 0
        ret
    
;    .ELSEIF eax == WM_ERASEBKGND
;        mov eax, 1
;        ret
;
;    .ELSEIF eax == WM_PAINT
;        Invoke _MUI_SmartPanelPaint, hWin
;        mov eax, 0
;        ret
    
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        Invoke MUISetExtProperty, hWin, wParam, lParam
        ret

    .ELSEIF eax == MUISPM_REGISTERPANEL
        Invoke MUISmartPanelRegisterPanel, hWin, wParam, lParam
        ret
        
    .ELSEIF eax == MUISPM_SETCURRENTPANEL
        Invoke MUISmartPanelSetCurrentPanel, hWin, wParam, lParam
        ret
    
    .ELSEIF eax == MUISPM_GETCURRENTPANEL
        Invoke MUIGetIntProperty, hWin, @SmartPanelCurrentPanel
        ret
        
    .ELSEIF eax == MUISPM_SETISDLGMSGVAR ; wParam is addr of variable to use to specify current selected panel
        Invoke MUISetIntProperty, hWin, @SmartPanellpdwIsDlgMsgVar, wParam
        ret 
        
    .ELSEIF eax == MUISPM_GETTOTALPANELS
        Invoke MUIGetIntProperty, hWin, @SmartPanelTotalPanels
        ret
    
    .ELSEIF eax == MUISPM_NEXTPANEL
        Invoke MUISmartPanelNextPanel, hWin, wParam
        ret
        
    .ELSEIF eax == MUISPM_PREVPANEL
        Invoke MUISmartPanelPrevPanel, hWin, wParam
        ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_SmartPanelWndProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelInit - set initial default values
;------------------------------------------------------------------------------
_MUI_SmartPanelInit PROC USES EBX hWin:DWORD 
    LOCAL dwStyle:DWORD
    LOCAL dwExStyle:DWORD
    LOCAL hParent:DWORD
    LOCAL hdc:DWORD
    LOCAL hDCMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, DS_CONTROL or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != DS_CONTROL or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, DS_CONTROL or WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
    
    Invoke GetWindowLong, hWin, GWL_EXSTYLE
    mov dwExStyle, eax
    and eax, WS_EX_CONTROLPARENT
    .IF eax != WS_EX_CONTROLPARENT
        mov eax, dwExStyle
        or eax, WS_EX_CONTROLPARENT
        mov dwExStyle, eax
        Invoke SetWindowLong, hWin, GWL_EXSTYLE, dwExStyle
    .ENDIF
    ;PrintDec dwStyle
    
    ; Set default initial internal property values     
    Invoke MUISetIntProperty, hWin, @SmartPanelCurrentPanel, -1
    Invoke MUISetIntProperty, hWin, @SmartPanelTotalPanels, 0
    Invoke MUISetIntProperty, hWin, @SmartPanelPanelsArray, 0
    Invoke MUISetIntProperty, hWin, @SmartPanellpdwIsDlgMsgVar, 0
    
    ; Set default initial external property values
    Invoke MUISetExtProperty, hWin, @SmartPanelPanelsColor, -1
    Invoke MUISetExtProperty, hWin, @SmartPanelBorderColor, -1
    Invoke MUISetExtProperty, hWin, @SmartPanelDllInstance, 0
    
;    Invoke MUIGetParentBackgroundColor, hControl
;    .IF eax == -1
;    
;        PrintText 'Get parent background'
;    
;        Invoke GetParent, hControl
;        mov hParent, eax
;        
;        Invoke GetDC, hParent
;        mov hdc, eax
;    
;        Invoke CreateCompatibleDC, hdc
;        mov hDCMem, eax        
;        
;        Invoke GetWindowRect, hControl, Addr rect
;        mov eax, rect.right
;        mov ebx, rect.left
;        sub eax, ebx
;        mov dwWidth, eax
;        
;        mov eax, rect.bottom
;        mov ebx, rect.top
;        sub eax, ebx
;        mov dwHeight, eax
;        
;        Invoke CreateCompatibleBitmap, hdc, dwWidth, dwHeight
;        mov hBitmap, eax
;        
;        Invoke SelectObject, hDCMem, hBitmap
;        mov hOldBitmap, eax        
;        
;        mov eax, rect.left
;        mov pt.x, eax
;        mov eax, rect.top
;        mov pt.y, eax
;        
;        Invoke ScreenToClient, hParent, Addr pt
;        
;        Invoke BitBlt, hDCMem, 0, 0, dwWidth, dwHeight, hdc, pt.x, pt.y, SRCCOPY
;        
;        Invoke SelectObject, hDCMem, hOldBitmap
;    
;        Invoke DeleteDC, hDCMem        
;        
;        Invoke ReleaseDC, hParent, hdc
;        PrintDec hBitmap
;        Invoke MUISetIntProperty, hControl, @SmartPanelBitmap, hBitmap
;        
;    .ENDIF
    
    
    ret

_MUI_SmartPanelInit ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelCleanup - cleanup a few things before control is destroyed
;------------------------------------------------------------------------------
_MUI_SmartPanelCleanup PROC PRIVATE hWin:DWORD
    LOCAL TotalItems:DWORD

    Invoke MUIGetIntProperty, hWin, @SmartPanelTotalPanels
    mov TotalItems, eax

    .IF TotalItems != 0
        Invoke MUIGetIntProperty, hWin, @SmartPanelPanelsArray
        ;mov pItemData, eax
        .IF eax != NULL
            Invoke GlobalFree, eax
        .ENDIF
    .ENDIF
    
    mov eax, 0
    ret

_MUI_SmartPanelCleanup ENDP


MUI_ALIGN
;;------------------------------------------------------------------------------
;; _MUI_SmartPanelPaint - 
;;------------------------------------------------------------------------------
;_MUI_SmartPanelPaint PROC hWin:DWORD
;    LOCAL ps:PAINTSTRUCT 
;    LOCAL rect:RECT
;    LOCAL hdc:HDC
;    LOCAL hdcMem:DWORD
;    LOCAL hBitmap:DWORD
;    LOCAL hbmOld:DWORD
;
;    Invoke BeginPaint, hWin, Addr ps
;    mov hdc, eax
;
;    Invoke MUIGetIntProperty, hWin, @SmartPanelBitmap
;    mov hBitmap, eax
;    
;    .IF eax != 0
;
;        Invoke GetClientRect, hWin, Addr rect
;
;        Invoke CreateCompatibleDC, hdc
;        mov hdcMem, eax
;        Invoke SelectObject, hdcMem, hBitmap
;        mov hbmOld, eax
;
;        Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY
;
;        Invoke SelectObject, hdcMem, hbmOld
;        Invoke DeleteDC, hdcMem
;        .IF hbmOld != 0
;            Invoke DeleteObject, hbmOld
;        .ENDIF
;
;    .ENDIF
;
;    Invoke EndPaint, hWin, Addr ps
;    ret
;
;_MUI_SmartPanelPaint ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelRegisterPanel - Creates the panel dialog and saves the handle 
; in the MUISP_ITEM. Returns handle of dialog in eax
;------------------------------------------------------------------------------
MUISmartPanelRegisterPanel PROC PRIVATE USES EBX hControl:DWORD, idPanelDlg:DWORD, lpdwPanelProc:DWORD
    LOCAL hinstance:DWORD
    LOCAL hPanelDlg:DWORD
    LOCAL rect:RECT
    LOCAL pItemData:DWORD
    LOCAL pItemDataEntry:DWORD
    LOCAL TotalItems:DWORD
    LOCAL uIdSubclass:DWORD

    Invoke MUIGetExtProperty, hControl, @SmartPanelDllInstance
    .IF eax == 0
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    Invoke MUIGetIntProperty, hControl, @SmartPanelTotalPanels
    mov TotalItems, eax
    Invoke MUIGetIntProperty, hControl, @SmartPanelPanelsArray
    mov pItemData, eax
    
    Invoke CreateDialogParam, hinstance, idPanelDlg, hControl, lpdwPanelProc, 0
    .IF eax == NULL
        mov eax, NULL
        ret
    .ENDIF
    mov hPanelDlg, eax
    
    Invoke MUIAllocStructureMemory, Addr pItemData, TotalItems, SIZEOF MUISP_ITEM
    .IF eax == -1
        mov eax, NULL
        ret
    .ENDIF
    mov pItemDataEntry, eax
    
    mov ebx, pItemDataEntry
    mov eax, hPanelDlg
    mov [ebx].MUISP_ITEM.hPanel, eax
    mov eax, TotalItems
    mov [ebx].MUISP_ITEM.iItem, eax
    ;mov eax, lParam
    ;mov [ebx].MUISP_ITEM.lParam, eax   
    
    inc TotalItems
    Invoke MUISetIntProperty, hControl, @SmartPanelTotalPanels, TotalItems
    Invoke MUISetIntProperty, hControl, @SmartPanelPanelsArray, pItemData
        
    ;Invoke SetWindowLongPtr, hPanelDlg, GWL_EXSTYLE, WS_EX_CONTROLPARENT    
    Invoke SetWindowLongPtr, hPanelDlg, GWL_STYLE, WS_CHILD or DS_CONTROL or WS_CLIPCHILDREN; 40000000d ; WS_CHILD
    Invoke SetWindowPos, hPanelDlg, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED ; 
    Invoke GetClientRect, hControl, Addr rect
    ;sub rect.right, 2d
    ;sub rect.bottom, 2d
    Invoke SetWindowPos, hPanelDlg, HWND_TOP, 0, 0, rect.right, rect.bottom, SWP_NOZORDER ;+ SWP_NOMOVE

    Invoke MUIGetIntProperty, hControl, @SPSubclassCounter
    mov uIdSubclass, eax
    Invoke SetWindowSubclass, hPanelDlg, Addr _MUI_SP_DialogSubClassProc, uIdSubclass, hControl
    inc uIdSubclass
    Invoke MUISetIntProperty, hControl, @SPSubclassCounter, uIdSubclass

    mov eax, hPanelDlg
    ret

MUISmartPanelRegisterPanel endp


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SP_DialogSubClassProc - SUBCLASS of Registered panel (Dialog) for 
; painting panel back color
;------------------------------------------------------------------------------
_MUI_SP_DialogSubClassProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM, uIdSubclass:UINT, dwRefData:DWORD
    LOCAL dwBackColor:DWORD
    
    mov eax, uMsg
    .IF eax == WM_NCDESTROY
        Invoke RemoveWindowSubclass, hWin, Addr _MUI_SP_DialogSubClassProc, uIdSubclass
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam 
        ret

    .ELSEIF eax == WM_ERASEBKGND
        Invoke MUIGetExtProperty, dwRefData, @SmartPanelPanelsColor
        .IF eax == -1
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
            ret
        .ELSE
            mov eax, 1
            ret
        .ENDIF

    .ELSEIF eax == WM_PAINT
        Invoke MUIGetExtProperty, dwRefData, @SmartPanelPanelsColor
        .IF eax == -1
            Invoke DefSubclassProc, hWin, uMsg, wParam, lParam         
            ret
        .ELSE
            mov dwBackColor, eax
            Invoke _MUI_SP_DialogPaintBackground, hWin, dwBackColor
            ret
        .ENDIF    

    .ELSE
        Invoke DefSubclassProc, hWin, uMsg, wParam, lParam
    .ENDIF

    ret    

_MUI_SP_DialogSubClassProc ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SP_DialogPaintBackground
;------------------------------------------------------------------------------
_MUI_SP_DialogPaintBackground PROC hWin:DWORD, dwBackColor:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD    

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Get some property values
    ;---------------------------------------------------------- 
    Invoke GetClientRect, hWin, Addr rect

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
    ; Fill background
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, dwBackColor
    Invoke FillRect, hdcMem, Addr rect, hBrush

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
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem
    
    Invoke EndPaint, hWin, Addr ps

    ret

_MUI_SP_DialogPaintBackground ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelGetCurrentPanel - Returns in eax the handle of the current panel
; or NULL
;------------------------------------------------------------------------------
MUISmartPanelGetCurrentPanel PROC hControl:DWORD
    Invoke MUIGetIntProperty, hControl, @SmartPanelCurrentPanel
    Invoke _MUI_SmartPanelGetPanelHandle, hControl, eax
    ret
MUISmartPanelGetCurrentPanel ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelSetCurrentPanel - Returns the index of the previously selected 
; panel if successful or - 1 otherwise.
;------------------------------------------------------------------------------
MUISmartPanelSetCurrentPanel PROC PRIVATE USES EBX hControl:DWORD, NewSelection:DWORD, dwNotify:DWORD
    LOCAL OldSelection:DWORD
    LOCAL TotalItems:DWORD
    LOCAL hNewSelection:DWORD
    LOCAL hOldSelection:DWORD
    LOCAL rect:RECT

    Invoke MUIGetIntProperty, hControl, @SmartPanelTotalPanels
    mov TotalItems, eax
    .IF TotalItems == 0
        mov eax, -1
        ret
    .ENDIF
    
    mov eax, NewSelection
    mov ebx, TotalItems
    dec ebx
    .IF sdword ptr eax < 0 || eax > ebx
        mov eax, -1
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @SmartPanelCurrentPanel
    mov OldSelection, eax
    .IF OldSelection == -1 ; no current item set yet, so select new item regardless
        Invoke _MUI_SmartPanelGetPanelHandle, hControl, NewSelection
        mov hNewSelection, eax
        Invoke GetClientRect, hControl, Addr rect
        ;sub rect.right, 2d
        ;sub rect.bottom, 2d
        Invoke SetWindowPos, hNewSelection, HWND_TOP, 0, 0, rect.right, rect.bottom, SWP_NOZORDER ;+ SWP_NOMOVE                         
        Invoke ShowWindow, hNewSelection, SW_SHOWDEFAULT
        
        Invoke MUISetIntProperty, hControl, @SmartPanelCurrentPanel, NewSelection

        Invoke MUIGetIntProperty, hControl, @SmartPanellpdwIsDlgMsgVar
        .IF eax != NULL
            mov ebx, hNewSelection
            mov [eax], ebx
        .ENDIF        
        mov eax, NewSelection
        ret
    .ENDIF
    
    mov eax, OldSelection
    mov ebx, NewSelection
    .IF eax != ebx
    
        Invoke _MUI_SmartPanelGetPanelHandle, hControl, OldSelection
        mov hOldSelection, eax

        Invoke _MUI_SmartPanelGetPanelHandle, hControl, NewSelection
        mov hNewSelection, eax
        
        
        ; call slide panels function if specified
        Invoke GetWindowLong, hControl, GWL_STYLE
        ;mov dwStyle, eax
        AND eax, MUISPS_SLIDEPANELS_SLOW + MUISPS_SLIDEPANELS_NORMAL + MUISPS_SLIDEPANELS_FAST + MUISPS_SLIDEPANELS_VFAST
        .IF eax == MUISPS_SLIDEPANELS_SLOW
            Invoke _MUI_SmartPanelSlidePanels, hControl, OldSelection, NewSelection, SlideSlow

        .ELSEIF eax == MUISPS_SLIDEPANELS_NORMAL
            Invoke _MUI_SmartPanelSlidePanels, hControl, OldSelection, NewSelection, SlideNormal
        
        .ELSEIF eax == MUISPS_SLIDEPANELS_FAST
            Invoke _MUI_SmartPanelSlidePanels, hControl, OldSelection, NewSelection, SlideFast
            
        .ELSEIF eax == MUISPS_SLIDEPANELS_VFAST
            Invoke _MUI_SmartPanelSlidePanels, hControl, OldSelection, NewSelection, SlideVFast
            
        .ELSE ; if style is not animation
            .IF hOldSelection != NULL
                Invoke ShowWindow, hOldSelection, SW_HIDE
            .ENDIF        
            .IF hNewSelection != NULL
                ; resize panel if container size has changed since last selection
                Invoke GetClientRect, hControl, Addr rect
                ;sub rect.right, 2d
                ;sub rect.bottom, 2d
                Invoke SetWindowPos, hNewSelection, HWND_TOP, 0, 0, rect.right, rect.bottom, SWP_NOZORDER ;+ SWP_NOMOVE                         
                
                Invoke ShowWindow, hNewSelection, SW_SHOWDEFAULT
                Invoke SetFocus, hNewSelection
            .ENDIF
        .ENDIF
        
        ; update current panel internally AND externally if user provided a var to hold this.
        Invoke MUISetIntProperty, hControl, @SmartPanelCurrentPanel, NewSelection

        Invoke MUIGetIntProperty, hControl, @SmartPanellpdwIsDlgMsgVar
        .IF eax != NULL
            mov ebx, hNewSelection
            mov [eax], ebx
        .ENDIF
        
        ; Notify if user has specified so
        .IF dwNotify == TRUE
            Invoke _MUI_SmartPanelNavNotify, hControl, OldSelection, NewSelection
        .ENDIF
        
        mov eax, OldSelection    
    .ELSE
        mov eax, -1
    .ENDIF
    ret
MUISmartPanelSetCurrentPanel ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelNavNotify
;------------------------------------------------------------------------------
_MUI_SmartPanelNavNotify PROC PRIVATE USES EBX hWin:DWORD, OldSelection:DWORD, NewSelection:DWORD
    LOCAL pItemData:DWORD
    LOCAL pOldItemDataEntry:DWORD
    LOCAL pNewItemDataEntry:DWORD
    LOCAL TotalItems:DWORD
    LOCAL hItem:DWORD
    LOCAL ItemIndex:DWORD
    LOCAL hParent:DWORD
    LOCAL idControl:DWORD
    
    Invoke GetParent, hWin
    mov hParent, eax

    mov eax, hWin
    mov SPNM.hdr.hwndFrom, eax
    mov eax, MUISPN_SELCHANGED
    mov SPNM.hdr.code, eax
    
    Invoke MUIGetIntProperty, hWin, @SmartPanelPanelsArray
    mov pItemData, eax
    
    mov eax, OldSelection
    mov ebx, SIZEOF MUISP_ITEM
    mul ebx
    mov ebx, pItemData
    add eax, ebx
    mov pOldItemDataEntry, eax
    
    mov eax, NewSelection
    mov ebx, SIZEOF MUISP_ITEM
    mul ebx
    mov ebx, pItemData
    add eax, ebx
    mov pNewItemDataEntry, eax    
        
    mov ebx, pOldItemDataEntry
    mov eax, [ebx].MUISP_ITEM.iItem
    mov SPNM.itemOld.iItem, eax
    mov eax, [ebx].MUISP_ITEM.lParam
    mov SPNM.itemOld.lParam, eax
    mov eax, [ebx].MUISP_ITEM.hPanel
    mov SPNM.itemNew.hPanel, eax    
    
    mov ebx, pNewItemDataEntry
    mov eax, [ebx].MUISP_ITEM.iItem
    mov SPNM.itemNew.iItem, eax
    mov eax, [ebx].MUISP_ITEM.lParam
    mov SPNM.itemNew.lParam, eax
    mov eax, [ebx].MUISP_ITEM.hPanel
    mov SPNM.itemNew.hPanel, eax
    
    Invoke GetDlgCtrlID, hWin
    mov idControl, eax
    
    Invoke GetParent, hParent
    .IF eax != NULL
        Invoke PostMessage, hParent, WM_NOTIFY, idControl, Addr SPNM
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret

_MUI_SmartPanelNavNotify endp


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelSlidePanels - SlideSpeed 0 slow, 1 fast, 2 very fast
;------------------------------------------------------------------------------
_MUI_SmartPanelSlidePanels PROC PRIVATE USES EBX hWin:DWORD, OldSelection:DWORD, NewSelection:DWORD, SlideSpeed:DWORD 
    LOCAL hCurrentPanel:DWORD
    LOCAL hNextPanel:DWORD
    LOCAL nPanel:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, MUISPS_SPS_SKIPBETWEEN
    .IF eax == MUISPS_SPS_SKIPBETWEEN

        Invoke _MUI_SmartPanelGetPanelHandle, hWin, OldSelection
        mov hCurrentPanel, eax
        
        Invoke _MUI_SmartPanelGetPanelHandle, hWin, NewSelection
        mov hNextPanel, eax

        mov eax, NewSelection
        .IF eax < OldSelection ; moving down = left, so slide right 
            Invoke _MUI_SmartPanelSlidePanelsRight, hWin, hCurrentPanel, hNextPanel, SlideSpeed
        .ELSE ; moving up = right, so slide left   
            Invoke _MUI_SmartPanelSlidePanelsLeft, hWin, hCurrentPanel, hNextPanel, SlideSpeed
        .ENDIF

    .ELSE
        
        mov eax, NewSelection
        .IF eax < OldSelection ; moving down = left, so slide right till we get to it
            
            mov eax, OldSelection
            mov nPanel, eax
            .WHILE eax > NewSelection
        
                Invoke _MUI_SmartPanelGetPanelHandle, hWin, nPanel
                mov hCurrentPanel, eax
                mov eax, nPanel
                dec eax
                Invoke _MUI_SmartPanelGetPanelHandle, hWin, eax
                mov hNextPanel, eax
                
                Invoke _MUI_SmartPanelSlidePanelsRight, hWin, hCurrentPanel, hNextPanel, SlideSpeed
                dec nPanel
                mov eax, nPanel
            .ENDW
        
        .ELSE ; moving up = right, so slide left till we get to it
            
            mov eax, OldSelection     
            mov nPanel, eax
            .WHILE eax < NewSelection
        
                Invoke _MUI_SmartPanelGetPanelHandle, hWin, nPanel
                mov hCurrentPanel, eax
                mov eax, nPanel
                inc eax
                Invoke _MUI_SmartPanelGetPanelHandle, hWin, eax
                mov hNextPanel, eax
                
                Invoke _MUI_SmartPanelSlidePanelsLeft, hWin, hCurrentPanel, hNextPanel, SlideSpeed
                inc nPanel
                mov eax, nPanel
            .ENDW
            
        .ENDIF
        
    .ENDIF
    ret
_MUI_SmartPanelSlidePanels endp


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelSlidePanelsLeft - Slides current and next panel left till we 
; show next panel only
;------------------------------------------------------------------------------
_MUI_SmartPanelSlidePanelsLeft PROC hWin:DWORD, hCurrentPanel:DWORD, hNextPanel:DWORD, SlideSpeed:DWORD
    LOCAL rect:RECT
    LOCAL xposnextpanel:SDWORD
    LOCAL xposcurrentpanel:SDWORD    
    
    IFDEF DEBUG32
    PrintText 'SP_SlidePanelsLeft'
    ENDIF
    Invoke GetClientRect, hWin, Addr rect
    mov eax, rect.right
    mov xposnextpanel, eax
    mov xposcurrentpanel, 1
    Invoke SetWindowPos, hNextPanel, HWND_TOP, xposnextpanel, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER + SWP_NOCOPYBITS +SWP_SHOWWINDOW + SWP_NOSENDCHANGING+ SWP_NOACTIVATE ;+SWP_NOCOPYBITS +

    mov eax, xposnextpanel
    .WHILE sdword ptr eax > 0
        Invoke SetWindowPos, hNextPanel, HWND_TOP, xposnextpanel, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER  + SWP_NOSENDCHANGING + SWP_NOACTIVATE;+ SWP_NOMOVE +SWP_NOCOPYBITS
        Invoke SetWindowPos, hCurrentPanel, HWND_TOP, xposcurrentpanel, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER  + SWP_NOSENDCHANGING + SWP_NOACTIVATE;+ SWP_NOMOVE +SWP_NOCOPYBITS
        ;Invoke InvalidateRect, hNextPanel, NULL, TRUE
        
        Invoke UpdateWindow, hNextPanel
        ;Invoke UpdateWindow, hCurrentPanel            
        .IF SlideSpeed == SlideVFast
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
        .ELSEIF SlideSpeed == SlideFast
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
        .ELSEIF SlideSpeed == SlideNormal
            dec xposcurrentpanel
            dec xposnextpanel
            dec xposcurrentpanel
            dec xposnextpanel
        .ELSE
            dec xposcurrentpanel
            dec xposnextpanel
        .ENDIF
        ;dec xposcurrentpanel
        ;dec xposnextpanel
        ;PrintDec xposnextpanel
        mov eax, xposnextpanel
    .ENDW
    
    ;PrintText 'SP_SlidePanelsLeft End'
    
    Invoke ShowWindow, hCurrentPanel, SW_HIDE
    Invoke SetWindowPos, hNextPanel, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER + SWP_NOSENDCHANGING + SWP_NOACTIVATE ;+ SWP_NOMOVE  +SWP_NOCOPYBITS
    Invoke ShowWindow, hNextPanel, SW_SHOWDEFAULT
    Invoke SetFocus, hNextPanel    
    
    ;Invoke InvalidateRect, hNextPanel, NULL, TRUE
    ;Invoke UpdateWindow, hNextPanel
    ret

_MUI_SmartPanelSlidePanelsLeft endp


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelSlidePanelsRight - Slides current and next panel right till we 
; show next panel only
;------------------------------------------------------------------------------
_MUI_SmartPanelSlidePanelsRight PROC hWin:DWORD, hCurrentPanel:DWORD, hNextPanel:DWORD, SlideSpeed:DWORD
    LOCAL rect:RECT
    LOCAL xposnextpanel:SDWORD
    LOCAL xposcurrentpanel:SDWORD
    
    IFDEF DEBUG32
    PrintText 'SP_SlidePanelsRight'
    ENDIF
    Invoke GetClientRect, hWin, Addr rect
    mov eax, 0
    sub eax, rect.right ;sdword ptr sdword ptr 
    mov xposnextpanel, eax ;-570
    mov xposcurrentpanel, 1
    Invoke SetWindowPos, hNextPanel, HWND_TOP, xposnextpanel, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER + SWP_NOCOPYBITS +SWP_SHOWWINDOW + SWP_NOSENDCHANGING+ SWP_NOACTIVATE ; +SWP_NOCOPYBITS + 
    
    mov eax, xposnextpanel
    .WHILE sdword ptr eax < 1
        Invoke SetWindowPos, hNextPanel, HWND_TOP, xposnextpanel, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER + SWP_NOSENDCHANGING + SWP_NOACTIVATE ;+ SWP_NOMOVE  +SWP_NOCOPYBITS
        Invoke SetWindowPos, hCurrentPanel, HWND_TOP, xposcurrentpanel, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER  + SWP_NOSENDCHANGING + SWP_NOACTIVATE;+ SWP_NOMOVE +SWP_NOCOPYBITS
        ;Invoke InvalidateRect, hNextPanel, NULL, TRUE

        Invoke UpdateWindow, hNextPanel
        ;Invoke UpdateWindow, hCurrentPanel
        .IF SlideSpeed == SlideVFast
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel                    
        .ELSEIF SlideSpeed == SlideFast
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel
        .ELSEIF SlideSpeed == SlideNormal
            inc xposcurrentpanel
            inc xposnextpanel
            inc xposcurrentpanel
            inc xposnextpanel
        .ELSE
            inc xposcurrentpanel
            inc xposnextpanel
        .ENDIF
        ;PrintDec xposnextpanel
        mov eax, xposnextpanel
    .ENDW
    
    ;PrintText 'SP_SlidePanelsRight End'
    
    Invoke ShowWindow, hCurrentPanel, SW_HIDE
    Invoke SetWindowPos, hNextPanel, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE + SWP_NOZORDER + SWP_NOSENDCHANGING + SWP_NOACTIVATE ;+ SWP_NOMOVE  +SWP_NOCOPYBITS  
    Invoke ShowWindow, hNextPanel, SW_SHOWDEFAULT
    Invoke SetFocus, hNextPanel
    
    ;Invoke InvalidateRect, hNextPanel, NULL, TRUE
    ;Invoke UpdateWindow, hNextPanel    
    ret

_MUI_SmartPanelSlidePanelsRight endp


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelNextPanel - returns previous panel selected in eax or -1 if 
; nothing happening
;------------------------------------------------------------------------------
MUISmartPanelNextPanel PROC PRIVATE USES EBX hControl:DWORD, dwNotify:DWORD
    LOCAL OldSelection:DWORD
    LOCAL NewSelection:DWORD
    LOCAL TotalItems:DWORD
    LOCAL hItem:DWORD
    LOCAL hNewSelection:DWORD
    LOCAL hOldSelection:DWORD
    LOCAL rect:RECT
    LOCAL SlideSpeed:DWORD
    LOCAL dwStyle:DWORD
    
    ;PrintText 'SP_NextPanel'
    
    Invoke MUIGetIntProperty, hControl, @SmartPanelTotalPanels
    mov TotalItems, eax
    .IF TotalItems < 2 ; == 0
        mov eax, -1
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @SmartPanelCurrentPanel
    mov OldSelection, eax

    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax
    
    inc eax ; for adjust of 0 based index
    .IF eax == TotalItems
        mov eax, dwStyle
        AND eax, MUISPS_SPS_WRAPAROUND
        .IF eax == MUISPS_SPS_WRAPAROUND
            mov NewSelection, 0
        .ELSE
            mov eax, OldSelection
            ret
        .ENDIF
    .ELSE
        mov eax, OldSelection
        inc eax
        mov NewSelection, eax
    .ENDIF
    
    Invoke _MUI_SmartPanelGetPanelHandle, hControl, OldSelection
    mov hOldSelection, eax

    Invoke _MUI_SmartPanelGetPanelHandle, hControl, NewSelection
    mov hNewSelection, eax
    
    ; call slide panels function if specified
    mov eax, dwStyle
    AND eax, MUISPS_SLIDEPANELS_SLOW + MUISPS_SLIDEPANELS_NORMAL + MUISPS_SLIDEPANELS_FAST + MUISPS_SLIDEPANELS_VFAST
    .IF eax == 0 ; if style is not animation
        .IF hOldSelection != NULL
            Invoke ShowWindow, hOldSelection, SW_HIDE
        .ENDIF        
        .IF hNewSelection != NULL
            ; resize panel if container size has changed since last selection
            Invoke GetClientRect, hControl, Addr rect
            Invoke SetWindowPos, hNewSelection, HWND_TOP, 0, 0, rect.right, rect.bottom, SWP_NOZORDER ;+ SWP_NOMOVE                         
            Invoke ShowWindow, hNewSelection, SW_SHOWDEFAULT
        .ENDIF
    .ELSE
        mov eax, dwStyle
        AND eax, MUISPS_SLIDEPANELS_SLOW + MUISPS_SLIDEPANELS_NORMAL + MUISPS_SLIDEPANELS_FAST + MUISPS_SLIDEPANELS_VFAST
        .IF eax == MUISPS_SLIDEPANELS_SLOW
            mov eax, SlideSlow
        .ENDIF    
        .IF eax == MUISPS_SLIDEPANELS_NORMAL
            mov eax, SlideNormal
        .ENDIF
        .IF eax == MUISPS_SLIDEPANELS_FAST
            mov eax, SlideFast
        .ENDIF    
        .IF eax == MUISPS_SLIDEPANELS_VFAST
            mov eax, SlideVFast
        .ENDIF
         mov SlideSpeed, eax
         
         Invoke _MUI_SmartPanelSlidePanelsLeft, hControl, hOldSelection, hNewSelection, SlideSpeed

    .ENDIF
    
    ; update current panel internally AND externally if user provided a var to hold this.
    Invoke MUISetIntProperty, hControl, @SmartPanelCurrentPanel, NewSelection

    Invoke MUIGetIntProperty, hControl, @SmartPanellpdwIsDlgMsgVar
    .IF eax != NULL
        mov ebx, hNewSelection
        mov [eax], ebx
    .ENDIF
   
    ; Notify if user has specified so
    .IF dwNotify == TRUE
        Invoke _MUI_SmartPanelNavNotify, hControl, OldSelection, NewSelection
    .ENDIF
    mov eax, OldSelection
    ret
MUISmartPanelNextPanel ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelPrevPanel - returns previous panel selected in eax or -1 if 
; nothing happening
;------------------------------------------------------------------------------
MUISmartPanelPrevPanel PROC PRIVATE USES EBX hControl:DWORD, dwNotify:DWORD
    LOCAL OldSelection:DWORD
    LOCAL NewSelection:DWORD
    LOCAL TotalItems:DWORD
    LOCAL hItem:DWORD
    LOCAL hNewSelection:DWORD
    LOCAL hOldSelection:DWORD
    LOCAL rect:RECT
    LOCAL SlideSpeed:DWORD
    LOCAL dwStyle:DWORD

    ;PrintText 'SP_PrevPanel'

    Invoke MUIGetIntProperty, hControl, @SmartPanelTotalPanels
    mov TotalItems, eax
    .IF TotalItems < 2 ; == 0
        mov eax, -1
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hControl, @SmartPanelCurrentPanel
    mov OldSelection, eax
    
    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax    
    
    .IF eax == 0
        mov eax, dwStyle
        AND eax, MUISPS_SPS_WRAPAROUND
        .IF eax == MUISPS_SPS_WRAPAROUND
            mov eax, TotalItems     
            dec eax ; for adjust of 0 based index
            mov NewSelection, eax
        .ELSE
            mov eax, 0 ;OldSelection
            ret
        .ENDIF
    .ELSE
        mov eax, OldSelection
        dec eax
        mov NewSelection, eax
    .ENDIF
    
    Invoke _MUI_SmartPanelGetPanelHandle, hControl, OldSelection
    mov hOldSelection, eax

    Invoke _MUI_SmartPanelGetPanelHandle, hControl, NewSelection
    mov hNewSelection, eax
   
    ; call slide panels function if specified
    mov eax, dwStyle
    AND eax, MUISPS_SLIDEPANELS_SLOW + MUISPS_SLIDEPANELS_NORMAL + MUISPS_SLIDEPANELS_FAST + MUISPS_SLIDEPANELS_VFAST
    .IF eax == 0 ; if style is not animation
        .IF hOldSelection != NULL
            Invoke ShowWindow, hOldSelection, SW_HIDE
        .ENDIF        
        .IF hNewSelection != NULL
            ; resize panel if container size has changed since last selection
            Invoke GetClientRect, hControl, Addr rect
            Invoke SetWindowPos, hNewSelection, HWND_TOP, 0, 0, rect.right, rect.bottom, SWP_NOZORDER ;+ SWP_NOMOVE                         
            Invoke ShowWindow, hNewSelection, SW_SHOWDEFAULT
        .ENDIF
    .ELSE
        mov eax, dwStyle
        AND eax, MUISPS_SLIDEPANELS_SLOW + MUISPS_SLIDEPANELS_NORMAL + MUISPS_SLIDEPANELS_FAST + MUISPS_SLIDEPANELS_VFAST
        .IF eax == MUISPS_SLIDEPANELS_SLOW
            mov eax, SlideSlow
        .ENDIF    
        .IF eax == MUISPS_SLIDEPANELS_NORMAL
            mov eax, SlideNormal
        .ENDIF
        .IF eax == MUISPS_SLIDEPANELS_FAST
            mov eax, SlideFast
        .ENDIF    
        .IF eax == MUISPS_SLIDEPANELS_VFAST
            mov eax, SlideVFast
        .ENDIF
         mov SlideSpeed, eax
         
         Invoke _MUI_SmartPanelSlidePanelsRight, hControl, hOldSelection, hNewSelection, SlideSpeed

    .ENDIF
    
    ; update current panel internally AND externally if user provided a var to hold this.
    Invoke MUISetIntProperty, hControl, @SmartPanelCurrentPanel, NewSelection

    Invoke MUIGetIntProperty, hControl, @SmartPanellpdwIsDlgMsgVar
    .IF eax != NULL
        mov ebx, hNewSelection
        mov [eax], ebx
    .ENDIF
   
    ; Notify if user has specified so
    .IF dwNotify == TRUE
        Invoke _MUI_SmartPanelNavNotify, hControl, OldSelection, NewSelection
    .ENDIF
    mov eax, OldSelection
    ret

MUISmartPanelPrevPanel ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelSetIsDlgMsgVar
;------------------------------------------------------------------------------
MUISmartPanelSetIsDlgMsgVar PROC hControl:DWORD, lpdwIsDlgMsgVar:DWORD
    Invoke MUISetIntProperty, hControl, @SmartPanellpdwIsDlgMsgVar, lpdwIsDlgMsgVar
    ret
MUISmartPanelSetIsDlgMsgVar ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SmartPanelGetPanelHandle, returns in eax handle or NULL if error
;------------------------------------------------------------------------------
_MUI_SmartPanelGetPanelHandle PROC PRIVATE USES EBX hWin:DWORD, nItem:DWORD
    LOCAL TotalItems:DWORD
    LOCAL pItemData:DWORD
    LOCAL pItemDataEntry:DWORD
    
    .IF nItem == -1
        mov eax, NULL
        ret
    .ENDIF
    
    Invoke MUIGetIntProperty, hWin, @SmartPanelTotalPanels
    mov TotalItems, eax
    .IF TotalItems == 0
        mov eax, NULL
        ret
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @SmartPanelPanelsArray
    mov pItemData, eax

    mov eax, nItem
    mov ebx, SIZEOF MUISP_ITEM
    mul ebx
    mov ebx, pItemData
    add eax, ebx
    mov pItemDataEntry, eax
    mov ebx, pItemDataEntry
    mov eax, [ebx].MUISP_ITEM.hPanel
    ret

_MUI_SmartPanelGetPanelHandle endp


MUI_ALIGN
;------------------------------------------------------------------------------
; MUISmartPanelCurrentPanelIndex - returns current selected panel as a 
; numerical index in eax, or -1 if error.
;------------------------------------------------------------------------------
MUISmartPanelCurrentPanelIndex PROC PUBLIC hControl:DWORD
    Invoke MUIGetIntProperty, hControl, @SmartPanelCurrentPanel
    ret
MUISmartPanelCurrentPanelIndex ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; _MUI_SP_ResizePanels - Resize panels to match SmartPanel size
;------------------------------------------------------------------------------
_MUI_SP_ResizePanels PROC USES EBX hWin:DWORD
    LOCAL rect:RECT
    LOCAL hPanelDlg:DWORD
    LOCAL dwTotalPanels:DWORD
    LOCAL pItemData:DWORD
    LOCAL pItemDataEntry:DWORD
    LOCAL hDefer:DWORD
    LOCAL nCurrentPanel:DWORD
    
    ; check if size hasnt been sent at init, before properties can be checked?
    ; check if sliding currently?
    
    Invoke MUIGetIntProperty, hWin, @SmartPanelTotalPanels
    mov dwTotalPanels, eax
    .IF dwTotalPanels == 0
        xor eax, eax
        ret
    .ENDIF

    Invoke MUIGetIntProperty, hWin, @SmartPanelPanelsArray
    mov pItemData, eax
    mov pItemDataEntry, eax
    
    Invoke GetClientRect, hWin, Addr rect

    Invoke BeginDeferWindowPos, dwTotalPanels
    mov hDefer, eax
    
    mov nCurrentPanel, 0
    mov eax, 0
    .WHILE eax < dwTotalPanels
        mov ebx, pItemDataEntry
        mov eax, [ebx].MUISP_ITEM.hPanel
        mov hPanelDlg, eax
        
        .IF hDefer == NULL
            Invoke SetWindowPos, hPanelDlg, NULL, 0, 0, rect.right, rect.bottom, SWP_NOZORDER or SWP_NOOWNERZORDER  or SWP_NOACTIVATE or SWP_NOMOVE ;or SWP_NOSENDCHANGING ;or SWP_NOCOPYBITS
        .ELSE
            Invoke DeferWindowPos, hDefer, hPanelDlg, NULL, 0, 0, rect.right, rect.bottom, SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOACTIVATE or SWP_NOMOVE ;or SWP_NOSENDCHANGING
            mov hDefer, eax
        .ENDIF
        
        add pItemDataEntry, SIZEOF MUISP_ITEM
        inc nCurrentPanel
        mov eax, nCurrentPanel
    .ENDW
    
    .IF hDefer != NULL
        Invoke EndDeferWindowPos, hDefer
    .ENDIF      

    xor eax, eax
    ret

_MUI_SP_ResizePanels ENDP













END
