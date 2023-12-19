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

includelib user32.lib
includelib Kernel32.Lib

include ModernUI.inc


.CONST

.DATA
ExistingClassWndProc    DD 0

.CODE



MUI_ALIGN
;------------------------------------------------------------------------------
; Superclass an existing control and registers the new superclass (ANSI version)
; https://learn.microsoft.com/en-us/windows/win32/winmsg/about-window-procedures#window-procedure-superclassing
;
; lpszExistingClassName     - string containing the existing class name to superclass
; lpdwExistingClassWndProc  - pointer to a dword to store the existing class's 
;                             main window procedure
; lpszSuperclassName        - string containing the new superclass name to register
; lpSuperclassWndProc       - pointer to the main window procedure to use for the
;                             new superclass
; lpSuperclassCursorName    - id as LoadCursor to use for cursor, or IDC_ARROW 
;                             as default
; cbSuperclassWndExtra      - amount of extra bytes needed for the superclass. 
;                             For MUI controls typically 8 bytes, first dword 
;                             for internal properties structure allocated in 
;                             memory via MUIAllocMemProperties, and second dword
;                             for external properties structure allocated in 
;                             memory via MUIAllocMemProperties.
; lpcbWndExtraOffset        - pointer to a dword to store the cbWndExtra bytes 
;                             used by the base existing class. Use MUIGetProperty
;                             and MUISetProperty functions and add the extra 
;                             base class bytes to the cbWndExtraOffset parameter
;
;------------------------------------------------------------------------------
MUISuperclassA PROC USES EBX lpszExistingClassName:MUILPSTRING, lpdwExistingClassWndProc:POINTER, lpszSuperclassName:MUILPSTRING, lpSuperclassWndProc:POINTER, lpSuperclassCursorName:MUIVALUE, cbSuperclassWndExtra:MUIVALUE, lpcbWndExtraOffset:LPMUIVALUE
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
	.IF lpszExistingClassName == NULL || lpdwExistingClassWndProc == NULL || lpszSuperclassName == NULL || lpSuperclassWndProc == NULL
	    mov eax, FALSE
	    ret
	.ENDIF
	
    Invoke GetModuleHandleA, NULL
    mov hinstance, eax
    
    mov wc.cbSize, SIZEOF WNDCLASSEX
    Invoke GetClassInfoExA, hinstance, lpszSuperclassName, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        ; get existing class information first
        Invoke GetClassInfoExA, hinstance, lpszExistingClassName, Addr wc
        mov wc.cbSize, SIZEOF WNDCLASSEX
        ; Change to our superclass
        mov eax, lpszSuperclassName
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
        .IF lpdwExistingClassWndProc != NULL
            ; ideally return the old window proc
            mov eax, wc.lpfnWndProc
            mov ebx, lpdwExistingClassWndProc
            mov [ebx], eax
        .ELSE
            ; else store old window proc in our global var
            mov eax, wc.lpfnWndProc
            mov ExistingClassWndProc, eax
        .ENDIF
        ; point to our superclass proc to use instead
        mov eax, lpSuperclassWndProc
    	mov wc.lpfnWndProc, eax
    	; Load a custom cursor if specified
    	.IF lpSuperclassCursorName != NULL
    	    Invoke LoadCursorA, NULL, lpSuperclassCursorName
    	.ELSE
    	    Invoke LoadCursorA, NULL, IDC_ARROW
        .ENDIF
    	mov wc.hCursor, eax
    	mov wc.hIcon, 0
    	mov wc.hIconSm, 0
    	mov wc.lpszMenuName, NULL
    	mov wc.hbrBackground, NULL
    	mov wc.style, NULL
        mov wc.cbClsExtra, 0
        ; Find out the base bytes used by the existing class in cbWndExtra
        mov eax, wc.cbWndExtra
        .IF lpcbWndExtraOffset != NULL
            ; store the base bytes used by the existing class as an offset into cbWndExtra
            mov ebx, lpcbWndExtraOffset
            mov [ebx], eax
        .ENDIF
        ; Add our own extra bytes required
        add eax, cbSuperclassWndExtra
    	mov wc.cbWndExtra, eax
    	Invoke RegisterClassExA, Addr wc
    	.IF eax == FALSE
    	.ELSE
    	    mov eax, TRUE
    	.ENDIF
    .ELSE
        mov eax, TRUE
    .ENDIF 

    ret
MUISuperclassA ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Superclass an existing control and registers the new superclass (UNICODE version)
; https://learn.microsoft.com/en-us/windows/win32/winmsg/about-window-procedures#window-procedure-superclassing
;
; lpszExistingClassName     - string containing the existing class name to superclass
; lpdwExistingClassWndProc  - pointer to a dword to store the existing class's 
;                             main window procedure
; lpszSuperclassName        - string containing the new superclass name to register
; lpSuperclassWndProc       - pointer to the main window procedure to use for the
;                             new superclass
; lpSuperclassCursorName    - id as LoadCursor to use for cursor, or IDC_ARROW 
;                             as default
; cbSuperclassWndExtra      - amount of extra bytes needed for the superclass. 
;                             For MUI controls typically 8 bytes, first dword 
;                             for internal properties structure allocated in 
;                             memory via MUIAllocMemProperties, and second dword
;                             for external properties structure allocated in 
;                             memory via MUIAllocMemProperties.
; lpcbWndExtraOffset        - pointer to a dword to store the cbWndExtra bytes 
;                             used by the base existing class. Use MUIGetProperty
;                             and MUISetProperty functions and add the extra 
;                             base class bytes to the cbWndExtraOffset parameter
;
;------------------------------------------------------------------------------
MUISuperclassW PROC USES EBX lpszExistingClassName:MUILPSTRING, lpdwExistingClassWndProc:POINTER, lpszSuperclassName:MUILPSTRING, lpSuperclassWndProc:POINTER, lpSuperclassCursorName:MUIVALUE, cbSuperclassWndExtra:MUIVALUE, lpcbWndExtraOffset:LPMUIVALUE
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
	.IF lpszExistingClassName == NULL || lpdwExistingClassWndProc == NULL || lpszSuperclassName == NULL || lpSuperclassWndProc == NULL
	    mov eax, FALSE
	    ret
	.ENDIF
	
    Invoke GetModuleHandleW, NULL
    mov hinstance, eax
    
    mov wc.cbSize, SIZEOF WNDCLASSEX
    Invoke GetClassInfoExW, hinstance, lpszSuperclassName, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        ; get existing class information first
        Invoke GetClassInfoExW, hinstance, lpszExistingClassName, Addr wc
        mov wc.cbSize, SIZEOF WNDCLASSEX
        ; Change to our superclass
        mov eax, lpszSuperclassName
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
        .IF lpdwExistingClassWndProc != NULL
            ; ideally return the old window proc
            mov eax, wc.lpfnWndProc
            mov ebx, lpdwExistingClassWndProc
            mov [ebx], eax
        .ELSE
            ; else store old window proc in our global var
            mov eax, wc.lpfnWndProc
            mov ExistingClassWndProc, eax
        .ENDIF
        ; point to our superclass proc to use instead
        mov eax, lpSuperclassWndProc
    	mov wc.lpfnWndProc, eax
    	; Load a custom cursor if specified
    	.IF lpSuperclassCursorName != NULL
    	    Invoke LoadCursorW, NULL, lpSuperclassCursorName
    	.ELSE
    	    Invoke LoadCursorW, NULL, IDC_ARROW
        .ENDIF
    	mov wc.hCursor, eax
    	mov wc.hIcon, 0
    	mov wc.hIconSm, 0
    	mov wc.lpszMenuName, NULL
    	mov wc.hbrBackground, NULL
    	mov wc.style, NULL
        mov wc.cbClsExtra, 0
        ; Find out the base bytes used by the existing class in cbWndExtra
        mov eax, wc.cbWndExtra
        .IF lpcbWndExtraOffset != NULL
            ; store the base bytes used by the existing class as an offset into cbWndExtra
            mov ebx, lpcbWndExtraOffset
            mov [ebx], eax
        .ENDIF
        ; Add our own extra bytes required
        add eax, cbSuperclassWndExtra
    	mov wc.cbWndExtra, eax
    	Invoke RegisterClassExW, Addr wc
    	.IF eax == FALSE
    	.ELSE
    	    mov eax, TRUE
    	.ENDIF
    .ELSE
        mov eax, TRUE
    .ENDIF 

    ret
MUISuperclassW ENDP






MODERNUI_LIBEND




