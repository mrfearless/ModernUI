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
include kernel32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.Lib
includelib gdi32.lib

include ModernUI.inc


IFNDEF CURSORDIR
CURSORDIR           STRUCT
    idReserved      WORD ?
    idType          WORD ?
    idCount         WORD ?
CURSORDIR           ENDS
ENDIF

IFNDEF CURSORDIRENTRY
CURSORDIRENTRY      STRUCT
    bWidth          BYTE ?  
    bHeight         BYTE ?  
    bColorCount     BYTE ? 
    bReserved       BYTE ? 
    XHotspot        WORD ?
    YHotspot        WORD ?
    dwBytesInRes    DWORD ?
    pImageData      DWORD ?
CURSORDIRENTRY      ENDS
ENDIF


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
;MUICreateCursorFromMemory
; Creates a cursor from icon/cursor data stored in the DATA or CONST SECTION
; (The cursor data is an CUR file stored directly in the executable)
;
; Parameters
;   pCursorData = Pointer to the cursor file data
;
;------------------------------------------------------------------------------
MUICreateCursorFromMemory PROC USES EBX pCursorData:DWORD
    LOCAL hinstance:DWORD
    LOCAL pCursorDirEntry:DWORD
    LOCAL pInfoHeader:DWORD
    LOCAL bWidth:DWORD
    LOCAL bHeight:DWORD
    LOCAL bColorCount:DWORD
    LOCAL XHotspot:DWORD
    LOCAL YHotspot:DWORD
    LOCAL pImageData:DWORD
    LOCAL RGBQuadSize:DWORD
    LOCAL pXORData:DWORD
    LOCAL pANDData:DWORD
    LOCAL biHeight:DWORD
    LOCAL biWidth:DWORD
    LOCAL biBitCount:DWORD
    LOCAL dwSizeImageXOR:DWORD
    LOCAL dwSizeImageAND:DWORD
    
    mov ebx, pCursorData
    movzx eax, word ptr [ebx].CURSORDIR.idCount
    .IF eax == 0 || eax > 1
        mov eax, 0
        ret
    .ENDIF

    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    mov ebx, pCursorData
    add ebx, SIZEOF CURSORDIR
    mov pCursorDirEntry, ebx
    
    movzx eax, byte ptr [ebx].CURSORDIRENTRY.bWidth
    mov bWidth, eax
    movzx eax, byte ptr [ebx].CURSORDIRENTRY.bHeight
    mov bHeight, eax
    movzx eax, byte ptr [ebx].CURSORDIRENTRY.bColorCount
    mov bColorCount, eax
    movzx eax, word ptr [ebx].CURSORDIRENTRY.XHotspot
    mov XHotspot, eax
    movzx eax, word ptr [ebx].CURSORDIRENTRY.YHotspot
    mov YHotspot, eax
    mov eax, [ebx].CURSORDIRENTRY.pImageData
    mov pImageData, eax
    
    mov eax, SIZEOF DWORD
    mov ebx, bColorCount
    mul ebx
    mov RGBQuadSize, eax
    
    mov ebx, pCursorData
    add ebx, pImageData
    mov pInfoHeader, ebx
    
    mov eax, [ebx].BITMAPINFOHEADER.biWidth
    mov biWidth, eax
    mov eax, [ebx].BITMAPINFOHEADER.biHeight
    mov biHeight, eax
    movzx eax, word ptr [ebx].BITMAPINFOHEADER.biBitCount
    mov biBitCount, eax
    
    .IF eax == 1 ; BI_MONOCHROME
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        shr eax, 3 ; div by 8
        mov dwSizeImageXOR, eax
        mov dwSizeImageAND, eax

    .ELSEIF eax == 4 ; BI_4_BIT
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        shr eax, 1 ; div by 2
        mov dwSizeImageXOR, eax
        
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        shr eax, 3 ; div by 8
        mov dwSizeImageAND, eax

    .ELSEIF eax == 8 ; BI_8_BIT
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        mov dwSizeImageXOR, eax
        
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        shr eax, 3 ; div by 8
        mov dwSizeImageAND, eax

    .ELSEIF eax == 0
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        mov ebx, 4
        mul ebx
        mov dwSizeImageXOR, eax

        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        shr eax, 3 ; div by 8
        mov dwSizeImageAND, eax

    .ELSE ; default
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        mov ebx, biBitCount
        shr ebx, 3 ; div by 8
        mul ebx
        mov dwSizeImageXOR, eax
        
        mov eax, biWidth
        mov ebx, biHeight
        shr ebx, 1 ; div by 2
        mul ebx
        shr eax, 3 ; div by 8
        mov dwSizeImageAND, eax

    .ENDIF

    mov ebx, pCursorData
    add ebx, pImageData
    add ebx, SIZEOF BITMAPINFOHEADER
    .IF biBitCount == 1 || biBitCount == 4 || biBitCount == 8
        add ebx, RGBQuadSize
    .ENDIF
    mov pXORData, ebx
    add ebx, dwSizeImageXOR
    mov pANDData, ebx

    Invoke CreateCursor, hinstance, XHotspot, YHotspot, bWidth, bHeight, pANDData, pXORData

    ret
MUICreateCursorFromMemory ENDP


END



