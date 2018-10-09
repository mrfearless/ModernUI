#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif


//------------------------------------------------------------------------------
// ModernUI_ProgressDots Prototypes
//------------------------------------------------------------------------------

void MUI_EXPORT MUIProgressDotsRegister(); // Use 'ModernUI_ProgressDots' as class in RadASM custom class control
HWND MUI_EXPORT MUIProgressDotsCreate(HWND hWndParent, DWORD ypos, DWORD dwHeight, DWORD dwResourceID, DWORD dwStyle);
unsigned int MUI_EXPORT MUIProgressDotsSetProperty(HWND hMUIProgressDots, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUIProgressDotsGetProperty(HWND hMUIProgressDots, DWORD dwProperty);
void MUI_EXPORT MUIProgressDotsAnimateStart(HWND hMUIProgressDots);
void MUI_EXPORT MUIProgressDotsAnimateStop(HWND hMUIProgressDots);



//------------------------------------------------------------------------------
// ModernUI_ProgressDots Properties: Use with MUIProgressDotsSetProperty / 
// MUIProgressDotsGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
//------------------------------------------------------------------------------
#define ProgressDotsBackColor       0   // Background color of control 
#define ProgressDotsDotColor        4   // Progress Dots color 
#define ProgressDotsShowInterval    8   // Interval till dot starts showing, default is 16
#define ProgressDotsTimeInterval    12  // Milliseconds for timer, defaults to 10, higher will slow down animation of dots
#define ProgressDotsSpeed           16  // Speed for fast dots (before and after markers), default is 2. For adjusting xpos of dots. Middle portion is always xpos=xpos+1


#ifdef __cplusplus
}
#endif
