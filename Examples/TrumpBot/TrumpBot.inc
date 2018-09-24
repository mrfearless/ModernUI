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

include ModernUI_Tooltip.inc
includelib ModernUI_Tooltip.lib

include ModernUI_DesktopFace.inc
includelib ModernUI_DesktopFace.lib

include ModernUI_TrayMenu.inc
includelib ModernUI_TrayMenu.lib


;-----------------------------------------------------------------------------------------
; TrumpBot Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
InitGUI                 PROTO :DWORD


.CONST
;-----------------------------------------------------------------------------------------
; TrumpBot Constants
;-----------------------------------------------------------------------------------------

; Trump Resources
ICO_MAIN                EQU 100
ICO_TRUMP               EQU 200
RGN_TRUMP               EQU 201
WAV_PUNCH               EQU 300
WAV_MAGA                EQU 301
WAV_AMERICA             EQU 302
ANI_BOXGLOVE            EQU 310

; Timer IDs
TIMER_TRUMP             EQU 0
TIMER_TRUMP_HIDE        EQU 1

SHOWTRUMPTIME           EQU 1000 ; time that trump is visible for us to catch him!
                                 ; roughly long enough for him to say "america!"



.DATA
;-----------------------------------------------------------------------------------------
; TrumpBot Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'TrumpBot',0
AppName                 DB 'TrumpBot',0
AboutMsg                DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2018',0
szTrumpBotIntroText     DB 'Punch my face to begin. Try to catch me as I move around your desktop.',0
bTrumpStarted           DD FALSE


.DATA?
;-----------------------------------------------------------------------------------------
; TrumpBot Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hMainIcon               DD ?
hMUITM                  DD ?
hMUITIP                 DD ?
hTrayMenu               DD ?
hRCMenuPopup            DD ?
hRCSubMenuTrans         DD ?
hRCSubMenuZOrder        DD ?
hRCSubMenuFace          DD ?
hRCSubMenuSpeed         DD ?
hTMSubMenuFace          DD ?
hTMSubMenuSpeed         DD ?
hBoxGloveCursor         DD ?
hIcoTrump               DD ?
hDFTrump                DD ?


