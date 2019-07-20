;==============================================================================
;
; ModernUI Control - ModernUI_Animation
;
; Copyright (c) 2019 by fearless
;
; All Rights Reserved
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
; ModernUI_Animation Prototypes
;------------------------------------------------------------------------------
MUIAnimationRegister	    PROTO												    ; Use 'ModernUI_Animation' as class in RadASM custom class control
MUIAnimationCreate		    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hWndParent, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
MUIAnimationSetProperty	    PROTO :DWORD,:DWORD,:DWORD							    ; hModernUI_Animation, dwProperty, dwPropertyValue
MUIAnimationGetProperty	    PROTO :DWORD,:DWORD									    ; hModernUI_Animation, dwProperty

; Add image handle (bitmap, icon or png) as an animation frame image
MUIAnimationAddFrame        PROTO :DWORD,:DWORD,:DWORD						        ; hModernUI_Animation, dwImageType, lpMuiAnimationFrameStruct
MUIAnimationAddFrames       PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_Animation, dwImageType, lpArrayMuiAnimationFrameStructs, dwCount
; Load an image resource id (bitmap, icon or png) as an animation frame image
MUIAnimationLoadFrame       PROTO :DWORD,:DWORD,:DWORD						        ; hModernUI_Animation, dwImageType, lpMuiAnimationFrameStruct
MUIAnimationLoadFrames      PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_Animation, dwImageType, lpArrayMuiAnimationFrameStructs, dwCount
; Create a series of animation frames images from a sprite sheet
MUIAnimationAddSpriteSheet  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hModernUI_Animation, dwImageType, hImageSpriteSheet, dwSpriteCount, lpFrameTimes, dwFrameTimeSize, dwFrameTimeType
MUIAnimationLoadSpriteSheet PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD  ; hModernUI_Animation, dwImageType, idResSpriteSheet, dwSpriteCount, lpFrameTimes, dwFrameTimeSize, dwFrameTimeType
; Insert image handle as an animation frame image
MUIAnimationInsertFrame     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD                ; hModernUI_Animation, dwImageType, lpMuiAnimationFrameStruct, dwFrameIndex, bInsertBefore
MUIAnimationInsertFrames    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD         ; hModernUI_Animation, dwImageType, lpArrayMuiAnimationFrameStructs, dwCount, dwFrameIndex, bInsertBefore

; Frame Operations
MUIAnimationClear           PROTO :DWORD                                            ; hModernUI_Animation
MUIAnimationDeleteFrames    PROTO :DWORD                                            ; hModernUI_Animation
MUIAnimationDeleteFrame     PROTO :DWORD,:DWORD                                     ; hModernUI_Animation, dwFrameIndex
MUIAnimationMoveFrame       PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_Animation, dwFrameIndexFrom, dwFrameIndexTo
MUIAnimationCopyFrame       PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_Animation, dwFrameIndexFrom, dwFrameIndexTo
MUIAnimationCropFrame       PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_Animation, dwFrameIndex, lpRect
MUIAnimationCropFrames      PROTO :DWORD,:DWORD                                     ; hModernUI_Animation, lpRect

; Save frames to file
MUIAnimationExportSpriteSheet PROTO :DWORD,:DWORD,:DWORD                            ; hModernUI_Animation, dwImageType, lpszSpritesheetFilename, lpszFrameTimesFilename
MUIAnimationExportFrame       PROTO :DWORD,:DWORD,:DWORD,:DWORD                     ; hModernUI_Animation, dwImageType, lpszFrameFilename, dwFrameIndex
MUIAnimationExportFrames      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD              ; hModernUI_Animation, dwImageType, lpszFrameFolder, lpszFilePrefix, bFileFrameNo

; Load frames from file
MUIAnimationImportSpriteSheet PROTO :DWORD,:DWORD,:DWORD                            ; hModernUI_Animation, dwImageType, lpszSpritesheetFilename, lpszFrameTimesFilename
MUIAnimationImportFrame       PROTO :DWORD,:DWORD,:DWORD,:DWORD                     ; hModernUI_Animation, dwImageType, lpszFrameFilename, dwFrameIndex

; Frame Information
MUIAnimationGetFrameInfo    PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_Animation, dwFrameIndex, lpMuiAnimationFrameStruct
MUIAnimationGetFrameImage   PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_Animation, dwFrameIndex, lpdwFrameType
MUIAnimationGetFrameTime    PROTO :DWORD,:DWORD                                     ; hModernUI_Animation, dwFrameIndex

MUIAnimationSetFrameInfo    PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_Animation, dwFrameIndex, lpMuiAnimationFrameStruct
MUIAnimationSetFrameImage   PROTO :DWORD,:DWORD,:DWORD,:DWORD                       ; hModernUI_Animation, dwFrameIndex, dwFrameType, hFrameImage
MUIAnimationSetFrameTime    PROTO :DWORD,:DWORD,:DWORD                              ; hModernUI_Animation, dwFrameIndex, dwFrameTime

; Animation control
MUIAnimationStart           PROTO :DWORD                                            ; hModernUI_Animation
MUIAnimationStop            PROTO :DWORD                                            ; hModernUI_Animation
MUIAnimationPause           PROTO :DWORD                                            ; hModernUI_Animation
MUIAnimationResume          PROTO :DWORD                                            ; hModernUI_Animation
MUIAnimationStep            PROTO :DWORD,:DWORD                                     ; hModernUI_Animation, bReverse
MUIAnimationSpeed           PROTO :DWORD,:REAL4                                     ; hModernUI_Animation, fSpeedFactor

MUIAnimationSetDefaultTime  PROTO :DWORD,:DWORD                                     ; hModernUI_Animation, dwDefaultFrameTime

MUIAnimationNotifyCallback  PROTO :DWORD,:DWORD                                     ; hModernUI_Animation, lpNMAnimationStruct


;------------------------------------------------------------------------------
; ModernUI_Animation Messages
;------------------------------------------------------------------------------
MUIAM_ADDFRAME              EQU WM_USER+1752 ; wParam = dwImageType, lParam = lpAnimationFrameStruct
MUIAM_LOADFRAME             EQU WM_USER+1751 ; wParam = dwImageType, lParam = idResImage
MUIAM_START                 EQU WM_USER+1750 ; wParam & lParam = NULL
MUIAM_STOP                  EQU WM_USER+1749 ; wParam & lParam = NULL
MUIAM_STEP                  EQU WM_USER+1748 ; wParam = bReverse
MUIAM_SPEED                 EQU WM_USER+1745 ; wParam = dwSpeedFactor


;------------------------------------------------------------------------------
; ModernUI_Animation Notifications
;------------------------------------------------------------------------------
MUIAN_STOP                  EQU 0   ; Animation is stopped
MUIAN_START                 EQU 1   ; Animation has started
MUIAN_PAUSE                 EQU 2   ; Animation is paused 
MUIAN_RESUME                EQU 3   ; Animation has resumed
MUIAN_STEP                  EQU 4   ; Animation stepping 
MUIAN_FRAME                 EQU 5   ; Occurs every frame shown

;------------------------------------------------------------------------------
; ModernUI_Animation Structures
;------------------------------------------------------------------------------
IFNDEF MUI_ANIMATION_FRAME  ; lpMuiAnimationFrameStruct
MUI_ANIMATION_FRAME         STRUCT
    dwFrameType             DD ?    ; DWORD. Image type: MUIAIT_BMP, MUIAIT_ICO, MUIAIT_PNG
    dwFrameImage            DD ?    ; DWORD/HANDLE. Handle or resource ID of image: Bitmap, Icon or PNG (RT_BITMAP, RT_ICON or RT_RCDATA resource)
    dwFrameTime             DD ?    ; DWORD. Frame time in milliseconds
    lParam                  DD ?    ; DWORD. Custom user specified value
MUI_ANIMATION_FRAME         ENDS
ENDIF

IFNDEF MUI_ANIMATION_FT_FULL ; For array of frame times for every frame in array
MUI_ANIMATION_FT_FULL     STRUCT
    dwFrameTime           DD ?
MUI_ANIMATION_FT_FULL     ENDS
ENDIF

IFNDEF MUI_ANIMATION_FT_COMPACT ; For array of frame times for specified frame indexes in each entry
MUI_ANIMATION_FT_COMPACT  STRUCT
    dwFrameID             DD ?
    dwFrameTime           DD ?
MUI_ANIMATION_FT_COMPACT  ENDS
ENDIF

IFNDEF NM_ANIMATION_FRAME   ; ModernUI_Animation Notification Item
NM_ANIMATION_FRAME          STRUCT
    dwFrameIndex            DD ?    ; DWORD. Frame index
    dwFrameType             DD ?    ; DWORD. Image type: MUIAIT_BMP, MUIAIT_ICO, MUIAIT_PNG
    dwFrameImage            DD ?    ; HANDLE. Handle of image: Bitmap, Icon or PNG
    dwFrameTime             DD ?    ; DWORD. Frame time in milliseconds
    lParam                  DD ?    ; DWORD. Custom user specified value
NM_ANIMATION_FRAME          ENDS
ENDIF

IFNDEF NM_ANIMATION         ; Notification Message Structure for ModernUI_Animation
NM_ANIMATION                STRUCT
    hdr                     NMHDR <>
    item                    NM_ANIMATION_FRAME <>
NM_ANIMATION                ENDS
ENDIF


.CONST
;------------------------------------------------------------------------------
; ModernUI_Animation Constants
;------------------------------------------------------------------------------

; ModernUI_Animation Styles
MUIAS_NOSTRETCH             EQU 0
MUIAS_NOCENTER              EQU 1
MUIAS_CENTER                EQU 2
MUIAS_STRETCH               EQU 3
MUIAS_LCLICK                EQU 4
MUIAS_RCLICK                EQU 8
MUIAS_HAND                  EQU 10h
MUIAS_CONTROL               EQU 20h

;------------------------------------------------------------------------------
; ModernUI_Animation Properties: Use with MUIAnimationSetProperty / 
; MUIAnimationGetProperty or MUI_SETPROPERTY / MUI_GETPROPERTY msgs
;------------------------------------------------------------------------------
@AnimationBackColor         EQU 0   ; RGBCOLOR. Background color of animation
@AnimationBorderColor       EQU 4   ; RGBCOLOR. Border color of animation
@AnimationLoop              EQU 8   ; BOOL. Loop animation back to start. Default is TRUE
@AnimationNotifications     EQU 12  ; BOOL. Allow notifications via WM_NOTIFY. Default is TRUE
@AnimationNotifyCallback    EQU 16  ; DWORD. Address of custom notifications callback function (MUIAnimationNotifyCallback)
@AnimationDllInstance       EQU 20  ; DWORD. Instance of DLL if using control in a DLL
@AnimationParam             EQU 24  ; DWORD. Custom user specified value


; Animation Image Type:
MUIAIT_NONE                 EQU 0
MUIAIT_BMP                  EQU 1
MUIAIT_ICO                  EQU 2
MUIAIT_PNG                  EQU 3

; Animation Frame Type:
MUIAFT_FULL                 EQU 0
MUIAFT_COMPACT              EQU 1








