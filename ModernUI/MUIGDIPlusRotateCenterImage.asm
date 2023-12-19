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

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
includelib gdiplus.lib


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


.CODE


MUI_ALIGN
;-------------------------------------------------------------------------------------
; MUIGDIPlusRotateCenterImage
;-------------------------------------------------------------------------------------
MUIGDIPlusRotateCenterImage PROC hImage:GPIMAGE, fAngle:REAL4
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL matrix:DWORD
    LOCAL pBitmap:DWORD
    LOCAL pBrush:DWORD
    LOCAL dwImageWidth:DWORD
    LOCAL dwImageHeight:DWORD
    LOCAL dwX:SDWORD
    LOCAL dwY:SDWORD
    LOCAL x:REAL4
    LOCAL y:REAL4
    LOCAL xneg:REAL4
    LOCAL yneg:REAL4
    LOCAL angle:REAL4

    ;---------------------------------------------------------------------------------
    ; Check if angle is 0, if it is just clone image
    ;---------------------------------------------------------------------------------
;    finit           ; init fpu
;    fld fAngle
;    ftst            ; compare the value of ST(0) to +0.0
;    fstsw ax        ; copy the Status Word containing the result to AX
;    fwait           ; insure the previous instruction is completed
;    sahf            ; transfer the condition codes to the CPU's flag register
;    jz angle_is_0
;    jmp angle_is_not_0
;
;angle_is_0:
;    Invoke GdipCloneImage, hImage, Addr pBitmap
;    mov eax, pBitmap
;    ret
;    
;angle_is_not_0:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 360, if it is just clone image
    ;---------------------------------------------------------------------------------
;    finit           ; init fpu
;    fld fAngle
;    fcom FP4(360.0) ; compare ST(0) with the value of the real4_var variable: 360.0
;    fstsw ax        ; copy the Status Word containing the result to AX
;    fwait           ; insure the previous instruction is completed
;    sahf            ; transfer the condition codes to the CPU's flag register
;    jz angle_is_360
;    jmp angle_is_not_360
;
;angle_is_360:
;    Invoke GdipCloneImage, hImage, Addr pBitmap
;    mov eax, pBitmap
;    ret
;
;angle_is_not_360:
    
    ;---------------------------------------------------------------------------------
    ; Create new image based on hImage and rotate this new image 
    ;---------------------------------------------------------------------------------
    mov pGraphics, 0
    mov pGraphicsBuffer, 0
    mov matrix, 0
    mov pBitmap, 0
    mov pBrush, 0
    
    Invoke MUIGetImageSize, hImage, MUIIT_PNG, Addr dwImageWidth, Addr dwImageHeight
    Invoke GdipGetImageGraphicsContext, hImage, Addr pGraphics
    Invoke GdipCreateBitmapFromGraphics, dwImageWidth, dwImageHeight, pGraphics, Addr pBitmap 
    Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer
    
    Invoke GdipSetPixelOffsetMode, pGraphicsBuffer, PixelOffsetModeHighQuality
    Invoke GdipSetPageUnit, pGraphicsBuffer, UnitPixel
    Invoke GdipSetSmoothingMode, pGraphicsBuffer, SmoothingModeAntiAlias
    Invoke GdipSetInterpolationMode, pGraphicsBuffer, InterpolationModeHighQualityBicubic
    
    ;---------------------------------------------------------------------------------
    ; Check if angle is 180, if it is then do a flip instead of rotating
    ; (fixes the speed wobble issue when 180.0 is the angle)
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(180.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_180
    jmp angle_is_not_180
    
angle_is_180:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, Rotate180FlipNone
    jmp tidyup

angle_is_not_180:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 90, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(90.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_90
    jmp angle_is_not_90
    
angle_is_90:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, Rotate90FlipNone
    jmp tidyup

angle_is_not_90:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 270, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(270.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_270
    jmp angle_is_not_270
    
angle_is_270:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, Rotate270FlipNone
    jmp tidyup

angle_is_not_270:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 360, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(360.0) ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_360
    jmp angle_is_not_360
    
angle_is_360:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, RotateNoneFlipNone
    jmp tidyup

angle_is_not_360:

    ;---------------------------------------------------------------------------------
    ; Check if angle is 0, if it is then do a flip instead of rotating
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    fld fAngle
    fcom FP4(0.0)   ; compare ST(0) with the value of the real4_var variable: 180.0
    fstsw ax        ; copy the Status Word containing the result to AX
    fwait           ; insure the previous instruction is completed
    sahf            ; transfer the condition codes to the CPU's flag register
    fstp st(0)
    ;ffree st(0)
    jz angle_is_0
    jmp angle_is_not_0
    
angle_is_0:
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, 0, 0, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, 0, 0
    Invoke GdipImageRotateFlip, pBitmap, RotateNoneFlipNone
    jmp tidyup

angle_is_not_0:

    ;---------------------------------------------------------------------------------
    ; Do the actual rotation, calc Translate x, y position for GdipTranslateMatrix to
    ; rotate at image center. Calc the negative of x, y to restore
    ; the origin for drawing with GdipDrawImage
    ;---------------------------------------------------------------------------------
    finit           ; init fpu
    
    fild dwImageWidth
    fld FP4(2.0)
    fdiv
    fstp x
    
    fild dwImageHeight
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
    
    fld xneg
    fistp dwX
    
    fld yneg
    fistp dwY
    
    finit
    ;Invoke GdipTranslateWorldTransform, pGraphicsBuffer, x, y, MatrixOrderPrepend ;%MatrixOrderAppend)
    ;Invoke GdipRotateWorldTransform, pGraphicsBuffer, fAngle, MatrixOrderPrepend;MatrixOrderAppend;%MatrixOrderPrepend)
    
    Invoke GdipResetWorldTransform, pGraphicsBuffer
    Invoke GdipCreateMatrix, Addr matrix
    Invoke GdipTranslateMatrix, matrix, x, y, MatrixOrderPrepend
    Invoke GdipRotateMatrix, matrix, fAngle, MatrixOrderPrepend
    Invoke GdipSetWorldTransform, pGraphicsBuffer, matrix
    
    ;Invoke GdipDrawImageRectRectI, pGraphicsBuffer, hImage, dwX, dwY, dwImageWidth, dwImageHeight, 0, 0, dwImageWidth, dwImageHeight, UnitPixel, NULL, NULL, NULL    
    
    Invoke GdipDrawImage, pGraphicsBuffer, hImage, xneg, yneg
    Invoke GdipResetWorldTransform, pGraphicsBuffer

tidyup:
    ;---------------------------------------------------------------------------------
    ; Delete buffers and return our new rotated image
    ;---------------------------------------------------------------------------------
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

