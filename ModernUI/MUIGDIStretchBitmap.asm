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

.DATA
szMUIGDIStretchBitmapDisplayDC DB 'DISPLAY',0

.CODE

; TODO, MUIGDIStretchImage, MUIGDIStretchBitmap, MUIGDIStretchIcon, MUIGDIStretchPng


MUI_ALIGN
;------------------------------------------------------------------------------
; MUIGDIStretchBitmap - Returns new stretch bitmap in eax. Bitmap is scaled to
; fit rectangle specified by lpBoundsRect. On return the new bitmap height and 
; width are returned in lpdwBitmapWidth and lpdwBitmapHeight. Additionaly the
; x and y positioning to center the new bitmap in the rectangle specified by
; lpBoundsRect are returned in lpdwX and lpdwY.
;------------------------------------------------------------------------------
MUIGDIStretchBitmap PROC USES EBX hBitmap:HBITMAP, lpBoundsRect:LPRECT, lpBitmapWidth:LPMUIVALUE, lpBitmapHeight:LPMUIVALUE, lpBitmapX:LPMUIVALUE, lpBitmapY:LPMUIVALUE
    LOCAL dwBitmapWidth:DWORD
    LOCAL dwBitmapHeight:DWORD
    LOCAL dwNewBitmapWidth:DWORD
    LOCAL dwNewBitmapHeight:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL dwWidthRatio:DWORD
    LOCAL dwHeightRatio:DWORD    
    LOCAL X:DWORD
    LOCAL Y:DWORD
    LOCAL BoundsRect:RECT
    LOCAL hdc:HDC
    LOCAL hdcBitmap:HDC
    LOCAL hStretchedBitmap:DWORD
    LOCAL hStretchedBitmapOld:DWORD
    LOCAL hBitmapOld:DWORD
    
    .IF hBitmap == 0 || lpBoundsRect == 0
        .IF lpBitmapWidth != 0
            mov ebx, lpBitmapWidth
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        .IF lpBitmapHeight != 0
            mov ebx, lpBitmapHeight
            mov eax, 0
            mov [ebx], eax
        .ENDIF
        .IF lpBitmapX != 0
            mov ebx, lpBitmapX
            mov eax, 0
            mov [ebx], eax    
        .ENDIF
        .IF lpBitmapY != 0
            mov ebx, lpBitmapY
            mov eax, 0
            mov [ebx], eax
        .ENDIF    
        mov eax, 0
        ret
    .ENDIF
    
    Invoke CopyRect, Addr BoundsRect, lpBoundsRect
    Invoke MUIGetImageSize, hBitmap, MUIIT_BMP, Addr dwBitmapWidth, Addr dwBitmapHeight

    mov eax, BoundsRect.right
    sub eax, BoundsRect.left
    mov dwWidth, eax
    mov eax, BoundsRect.bottom
    sub eax, BoundsRect.top
    mov dwHeight, eax
    
    finit
    fild dwBitmapWidth
    fild dwWidth
    fdiv
    fistp dwWidthRatio
    
    fild dwBitmapHeight
    fild dwHeight
    fdiv
    fistp dwHeightRatio

    mov eax, dwWidthRatio
    .IF eax >= dwHeightRatio ; Width constrained
        mov eax, dwWidth
        mov dwNewBitmapWidth, eax

        fild dwNewBitmapWidth
        fild dwBitmapWidth
        fdiv
        fld st
        fild dwBitmapHeight
        fmul
        fistp dwNewBitmapHeight
        
    .ELSE ; Height constrained
        mov eax, dwHeight
        mov dwNewBitmapHeight, eax    

        fild dwNewBitmapHeight
        fild dwBitmapHeight
        fdiv
        fld st
        fild dwBitmapWidth
        fmul
        fistp dwNewBitmapWidth  
          
    .ENDIF
    
    ; calc centering position
    mov eax, dwWidth
    sub eax, dwNewBitmapWidth
    shr eax, 1 ; div by 2
    mov X, eax
    
    mov eax, dwHeight
    sub eax, dwNewBitmapHeight
    shr eax, 1 ; div by 2
    mov Y, eax    
    
    Invoke CreateDC, Addr szMUIGDIStretchBitmapDisplayDC, NULL, NULL, NULL
    mov hdc, eax
    
    Invoke CreateCompatibleBitmap, hdc, dwNewBitmapWidth, dwNewBitmapHeight
    mov hStretchedBitmap, eax
    Invoke SelectObject, hdc, hStretchedBitmap
    mov hStretchedBitmapOld, eax    

    Invoke CreateCompatibleDC, hdc
    mov hdcBitmap, eax
    Invoke SelectObject, hdcBitmap, hBitmap
    mov hBitmapOld, eax

    Invoke SetStretchBltMode, hdc, HALFTONE
    Invoke SetBrushOrgEx, hdc, 0, 0, 0
    Invoke StretchBlt, hdc, 0, 0, dwNewBitmapWidth, dwNewBitmapHeight, hdcBitmap, 0, 0, dwBitmapWidth, dwBitmapHeight, SRCCOPY        

    Invoke SelectObject, hdcBitmap, hBitmapOld
    Invoke DeleteObject, hBitmapOld
    Invoke DeleteDC, hdcBitmap
    Invoke SelectObject, hdc, hStretchedBitmapOld
    Invoke DeleteObject, hStretchedBitmapOld     
    Invoke DeleteDC, hdc

    .IF lpBitmapWidth != 0
        mov ebx, lpBitmapWidth
        mov eax, dwNewBitmapWidth
        mov [ebx], eax
    .ENDIF

    .IF lpBitmapHeight != 0
        mov ebx, lpBitmapHeight
        mov eax, dwNewBitmapHeight
        mov [ebx], eax
    .ENDIF

    .IF lpBitmapX != 0
        mov ebx, lpBitmapX
        mov eax, X
        mov [ebx], eax    
    .ENDIF

    .IF lpBitmapY != 0
        mov ebx, lpBitmapY
        mov eax, Y
        mov [ebx], eax
    .ENDIF

    mov eax, hStretchedBitmap
    ret
MUIGDIStretchBitmap ENDP


MODERNUI_LIBEND


;MUIGDIStretchPng PROC
;    Invoke GdipCreateFromHDC, hdcMem, Addr pGraphics
;    
;    Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
;    Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer            
;    Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
;    Invoke GdipDrawImageRectI, pGraphics, pBitmap, pt.x, pt.y, ImageWidth, ImageHeight
;    .IF pBitmap != NULL
;        Invoke GdipDisposeImage, pBitmap
;    .ENDIF
;    .IF pGraphicsBuffer != NULL
;        Invoke GdipDeleteGraphics, pGraphicsBuffer
;    .ENDIF
;    .IF pGraphics != NULL
;        Invoke GdipDeleteGraphics, pGraphics
;    .ENDIF
;    ret
;MUIGDIStretchPng ENDP


;pBitmap2 := Gdip_CreateBitmap(NewWidth, NewHeight)
;	G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
;	Gdip_DrawImage(G2, pBitmap, 0, 0, NewWidth, NewHeight)
;	Gdip_DeleteGraphics(G2)
;	if Dispose
;		Gdip_DisposeImage(pBitmap)
;	return pBitmap2


;	    Invoke GdipSetPageUnit, pGraphics, UnitPixel     
;        invoke GdipSetSmoothingMode, pGraphics, SmoothingModeAntiAlias
;	    invoke GdipSetPixelOffsetMode, pGraphics, PixelOffsetModeHighQuality
;        invoke GdipSetInterpolationMode, pGraphics, InterpolationModeHighQualityBicubic






