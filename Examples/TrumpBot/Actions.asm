include bcrypt.inc
includelib bcrypt.lib

include winmm.inc
includelib winmm.lib

PlaySoundClip           PROTO :DWORD
SetRandomPosition       PROTO :DWORD
GenRandomTime           PROTO :DWORD, :DWORD


.CONST
ACTION_VFAST_MIN        EQU 3000        ; 3 seconds
ACTION_VFAST_MAX        EQU 5000        ; 5 seconds
ACTION_FAST_MIN         EQU 5000        ; 5 seconds
ACTION_FAST_MAX         EQU 30000       ; 30 seconds = 1/2 min
ACTION_NORMAL_MIN       EQU 30000       ; 30 seconds
ACTION_NORMAL_MAX       EQU 240000      ; 240 seconds = 4 mins
ACTION_SLOW_MIN         EQU 60000       ; 60 seconds
ACTION_SLOW_MAX         EQU 600000      ; 600 seconds = 10 min


.CODE


;-------------------------------------------------------------------------------------
; PlaySoundClip - Play sound clip
;-------------------------------------------------------------------------------------
PlaySoundClip PROC idResSound:DWORD
    Invoke PlaySound, NULL, NULL, SND_ASYNC
    Invoke PlaySound, idResSound, hInstance, SND_RESOURCE or SND_ASYNC
    ret
PlaySoundClip ENDP


;-------------------------------------------------------------------------------------
; SetRandomPosition - set random position of desktop face
;-------------------------------------------------------------------------------------
SetRandomPosition PROC USES ECX EDX hWin:DWORD
    LOCAL hMonitor:DWORD
    LOCAL lpmi:MONITORINFOEX
    LOCAL workrect:RECT
    LOCAL rect:RECT
    LOCAL nLeft:DWORD
    LOCAL nTop:DWORD
    LOCAL dwRandom:DWORD
 
    Invoke MonitorFromWindow, hWin, MONITOR_DEFAULTTONEAREST
    mov hMonitor, eax

    mov lpmi.cbSize, SIZEOF MONITORINFOEX
    Invoke GetMonitorInfo, hMonitor, Addr lpmi
    
    Invoke CopyRect, Addr workrect, Addr lpmi.rcWork
    
    Invoke GetWindowRect, hWin, Addr rect

    mov dwRandom, 0
    Invoke BCryptGenRandom, NULL, Addr dwRandom, 4, BCRYPT_USE_SYSTEM_PREFERRED_RNG
    mov eax, dwRandom    
    mov ecx, workrect.right
	xor edx, edx
	div ecx
	mov nLeft, edx

    Invoke BCryptGenRandom, NULL, Addr dwRandom, 4, BCRYPT_USE_SYSTEM_PREFERRED_RNG
    mov eax, dwRandom
    mov ecx, workrect.bottom
	xor edx, edx
	div ecx
	mov nTop, edx

	mov eax, nLeft
	add eax, rect.right
	.IF eax > workrect.right
	    mov eax, workrect.right
	    sub eax, rect.right
	    mov nLeft, eax
	.ENDIF

	mov eax, nTop
	add eax, rect.bottom
	.IF eax > workrect.bottom
	    mov eax, workrect.bottom
	    sub eax, rect.bottom
	    mov nTop, eax
	.ENDIF

    Invoke SetWindowPos, hWin, HWND_TOPMOST, nLeft, nTop, 0, 0, SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE or SWP_NOREDRAW	or SWP_HIDEWINDOW	

    ret
SetRandomPosition ENDP



;-------------------------------------------------------------------------------------
; Get random time
;-------------------------------------------------------------------------------------
GenRandomTime PROC USES EBX ECX EDX dwMinTime:DWORD, dwMaxTime:DWORD
    LOCAL dwRandom:DWORD
    mov dwRandom, 0
    Invoke BCryptGenRandom, NULL, Addr dwRandom, 4, BCRYPT_USE_SYSTEM_PREFERRED_RNG ;0x00000002
    mov eax, dwRandom
    
    mov ecx, dwMaxTime
	xor edx, edx
	div ecx
	mov eax, edx

    .IF sdword ptr eax < dwMinTime
        mov eax, dwMinTime
    .ENDIF
    .IF sdword ptr eax > dwMaxTime
        mov eax, dwMaxTime
    .ENDIF
    ret
GenRandomTime ENDP







