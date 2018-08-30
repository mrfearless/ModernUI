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
; dwImageType: 0=none, 1=bmp, 2=ico
; dwImageLocation: 0=center center, 1=bottom left, 2=bottom right, 3=top left, 
; 4=top right, 5=center top, 6=center bottom
;------------------------------------------------------------------------------
MUIPaintBackgroundImage PROC PUBLIC USES EBX hWin:DWORD, dwBackcolor:DWORD, dwBorderColor:DWORD, hImage:DWORD, dwImageType:DWORD, dwImageLocation:DWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL hdc:HDC
    LOCAL rect:RECT
    LOCAL pt:POINT
    LOCAL hdcMem:DWORD
    LOCAL hdcMemBmp:DWORD
    LOCAL hbmMem:DWORD
    LOCAL hbmMemBmp:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL ImageWidth:DWORD
    LOCAL ImageHeight:DWORD
    LOCAL pGraphics:DWORD
    LOCAL pGraphicsBuffer:DWORD
    LOCAL pBitmap:DWORD
    
    .IF dwImageType == MUIIT_PNG
        mov pGraphics, 0
        mov pGraphicsBuffer, 0
        mov pBitmap, 0
    .ENDIF
    
    Invoke BeginPaint, hWin, addr ps
    mov hdc, eax
    Invoke GetClientRect, hWin, Addr rect
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------      
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax 

    ;----------------------------------------------------------
    ; Fill background
    ;----------------------------------------------------------
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdcMem, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdcMem, dwBackcolor
    Invoke FillRect, hdcMem, Addr rect, hBrush

    ;----------------------------------------------------------
    ; Draw border if !0
    ;----------------------------------------------------------
    .IF dwBorderColor != 0
        .IF hOldBrush != 0
            Invoke SelectObject, hdcMem, hOldBrush
            Invoke DeleteObject, hOldBrush
        .ENDIF    
        Invoke GetStockObject, DC_BRUSH
        mov hBrush, eax
        Invoke SelectObject, hdcMem, eax
        mov hOldBrush, eax
        Invoke SetDCBrushColor, hdcMem, dwBorderColor
        Invoke FrameRect, hdcMem, Addr rect, hBrush
    .ENDIF
    
    .IF hImage != NULL
        ;----------------------------------------
        ; Calc left and top of image based on 
        ; client rect and image width and height
        ;----------------------------------------
        Invoke MUIGetImageSize, hImage, dwImageType, Addr ImageWidth, Addr ImageHeight

        mov eax, dwImageLocation
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
        mov eax, dwImageType
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
    ; Cleanup
    ;----------------------------------------------------------
    .IF hOldBrush != 0
        Invoke SelectObject, hdcMem, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    .IF hOldBitmap != 0
        Invoke SelectObject, hdcMem, hOldBitmap
        Invoke DeleteObject, hOldBitmap
    .ENDIF
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem

    invoke EndPaint, hWin, addr ps
    mov eax, 0
    ret

MUIPaintBackgroundImage ENDP


END



