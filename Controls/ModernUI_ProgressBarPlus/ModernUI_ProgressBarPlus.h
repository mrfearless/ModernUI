#ifdef __cplusplus
extern "C" {
#endif

#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif


//------------------------------------------------------------------------------
// ModernUI_ProgressBar Prototypes
//------------------------------------------------------------------------------

void MUI_EXPORT MUIProgressBarRegister(); // Use 'ModernUI_ProgressBar' as class in custom control
HWND MUI_EXPORT MUIProgressBarCreate(HWND hWndParent, DWORD xpos, DWORD ypos, DWORD dwWidth, DWORD dwHeight, DWORD dwResourceID, DWORD dwStyle);
unsigned int MUI_EXPORT MUIProgressBarSetProperty(HWND hModernUI_ProgressBar, DWORD dwProperty, DWORD dwPropertyValue);
unsigned int MUI_EXPORT MUIProgressBarGetProperty(HWND hModernUI_ProgressBar, DWORD dwProperty);
bool MUI_EXPORT MUIProgressBarSetMinMax(HWND hModernUI_ProgressBar, DWORD dwMin, DWORD dwMax);
unsigned int MUI_EXPORT MUIProgressBarSetPercent(HWND hModernUI_ProgressBar, DWORD dwPercent);
unsigned int MUI_EXPORT MUIProgressBarGetPercent(HWND hModernUI_ProgressBar);
bool MUI_EXPORT MUIProgressBarStep(HWND hModernUI_ProgressBar);



//------------------------------------------------------------------------------
// ModernUI_ProgressBar Properties: Use with MUIProgressBarSetProperty / 
// MUIProgressBarGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
//------------------------------------------------------------------------------
#define ProgressBarTextColor        0   // Text color 
#define ProgressBarTextFont         4   // Font
#define ProgressBarBackColor        8   // Background color
#define ProgressBarProgressColor    12  //
#define ProgressBarBorderColor      16  //
#define ProgressBarPercent          20  // 
#define ProgressBarMin              24  //
#define ProgressBarMax              28  //
#define ProgressBarStep             32  //



#ifdef __cplusplus
}
#endif
