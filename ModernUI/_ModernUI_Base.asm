;==============================================================================
;
; ModernUI Library v0.0.0.5
;
; Copyright (c) 2018 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;==============================================================================

.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include windows.inc
include user32.inc
includelib user32.lib

include ModernUI.inc


; Prototypes for internal use
_MUIGetProperty PROTO :DWORD, :DWORD, :DWORD           ; hControl, cbWndExtraOffset, dwProperty
_MUISetProperty PROTO :DWORD, :DWORD, :DWORD, :DWORD   ; hControl, cbWndExtraOffset, dwProperty, dwPropertyValue

.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets the pointer to memory allocated to control at startup and stored in 
; cbWinExtra adds the offset to property to this pointer and fetches value at 
; this location and returns it in eax.
;
; Properties are defined as constants, which are used as offsets in memory to 
; the; data alloc'd, for example: @MouseOver EQU 0, @SelectedState EQU 4
; we might specify 4 in cbWndExtra and then GlobalAlloc 8 bytes of data to 
; control at startup and store this pointer with:
; 
;   Invoke SetWindowLong, hControl, 0, pMem
;
; pMem is our pointer to our 8 bytes of storage, of which first four bytes 
; (dword) is used for our @MouseOver property and the next dword for 
; @SelectedState
; 
; Added extra option to check if dwProperty is OR'd with MUI_PROPERTY_ADDRESS
; then return address of property
;
;
;------------------------------------------------------------------------------
_MUIGetProperty PROC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwProperty:DWORD
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, dwProperty
    mov eax, dwProperty
    and eax, MUI_PROPERTY_ADDRESS
    .IF eax == MUI_PROPERTY_ADDRESS
        mov eax, ebx ; address of property in eax
    .ELSE
        mov eax, [ebx] ; contents of property at address in ebx
    .ENDIF
    ret
_MUIGetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets property value and returns previous value in eax.
;------------------------------------------------------------------------------
_MUISetProperty PROC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
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


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtProperty PROC hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_EXTERNAL_PROPERTIES, dwProperty ; get external properties
    ret
MUIGetExtProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtProperty PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, MUI_EXTERNAL_PROPERTIES, dwProperty, dwPropertyValue ; set external properties
    ret
MUISetExtProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntProperty PROC hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_INTERNAL_PROPERTIES, dwProperty ; get internal properties
    ret
MUIGetIntProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntProperty PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, MUI_INTERNAL_PROPERTIES, dwProperty, dwPropertyValue ; set internal properties
    ret
MUISetIntProperty ENDP



MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child external property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUIGetExtPropertyEx PROC hControl:DWORD, dwParentProperty:DWORD, dwChildProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_EXTERNAL_PROPERTIES, dwParentProperty ; get parent external properties
    .IF eax != 0
        add eax, dwChildProperty
        mov eax, [eax]
    .ENDIF
    ret
MUIGetExtPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child external property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUISetExtPropertyEx PROC USES EBX hControl:DWORD, dwParentProperty:DWORD, dwChildProperty:DWORD, dwPropertyValue:DWORD
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetProperty, hControl, MUI_EXTERNAL_PROPERTIES, dwParentProperty ; get parent external properties
    .IF eax != 0
        mov ebx, eax
        add ebx, dwChildProperty
        mov eax, [eax]
        mov dwPrevValue, eax
        mov eax, dwPropertyValue
        mov [ebx], eax
        mov eax, dwPrevValue
    .ENDIF
    ret
MUISetExtPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child internal property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUIGetIntPropertyEx PROC hControl:DWORD, dwParentProperty:DWORD, dwChildProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_INTERNAL_PROPERTIES, dwParentProperty ; get parent internal properties
    .IF eax != 0
        add eax, dwChildProperty
        mov eax, [eax]
    .ENDIF
    ret
MUIGetIntPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child internal property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUISetIntPropertyEx PROC USES EBX hControl:DWORD, dwParentProperty:DWORD, dwChildProperty:DWORD, dwPropertyValue:DWORD
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetProperty, hControl, MUI_INTERNAL_PROPERTIES, dwParentProperty ; get parent internal properties
    .IF eax != 0
        mov ebx, eax
        add ebx, dwChildProperty
        mov eax, [eax]
        mov dwPrevValue, eax
        mov eax, dwPropertyValue
        mov [ebx], eax
        mov eax, dwPrevValue
    .ENDIF
    ret
MUISetIntPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtPropertyExtra PROC hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_EXTERNAL_PROPERTIES_EXTRA, dwProperty ; get external properties
    ret
MUIGetExtPropertyExtra ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtPropertyExtra PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, MUI_EXTERNAL_PROPERTIES_EXTRA, dwProperty, dwPropertyValue ; set external properties
    ret
MUISetExtPropertyExtra ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntPropertyExtra PROC hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_INTERNAL_PROPERTIES_EXTRA, dwProperty ; get internal properties
    ret
MUIGetIntPropertyExtra ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntPropertyExtra PROC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, MUI_INTERNAL_PROPERTIES_EXTRA, dwProperty, dwPropertyValue ; set internal properties
    ret
MUISetIntPropertyExtra ENDP

MODERNUI_LIBEND



