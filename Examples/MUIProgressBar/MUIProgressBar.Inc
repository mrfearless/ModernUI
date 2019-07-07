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

include ModernUI_ProgressBar.inc
includelib ModernUI_ProgressBar.lib


;-----------------------------------------------------------------------------------------
; MUIProgressBar Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUIProgressBar Constants
;-----------------------------------------------------------------------------------------
ICO_MAIN                EQU 100

; Main Dialog
IDD_DIALOG              EQU 1000
IDC_CAPTIONBAR          EQU 1001
IDC_STARTBUTTON         EQU 1002
IDC_EXITBUTTON          EQU 1003
IDC_PB1                 EQU 1011
IDC_PB2                 EQU 1012
IDC_PB3                 EQU 1013
IDC_PB4                 EQU 1014
IDC_PB5                 EQU 1015

; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; MUIProgressBar Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'ModernUI_ProgressBar Examples',0
AboutMsg                DB 'Copyright © fearless 2019',0

szStartButtonText       db "Start",0
szExitButtonText        db "Exit",0

dwTimer1                DD 0

.DATA?
;-----------------------------------------------------------------------------------------
; MUIProgressBar Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hCaptionBar             DD ?
hStartBtn               DD ?
hExitBtn                DD ?
hPB1                    DD ?
hPB2                    DD ?
hPB3                    DD ?
hPB4                    DD ?
hPB5                    DD ?
RtlGenRandom            DD ?  



