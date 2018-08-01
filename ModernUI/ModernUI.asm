;======================================================================================================================================
;
; ModernUI Library v0.0.0.5
;
; Copyright (c) 2016 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;======================================================================================================================================


.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

MUI_USEGDIPLUS EQU 1 ; comment out of you dont require png (gdiplus) support

;DEBUG32 EQU 1
;
;IFDEF DEBUG32
;    PRESERVEXMMREGS equ 1
;    includelib M:\Masm32\lib\Debug32.lib
;    DBG32LIB equ 1
;    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
;    include M:\Masm32\include\debug32.inc
;ENDIF

include windows.inc

include kernel32.inc
include user32.inc
include gdi32.inc

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
ENDIF

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

IFDEF MUI_USEGDIPLUS
includelib gdiplus.lib
ENDIF

include ModernUI.inc

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUIGetProperty                 PROTO :DWORD, :DWORD, :DWORD           ; hControl, cbWndExtraOffset, dwProperty
_MUISetProperty                 PROTO :DWORD, :DWORD, :DWORD, :DWORD   ; hControl, cbWndExtraOffset, dwProperty, dwPropertyValue



;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
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

.CONST



.DATA
IFDEF MUI_USEGDIPLUS
MUI_GDIPLUS                     DD 0 ; controls that use gdiplus check this first, if 0 they call gdi startup and inc the value
                                     ; controls that use gdiplus when destroyed decrement this value and check if 0. If 0 they call gdi finish

MUI_GDIPlusToken                DD 0
MUI_gdipsi                      GdiplusStartupInput <1,0,0,0>
ENDIF

szMUIBitmapFromMemoryDisplayDC  DB 'DISPLAY',0

.CODE

align 4

;======================================================================================================================================
; PRIVATE FUNCTIONS
;
; These functions are intended for use with controls created for the ModernUI framework
; even though they are PUBLIC they are prefixed with _ to indicate for internal use.
; Only ModernUI controls should call these functions directly.
;
; The exception to this is the MUIGetProperty and MUISetProperty which are for
; users of the ModernUI controls to use for getting and setting external properties.
;
;======================================================================================================================================



;-------------------------------------------------------------------------------------
; Start of ModernUI framework (wrapper for gdiplus startup)
; Placed at start of program before WinMain call
;-------------------------------------------------------------------------------------
IFDEF MUI_USEGDIPLUS
MUIGDIPlusStart PROC PUBLIC
    .IF MUI_GDIPLUS == 0
        ;PrintText 'GdiplusStartup'
        Invoke GdiplusStartup, Addr MUI_GDIPlusToken, Addr MUI_gdipsi, NULL
    .ENDIF
    inc MUI_GDIPLUS
    ;PrintDec MUI_GDIPLUS
    xor eax, eax
    ret
MUIGDIPlusStart ENDP
ENDIF

;-------------------------------------------------------------------------------------
; Finish ModernUI framework (wrapper for gdiplus shutdown)
; Placed after WinMain call before ExitProcess
;-------------------------------------------------------------------------------------
IFDEF MUI_USEGDIPLUS
MUIGDIPlusFinish PROC PUBLIC
    ;PrintDec MUI_GDIPLUS
    dec MUI_GDIPLUS
    .IF MUI_GDIPLUS == 0
        ;PrintText 'GdiplusShutdown'
        Invoke GdiplusShutdown, MUI_GDIPlusToken
    .ENDIF
    xor eax, eax
    ret
MUIGDIPlusFinish ENDP
ENDIF

;-------------------------------------------------------------------------------------
; Gets the pointer to memory allocated to control at startup and stored in cbWinExtra
; adds the offset to property to this pointer and fetches value at this location and
; returns it in eax.
; Properties are defined as constants, which are used as offsets in memory to the 
; data alloc'd
; for example: @MouseOver EQU 0, @SelectedState EQU 4
; we might specify 4 in cbWndExtra and then GlobalAlloc 8 bytes of data to control at 
; startup and store this pointer with SetWindowLong, hControl, 0, pMem
; pMem is our pointer to our 8 bytes of storage, of which first four bytes (dword) is
; used for our @MouseOver property and the next dword for @SelectedState 
; cbWndExtraOffset is usually going to be 0 for custom registered window controls
; and some other offset for superclassed window control
;-------------------------------------------------------------------------------------
_MUIGetProperty PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwProperty:DWORD
    
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    
    ret

_MUIGetProperty ENDP


;-------------------------------------------------------------------------------------
; Sets property value and returns previous value in eax.
;-------------------------------------------------------------------------------------
_MUISetProperty PROC PUBLIC USES EBX hControl:DWORD, cbWndExtraOffset:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax == 0
        ret
    .ENDIF    
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    mov dwPrevValue, eax    
    mov eax, dwPropertyValue
    mov [ebx], eax
    mov eax, dwPrevValue
    ret

_MUISetProperty ENDP


;-------------------------------------------------------------------------------------
; Allocs memory for the properties of a control
;-------------------------------------------------------------------------------------
MUIAllocMemProperties PROC PUBLIC hControl:DWORD, cbWndExtraOffset:DWORD, dwSize:DWORD
    LOCAL pMem:DWORD
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, dwSize
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov pMem, eax
    
    Invoke SetWindowLong, hControl, cbWndExtraOffset, pMem
    
    mov eax, TRUE
    ret
MUIAllocMemProperties ENDP


;-------------------------------------------------------------------------------------
; Frees memory for the properties of a control
;-------------------------------------------------------------------------------------
MUIFreeMemProperties PROC PUBLIC hControl:DWORD, cbWndExtraOffset:DWORD
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax != NULL
        invoke GlobalFree, eax
        Invoke SetWindowLong, hControl, cbWndExtraOffset, 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret
MUIFreeMemProperties ENDP


;======================================================================================================================================
; PUBLIC FUNCTIONS
;======================================================================================================================================


;-------------------------------------------------------------------------------------
; Gets external property value and returns it in eax
;-------------------------------------------------------------------------------------
MUIGetExtProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_EXTERNAL_PROPERTIES, dwProperty ; get external properties
    ret
MUIGetExtProperty ENDP


;-------------------------------------------------------------------------------------
; Sets external property value and returns previous value in eax.
;-------------------------------------------------------------------------------------
MUISetExtProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, MUI_EXTERNAL_PROPERTIES, dwProperty, dwPropertyValue ; set external properties
    ret
MUISetExtProperty ENDP


;-------------------------------------------------------------------------------------
; Gets internal property value and returns it in eax
;-------------------------------------------------------------------------------------
MUIGetIntProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke _MUIGetProperty, hControl, MUI_INTERNAL_PROPERTIES, dwProperty ; get internal properties
    ret
MUIGetIntProperty ENDP


;-------------------------------------------------------------------------------------
; Sets internal property value and returns previous value in eax.
;-------------------------------------------------------------------------------------
MUISetIntProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke _MUISetProperty, hControl, MUI_INTERNAL_PROPERTIES, dwProperty, dwPropertyValue ; set internal properties
    ret
MUISetIntProperty ENDP


;-------------------------------------------------------------------------------------
; Convert font point size eg '12' to logical unit size for use with CreateFont,
; CreateFontIndirect
;-------------------------------------------------------------------------------------
MUIPointSizeToLogicalUnit PROC PUBLIC hWin:DWORD, dwPointSize:DWORD
    LOCAL hdc:HDC
    LOCAL dwLogicalUnit:DWORD
    
    Invoke GetDC, hWin
    mov hdc, eax
    Invoke SetMapMode, hdc, MM_TEXT
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    Invoke MulDiv, dwPointSize, eax, 72d
    neg eax
    mov dwLogicalUnit, eax
    Invoke ReleaseDC, hWin, hdc
    mov eax, dwLogicalUnit
    ret
MUIPointSizeToLogicalUnit ENDP


;-------------------------------------------------------------------------------------
; Applies the ModernUI style to a dialog to make it a captionless, borderless form. 
; User can manually change a form in a resource editor to have the following style
; flags: WS_POPUP or WS_VISIBLE and optionally with DS_CENTER /DS_CENTERMOUSE / 
; WS_CLIPCHILDREN / WS_CLIPSIBLINGS / WS_MINIMIZE / WS_MAXIMIZE
;-------------------------------------------------------------------------------------
MUIApplyToDialog PROC PUBLIC hWin:DWORD, dwDropShadow:DWORD, dwClipping:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwNewStyle:DWORD
    LOCAL dwClassStyle:DWORD

    mov dwNewStyle, WS_POPUP
    
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    and eax, DS_CENTER
    .IF eax == DS_CENTER
        or dwNewStyle, DS_CENTER
    .ENDIF
    
    mov eax, dwStyle
    and eax, DS_CENTERMOUSE
    .IF eax == DS_CENTERMOUSE
        or dwNewStyle, DS_CENTERMOUSE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_VISIBLE
    .IF eax == WS_VISIBLE
        or dwNewStyle, WS_VISIBLE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_MINIMIZE
    .IF eax == WS_MINIMIZE
        or dwNewStyle, WS_MINIMIZE
    .ENDIF
    
    mov eax, dwStyle
    and eax, WS_MAXIMIZE
    .IF eax == WS_MAXIMIZE
        or dwNewStyle, WS_MAXIMIZE
    .ENDIF        

    .IF dwClipping == TRUE
        mov eax, dwStyle
        and eax, WS_CLIPSIBLINGS
        .IF eax == WS_CLIPSIBLINGS
            or dwNewStyle, WS_CLIPSIBLINGS
        .ENDIF        
        or dwNewStyle, WS_CLIPCHILDREN
    .ENDIF

    Invoke SetWindowLong, hWin, GWL_STYLE, dwNewStyle
    
    ; Set dropshadow on or off on our dialog
    
    Invoke GetClassLong, hWin, GCL_STYLE
    mov dwClassStyle, eax
    
    .IF dwDropShadow == TRUE
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax != CS_DROPSHADOW
            or dwClassStyle, CS_DROPSHADOW
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
        .ENDIF
    .ELSE    
        mov eax, dwClassStyle
        and eax, CS_DROPSHADOW
        .IF eax == CS_DROPSHADOW
            and dwClassStyle,(-1 xor CS_DROPSHADOW)
            Invoke SetClassLong, hWin, GCL_STYLE, dwClassStyle
        .ENDIF
    .ENDIF

    ; remove any menu that might have been assigned via class registration - for modern ui look
    Invoke GetMenu, hWin
    .IF eax != NULL
        Invoke SetMenu, hWin, NULL
    .ENDIF

    Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED

    ret

MUIApplyToDialog ENDP


;-------------------------------------------------------------------------------------
; Center child window hWndChild into parent window or desktop if hWndParent is NULL. 
; Parent doesnt need to be the owner.
; No returned value
;-------------------------------------------------------------------------------------
MUICenterWindow PROC hWndChild:DWORD, hWndParent:DWORD
    LOCAL rectChild:RECT         ; Child window coordonate
    LOCAL rectParent:RECT        ; Parent window coordonate
    LOCAL rectDesktop:RECT       ; Desktop coordonate (WORKAREA)
    LOCAL dwChildLeft:DWORD      ;
    LOCAL dwChildTop:DWORD       ; Child window new coordonate
    LOCAL dwChildWidth:DWORD     ; used by MoveWindow
    LOCAL dwChildHeight:DWORD    ;
    LOCAL bParentMinimized:DWORD ; Is parent window minimized
    LOCAL bParentVisible:DWORD   ; Is parent window visible

    Invoke IsIconic, hWndParent
    mov bParentMinimized, eax
    
    Invoke IsWindowVisible, hWndParent
    mov bParentVisible, eax

    Invoke GetWindowRect, hWndChild, addr rectChild
    .IF eax != 0    ; 0 = no centering possible

        Invoke SystemParametersInfo, SPI_GETWORKAREA, NULL, addr rectDesktop, NULL
        .IF eax != 0    ; 0 = no centering possible
            
            .IF bParentMinimized == FALSE || bParentVisible == FALSE || hWndParent == NULL ; use desktop space
                mov eax, rectDesktop.left
                mov rectParent.left, eax
                mov eax, rectDesktop.top
                mov rectParent.top, eax
                mov eax, rectDesktop.right
                mov rectParent.right, eax
                mov eax, rectDesktop.bottom
                mov rectParent.bottom, eax
            .ELSE
                Invoke GetWindowRect, hWndParent, addr rectParent
                .IF eax == 0    ; 0 = we take the desktop as parent (invalid or NULL hWndParent)
                    mov eax, rectDesktop.left
                    mov rectParent.left, eax
                    mov eax, rectDesktop.top
                    mov rectParent.top, eax
                    mov eax, rectDesktop.right
                    mov rectParent.right, eax
                    mov eax, rectDesktop.bottom
                    mov rectParent.bottom, eax
                .ENDIF
            .ENDIF
            ;
            ; Get new coordonate and make sure the child window
            ; is not moved outside the desktop workarea
            ;
            mov eax, rectChild.right                   ; width = right - left
            sub eax, rectChild.left
            mov dwChildWidth, eax
            mov eax, rectParent.right
            sub eax, rectParent.left
            sub eax, dwChildWidth                      ; eax = Parent width - Child width...
            sar eax, 1                                 ; divided by 2
            add eax, rectParent.left                   ; eax = temporary left coord (need validation)
            .IF sdword ptr eax < rectDesktop.left
                mov eax, rectDesktop.left
            .ENDIF
            mov dwChildLeft, eax
            add eax, dwChildWidth                      ; eax = new left coord + child width
            .IF sdword ptr eax > rectDesktop.right     ; if child right outside desktop workarea
                mov eax, rectDesktop.right
                sub eax, dwChildWidth                  ; right = desktop right - child width
                mov dwChildLeft, eax                   ;
            .ENDIF

            mov eax, rectChild.bottom                  ; height = bottom - top
            sub eax, rectChild.top
            mov dwChildHeight, eax
            mov eax, rectParent.bottom
            sub eax, rectParent.top
            sub eax, dwChildHeight                     ; eax = Parent height - Child height...
            sar eax, 1
            add eax, rectParent.top
            .IF sdword ptr eax < rectDesktop.top       ; eax (child top) must not be smaller, if so...
                mov eax, rectDesktop.top               ; child top = Desktop.top
            .ENDIF
            mov dwChildTop, eax
            add eax, dwChildHeight                     ; eax = new top coord + child height
            .IF sdword ptr eax > rectDesktop.bottom
                mov eax, rectDesktop.bottom            ; child is outside desktop bottom
                sub eax, dwChildHeight                 ; child top = Desktop.bottom - child height
                mov dwChildTop, eax                    ;
           .ENDIF
           ;
           ; Now we have the new coordonate - the dialog window can be moved
           ;
           Invoke MoveWindow, hWndChild, dwChildLeft, dwChildTop, dwChildWidth, dwChildHeight, TRUE
        .ENDIF
    .ENDIF
    xor eax, eax
    ret

MUICenterWindow ENDP




;-------------------------------------------------------------------------------------
; Paint the background of the main window specified color
; optional provide dwBorderColor for border. If dwBorderColor = 0, no border is drawn
; if you require black for border, use 1, or MUI_RGBCOLOR(1,1,1)
;
; If you are using this on a window/dialog that does not use the ModernUI_CaptionBar
; control AND window/dialog is resizable, you should place a call to InvalideRect
; in the WM_NCCALCSIZE handler to prevent ugly drawing artifacts when border is drawn
; whilst resize of window/dialog occurs. The ModernUI_CaptionBar handles this call to 
; WM_NCCALCSIZE already by default. Here is an example of what to include if you need:
;
;    .ELSEIF eax == WM_NCCALCSIZE
;        Invoke InvalidateRect, hWin, NULL, TRUE
; 
;-------------------------------------------------------------------------------------
MUIPaintBackground PROC PUBLIC hWin:DWORD, dwBackcolor:DWORD, dwBorderColor:DWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL hdc:HDC
    LOCAL rect:RECT
    LOCAL hdcMem:DWORD
    LOCAL hbmMem:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD

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
    
    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

;    .IF dwBorderColor != 0
;        Invoke GetStockObject, DC_BRUSH
;        mov hBrush, eax
;        Invoke SelectObject, hdc, eax
;        Invoke SetDCBrushColor, hdc, dwBorderColor
;        Invoke FrameRect, hdc, Addr rect, hBrush
;    .ENDIF

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

    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem
    Invoke DeleteObject, hOldBitmap
    Invoke ReleaseDC, hWin, hdc
    
    Invoke EndPaint, hWin, addr ps
    mov eax, 0
    ret

MUIPaintBackground ENDP


;-------------------------------------------------------------------------------------
; Same as MUIPaintBackground, but with an image (dwImageType 0=none, 1=bmp, 2=ico)
; dwImageLocation: 0=center center, 1=bottom left, 2=bottom right, 3=top left, 
; 4=top right, 5=center top, 6=center bottom
;-------------------------------------------------------------------------------------
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
    Invoke SelectObject, hdcMem, hbmMem
    Invoke DeleteObject, hbmMem
    Invoke DeleteDC, hdcMem
    Invoke DeleteObject, hOldBitmap
    invoke ReleaseDC, hWin, hdc
    
    invoke EndPaint, hWin, addr ps
    mov eax, 0
    ret

MUIPaintBackgroundImage ENDP


;-------------------------------------------------------------------------------------
; Gets parent background color
; returns in eax, MUI_RGBCOLOR or -1 if NULL brush is set
; Useful for certain controls to retrieve the parents background color and then to 
; set their own background color based on the same value.
;-------------------------------------------------------------------------------------
MUIGetParentBackgroundColor PROC PUBLIC hControl:DWORD
    LOCAL hParent:DWORD
    LOCAL hBrush:DWORD
    LOCAL logbrush:LOGBRUSH
    
    Invoke GetParent, hControl
    mov hParent, eax
    
    Invoke GetClassLong, hParent, GCL_HBRBACKGROUND
    .IF eax == NULL
        ;PrintText 'GetClassLong, hParent, GCL_HBRBACKGROUND = NULL'
        mov eax, -1
        ret
    .ENDIF
    
    .IF eax > 32d
        mov hBrush, eax
        Invoke GetObject, hBrush, SIZEOF LOGBRUSH, Addr logbrush
        .IF eax == 0
            ;PrintText 'GetObject, hBrush, SIZEOF LOGBRUSH, Addr logbrush = 0'
            mov eax, -1
            ret
        .ENDIF
        mov eax, logbrush.lbColor
    .ELSE
        dec eax ; to adjust for initial value being COLOR_X+1
        Invoke GetSysColor, eax
        ret
    .ENDIF

    ret
MUIGetParentBackgroundColor ENDP


;-------------------------------------------------------------------------------------
; Gets parent's background bitmap from parent DC, at the child's location and size
; For use in setting background of child to 'transparent'
; returns hBitmap or NULL
;-------------------------------------------------------------------------------------
MUIGetParentBackgroundBitmap PROC PUBLIC USES EBX hControl:DWORD
    LOCAL rcWin:RECT
    LOCAL rcWnd:RECT
    LOCAL parWnd:DWORD
    LOCAL parDc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hOldBitmap:DWORD
	LOCAL dwWidth:DWORD
	LOCAL dwHeight:DWORD      

    Invoke GetParent, hControl; // Get the parent window.
    mov parWnd, eax
    Invoke GetDC, parWnd; // Get its DC.
    mov parDc, eax 
    ;Invoke UpdateWindow, hWnd
    Invoke GetWindowRect, hControl, Addr rcWnd;
    Invoke ScreenToClient, parWnd, Addr rcWnd; // Convert to the parent's co-ordinates
    Invoke GetClipBox, parDc, Addr rcWin
    ; Copy from parent DC.
    mov eax, rcWin.right
    mov ebx, rcWin.left
    sub eax, ebx
    mov dwWidth, eax
    
    mov eax, rcWin.bottom
    mov ebx, rcWin.top
    sub eax, ebx
    mov dwHeight, eax    

    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke CreateCompatibleDC, parDc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, parDc, dwWidth, dwHeight
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax

    Invoke BitBlt, hdcMem, 0, 0, dwWidth, dwHeight, parDc, rcWnd.left, rcWnd.top, SRCCOPY;

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    Invoke SelectObject, hdcMem, hOldBitmap
    Invoke DeleteDC, hdcMem
    ;Invoke DeleteObject, hbmMem
    .IF hOldBitmap != 0
        Invoke DeleteObject, hOldBitmap
    .ENDIF          
    Invoke ReleaseDC, parWnd, parDc
    
    mov eax, hbmMem
    ret

MUIGetParentBackgroundBitmap ENDP


;-------------------------------------------------------------------------------------
; MUIGetImageSize
;-------------------------------------------------------------------------------------
MUIGetImageSize PROC PRIVATE USES EBX hImage:DWORD, dwImageType:DWORD, lpdwImageWidth:DWORD, lpdwImageHeight:DWORD
    LOCAL bm:BITMAP
    LOCAL iinfo:ICONINFO
    LOCAL nImageWidth:DWORD
    LOCAL nImageHeight:DWORD

    mov eax, dwImageType
    .IF eax == MUIIT_NONE
        mov eax, 0
        mov ebx, lpdwImageWidth
        mov [ebx], eax
        mov ebx, lpdwImageHeight
        mov [ebx], eax    
        mov eax, FALSE
        ret
        
    .ELSEIF eax == MUIIT_BMP ; bitmap/icon
        Invoke RtlZeroMemory, Addr bm, SIZEOF BITMAP
        Invoke GetObject, hImage, SIZEOF bm, Addr bm
        .IF eax != 0
            mov eax, bm.bmWidth
            mov ebx, lpdwImageWidth
            mov [ebx], eax
            mov eax, bm.bmHeight
            mov ebx, lpdwImageHeight
            mov [ebx], eax
        .ELSE
            mov eax, 0
            mov ebx, lpdwImageWidth
            mov [ebx], eax
            mov eax, 0
            mov ebx, lpdwImageHeight
            mov [ebx], eax
        .ENDIF
    
    .ELSEIF eax == MUIIT_ICO ; icon    
        Invoke GetIconInfo, hImage, Addr iinfo ; get icon information
        mov eax, iinfo.hbmColor ; bitmap info of icon has width/height
        .IF eax != NULL
            Invoke GetObject, iinfo.hbmColor, SIZEOF bm, Addr bm
            mov eax, bm.bmWidth
            mov ebx, lpdwImageWidth
            mov [ebx], eax
            mov eax, bm.bmHeight
            mov ebx, lpdwImageHeight
            mov [ebx], eax
        .ELSE ; Icon has no color plane, image width/height data stored in mask
            mov eax, iinfo.hbmMask
            .IF eax != NULL
                Invoke GetObject, iinfo.hbmMask, SIZEOF bm, Addr bm
                mov eax, bm.bmWidth
                mov ebx, lpdwImageWidth
                mov [ebx], eax
                mov eax, bm.bmHeight
                shr eax, 1 ;bmp.bmHeight / 2;
                mov ebx, lpdwImageHeight
                mov [ebx], eax                
            .ENDIF
        .ENDIF
        ; free up color and mask icons created by the GetIconInfo function
        mov eax, iinfo.hbmColor
        .IF eax != NULL
            Invoke DeleteObject, eax
        .ENDIF
        mov eax, iinfo.hbmMask
        .IF eax != NULL
            Invoke DeleteObject, eax
        .ENDIF
    
    .ELSEIF eax == MUIIT_PNG ; png
        IFDEF MUI_USEGDIPLUS
        Invoke GdipGetImageWidth, hImage, Addr nImageWidth
        Invoke GdipGetImageHeight, hImage, Addr nImageHeight
        mov eax, nImageWidth
        mov ebx, lpdwImageWidth
        mov [ebx], eax
        mov eax, nImageHeight
        mov ebx, lpdwImageHeight
        mov [ebx], eax
        ENDIF
    .ENDIF
    
    mov eax, TRUE
    ret

MUIGetImageSize ENDP


;--------------------------------------------------------------------------------------------------------------------
; Dynamically allocates or resizes a memory location based on items in a structure and the size of the structure
;
; StructMemPtr is an address to receive the pointer to memory location of the base structure in memory.
; StructMemPtr can be NULL if TotalItems are 0. Otherwise it must contain the address of the base structure in memory
; if the memory is to be increased, TotalItems > 0
; ItemSize is typically SIZEOF structure to be allocated (this function calcs for you the size * TotalItems)
; If StructMemPtr is NULL then memory object is initialized to the size of total items * itemsize and pointer to mem
; is returned in eax.
; On return eax contains the pointer to the new structure item or -1 if there was a problem alloc'ing memory.
;--------------------------------------------------------------------------------------------------------------------
MUIAllocStructureMemory PROC USES EBX dwPtrStructMem:DWORD, TotalItems:DWORD, ItemSize:DWORD
    LOCAL StructDataOffset:DWORD
    LOCAL StructSize:DWORD
    LOCAL StructData:DWORD
    
    ;PrintText 'AllocStructureMemory'
    .IF TotalItems == 0
        Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, ItemSize ;
        .IF eax != NULL
            mov StructData, eax
            mov ebx, dwPtrStructMem
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
        
        .IF dwPtrStructMem != NULL
        
            ; calc new size to grow structure and offset to new entry
            mov eax, TotalItems
            inc eax
            mov ebx, ItemSize
            mul ebx
            mov StructSize, eax ; save new size to alloc mem for
            mov ebx, ItemSize
            sub eax, ebx
            mov StructDataOffset, eax ; save offset for new entry
            
            mov ebx, dwPtrStructMem ; get value from addr of passed dword dwPtrStructMem into eax, this is our pointer to previous mem location of structure
            mov eax, [ebx]
            mov StructData, eax
            ;IFDEF DEBUG32
            ;    PrintDec StructData
            ;    PrintDec StructSize
            ;ENDIF
            
            .IF TotalItems >= 2
                Invoke GlobalUnlock, StructData
            .ENDIF
            Invoke GlobalReAlloc, StructData, StructSize, GMEM_ZEROINIT + GMEM_MOVEABLE ; resize memory for structure
            .IF eax != NULL
                ;PrintDec eax
                Invoke GlobalLock, eax
                mov StructData, eax
                
                mov ebx, dwPtrStructMem
                mov [ebx], eax ; save new pointer to memory alloc'd for structure back to dword address passed as dwPtrStructMem
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
            Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, StructSize ;GMEM_FIXED+GMEM_ZEROINIT
            .IF eax != NULL
                mov StructData, eax
                ;mov ebx, dwPtrStructMem ; alloc memory so dont return anything to this as it was null when we got it
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


;--------------------------------------------------------------------------------------------------------------------
;CreateIconFromData
; Creates an icon from icon data stored in the DATA or CONST SECTION
; (The icon data is an ICO file stored directly in the executable)
;
; Parameters
;   pIconData = Pointer to the ico file data
;   iIcon = zero based index of the icon to load
;
; If successful will return an icon handle, this handle must be freed
; using DestroyIcon when it is no longer needed. The size of the icon
; is returned in EDX, the high order word contains the width and the
; low order word the height.
; 
; Returns 0 if there is an error.
; If the index is greater than the number of icons in the file EDX will
; be set to the number of icons available otherwise EDX is 0. To find
; the number of available icons set the index to -1
;
;http://www.masmforum.com/board/index.php?topic=16267.msg134434#msg134434
;--------------------------------------------------------------------------------------------------------------------
MUICreateIconFromMemory PROC USES EDX pIconData:DWORD, iIcon:DWORD
    LOCAL sz[2]:DWORD

    xor eax, eax
    mov edx, [pIconData]
    or edx, edx
    jz ERRORCATCH

    movzx eax, WORD PTR [edx+4]
    cmp eax, [iIcon]
    ja @F
        ERRORCATCH:
        push eax
        invoke SetLastError, ERROR_RESOURCE_NAME_NOT_FOUND
        pop edx
        xor eax, eax
        ret
    @@:

    mov eax, [iIcon]
    shl eax, 4
    add edx, eax
    add edx, 6

    movzx eax, BYTE PTR [edx]
    mov [sz], eax
    movzx eax, BYTE PTR [edx+1]
    mov [sz+4], eax

    mov eax, [edx+12]
    add eax, [pIconData]
    mov edx, [edx+8]

    invoke CreateIconFromResourceEx, eax, edx, 1, 030000h, [sz], [sz+4], 0

    mov edx,[sz]
    shl edx,16
    mov dx, word ptr [sz+4]

    ret

MUICreateIconFromMemory ENDP


;--------------------------------------------------------------------------------------------------------------------
;MUICreateCursorFromMemory
; Creates a cursor from icon/cursor data stored in the DATA or CONST SECTION
; (The cursor data is an CUR file stored directly in the executable)
;
; Parameters
;   pCursorData = Pointer to the cursor file data

;--------------------------------------------------------------------------------------------------------------------
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


;-------------------------------------------------------------------------------------
; MUICreateBitmapFromMemory
;
; http://www.masmforum.com/board/index.php?topic=16267.msg134453#msg134453
;-------------------------------------------------------------------------------------
MUICreateBitmapFromMemory PROC USES ECX EDX pBitmapData:DWORD
    LOCAL hDC:DWORD
    LOCAL hBmp:DWORD

    ;Invoke GetDC,hWnd
    Invoke CreateDC, Addr szMUIBitmapFromMemoryDisplayDC, NULL, NULL, NULL
    test    eax,eax
    jz      @f
    mov     hDC,eax
    mov     edx,pBitmapData
    lea     ecx,[edx + SIZEOF BITMAPFILEHEADER]  ; start of the BITMAPINFOHEADER header
    mov     eax,BITMAPFILEHEADER.bfOffBits[edx]
    add     edx,eax
    Invoke  CreateDIBitmap,hDC,ecx,CBM_INIT,edx,ecx,DIB_RGB_COLORS
    mov     hBmp,eax
    ;Invoke  ReleaseDC,hWnd,hDC
    Invoke DeleteDC, hDC
    mov     eax,hBmp
@@:
    ret
MUICreateBitmapFromMemory ENDP


;-------------------------------------------------------------------------------------
; MUILoadRegionFromResource - Loads region from a resource
;-------------------------------------------------------------------------------------
MUILoadRegionFromResource PROC USES EBX hInst:DWORD, idRgnRes:DWORD, lpRegion:DWORD, lpdwSizeRegion:DWORD
    LOCAL hRes:DWORD
    ; Load region
    Invoke FindResource, hInst, idRgnRes, RT_RCDATA ; load rng image as raw data
    .IF eax != NULL
        mov hRes, eax
        Invoke SizeofResource, hInst, hRes
        .IF eax != 0
            .IF lpdwSizeRegion != NULL
                mov ebx, lpdwSizeRegion
                mov [ebx], eax
            .ELSE
                mov eax, FALSE
                ret
            .ENDIF
            Invoke LoadResource, hInst, hRes
            .IF eax != NULL
                Invoke LockResource, eax
                .IF eax != NULL
                    .IF lpRegion != NULL
                        mov ebx, lpRegion
                        mov [ebx], eax
                        mov eax, TRUE
                    .ELSE
                        mov eax, FALSE
                    .ENDIF
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov eax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov eax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov eax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov eax, FALSE
    .ENDIF    
    ret
MUILoadRegionFromResource ENDP


;-------------------------------------------------------------------------------------
; Sets a window/controls region from a region stored as an RC_DATA resource: idRgnRes
; if lpdwCopyRgn != NULL a copy of region handle is provided (for FrameRgn for example)
;-------------------------------------------------------------------------------------
MUISetRegionFromResource PROC USES EBX hWin:DWORD, idRgnRes:DWORD, lpdwCopyRgn:DWORD, bRedraw:DWORD
    LOCAL hinstance:DWORD
    LOCAL ptrRegionData:DWORD
    LOCAL dwRegionDataSize:DWORD
    LOCAL hRgn:DWORD
    
    .IF idRgnRes == NULL
        Invoke SetWindowRgn, hWin, NULL, FALSE
        ret
    .ENDIF
 
    Invoke GetModuleHandle, NULL
    mov hinstance, eax
    
    Invoke MUILoadRegionFromResource, hinstance, idRgnRes, Addr ptrRegionData, Addr dwRegionDataSize
    .IF eax == FALSE
        .IF lpdwCopyRgn != NULL
            mov eax, NULL
            mov ebx, lpdwCopyRgn
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE    
        ret
    .ENDIF
    
    Invoke SetWindowRgn, hWin, NULL, FALSE
    Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
    mov hRgn, eax
    .IF eax == NULL
        .IF lpdwCopyRgn != NULL
            mov eax, NULL
            mov ebx, lpdwCopyRgn
            mov [ebx], eax
        .ENDIF
        mov eax, FALSE
        ret
    .ENDIF
    Invoke SetWindowRgn, hWin, hRgn, bRedraw
    
    .IF lpdwCopyRgn != NULL
        Invoke ExtCreateRegion, NULL, dwRegionDataSize, ptrRegionData
        mov hRgn, eax
        mov ebx, lpdwCopyRgn
        mov [ebx], eax
    .ENDIF

    mov eax, TRUE    
    ret

MUISetRegionFromResource ENDP


MUITransparentBitmap PROC hdc:DWORD, hBitmap:DWORD, xStart:DWORD, yStart:DWORD, cTransparentColor:DWORD
    
;void DrawTransparentBitmap(HDC hdc, HBITMAP hBitmap, short xStart,
;                           short yStart, COLORREF cTransparentColor)
;{
;   BITMAP     bm;
;   COLORREF   cColor;
;   HBITMAP    bmAndBack, bmAndObject, bmAndMem, bmSave;
;   HBITMAP    bmBackOld, bmObjectOld, bmMemOld, bmSaveOld;
;   HDC        hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave;
;   POINT      ptSize;
;
;   hdcTemp = CreateCompatibleDC(hdc);
;   SelectObject(hdcTemp, hBitmap);   // Select the bitmap
;
;   GetObject(hBitmap, sizeof(BITMAP), (LPSTR)&bm);
;   ptSize.x = bm.bmWidth;            // Get width of bitmap
;   ptSize.y = bm.bmHeight;           // Get height of bitmap
;   DPtoLP(hdcTemp, &ptSize, 1);      // Convert from device
;                                     // to logical points
;
;   // Create some DCs to hold temporary data.
;   hdcBack   = CreateCompatibleDC(hdc);
;   hdcObject = CreateCompatibleDC(hdc);
;   hdcMem    = CreateCompatibleDC(hdc);
;   hdcSave   = CreateCompatibleDC(hdc);
;
;   // Create a bitmap for each DC. DCs are required for a number of
;   // GDI functions.
;
;   // Monochrome DC
;   bmAndBack   = CreateBitmap(ptSize.x, ptSize.y, 1, 1, NULL);
;
;   // Monochrome DC
;   bmAndObject = CreateBitmap(ptSize.x, ptSize.y, 1, 1, NULL);
;
;   bmAndMem    = CreateCompatibleBitmap(hdc, ptSize.x, ptSize.y);
;   bmSave      = CreateCompatibleBitmap(hdc, ptSize.x, ptSize.y);
;
;   // Each DC must select a bitmap object to store pixel data.
;   bmBackOld   = SelectObject(hdcBack, bmAndBack);
;   bmObjectOld = SelectObject(hdcObject, bmAndObject);
;   bmMemOld    = SelectObject(hdcMem, bmAndMem);
;   bmSaveOld   = SelectObject(hdcSave, bmSave);
;
;   // Set proper mapping mode.
;   SetMapMode(hdcTemp, GetMapMode(hdc));
;
;   // Save the bitmap sent here, because it will be overwritten.
;   BitBlt(hdcSave, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);
;
;   // Set the background color of the source DC to the color.
;   // contained in the parts of the bitmap that should be transparent
;   cColor = SetBkColor(hdcTemp, cTransparentColor);
;
;   // Create the object mask for the bitmap by performing a BitBlt
;   // from the source bitmap to a monochrome bitmap.
;   BitBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);
;
;   // Set the background color of the source DC back to the original
;   // color.
;   SetBkColor(hdcTemp, cColor);
;
;   // Create the inverse of the object mask.
;   BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, NOTSRCCOPY);
;
;   // Copy the background of the main DC to the destination.
;   BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdc, xStart, yStart, SRCCOPY);
;
;   // Mask out the places where the bitmap will be placed.
;   BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);
;
;   // Mask out the transparent colored pixels on the bitmap.
;   BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);
;
;   // XOR the bitmap with the background on the destination DC.
;   BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCPAINT);
;
;   // Copy the destination to the screen.
;   BitBlt(hdc, xStart, yStart, ptSize.x, ptSize.y, hdcMem, 0, 0, SRCCOPY);
;
;   // Place the original bitmap back into the bitmap sent here.
;   BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcSave, 0, 0, SRCCOPY);
;
;   // Delete the memory bitmaps.
;   DeleteObject(SelectObject(hdcBack, bmBackOld));
;   DeleteObject(SelectObject(hdcObject, bmObjectOld));
;   DeleteObject(SelectObject(hdcMem, bmMemOld));
;   DeleteObject(SelectObject(hdcSave, bmSaveOld));
;
;   // Delete the memory DCs.
;   DeleteDC(hdcMem);
;   DeleteDC(hdcBack);
;   DeleteDC(hdcObject);
;   DeleteDC(hdcSave);
;   DeleteDC(hdcTemp);
;}    
    ret

MUITransparentBitmap ENDP


MUITransparentBlt PROC destHDC:DWORD, xDest:DWORD, yDest:DWORD, wDest:DWORD, hDest:DWORD, srcHDC:DWORD, xSrc:DWORD, ySrc:DWORD, cTransparentColor:DWORD
    
;void MyTransparentBlt(
;	HDC destHDC,
;	short xDest,
;	short yDest,
;	short wDest,
;	short hDest,
;	HDC srcHDC,
;	short xSrc,
;	short ySrc,
;	COLORREF cTransparentColor
;)
;{
;
;	HDC	hdcMask	= CreateCompatibleDC(destHDC),
;		hdcBack	= CreateCompatibleDC(destHDC),
;		hdcFore	= CreateCompatibleDC(destHDC),
;		hdcTemp	= CreateCompatibleDC(destHDC);
;
;	HBITMAP bmNewMask, bmOldMask,
;			bmNewBack, bmOldBack,
;			bmNewFore, bmOldFore,
;			bmNewTemp, bmOldTemp;
;
;	/* Monochrome DC */
;	bmOldMask = SelectObject(hdcMask,
;		bmNewMask = CreateBitmap(wDest, hDest, 1, 1, NULL));
;
;	/* Temp. Mask */
;	bmOldBack = SelectObject(hdcBack,
;		bmNewBack = CreateCompatibleBitmap(destHDC, wDest, hDest));
;	bmOldFore = SelectObject(hdcFore,
;		bmNewFore = CreateCompatibleBitmap(destHDC, wDest, hDest));
;	bmOldTemp = SelectObject(hdcTemp,
;		bmNewTemp = CreateCompatibleBitmap(destHDC, wDest, hDest));
;
;/*	FillRect(hdcTemp, &cli, brTrans);
;	BitBlt(hdcTemp, 0, 0, wDest, hDest, srcHDC, xSrc, ySrc, SRCINVERT);
;*/
;	BitBlt(hdcTemp, 0, 0, wDest, hDest, srcHDC, xSrc, ySrc, SRCCOPY);
;
;	/* MonoChrome Created */
;	SetBkColor(hdcTemp, cTransparentColor);
;	BitBlt(hdcMask, 0, 0, wDest, hDest, hdcTemp, 0, 0, SRCCOPY);
;
;	/* Make Foreground layer */
;	SetTextColor(hdcFore, 0xFFFFFF);
;	SetBkColor(hdcFore, 0);
;
;	BitBlt(hdcFore, 0, 0, wDest, hDest, srcHDC, xSrc, ySrc, SRCCOPY);
;	BitBlt(hdcFore, 0, 0, wDest, hDest, hdcMask, 0, 0, SRCAND);
;
;
;	/* Change MonoChrome Map */
;	BitBlt(hdcMask, 0, 0, wDest, hDest, hdcMask, 0, 0, DSTINVERT);
;
;	/* Make Background layer */
;	SetTextColor(hdcBack, 0xFFFFFF);
;	SetBkColor(hdcBack, 0);
;
;	BitBlt(hdcBack, 0, 0, wDest, hDest, destHDC, xDest, yDest, SRCCOPY);
;	BitBlt(hdcBack, 0, 0, wDest, hDest, hdcMask, 0, 0, SRCAND);
;
;
;	/* merge */
;	BitBlt(destHDC, xDest, yDest, wDest, hDest, hdcBack, 0, 0, SRCCOPY);
;	BitBlt(destHDC, xDest, yDest, wDest, hDest, hdcFore, 0, 0, SRCPAINT);
;
;
;	/* Cleanup */
;	DeleteObject(SelectObject(hdcTemp, bmOldTemp));
;	DeleteObject(SelectObject(hdcMask, bmOldMask));
;	DeleteObject(SelectObject(hdcBack, bmOldBack));
;	DeleteObject(SelectObject(hdcFore, bmOldFore));
;
;	DeleteDC(hdcTemp);
;	DeleteDC(hdcMask);
;	DeleteDC(hdcBack);
;	DeleteDC(hdcFore);
;}    
    ret

MUITransparentBlt ENDP




MUITransBitblt PROC
;TransBitblt proc hDC:DWORD,Xpos:DWORD,Ypos:DWORD,hBitMap:DWORD
;
;            LOCAL hdcOffScr    :DWORD
;            LOCAL hbmOffScr    :DWORD
;            LOCAL hObject      :DWORD
;            LOCAL hdcImage     :DWORD
;            LOCAL hdcMask      :DWORD
;            LOCAL hbmMask      :DWORD
;            LOCAL OldObject    :DWORD
;            LOCAL OldbmOffScr  :DWORD
;            LOCAL OldbmMask    :DWORD
;           
;            LOCAL bm           :BITMAP
;            LOCAL rect         :RECT
;
;            invoke GetObject,hBitMap,sizeof bm,addr bm
;            invoke CreateCompatibleDC,hDC
;            mov [hdcOffScr],eax
;            invoke CreateCompatibleBitmap,hDC,bm.bmWidth,bm.bmHeight
;            mov [hbmOffScr],eax
;            invoke SelectObject,hdcOffScr,hbmOffScr
;            mov [OldbmOffScr],eax
;            invoke BitBlt,hdcOffScr,0,0,bm.bmWidth,bm.bmHeight,hDC,Xpos,Ypos,SRCCOPY
;            invoke CreateCompatibleDC,hDC
;            mov [hdcMask],eax
;            invoke CreateCompatibleDC,hDC
;            mov [hdcImage],eax
;            invoke CreateBitmap,bm.bmWidth,bm.bmHeight,1,1,NULL
;            mov [hbmMask],eax
;            invoke SelectObject,hdcMask,hbmMask
;            mov [OldbmMask],eax
;            invoke SelectObject,hdcImage,hBitMap
;            mov [OldObject],eax
;
;            invoke GetPixel,hdcImage,0,0
;            invoke SetBkColor,hdcImage,eax   
;            invoke BitBlt,hdcMask,0,0,bm.bmWidth,bm.bmHeight,hdcImage,0,0,SRCCOPY
;
;            invoke SelectObject,hdcImage,OldObject
;            mov [hBitMap],eax
;            invoke SelectObject,hdcMask,OldbmMask
;            mov [hbmMask],eax
;
;            invoke DeleteDC,hdcMask
;            invoke DeleteDC,hdcImage
;
;            invoke CreateCompatibleDC,hDC
;            mov [hdcImage],eax
;            invoke SelectObject,hdcImage,hBitMap
;            mov [OldObject],eax
;            invoke CreateCompatibleDC,hDC
;            mov [hdcMask],eax
;            invoke SelectObject,hdcMask,hbmMask
;            mov [OldbmMask],eax
;            invoke SetBkColor,hdcOffScr,0FFFFFFh
;            invoke BitBlt,hdcOffScr,0,0,bm.bmWidth,bm.bmHeight,hdcImage,0,0,SRCINVERT
;            invoke BitBlt,hdcOffScr,0,0,bm.bmWidth,bm.bmHeight,hdcMask,0,0,SRCAND
;            invoke BitBlt,hdcOffScr,0,0,bm.bmWidth,bm.bmHeight,hdcImage,0,0,SRCINVERT
;            invoke BitBlt,hDC,Xpos,Ypos,bm.bmWidth,bm.bmHeight,hdcOffScr,0,0,SRCCOPY
;;Clean up.(do some house cleaning)
;           
;            invoke SelectObject,hdcImage,OldObject
;            mov [hBitMap],eax
;            invoke SelectObject,hdcMask,OldbmMask
;            mov [hbmMask],eax
;            invoke SelectObject,hdcOffScr,OldbmOffScr
;            mov [hbmOffScr],eax
;            invoke DeleteObject,hbmMask
;            invoke DeleteObject,hbmOffScr
;            invoke DeleteDC,hdcOffScr
;            invoke DeleteDC,hdcImage
;            invoke DeleteDC,hdcMask
;            ret
;TransBitblt endp
    ret
MUITransBitblt ENDP

END
