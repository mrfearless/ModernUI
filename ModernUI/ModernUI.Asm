;======================================================================================================================================
;
; ModernUI Library v1.0.0.0
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
include gdiplus.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib gdiplus.lib

include ModernUI.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUIGetProperty                  PROTO :DWORD, :DWORD, :DWORD           ; hControl, cbWndExtraOffset, dwProperty
_MUISetProperty                  PROTO :DWORD, :DWORD, :DWORD, :DWORD   ; hControl, cbWndExtraOffset, dwProperty, dwPropertyValue



;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------



.CONST



.DATA
MUI_GDIPLUS                     DD 0 ; controls that use gdiplus check this first, if 0 they call gdi startup and inc the value
                                     ; controls that use gdiplus when destroyed decrement this value and check if 0. If 0 they call gdi finish

MUI_GDIPlusToken	            DD 0
MUI_gdipsi	                    GdiplusStartupInput	<1,0,0,0>


.CODE

;======================================================================================================================================
; PRIVATE FUNCTIONS
;
; These functions are intended for use with controls created for the ModernUI framework
; even though they are PUBLIC they are prefixed with _ to indicate for internal use.
; Only ModernUI controls should call these functions directly.
;
; The exception to this is the MUIGetProperty and MUISetProperty which are for
; users of the ModernUI controls to use for getting and setting external properties.
;
;======================================================================================================================================



;-------------------------------------------------------------------------------------
; Start of ModernUI framework (wrapper for gdiplus startup)
; Placed at start of program before WinMain call
;-------------------------------------------------------------------------------------
MUIGDIPlusStart PROC PUBLIC
    .IF MUI_GDIPLUS == 0
	    Invoke GdiplusStartup, Addr MUI_GDIPlusToken, Addr MUI_gdipsi, NULL
	.ENDIF
	inc MUI_GDIPLUS
	xor eax, eax
    ret
MUIGDIPlusStart ENDP


;-------------------------------------------------------------------------------------
; Finish ModernUI framework (wrapper for gdiplus shutdown)
; Placed after WinMain call before ExitProcess
;-------------------------------------------------------------------------------------
MUIGDIPlusFinish PROC PUBLIC
    dec MUI_GDIPLUS
    .IF MUI_GDIPLUS == 0
        Invoke GdiplusShutdown, MUI_GDIPlusToken
    .ENDIF
    xor eax, eax
    ret
MUIGDIPlusFinish ENDP


;-------------------------------------------------------------------------------------
; Gets the pointer to memory allocated to control at startup and stored in cbWinExtra
; adds the offset to property to this pointer and fetches value at this location and
; returns it in eax.
; Properties are defined as constants, which are used as offsets in memory to the 
; data alloc'd
; for example: @MouseOver EQU 0, @SelectedState EQU 4
; we might specify 4 in cbWndExtra and then GlobalAlloc 8 bytes of data to control at 
; startup and store this pointer with SetWindowLong, hControl, 0, pMem
; pMem is our pointer to our 8 bytes of storage, of which first four bytes (dword) is
; used for our @MouseOver property and the next dword for @SelectedState 
; cbWndExtraOffset is usually going to be 0 for custom registered window controls
; and some other offset for superclassed window control
;-------------------------------------------------------------------------------------
_MUIGetProperty PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwProperty:DWORD
    
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    
    ret

_MUIGetProperty ENDP


;-------------------------------------------------------------------------------------
; Sets property value and returns previous value in eax.
;-------------------------------------------------------------------------------------
_MUISetProperty PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF    
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    mov dwPrevValue, eax    
    mov eax, dwPropertyValue
    mov [ebx], eax
    mov eax, dwPrevValue
    ret

_MUISetProperty ENDP


;-------------------------------------------------------------------------------------
; Allocs memory for the properties of a control
;-------------------------------------------------------------------------------------
MUIAllocMemProperties PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwSize:DWORD
    LOCAL pMem:DWORD
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, dwSize
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov pMem, eax
    
    Invoke SetWindowLong, hControl, cbWndExtraOffset, pMem
    
    mov eax, TRUE
    ret
MUIAllocMemProperties ENDP


;-------------------------------------------------------------------------------------
; Frees memory for the properties of a control
;-------------------------------------------------------------------------------------
MUIFreeMemProperties PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax != NULL
        invoke GlobalFree, eax
        Invoke SetWindowLong, hControl, cbWndExtraOffset, 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret
MUIFreeMemProperties ENDP


;======================================================================================================================================
; PUBLIC FUNCTIONS
;======================================================================================================================================


;-------------------------------------------------------------------------------------
; Gets external property value and returns it in eax
;-------------------------------------------------------------------------------------
MUIGetExtProperty PROC PUBLIC USES EBX hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, 4, dwProperty ; get external properties
    ret
MUIGetExtProperty ENDP


;-------------------------------------------------------------------------------------
; Sets external property value and returns previous value in eax.
;-------------------------------------------------------------------------------------
MUISetExtProperty PROC PUBLIC USES EBX hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, 4, dwProperty, dwPropertyValue ; set external properties
    ret
MUISetExtProperty ENDP


;-------------------------------------------------------------------------------------
; Gets internal property value and returns it in eax
;-------------------------------------------------------------------------------------
MUIGetIntProperty PROC PUBLIC USES EBX hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, 0, dwProperty ; get internal properties
    ret
MUIGetIntProperty ENDP


;-------------------------------------------------------------------------------------
; Sets internal property value and returns previous value in eax.
;-------------------------------------------------------------------------------------
MUISetIntProperty PROC PUBLIC USES EBX hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, 0, dwProperty, dwPropertyValue ; set internal properties
    ret
MUISetIntProperty ENDP


;-------------------------------------------------------------------------------------
; Convert font point size eg '12' to logical unit size for use with CreateFont,
; CreateFontIndirect
;-------------------------------------------------------------------------------------
MUIPointSizeToLogicalUnit PROC PUBLIC hWin:DWORD, dwPointSize:DWORD
    LOCAL hdc:HDC
    LOCAL dwLogicalUnit:DWORD
    
    Invoke GetDC, hWin
    mov hdc, eax
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    Invoke MulDiv, dwPointSize, eax, 72d
    mov dwLogicalUnit, eax
    Invoke ReleaseDC, hWin, hdc
    mov eax, dwLogicalUnit
    ret
MUIPointSizeToLogicalUnit ENDP
















END
