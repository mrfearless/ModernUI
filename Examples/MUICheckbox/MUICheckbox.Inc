include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib masm32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_CaptionBar.inc
includelib ModernUI_CaptionBar.lib

include ModernUI_Button.inc
includelib ModernUI_Button.lib

include ModernUI_Checkbox.inc
includelib ModernUI_Checkbox.lib

;-----------------------------------------------------------------------------------------
; MUICheckbox Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUICheckbox Constants
;-----------------------------------------------------------------------------------------

ICO_MUI                 EQU 100
ICO_NOCHECKMARK         EQU 101
ICO_CHECKMARK           EQU 102


; Main Dialog
IDD_DIALOG              EQU 1000

; Main Dialog
IDD_DIALOG              EQU 1000
IDC_CAPTIONBAR          EQU 1001
IDC_CHECKBOX1           EQU 1002
IDC_CHECKBOX2           EQU 1003
IDC_CHECKBOX3           EQU 1004
IDC_CHECKBOX4           EQU 1005

IDC_RADIO1              EQU 1010
IDC_RADIO2              EQU 1011
IDC_RADIO3              EQU 1012
IDC_RADIO4              EQU 1013

; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; MUICheckbox Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'MUICheckbox Example #1',0
AboutMsg                DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2018',0

szCheckbox1Text         DB 'Checkbox option 1 - disabled',0
szCheckbox2Text         DB 'Checkbox option 2 - disabled but set',0
szCheckbox3Text         DB 'Checkbox option 3',0
szCheckbox4Text         DB 'Checkbox option 3',0

szRadio1Text            DB 'Radio option 1 - disabled',0
szRadio2Text            DB 'Radio option 2 - disabled but set',0
szRadio3Text            DB 'Radio option 3',0
szRadio4Text            DB 'Radio option 4',0

bDark                   DD TRUE

.DATA?
;-----------------------------------------------------------------------------------------
; MUICheckbox Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hCaptionBar             DD ?
hChk1                   DD ?
hChk2                   DD ?
hChk3                   DD ?
hChk4                   DD ?
hRadio1                 DD ?
hRadio2                 DD ?
hRadio3                 DD ?
hRadio4                 DD ?





