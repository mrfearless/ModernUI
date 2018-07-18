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


;-----------------------------------------------------------------------------------------
; TSOptions Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
InitGUI                 PROTO :DWORD
SetActiveButton         PROTO :DWORD


.CONST
;-----------------------------------------------------------------------------------------
; TSOptions Constants
;-----------------------------------------------------------------------------------------
; Icons
ICO_MAIN                EQU 100

; ModernUI button icons resids:
ICO_Application         EQU 201
ICO_myTeamSpeak         EQU 202
ICO_Playback            EQU 203
ICO_Capture             EQU 204
ICO_Design              EQU 205
ICO_Addons              EQU 206
ICO_Hotkeys             EQU 207
ICO_Whisper             EQU 208
ICO_Downloads           EQU 209
ICO_Chat                EQU 210
ICO_Security            EQU 211
ICO_Messages            EQU 212
ICO_Notifications       EQU 213


; Main Dialog
IDD_DIALOG				EQU 1000
IDC_BLACKFRAME          EQU 1001

; ModernUI button resource ids:
OPT_APPLICATION         EQU 1101
OPT_MYTEAMSPEAK         EQU 1102
OPT_PLAYBACK            EQU 1103
OPT_CAPTURE             EQU 1104
OPT_DESIGN              EQU 1105
OPT_ADDONS              EQU 1106
OPT_HOKEYS              EQU 1107
OPT_WHISPER             EQU 1108
OPT_DOWNLOADS           EQU 1109
OPT_CHAT                EQU 1110
OPT_SECURITY            EQU 1111
OPT_MESSAGES            EQU 1112
OPT_NOTIFICATIONS       EQU 1113


.DATA
;-----------------------------------------------------------------------------------------
; TSOptions Initialized Data
;-----------------------------------------------------------------------------------------
ClassName				DB 'DLGCLASS',0
AppName					DB 'TS Options',0
AboutMsg				DB 'www.LetTheLight.in',13,10,'Copyright © fearless 2018',0

; ModernUI button text
szOptApplication        DB 'Application',0
szOptmyTeamSpeak        DB 'myTeamSpeak',0
szOptPlayback           DB 'Playback',0
szOptCapture            DB 'Capture',0
szOptDesign             DB 'Design',0
szOptAddons             DB 'Addons',0
szOptHotkeys            DB 'Hotkeys',0
szOptWhisper            DB 'Whisper',0
szOptDownloads          DB 'Downloads',0
szOptChat               DB 'Chat',0
szOptSecurity           DB 'Security',0
szOptMessages           DB 'Messages',0
szOptNotifications      DB 'Notifications',0
szOptBlank              DB ' ',0

IFNDEF MUI_BUTTON_TEAMSPEAK
MUI_BUTTON_TEAMSPEAK            DD 0                                                    ; Font 
                                DD 0, 0, 0, 0, 05C5C5Ch                                 ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0FFFFFFh, 0FFFAF5h, 0FFECDCh, 0FDE4D0h, 08C8C8Ch     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD 0FFFFFFh, 0FCD7B9h, 0DDAC84h, 0CEA27Dh, 08C8C8Ch     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_ALL                                           ; BorderStyle
                                DD 0, 0, 0, 0                                           ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0, 0, 4, MUIBIT_NONE, 0                           ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0, 0                                              ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0 
ENDIF

.DATA?
;-----------------------------------------------------------------------------------------
; TSOptions Uninitialized Data
;-----------------------------------------------------------------------------------------
icc 					INITCOMMONCONTROLSEX <>
hInstance				DD ?
CommandLine				DD ?
hWnd					DD ?
hIcoMain                DD ?

; ModernUI button handles:
hOptApplication         DD ?
hOptmyTeamSpeak         DD ?
hOptPlayback            DD ?
hOptCapture             DD ?
hOptDesign              DD ?
hOptAddons              DD ?
hOptHotkeys             DD ?
hOptWhisper             DD ?
hOptDownloads           DD ?
hOptChat                DD ?
hOptSecurity            DD ?
hOptMessages            DD ?
hOptNotifications       DD ?
hOptBlank               DD ?

