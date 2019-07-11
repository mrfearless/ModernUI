/*=============================================================================

 ModernUI Library

 Copyright (c) 2019 by fearless

 All Rights Reserved

 http://github.com/mrfearless/ModernUI

=============================================================================*/

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif

/*------------------------------------------
; ModernUI Library Typedefs
;-----------------------------------------*/
// ModernUI Typedefs
typedef size_t MUIWND;              // HWND
typedef size_t MUIPROPERTIES;       // Typedef for use of MUI_INTERNAL_PROPERTIES, MUI_EXTERNAL_PROPERTIES etc
typedef size_t MUIPROPERTY;         // Typedef for MUI(Get/Set)(Int/Ext)Property function's Property parameter
typedef size_t MUIPROPERTYVALUE;    // Typedef for MUISetIntProperty/MUISetExtProperty PropertyValue parameter
typedef size_t MUIVALUE;            // QWORD in x64
typedef MUIVALUE * LPMUIVALUE;      // Pointer to MUIVALUE
typedef size_t MUIIT;               // Image type
typedef size_t MUIIL;               // Image location
typedef size_t MUIPFS;              // Paint frame style
typedef size_t MUIIMAGE;            // HBITMAP, HICON or GPIMAGE
typedef MUIIMAGE * LPMUIIMAGE;      // Pointer to MUIIMAGE
typedef size_t MUICOLORRGB;         // COLORREF color value using MUI_RGBCOLOR macro
typedef size_t MUICOLORARGB;        // ARGB color value using MUI_ARGBCOLOR macro
// Expand on or add to some of the GDI+ data types:
typedef size_t GPGRAPHICS;          // GDI+ graphics context
typedef GPGRAPHICS * LPGPGRAPHICS;  // Pointer to GPGRAPHICS
typedef size_t GPIMAGE;             // GDI+ image
typedef GPIMAGE * LPGPIMAGE;        // Pointer to GDI+ image
// Expand on or add to some of the common Windows data types:
typedef RECT * LPRECT;              // Pointer to RECT
typedef HBITMAP * LPHBITMAP;        // Pointer to HBITMAP
typedef HDC * LPHDC;                // Pointer to HDC
typedef size_t POINTER;             // QWORD in x64
typedef size_t RESID;               // Resource ID 

/*------------------------------------------
; ModernUI Property Constants 
;-----------------------------------------*/
#ifdef _WIN64
#define MUI_INTERNAL_PROPERTIES         0           // cbWndExtra offset for internal properties pointer
#define MUI_EXTERNAL_PROPERTIES         8           // cbWndExtra offset for external properties pointer
#define MUI_INTERNAL_PROPERTIES_EXTRA   16          // cbWndExtra offset for extra internal properties pointer
#define MUI_EXTERNAL_PROPERTIES_EXTRA   24          // cbWndExtra offset for extra external properties pointer
#define MUI_PROPERTY_ADDRESS            0x80000000  // OR with Property in MUIGetIntProperty/MUIGetExtProperty to return address of property
#else // WIN32 x86
#define MUI_INTERNAL_PROPERTIES         0           // cbWndExtra offset for internal properties pointer
#define MUI_EXTERNAL_PROPERTIES         4           // cbWndExtra offset for external properties pointer
#define MUI_INTERNAL_PROPERTIES_EXTRA   8           // cbWndExtra offset for extra internal properties pointer
#define MUI_EXTERNAL_PROPERTIES_EXTRA   12          // cbWndExtra offset for extra external properties pointer
#define MUI_PROPERTY_ADDRESS            0x80000000  // OR with Property in MUIGetIntProperty/MUIGetExtProperty to return address of property
#endif

/*------------------------------------------
// ModernUI Custom Messages - each control 
// should handle these
//----------------------------------------*/
#define MUI_GETPROPERTY                 WM_USER + 1800  // wParam = Property, lParam = NULL
#define MUI_SETPROPERTY                 WM_USER + 1799  // wParam = Property, lParam = PropertyValue

/*------------------------------------------
// Image Types Enum MUIIMAGE
//----------------------------------------*/
#define MUIIT_NONE                      0
#define MUIIT_BMP                       1
#define MUIIT_ICO                       2
#define MUIIT_PNG                       3

/*------------------------------------------
// Image Locations Enum MUIIL
//----------------------------------------*/
#define MUIIL_CENTER                    0
#define MUIIL_BOTTOMLEFT                1
#define MUIIL_BOTTOMRIGHT               2
#define MUIIL_TOPLEFT                   3
#define MUIIL_TOPRIGHT                  4
#define MUIIL_TOPCENTER                 5
#define MUIIL_BOTTOMCENTER              6

/*------------------------------------------
// MUIGDIPaintFrame Frame Style Enum MUIPFS
//----------------------------------------*/
#define MUIPFS_NONE                     0
#define MUIPFS_LEFT                     1
#define MUIPFS_TOP                      2
#define MUIPFS_BOTTOM                   4
#define MUIPFS_RIGHT                    8
#define MUIPFS_ALL                      MUIPFS_LEFT + MUIPFS_TOP + MUIPFS_BOTTOM + MUIPFS_RIGHT

/*------------------------------------------
// Color Macros
//----------------------------------------*/
#define MUI_RGBCOLOR(r,g,b) ((COLORREF)(((BYTE)(r)|((WORD)((BYTE)(g))<<8))|(((DWORD)(BYTE)(b))<<16)))
//#define MUI_ARGBCOLOR(a,r,g,b) ((DWORD)(((BYTE)(b)|((BYTE)(g)<<8)|((BYTE)(r)<<16)|((BYTE)(a)<<24))))
#define MUI_ARGBCOLOR(a,r,g,b) ((DWORD(a)<<24) + (DWORD(r)<<16) + (DWORD(g)<<8) + DWORD(b))

/*------------------------------------------
// ModernUI Structures
//----------------------------------------*/
typedef struct GDIPRECT{
    double left;
    double top;
    double right;
    double bottom;
} GDIPRECT;

typedef GDIPRECT GPRECT;                 // Alias for GDIPRECT
typedef GPRECT * LPGPRECT;               // Pointer to GDIPRECT
typedef GDIPRECT * LPGDIPRECT;           // Pointer to GDIPRECT

/*------------------------------------------------------------------------------
// ModernUI Prototypes
//----------------------------------------------------------------------------*/
// ModernUI Base Functions:
MUIPROPERTY MUI_EXPORT MUIGetExtProperty(MUIWND hWin, MUIPROPERTY Property);
MUIPROPERTY MUI_EXPORT MUISetExtProperty(MUIWND hWin, MUIPROPERTY Property, MUIPROPERTYVALUE PropertyValue);
MUIPROPERTY MUI_EXPORT MUIGetIntProperty(MUIWND hWin, MUIPROPERTY Property);
MUIPROPERTY MUI_EXPORT MUISetIntProperty(MUIWND hWin, MUIPROPERTY Property, MUIPROPERTYVALUE PropertyValue);

MUIPROPERTY MUI_EXPORT MUIGetExtPropertyEx(MUIWND hWin, MUIPROPERTY Property, ParentProperty MUIPROPERTY);
MUIPROPERTY MUI_EXPORT MUISetExtPropertyEx(MUIWND hWin, MUIPROPERTY Property, ParentProperty MUIPROPERTY, ChildProperty MUIPROPERTYVALUE);
MUIPROPERTY MUI_EXPORT MUIGetIntPropertyEx(MUIWND hWin, MUIPROPERTY Property, ParentProperty MUIPROPERTY);
MUIPROPERTY MUI_EXPORT MUISetIntPropertyEx(MUIWND hWin, MUIPROPERTY Property, ParentProperty MUIPROPERTY, ChildProperty MUIPROPERTYVALUE);

MUIPROPERTY MUI_EXPORT MUIGetExtPropertyExtra(MUIWND hWin, MUIPROPERTY Property);
MUIPROPERTY MUI_EXPORT MUISetExtPropertyExtra(MUIWND hWin, MUIPROPERTY Property, MUIPROPERTYVALUE PropertyValue);
MUIPROPERTY MUI_EXPORT MUIGetIntPropertyExtra(MUIWND hWin, MUIPROPERTY Property);
MUIPROPERTY MUI_EXPORT MUISetIntPropertyExtra(MUIWND hWin, MUIPROPERTY Property, MUIPROPERTYVALUE PropertyValue);

// ModernUI Memory Functions 
bool MUI_EXPORT MUIAllocMemProperties(MUIWND hWin, MUIPROPERTIES cbWndExtraOffset, MUIVALUE SizeToAllocate);
bool MUI_EXPORT MUIFreeMemProperties(MUIWND hWin, MUIPROPERTIES cbWndExtraOffset);
POINTER MUI_EXPORT MUIAllocStructureMemory(POINTER *PtrStructMem , MUIVALUE TotalItems, MUIVALUE ItemSize);

// ModernUI GDI Functions 
void MUI_EXPORT MUIGDIDoubleBufferStart(MUIWND hWin, HDC hdcSource, HDC *lpHDCBuffer, RECT *lpClientRect, HBITMAP *lphBufferBitmap);
void MUI_EXPORT MUIGDIDoubleBufferFinish(HDC hdc, HBITMAP hBufferBitmap, HBITMAP hBitmapUsed, HFONT hFontUsed, HBRUSH hBrushUsed, HPEN hPenUsed);
HBITMAP MUI_EXPORT MUIGDIBlend(MUIWND hWin, HDC hdc, MUICOLORRGB BlendColor, MUIVALUE BlendLevel);
HBITMAP MUI_EXPORT MUIGDIBlendBitmaps(HBITMAP hBitmap1, HBITMAP hBitmap2, MUICOLORRGB ColorBitmap2, MUIVALUE Transparency);
HBITMAP MUI_EXPORT MUIGDIStretchBitmap(HBITMAP hBitmap, RECT *lpBoundsRect, MUIVALUE *lpBitmapWidth, MUIVALUE *lpBitmapHeight, MUIVALUE *lpBitmapX, MUIVALUE *lpBitmapY);
MUIIMAGE MUI_EXPORT MUIGDIStretchImage(MUIIMAGE hImage, MUIIT ImageHandleType, RECT * lpBoundsRect, MUIVALUE *lpImageWidth, MUIVALUE *lpImageHeight, MUIVALUE *lpImageX, MUIVALUE *lpImageY);
HBITMAP MUI_EXPORT MUIGDIRotateCenterBitmap(MUIWND hWin, HBITMAP hBitmap, MUIVALUE Angle, MUICOLORRGB BackColor);
void MUI_EXPORT MUIGDIPaintFill(HDC hdc, RECT *lpFillRect, MUICOLORRGB FillColor);
void MUI_EXPORT MUIGDIPaintFrame(HDC hdc, RECT *lpFrameRect, MUICOLORRGB FrameColor, MUIPFS FrameStyle);

// ModernUI GDIPlus Functions 
void MUI_EXPORT MUIGDIPlusStart();
void MUI_EXPORT MUIGDIPlusFinish();
void MUI_EXPORT MUIGDIPlusDoubleBufferStart(MUIWND hWin, GPGRAPHICS pGraphics, GPIMAGE *lpBitmapHandle, GPGRAPHICS *lpGraphicsBuffer);
void MUI_EXPORT MUIGDIPlusDoubleBufferFinish(MUIWND hWin, GPGRAPHICS pGraphics, GPIMAGE pBitmap, GPGRAPHICS pGraphicsBuffer);
GPIMAGE MUI_EXPORT MUIGDIPlusRotateCenterImage(GPIMAGE hImage, double fAngle);
void MUI_EXPORT MUIGDIPlusPaintFill(GPGRAPHICS pGraphics, GPRECT *lpFillGdipRect, MUICOLORARGB FillColor);
void MUI_EXPORT MUIGDIPlusPaintFillI(GPGRAPHICS pGraphics, RECT *lpFillRectI, MUICOLORARGB FillColor);
void MUI_EXPORT MUIGDIPlusPaintFrame(GPGRAPHICS pGraphics, GPRECT *lpFrameGdipRect, MUICOLORARGB FrameColor, MUIPFS FrameStyle);
void MUI_EXPORT MUIGDIPlusPaintFrameI(GPGRAPHICS pGraphics, RECT *lpFrameRectI, MUICOLORARGB FrameColor, MUIPFS FrameStyle);
GPIMAGE MUI_EXPORT MUILoadPngFromResource(MUIWND hWin, MUIPROPERTY InstanceProperty, MUIPROPERTY Property, RESID idPngRes);
void MUI_EXPORT MUIGDIPlusRectToGdipRect(RECT *lpRect, GPRECT *lpGdipRect);

// GDIPlus aliases 
void MUI_EXPORT MUIGDIPStart();
void MUI_EXPORT MUIGDIPFinish();
void MUI_EXPORT MUIGDIPDoubleBufferStart(MUIWND hWin, GPGRAPHICS pGraphics, GPIMAGE *lpBitmapHandle, GPGRAPHICS *lpGraphicsBuffer);
void MUI_EXPORT MUIGDIPDoubleBufferFinish(MUIWND hWin, GPGRAPHICS pGraphics, GPIMAGE pBitmap, GPGRAPHICS pGraphicsBuffer);
GPIMAGE MUI_EXPORT MUIGDIPRotateCenterImage(GPIMAGE hImage, double fAngle);
void MUI_EXPORT MUIGDIPPaintFill(GPGRAPHICS pGraphics, GPRECT *lpFillGdipRect, MUICOLORARGB FillColor);
void MUI_EXPORT MUIGDIPPaintFillI(GPGRAPHICS pGraphics, RECT *lpFillRectI, MUICOLORARGB FillColor);
void MUI_EXPORT MUIGDIPPaintFrame(GPGRAPHICS pGraphics, GPRECT *lpFrameGdipRect, MUICOLORARGB FrameColor, MUIPFS FrameStyle);
void MUI_EXPORT MUIGDIPPaintFrameI(GPGRAPHICS pGraphics, RECT *lpFrameRectI, MUICOLORARGB FrameColor, MUIPFS FrameStyle);
GPIMAGE MUI_EXPORT MUILoadJpgFromResource(MUIWND hWin, MUIPROPERTY InstanceProperty, MUIPROPERTY Property, RESID idPngRes);
void MUI_EXPORT MUIGDIPRectToGdipRect(RECT *lpRect, GPRECT *lpGdipRect);

// ModernUI Painting & Color Functions 
void MUI_EXPORT MUIPaintBackground(MUIWND hWin, MUICOLORRGB BackColor, MUICOLORRGB BorderColor);
void MUI_EXPORT MUIPaintBackgroundImage(MUIWND hWin, MUICOLORRGB BackColor, MUICOLORRGB BorderColor, MUIIMAGE hImage, MUIIT ImageHandleType, MUIIL ImageLocation);
MUICOLORRGB MUI_EXPORT MUIGetParentBackgroundColor(MUIWND hWin);
HBITMAP MUI_EXPORT MUIGetParentBackgroundBitmap(MUIWND hWin);

// ModernUI Window/Dialog Functions 
void MUI_EXPORT MUIApplyToDialog(MUIWND hWin, BOOL bDropShadow, BOOL bClipping);
void MUI_EXPORT MUICenterWindow(hWndChild MUIWND, hWndParent MUIWND);
void MUI_EXPORT MUIGetParentRelativeWindowRect(MUIWND hWin, RECT *lpRectControl);

// ModernUI Region Functions 
bool MUI_EXPORT MUILoadRegionFromResource(HINSTANCE hInst, RESID idRgnRes, POINTER *lpRegionData, MUIVALUE *lpSizeRegionData);
bool MUI_EXPORT MUISetRegionFromResource(MUIWND hWin, RESID idRgnRes, MUIVALUE lpCopyRgnHandle, BOOL bRedraw);

// ModernUI Font Functions 
MUIVALUE MUI_EXPORT MUIPointSizeToLogicalUnit(MUIWND hWin, MUIVALUE PointSize);

// ModernUI Image Functions 
bool MUI_EXPORT MUIGetImageSize(MUIIMAGE hImage, MUIIT ImageHandleType, MUIVALUE *lpImageWidth, MUIVALUE *lpImageHeight);
bool MUI_EXPORT MUIGetImageSizeEx(MUIWND hWin, MUIIMAGE hImage, MUIIT ImageHandleType, MUIVALUE *lpImageWidth, MUIVALUE *lpImageHeight, MUIVALUE *lpImageX, MUIVALUE *lpImageY);
HICON MUI_EXPORT MUICreateIconFromMemory(POINTER pIconData, MUIVALUE iIcon);
HICON MUI_EXPORT MUICreateCursorFromMemory(POINTER pCursorData);
HBITMAP MUI_EXPORT MUICreateBitmapFromMemory(POINTER pBitmapData);
HBITMAP MUI_EXPORT MUILoadBitmapFromResource(MUIWND hWin, MUIPROPERTY InstanceProperty, MUIPROPERTY Property, RESID idBmpRes);
HICON MUI_EXPORT MUILoadIconFromResource(MUIWND hWin, MUIPROPERTY InstanceProperty, MUIPROPERTY Property, RESID idIcoRes);
MUIIMAGE MUI_EXPORT MUILoadImageFromResource(MUIWND hWin, MUIPROPERTY InstanceProperty, MUIPROPERTY Property, MUIIT ImageHandleType, RESID idImageRes);

// ModernUI DPI & Scaling Functions 
void MUI_EXPORT MUIDPI(MUIVALUE *lpDPIX, MUIVALUE *lpDPIY);
MUIVALUE MUI_EXPORT MUIDPIScaleX(MUIVALUE ValueX );
MUIVALUE MUI_EXPORT MUIDPIScaleY(MUIVALUE ValueY);
void MUI_EXPORT MUIDPIScaleRect(RECT *lpRect );
void MUI_EXPORT MUIDPIScaleControl(MUIVALUE *lpLeft, MUIVALUE *lpTop, MUIVALUE *lpWidth, MUIVALUE *lpHeight);
void MUI_EXPORT MUIDPIScaleFontSize(MUIVALUE PointSize);
void MUI_EXPORT MUIDPIScaleFont(HFONT hFont);
void MUI_EXPORT MUIDPIScaledScreen(MUIVALUE * lpScreenWidth, MUIVALUE * lpScreenHeight);
bool MUI_EXPORT MUIDPISetDPIAware();


/*-----------------------------------------
; Notes
;------------------------------------------
; Custom controls  dwStyle parameter of 
; CreateWindowEx.
;
; The low 16 bits of the dwStyle parameter 
; are defined by the implementor of the 
; window class (by the person who calls 
; RegisterClass) - Raymond Chen
;
; 0x0h - 0xFFFFh reserved for user creating
; the control to define styles
;----------------------------------------*/


#ifdef __cplusplus
}
#endif
