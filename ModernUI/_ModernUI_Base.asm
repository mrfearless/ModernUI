;==============================================================================
;
; ModernUI Library
;
; Copyright (c) 2023 by fearless
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
_MUIGetPropertyA PROTO hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
_MUISetPropertyA PROTO hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
_MUIGetPropertyW PROTO hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
_MUISetPropertyW PROTO hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE


.CODE


;==============================================================================
; ANSI
;==============================================================================

MUI_ALIGN
;------------------------------------------------------------------------------
; Gets the pointer to memory allocated to control at startup and stored in 
; cbWinExtra adds the offset to property to this pointer and fetches value at 
; this location and returns it in eax.
;
; Properties are defined as constants, which are used as offsets in memory to 
; the; data alloc'd, for example: @MouseOver EQU 0, @SelectedState EQU 4
; we might specify 8 in cbWndExtra and then GlobalAlloc 8 bytes of data to 
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
_MUIGetPropertyA PROC USES EBX hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
    Invoke GetWindowLongA, hWin, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, Property
    mov eax, Property
    and eax, MUI_PROPERTY_ADDRESS
    .IF eax == MUI_PROPERTY_ADDRESS
        mov eax, ebx ; return address of the property in eax
    .ELSE
        mov eax, [ebx] ; return in eax the contents of the property at address in rbx
    .ENDIF
    ret
_MUIGetPropertyA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets property value and returns previous value in eax.
;------------------------------------------------------------------------------
_MUISetPropertyA PROC USES EBX hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLongA, hWin, cbWndExtraOffset
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
_MUISetPropertyA ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Gets the pointer to memory allocated to control at startup and stored in 
; cbWinExtra adds the offset to property to this pointer and fetches value at 
; this location and returns it in eax.
;
; Properties are defined as constants, which are used as offsets in memory to 
; the; data alloc'd, for example: @MouseOver EQU 0, @SelectedState EQU 4
; we might specify 8 in cbWndExtra and then GlobalAlloc 8 bytes of data to 
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
; Added public versions of these to allow for adjustment of the base address
; to fetch the internal or external property structures from. This is for
; example where we have to deal with a superclassed control based on an existing
; control that has its own cbWndExtra bytes, which we must preserve.
; Use GetClassInfoEx to determine the offset to account for theses bytes to
; add to the cbWndExtraOffset parameter to correctly address alloc mem.
; MUIAllocMemProperties also must be adjusted by this offset to preserve the
; extra bytes for the base class being superclassed
;------------------------------------------------------------------------------
MUIGetPropertyA PROC hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
    Invoke _MUIGetPropertyA, hWin, cbWndExtraOffset, Property ; get properties
    ret
MUIGetPropertyA ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Sets property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetPropertyA PROC hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyA, hWin, cbWndExtraOffset, Property, PropertyValue ; set properties
    ret
MUISetPropertyA ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Gets external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtPropertyA PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyA, hWin, MUI_EXTERNAL_PROPERTIES, Property ; get external properties
    ret
MUIGetExtPropertyA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtPropertyA PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyA, hWin, MUI_EXTERNAL_PROPERTIES, Property, PropertyValue ; set external properties
    ret
MUISetExtPropertyA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntPropertyA PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyA, hWin, MUI_INTERNAL_PROPERTIES, Property ; get internal properties
    ret
MUIGetIntPropertyA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntPropertyA PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyA, hWin, MUI_INTERNAL_PROPERTIES, Property, PropertyValue ; set internal properties
    ret
MUISetIntPropertyA ENDP



MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child external property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUIGetExtPropertyExA PROC hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY
    Invoke _MUIGetPropertyA, hWin, MUI_EXTERNAL_PROPERTIES, ParentProperty ; get parent external properties
    .IF eax != 0
        add eax, ChildProperty
        mov eax, [eax]
    .ENDIF
    ret
MUIGetExtPropertyExA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets child external property value
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUISetExtPropertyExA PROC USES EBX hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetPropertyA, hWin, MUI_EXTERNAL_PROPERTIES, ParentProperty ; get parent external properties
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
MUISetExtPropertyExA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child internal property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUIGetIntPropertyExA PROC hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY
    Invoke _MUIGetPropertyA, hWin, MUI_INTERNAL_PROPERTIES, ParentProperty ; get parent internal properties
    .IF eax != 0
        add eax, ChildProperty
        mov eax, [eax]
    .ENDIF
    ret
MUIGetIntPropertyExA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets child internal property value
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUISetIntPropertyExA PROC USES EBX hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetPropertyA, hWin, MUI_INTERNAL_PROPERTIES, ParentProperty ; get parent internal properties
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
MUISetIntPropertyExA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtPropertyExtraA PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyA, hWin, MUI_EXTERNAL_PROPERTIES_EXTRA, Property ; get extra external properties
    ret
MUIGetExtPropertyExtraA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtPropertyExtraA PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyA, hWin, MUI_EXTERNAL_PROPERTIES_EXTRA, Property, PropertyValue ; set extra external properties
    ret
MUISetExtPropertyExtraA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntPropertyExtraA PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyA, hWin, MUI_INTERNAL_PROPERTIES_EXTRA, Property ; get extra internal properties
    ret
MUIGetIntPropertyExtraA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntPropertyExtraA PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyA, hWin, MUI_INTERNAL_PROPERTIES_EXTRA, Property, PropertyValue ; set extra internal properties
    ret
MUISetIntPropertyExtraA ENDP


;==============================================================================
; UNICODE
;==============================================================================

MUI_ALIGN
;------------------------------------------------------------------------------
; Gets the pointer to memory allocated to control at startup and stored in 
; cbWinExtra adds the offset to property to this pointer and fetches value at 
; this location and returns it in eax.
;
; Properties are defined as constants, which are used as offsets in memory to 
; the; data alloc'd, for example: @MouseOver EQU 0, @SelectedState EQU 4
; we might specify 8 in cbWndExtra and then GlobalAlloc 8 bytes of data to 
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
_MUIGetPropertyW PROC USES EBX hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
    Invoke GetWindowLongW, hWin, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, Property
    mov eax, Property
    and eax, MUI_PROPERTY_ADDRESS
    .IF eax == MUI_PROPERTY_ADDRESS
        mov eax, ebx ; return address of the property in eax
    .ELSE
        mov eax, [ebx] ; return in eax the contents of the property at address in ebx
    .ENDIF
    ret
_MUIGetPropertyW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets property value and returns previous value in eax.
;------------------------------------------------------------------------------
_MUISetPropertyW PROC USES EBX hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLongW, hWin, cbWndExtraOffset
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
_MUISetPropertyW ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Gets the pointer to memory allocated to control at startup and stored in 
; cbWinExtra adds the offset to property to this pointer and fetches value at 
; this location and returns it in eax.
;
; Properties are defined as constants, which are used as offsets in memory to 
; the; data alloc'd, for example: @MouseOver EQU 0, @SelectedState EQU 4
; we might specify 8 in cbWndExtra and then GlobalAlloc 8 bytes of data to 
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
; Added public versions of these to allow for adjustment of the base address
; to fetch the internal or external property structures from. This is for
; example where we have to deal with a superclassed control based on an existing
; control that has its own cbWndExtra bytes, which we must preserve.
; Use GetClassInfoEx to determine the offset to account for theses bytes to
; add to the cbWndExtraOffset parameter to correctly address alloc mem.
; MUIAllocMemProperties also must be adjusted by this offset to preserve the
; extra bytes for the base class being superclassed
;------------------------------------------------------------------------------
MUIGetPropertyW PROC hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY
    Invoke _MUIGetPropertyW, hWin, cbWndExtraOffset, Property ; get properties
    ret
MUIGetPropertyW ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Sets property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetPropertyW PROC hWin:MUIWND, cbWndExtraOffset:MUIPROPERTIES, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyW, hWin, cbWndExtraOffset, Property, PropertyValue ; set properties
    ret
MUISetPropertyW ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Gets external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtPropertyW PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyW, hWin, MUI_EXTERNAL_PROPERTIES, Property ; get external properties
    ret
MUIGetExtPropertyW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtPropertyW PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyW, hWin, MUI_EXTERNAL_PROPERTIES, Property, PropertyValue ; set external properties
    ret
MUISetExtPropertyW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntPropertyW PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyW, hWin, MUI_INTERNAL_PROPERTIES, Property ; get internal properties
    ret
MUIGetIntPropertyW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntPropertyW PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyW, hWin, MUI_INTERNAL_PROPERTIES, Property, PropertyValue ; set internal properties
    ret
MUISetIntPropertyW ENDP



MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child external property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUIGetExtPropertyExW PROC hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY
    Invoke _MUIGetPropertyW, hWin, MUI_EXTERNAL_PROPERTIES, ParentProperty ; get parent external properties
    .IF eax != 0
        add eax, ChildProperty
        mov eax, [eax]
    .ENDIF
    ret
MUIGetExtPropertyExW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets child external property value
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUISetExtPropertyExW PROC USES EBX hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetPropertyW, hWin, MUI_EXTERNAL_PROPERTIES, ParentProperty ; get parent external properties
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
MUISetExtPropertyExW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets child internal property value and returns it in eax
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUIGetIntPropertyExW PROC hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY
    Invoke _MUIGetPropertyW, hWin, MUI_INTERNAL_PROPERTIES, ParentProperty ; get parent internal properties
    .IF eax != 0
        add eax, ChildProperty
        mov eax, [eax]
    .ENDIF
    ret
MUIGetIntPropertyExW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets child internal property value
; For properties (parent) in main ModernUI controls that store pointers to 
; another (child) defined properties structure
;------------------------------------------------------------------------------
MUISetIntPropertyExW PROC USES EBX hWin:MUIWND, ParentProperty:MUIPROPERTY, ChildProperty:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    LOCAL dwPrevValue:DWORD
    Invoke _MUIGetPropertyW, hWin, MUI_INTERNAL_PROPERTIES, ParentProperty ; get parent internal properties
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
MUISetIntPropertyExW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra external property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetExtPropertyExtraW PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyW, hWin, MUI_EXTERNAL_PROPERTIES_EXTRA, Property ; get extra external properties
    ret
MUIGetExtPropertyExtraW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra external property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetExtPropertyExtraW PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyW, hWin, MUI_EXTERNAL_PROPERTIES_EXTRA, Property, PropertyValue ; set extra external properties
    ret
MUISetExtPropertyExtraW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Gets Extra internal property value and returns it in eax
;------------------------------------------------------------------------------
MUIGetIntPropertyExtraW PROC hWin:MUIWND, Property:MUIPROPERTY
    Invoke _MUIGetPropertyW, hWin, MUI_INTERNAL_PROPERTIES_EXTRA, Property ; get extra internal properties
    ret
MUIGetIntPropertyExtraW ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Sets Extra internal property value and returns previous value in eax.
;------------------------------------------------------------------------------
MUISetIntPropertyExtraW PROC hWin:MUIWND, Property:MUIPROPERTY, PropertyValue:MUIPROPERTYVALUE
    Invoke _MUISetPropertyW, hWin, MUI_INTERNAL_PROPERTIES_EXTRA, Property, PropertyValue ; set extra internal properties
    ret
MUISetIntPropertyExtraW ENDP



MODERNUI_LIBEND



