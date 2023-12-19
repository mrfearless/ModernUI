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
include kernel32.inc
include user32.inc
includelib user32.lib
includelib Kernel32.Lib

include ModernUI.inc


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Dynamically allocates or resizes a memory location based on items in a 
; structure and the size of the structure.
;
; StructMemPtr is an address to receive the pointer to memory location of the 
; base structure in memory.
;
; StructMemPtr can be NULL if TotalItems are 0. Otherwise it must contain the 
; address of the base structure in memory if the memory is to be increased, 
; TotalItems > 0
;
; ItemSize is typically SIZEOF structure to be allocated (this function calcs 
; for you the size * TotalItems)
;
; If StructMemPtr is NULL then memory object is initialized to the size of total
; items * itemsize and pointer to mem is returned in eax.
; 
; On return eax contains the pointer to the new structure item or -1 if there 
; was a problem alloc'ing memory.
;------------------------------------------------------------------------------
MUIAllocStructureMemory PROC USES EBX PtrStructMem:POINTER, TotalItems:MUIVALUE, ItemSize:MUIVALUE
    LOCAL StructDataOffset:DWORD
    LOCAL StructSize:DWORD
    LOCAL StructData:DWORD
    
    ;PrintText 'AllocStructureMemory'
    .IF TotalItems == 0
        Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, ItemSize ;
        .IF eax != NULL
            mov StructData, eax
            mov ebx, PtrStructMem
            mov [ebx], eax ; save pointer to memory alloc'd for structure
            mov StructDataOffset, 0 ; save offset for new entry
            ;IFDEF DEBUG32
            ;    PrintDec StructData
            ;ENDIF
        .ELSE
            IFDEF DEBUG32
            PrintText '_AllocStructureMemory::Mem error GlobalAlloc'
            ENDIF
            mov eax, -1
            ret
        .ENDIF
    .ELSE
        
        .IF PtrStructMem != NULL
        
            ; calc new size to grow structure and offset to new entry
            mov eax, TotalItems
            inc eax
            mov ebx, ItemSize
            mul ebx
            mov StructSize, eax ; save new size to alloc mem for
            mov ebx, ItemSize
            sub eax, ebx
            mov StructDataOffset, eax ; save offset for new entry
            
            mov ebx, PtrStructMem ; get value from addr of passed dword PtrStructMem into eax, this is our pointer to previous mem location of structure
            mov eax, [ebx]
            mov StructData, eax
            ;IFDEF DEBUG32
            ;    PrintDec StructData
            ;    PrintDec StructSize
            ;ENDIF
            
            .IF TotalItems >= 2
                Invoke GlobalUnlock, StructData
            .ENDIF
            Invoke GlobalReAlloc, StructData, StructSize, GMEM_ZEROINIT or GMEM_MOVEABLE ; resize memory for structure
            .IF eax != NULL
                ;PrintDec eax
                Invoke GlobalLock, eax
                mov StructData, eax
                
                mov ebx, PtrStructMem
                mov [ebx], eax ; save new pointer to memory alloc'd for structure back to dword address passed as PtrStructMem
            .ELSE
                IFDEF DEBUG32
                PrintText '_AllocStructureMemory::Mem error GlobalReAlloc'
                ENDIF
                mov eax, -1
                ret
            .ENDIF
        
        .ELSE ; initialize structure size to the size specified by items * size
            
            ; calc size of structure
            mov eax, TotalItems
            mov ebx, ItemSize
            mul ebx
            mov StructSize, eax ; save new size to alloc mem for        
            Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, StructSize ;GMEM_FIXED+GMEM_ZEROINIT
            .IF eax != NULL
                mov StructData, eax
                ;mov ebx, PtrStructMem ; alloc memory so dont return anything to this as it was null when we got it
                ;mov [ebx], eax ; save pointer to memory alloc'd for structure
                mov StructDataOffset, 0 ; save offset for new entry
                ;IFDEF DEBUG32
                ;    PrintDec StructData
                ;ENDIF
            .ELSE
                IFDEF DEBUG32
                PrintText '_AllocStructureMemory::Mem error GlobalAlloc'
                ENDIF
                mov eax, -1
                ret
            .ENDIF
        .ENDIF
    .ENDIF

    ; calc entry to new item, (base address of memory alloc'd for structure + size of mem for new structure size - size of structure item)
    ;PrintText 'AllocStructureMemory END'
    mov eax, StructData
    add eax, StructDataOffset
    
    ret
MUIAllocStructureMemory endp


MODERNUI_LIBEND



