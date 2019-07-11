;==============================================================================
;
; ModernUI Library
;
; Copyright (c) 2019 by fearless
;
; All Rights Reserved
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
_MUIGetProperty PROTO hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
_MUISetProperty PROTO hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE

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
;   Invoke SetWindowLong, hWin, 0, pMem
;
; pMem is our pointer to our 8 bytes of storage, of which first four bytes 
; (dword) is used for our @MouseOver property and the next dword for 
; @SelectedState
; 
; Added extra option to check if Property is OR'd with MUI_PROPERTY_ADDRESS
; then return address of property
;
;
;------------------------------------------------------------------------------
_MUIGetProperty PROC USES EBX hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
    Invoke GetWindowLong, hWin, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, Property
    mov eax, Property
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
_MUISetProperty PROC USES EBX hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLong, hWin, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF    
    mov ebx, eax
    add ebx, Property
    mov eax, [ebx]
    mov dwPrevValue, eax
    mov eax, PropertyValue
    mov [ebx], eax
    mov eax, dwPrevValue
    ret
_MUISetProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtProperty PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetProperty, hWin, MUI_EXTERNAL_PROPERTIES, Property ; get external properties
    ret
MUIGetExtProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtProperty PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetProperty, hWin, MUI_EXTERNAL_PROPERTIES, Property, PropertyValue ; set external properties
    ret
MUISetExtProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntProperty PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetProperty, hWin, MUI_INTERNAL_PROPERTIES, Property ; get internal properties
    ret
MUIGetIntProperty ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntProperty PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetProperty, hWin, MUI_INTERNAL_PROPERTIES, Property, PropertyValue ; set internal properties
    ret
MUISetIntProperty ENDP



MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child external property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUIGetExtPropertyEx PROC hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY
    Invoke _MUIGetProperty, hWin, MUI_EXTERNAL_PROPERTIES, ParentProperty ; get parent external properties
    .IF eax != 0
        add eax, ChildProperty
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
MUISetExtPropertyEx PROC USES EBX hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetProperty, hWin, MUI_EXTERNAL_PROPERTIES, ParentProperty ; get parent external properties
    .IF eax != 0
        mov ebx, eax
        add ebx, ChildProperty
        mov eax, [eax]
        mov dwPrevValue, eax
        mov eax, PropertyValue
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
MUIGetIntPropertyEx PROC hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY
    Invoke _MUIGetProperty, hWin, MUI_INTERNAL_PROPERTIES, ParentProperty ; get parent internal properties
    .IF eax != 0
        add eax, ChildProperty
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
MUISetIntPropertyEx PROC USES EBX hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetProperty, hWin, MUI_INTERNAL_PROPERTIES, ParentProperty ; get parent internal properties
    .IF eax != 0
        mov ebx, eax
        add ebx, ChildProperty
        mov eax, [eax]
        mov dwPrevValue, eax
        mov eax, PropertyValue
        mov [ebx], eax
        mov eax, dwPrevValue
    .ENDIF
    ret
MUISetIntPropertyEx ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtPropertyExtra PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetProperty, hWin, MUI_EXTERNAL_PROPERTIES_EXTRA, Property ; get external properties
    ret
MUIGetExtPropertyExtra ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtPropertyExtra PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetProperty, hWin, MUI_EXTERNAL_PROPERTIES_EXTRA, Property, PropertyValue ; set external properties
    ret
MUISetExtPropertyExtra ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntPropertyExtra PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetProperty, hWin, MUI_INTERNAL_PROPERTIES_EXTRA, Property ; get internal properties
    ret
MUIGetIntPropertyExtra ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntPropertyExtra PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetProperty, hWin, MUI_INTERNAL_PROPERTIES_EXTRA, Property, PropertyValue ; set internal properties
    ret
MUISetIntPropertyExtra ENDP

MODERNUI_LIBEND



