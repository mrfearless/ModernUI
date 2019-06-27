#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif


//------------------------------------------------------------------------------
// ModernUI Prototypes
//------------------------------------------------------------------------------

// ModernUI Base Functions:
unsigned int MUI_EXPORT MUIGetExtProperty(HWND hControl, DWORD dwProperty);
unsigned int MUI_EXPORT MUISetExtProperty(HWND hControl, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUIGetIntProperty(HWND hControl, DWORD dwProperty);
unsigned int MUI_EXPORT MUISetIntProperty(HWND hControl, DWORD dwProperty, DWORD dwPropertyValue);
	
unsigned int MUI_EXPORT MUIGetExtPropertyEx(HWND hControl, DWORD dwParentProperty, DWORD dwChildProperty);
unsigned int MUI_EXPORT MUISetExtPropertyEx(HWND hControl, DWORD dwParentProperty, DWORD dwChildProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUIGetIntPropertyEx(HWND hControl, DWORD dwParentProperty, DWORD dwChildProperty);
unsigned int MUI_EXPORT MUISetIntPropertyEx(HWND hControl, DWORD dwParentProperty, DWORD dwChildProperty, DWORD dwPropertyValue);

unsigned int MUI_EXPORT MUIGetExtPropertyExtra(HWND hControl, DWORD dwProperty);
unsigned int MUI_EXPORT MUISetExtPropertyExtra(HWND hControl, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUIGetIntPropertyExtra(HWND hControl, DWORD dwProperty);
unsigned int MUI_EXPORT MUISetIntPropertyExtra(HWND hControl, DWORD dwProperty, DWORD dwPropertyValue);


// ModernUI Memory Functions:
bool MUI_EXPORT MUIAllocMemProperties(HWND hControl, DWORD cbWndExtraOffset, DWORD dwSizeToAllocate);
bool MUI_EXPORT MUIFreeMemProperties(HWND hControl, DWORD cbWndExtraOffset);
unsigned int MUI_EXPORT MUIAllocStructureMemory(DWORD dwPtrStructMem, DWORD TotalItems, DWORD ItemSize);

// ModernUI GDI Functions:
bool MUI_EXPORT MUIGDIDoubleBufferStart(HWND hWin, HDC hdcSource, HDC *lpHDCBuffer, RECT *lpClientRect, HBITMAP *lphBufferBitmap);
bool MUI_EXPORT MUIGDIDoubleBufferFinish(HDC hdcBuffer, HBITMAP hBufferBitmap, HBITMAP hBitmapUsed, HFONT hFontUsed, HBRUSH hBrushUsed, HPEN hPenUsed);
bool MUI_EXPORT MUIGDIBlend (HWNDhWin, HDC hdc, int dwColor, int dwBlendLevel);
bool MUI_EXPORT MUIGDIBlendBitmaps(HBITMAP hBitmap1, HBITMAP hBitmap2, int dwColorBitmap2, int dwTransparency);
HBITMAP MUI_EXPORT MUIGDIStretchBitmap(HBITMAP hBitmap, RECT *lpBoundsRect, int *lpdwBitmapWidth, int *lpdwBitmapHeight, int *lpdwX, int *lpdwY);
HBITMAP MUI_EXPORT MUIGDIStretchImage(hImage, dwImageType, RECT *lpBoundsRect, int *lpdwImageWidth, int *lpdwImageHeight, int *lpdwImageX, int *lpdwImageY);
HBITMAP MUI_EXPORT MUIGDIRotateBitmapCenter(HWND hWin, HBITMAP hBitmap, int dwAngle, int dwBackColor);

// ModernUI GDIPlus Functions:
void MUI_EXPORT MUIGDIPlusStart();
void MUI_EXPORT MUIGDIPlusFinish();

// ModernUI Painting & Color Functions:
void MUI_EXPORT MUIPaintBackground(HWND hDialogWindow, COLORREF dwBackColor, COLORREF dwBorderColor);
void MUI_EXPORT MUIPaintBackgroundImage(HWND hDialogWindow, COLORREF dwBackColor, COLORREF dwBorderColor, HANDLE hImage, DWORD dwImageType, DWORD dwImageLocation);
unsigned int MUI_EXPORT MUIGetParentBackgroundColor(HWND hControl);
unsigned int MUI_EXPORT MUIGetParentBackgroundBitmap(HWND hControl);

// ModernUI Window/Dialog Functions:
void MUI_EXPORT MUIApplyToDialog(HWND hDialogWindow, BOOL bDropShadow, BOOL bClipping);
void MUI_EXPORT MUICenterWindow(HWND hWndChild, HWND hWndParent);
void MUI_EXPORT MUIGetParentRelativeWindowRect(HWND hControl, RECT *lpRectControl);

// ModernUI Region Functions:
bool MUI_EXPORT MUILoadRegionFromResource(HINSTANCE hInstance, DWORD idRgnRes, DWORD *lpRegion, DWORD *lpdwSizeRegion);
bool MUI_EXPORT MUISetRegionFromResource(HWND hWin, DWORD idRgnRes, DWORD *lpdwCopyRgn, BOOL bRedraw);

// ModernUI Font Functions:
unsigned int MUI_EXPORT MUIPointSizeToLogicalUnit(HWND hControl, DWORD dwPointSize);

// ModernUI Image Functions:
bool MUI_EXPORT MUIGetImageSize(HANDLE hImage, DWORD dwImageType, DWORD *lpdwImageWidth, DWORD *lpdwImageHeight);
bool MUI_EXPORT MUICreateIconFromMemory(DWORD pIconData, DWORD iIcon);
bool MUI_EXPORT MUICreateCursorFromMemory(DWORD pCursorData);
bool MUI_EXPORT MUICreateBitmapFromMemory(DWORD pBitmapData);

// ModernUI DPI & Scaling Functions:
void MUIDPI(DWORD *lpdwDPIX, DWORD *lpdwDPIY);
unsigned int MUIDPIScaleX(DWORD dwValueX);
unsigned int MUIDPIScaleY(DWORD dwValueY);
bool MUIDPIScaleRect(RECT *lpRect);
void MUIDPIScaleControl(DWORD *lpdwLeft, DWORD *lpdwTop, DWORD *lpdwWidth, DWORD *lpdwHeight);
void MUIDPIScaleFontSize(HWND hControl, DWORD dwPointSize);
void MUIDPIScaledScreen(DWORD *lpdwScreenWidth, DWORD *lpdwScreenHeight);
bool MUIDPISetDPIAware();



//------------------------------------------
// Global constants used by all ModernUI
// controls. 
//------------------------------------------
#define MUI_INTERNAL_PROPERTIES         0               // cbWndExtra offset for internal properties pointer
#define MUI_EXTERNAL_PROPERTIES         4               // cbWndExtra offset for external properties pointer
#define MUI_INTERNAL_PROPERTIES_EXTRA   8               // cbWndExtra offset for extra internal properties pointer
#define MUI_EXTERNAL_PROPERTIES_EXTRA   12              // cbWndExtra offset for extra external properties pointer
#define MUI_PROPERTY_ADDRESS            80000000h       // OR with dwProperty in MUIGetIntProperty/MUIGetExtProperty to return address of property 


//------------------------------------------
// ModernUI Custom Messages - each control 
// should handle these
//------------------------------------------
#define MUI_GETPROPERTY                 WM_USER + 1800  // wParam = dwProperty, lParam = NULL
#define MUI_SETPROPERTY                 WM_USER + 1799  // wParam = dwProperty, lParam = dwPropertyValue


//------------------------------------------
// Image Types
//------------------------------------------
#define MUIIT_NONE                      0
#define MUIIT_BMP                       1
#define MUIIT_ICO                       2
#define MUIIT_PNG                       3


//------------------------------------------
// Image Locations
//------------------------------------------
#define MUIIL_CENTER                    0
#define MUIIL_BOTTOMLEFT                1
#define MUIIL_BOTTOMRIGHT               2
#define MUIIL_TOPLEFT                   3
#define MUIIL_TOPRIGHT                  4
#define MUIIL_TOPCENTER                 5
#define MUIIL_BOTTOMCENTER              6

//------------------------------------------
// ModernUI Macros
//------------------------------------------
#define MUI_RGBCOLOR(r,g,b) ((COLORREF)(((BYTE)(r)|((WORD)((BYTE)(g))<<8))|(((DWORD)(BYTE)(b))<<16)))



#ifdef __cplusplus
}
#endif
