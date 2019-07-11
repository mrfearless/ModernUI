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

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
includelib gdiplus.lib
ENDIF


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Same as MUIPaintBackground, but with an image.
;
; ImageHandleType: 0=none, 1=bmp, 2=ico
; ImageLocation: 0=center center, 1=bottom left, 2=bottom right, 3=top left, 
; 4=top right, 5=center top, 6=center bottom
;------------------------------------------------------------------------------
MUIPaintBackgroundImage PROC USES EBX hWin:MUIWND, BackColor:MUICOLORRGB, BorderColor:MUICOLORRGB, hImage:MUIIMAGE, ImageHandleType:MUIIT, ImageLocation:MUIIL
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL pt:POINT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hBufferBitmap:HBITMAP
    LOCAL hdcMemBmp:HDC
    LOCAL hbmMem:HBITMAP
    LOCAL hbmMemBmp:HBITMAP
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL pBitmap:DWORD
    
    .IF ImageHandleType == MUIIT_PNG
        mov pGraphics, 0
        mov pGraphicsBuffer, 0
        mov pBitmap, 0
    .ENDIF
    
    Invoke BeginPaint, hWin, addr ps
    mov hdc, eax

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke MUIGDIDoubleBufferStart, hWin, hdc, Addr hdcMem, Addr rect, Addr hBufferBitmap

    ;----------------------------------------------------------
    ; Paint background
    ;----------------------------------------------------------
    Invoke MUIGDIPaintFill, hdcMem, Addr rect, BackColor

    ;----------------------------------------------------------
    ; Paint Border
    ;----------------------------------------------------------
    .IF BorderColor != 0
        Invoke MUIGDIPaintFrame, hdcMem, Addr rect, BorderColor, MUIPFS_ALL
    .ENDIF
    
    .IF hImage != NULL
        ;----------------------------------------
        ; Calc left and top of image based on 
        ; client rect and image width and height
        ;----------------------------------------
        Invoke MUIGetImageSize, hImage, ImageHandleType, Addr ImageWidth, Addr ImageHeight

        mov eax, ImageLocation
        .IF eax == MUIIL_CENTER
            mov eax, rect.right
            shr eax, 1
            mov ebx, ImageWidth
            shr ebx, 1
            sub eax, ebx
            mov pt.x, eax
                    
            mov eax, rect.bottom
            shr eax, 1
            mov ebx, ImageHeight
            shr ebx, 1
            sub eax, ebx
            mov pt.y, eax
        
        .ELSEIF eax == MUIIL_BOTTOMLEFT
            mov pt.x, 1
            
            mov eax, rect.bottom
            mov ebx, ImageHeight
            sub eax, ebx
            dec eax
            mov pt.y, eax
        
        .ELSEIF eax == MUIIL_BOTTOMRIGHT
            mov eax, rect.right
            mov ebx, ImageWidth
            sub eax, ebx
            dec eax
            mov pt.x, eax
                    
            mov eax, rect.bottom
            mov ebx, ImageHeight
            sub eax, ebx
            dec eax
            mov pt.y, eax        
        
        .ELSEIF eax == MUIIL_TOPLEFT
            mov pt.x, 1
            mov pt.y, 1
        
        .ELSEIF eax == MUIIL_TOPRIGHT
            mov eax, rect.right
            mov ebx, ImageWidth
            sub eax, ebx
            dec eax
            mov pt.x, eax        
        
        .ELSEIF eax == MUIIL_TOPCENTER
            mov pt.x, 1

            mov eax, rect.bottom
            shr eax, 1
            mov ebx, ImageHeight
            shr ebx, 1
            sub eax, ebx
            mov pt.y, eax            
        
        .ELSEIF eax == MUIIL_BOTTOMCENTER
            mov eax, rect.right
            shr eax, 1
            mov ebx, ImageWidth
            shr ebx, 1
            sub eax, ebx
            mov pt.x, eax
                    
            mov eax, rect.bottom
            mov ebx, ImageHeight
            sub eax, ebx
            dec eax
            mov pt.y, eax
        
        .ENDIF
        
        ;----------------------------------------
        ; Draw image depending on what type it is
        ;----------------------------------------
        mov eax, ImageHandleType
        .IF eax == MUIIT_NONE
            
        .ELSEIF eax == MUIIT_BMP
            Invoke CreateCompatibleDC, hdc
            mov hdcMemBmp, eax
            Invoke SelectObject, hdcMemBmp, hImage
            mov hbmMemBmp, eax
            dec rect.right
            dec rect.bottom
            Invoke BitBlt, hdcMem, pt.x, pt.y, rect.right, rect.bottom, hdcMemBmp, 0, 0, SRCCOPY ;ImageWidth, ImageHeight
            inc rect.right
            inc rect.bottom
            Invoke SelectObject, hdcMemBmp, hbmMemBmp
            Invoke DeleteDC, hdcMemBmp
            .IF hbmMemBmp != 0
                Invoke DeleteObject, hbmMemBmp
            .ENDIF

        .ELSEIF eax == MUIIT_ICO
            Invoke DrawIconEx, hdcMem, pt.x, pt.y, hImage, 0, 0, NULL, NULL, DI_NORMAL ; 0, 0,

        
        .ELSEIF eax == MUIIT_PNG
            IFDEF MUI_USEGDIPLUS
            Invoke GdipCreateFromHDC, hdcMem, Addr pGraphics
            
            Invoke GdipCreateBitmapFromGraphics, ImageWidth, ImageHeight, pGraphics, Addr pBitmap
            Invoke GdipGetImageGraphicsContext, pBitmap, Addr pGraphicsBuffer            
            Invoke GdipDrawImageI, pGraphicsBuffer, hImage, 0, 0
            dec rect.right
            dec rect.bottom               
            Invoke GdipDrawImageRectI, pGraphics, pBitmap, pt.x, pt.y, rect.right, rect.bottom ;ImageWidth, ImageHeight
            inc rect.right
            inc rect.bottom               
            .IF pBitmap != NULL
                Invoke GdipDisposeImage, pBitmap
            .ENDIF
            .IF pGraphicsBuffer != NULL
                Invoke GdipDeleteGraphics, pGraphicsBuffer
            .ENDIF
            .IF pGraphics != NULL
                Invoke GdipDeleteGraphics, pGraphics
            .ENDIF
            ENDIF
        .ENDIF
        
    .ENDIF

    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Finish Double Buffering & Cleanup
    ;----------------------------------------------------------    
    Invoke MUIGDIDoubleBufferFinish, hdcMem, hBufferBitmap, 0, 0, 0, 0    

    invoke EndPaint, hWin, addr ps
    mov eax, 0
    ret
MUIPaintBackgroundImage ENDP


MODERNUI_LIBEND



