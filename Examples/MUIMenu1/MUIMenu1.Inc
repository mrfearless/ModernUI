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
; MUIMenu1 Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUIMenu1 Constants
;-----------------------------------------------------------------------------------------

ICO_MUI                 EQU 100
ICO_IMAGE               EQU 101
ICO_FILE                EQU 102
ICO_FOLDER              EQU 103


; Main Dialog
IDD_DIALOG              EQU 1000
IDC_CAPTIONBAR          EQU 1001
IDC_MENUITEM1           EQU 1011
IDC_MENUITEM2           EQU 1012
IDC_MENUITEM3           EQU 1013

; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; MUIMenu1 Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'MUIMenu1 Example #1',0
AboutMsg                DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2016',0
szMenu1Text             DB 'Image Options',0
szMenu2Text             DB 'Filename Options',0
szMenu3Text             DB 'Folder Options',0




.DATA?
;-----------------------------------------------------------------------------------------
; MUIMenu1 Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hCaptionBar             DD ?
hMenu1                   DD ?
hMenu2                   DD ?
hMenu3                   DD ?



