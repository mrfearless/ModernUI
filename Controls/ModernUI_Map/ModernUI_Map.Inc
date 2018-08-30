;==============================================================================
;
; ModernUI Control - ModernUI_Map
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
; ModernUI_Map Prototypes
;------------------------------------------------------------------------------
MUIMapRegister          PROTO                                                                   ; Use 'ModernUI_Map' as class in RadASM custom class control
MUIMapCreate            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszText, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIMapSetProperty       PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Map, dwProperty, dwPropertyValue
MUIMapGetProperty       PROTO :DWORD, :DWORD                                                    ; hModernUI_Map, dwProperty
MUIMapLoadImages        PROTO :DWORD, :DWORD, :DWORD, :DWORD                                    ; hModernUI_Map, dwImageType, dwResIDImage, dwResIDImageDisabled
MUIMapSetImages         PROTO :DWORD, :DWORD, :DWORD, :DWORD                                    ; hModernUI_Map, dwImageType, hImage, hImageDisabled

MUIMapButtonGetHandle   PROTO :DWORD, :DWORD                                                    ; hModernUI_Map, dwMapButtonID (map constant). Returns in eax hMapButton
MUIMapButtonGetProperty PROTO :DWORD, :DWORD, :DWORD                                            ; hModernUI_Map, dwMapButtonID, dwProperty
MUIMapButtonSetProperty PROTO :DWORD, :DWORD, :DWORD, :DWORD                                    ; hModernUI_Map, dwMapButtonID, dwProperty, dwPropertyValue


;------------------------------------------------------------------------------
; ModernUI_Map Structures
;------------------------------------------------------------------------------

IFNDEF MUI_MAP_PROPERTIES
MUI_MAP_PROPERTIES                 STRUCT
    dwMapTextColor                 DD ?
    dwMapTextFont                  DD ?
    dwMapBackColor                 DD ?
    dwMapBackColorDisabled         DD ?
    dwMapBorderColor               DD ?
    dwMapBorderColorDisabled       DD ?
    dwMapBackImageType             DD ?
    dwMapBackImage                 DD ?
    dwMapBackImageDisabled         DD ? 
    dwMapButtonBackColor           DD ? 
    dwMapButtonBackColorAlt        DD ? 
    dwMapButtonBackColorSel        DD ? 
    dwMapButtonBackColorSelAlt     DD ? 
    dwMapButtonBackColorDisabled   DD ?
    dwMapButtonBorderColor         DD ? 
    dwMapButtonBorderColorAlt      DD ? 
    dwMapButtonBorderColorSel      DD ? 
    dwMapButtonBorderColorSelAlt   DD ? 
    dwMapButtonBorderColorDisabled DD ? 
    dwMapButtonBorderStyle         DD ?
    dwMapButtonUserData            DD ? 
MUI_MAP_PROPERTIES                 ENDS
ENDIF

IFNDEF MUIM_ITEM                   ; Map Item for use with MUIM_NOTIFY and WM_NOTIFY
MUIM_ITEM                          STRUCT
    idMapButton                    DD 0
    hMapButton                     DD 0
    lParam                         DD 0    
MUIM_ITEM                          ENDS
ENDIF

IFNDEF MUIM_NOTIFY                 ; Noticiation Message Structure for Map
MUIM_NOTIFY                        STRUCT
    hdr                            NMHDR <>
    mapitem                        MUIM_ITEM <0,0,0>
MUIM_NOTIFY                        ENDS
ENDIF



.CONST
;------------------------------------------------------------------------------
; ModernUI_Map Constants
;------------------------------------------------------------------------------

; ModernUI_Map Notify Codes:
MUIMN_CLICKED                     EQU 1
MUIMN_MOUSEOVER                   EQU 2
MUIMN_MOUSELEAVE                  EQU 3
MUIMN_SELECTED                    EQU 4
MUIMN_UNSELECTED                  EQU 5
MUIMN_ENABLED                     EQU 6
MUIMN_DISABLED                    EQU 7

; ModernUI_Map Styles:
MUIMS_WORLD             EQU 0 ; world countries
MUIMS_EUROPE            EQU 1 ; european countries (including grouped uk (scotland, wales, england and northen ireland))
MUIMS_USA               EQU 2 ; usa states
MUIMS_BRITISHISLES      EQU 3 ; grouped uk and ireland
MUIMS_UK_IND            EQU 4 ; individual scotland, wales, england and northen ireland
MUIMS_UK_IRELAND_IND    EQU 5 ; individual scotland, wales, england, northen ireland and ireland

MUIMS_KEEPIMAGES        EQU 10h

; ModernUI_MapButton Countries (British Isles/UK):
MUIMB_IRELAND           EQU 0
MUIMB_SCOTLAND          EQU 1
MUIMB_ENGLAND           EQU 2
MUIMB_WALES             EQU 3
MUIMB_NORTHERN_IRELAND  EQU 4
MUIMB_UNITED_KINGDOM    EQU 5

; ModernUI_MapButton Countries (Europe):
MUIMB_IRELAND           EQU 0
MUIMB_UNITED_KINGDOM    EQU 5
MUIMB_FRANCE            EQU 6
MUIMB_GERMANY           EQU 7
MUIMB_SPAIN             EQU 8
MUIMB_PORTUGAL          EQU 9
MUIMB_ITALY             EQU 10
MUIMB_BELGIUM           EQU 11
MUIMB_LUXEMBURG         EQU 12
MUIMB_SWITZERLAND       EQU 13
MUIMB_NETHERLANDS       EQU 14
MUIMB_NORWAY            EQU 15
MUIMB_SWEDEN            EQU 16
MUIMB_FINLAND           EQU 17
MUIMB_DENMARK           EQU 18
MUIMB_POLAND            EQU 19
MUIMB_ESTONIA           EQU 20
MUIMB_LATVIA            EQU 21
MUIMB_LITHUANIA         EQU 22
MUIMB_SLOVENIA          EQU 23
MUIMB_SLOVAKIA          EQU 24
MUIMB_CZECH_REPUBLIC    EQU 25
MUIMB_MONTENEGRO        EQU 26
MUIMB_ALBANIA           EQU 27
MUIMB_HUNGARY           EQU 28
MUIMB_BULGARIA          EQU 29
MUIMB_CROATIA           EQU 30
MUIMB_KOSOVO            EQU 31
MUIMB_SERBIA            EQU 32
MUIMB_BOSNIA_HERZ       EQU 33
MUIMB_MACEDONIA         EQU 34
MUIMB_ROMANIA           EQU 35
MUIMB_MOLDOVIA          EQU 36
MUIMB_GREECE            EQU 37
MUIMB_UKRAINE           EQU 38
MUIMB_BELARUS           EQU 39
MUIMB_TURKEY            EQU 40
MUIMB_GEORGIA           EQU 41
MUIMB_ARMENIA           EQU 42
MUIMB_AZERBAIJAN        EQU 43
MUIMB_RUSSIA            EQU 44

; ModernUI_MapButton Countries (World):

MUIMB_GREENLAND         EQU 45

; North America
MUIMB_NORTH_AMERICA     EQU 46
MUIMB_CANADA            EQU 47
MUIMB_MEXICO            EQU 48
MUIMB_BELIZE            EQU 49
MUIMB_GUATEMALA         EQU 50
MUIMB_EL_SALVADOR       EQU 51
MUIMB_HONDURAS          EQU 52
MUIMB_NICARAGUA         EQU 53
MUIMB_COSTARICA         EQU 54
MUIMB_PANAMA            EQU 55

; South America
MUIMB_COLOMBIA          EQU 56
MUIMB_VENEZUELA         EQU 57
MUIMB_GUYANA            EQU 58
MUIMB_SURINAME          EQU 59
MUIMB_FRENCH_GUIANA     EQU 60
MUIMB_ECUADOR           EQU 61
MUIMB_PERU              EQU 62
MUIMB_BRAZIL            EQU 63
MUIMB_BOLIVIA           EQU 64
MUIMB_PARAGUAY          EQU 65
MUIMB_CHILE             EQU 66
MUIMB_ARGENTINA         EQU 67
MUIMB_URUGUAY           EQU 68

; African
MUIMB_MOROCCO           EQU 69
MUIMB_ALGERIA           EQU 70
MUIMB_TUNISIA           EQU 71
MUIMB_LIBYA             EQU 72
MUIMB_EGYPT             EQU 73
MUIMB_WESTERN_SAHARA    EQU 74
MUIMB_MAURITANIA        EQU 75
MUIMB_MALI              EQU 76
MUIMB_NIGER             EQU 77
MUIMB_CHAD              EQU 78
MUIMB_SUDAN             EQU 79
MUIMB_ERITREA           EQU 80
MUIMB_DJIBOUTI          EQU 81
MUIMB_ETHIOPIA          EQU 82
MUIMB_SOMALIA           EQU 83
MUIMB_KENYA             EQU 84
MUIMB_UGANDA            EQU 85
MUIMB_SENEGAL           EQU 86
MUIMB_GAMBIA            EQU 87
MUIMB_GUINEA_BISSAU     EQU 88
MUIMB_GUINEA            EQU 89
MUIMB_SIERRA_LEONS      EQU 90   
MUIMB_LIBERIA           EQU 91
MUIMB_COTE_DIVOIRE      EQU 92
MUIMB_GHANA             EQU 93
MUIMB_TOGO              EQU 94
MUIMB_BENIN             EQU 95
MUIMB_NIGERIA           EQU 96
MUIMB_CAMEROON          EQU 97
MUIMB_EQUATORIAL_GUINEA EQU 98
MUIMB_GABON             EQU 99
MUIMB_CONGO             EQU 100
MUIMB_DC_CONGO          EQU 101
MUIMB_RWANDA            EQU 102
MUIMB_BURUNDI           EQU 103
MUIMB_TARZANIA          EQU 104
MUIMB_ANGOLA            EQU 105
MUIMB_ZAMBIA            EQU 106
MUIMB_MALAWI            EQU 107
MUIMB_MOZAMBIQUE        EQU 108
MUIMB_NAMIBIA           EQU 109
MUIMB_ZIMBABWE          EQU 110
MUIMB_BOTSWANA          EQU 111
MUIMB_SOUTH_AFRICA      EQU 112
MUIMB_SWAZILAND         EQU 113
MUIMB_LESOTHO           EQU 114
MUIMB_MADAGASCAR        EQU 115
MUIMB_BURKINA_FASO      EQU 116
MUIMB_CENTRAL_AFRICA    EQU 117 

; Middle East & Asia
MUIMB_ARMENIA           EQU 42
MUIMB_SYRIA             EQU 119
MUIMB_LEBANNON          EQU 120
MUIMB_ISRAEL            EQU 121
MUIMB_JORDAN            EQU 122
MUIMB_IRAQ              EQU 123
MUIMB_KUWAIT            EQU 124
MUIMB_UAE               EQU 125  
MUIMB_SAUDIA_ARABIA     EQU 126
MUIMB_YEMEN             EQU 127
MUIMB_OMAN              EQU 128
MUIMB_BAHRAIN           EQU 129
MUIMB_QATAR             EQU 130
MUIMB_IRAN              EQU 131
MUIMB_TERKMENISTAN      EQU 132
MUIMB_UZBEKISTAN        EQU 133
MUIMB_KYRGYZSTAN        EQU 134
MUIMB_TAJIKISTAN        EQU 135
MUIMB_AFGHANISTAN       EQU 136
MUIMB_PAKISTAN          EQU 137
MUIMB_INDIA             EQU 138
MUIMB_NEPAL             EQU 139
MUIMB_BHUTAN            EQU 140
MUIMB_BANGLADESH        EQU 141
MUIMB_BURMA             EQU 142
MUIMB_THAILAND          EQU 143
MUIMB_LAOS              EQU 144
MUIMB_CAMBODIA          EQU 145
MUIMB_VIETNAM           EQU 146
MUIMB_CHINA             EQU 147
MUIMB_SOUTH_KOREA       EQU 148
MUIMB_NORTH_KOREA       EQU 149
MUIMB_MONGOLIA          EQU 150
MUIMB_SRILANKA          EQU 151

MUIMB_AUSTRALIA         EQU 152
MUIMB_MALAYSIA          EQU 153
MUIMB_SINGAPORE         EQU 154
MUIMB_BRUNEI            EQU 155
MUIMB_INDONESIA         EQU 156
MUIMB_EAST_TIMOR        EQU 157
MUIMB_PAPUA_NEW_GUINEA  EQU 158
MUIMB_SOLOMON_ISLAND    EQU 159
MUIMB_PHILIPPINES       EQU 160
MUIMB_TIAWAN            EQU 161
MUIMB_JAPAN             EQU 162
MUIMB_NEW_ZEALAND       EQU 163
MUIMB_CUBA              EQU 164
MUIMB_THE_BAHAMAS       EQU 165
MUIMB_JAMAICA           EQU 166
MUIMB_HATI              EQU 167
MUIMB_DOMINICAN_REPUBLIC EQU 168    
MUIMB_PUERTO_RICO       EQU 169
MUIMB_MAX               EQU 170


; Map Image Types
MUIMIT_NONE                     EQU 0
MUIMIT_BMP                      EQU 1
MUIMIT_ICO                      EQU 2
MUIMIT_PNG                      EQU 3


;------------------------------------------------------------------------------
; ModernUI_Map Properties: Use with MUIMapSetProperty / MUIMapGetProperty or 
; MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@MapTextColor                   EQU 0   ; Text color for map control title text
@MapTextFont                    EQU 4   ; Font for map control title text
@MapBackColor                   EQU 8   ; Background color of map control
@MapBackColorDisabled           EQU 12  ; Background color of map control when disabled
@MapBorderColor                 EQU 16  ; Border color of map control
@MapBorderColorDisabled         EQU 20  ; Border color of map control when disabled
@MapBackImageType               EQU 24  ; Map Image Types - One of the following: MUIMIT_NONE, MUIMIT_BMP, MUIMIT_ICO or MUIMIT_PNG
@MapBackImage                   EQU 28  ; hImage
@MapBackImageDisabled           EQU 32  ; hImage
@MapButtonBackColor             EQU 36  ; Colorref. Back color.
@MapButtonBackColorAlt          EQU 40  ; Colorref. Back color when mouse hovers over control.
@MapButtonBackColorSel          EQU 44  ; Colorref. Back color when selected state = TRUE.
@MapButtonBackColorSelAlt       EQU 48  ; Colorref. Back color when selected state = TRUE and mouse hovers over control.
@MapButtonBackColorDisabled     EQU 52  ; Colorref. Back color when control is disabled.
@MapButtonBorderColor           EQU 56  ; Colorref. Border color.
@MapButtonBorderColorAlt        EQU 60  ; Colorref. Border color when mouse hovers over control.
@MapButtonBorderColorSel        EQU 64  ; Colorref. Border color when selected state = TRUE.
@MapButtonBorderColorSelAlt     EQU 68  ; Colorref. Border color when selected state = TRUE and mouse hovers over control.
@MapButtonBorderColorDisabled   EQU 72  ; Colorref. Border color when control is disabled.
@MapButtonBorderSize            EQU 76  ; MapButton Border size, 0 = disabled/no border (default)
@MapButtonUserData              EQU 80  ; User defined dword data









