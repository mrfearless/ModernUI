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

include ModernUI_Text.inc
includelib ModernUI_Text.lib

include ModernUI_ProgressDots.inc
includelib ModernUI_ProgressDots.lib

;-----------------------------------------------------------------------------------------
; MUIPLTest Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUIPLTest Constants
;-----------------------------------------------------------------------------------------

ICO_MAIN                EQU 100
BMP_RSLOGO              EQU 200                


; Main Dialog
IDD_DIALOG				EQU 1000
IDC_BTNCANCEL           EQU 1001
IDC_TEXT1               EQU 1003
IDC_CAPTIONBAR          EQU 1019
IDC_MUIPD               EQU 1020




.DATA
;-----------------------------------------------------------------------------------------
; MUIPLTest Initialized Data
;-----------------------------------------------------------------------------------------
ClassName				DB 'DLGCLASS',0
AppName					DB 'Radasm Studio Installer',0
AboutMsg				DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2014',0

szBtnCancelText         DB "Cancel",0
szInstalling            DB "Installing...",0


.DATA?
;-----------------------------------------------------------------------------------------
; MUIPLTest Uninitialized Data
;-----------------------------------------------------------------------------------------
icc 					INITCOMMONCONTROLSEX <>
hInstance				DD ?
CommandLine				DD ?
hWnd					DD ?
hIcoMain                DD ?
hCaptionBar             DD ?
hText1                  DD ?
hMUIPD                  DD ?
hBtnCancel              DD ?



