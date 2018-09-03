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

include ModernUI_Text.inc
includelib ModernUI_Text.lib

include ModernUI_CaptionBar.inc
includelib ModernUI_CaptionBar.lib

;-----------------------------------------------------------------------------------------
; Text Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
;
;IFNDEF @TextFore
;@TextFore               STRUCT
;    Font                DD ?
;    Color               DD ?
;    ColorAlt            DD ?
;    ColorDisabled       DD ?
;@TextFore               ENDS
;ENDIF
;
;IFNDEF @TextBack
;@TextBack               STRUCT
;    Color               DD ?
;    ColorAlt            DD ?
;    ColorDisabled       DD ?
;@TextBack               ENDS
;ENDIF

;IFNDEF @MUIText
;@MUIText                    STRUCT
;    Font                    DD ?
;    Color                   DD ?
;    ColorAlt                DD ?
;    ColorDisabled           DD ?
;    STRUCT                  Back
;        Color               DD ?
;        ColorAlt            DD ?
;        ColorDisabled       DD ?
;    ENDS  
;@MUIText                    ENDS
;ENDIF

.CONST
;-----------------------------------------------------------------------------------------
; Text Constants
;-----------------------------------------------------------------------------------------
ICO_MAIN                EQU 100

; Main Dialog
IDD_DIALOG				EQU 1000
IDC_CAPTIONBAR          EQU 1099

; Main Menu 
IDM_MENU				EQU 10000
IDM_FILE_EXIT			EQU 10001
IDM_HELP_ABOUT			EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; Text Initialized Data
;-----------------------------------------------------------------------------------------
ClassName				DB 'DLGCLASS',0
AppName					DB 'ModernUI_Text Example',0
AboutMsg				DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2014',0

szText                  DB "This is a test",10,13,"and so is this",0




.DATA?
;-----------------------------------------------------------------------------------------
; Text Uninitialized Data
;-----------------------------------------------------------------------------------------
icc 					INITCOMMONCONTROLSEX <>
hInstance				DD ?
CommandLine				DD ?
hWnd					DD ?
hText1                  DD ?
hCaptionBar             DD ?
hIcoMain                DD ?


