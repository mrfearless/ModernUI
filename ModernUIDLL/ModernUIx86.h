#ifdef __cplusplus
extern "C" {
#endif


#ifdef _MSC_VER     // MSVC compiler
#define MUI_EXPORT __declspec(dllexport) __stdcall
#else
#define MUI_EXPORT
#endif

#Include "ModernUI.h"
#Include "ModernUI_CaptionBar.h"
#Include "ModernUI_CheckBox.h"
#Include "ModernUI_Button.h"
#Include "ModernUI_ProgressBar.h"
#Include "ModernUI_ProgressDots.h"
#Include "ModernUI_SmartPanel.h"
#Include "ModernUI_TextWide.h"
#Include "ModernUI_TrayMenu.h"

#ifdef __cplusplus
}
#endif