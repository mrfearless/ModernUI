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
includelib user32.lib

include kernel32.inc
includelib kernel32.lib

include gdiplus.inc
includelib gdiplus.lib

include ModernUI.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------




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
_MUIGDIPlusStart PROC PUBLIC
    .IF MUI_GDIPLUS == 0
	    Invoke GdiplusStartup, Addr MUI_GDIPlusToken, Addr MUI_gdipsi, NULL
	.ENDIF
	inc MUI_GDIPLUS

;    Invoke CreateFont, 10d, 0, 0, 0, 0, FALSE, FALSE, FALSE, SYMBOL_CHARSET, OUT_TT_ONLY_PRECIS, CLIP_DEFAULT_PRECIS, PROOF_QUALITY, FF_DONTCARE, Addr szMUISysFont
;    mov hMUISysFont, eax
	xor eax, eax
    ret
_MUIGDIPlusStart ENDP


;-------------------------------------------------------------------------------------
; Finish ModernUI framework (wrapper for gdiplus shutdown)
; Placed after WinMain call before ExitProcess
;-------------------------------------------------------------------------------------
_MUIGDIPlusFinish PROC PUBLIC
    dec MUI_GDIPLUS
    .IF MUI_GDIPLUS == 0
        Invoke GdiplusShutdown, MUI_GDIPlusToken
    .ENDIF
    xor eax, eax
    ret
_MUIGDIPlusFinish ENDP


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
_MUIAllocMemProperties PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwSize:DWORD
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
_MUIAllocMemProperties ENDP


;-------------------------------------------------------------------------------------
; Frees memory for the properties of a control
;-------------------------------------------------------------------------------------
_MUIFreeMemProperties PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax != NULL
        invoke GlobalFree, eax
        Invoke SetWindowLong, hControl, cbWndExtraOffset, 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret
_MUIFreeMemProperties ENDP


;======================================================================================================================================
; PUBLIC FUNCTIONS
;======================================================================================================================================


;-------------------------------------------------------------------------------------
; This is a public based version of the _MUIGetProperty for users of the ModernUI
; controls to use when getting the external property value
;
; Gets property value and returns it in eax
;-------------------------------------------------------------------------------------
MUIGetProperty PROC PUBLIC USES EBX hControl:DWORD, dwProperty:DWORD
    
    Invoke GetWindowLong, hControl, 4 ; external properties
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    
    ret

MUIGetProperty ENDP


;-------------------------------------------------------------------------------------
; This is a public based version of the _MUISetProperty for users of the ModernUI
; controls to use when setting external property values
;
; Sets property value and returns previous value in eax.
;-------------------------------------------------------------------------------------
MUISetProperty PROC PUBLIC USES EBX hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLong, hControl, 4
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

MUISetProperty ENDP























END
