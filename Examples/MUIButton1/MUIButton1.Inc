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

;-----------------------------------------------------------------------------------------
; MUIButton1 Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUIButton1 Constants
;-----------------------------------------------------------------------------------------

ICO_SYSTEM              EQU 100
ICO_SYSTEM_GREY         EQU 101
PNG_CHART               EQU 102
PNG_CHART_GREY          EQU 103
BMP_HOUSE               EQU 104
BMP_HOUSE_GREY          EQU 105

; Main Dialog
IDD_DIALOG				EQU 1000
IDC_CAPTIONBAR          EQU 1001
IDC_BUTTON1             EQU 1002
IDC_BUTTON2             EQU 1003
IDC_BUTTON3             EQU 1004

; Main Menu 
IDM_MENU				EQU 10000
IDM_FILE_EXIT			EQU 10001
IDM_HELP_ABOUT			EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; MUIButton1 Initialized Data
;-----------------------------------------------------------------------------------------
ClassName				DB 'DLGCLASS',0
AppName					DB 'MUIButton Example #1',0
AboutMsg				DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2016',0
szButton1Text           DB 'Button 1',0
szButton2Text           DB 'Button 2',0
szButton3Text           DB 'Button 3',0
szBtnClicked            DB 'Button 1 was clicked.',0
szNotifyText            DB '23',0


.DATA?
;-----------------------------------------------------------------------------------------
; MUIButton1 Uninitialized Data
;-----------------------------------------------------------------------------------------
icc 					INITCOMMONCONTROLSEX <>
hInstance				DD ?
CommandLine				DD ?
hWnd					DD ?
hCaptionBar             DD ?
hBtn1                   DD ?
hBtn2                   DD ?
hBtn3                   DD ?


