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
include kernel32.inc

includelib user32.lib
includelib gdi32.lib
includelib Kernel32.Lib

include ModernUI.inc


;todo no need to calc if dpi is already 96

.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Get DPI
;------------------------------------------------------------------------------
MUIDPI PROC USES EBX lpdwDPIX:DWORD, lpdwDPIY:DWORD
    LOCAL hdc:HDC

    Invoke GetDC, NULL
    mov hdc, eax

    Invoke GetDeviceCaps, hdc, LOGPIXELSX
    .IF lpdwDPIX != NULL
        mov ebx, lpdwDPIX
        mov [ebx], eax
    .ENDIF
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    .IF lpdwDPIX != NULL
        mov ebx, lpdwDPIY
        mov [ebx], eax
    .ENDIF    

    Invoke ReleaseDC, NULL, hdc
    xor eax, eax
    ret
MUIDPI ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Scale value based on DPIX
;------------------------------------------------------------------------------
MUIDPIScaleX PROC dwValueToScale:DWORD
    LOCAL hdc:HDC
    LOCAL dwScaledValue:DWORD
    
    .IF dwValueToScale == 0
        mov eax, 0
        ret
    .ENDIF

    Invoke GetDC, NULL
    mov hdc, eax
    Invoke GetDeviceCaps, hdc, LOGPIXELSX
    Invoke MulDiv, dwValueToScale, eax, 96d
    mov dwScaledValue, eax
    Invoke ReleaseDC, NULL, hdc
    mov eax, dwScaledValue
    ret
MUIDPIScaleX ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Scale value based on DPIY
;------------------------------------------------------------------------------
MUIDPIScaleY PROC dwValueToScale:DWORD
    LOCAL hdc:HDC
    LOCAL dwScaledValue:DWORD
    
    .IF dwValueToScale == 0
        mov eax, 0
        ret
    .ENDIF    
    
    Invoke GetDC, NULL
    mov hdc, eax
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    Invoke MulDiv, dwValueToScale, eax, 96d
    mov dwScaledValue, eax
    Invoke ReleaseDC, NULL, hdc
    mov eax, dwScaledValue
    ret
MUIDPIScaleY ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Scale rect based on DPIX and DPIY
;------------------------------------------------------------------------------
MUIDPIScaleRect PROC lpRect:DWORD
    LOCAL rect:RECT
    LOCAL dwDPIX:DWORD
    LOCAL dwDPIY:DWORD
    
    .IF lpRect == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke CopyRect, Addr rect, lpRect
    Invoke MUIDPI, Addr dwDPIX, Addr dwDPIY
    
    .IF rect.left != 0
        Invoke MulDiv, rect.left, dwDPIX, 96d
        mov rect.left, eax
    .ENDIF
    .IF rect.top != 0
        Invoke MulDiv, rect.top, dwDPIY, 96d
        mov rect.top, eax
    .ENDIF
    .IF rect.right != 0
        Invoke MulDiv, rect.right, dwDPIX, 96d
        mov rect.right, eax
    .ENDIF
    .IF rect.bottom != 0
        Invoke MulDiv, rect.bottom, dwDPIY, 96d
        mov rect.bottom, eax
    .ENDIF
    Invoke CopyRect, lpRect, Addr rect
    mov eax, TRUE
    ret
MUIDPIScaleRect ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Get scaled screen width and height
;------------------------------------------------------------------------------
MUIDPIScaledScreen PROC USES EBX lpdwScreenWidth:DWORD, lpdwScreenHeight:DWORD
    LOCAL cxScreen:DWORD
    LOCAL cyScreen:DWORD
    LOCAL dwDPIX:DWORD
    LOCAL dwDPIY:DWORD    

    Invoke GetSystemMetrics, SM_CXSCREEN
    mov cxScreen, eax
    Invoke GetSystemMetrics, SM_CYSCREEN
    mov cyScreen, eax
    
    Invoke MUIDPI, Addr dwDPIX, Addr dwDPIY
    Invoke MulDiv, cxScreen, dwDPIX, 96d
    .IF lpdwScreenWidth != NULL
        mov ebx, lpdwScreenWidth
        mov [ebx], eax
    .ENDIF
    Invoke MulDiv, cyScreen, dwDPIY, 96d
    .IF lpdwScreenHeight != NULL
        mov ebx, lpdwScreenHeight
        mov [ebx], eax
    .ENDIF
    ret
MUIDPIScaledScreen ENDP


MUI_ALIGN
;------------------------------------------------------------------------------
; Scale control based on DPIX and DPIY
;------------------------------------------------------------------------------
MUIDPIScaleControl PROC USES EBX lpdwLeft:DWORD, lpdwTop:DWORD, lpdwWidth:DWORD, lpdwHeight:DWORD
    LOCAL rect:RECT
    
    .IF lpdwLeft != 0
        mov ebx, lpdwLeft
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF        
    mov rect.left, eax
    .IF lpdwTop != 0
        mov ebx, lpdwTop
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF
    mov rect.top, eax
    .IF lpdwWidth != 0
        mov ebx, lpdwWidth
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF
    mov rect.right, eax
    .IF lpdwHeight != 0
        mov ebx, lpdwHeight
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF
    mov rect.bottom, eax    
    Invoke MUIDPIScaleRect, Addr rect
    .IF lpdwLeft != 0
        mov ebx, lpdwLeft
        mov eax, rect.left
        mov [ebx], eax
    .ENDIF
    .IF lpdwTop != 0
        mov ebx, lpdwTop
        mov eax, rect.top
        mov [ebx], eax
    .ENDIF
    .IF lpdwWidth != 0
        mov ebx, lpdwWidth
        mov eax, rect.right
        mov [ebx], eax
    .ENDIF
    .IF lpdwHeight != 0
        mov ebx, lpdwHeight
        mov eax, rect.bottom
        mov [ebx], eax
    .ENDIF
    xor eax, eax
    ret
MUIDPIScaleControl ENDP


END

;// Definition: relative pixel = 1 pixel at 96 DPI and scaled based on actual DPI.
;class CDPI
;{
;public:
;CDPI() : _fInitialized(false), _dpiX(96), _dpiY(96) { }
;
;// Get screen DPI.
;int GetDPIX() { _Init(); return _dpiX; }
;int GetDPIY() { _Init(); return _dpiY; }
;
;// Convert between raw pixels and relative pixels.
;int ScaleX(int x) { _Init(); return MulDiv(x, _dpiX, 96); }
;int ScaleY(int y) { _Init(); return MulDiv(y, _dpiY, 96); }
;int UnscaleX(int x) { _Init(); return MulDiv(x, 96, _dpiX); }
;int UnscaleY(int y) { _Init(); return MulDiv(y, 96, _dpiY); }
;
;// Determine the screen dimensions in relative pixels.
;int ScaledScreenWidth() { return _ScaledSystemMetricX(SM_CXSCREEN); }
;int ScaledScreenHeight() { return _ScaledSystemMetricY(SM_CYSCREEN); }
;
;// Scale rectangle from raw pixels to relative pixels.
;void ScaleRect(__inout RECT *pRect)
;{
;pRect->left = ScaleX(pRect->left);
;pRect->right = ScaleX(pRect->right);
;pRect->top = ScaleY(pRect->top);
;pRect->bottom = ScaleY(pRect->bottom);
;}
;// Determine if screen resolution meets minimum requirements in relative
;// pixels.
;bool IsResolutionAtLeast(int cxMin, int cyMin)
;{
;return (ScaledScreenWidth() >= cxMin) && (ScaledScreenHeight() >= cyMin);
;}
;
;// Convert a point size (1/72 of an inch) to raw pixels.
;int PointsToPixels(int pt) { _Init(); return MulDiv(pt, _dpiY, 72); }
;
;// Invalidate any cached metrics.
;void Invalidate() { _fInitialized = false; }
;
;private:
;void _Init()
;{
;if (!_fInitialized)
;{
;HDC hdc = GetDC(NULL);
;if (hdc)
;{
;_dpiX = GetDeviceCaps(hdc, LOGPIXELSX);
;_dpiY = GetDeviceCaps(hdc, LOGPIXELSY);
;ReleaseDC(NULL, hdc);
;}
;_fInitialized = true;
;}
;}
;
;int _ScaledSystemMetricX(int nIndex)
;{
;_Init();
;return MulDiv(GetSystemMetrics(nIndex), 96, _dpiX);
;}
;
;int _ScaledSystemMetricY(int nIndex)
;{
;_Init();
;return MulDiv(GetSystemMetrics(nIndex), 96, _dpiY);
;}
;private:
;bool _fInitialized;
;
;int _dpiX;
;int _dpiY;
;};