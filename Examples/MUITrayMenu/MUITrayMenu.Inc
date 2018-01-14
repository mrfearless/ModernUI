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

include ModernUI_TrayMenu.inc
includelib ModernUI_TrayMenu.lib 


;-----------------------------------------------------------------------------------------
; MUITrayMenu Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUITrayMenu Constants
;-----------------------------------------------------------------------------------------
; Main Dialog
IDD_DIALOG              EQU 1000
IDC_CAPTIONBAR          EQU 1001
IDC_SHOWNOTIFICATION    EQU 1002
IDC_EXIT                EQU 1003

; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101

; ModernUI Dialog Icons
ICO_MUI                 EQU 100
ICO_MIN                 EQU 101
ICO_MAX                 EQU 102
ICO_RES                 EQU 103
ICO_CLOSE               EQU 104

IDM_TEST0               EQU 10007
IDM_TEST1               EQU 10008
IDM_TRAY_URL            EQU 10009
IDM_TRAY_EXIT           EQU 10010
IDM_TRAY_OPT            EQU 10011


.DATA
;-----------------------------------------------------------------------------------------
; MUITrayMenu Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'MUITrayMenu',0
AboutMsg                DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2017',0
szShellCmdOpen          DB 'open',0


szTrayMenuTooltip       DB 'ModernUI TrayMenu',0
szNotifyMsg             DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2017',0
szNotifyTitle           DB 'ModernUI TrayMenu Control',0
szShowNotifyText        DB "Show Notification",0
szExitButton            DB "Exit",0

szTest0                 DB "TrayMenu Control",0
szTest1                 DB "fearless 2016",0
szWebUrl                DB "www.LetTheLight.in",0
szOptions               DB "Options...",0
szTrayMenuExit          DB "Exit",0

; TrayMenu macros used to define a menu for use with the TrayMenu control
;
;                          Menu Text Var       Menu ID         Menu State  Notes
;                          __________________  ______________  __________  ____________________________
MUITRAYMENU TrayMenu1
    MUITRAYMENU_ITEM       szTest0,            IDM_TEST0,      ENABLED     ; Test 0
    MUITRAYMENU_ITEM       ------------------                              ; Seperator
    MUITRAYMENU_ITEM       szTest1,            IDM_TEST1,      ENABLED     ; Test 1
    MUITRAYMENU_ITEM       szWebUrl,           IDM_TRAY_URL,   ENABLED     ; Url
    MUITRAYMENU_ITEM       ------------------                              ; Seperator
    MUITRAYMENU_ITEM       szOptions,          IDM_TRAY_OPT,   ENABLED     ; Options
    MUITRAYMENU_ITEM       ------------------                              ; Seperator
    MUITRAYMENU_ITEM       szTrayMenuExit,     IDM_TRAY_EXIT,  ENABLED     ; Exit 
MUITRAYMENU_END




.DATA?
;-----------------------------------------------------------------------------------------
; MUITrayMenu Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hCaptionBar             DD ?
hIcoMain                DD ?
hTrayMenu               DD ?
hNotifyBtn              DD ?
hExitBtn                DD ?
