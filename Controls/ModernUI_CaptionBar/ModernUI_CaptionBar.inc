;==============================================================================
;
; ModernUI Control - ModernUI_CaptionBar
;
; Copyright (c) 2018 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;
; This software is provided 'as-is', without any express or implied warranty. 
; In no event will the author be held liable for any damages arising from the 
; use of this software.
;
; Permission is granted to anyone to use this software for any non-commercial 
; program. If you use the library in an application, an acknowledgement in the
; application or documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave
; the original copyright notices intact and not misrepresent the origin of the
; software. It is not allowed to claim you wrote the original software. 
; Modified files must have a clear notice that the files are modified, and not
; in the original state. This includes the name of the person(s) who modified 
; the code. 
;
; If you want to distribute or redistribute any portion of this package, you 
; will need to include the full package in it's original state, including this
; license and all the copyrights.  
;
; While distributing this package (in it's original state) is allowed, it is 
; not allowed to charge anything for this. You may not sell or include the 
; package in any commercial package without having permission of the author. 
; Neither is it allowed to redistribute any of the package's components with 
; commercial applications.
;
;==============================================================================

;------------------------------------------------------------------------------
; ModernUI_CaptionBar Prototypes for users of controls
;------------------------------------------------------------------------------
MUICaptionBarRegister       PROTO                                           ; Use 'ModernUI_CaptionBar' as class in RadASM custom class control
MUICaptionBarCreate         PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszCaptionText, dwCaptionHeight, dwResourceID, dwStyle
MUICaptionBarSetProperty    PROTO :DWORD, :DWORD, :DWORD                    ; hModernUI_CaptionBar, dwProperty, dwPropertyValue
MUICaptionBarGetProperty    PROTO :DWORD, :DWORD                            ; hModernUI_CaptionBar, dwProperty
MUICaptionBarLoadIcons      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD ; hModernUI_CaptionBar, idResMin, idResMinAlt, idResMax, idResMaxAlt, idResRes, idResResAlt, idResClose, idResCloseAlt
MUICaptionBarLoadIconsDll   PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD ; hModernUI_CaptionBar, hInstance, idResMin, idResMinAlt, idResMax, idResMaxAlt, idResRes, idResResAlt, idResClose, idResCloseAlt
MUICaptionBarLoadBackImage  PROTO :DWORD, :DWORD, :DWORD                    ; hModernUI_CaptionBar, dwImageType, dwResIDImage

MUICaptionBarAddButton      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hModernUI_CaptionBar, lpszButtonText, dwResourceID, dwResIDImage, dwResIDImageAlt. Returns in eax hCapButton
MUICaptionBarAddButtonEx    PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hModernUI_CaptionBar, lpszButtonText, dwResourceID, hIcon, hIconAlt. Returns in eax hCapButton
MUICapButtonSetProperty     PROTO :DWORD, :DWORD, :DWORD                    ; hCapButton, dwProperty, dwPropertyValue
MUICapButtonGetProperty     PROTO :DWORD, :DWORD                            ; hCapButton, dwProperty

;------------------------------------------------------------------------------
; ModernUI_Caption Structures
;------------------------------------------------------------------------------
IFNDEF MUI_CAPTIONBAR_PROPERTIES
MUI_CAPTIONBAR_PROPERTIES       STRUCT
    dwTextColor                 DD ?    ; RGBCOLOR. Text color for captionbar text and system buttons (min/max/restore/close)
    dwTextFont                  DD ?    ; hFont. Font for captionbar text
    dwBackColor                 DD ?    ; RGBCOLOR. Background color of captionbar and system buttons (min/max/restore/close)
    dwBackImageType             DD ?    ; DWORD. Image Type - One of the following: MUICBIT_NONE,MUICBIT_BMP, MUICBIT_ICO, MUICBIT_PNG
    dwBackImage                 DD ?    ; hImage. Image to display in captionbar background.
    dwBackImageOffsetX          DD ?    ; DWORD. Offset x +/- to set position of hImage
    dwBackImageOffsetY          DD ?    ; DWORD. Offset y +/- to set position of hImage    
    dwButtonTextRollColor       DD ?    ; RGBCOLOR. Text color for system buttons (min/max/restore/close) when mouse moves over button
    dwButtonBackRollColor       DD ?    ; RGBCOLOR. Background color for system buttons (min/max/restore/close) when mouse moves over button
    dwButtonBorderColor         DD ?    ; RGBCOLOR. Border color for system buttons (min/max/restore/close). 0 = use same as @CaptionBarBackColor
    dwButtonBorderRollColor     DD ?    ; RGBCOLOR. Border color for system buttons (min/max/restore/close) when mouse moves over button. 0 = use @CaptionBarBtnBckRollColor  
    dwButtonsWidth              DD ?    ; DWORD. System buttons width. Defaults = 32px
    dwButtonsHeight             DD ?    ; DWORD. System buttons height. Defaults = 28px
    dwButtonsOffsetX            DD ?    ; DWORD. Offset y +/- to set position of system buttons (min/max/restore/close) in relation to right of captionbar
    dwButtonsOffsetY            DD ?    ; DWORD. Offset y + to set position of system buttons (min/max/restore/close) in relation to top of captionbar    
    dwBtnIcoMin                 DD ?    ; hIcon. For minimize button
    dwBtnIcoMinAlt              DD ?    ; hIcon. For minimize button when mouse moves over button
    dwBtnIcoMax                 DD ?    ; hIcon. For maximize button
    dwBtnIcoMaxAlt              DD ?    ; hIcon. For maximize button when mouse moves over button
    dwBtnIcoRes                 DD ?    ; hIcon. For restore button
    dwBtnIcoResAlt              DD ?    ; hIcon. For restore button when mouse moves over button
    dwBtnIcoClose               DD ?    ; hIcon. For close button
    dwBtnIcoCloseAlt            DD ?    ; hIcon. For close button when mouse moves over button
    dwWindowBackColor           DD ?    ; RGBCOLOR. If -1 = No painting of window/dialog background, handled by user or default system.
    dwWindowBorderColor         DD ?    ; RGBCOLOR. If -1 = No border. if WindowBackColor != -1 then color of border to paint on window.    
    dwDllInstance               DD ?    ; hInstance. For loading resources (icons) - normally set to 0 (current module) but when resources are in a dll set this before calling MUICaptionBarLoadIcons
    dwCaptionBarParam           DD ?    ; DWORD. Custom user data
MUI_CAPTIONBAR_PROPERTIES       ENDS
ENDIF

IFNDEF MUI_CAPBUTTON_PROPERTIES
MUI_CAPBUTTON_PROPERTIES        STRUCT  
    dwTextColor                 DD ?    ; RGBCOLOR
    dwTextRollColor             DD ?    ; RGBCOLOR
    dwBackColor                 DD ?    ; RGBCOLOR. Color of back of button.
    dwBackRollColor             DD ?    ; RGBCOLOR. Color of back of button when mouse moves over.
    dwBorderColor               DD ?    ; RGBCOLOR. Color of border of button. 0 = use same as dwBackColor
    dwBorderRollColor           DD ?    ; RGBCOLOR. Color of border of button when mouse moves over. 0 = use same as dwBackRollColor
    dwIco                       DD ?    ; hIcon. Handle of icon to use for button
    dwIcoAlt                    DD ?    ; hIcon. Handle of icon to use for button when mouse moves over it
    dwParam                     DD ?    ; DWORD. Custom user data. Passed as wNotifyCode (HIWORD of wParam) in WM_COMMAND
    dwResourceID                DD ?    ; DWORD. Resource ID for button    
MUI_CAPBUTTON_PROPERTIES        ENDS
ENDIF


.CONST
;------------------------------------------------------------------------------
; ModernUI_Caption Constants
;------------------------------------------------------------------------------

; CaptionBar Styles
MUICS_LEFT                      EQU 0h   ; left align caption bar text
MUICS_CENTER                    EQU 1h   ; center align caption bar text
MUICS_NOMINBUTTON               EQU 2h   ; no minimize button
MUICS_NOMAXBUTTON               EQU 4h   ; no maximize/restore button
MUICS_NOCLOSEBUTTON             EQU 8h   ; no close button
MUICS_REDCLOSEBUTTON            EQU 10h  ; close button uses win8+ red background color
MUICS_NOMOVEWINDOW              EQU 20h  ; Dont allow window to move when caption bar is clicked and dragged, if not specified will allow this.
MUICS_WINNOMUISTYLE             EQU 40h  ; Dont apply MUI borderless frame style to window/dialog, if not specified will apply MUI style.
MUICS_WINNODROPSHADOW           EQU 80h  ; Dont apply drop shadow to window/dialog. If not specified will apply dropshadow if MUICS_WINDOWNOMUISTYLE not specified.
MUICS_USEICONSFORBUTTONS        EQU 100h ; Use icons instead of text (Marlett font glyphs) for the min/max/res/close buttons: Load icons via the MUICaptionBarLoadIcons functions or set handles via @CaptionBarBtnIcoXXX properties
MUICS_KEEPICONS                 EQU 200h ; Dont delete icons handles when control is destoyed. Essential if icon handles are used in multiple controls or where set directly with properties 
MUICS_NOCAPTIONTITLETEXT        EQU 400h ; Dont draw a title text value, use lpszCaptionText for taskbar name of app only.
MUICS_NOBORDER                  EQU 800h ; No border used, so position ModernUI_CaptionBar at 0,0 instead of at 1,1
MUICS_WINSIZE                   EQU 1000h; Dialog/Window is resizable.
MUICS_THEME                     EQU 8000h; Use default windows theme colors and react to WM_THEMECHANGED

;------------------------------------------------------------------------------
; ModernUI_Caption Properties: Use with MUICaptionBarSetProperty / 
; MUICaptionBarGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@CaptionBarTextColor            EQU 0   ; RGBCOLOR. Text color for captionbar text and system buttons (min/max/restore/close)
@CaptionBarTextFont             EQU 4   ; hFont. Font for captionbar text
@CaptionBarBackColor            EQU 8   ; RGBCOLOR. Background color of captionbar and system buttons (min/max/restore/close)
@CaptionBarBackImageType        EQU 12  ; DWORD. Image Type - One of the following: MUICBIT_NONE,MUICBIT_BMP, MUICBIT_ICO, MUICBIT_PNG
@CaptionBarBackImage            EQU 16  ; hImage. Image to display in captionbar background.
@CaptionBarBackImageOffsetX     EQU 20  ; DWORD. Offset x +/- to set position of hImage. Default = 0
@CaptionBarBackImageOffsetY     EQU 24  ; DWORD. Offset y +/- to set position of hImage. Default = 0
@CaptionBarBtnTxtRollColor      EQU 28  ; RGBCOLOR. Text color for system buttons (min/max/restore/close) when mouse moves over button
@CaptionBarBtnBckRollColor      EQU 32  ; RGBCOLOR. Background color for system buttons (min/max/restore/close) when mouse moves over button
@CaptionBarBtnBorderColor       EQU 36  ; RGBCOLOR. Border color for system buttons (min/max/restore/close). 0 = use same as @CaptionBarBackColor
@CaptionBarBtnBorderRollColor   EQU 40  ; RGBCOLOR. Border color for system buttons (min/max/restore/close) when mouse moves over button. 0 = use @CaptionBarBtnBckRollColor
@CaptionBarBtnWidth             EQU 44  ; DWORD. System buttons width. Defaults = 32px
@CaptionBarBtnHeight            EQU 48  ; DWORD. System buttons height. Defaults = 28px
@CaptionBarBtnOffsetX           EQU 52  ; DWORD. Offset y +/- to set position of system buttons (min/max/restore/close) in relation to right of captionbar
@CaptionBarBtnOffsetY           EQU 56  ; DWORD. Offset y + to set position of system buttons (min/max/restore/close) in relation to top of captionbar
@CaptionBarBtnIcoMin            EQU 60  ; hIcon. For minimize button
@CaptionBarBtnIcoMinAlt         EQU 64  ; hIcon. For minimize button when mouse moves over button
@CaptionBarBtnIcoMax            EQU 68  ; hIcon. For maximize button
@CaptionBarBtnIcoMaxAlt         EQU 72  ; hIcon. For maximize button when mouse moves over button
@CaptionBarBtnIcoRes            EQU 76  ; hIcon. For restore button
@CaptionBarBtnIcoResAlt         EQU 80  ; hIcon. For restore button when mouse moves over button
@CaptionBarBtnIcoClose          EQU 84  ; hIcon. For close button
@CaptionBarBtnIcoCloseAlt       EQU 88  ; hIcon. For close button when mouse moves over button
@CaptionBarWindowBackColor      EQU 92  ; RGBCOLOR. If -1 = No painting of window/dialog background, handled by user or default system.
@CaptionBarWindowBorderColor    EQU 96  ; RGBCOLOR. If -1 = No border. if WindowBackColor != -1 then color of border to paint on window.
@CaptionBarDllInstance          EQU 100 ; hInstance. For loading resources (icons) - normally set to 0 (current module) but when resources are in a dll set this before calling MUICaptionBarLoadIcons
@CaptionBarParam                EQU 104 ; DWORD. Custom user data

; CaptionBar Back Image Types
MUICBIT_NONE                    EQU 0
MUICBIT_BMP                     EQU 1
MUICBIT_ICO                     EQU 2
MUICBIT_PNG                     EQU 3

;------------------------------------------------------------------------------
; CaptionBar CapButton properties (extra custom buttons added with 
; MUICaptionBarAddButton)
; Note: setting ModernUI_CaptionBar properties will cascade down to set 
; equivalent CapButton properties.
;------------------------------------------------------------------------------
@CapButtonTextColor             EQU 0   ; RGBCOLOR.
@CapButtonTextRollColor         EQU 4   ; RGBCOLOR.
@CapButtonBackColor             EQU 8   ; RGBCOLOR.
@CapButtonBackRollColor         EQU 12  ; RGBCOLOR.
@CapButtonBorderColor           EQU 16  ; RGBCOLOR.
@CapButtonBorderRollColor       EQU 20  ; RGBCOLOR.
@CapButtonIco                   EQU 24  ; hIcon.
@CapButtonIcoAlt                EQU 28  ; hIcon. When mouse moves over capbutton
@CapButtonParam                 EQU 32  ; DWORD. Custom user data
@CapButtonResourceID            EQU 36  ; n/a might be removed in future

; Note setting dialog with WS_CLIPCHILDREN beforehand and using MUI Style (NOT MUICS_WINNOMUISTYLE) will call ApplyStyleToDialog, but other controls will have
; a black background for a millisecond before being painting normally. Unset WS_CLIPCHILDREN in dialog, and let ApplyStyleToDialog change it to prevent this
; black background for a millisecond thing happening.











