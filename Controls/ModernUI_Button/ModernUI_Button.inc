;==============================================================================
;
; ModernUI Control - ModernUI_Button
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
; ModernUI_Button Prototypes
;------------------------------------------------------------------------------
MUIButtonRegister               PROTO                                                                   ; Use 'ModernUI_Button' as class in RadASM custom class control
MUIButtonCreate                 PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszText, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIButtonSetProperty            PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, dwProperty, dwPropertyValue
MUIButtonGetProperty            PROTO :DWORD, :DWORD                                                    ; hModernUI_Button, dwProperty
MUIButtonGetState               PROTO :DWORD                                                            ; hModernUI_Button
MUIButtonSetState               PROTO :DWORD, :DWORD                                                    ; hModernUI_Button, bState

MUIButtonLoadImages             PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD            ; hModernUI_Button, dwImageType, dwResIDImage, dwResIDImageAlt, dwResIDImageSel, dwResIDImageSelAlt, dwResIDImageDisabled
MUIButtonSetImages              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD            ; hModernUI_Button, dwImageType, hImage, hImageAlt, hImageSel, hImageSelAlt, hImageDisabled

MUIButtonNotifySetText          PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, lpszNotifyText, bRedraw
MUIButtonNotifyLoadImage        PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, dwImageType, dwResIDNotifyImage
MUIButtonNotifySetImage         PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, dwImageType, hNotifyImage
MUIButtonNotifySetFont          PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, hFont, bRedraw
MUIButtonNotify                 PROTO :DWORD, :DWORD                                                    ; hModernUI_Button, bNotify

MUIButtonNoteSetText            PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, lpszNoteText, bRedraw
MUIButtonNoteSetFont            PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, hFont, bRedraw

MUIButtonSetAllProperties       PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Button, lpMUI_BUTTON_PROPERTIES structure, SIZEOF MUI_BUTTON_PROPERTIES

MUIButtonSetBackBrush           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD                            ; hModernUI_Button, hBrush, dwBrushOrgX, dwBrushOrgY, dwBrushPos
MUIButtonLoadBackBrush          PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD                            ; hModernUI_Button, idResBitmap, dwBrushOrgX, dwBrushOrgY, dwBrushPos

;------------------------------------------------------------------------------
; ModernUI_Button Structures
;------------------------------------------------------------------------------
IFNDEF MUI_BUTTON_PROPERTIES
MUI_BUTTON_PROPERTIES           STRUCT
    dwTextFont                  DD ?       ; hFont
    dwTextColor                 DD ?       ; Colorref
    dwTextColorAlt              DD ?       ; Colorref
    dwTextColorSel              DD ?       ; Colorref
    dwTextColorSelAlt           DD ?       ; Colorref
    dwTextColorDisabled         DD ?       ; Colorref
    dwBackColor                 DD ?       ; Colorref
    dwBackColorAlt              DD ?       ; Colorref
    dwBackColorSel              DD ?       ; Colorref
    dwBackColorSelAlt           DD ?       ; Colorref
    dwBackColorDisabled         DD ?       ; Colorref
    dwBackColorTo               DD ?       ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorAltTo            DD ?       ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorSelTo            DD ?       ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorSelAltTo         DD ?       ; Colorref, Gradient color to, -1 = not using gradients
    dwBackColorDisabledTo       DD ?       ; Colorref, Gradient color to, -1 = not using gradients
    dwBorderColor               DD ?       ; Colorref
    dwBorderColorAlt            DD ?       ; Colorref
    dwBorderColorSel            DD ?       ; Colorref
    dwBorderColorSelAlt         DD ?       ; Colorref
    dwBorderColorDisabled       DD ?       ; Colorref
    dwBorderStyle               DD ?       ; Button Border Styles
    dwAccentColor               DD ?       ; Colorref
    dwAccentColorAlt            DD ?       ; Colorref
    dwAccentColorSel            DD ?       ; Colorref
    dwAccentColorSelAlt         DD ?       ; Colorref
    dwAccentStyle               DD ?       ; Button Accent Styles
    dwAccentStyleAlt            DD ?       ; Button Accent Styles
    dwAccentStyleSel            DD ?       ; Button Accent Styles
    dwAccentStyleSelAlt         DD ?       ; Button Accent Styles
    dwImageType                 DD ?       ; hImage
    dwImage                     DD ?       ; hImage - Left or center image
    dwImageAlt                  DD ?       ; hImage - Left or center image
    dwImageSel                  DD ?       ; hImage - Left or center image
    dwImageSelAlt               DD ?       ; hImage - Left or center image
    dwImageDisabled             DD ?       ; hImage - Left or center image
    dwRightImage                DD ?       ; hImage - Right side image
    dwRightImageAlt             DD ?       ; hImage - Right side image
    dwRightImageSel             DD ?       ; hImage - Right side image
    dwRightImageSelAlt          DD ?       ; hImage - Right side image
    dwRightImageDisabled        DD ?       ; hImage - Right side image
    dwNotifyTextFont            DD ?       ; hFont
    dwNotifyTextColor           DD ?       ; Colorref
    dwNotifyBackColor           DD ?       ; Colorref
    dwNotifyRound               DD ?       ; Roundrect x,y value
    dwNotifyImageType           DD ?       ; Button Image Types
    dwNotifyImage               DD ?       ; hImage
    dwButtonNoteTextFont        DD ?       ; hFont
    dwButtonNoteTextColor       DD ?       ; Colorref
    dwButtonNoteTextColorDisabled DD ?     ; Colorref
    dwButtonPaddingLeftIndent   DD ?       ; 
    dwButtonPaddingGeneral      DD ?       ; 
    dwButtonPaddingStyle        DD ?       ; 
    dwButtonPaddingTextImage    DD ?       ; 
    dwButtonDllInstance         DD ?
    dwButtonParam               DD ?
MUI_BUTTON_PROPERTIES           ENDS
ENDIF


.CONST
;------------------------------------------------------------------------------
; ModernUI_Button Constants
;------------------------------------------------------------------------------

; ModernUI_Button Messages
MUIBM_GETSTATE                  EQU WM_USER + 1779 ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
MUIBM_SETSTATE                  EQU WM_USER + 1778 ; wParam = TRUE/FALSE, lParam = NULL

MUIBM_NOTIFYSETTEXT             EQU WM_USER + 1777 ; wParam = lpszNotifyText, lParam = Redraw TRUE/FALSE
MUIBM_NOTIFYSETIMAGE            EQU WM_USER + 1776 ; wParam = dwImageType, lParam = Handle of Image
MUIBM_NOTIFYLOADIMAGE           EQU WM_USER + 1775 ; wParam = dwImageType, lParam = ResourceID
MUIBM_NOTIFYSETFONT             EQU WM_USER + 1774 ; wParam = hFont, lParam = TRUE/FALSE to redraw control
MUIBM_NOTIFY                    EQU WM_USER + 1773 ; wParam = TRUE/FALSE to notify or clear notification, lParam = NULL

MUIBM_NOTESETTEXT               EQU WM_USER + 1772 ; wParam = lpszNoteText, lParam = TRUE/FALSE to redraw control
MUIBM_NOTESETFONT               EQU WM_USER + 1771 ; wParam = hFont, lParam = TRUE/FALSE to redraw control




; ModernUI_Button Styles
MUIBS_LEFT                      EQU 1       ; Align text to the left of the button
MUIBS_BOTTOM                    EQU 2       ; Place image at the top, and text below
MUIBS_CENTER                    EQU 4       ; Align text centerally.
MUIBS_AUTOSTATE                 EQU 8       ; Automatically toggle between TRUE/FALSE state when clicked. TRUE = Selected.
MUIBS_PUSHBUTTON                EQU 10h     ; Simulate button movement down slightly when mouse click and movement up again when mouse is released.
MUIBS_HAND                      EQU 20h     ; Show a hand instead of an arrow when mouse moves over button.
MUIBS_KEEPIMAGES                EQU 40h     ; Dont delete image handles when control is destoyed. Essential if image handles are used in multiple controls.
MUIBS_DROPDOWN                  EQU 80h     ; Show dropdown arrow right side of control
MUIBS_NOFOCUSRECT               EQU 100h    ; Dont show focus rect, just use change border to @ButtonBorderColorAlt when setfocus.
MUIBS_THEME                     EQU 8000h   ; Use default windows theme colors and react to WM_THEMECHANGED

;------------------------------------------------------------------------------
; ModernUI_Button Properties: Use with MUIButtonSetProperty / 
; MUIButtonGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@ButtonTextFont                 EQU 0       ; hFont
@ButtonTextColor                EQU 4       ; Colorref
@ButtonTextColorAlt             EQU 8       ; Colorref
@ButtonTextColorSel             EQU 12      ; Colorref
@ButtonTextColorSelAlt          EQU 16      ; Colorref
@ButtonTextColorDisabled        EQU 20      ; Colorref
@ButtonBackColor                EQU 24      ; Colorref, -1 = transparent
@ButtonBackColorAlt             EQU 28      ; Colorref
@ButtonBackColorSel             EQU 32      ; Colorref
@ButtonBackColorSelAlt          EQU 36      ; Colorref
@ButtonBackColorDisabled        EQU 40      ; Colorref
@ButtonBackColorTo              EQU 44      ; Colorref, Gradient color to, -1 = not using gradients
@ButtonBackColorAltTo           EQU 48      ; Colorref, Gradient color to, -1 = not using gradients
@ButtonBackColorSelTo           EQU 52      ; Colorref, Gradient color to, -1 = not using gradients
@ButtonBackColorSelAltTo        EQU 56      ; Colorref, Gradient color to, -1 = not using gradients
@ButtonBackColorDisabledTo      EQU 60      ; Colorref, Gradient color to, -1 = not using gradients
@ButtonBorderColor              EQU 64      ; Colorref, -1 = transparent
@ButtonBorderColorAlt           EQU 68      ; Colorref
@ButtonBorderColorSel           EQU 72      ; Colorref
@ButtonBorderColorSelAlt        EQU 76      ; Colorref
@ButtonBorderColorDisabled      EQU 80      ; Colorref
@ButtonBorderStyle              EQU 84      ; Button Border Styles - Either MUIBBS_NONE, MUIBBS_ALL or a combination of MUIBBS_LEFT, MUIBBS_TOP, MUIBBS_BOTTOM, MUIBBS_RIGHT
@ButtonAccentColor              EQU 88      ; Colorref, -1 = transparent
@ButtonAccentColorAlt           EQU 92      ; Colorref
@ButtonAccentColorSel           EQU 96      ; Colorref
@ButtonAccentColorSelAlt        EQU 100     ; Colorref
@ButtonAccentStyle              EQU 104     ; Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
@ButtonAccentStyleAlt           EQU 108     ; Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
@ButtonAccentStyleSel           EQU 112     ; Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
@ButtonAccentStyleSelAlt        EQU 116     ; Button Accent Styles - Either MUIBAS_NONE, MUIBAS_ALL or a combination of MUIBAS_LEFT, MUIBAS_TOP, MUIBAS_BOTTOM, MUIBAS_RIGHT
@ButtonImageType                EQU 120     ; Button Image Types - One of the following: MUIBIT_NONE, MUIBIT_BMP, MUIBIT_ICO or MUIBIT_PNG
@ButtonImage                    EQU 124     ; hImage
@ButtonImageAlt                 EQU 128     ; hImage
@ButtonImageSel                 EQU 132     ; hImage
@ButtonImageSelAlt              EQU 136     ; hImage
@ButtonImageDisabled            EQU 140     ; hImage
@ButtonRightImage               EQU 144     ; hImage - Right side image
@ButtonRightImageAlt            EQU 148     ; hImage - Right side image
@ButtonRightImageSel            EQU 152     ; hImage - Right side image
@ButtonRightImageSelAlt         EQU 156     ; hImage - Right side image
@ButtonRightImageDisabled       EQU 160     ; hImage - Right side image
@ButtonNotifyTextFont           EQU 164     ; hFont
@ButtonNotifyTextColor          EQU 168     ; Colorref
@ButtonNotifyBackColor          EQU 172     ; Colorref
@ButtonNotifyRound              EQU 176     ; dwPixels - Roundrect x,y value
@ButtonNotifyImageType          EQU 180     ; Button Image Types - One of the following: MUIBIT_NONE, MUIBIT_BMP, MUIBIT_ICO or MUIBIT_PNG
@ButtonNotifyImage              EQU 184     ; hImage
@ButtonNoteTextFont             EQU 188     ; hFont
@ButtonNoteTextColor            EQU 192     ; Colorref
@ButtonNoteTextColorDisabled    EQU 196     ; Colorref
@ButtonPaddingLeftIndent        EQU 200     ; dwPixels - No of pixels to indent images + text (or just text if no images). Defaults to 0 when control is created
@ButtonPaddingGeneral           EQU 204     ; dwPixels - No of pixels of padding to apply based on @ButtonPaddingStyle: Defaults to 4px when control is created.
@ButtonPaddingStyle             EQU 208     ; Button Padding Style - Where to apply @ButtonPaddingGeneral: defaults to MUIBPS_ALL when control is created
@ButtonPaddingTextImage         EQU 212     ; dwPixels - No of pixels between left images and text. Defaults to 8 when control is created
@ButtonDllInstance              EQU 216     ; Set to hInstance of dll before calling MUIButtonLoadImages or MUIButtonNotifyLoadImage if used within a dll
@ButtonParam                    EQU 220     ; Custom user data

; Button Border Styles
MUIBBS_NONE                     EQU 0
MUIBBS_LEFT                     EQU 1
MUIBBS_TOP                      EQU 2
MUIBBS_BOTTOM                   EQU 4
MUIBBS_RIGHT                    EQU 8
MUIBBS_ALL                      EQU MUIBBS_LEFT + MUIBBS_TOP + MUIBBS_BOTTOM + MUIBBS_RIGHT


; Button Accent Styles
MUIBAS_NONE                     EQU 0
MUIBAS_LEFT                     EQU 1
MUIBAS_TOP                      EQU 2
MUIBAS_BOTTOM                   EQU 4
MUIBAS_RIGHT                    EQU 8
MUIBAS_ALL                      EQU MUIBAS_LEFT + MUIBAS_TOP + MUIBAS_BOTTOM + MUIBAS_RIGHT

; Button Image Types
MUIBIT_NONE                     EQU 0
MUIBIT_BMP                      EQU 1
MUIBIT_ICO                      EQU 2
MUIBIT_PNG                      EQU 3

; Button Padding Styles
MUIBPS_NONE                     EQU 0
MUIBPS_LEFT                     EQU 1
MUIBPS_TOP                      EQU 2
MUIBPS_BOTTOM                   EQU 4
MUIBPS_RIGHT                    EQU 8
MUIBPS_ALL                      EQU MUIBPS_LEFT + MUIBPS_TOP + MUIBPS_BOTTOM + MUIBPS_RIGHT

; Button Brush Position:
MUIBBP_RELATIVE                 EQU 0
MUIBBP_ABSOLUTE                 EQU 1


.DATA
; Button All Properties Themes
;                               ; MUI_BUTTON_PROPERTIES
MUI_BUTTON_DEFAULT_THEME        DD 0                                                    ; Font 
                                DD 0333333h, 0333333h, 0333333h, 0333333h, 0CCCCCCh     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0FFFFFFh, 0DDDDDDh, 0FFFFFFh, 0DDDDDDh, 0C0C0C0h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0CCCCCCh, 0CCCCCCh, 0E2A11Bh, 0E2A11Bh, 0CCCCCCh     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_ALL                                           ; BorderStyle
                                DD 0000000h, 0000000h, 0000000h, 0000000h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0333333h, 0FFFFFFh, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0333333h, 0CCCCCCh                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0                                                    ; DllInstance
                                
MUI_BUTTON_LIGHT_THEME          TEXTEQU <MUI_BUTTON_DEFAULT_THEME>

MUI_BUTTON_DARK_THEME           DD 0                                                    ; Font 
                                DD 0333333h, 0333333h, 0333333h, 0333333h, 0CCCCCCh     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0FFFFFFh, 0DDDDDDh, 0FFFFFFh, 0DDDDDDh, 0C0C0C0h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0CCCCCCh, 0CCCCCCh, 0E2A11Bh, 0E2A11Bh, 0CCCCCCh     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_ALL                                           ; BorderStyle
                                DD 0000000h, 0000000h, 0000000h, 0000000h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0333333h, 0FFFFFFh, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0333333h, 0CCCCCCh                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0                                                    ; DllInstance

MUI_CHECKBOX_LIGHT_THEME        DD 0                                                    ; Font 
                                DD 0333333h, 0B97A29h, 0333333h, 0B97A29h, 0333333h     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0F0F0F0h, 0F0F0F0h, 0F0F0F0h, 0F0F0F0h, 0F0F0F0h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0, 0, 0, 0, 0                                        ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_NONE                                          ; BorderStyle
                                DD 0000000h, 0000000h, 0000000h, 0000000h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0000000h, 0000000h, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0000000h, 0000000h                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0                                                    ; DllInstance

MUI_CHECKBOX_DARK_THEME         DD 0                                                    ; Font 
                                DD 0F0F0F0h, 0F0F0F0h, 0F0F0F0h, 0F0F0F0h, 0F0F0F0h     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0333333h, 0333333h, 0333333h, 0333333h, 0333333h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0, 0, 0, 0, 0                                        ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_NONE                                          ; BorderStyle
                                DD 0000000h, 0000000h, 0000000h, 0000000h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0000000h, 0000000h, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0000000h, 0000000h                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0                                                    ; DllInstance

MUI_MENUITEM_LIGHT_THEME        DD 0                                                    ; Font 
                                DD 0333333h, 03D3D3Dh, 0474747h, 0474747h, 0333333h     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0B9B9B9h, 0C3C3C3h, 0FFFFFFh, 0FFFFFFh, 0676767h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0696969h, 0696969h, 0696969h, 0696969h, 0696969h     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_BOTTOM + MUIBBS_TOP                           ; BorderStyle
                                DD 0000000h, 0917947h, 0C19539h, 0C19539h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_LEFT, MUIBAS_LEFT, MUIBAS_LEFT, MUIBAS_LEFT   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0333333h, 0B9B9B9h, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0333333h, 0CCCCCCh                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0   

MUI_MENUITEM_DARK_THEME         DD 0                                                    ; Font 
                                DD 0B9B9B9h, 0C3C3C3h, 0FFFFFFh, 0FFFFFFh, 0676767h     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0333333h, 03D3D3Dh, 0474747h, 0474747h, 0333333h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0696969h, 0696969h, 0696969h, 0696969h, 0696969h     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_BOTTOM + MUIBBS_TOP                           ; BorderStyle
                                DD 0000000h, 0917947h, 0C19539h, 0C19539h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_LEFT, MUIBAS_LEFT, MUIBAS_LEFT, MUIBAS_LEFT   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0B9B9B9h, 0333333h, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0B9B9B9h, 0CCCCCCh                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0                                                    ; DllInstance

MUI_MENUITEM_DARK_THEME_BLANK   DD 0                                                    ; Font 
                                DD 0B9B9B9h, 0B9B9B9h, 0B9B9B9h, 0B9B9B9h, 0676767h     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0333333h, 0333333h, 0333333h, 0333333h, 0333333h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0696969h, 0696969h, 0696969h, 0696969h, 0696969h     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_BOTTOM + MUIBBS_TOP                           ; BorderStyle
                                DD 0000000h, 0000000h, 0000000h, 0000000h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0B9B9B9h, 0333333h, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0B9B9B9h, 0CCCCCCh                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0                                                    ; DllInstance


MUI_MENUITEM_DARK_THEME_2       DD 0                                                    ; Font 
                                DD 0B9B9B9h, 0C3C3C3h, 0FFFFFFh, 0FFFFFFh, 0676767h     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0333333h, 03D3D3Dh, 0474747h, 0474747h, 0333333h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0000000h, 0000000h, 0000000h, 0000000h, 0000000h     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_BOTTOM + MUIBBS_TOP                           ; BorderStyle
                                DD 0000000h, 0917947h, 0C19539h, 0C19539h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_LEFT, MUIBAS_LEFT, MUIBAS_LEFT, MUIBAS_LEFT   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0B9B9B9h, 0333333h, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0B9B9B9h, 0CCCCCCh                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0   

MUI_MENUITEM_DARK_THEME_BLANK_2 DD 0                                                    ; Font 
                                DD 0B9B9B9h, 0B9B9B9h, 0B9B9B9h, 0B9B9B9h, 0676767h     ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0333333h, 0333333h, 0333333h, 0333333h, 0333333h     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
                                DD 0000000h, 0000000h, 0000000h, 0000000h, 0000000h     ; BorderColor, BorderColorAlt, BorderColorSelected, BorderColorSelectedAlt, BorderColorDisabled
                                DD MUIBBS_BOTTOM + MUIBBS_TOP                           ; BorderStyle
                                DD 0000000h, 0000000h, 0000000h, 0000000h               ; AccentColor, AccentColorAlt, AccentColorSel, AccentColorSelAlt
                                DD MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE, MUIBAS_NONE   ; AccentStyle, AccentStyleAlt, AccentStyleSel, AccentStyleSelAlt
                                DD MUIBIT_NONE                                          ; ImageType
                                DD 0, 0, 0, 0, 0                                        ; Image, ImageAlt, ImageSel, ImageSelAlt, ImageDisabled
                                DD 0, 0, 0, 0, 0                                        ; RightImage, RightImageAlt, RightImageSel, RightImageSelAlt, RightImageDisabled
                                DD 0, 0B9B9B9h, 0333333h, 4, MUIBIT_NONE, 0             ; NotifyTextFont, NotifyTextColor, NotifyBackColor, NotifyRound, NotifyImageType, NotifyImage
                                DD 0, 0B9B9B9h, 0CCCCCCh                                ; NoteTextFont, NoteTextColor, NoteTextColorDisabled
                                DD 0, 4, MUIBPS_ALL, 8                                  ; PaddingLeftIndent, PaddingGeneral, PaddingStyle, PaddingTextImage
                                DD 0    


MUI_TEXT_DOS_PROMPT             TEXTEQU <MUI_MENUITEM_DARK_THEME_BLANK_2>


MUI_BUTTON_TEAMSPEAK            DD 0                                                    ; Font 
                                DD 0, 0, 0, 0, 05C5C5Ch                                 ; TextColor, TextColorAlt, TxtColorSelected, TxtColorSelectedAlt, TxtColorDisabled   
                                DD 0FFFFFFh, 0FFFAF5h, 0FFECDCh, 0FDE4D0h, 08C8C8Ch     ; BackColor, BackColorAlt, BackColorSelected, BackColorSelectedAlt, BackColorDisabled
                                DD -1, -1, -1, -1, -1                                   ; BackColorTo, BackColorAltTo, BackColorSelectedTo, BackColorSelectedAltTo, BackColorDisabledTo
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










