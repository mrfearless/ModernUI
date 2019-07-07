//==============================================================================
//
// ModernUI Control - ModernUI_ProgressBar
//
// Copyright (c) 2019 by fearless
//
// All Rights Reserved
//
// http://github.com/mrfearless/ModernUI
//
//==============================================================================

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
// ModernUI_ProgressBar Styles
//------------------------------------------------------------------------------
#define MUIPBS_PULSE                0   // Show pulse hearbeat on progress (default)
#define MUIPBS_NOPULSE              1   // Dont show pulse heartbeat on progress
#define MUIPBS_TEXT_NONE            0   // Dont show % text (default)
#define MUIPBS_TEXT_CENTRE          2   // Show % text in centre of progress control
#define MUIPBS_TEXT_FOLLOW          4   // Show % text and follow progress bar 
#define MUIPBS_R2G                  8   // Show a fading red to green progress bar

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
#define @ProgressBarPulse           36  // BOOL. Use pulse glow on bar. (default TRUE)
#define @ProgressBarPulseTime       40  // DWORD. Milliseconds until pulse (default 3000ms)
#define @ProgressBarTextType        44  // DWORD. (Default 0) dont show. 1=show centre, 2=follow progress
#define @ProgressBarSetTextPos      48  // DWORD. (Default 0) 0 = preppend WM_SETTEXT text, 1 = append WM_SETTEXT text (not used currently)

// ProgressBar Text Type:
#define MUIPBTT_NONE                0   // No percentage text in progress bar (default)
#define MUIPBTT_CENTRE              1   // Percentage text in center of progress bar
#define MUIPBTT_FOLLOW              2   // Percentage text follows progress as it draws

#ifdef __cplusplus
}
#endif
