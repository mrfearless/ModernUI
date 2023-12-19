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
include kernel32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
;CreateIconFromData
; Creates an icon from icon data stored in the DATA or CONST SECTION
; (The icon data is an ICO file stored directly in the executable)
;
; Parameters
;   pIconData = Pointer to the ico file data
;   iIcon = zero based index of the icon to load
;
; If successful will return an icon handle, this handle must be freed
; using DestroyIcon when it is no longer needed. The size of the icon
; is returned in EDX, the high order word contains the width and the
; low order word the height.
; 
; Returns 0 if there is an error.
; If the index is greater than the number of icons in the file EDX will
; be set to the number of icons available otherwise EDX is 0. To find
; the number of available icons set the index to -1
;
;http://www.masmforum.com/board/index.php?topic=16267.msg134434#msg134434
;------------------------------------------------------------------------------
MUICreateIconFromMemory PROC USES EDX pIconData:POINTER, iIcon:MUIVALUE
    LOCAL sz[2]:DWORD

    xor eax, eax
    mov edx, [pIconData]
    or edx, edx
    jz ERRORCATCH

    movzx eax, WORD PTR [edx+4]
    cmp eax, [iIcon]
    ja @F
        ERRORCATCH:
        push eax
        invoke SetLastError, ERROR_RESOURCE_NAME_NOT_FOUND
        pop edx
        xor eax, eax
        ret
    @@:

    mov eax, [iIcon]
    shl eax, 4
    add edx, eax
    add edx, 6

    movzx eax, BYTE PTR [edx]
    mov [sz], eax
    movzx eax, BYTE PTR [edx+1]
    mov [sz+4], eax

    mov eax, [edx+12]
    add eax, [pIconData]
    mov edx, [edx+8]

    invoke CreateIconFromResourceEx, eax, edx, 1, 030000h, [sz], [sz+4], 0

    mov edx,[sz]
    shl edx,16
    mov dx, word ptr [sz+4]

    ret

MUICreateIconFromMemory ENDP


MODERNUI_LIBEND



