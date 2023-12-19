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
include gdi32.inc
include kernel32.inc

includelib user32.lib
includelib gdi32.lib
includelib Kernel32.Lib

include ModernUI.inc


.CONST

; PROCESS_DPI_AWARENESS
PROCESS_DPI_UNAWARE = 0
PROCESS_SYSTEM_DPI_AWARE = 1
PROCESS_PER_MONITOR_DPI_AWARE = 2

; DPI_AWARENESS
DPI_AWARENESS_INVALID = -1
DPI_AWARENESS_UNAWARE = 0
DPI_AWARENESS_SYSTEM_AWARE = 1
DPI_AWARENESS_PER_MONITOR_AWARE = 2


DPI_AWARENESS_CONTEXT_UNAWARE              EQU ((DPI_AWARENESS_CONTEXT)-1)
DPI_AWARENESS_CONTEXT_SYSTEM_AWARE         EQU ((DPI_AWARENESS_CONTEXT)-2)
DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE    EQU ((DPI_AWARENESS_CONTEXT)-3)
DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 EQU ((DPI_AWARENESS_CONTEXT)-4)


.DATA
szMUIDPIUser32DLL       DB 'user32.dll',0
szMUIDPISPDA            DB 'SetProcessDPIAware',0
szMUIDPISPDAS           DB 'SetProcessDPIAwareness',0
szMUIDPISPDAC           DB 'SetProcessDpiAwarenessContext',0
szMUIDPIGTDAC           DB 'GetThreadDpiAwarenessContext',0
szMUIDPIGAFDAC          DB 'GetAwarenessFromDpiAwarenessContext',0


DPI_AWARENESS_CONTEXT   DD 0


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Get DPI
;------------------------------------------------------------------------------
MUIDPI PROC USES EBX lpDPIX:LPMUIVALUE, lpDPIY:LPMUIVALUE
    LOCAL hdc:HDC

    Invoke GetDC, NULL
    mov hdc, eax

    Invoke GetDeviceCaps, hdc, LOGPIXELSX
    .IF lpDPIX != NULL
        mov ebx, lpDPIX
        mov [ebx], eax
    .ENDIF
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    .IF lpDPIX != NULL
        mov ebx, lpDPIY
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
MUIDPIScaleX PROC ValueToScale:MUIVALUE
    LOCAL hdc:HDC
    LOCAL dwScaledValue:DWORD
    
    .IF ValueToScale == 0
        mov eax, 0
        ret
    .ENDIF

    Invoke GetDC, NULL
    mov hdc, eax
    Invoke GetDeviceCaps, hdc, LOGPIXELSX
    .IF eax == 96d ; already at 96dpi
        mov eax, ValueToScale
    .ELSE
        Invoke MulDiv, ValueToScale, eax, 96d
    .ENDIF
    mov dwScaledValue, eax
    Invoke ReleaseDC, NULL, hdc
    mov eax, dwScaledValue
    ret
MUIDPIScaleX ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Scale value based on DPIY
;------------------------------------------------------------------------------
MUIDPIScaleY PROC ValueToScale:MUIVALUE
    LOCAL hdc:HDC
    LOCAL dwScaledValue:DWORD
    
    .IF ValueToScale == 0
        mov eax, 0
        ret
    .ENDIF    
    
    Invoke GetDC, NULL
    mov hdc, eax
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    .IF eax == 96d ; already at 96dpi
        mov eax, ValueToScale
    .ELSE    
        Invoke MulDiv, ValueToScale, eax, 96d
    .ENDIF
    mov dwScaledValue, eax
    Invoke ReleaseDC, NULL, hdc
    mov eax, dwScaledValue
    ret
MUIDPIScaleY ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Scale rect based on DPIX and DPIY
;
; Return TRUE if scaling was done, FALSE if not or not required
;------------------------------------------------------------------------------
MUIDPIScaleRect PROC lpRect:LPRECT
    LOCAL rect:RECT
    LOCAL dwDPIX:DWORD
    LOCAL dwDPIY:DWORD
    
    .IF lpRect == NULL
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke MUIDPI, Addr dwDPIX, Addr dwDPIY
    .IF dwDPIX == 96d && dwDPIY == 96d ; already at 96dpi
        mov eax, FALSE
        ret
    .ENDIF
    
    Invoke CopyRect, Addr rect, lpRect
    
    .IF rect.left != 0
        .IF dwDPIX != 96d
            Invoke MulDiv, rect.left, dwDPIX, 96d
            mov rect.left, eax
        .ENDIF
    .ENDIF
    .IF rect.top != 0
        .IF dwDPIY != 96d
            Invoke MulDiv, rect.top, dwDPIY, 96d
            mov rect.top, eax
        .ENDIF
    .ENDIF
    .IF rect.right != 0
        .IF dwDPIX != 96d
            Invoke MulDiv, rect.right, dwDPIX, 96d
            mov rect.right, eax
        .ENDIF
    .ENDIF
    .IF rect.bottom != 0
        .IF dwDPIY != 96d
            Invoke MulDiv, rect.bottom, dwDPIY, 96d
            mov rect.bottom, eax
        .ENDIF
    .ENDIF
    Invoke CopyRect, lpRect, Addr rect
    mov eax, TRUE
    ret
MUIDPIScaleRect ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Get scaled screen width and height
;------------------------------------------------------------------------------
MUIDPIScaledScreen PROC USES EBX lpScreenWidth:LPMUIVALUE, lpScreenHeight:LPMUIVALUE
    LOCAL cxScreen:DWORD
    LOCAL cyScreen:DWORD
    LOCAL dwDPIX:DWORD
    LOCAL dwDPIY:DWORD    

    Invoke GetSystemMetrics, SM_CXSCREEN
    mov cxScreen, eax
    Invoke GetSystemMetrics, SM_CYSCREEN
    mov cyScreen, eax
    
    Invoke MUIDPI, Addr dwDPIX, Addr dwDPIY
    .IF dwDPIX != 96d
        Invoke MulDiv, cxScreen, dwDPIX, 96d
    .ELSE
        mov eax, cxScreen
    .ENDIF
    .IF lpScreenWidth != NULL
        mov ebx, lpScreenWidth
        mov [ebx], eax
    .ENDIF
    .IF dwDPIY != 96d
        Invoke MulDiv, cyScreen, dwDPIY, 96d
    .ELSE
        mov eax, cyScreen
    .ENDIF
    .IF lpScreenHeight != NULL
        mov ebx, lpScreenHeight
        mov [ebx], eax
    .ENDIF
    ret
MUIDPIScaledScreen ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Scale control based on DPIX and DPIY
;
; Return TRUE if scaling was done, FALSE if not or not required
;------------------------------------------------------------------------------
MUIDPIScaleControl PROC USES EBX lpLeft:LPMUIVALUE, lpTop:LPMUIVALUE, lpWidth:LPMUIVALUE, lpHeight:LPMUIVALUE
    LOCAL rect:RECT
    
    .IF lpLeft != 0
        mov ebx, lpLeft
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF        
    mov rect.left, eax
    .IF lpTop != 0
        mov ebx, lpTop
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF
    mov rect.top, eax
    .IF lpWidth != 0
        mov ebx, lpWidth
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF
    mov rect.right, eax
    .IF lpHeight != 0
        mov ebx, lpHeight
        mov eax, [ebx]
    .ELSE
        mov eax, 0
    .ENDIF
    mov rect.bottom, eax    
    Invoke MUIDPIScaleRect, Addr rect
    .IF eax == TRUE
        .IF lpLeft != 0
            mov ebx, lpLeft
            mov eax, rect.left
            mov [ebx], eax
        .ENDIF
        .IF lpTop != 0
            mov ebx, lpTop
            mov eax, rect.top
            mov [ebx], eax
        .ENDIF
        .IF lpWidth != 0
            mov ebx, lpWidth
            mov eax, rect.right
            mov [ebx], eax
        .ENDIF
        .IF lpHeight != 0
            mov ebx, lpHeight
            mov eax, rect.bottom
            mov [ebx], eax
        .ENDIF
        mov eax, TRUE
    .ENDIF
    ret
MUIDPIScaleControl ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Set DPI aware try for per monitor v2 and depending on OS try each possible
; option from SetProcessDpiAwarenessContext down to basic SetProcessDpiAware
;------------------------------------------------------------------------------
MUIDPISetDPIAwareA PROC
    LOCAL hUser32:DWORD
    LOCAL setDPIAware:DWORD
    LOCAL setDPIAwareness:DWORD
    LOCAL setDPIAwarenessContext:DWORD
    LOCAL getThreadDpiAwarenessContext:DWORD
    LOCAL getAwarenessFromDpiAwarenessContext:DWORD
    LOCAL dwResult:DWORD
    
    Invoke LoadLibraryA, Addr szMUIDPIUser32DLL
    
    .IF eax == 0
        mov eax, FALSE
        ret
    .ENDIF
    mov hUser32, eax
    
    Invoke GetProcAddress, hUser32, Addr szMUIDPISPDA
    mov setDPIAware, eax
    
    Invoke GetProcAddress, hUser32, Addr szMUIDPISPDAS
    mov setDPIAwareness, eax
    
    Invoke GetProcAddress, hUser32, Addr szMUIDPISPDAC
    mov setDPIAwarenessContext, eax    

    Invoke GetProcAddress, hUser32, Addr szMUIDPIGTDAC
    mov getThreadDpiAwarenessContext, eax   

    Invoke GetProcAddress, hUser32, Addr szMUIDPIGAFDAC
    mov getAwarenessFromDpiAwarenessContext, eax   

    .IF getThreadDpiAwarenessContext != 0
        call getThreadDpiAwarenessContext
        mov DPI_AWARENESS_CONTEXT, eax
        .IF getAwarenessFromDpiAwarenessContext != 0
            push DPI_AWARENESS_CONTEXT
            call getAwarenessFromDpiAwarenessContext
            .IF eax > 0 ; already set
                mov eax, TRUE
                ret
            .ENDIF
        .ENDIF
    .ENDIF

    .IF setDPIAwarenessContext != 0
        push DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
        call setDPIAwarenessContext
        .IF eax == FALSE
            push DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE
            call setDPIAwarenessContext
            .IF eax == FALSE
                .IF setDPIAwareness != 0
                    push PROCESS_PER_MONITOR_DPI_AWARE
                    call setDPIAwareness
                    .IF eax == FALSE
                        .IF setDPIAware != 0
                            call setDPIAware
                        .ENDIF
                    .ENDIF
                .ENDIF
            .ENDIF
        .ENDIF
        mov dwResult, eax
        
    .ELSEIF setDPIAwareness != 0
        push PROCESS_PER_MONITOR_DPI_AWARE
        call setDPIAwareness
        .IF eax == FALSE
            .IF setDPIAware != 0
                call setDPIAware
            .ENDIF
        .ENDIF
        mov dwResult, eax
        
    .ELSEIF setDPIAware != 0
        call setDPIAware
        mov dwResult, eax
        
    .ELSE
        mov dwResult, FALSE
        
    .ENDIF
    
    Invoke FreeLibrary, hUser32
    mov eax, dwResult
    ret
MUIDPISetDPIAwareA ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
; Scale font point size eg '12' to logical unit size for use with CreateFont
; or CreateFontIndirect, based on DPIY
;------------------------------------------------------------------------------
MUIDPIScaleFontSize PROC PointSize:MUIVALUE
    LOCAL hdc:HDC
    LOCAL dwScaledValue:DWORD
    LOCAL dwLogicalUnit:DWORD
    
    .IF PointSize == 0
        mov eax, 0
        ret
    .ENDIF    
    
    Invoke GetDC, NULL
    mov hdc, eax
    
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    Invoke MulDiv, PointSize, eax, 72d
    neg eax
    mov dwLogicalUnit, eax    
    
    
    Invoke GetDeviceCaps, hdc, LOGPIXELSY
    .IF eax == 96d ; already at 96dpi
        mov eax, dwLogicalUnit
    .ELSE    
        Invoke MulDiv, dwLogicalUnit, eax, 96d
    .ENDIF
    mov dwScaledValue, eax
    Invoke ReleaseDC, NULL, hdc
    mov eax, dwScaledValue
    ret
MUIDPIScaleFontSize ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
MUIDPIScaleFontA PROC hFontToScale:HFONT
    LOCAL lf:LOGFONT

    .IF hFontToScale == 0
        mov eax, 0
        ret
    .ENDIF

    Invoke GetObjectA, hFontToScale, SIZEOF LOGFONT, Addr lf
    mov eax, lf.lfHeight
    Invoke MUIDPIScaleFontSize, eax
    mov lf.lfHeight, eax
    Invoke CreateFontIndirectA, Addr lf
    ret
MUIDPIScaleFontA ENDP


;==============================================================================
; UNICODE
;==============================================================================

MUI_ALIGN
;------------------------------------------------------------------------------
; Set DPI aware try for per monitor v2 and depending on OS try each possible
; option from SetProcessDpiAwarenessContext down to basic SetProcessDpiAware
;------------------------------------------------------------------------------
MUIDPISetDPIAwareW PROC
    LOCAL hUser32:DWORD
    LOCAL setDPIAware:DWORD
    LOCAL setDPIAwareness:DWORD
    LOCAL setDPIAwarenessContext:DWORD
    LOCAL getThreadDpiAwarenessContext:DWORD
    LOCAL getAwarenessFromDpiAwarenessContext:DWORD
    LOCAL dwResult:DWORD
    
    Invoke LoadLibraryW, Addr szMUIDPIUser32DLL
    
    .IF eax == 0
        mov eax, FALSE
        ret
    .ENDIF
    mov hUser32, eax
    
    Invoke GetProcAddress, hUser32, Addr szMUIDPISPDA
    mov setDPIAware, eax
    
    Invoke GetProcAddress, hUser32, Addr szMUIDPISPDAS
    mov setDPIAwareness, eax
    
    Invoke GetProcAddress, hUser32, Addr szMUIDPISPDAC
    mov setDPIAwarenessContext, eax    

    Invoke GetProcAddress, hUser32, Addr szMUIDPIGTDAC
    mov getThreadDpiAwarenessContext, eax   

    Invoke GetProcAddress, hUser32, Addr szMUIDPIGAFDAC
    mov getAwarenessFromDpiAwarenessContext, eax   

    .IF getThreadDpiAwarenessContext != 0
        call getThreadDpiAwarenessContext
        mov DPI_AWARENESS_CONTEXT, eax
        .IF getAwarenessFromDpiAwarenessContext != 0
            push DPI_AWARENESS_CONTEXT
            call getAwarenessFromDpiAwarenessContext
            .IF eax > 0 ; already set
                mov eax, TRUE
                ret
            .ENDIF
        .ENDIF
    .ENDIF

    .IF setDPIAwarenessContext != 0
        push DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
        call setDPIAwarenessContext
        .IF eax == FALSE
            push DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE
            call setDPIAwarenessContext
            .IF eax == FALSE
                .IF setDPIAwareness != 0
                    push PROCESS_PER_MONITOR_DPI_AWARE
                    call setDPIAwareness
                    .IF eax == FALSE
                        .IF setDPIAware != 0
                            call setDPIAware
                        .ENDIF
                    .ENDIF
                .ENDIF
            .ENDIF
        .ENDIF
        mov dwResult, eax
        
    .ELSEIF setDPIAwareness != 0
        push PROCESS_PER_MONITOR_DPI_AWARE
        call setDPIAwareness
        .IF eax == FALSE
            .IF setDPIAware != 0
                call setDPIAware
            .ENDIF
        .ENDIF
        mov dwResult, eax
        
    .ELSEIF setDPIAware != 0
        call setDPIAware
        mov dwResult, eax
        
    .ELSE
        mov dwResult, FALSE
        
    .ENDIF
    
    Invoke FreeLibrary, hUser32
    mov eax, dwResult
    ret
MUIDPISetDPIAwareW ENDP

MUI_ALIGN
;------------------------------------------------------------------------------
;
;------------------------------------------------------------------------------
MUIDPIScaleFontW PROC hFontToScale:HFONT
    LOCAL lf:LOGFONT

    .IF hFontToScale == 0
        mov eax, 0
        ret
    .ENDIF

    Invoke GetObjectW, hFontToScale, SIZEOF LOGFONT, Addr lf
    mov eax, lf.lfHeight
    Invoke MUIDPIScaleFontSize, eax
    mov lf.lfHeight, eax
    Invoke CreateFontIndirectW, Addr lf
    ret
MUIDPIScaleFontW ENDP



MODERNUI_LIBEND



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



;https://stackoverflow.com/questions/33507031/detect-if-non-dpi-aware-application-has-been-scaled-virtualized
;
;
;
;// Get the monitor that the window is currently displayed on
;// (where hWnd is a handle to the window of interest).
;HMONITOR hMonitor = MonitorFromWindow(hWnd, MONITOR_DEFAULTTONEAREST);
;
;// Get the logical width and height of the monitor.
;MONITORINFOEX miex;
;miex.cbSize = sizeof(miex);
;GetMonitorInfo(hMonitor, &miex);
;int cxLogical = (miex.rcMonitor.right  - miex.rcMonitor.left);
;int cyLogical = (miex.rcMonitor.bottom - miex.rcMonitor.top);
;
;// Get the physical width and height of the monitor.
;DEVMODE dm;
;dm.dmSize        = sizeof(dm);
;dm.dmDriverExtra = 0;
;EnumDisplaySettings(miex.szDevice, ENUM_CURRENT_SETTINGS, &dm);
;int cxPhysical = dm.dmPelsWidth;
;int cyPhysical = dm.dmPelsHeight;
;
;// Calculate the scaling factor.
;double horzScale = ((double)cxPhysical / (double)cxLogical);
;double vertScale = ((double)cyPhysical / (double)cyLogical);
;ASSERT(horzScale == vertScale);

















