#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif


//------------------------------------------------------------------------------
// ModernUI_Button Prototypes
//------------------------------------------------------------------------------

void MUI_EXPORT MUIButtonRegister(); // Use 'ModernUI_Button' as class in RadASM custom class control
bool MUI_EXPORT MUIButtonCreate(HWND hWndParent, LPCSTR *lpszText, DWORD xpos, DWORD ypos, DWORD dwWidth, DWORD dwHeight, DWORD dwResourceID, DWORD dwStyle);
unsigned int MUI_EXPORT MUIButtonSetProperty(HWND hModernUI_Button, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUIButtonGetProperty(HWND hModernUI_Button, DWORD dwProperty);
bool MUI_EXPORT MUIButtonGetState(HWND hModernUI_Button);
bool MUI_EXPORT MUIButtonSetState(HWND hModernUI_Button, BOOL bState);

bool MUI_EXPORT MUIButtonLoadImages(HWND hModernUI_Button, DWORD dwImageType, DWORD dwResIDImage, DWORD dwResIDImageAlt, DWORD dwResIDImageSel, DWORD dwResIDImageSelAlt, DWORD dwResIDImageDisabled);
bool MUI_EXPORT MUIButtonSetImages(HWND hModernUI_Button, DWORD dwImageType, HANDLE hImage, HANDLE hImageAlt, HANDLE hImageSel, HANDLE hImageSelAlt, HANDLE hImageDisabled);



//------------------------------------------
// ModernUI_Button Styles
// 
//------------------------------------------

#define MUIBS_LEFT                     0x1     // Align text to the left of the button
#define MUIBS_BOTTOM                   0x2     // Place image at the top, and text below
#define MUIBS_CENTER                   0x4     // Align text centerally.
#define MUIBS_AUTOSTATE                0x8     // Automatically toggle between TRUE/FALSE state when clicked. TRUE = Selected.
#define MUIBS_PUSHBUTTON               0x10    // Simulate button movement down slightly when mouse click and movement up again when mouse is released.
#define MUIBS_HAND                     0x20    // Show a hand instead of an arrow when mouse moves over button.
#define MUIBS_KEEPIMAGES               0x40    // Dont delete image handles when control is destoyed. Essential if image handles are used in multiple controls.
#define MUIBS_DROPDOWN                 0x80    // Show dropdown arrow right side of control
#define MUIBS_NOFOCUSRECT              0x100   // Dont show focus rect, just use change border to ButtonBorderColorAlt when setfocus.
#define MUIBS_THEME                    0x800h  // Use default windows theme colors and react to WM_THEMECHANGED



//------------------------------------------------------------------------------
// ModernUI_Button Properties: Use with MUIButtonSetProperty / 
// MUIButtonGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
//------------------------------------------------------------------------------
#define ButtonTextFont                 0       // hFont
#define ButtonTextColor                4       // Colorref
#define ButtonTextColorAlt             8       // Colorref
#define ButtonTextColorSel             12      // Colorref
#define ButtonTextColorSelAlt          16      // Colorref
#define ButtonTextColorDisabled        20      // Colorref
#define ButtonBackColor                24      // Colorref, -1 = transparent
#define ButtonBackColorAlt             28      // Colorref
#define ButtonBackColorSel             32      // Colorref
#define ButtonBackColorSelAlt          36      // Colorref
#define ButtonBackColorDisabled        40      // Colorref
#define ButtonBorderColor              44      // Colorref, -1 = transparent
#define ButtonBorderColorAlt           48      // Colorref
#define ButtonBorderColorSel           52      // Colorref
#define ButtonBorderColorSelAlt        56      // Colorref
#define ButtonBorderColorDisabled      60      // Colorref
#define ButtonBorderStyle              64      // Button Border Styles - Either MUIBBS_NONE, MUIBBS_ALL or a combination of MUIBBS_LEFT, MUIBBS_TOP, MUIBBS_BOTTOM, MUIBBS_RIGHT
#define ButtonAccentColor              68      // Colorref, -1 = transparent
#define ButtonAccentColorAlt           72      // Colorref
#define ButtonAccentColorSel           76      // Colorref
#define ButtonAccentColorSelAlt        80      // Colorref
#define ButtonAccentStyle              84      // Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
#define ButtonAccentStyleAlt           88      // Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
#define ButtonAccentStyleSel           92      // Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
#define ButtonAccentStyleSelAlt        96      // Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
#define ButtonImageType                100     // Button Image Types - One of the following: MUIBIT_NONE, MUIBIT_BMP, MUIBIT_ICO or MUIBIT_PNG
#define ButtonImage                    104     // hImage
#define ButtonImageAlt                 108     // hImage
#define ButtonImageSel                 112     // hImage
#define ButtonImageSelAlt              116     // hImage
#define ButtonImageDisabled            120     // hImage
#define ButtonRightImage               124     // hImage - Right side image
#define ButtonRightImageAlt            128     // hImage - Right side image
#define ButtonRightImageSel            132     // hImage - Right side image
#define ButtonRightImageSelAlt         136     // hImage - Right side image
#define ButtonRightImageDisabled       140     // hImage - Right side image
#define ButtonNotifyTextFont           144     // hFont
#define ButtonNotifyTextColor          148     // Colorref
#define ButtonNotifyBackColor          152     // Colorref
#define ButtonNotifyRound              156     // dwPixels - Roundrect x,y value
#define ButtonNotifyImageType          160     // Button Image Types - One of the following: MUIBIT_NONE, MUIBIT_BMP, MUIBIT_ICO or MUIBIT_PNG
#define ButtonNotifyImage              164     // hImage
#define ButtonNoteTextFont             168     // hFont
#define ButtonNoteTextColor            172     // Colorref
#define ButtonNoteTextColorDisabled    176     // Colorref
#define ButtonPaddingLeftIndent        180     // dwPixels - No of pixels to indent images + text (or just text if no images). Defaults to 0 when control is created
#define ButtonPaddingGeneral           184     // dwPixels - No of pixels of padding to apply based on ButtonPaddingStyle: Defaults to 4px when control is created.
#define ButtonPaddingStyle             188     // Button Padding Style - Where to apply ButtonPaddingGeneral: defaults to MUIBPS_ALL when control is created
#define ButtonPaddingTextImage         192     // dwPixels - No of pixels between left images and text. Defaults to 8 when control is created
#define ButtonDllInstance              196     // Set to hInstance of dll before calling MUIButtonLoadImages or MUIButtonNotifyLoadImage if used within a dll
#define ButtonParam                    200     // Custom user data

// Button Border Styles
#define MUIBBS_NONE                    0
#define MUIBBS_LEFT                    1
#define MUIBBS_TOP                     2
#define MUIBBS_BOTTOM                  4
#define MUIBBS_RIGHT                   8
#define MUIBBS_ALL                     MUIBBS_LEFT + MUIBBS_TOP + MUIBBS_BOTTOM + MUIBBS_RIGHT


// Button Accent Styles
#define MUIBAS_NONE                    0
#define MUIBAS_LEFT                    1
#define MUIBAS_TOP                     2
#define MUIBAS_BOTTOM                  4
#define MUIBAS_RIGHT                   8
#define MUIBAS_ALL                     MUIBAS_LEFT + MUIBAS_TOP + MUIBAS_BOTTOM + MUIBAS_RIGHT

// Button Image Types
#define MUIBIT_NONE                    0
#define MUIBIT_BMP                     1
#define MUIBIT_ICO                     2
#define MUIBIT_PNG                     3

// Button Padding Styles
#define MUIBPS_NONE                    0
#define MUIBPS_LEFT                    1
#define MUIBPS_TOP                     2
#define MUIBPS_BOTTOM                  4
#define MUIBPS_RIGHT                   8
#define MUIBPS_ALL                     MUIBPS_LEFT + MUIBPS_TOP + MUIBPS_BOTTOM + MUIBPS_RIGHT





#ifdef __cplusplus
}
#endif
