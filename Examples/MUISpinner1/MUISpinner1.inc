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

include ModernUI_Spinner.inc
includelib ModernUI_Spinner.lib

;-----------------------------------------------------------------------------------------
; MUIButton1 Prototypes
;-----------------------------------------------------------------------------------------
WinMain                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; MUIButton1 Constants
;-----------------------------------------------------------------------------------------

ICO_MAIN                EQU 100
BMP_BACKIMAGE           EQU 101

BMP_SPIN1               EQU 201 ; "Images/FramesSpinners/squares-circle-grey 1.bmp"
BMP_SPIN2               EQU 202 ; "Images/FramesSpinners/squares-circle-grey 2.bmp"
BMP_SPIN3               EQU 203 ; "Images/FramesSpinners/squares-circle-grey 3.bmp"
BMP_SPIN4               EQU 204 ; "Images/FramesSpinners/squares-circle-grey 4.bmp"
BMP_SPIN5               EQU 205 ; "Images/FramesSpinners/squares-circle-grey 5.bmp"
BMP_SPIN6               EQU 206 ; "Images/FramesSpinners/squares-circle-grey 6.bmp"
BMP_SPIN7               EQU 207 ; "Images/FramesSpinners/squares-circle-grey 7.bmp"
BMP_SPIN8               EQU 208 ; "Images/FramesSpinners/squares-circle-grey 8.bmp"

PNG_SPIN2               EQU 402 ; "Images/SingleImageSpinners/small_12fadelines_spinner.png" - small segment fading
PNG_SPIN3               EQU 403 ; "Images/SingleImageSpinners/fadedcircle_spinner64x64.png" - faded circle
PNG_SPIN4               EQU 404 ; "Images/SingleImageSpinners/green_3recyclearrows_spinner64x64.png" - 3 recycle green arrows
PNG_SPIN5               EQU 405 ; "Images/SingleImageSpinners/brokenwheel_12faded_spinner64x64.png" - 12 segments fading
PNG_SPIN6               EQU 406 ; "Images/SingleImageSpinners/blue_circlearrows64x64.png" - blue with arrows
PNG_SPIN7               EQU 407 ; "Images/SingleImageSpinners/large_gear_spinner64x64.png" - large gear
PNG_SPIN8               EQU 408 ; "Images/SingleImageSpinners/green_3arrows_spinner48x48.png" - 3 green arrows
PNG_SPIN7B              EQU 409 ; "Images/SingleImageSpinners/small_gear_spinner32x322.png" - small gear

PNG_CLOCK1              EQU 501 ; "Images/FramesSpinners/832/832 01.png"
PNG_CLOCK2              EQU 502 ; 
PNG_CLOCK3              EQU 503 ; 
PNG_CLOCK4              EQU 504 ; 
PNG_CLOCK5              EQU 505 ; 
PNG_CLOCK6              EQU 506 ; 
PNG_CLOCK7              EQU 507 ; 
PNG_CLOCK8              EQU 508 ; 
PNG_CLOCK9              EQU 509 ; 
PNG_CLOCK10             EQU 510 ; 
PNG_CLOCK11             EQU 511 ; 
PNG_CLOCK12             EQU 512 ; 
PNG_CLOCK13             EQU 513 ; 
PNG_CLOCK14             EQU 514 ; 
PNG_CLOCK15             EQU 515 ; 
PNG_CLOCK16             EQU 516 ; 
PNG_CLOCK17             EQU 517 ; 
PNG_CLOCK18             EQU 518 ; 
PNG_CLOCK19             EQU 519 ; 
PNG_CLOCK20             EQU 520 ; 
PNG_CLOCK21             EQU 521 ; 
PNG_CLOCK22             EQU 522 ; 
PNG_CLOCK23             EQU 523 ; 
PNG_CLOCK24             EQU 524 ; "Images/FramesSpinners/832/832 24.png"

BMP_CLOCK_SPRITESHEET   EQU 600 ; "Images/SpritesheetSpinners/clock_grey_spritesheet1782x81.bmp"
PNG_CLOCK_SPRITESHEET   EQU 601 ; "Images/SpritesheetSpinners/clock_spritesheet1782x81.png"
PNG_INFINITY_SPRITESHEET EQU 602 ; "Images/SpritesheetSpinners/infinity_spritesheet1280x39.png"
PNG_SEARCH_SPRITESHEET  EQU 603 ; "Images/SpritesheetSpinners/green_searcharrow_spritesheet1152x64.png"

; Main Dialog
IDD_DIALOG              EQU 1000
IDC_CAPTIONBAR          EQU 1001

IDC_SPINNER1            EQU 1101
IDC_SPINNER2            EQU 1102
IDC_SPINNER3            EQU 1103
IDC_SPINNER4            EQU 1104
IDC_SPINNER5            EQU 1105
IDC_SPINNER6            EQU 1106
IDC_SPINNER7            EQU 1107
IDC_SPINNER8            EQU 1108
IDC_SPINNER9            EQU 1109
IDC_SPINNER7B           EQU 1110

IDC_SPINNERSPRITE1      EQU 1121
IDC_SPINNERSPRITE2      EQU 1122
IDC_SPINNERSPRITE3      EQU 1123
IDC_SPINNERSPRITE4      EQU 1124


; Main Menu 
IDM_MENU                EQU 10000
IDM_FILE_EXIT           EQU 10001
IDM_HELP_ABOUT          EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; MUIButton1 Initialized Data
;-----------------------------------------------------------------------------------------
ClassName               DB 'DLGCLASS',0
AppName                 DB 'ModernUI_Spinner Control Examples',0
AboutMsg                DB 'Copyright © fearless 2019',0

bSpinner1Pause          DD FALSE
bSpinner2Pause          DD FALSE
bSpinner3Pause          DD FALSE
bSpinner4Pause          DD FALSE
bSpinner5Pause          DD FALSE
bSpinner6Pause          DD FALSE
bSpinner7Pause          DD FALSE
bSpinner8Pause          DD FALSE
bSpinner9Pause          DD FALSE
bSpinner7bPause         DD FALSE
bSpinnerSprite1Pause    DD FALSE
bSpinnerSprite2Pause    DD FALSE
bSpinnerSprite3Pause    DD FALSE
bSpinnerSprite4Pause    DD FALSE

.DATA?
;-----------------------------------------------------------------------------------------
; MUIButton1 Uninitialized Data
;-----------------------------------------------------------------------------------------
icc                     INITCOMMONCONTROLSEX <>
hInstance               DD ?
CommandLine             DD ?
hWnd                    DD ?
hCaptionBar             DD ?
hSpinner1               DD ?
hSpinner2               DD ?
hSpinner3               DD ?
hSpinner4               DD ?
hSpinner5               DD ?
hSpinner6               DD ?
hSpinner7               DD ?
hSpinner7b              DD ?
hSpinner8               DD ?
hSpinner9               DD ?
hSpinnerSprite1         DD ?
hSpinnerSprite2         DD ?
hSpinnerSprite3         DD ?
hSpinnerSprite4         DD ?
hBackImage              DD ?
