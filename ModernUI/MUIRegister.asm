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


.CODE

MUI_ALIGN
;------------------------------------------------------------------------------
; Register a windows class (ANSI version)
;
; lpszClassName     - string containing the class name to register
; lpClassWndProc    - pointer to the main window procedure to use for the class
; lpCursorName      - id as LoadCursor to use for cursor, or IDC_ARROW as default
; cbWndExtra        - amount of extra bytes needed for the class - for MUI controls
;                     typically 8 bytes, first dword for internal properties 
;                     structure allocated in memory via MUIAllocMemProperties, 
;                     and second dword for external properties structure 
;                     allocated in memory via MUIAllocMemProperties.
;
;------------------------------------------------------------------------------
MUIRegisterA PROC lpszClassName:MUILPSTRING, lpClassWndProc:POINTER, lpCursorName:MUIVALUE, cbWndExtra:MUIVALUE
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
	.IF lpszClassName == NULL || lpClassWndProc == NULL
	    mov eax, FALSE
	    ret
	.ENDIF
	
    Invoke GetModuleHandleA, NULL
    mov hinstance, eax
    
    mov wc.cbSize, SIZEOF WNDCLASSEX
    Invoke GetClassInfoExA, hinstance, lpszClassName, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        mov eax, lpszClassName
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
        mov eax, lpClassWndProc
    	mov wc.lpfnWndProc, eax
    	.IF lpCursorName != NULL
    	    Invoke LoadCursorA, NULL, lpCursorName
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
        mov eax, cbWndExtra
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
MUIRegisterA ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Register a windows class (UNICODE version)
;
; lpszClassName     - string containing the class name to register
; lpClassWndProc    - pointer to the main window procedure to use for the class
; lpCursorName      - id as LoadCursor to use for cursor, or IDC_ARROW as default
; cbWndExtra        - amount of extra bytes needed for the class - for MUI controls
;                     typically 8 bytes, first dword for internal properties 
;                     structure allocated in memory via MUIAllocMemProperties, 
;                     and second dword for external properties structure 
;                     allocated in memory via MUIAllocMemProperties.
;
;------------------------------------------------------------------------------
MUIRegisterW PROC lpszClassName:MUILPSTRING, lpClassWndProc:POINTER, lpCursorName:MUIVALUE, cbWndExtra:MUIVALUE
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
	
	.IF lpszClassName == NULL || lpClassWndProc == NULL
	    mov eax, FALSE
	    ret
	.ENDIF
	
    Invoke GetModuleHandleW, NULL
    mov hinstance, eax
    
    mov wc.cbSize, SIZEOF WNDCLASSEX
    Invoke GetClassInfoExW, hinstance, lpszClassName, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize, SIZEOF WNDCLASSEX
        mov eax, lpszClassName
    	mov wc.lpszClassName, eax
    	mov eax, hinstance
        mov wc.hInstance, eax
        mov eax, lpClassWndProc
    	mov wc.lpfnWndProc, eax
    	.IF lpCursorName != NULL
    	    Invoke LoadCursorW, NULL, lpCursorName
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
        mov eax, cbWndExtra
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
MUIRegisterW ENDP







MODERNUI_LIBEND


