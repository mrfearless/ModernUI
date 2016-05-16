;=========================================================================================
;
; LICENSE
;
; LTLI ModernUI Library v1.0.0.0
;
; Copyright (c) 2016 by KSR aka fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
;
; This software is provided 'as-is', without any express or implied warranty. In no
; event will the author be held liable for any damages arising from the use of this
; software.
;
; Permission is granted to anyone to use this software for any non-commercial program.
; If you use the library in an application, an acknowledgement in the application or
; documentation is appreciated but not required. 
;
; You are allowed to make modifications to the source code, but you must leave the
; original copyright notices intact and not misrepresent the origin of the software.
; It is not allowed to claim you wrote the original software. Modified files must have
; a clear notice that the files are modified, and not in the original state. This includes
; the name of the person(s) who modified the code. 
;
; If you want to distribute or redistribute any portion of this package, you will need
; to include the full package in it's original state, including this license and all
; the copyrights. 
;
; While distributing this package (in it's original state) is allowed, it is not allowed
; to charge anything for this. You may not sell or include the package in any commercial
; package without having permission of the author. Neither is it allowed to redistribute
; any of the package's components with commercial applications.
;
;=========================================================================================

;-----------------------------------------------------------------------------------------
; LTLI ModernUI Prototypes
;-----------------------------------------------------------------------------------------

MUIGDIPlusStart                 PROTO                           ; Wrapper for GDIPlus startup - not used for the moment, possibly in future versions
MUIGDIPlusFinish                PROTO                           ; Wrapper for GDIPlus shutdown - not used for the moment, possibly in future versions

MUIGetProperty                  PROTO :DWORD, :DWORD, :DWORD
MUISetProperty                  PROTO :DWORD, :DWORD, :DWORD, :DWORD
MUIAllocMemProperties           PROTO :DWORD, :DWORD, :DWORD
MUIFreeMemProperties            PROTO :DWORD, :DWORD

;-----------------------------------------------------------------------------------------
; LTLI ModernUI Structures
;-----------------------------------------------------------------------------------------


.CONST
;-----------------------------------------------------------------------------------------
; LTLI ModernUI Constants
;-----------------------------------------------------------------------------------------












