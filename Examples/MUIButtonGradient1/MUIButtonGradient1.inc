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
; MUIButtonGradient1 Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUIButtonGradient1 Constants
;-----------------------------------------------------------------------------------------
; Main Dialog
IDD_DIALOG              EQU 1000
IDC_CAPTIONBAR          EQU 1001
IDC_BUTTONGRADIENT      EQU 1002

; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101

; ModernUI Dialog Icons
ICO_MUI                 EQU 100

ICO_SYSTEM              EQU 201
ICO_SYSTEM_GREY         EQU 202

.DATA
;-----------------------------------------------------------------------------------------
; MUIButtonGradient1 Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'MUIButtonGradient1',0
AboutMsg                DB 'www.github.com/mrfearless',13,10,'Copyright © fearless 2019',0

szButtonGradientText    DB 'MUIButtonGradient1',0



.DATA?
;-----------------------------------------------------------------------------------------
; MUIButtonGradient1 Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hCaptionBar             DD ?
hIcoMain                DD ?
hBtnGradient            DD ?


