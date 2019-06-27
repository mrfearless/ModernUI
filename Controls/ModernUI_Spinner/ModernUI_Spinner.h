#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif


//------------------------------------------------------------------------------
// ModernUI_Spinner Prototypes
//------------------------------------------------------------------------------

void MUI_EXPORT MUISpinnerRegister(); // Use 'ModernUI_Spinner' as class in custom control
HWND MUI_EXPORT MUISpinnerCreate(HWND hWndParent, DWORD xpos, DWORD ypos, DWORD dwWidth, DWORD dwHeight, DWORD dwResourceID, DWORD dwStyle);
unsigned int MUI_EXPORT MUISpinnerSetProperty(HWND hModernUI_Spinner, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUISpinnerGetProperty(HWND hModernUI_Spinner, DWORD dwProperty);

// Add image handle (bitmap, icon or png) as a spinner frame image
bool MUI_EXPORT MUISpinnerAddFrame(HWND hModernUI_Spinner, DWORD dwImageType, HANDLE hImage);
bool MUI_EXPORT MUISpinnerAddFrames(HWND hModernUI_Spinner, DWORD dwCount, DWORD dwImageType, DWORD *lpArrayImageHandles);
// Load an image resource id (bitmap, icon or png) as a spinner frame image
bool MUI_EXPORT MUISpinnerLoadFrame(HWND hModernUI_Spinner, DWORD dwImageType, DWORD idResImage);
bool MUI_EXPORT MUISpinnerLoadFrames(HWND hModernUI_Spinner, DWORD dwCount, DWORD dwImageType, DWORD *lpArrayResourceIDs);
// Create a series of spinner frame images from an individual png handle/resid
bool MUI_EXPORT MUISpinnerAddImage(HWND hModernUI_Spinner, HANDLE hImage, DWORD dwNoFramesToCreate);
bool MUI_EXPORT MUISpinnerLoadImage(HWND hModernUI_Spinner, DWORD idResImage, DWORD dwNoFramesToCreate);
// Create a series of spinner frame images from a sprite sheet
MUISpinnerAddSpriteSheet(HWND hModernUI_Spinner, dwSpriteCount, DWORD dwImageType, HANDLE hImageSpriteSheet, DWORD bReverse);
MUISpinnerLoadSpriteSheet(HWND hModernUI_Spinner, dwSpriteCount, DWORD dwImageType, DWORD idResSpriteSheet, DWORD bReverse);

// Spinner animation control
void MUI_EXPORT MUISpinnerEnable(HWND hModernUI_Spinner);
void MUI_EXPORT MUISpinnerDisable(HWND hModernUI_Spinner);
void MUI_EXPORT MUISpinnerReset(HWND hModernUI_Spinner);
void MUI_EXPORT MUISpinnerPause(HWND hModernUI_Spinner);
void MUI_EXPORT MUISpinnerResume(HWND hModernUI_Spinner);


//------------------------------------------
// ModernUI_Spinner Styles
//------------------------------------------
#define MUISPNS_HAND                0x20    // Show a hand instead of an arrow when mouse moves over spinner.


//------------------------------------------------------------------------------
// ModernUI_Spinner Properties: Use with MUISpinnerSetProperty / 
// MUISpinnerGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
//------------------------------------------------------------------------------
#define SpinnerBackColor            0       // Background color of spinner
#define SpinnerSpeed                4       // milliseconds until next spin stage or rotation occurs
#define SpinnerDllInstance          8

// Spinner Image Type:
#define MUISPIT_NONE                0
#define MUISPIT_BMP                 1
#define MUISPIT_ICO                 2
#define MUISPIT_PNG                 3


#ifdef __cplusplus
}
#endif
