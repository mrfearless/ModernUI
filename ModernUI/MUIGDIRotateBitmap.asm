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
include kernel32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.lib
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


RotateBitBltAtD     PROTO hDestDC:HDC, hSrcDC:HDC, xCenter:DWORD, yCenter:DWORD, angle:REAL4, destRect:RECT, xSrc:DWORD, ySrc:DWORD
RotateBitBltAtR     PROTO hDestDC:HDC, hSrcDC:HDC, xCenter:DWORD, yCenter:DWORD, angle:REAL4, destRect:RECT, xSrc:DWORD, ySrc:DWORD
GdiSetRot           PROTO hDC:HDC, radAngle:REAL4, xCenter:DWORD, yCenter:DWORD

.CODE

MUI_ALIGN
;------------------------------------------------------------------------------
; Center rotate bitmap at an angle and use specified back color to fill
; Returns in eax new hBitmapRotated. Use DeleteObject when finished.
;------------------------------------------------------------------------------
MUIGDIRotateCenterBitmap PROC hWin:DWORD, hBitmap:DWORD, dwAngle:DWORD, dwBackColor:DWORD
    LOCAL hdc:HDC
    LOCAL hdcOriginal:HDC
    LOCAL hdcRotated:HDC
    LOCAL hBitmapOld:DWORD
    LOCAL hBitmapRotated:DWORD
    LOCAL hBitmapRotatedOld:DWORD
    LOCAL hBrush:DWORD
    LOCAL hBrushOld:DWORD
    LOCAL xCenter:DWORD
    LOCAL yCenter:DWORD
    LOCAL rect:RECT
    LOCAL angle:REAL4
    
    Invoke GetDC, hWin
    mov hdc, eax
    
    Invoke GetClientRect, hWin, Addr rect
    
    mov eax, rect.right
    shr eax, 1 ; div by 2
    mov xCenter, eax
    mov eax, rect.bottom
    shr eax, 1 ; div by 2
    mov yCenter, eax
    
    ; Load orignal image
    Invoke CreateCompatibleDC, hdc
    mov hdcOriginal, eax
    Invoke SelectObject, hdcOriginal, hBitmap
    mov hBitmapOld, eax
    
    ; Create new bitmap based on original
    Invoke CreateCompatibleDC, hdc
    mov hdcRotated, eax
    Invoke CreateCompatibleBitmap, hdcOriginal, rect.right, rect.bottom
    mov hBitmapRotated, eax
    Invoke SelectObject, hdcRotated, hBitmapRotated
    mov hBitmapRotatedOld, eax
    
    ; Fill background color of rotated bitmap
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcRotated, hBrush
    mov hBrushOld, eax
    Invoke SetDCBrushColor, hdcRotated, dwBackColor
    inc rect.bottom
    Invoke FillRect, hdcRotated, Addr rect, hBrush
    dec rect.bottom
    Invoke SelectObject, hdcRotated, hBrushOld
    Invoke DeleteObject, hBrushOld
    Invoke DeleteObject, hBrush
    
    ; Rotate the bitmap
    finit
    fild dwAngle ;FP4(25.0)
    fstp angle
    Invoke RotateBitBltAtD, hdcRotated, hdcOriginal, xCenter, yCenter, angle, rect, 0, 0
    
    ; Tidy up
    Invoke SelectObject, hdcOriginal, hBitmapOld
    Invoke DeleteObject, hBitmapOld
    Invoke SelectObject, hdcRotated, hBitmapRotatedOld
    Invoke DeleteObject, hBitmapRotatedOld
    Invoke DeleteDC, hdcOriginal
    Invoke DeleteDC, hdcRotated
    Invoke ReleaseDC, hWin, hdc
    
    mov eax, hBitmapRotated
    
    ret
MUIGDIRotateCenterBitmap ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; From qWord's SWT examples on the masm32 forums
; destRect = rectangle to be rotated at position (xCenter|yCenter) in destination DC
; [angle]=degree
;------------------------------------------------------------------------------
RotateBitBltAtD PROC USES ECX EDX hDestDC:HDC, hSrcDC:HDC, xCenter:DWORD, yCenter:DWORD, angle:REAL4, destRect:RECT, xSrc:DWORD, ySrc:DWORD
    LOCAL xfrm:XFORM
    LOCAL mode:DWORD

	; degree -> radian
	fld angle
	fmul FP4(0.01745329) ;pi/180°
	fstp angle
	
	; save current graphic mode
	Invoke GetGraphicsMode, hDestDC
	mov mode, eax

	; set required graphic mode
	invoke SetGraphicsMode, hDestDC, GM_ADVANCED
	
	; save current world transform
	invoke GetWorldTransform, hDestDC, Addr xfrm
	
	; set new world transform
	invoke GdiSetRot, hDestDC, angle, xCenter, yCenter
	
	; copy to rotated rectangle in dest-DC
	mov ecx, destRect.right
	mov edx, destRect.bottom
	sub ecx, destRect.left
	sub edx, destRect.top
	invoke BitBlt, hDestDC, destRect.left, destRect.top, ecx, edx, hSrcDC, xSrc, ySrc, SRCCOPY

	; restore previous world transform
	invoke SetWorldTransform, hDestDC, Addr xfrm
	
	; restore previous graphic mode
	invoke SetGraphicsMode, hDestDC, mode
	
	mov eax, 1
	ret
RotateBitBltAtD ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; From qWord's SWT examples on the masm32 forums
; destRect = rectangle to be rotated at position (xCenter|yCenter) in destination DC
; [angle]=radian
;------------------------------------------------------------------------------
RotateBitBltAtR PROC USES ECX EDX hDestDC:HDC, hSrcDC:HDC, xCenter:DWORD, yCenter:DWORD, angle:REAL4, destRect:RECT, xSrc:DWORD, ySrc:DWORD
    LOCAL xfrm:XFORM
    LOCAL mode:DWORD

    Invoke GetGraphicsMode, hDestDC
	mov mode, eax
	invoke SetGraphicsMode, hDestDC, GM_ADVANCED
	invoke GetWorldTransform, hDestDC, Addr xfrm
	invoke GdiSetRot, hDestDC, angle, xCenter, yCenter
	mov ecx, destRect.right
	mov edx, destRect.bottom
	sub ecx, destRect.left
	sub edx, destRect.top
	invoke BitBlt, hDestDC, destRect.left, destRect.top, ecx, edx, hSrcDC, xSrc, ySrc, SRCCOPY
	invoke SetWorldTransform, hDestDC, Addr xfrm
	invoke SetGraphicsMode, hDestDC, mode
	
	mov eax,1
	ret
	
RotateBitBltAtR ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; From qWord's SWT examples on the masm32 forums
;------------------------------------------------------------------------------
GdiSetRot PROC hDC:HDC, radAngle:REAL4, xCenter:DWORD, yCenter:DWORD
    LOCAL xform:XFORM
	
	fld radAngle
	fchs
	fsincos
	fld st
	fstp REAL4 ptr xform.eM11
	fld st(1)
	fstp REAL4 ptr xform.eM12
	fld st(1)
	fchs
	fstp REAL4 ptr xform.eM21
	fld st
	fstp REAL4 ptr xform.eM22

	fld st(1)
	fld st(1)
	fimul xCenter
	fchs
	fiadd xCenter
	fxch
	fimul yCenter
	faddp st(1),st
	fstp REAL4 ptr xform.ex
	
	fimul yCenter
	fchs
	fiadd yCenter
	fxch
	fimul xCenter
	fsubp st(1),st
	fstp REAL4 ptr xform.ey
	
;	fSlv xform.eM11 =  cos(-radAngle)
;	fSlv xform.eM12 =  sin(-radAngle)
;	fSlv xform.eM21 = -sin(-radAngle)
;	fSlv xform.eM22 =  cos(-radAngle)
;	fSlv xform.ex = xCenter - cos(-radAngle)*xCenter + sin(-radAngle)*yCenter
;	fSlv xform.ey = yCenter - cos(-radAngle)*yCenter - sin(-radAngle)*xCenter
	
	Invoke SetWorldTransform, hDC, Addr xform
	ret
GdiSetRot ENDP


MODERNUI_LIBEND


