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
include gdi32.inc
includelib user32.lib
includelib gdi32.lib

include ModernUI.inc

IFNDEF FP4
    FP4 MACRO value
    LOCAL vname
    .data
    align 4
      vname REAL4 value
    .code
    EXITM <vname>
    ENDM
ENDIF


IFDEF MUI_USEGDIPLUS
include gdiplus.inc
includelib gdiplus.lib


.DATA
;------------------------------------------------------------------------------
; Controls that use gdiplus check the MUI_GDIPLUS variable first. If it is 0 
; they call MUIGDIPlusStart and increment the MUI_GDIPLUS value. 
; When the control is destroyed, they decrement the MUI_GDIPLUS value and check
; if it is 0. If it is 0 they call MUIGDIPlusFinish to finish up.
;------------------------------------------------------------------------------
MUI_GDIPLUS          DD 0 
MUI_GDIPlusToken     DD 0
MUI_gdipsi           GdiplusStartupInput <1,0,0,0>


.CODE


;------------------------------------------------------------------------------
; Start of ModernUI framework (wrapper for gdiplus startup)
; Placed at start of program before WinMain call
;------------------------------------------------------------------------------
MUI_ALIGN
MUIGDIPlusStart PROC
    .IF MUI_GDIPLUS == 0
        ;PrintText 'GdiplusStartup'
        Invoke GdiplusStartup, Addr MUI_GDIPlusToken, Addr MUI_gdipsi, NULL
    .ENDIF
    inc MUI_GDIPLUS
    ;PrintDec MUI_GDIPLUS
    xor eax, eax
    ret
MUIGDIPlusStart ENDP


;------------------------------------------------------------------------------
; Finish ModernUI framework (wrapper for gdiplus shutdown)
; Placed after WinMain call before ExitProcess
;------------------------------------------------------------------------------
MUI_ALIGN
MUIGDIPlusFinish PROC
    ;PrintDec MUI_GDIPLUS
    dec MUI_GDIPLUS
    .IF MUI_GDIPLUS == 0
        ;PrintText 'GdiplusShutdown'
        Invoke GdiplusShutdown, MUI_GDIPlusToken
    .ENDIF
    xor eax, eax
    ret
MUIGDIPlusFinish ENDP

MUI_ALIGN
;-------------------------------------------------------------------------------------
; Start Double Buffering for GDI+
;-------------------------------------------------------------------------------------
MUIGDIPlusDoubleBufferStart PROC USES EBX hWin:DWORD, pGraphics:DWORD, lpBitmapHandle:DWORD, lpGraphicsBuffer:DWORD
    LOCAL rect:RECT
    LOCAL pBuffer:DWORD
    LOCAL pBitmap:DWORD
    
    Invoke GetClientRect, hWin, Addr rect
    Invoke GdipCreateBitmapFromGraphics, rect.right, rect.bottom, pGraphics, Addr pBitmap
    Invoke GdipGetImageGraphicsContext, pBitmap, Addr pBuffer

    ; Save our created bitmap and buffer back to pGraphicsBuffer
    .IF lpGraphicsBuffer != NULL
        mov ebx, lpGraphicsBuffer
        mov eax, pBuffer
        mov [ebx], eax
    .ENDIF
    .IF lpBitmapHandle != NULL
        mov ebx, lpBitmapHandle
        mov eax, pBitmap
        mov [ebx], eax
    .ENDIF
    
    xor eax, eax
    ret
MUIGDIPlusDoubleBufferStart ENDP

MUI_ALIGN
;-------------------------------------------------------------------------------------
; Finish Double Buffering for GDI+ & copy finished pGraphicsBuffer to pGraphics (HDC)
;-------------------------------------------------------------------------------------
MUIGDIPlusDoubleBufferFinish PROC hWin:DWORD, pGraphics:DWORD, hBitmap:DWORD, pGraphicsBuffer:DWORD
    LOCAL rect:RECT
    
    Invoke GetClientRect, hWin, Addr rect
    Invoke GdipDrawImageRectI, pGraphics, hBitmap, 0, 0, rect.right, rect.bottom
    Invoke GdipDeleteGraphics, pGraphicsBuffer   
    invoke GdipDisposeImage, hBitmap
    xor eax, eax
    ret
MUIGDIPlusDoubleBufferFinish ENDP


MUI_ALIGN
;-------------------------------------------------------------------------------------
; MUIGDIPlusRotateCenterImage
;-------------------------------------------------------------------------------------
MUIGDIPlusRotateCenterImage PROC USES EBX hImage:DWORD, fAngle:REAL4, BaseColor:DWORD
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL matrix:DWORD
    LOCAL pBitmap:DWORD
    LOCAL pBrush:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL HalfImageWidth:DWORD
    LOCAL HalfImageHeight:DWORD
    LOCAL x:REAL4
    LOCAL y:REAL4
    LOCAL xneg:REAL4
    LOCAL yneg:REAL4
    LOCAL angle:REAL4

    mov pGraphics, 0
    mov pGraphicsBuffer, 0
    mov matrix, 0
    mov pBitmap, 0
    mov pBrush, 0

    Invoke MUIGetImageSize, hImage, MUIIT_PNG, Addr ImageWidth, Addr ImageHeight
    inc ImageWidth
    inc ImageHeight
    inc ImageWidth
    inc ImageHeight
    Invoke GdipGetImageGraphicsContext, hImage, Addr pGraphics
    Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap ; rect.right, rect.bottom
    Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer

    Invoke GdipSetPageUnit, pGraphics, UnitPixel
    Invoke GdipSetPageUnit, pGraphicsBuffer, UnitPixel   
    invoke GdipSetSmoothingMode, pGraphics, SmoothingModeAntiAlias  
    invoke GdipSetSmoothingMode, pGraphicsBuffer, SmoothingModeAntiAlias

    ;Invoke GdipCreateSolidFill, BaseColor, Addr pBrush
    ;Invoke GdipFillRectangleI, pGraphicsBuffer, pBrush, 0, 0, ImageWidth, ImageHeight
    
    finit
;    mov eax, ImageWidth
;    shr eax, 1
;    mov HalfImageWidth, eax
;    fild HalfImageWidth ;ImageWidth
;    fstp x
;    mov eax, ImageHeight
;    shr eax, 1
;    mov HalfImageHeight, eax
;    fild HalfImageHeight ;ImageHeight
;    fstp y
    fild ImageWidth
    fld FP4(2.0)
    fdiv
    fstp x
    
    fild ImageHeight
    fld FP4(2.0)
    fdiv
    fstp y
    
    fld x
    fld FP4(-1.0)
    fmul
    fstp xneg
    
    fld y
    fld FP4(-1.0)
    fmul
    fstp yneg
    
    
    ;fild dwAngle
    ;fstp angle
    
    Invoke GdipCreateMatrix, Addr matrix
    Invoke GdipTranslateMatrix, matrix, x, y, MatrixOrderPrepend
    Invoke GdipRotateMatrix, matrix, fAngle, MatrixOrderPrepend
    Invoke GdipSetWorldTransform, pGraphicsBuffer, matrix
    mov eax, HalfImageWidth
    neg eax
    mov ebx, HalfImageHeight
    neg ebx
    
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, xneg, yneg
    ;Invoke GdipDrawImageI, pGraphicsBuffer, hImage, eax, ebx
    Invoke GdipResetWorldTransform, pGraphicsBuffer

    ; tidy up buffers
    .IF matrix != NULL
        Invoke GdipDeleteMatrix, matrix
    .ENDIF
    .IF pBrush != NULL
        Invoke GdipDeleteBrush, pBrush
    .ENDIF
    .IF pGraphicsBuffer != NULL
        Invoke GdipDeleteGraphics, pGraphicsBuffer
    .ENDIF
    .IF pGraphics != NULL
        Invoke GdipDeleteGraphics, pGraphics
    .ENDIF    

    mov eax, pBitmap
    ret
MUIGDIPlusRotateCenterImage endp


ENDIF


MODERNUI_LIBEND
