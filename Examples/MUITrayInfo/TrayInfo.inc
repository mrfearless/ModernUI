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

include ModernUI_Button.inc
includelib ModernUI_Button.lib

include ModernUI_CaptionBar.inc
includelib ModernUI_CaptionBar.lib

include ModernUI_Checkbox.inc
includelib ModernUI_Checkbox.lib

include ModernUI_TrayMenu.inc
includelib ModernUI_TrayMenu.lib

include fpu.inc
includelib fpu.lib


;-----------------------------------------------------------------------------------------
; TrayInfo Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
InitGUI                 PROTO :DWORD
InitTimers              PROTO :DWORD

CPULoad                 PROTO
GetCPULoad              PROTO :DWORD
GetMemoryLoad           PROTO

.CONST
;-----------------------------------------------------------------------------------------
; TrayInfo Constants
;-----------------------------------------------------------------------------------------
ICO_MAIN                EQU 100
ICO_BLANK               EQU 101

BMP_TM_SHOW             EQU 200
BMP_TM_HIDE             EQU 201
BMP_TM_ICONS            EQU 202
BMP_TM_CPU              EQU 203
BMP_TM_MEM              EQU 204
BMP_TM_TIME             EQU 205
BMP_TM_EXIT             EQU 206


; Main Dialog
IDD_DIALOG              EQU 1000
IDC_CAPTIONBAR          EQU 1001 ; ModernUI_CaptionBar control resource id
IDC_BUTTONEXIT          EQU 1002 ; ModernUI_Button control resource id
IDC_BUTTONHIDE          EQU 1003 ; ModernUI_Button control resource id
IDC_CHECKCPU            EQU 1004 ; ModernUI_Checkbox control resource id
IDC_CHECKMEM            EQU 1005 ; ModernUI_Checkbox control resource id


; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101

; Timer IDs for CPU and MEM icons
TIMER_CPU               EQU 1
TIMER_MEM               EQU 2

; CPU Icon poll times
TIME_CPU_05             EQU 500
TIME_CPU_1              EQU 1000
TIME_CPU_2              EQU 2000
TIME_CPU_3              EQU 3000
TIME_CPU_5              EQU 5000

; MEM Icon poll times
TIME_MEM_2              EQU 2000
TIME_MEM_5              EQU 5000
TIME_MEM_10             EQU 10000
TIME_MEM_20             EQU 20000
TIME_MEM_30             EQU 30000

; for g_IconCPU
ICONS_CPU_SHOW          EQU 0
ICONS_CPU_HIDE          EQU 1

; for g_IconMEM
ICONS_MEM_SHOW          EQU 0
ICONS_MEM_HIDE          EQU 1

; for g_ResponseCPU
RESPONSE_CPU_05_SECS    EQU 0
RESPONSE_CPU_1_SEC      EQU 1
RESPONSE_CPU_2_SECS     EQU 2
RESPONSE_CPU_3_SECS     EQU 3
RESPONSE_CPU_5_SECS     EQU 4

; for g_ResponseMEM
RESPONSE_MEM_2_SECS     EQU 0
RESPONSE_MEM_5_SECS     EQU 1
RESPONSE_MEM_10_SECS    EQU 2
RESPONSE_MEM_20_SECS    EQU 3
RESPONSE_MEM_30_SECS    EQU 4


.DATA
;-----------------------------------------------------------------------------------------
; TrayInfo Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'TrayInfo - cpu and memory load info',0
AboutMsg                DB 'github.com/mrfearless',13,10,'Copyright © fearless 2019',0

szButtonTextExit        DB 'Exit',0
szButtonTextHide        DB 'Hide',0
szCheckTextCPU          DB 'Show CPU Load Icon',0
szCheckTextMEM          DB 'Show Memory Load Icon',0

szZeroPercent           DB '0',0
szPercentage            DB '%',0

szCPUToolTip            DB 32 DUP (0)
szMEMToolTip            DB 32 DUP (0)
szCPUTip                DB 'CPU Load ',0
szMEMTip                DB 'MEM Load ',0
szCpuLoadPercent        DB 8 DUP (0)
szMemLoadPercent        DB 8 DUP (0)

last_userTime           FILETIME <0,0>
last_kernelTime         FILETIME <0,0>
last_idleTime           FILETIME <0,0>

g_IconCPU               DD 0 ; 0=show cpu, 1=hide cpu
g_IconMEM               DD 0 ; 0=show mem, 1=hide mem
g_ResponseCPU           DD RESPONSE_CPU_1_SEC
g_ResponseMEM           DD RESPONSE_MEM_5_SECS


.DATA?
;-----------------------------------------------------------------------------------------
; TrayInfo Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?

hMainIcon               DD ?
hIconBlank              DD ?
hIconCPU                DD ?
hIconMEM                DD ?

hBmpShow                DD ?
hBmpHide                DD ?
hBmpIcons               DD ?
hBmpCPU                 DD ?
hBmpMEM                 DD ?
hBmpTime                DD ?
hBmpExit                DD ?

hFontCPU                DD ?
hFontMEM                DD ?

hCaptionBar             DD ? ; handle ModernUI_CaptionBar control
hBtnExit                DD ? ; handle ModernUI_Button control
hBtnHide                DD ? ; handle ModernUI_Button control
hChkCPU                 DD ? ; handle ModernUI_Checkbox control
hChkMEM                 DD ? ; handle ModernUI_Checkbox control
hMUITM                  DD ? ; handle to ModernUI_TrayMenu main one
hMUITMCPU               DD ? ; handle to ModernUI_TrayMenu for cpu icon
hMUITMMEM               DD ? ; handle to ModernUI_TrayMenu for mem icon

hTrayMenu               DD ? ; menu for all tray icons
hTMSubMenuIcons         DD ? ; submenu for tray menu
hTMSubMenuResponseCPU   DD ? ; submenu for tray menu
hTMSubMenuResponseMEM   DD ? ; submenu for tray menu


