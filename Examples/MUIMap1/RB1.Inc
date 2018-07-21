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

include ModernUI_Region.inc
includelib ModernUI_Region.lib

include ModernUI_Map.inc
includelib ModernUI_Map.lib

;-----------------------------------------------------------------------------------------
; RB1 Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; RB1 Constants
;-----------------------------------------------------------------------------------------

BMP_WATER               EQU 200

; Main Dialog
IDD_DIALOG				EQU 1000
IDC_RB1                 EQU 1001
IDC_BTN1                EQU 1002
IDC_MAP1                EQU 1003
IDC_LblCountry          EQU 1010

; Main Menu 
IDM_MENU				EQU 10000
IDM_FILE_EXIT			EQU 10001
IDM_HELP_ABOUT			EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; RB1 Initialized Data
;-----------------------------------------------------------------------------------------
ClassName				DB 'DLGCLASS',0
AppName					DB 'LTLI Dialog',0
AboutMsg				DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2014',0

szRegionAfrica          DB 'Central Africa',0
REGION_CENTRAL_AFRICA_DATA              DB 20h, 00h, 00h, 00h, 01h, 00h, 00h, 00h, 26h, 00h, 00h, 00h, 60h, 02h, 00h, 00h
                                        DB 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 34h, 00h, 00h, 00h, 25h, 00h, 00h, 00h
                                        DB 21h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 23h, 00h, 00h, 00h, 01h, 00h, 00h, 00h
                                        DB 20h, 00h, 00h, 00h, 01h, 00h, 00h, 00h, 25h, 00h, 00h, 00h, 02h, 00h, 00h, 00h
                                        DB 1Eh, 00h, 00h, 00h, 02h, 00h, 00h, 00h, 25h, 00h, 00h, 00h, 03h, 00h, 00h, 00h 
                                        DB 1Dh, 00h, 00h, 00h, 03h, 00h, 00h, 00h, 25h, 00h, 00h, 00h, 04h, 00h, 00h, 00h 
                                        DB 1Ch, 00h, 00h, 00h, 04h, 00h, 00h, 00h, 26h, 00h, 00h, 00h, 05h, 00h, 00h, 00h 
                                        DB 1Bh, 00h, 00h, 00h, 05h, 00h, 00h, 00h, 26h, 00h, 00h, 00h, 06h, 00h, 00h, 00h 
                                        DB 19h, 00h, 00h, 00h, 06h, 00h, 00h, 00h, 26h, 00h, 00h, 00h, 07h, 00h, 00h, 00h 
                                        DB 18h, 00h, 00h, 00h, 07h, 00h, 00h, 00h, 26h, 00h, 00h, 00h, 08h, 00h, 00h, 00h 
                                        DB 16h, 00h, 00h, 00h, 08h, 00h, 00h, 00h, 27h, 00h, 00h, 00h, 09h, 00h, 00h, 00h 
                                        DB 14h, 00h, 00h, 00h, 09h, 00h, 00h, 00h, 27h, 00h, 00h, 00h, 0Ah, 00h, 00h, 00h 
                                        DB 12h, 00h, 00h, 00h, 0Ah, 00h, 00h, 00h, 27h, 00h, 00h, 00h, 0Bh, 00h, 00h, 00h 
                                        DB 11h, 00h, 00h, 00h, 0Bh, 00h, 00h, 00h, 28h, 00h, 00h, 00h, 0Ch, 00h, 00h, 00h 
                                        DB 10h, 00h, 00h, 00h, 0Ch, 00h, 00h, 00h, 2Ah, 00h, 00h, 00h, 0Dh, 00h, 00h, 00h 
                                        DB 0Fh, 00h, 00h, 00h, 0Dh, 00h, 00h, 00h, 2Ch, 00h, 00h, 00h, 0Eh, 00h, 00h, 00h 
                                        DB 0Eh, 00h, 00h, 00h, 0Eh, 00h, 00h, 00h, 2Dh, 00h, 00h, 00h, 0Fh, 00h, 00h, 00h 
                                        DB 09h, 00h, 00h, 00h, 0Fh, 00h, 00h, 00h, 2Dh, 00h, 00h, 00h, 10h, 00h, 00h, 00h 
                                        DB 04h, 00h, 00h, 00h, 10h, 00h, 00h, 00h, 2Eh, 00h, 00h, 00h, 11h, 00h, 00h, 00h 
                                        DB 03h, 00h, 00h, 00h, 11h, 00h, 00h, 00h, 2Fh, 00h, 00h, 00h, 12h, 00h, 00h, 00h 
                                        DB 02h, 00h, 00h, 00h, 12h, 00h, 00h, 00h, 2Fh, 00h, 00h, 00h, 13h, 00h, 00h, 00h 
                                        DB 02h, 00h, 00h, 00h, 13h, 00h, 00h, 00h, 30h, 00h, 00h, 00h, 14h, 00h, 00h, 00h 
                                        DB 01h, 00h, 00h, 00h, 14h, 00h, 00h, 00h, 31h, 00h, 00h, 00h, 15h, 00h, 00h, 00h 
                                        DB 01h, 00h, 00h, 00h, 15h, 00h, 00h, 00h, 32h, 00h, 00h, 00h, 16h, 00h, 00h, 00h 
                                        DB 00h, 00h, 00h, 00h, 16h, 00h, 00h, 00h, 34h, 00h, 00h, 00h, 19h, 00h, 00h, 00h 
                                        DB 01h, 00h, 00h, 00h, 19h, 00h, 00h, 00h, 33h, 00h, 00h, 00h, 1Ah, 00h, 00h, 00h 
                                        DB 01h, 00h, 00h, 00h, 1Ah, 00h, 00h, 00h, 15h, 00h, 00h, 00h, 1Bh, 00h, 00h, 00h 
                                        DB 17h, 00h, 00h, 00h, 1Ah, 00h, 00h, 00h, 2Bh, 00h, 00h, 00h, 1Bh, 00h, 00h, 00h 
                                        DB 2Fh, 00h, 00h, 00h, 1Ah, 00h, 00h, 00h, 32h, 00h, 00h, 00h, 1Bh, 00h, 00h, 00h 
                                        DB 02h, 00h, 00h, 00h, 1Bh, 00h, 00h, 00h, 13h, 00h, 00h, 00h, 1Ch, 00h, 00h, 00h 
                                        DB 19h, 00h, 00h, 00h, 1Bh, 00h, 00h, 00h, 29h, 00h, 00h, 00h, 1Ch, 00h, 00h, 00h 
                                        DB 02h, 00h, 00h, 00h, 1Ch, 00h, 00h, 00h, 12h, 00h, 00h, 00h, 1Dh, 00h, 00h, 00h 
                                        DB 1Bh, 00h, 00h, 00h, 1Ch, 00h, 00h, 00h, 26h, 00h, 00h, 00h, 1Dh, 00h, 00h, 00h 
                                        DB 03h, 00h, 00h, 00h, 1Dh, 00h, 00h, 00h, 11h, 00h, 00h, 00h, 1Eh, 00h, 00h, 00h 
                                        DB 1Dh, 00h, 00h, 00h, 1Dh, 00h, 00h, 00h, 22h, 00h, 00h, 00h, 1Eh, 00h, 00h, 00h 
                                        DB 03h, 00h, 00h, 00h, 1Eh, 00h, 00h, 00h, 11h, 00h, 00h, 00h, 1Fh, 00h, 00h, 00h 
                                        DB 04h, 00h, 00h, 00h, 1Fh, 00h, 00h, 00h, 12h, 00h, 00h, 00h, 21h, 00h, 00h, 00h 
                                        DB 05h, 00h, 00h, 00h, 21h, 00h, 00h, 00h, 08h, 00h, 00h, 00h, 22h, 00h, 00h, 00h 
                                        DB 06h, 00h, 00h, 00h, 22h, 00h, 00h, 00h, 08h, 00h, 00h, 00h, 23h, 00h, 00h, 00h 
                                        DB 07h, 00h, 00h, 00h, 23h, 00h, 00h, 00h, 08h, 00h, 00h, 00h, 25h, 00h, 00h, 00h                               

REGION_CENTRAL_AFRICA_DATA_SIZE         DD ($ - REGION_CENTRAL_AFRICA_DATA)

szCountry               DB MAX_PATH DUP (0)
szBritishIsles          DB 'British Isles',0

szIrelandClicked        DB 'Ireland Clicked!',0
szScotlandClicked       DB 'Scotland Clicked!',0
szEnglandClicked        DB 'England Clicked!',0
szWalesClicked          DB 'Wales Clicked!',0
szNIrelandClicked       DB 'Northern Ireland Clicked!',0


.DATA?
;-----------------------------------------------------------------------------------------
; RB1 Uninitialized Data
;-----------------------------------------------------------------------------------------
icc 					INITCOMMONCONTROLSEX <>
hInstance				DD ?
CommandLine				DD ?
hWnd					DD ?
hRB1                    DD ?
hMUIMap                 DD ?
hLblCountry             DD ?
hPrevMapButton          DD ?

