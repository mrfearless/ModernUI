;==============================================================================
;
; ModernUI Library
;
; Copyright (c) 2019 by fearless
;
; All Rights Reserved
;
; http://github.com/mrfearless/ModernUI
;
;==============================================================================
.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib

include ModernUI.inc

IFDEF MUI_USEGDIPLUS
include gdiplus.inc
include ole32.inc
includelib gdiplus.lib
includelib ole32.lib

IFNDEF UNKNOWN
UNKNOWN                         STRUCT
   QueryInterface               DD ?
   AddRef                       DD ?
   Release                      DD ?
UNKNOWN                         ENDS
ENDIF

IFNDEF IStream
IStream                         STRUCT
    IUnknown                    UNKNOWN <>
    Read                        DD ?
    Write                       DD ?
    Seek                        DD ?
    SetSize                     DD ?
    CopyTo                      DD ?
    Commit                      DD ?
    Revert                      DD ?
    LockRegion                  DD ?
    UnlockRegion                DD ?
    Stat                        DD ?
    Clone                       DD ?
IStream                         ENDS
ENDIF


.CODE


MUI_ALIGN
;------------------------------------------------------------------------------
; Load JPG/PNG from resource using GDI+
;   Actually, this function can load any image format supported by GDI+
;
; by: Chris Vega
;
; Addendum KSR 2014 : Needs OLE32 include and lib for CreateStreamOnHGlobal and 
; GetHGlobalFromStream calls. Underlying stream needs to be left open for the life of
; the bitmap or corruption of png occurs. store png as RCDATA in resource file.
;
; Loads specified JPG/PNG resource into the specified external property and returns 
; old GDI+ image handle (if it previously existed) in eax or NULL. 
; If dwInstanceProperty != -1 fetches stored value to use as hinstance to load JPG/PNG
; resource. If dwProperty == -1, no property to set, so eax will contain hImage or NULL
;
; To load a JPG/PNG resource and simply return its handle, use -1 in property.
;
; NOTE: NOT WORKING 21/6/2019 
;-------------------------------------------------------------------------------------
MUILoadPngFromResource PROC hWin:MUIWND, InstanceProperty:MUIPROPERTY, Property:MUIPROPERTY, idResPng:RESID
    local rcRes:HRSRC
    local hResData:HRSRC
    local pResData:HANDLE
    local sizeOfRes:DWORD
    local hResBuffer:HANDLE
    local pResBuffer:DWORD
    local pIStream:DWORD
    local hIStream:DWORD
    LOCAL hinstance:DWORD
    LOCAL pImage:DWORD
    LOCAL pImageOld:DWORD
    LOCAL pBitmapFromStream:DWORD
    LOCAL pGraphics:DWORD
    LOCAL dwImageWidth:DWORD
    LOCAL dwImageHeight:DWORD

    .IF (hWin == NULL && InstanceProperty != -1) || idResPng == NULL
        mov eax, NULL
        ret
    .ENDIF

    .IF InstanceProperty != -1
        Invoke MUIGetExtProperty, hWin, InstanceProperty
        .IF eax == 0
            Invoke GetModuleHandle, NULL
        .ENDIF
    .ELSE
        Invoke GetModuleHandle, NULL
    .ENDIF
    mov hinstance, eax

    .IF Property != -1
        Invoke MUIGetExtProperty, hWin, Property
        .IF eax != 0
            mov pImageOld, eax
        .ELSE
            mov pImageOld, NULL
        .ENDIF
    .ENDIF

    ; ------------------------------------------------------------------
    ; STEP 1: Find the resource
    ; ------------------------------------------------------------------
    invoke  FindResource, hinstance, idResPng, RT_RCDATA
    or      eax, eax
    jnz     @f
    jmp     _MUILoadPngFromResource@Close
@@: mov     rcRes, eax
    
    ; ------------------------------------------------------------------
    ; STEP 2: Load the resource
    ; ------------------------------------------------------------------
    invoke  LoadResource, hinstance, rcRes
    or      eax, eax
    jnz     @f
    ret     ; Resource was not loaded
@@: mov     hResData, eax

    ; ------------------------------------------------------------------
    ; STEP 3: Create a stream to contain our loaded resource
    ; ------------------------------------------------------------------
    invoke  SizeofResource, hinstance, rcRes
    or      eax, eax
    jnz     @f
    jmp     _MUILoadPngFromResource@Close
@@: mov     sizeOfRes, eax
    
    invoke  LockResource, hResData
    or      eax, eax
    jnz     @f
    jmp     _MUILoadPngFromResource@Close
@@: mov     pResData, eax

    invoke  GlobalAlloc, GMEM_MOVEABLE, sizeOfRes
    or      eax, eax
    jnz     @f
    jmp     _MUILoadPngFromResource@Close
@@: mov     hResBuffer, eax

    invoke  GlobalLock, hResBuffer
    mov     pResBuffer, eax
    
    invoke  RtlMoveMemory, pResBuffer, hResData, sizeOfRes
    invoke  CreateStreamOnHGlobal, pResBuffer, TRUE, addr pIStream
    or      eax, eax
    jz      @f
    jmp     _MUILoadPngFromResource@Close
@@: 

    ; ------------------------------------------------------------------
    ; STEP 4: Create an image object from stream
    ; ------------------------------------------------------------------
    invoke  GdipCreateBitmapFromStream, pIStream, Addr pBitmapFromStream
    invoke  GetHGlobalFromStream, pIStream, addr hIStream

    ; ------------------------------------------------------------------
    ; STEP 5: Copy stream bitmap image to new ARGB 32bpp bitmap image
    ; ------------------------------------------------------------------
    Invoke GdipGetImageWidth, pBitmapFromStream, Addr dwImageWidth
    Invoke GdipGetImageHeight, pBitmapFromStream, Addr dwImageHeight    
    Invoke GdipCreateBitmapFromScan0, dwImageWidth, dwImageHeight, 0, PixelFormat32bppARGB, 0, Addr pImage
    Invoke GdipGetImageGraphicsContext, pImage, Addr pGraphics
    Invoke GdipDrawImage, pGraphics, pBitmapFromStream, 0, 0

    ; ------------------------------------------------------------------
    ; STEP 6: Free all used locks and resources
    ; ------------------------------------------------------------------
    Invoke GdipDeleteGraphics, pGraphics
    .IF hIStream != 0
        mov eax, hIStream
        push eax
        mov eax, DWORD PTR [eax]
        call IStream.IUnknown.Release[eax] ; release the stream
        mov hIStream, 0
    .ENDIF
    Invoke GlobalUnlock, hResBuffer
    Invoke GlobalFree, hResBuffer

    ; ------------------------------------------------------------------
    ; STEP 7: Set property if required, and return pImage or pImageOld
    ; ------------------------------------------------------------------
    .IF Property != -1
        Invoke MUISetExtProperty, hWin, Property, pImage
        mov eax, pImageOld
    .ELSE
        mov eax, pImage
    .ENDIF

_MUILoadPngFromResource@Close:
    ret
MUILoadPngFromResource ENDP


ENDIF


MODERNUI_LIBEND


;
;pBitmapNew := Gdip_CreateBitmap(w,h)
;pGraphicsNew := Gdip_GraphicsFromImage(pBitmapNew)
;Gdip_DrawImage(pGraphicsNew, pBitmap, 0, 0, w,h, 0, 0, w, hi)
;
;Gdip_SaveBitmapToFile(pBitmapNew, outfile)
;Gdip_DeleteGraphics(GNew)