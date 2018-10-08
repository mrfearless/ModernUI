#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif


//------------------------------------------------------------------------------
// ModernUI_CaptionBar Prototypes
//------------------------------------------------------------------------------

void MUI_EXPORT MUICaptionBarRegister();   // Use 'ModernUI_CaptionBar' as class in custom control
bool MUI_EXPORT MUICaptionBarCreate(HWND hWndParent, LPCSTR *lpszCaptionText, DWORD dwCaptionHeight, DWORD dwResourceID, DWORD dwStyle);
unsigned int MUI_EXPORT MUICaptionBarSetProperty(HWND hModernUI_CaptionBar, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUICaptionBarGetProperty(HWND hModernUI_CaptionBar, DWORD dwProperty);
bool MUI_EXPORT MUICaptionBarLoadIcons(HWND hModernUI_CaptionBar, DWORD idResMin, DWORD idResMinAlt, DWORD idResMax, DWORD idResMaxAlt, DWORD idResRes, DWORD idResResAlt, DWORD idResClose, DWORD idResCloseAlt);
bool MUI_EXPORT MUICaptionBarLoadIconsDll(HWND hModernUI_CaptionBar, HINSTANCE hInstance, DWORD idResMin, DWORD idResMinAlt, DWORD idResMax, DWORD idResMaxAlt, DWORD idResRes, DWORD idResResAlt, DWORD idResClose, DWORD idResCloseAlt);
bool MUI_EXPORT MUICaptionBarLoadBackImage(HWND hModernUI_CaptionBar, DWORD dwImageType, DWORD dwResIDImage);

bool MUI_EXPORT MUICaptionBarAddButton(HWND hModernUI_CaptionBar, LPCSTR *lpszButtonText, DWORD dwResourceID, DWORD dwResIDImage, DWORD dwResIDImageAlt);
bool MUI_EXPORT MUICaptionBarAddButtonEx(HWND hModernUI_CaptionBar, LPCSTR *lpszButtonText, DWORD dwResourceID, HANDLE hIcon, HANDLE hIconAlt);
unsigned int MUI_EXPORT MUICapButtonSetProperty(HWND hCapButton, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUICapButtonGetProperty(HWND hCapButton, DWORD dwProperty, DWORD dwPropertyValue);



//------------------------------------------
// ModernUI_CaptionBar Styles
// 
//------------------------------------------

#define MUICS_LEFT                      0x0   // left align caption bar text
#define MUICS_CENTER                    0x1   // center align caption bar text
#define MUICS_NOMINBUTTON               0x2   // no minimize button
#define MUICS_NOMAXBUTTON               0x4   // no maximize/restore button
#define MUICS_NOCLOSEBUTTON             0x8   // no close button
#define MUICS_REDCLOSEBUTTON            0x10  // close button uses win8+ red background color
#define MUICS_NOMOVEWINDOW              0x20  // Dont allow window to move when caption bar is clicked and dragged, if not specified will allow this.
#define MUICS_WINNOMUISTYLE             0x40  // Dont apply MUI borderless frame style to window/dialog, if not specified will apply MUI style.
#define MUICS_WINNODROPSHADOW           0x80  // Dont apply drop shadow to window/dialog. If not specified will apply dropshadow if MUICS_WINDOWNOMUISTYLE not specified.
#define MUICS_USEICONSFORBUTTONS        0x100 // Use icons instead of text (Marlett font glyphs) for the min/max/res/close buttons: Load icons via the MUICaptionBarLoadIcons functions or set handles via @CaptionBarBtnIcoXXX properties
#define MUICS_KEEPICONS                 0x200 // Dont delete icons handles when control is destoyed. Essential if icon handles are used in multiple controls or where set directly with properties 
#define MUICS_NOCAPTIONTITLETEXT        0x400 // Dont draw a title text value, use lpszCaptionText for taskbar name of app only.
#define MUICS_NOBORDER                  0x800 // No border used, so position ModernUI_CaptionBar at 0,0 instead of at 1,1
#define MUICS_WINSIZE                   0x1000// Dialog/Window is resizable.
#define MUICS_THEME                     0x8000// Use default windows theme colors and react to WM_THEMECHANGED


//------------------------------------------------------------------------------
// ModernUI_Caption Properties: Use with MUICaptionBarSetProperty / 
// MUICaptionBarGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
//------------------------------------------------------------------------------
#define CaptionBarTextColor            0   // RGBCOLOR. Text color for captionbar text and system buttons (min/max/restore/close)
#define CaptionBarTextFont             4   // hFont. Font for captionbar text
#define CaptionBarBackColor            8   // RGBCOLOR. Background color of captionbar and system buttons (min/max/restore/close)
#define CaptionBarBackImageType        12  // DWORD. Image Type - One of the following: MUICBIT_NONE,MUICBIT_BMP, MUICBIT_ICO, MUICBIT_PNG
#define CaptionBarBackImage            16  // hImage. Image to display in captionbar background.
#define CaptionBarBackImageOffsetX     20  // DWORD. Offset x +/- to set position of hImage. Default = 0
#define CaptionBarBackImageOffsetY     24  // DWORD. Offset y +/- to set position of hImage. Default = 0
#define CaptionBarBtnTxtRollColor      28  // RGBCOLOR. Text color for system buttons (min/max/restore/close) when mouse moves over button
#define CaptionBarBtnBckRollColor      32  // RGBCOLOR. Background color for system buttons (min/max/restore/close) when mouse moves over button
#define CaptionBarBtnBorderColor       36  // RGBCOLOR. Border color for system buttons (min/max/restore/close). 0 = use same as CaptionBarBackColor
#define CaptionBarBtnBorderRollColor   40  // RGBCOLOR. Border color for system buttons (min/max/restore/close) when mouse moves over button. 0 = use CaptionBarBtnBckRollColor
#define CaptionBarBtnWidth             44  // DWORD. System buttons width. Defaults = 32px
#define CaptionBarBtnHeight            48  // DWORD. System buttons height. Defaults = 28px
#define CaptionBarBtnOffsetX           52  // DWORD. Offset y +/- to set position of system buttons (min/max/restore/close) in relation to right of captionbar
#define CaptionBarBtnOffsetY           56  // DWORD. Offset y + to set position of system buttons (min/max/restore/close) in relation to top of captionbar
#define CaptionBarBtnIcoMin            60  // hIcon. For minimize button
#define CaptionBarBtnIcoMinAlt         64  // hIcon. For minimize button when mouse moves over button
#define CaptionBarBtnIcoMax            68  // hIcon. For maximize button
#define CaptionBarBtnIcoMaxAlt         72  // hIcon. For maximize button when mouse moves over button
#define CaptionBarBtnIcoRes            76  // hIcon. For restore button
#define CaptionBarBtnIcoResAlt         80  // hIcon. For restore button when mouse moves over button
#define CaptionBarBtnIcoClose          84  // hIcon. For close button
#define CaptionBarBtnIcoCloseAlt       88  // hIcon. For close button when mouse moves over button
#define CaptionBarWindowBackColor      92  // RGBCOLOR. If -1 = No painting of window/dialog background, handled by user or default system.
#define CaptionBarWindowBorderColor    96  // RGBCOLOR. If -1 = No border. if WindowBackColor != -1 then color of border to paint on window.
#define CaptionBarDllInstance          100 // hInstance. For loading resources (icons) - normally set to 0 (current module) but when resources are in a dll set this before calling MUICaptionBarLoadIcons
#define CaptionBarParam                104 // DWORD. Custom user data

// CaptionBar Back Image Types
#define MUICBIT_NONE                    0
#define MUICBIT_BMP                     1
#define MUICBIT_ICO                     2
#define MUICBIT_PNG                     3

//------------------------------------------------------------------------------
// CaptionBar CapButton properties (extra custom buttons added with 
// MUICaptionBarAddButton)
// Note: setting ModernUI_CaptionBar properties will cascade down to set 
// equivalent CapButton properties.
//------------------------------------------------------------------------------
#define CapButtonTextColor             0   // RGBCOLOR.
#define CapButtonTextRollColor         4   // RGBCOLOR.
#define CapButtonBackColor             8   // RGBCOLOR.
#define CapButtonBackRollColor         12  // RGBCOLOR.
#define CapButtonBorderColor           16  // RGBCOLOR.
#define CapButtonBorderRollColor       20  // RGBCOLOR.
#define CapButtonIco                   24  // hIcon.
#define CapButtonIcoAlt                28  // hIcon. When mouse moves over capbutton
#define CapButtonParam                 32  // DWORD. Custom user data
#define CapButtonResourceID            36  // n/a might be removed in future



#ifdef __cplusplus
}
#endif
