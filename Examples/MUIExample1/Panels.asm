Panel1Proc                      PROTO :DWORD, :DWORD, :DWORD, :DWORD
Panel2Proc                      PROTO :DWORD, :DWORD, :DWORD, :DWORD
Panel3Proc                      PROTO :DWORD, :DWORD, :DWORD, :DWORD
Panel4Proc                      PROTO :DWORD, :DWORD, :DWORD, :DWORD



.CONST
; Panel1
IDD_Panel1                      EQU 2500
IDC_TEXTCONFIRMCANCEL           EQU 2501
IDC_BTNCONFIRMYES               EQU 2502
IDC_BTNCONFIRMNO                EQU 2503

; Panel2
IDD_Panel2                      EQU 2600
IDC_TEXTINSTALLING              EQU 2601
IDC_BTNCANCEL                   EQU 2602
IDC_MUIPD                       EQU 2603

; Panel3
IDD_Panel3                      EQU 2700
IDC_TEXTCHOOSE                  EQU 2701
IDC_BTNCHOOSENEXT               EQU 2702
IDC_BTNCHOOSECANCEL             EQU 2703

; Panel4
IDD_Panel4                      EQU 2800
IDC_TEXTFINISHED                EQU 2801
IDC_BTNFINISH                   EQU 2802

.DATA

; Panel1
szConfirmCancel                 DB "Are you sure you want to cancel setup?",0
szConfirmYes                    DB "Yes",0
szConfirmNo                     DB "No",0

; Panel2
szBtnCancelText                 DB "Cancel",0
szInstalling                    DB "Preparing installation environment, please wait...",0

; Panel3
szChooseComponents              DB "Choose components to install.",0
szChooseNext                    DB "Next",0
szChooseCancel                  DB "Cancel",0

; Panel4
szFinished                      DB "Installation of Radasm Studio is now completed.",0
szBtnFinishText                 DB "Finish",0

; Stage flag
dwInstallStage                  DD 0


.DATA?
; Panel1
hPanel1                         DD ?
hMUITextConfirmCancel           DD ?
hMUIBtnConfirmYes               DD ?
hMUIBtnConfirmNo                DD ?

; Panel2
hPanel2                         DD ?
hMUITextInstalling              DD ?
hMUIBtnCancel                   DD ?
hMUIPD                          DD ?

; Panel3
hPanel3                         DD ?
hMUITextChoose                  DD ?
hMUIBtnChooseNext               DD ?
hMUIBtnChooseCancel             DD ?

; Panel4
hPanel4                         DD ?
hMUITextFinished                DD ?
hMUIBtnFinish                   DD ?

.CODE


;------------------------------------------------------------------------------
; Download Dialog - Panel1 - Confirm cancel setup dialog
;------------------------------------------------------------------------------
Panel1Proc PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    LOCAL wNotifyCode:DWORD
    
    mov eax, uMsg
    .IF eax==WM_INITDIALOG

        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button: Yes & No
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szConfirmYes, 245, 500, 90, 28, IDC_BTNCONFIRMYES, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hMUIBtnConfirmYes, eax        
        Invoke MUIButtonSetProperty, hMUIBtnConfirmYes, @ButtonTextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmYes, @ButtonTextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmYes, @ButtonBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmYes, @ButtonBackColorAlt, MUI_RGBCOLOR(66,66,68)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmYes, @ButtonBorderStyle, MUIBBS_ALL
        Invoke MUIButtonSetProperty, hMUIBtnConfirmYes, @ButtonBorderColor, MUI_RGBCOLOR(103,103,106)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmYes, @ButtonBorderColorAlt, MUI_RGBCOLOR(56,163,254)

        Invoke MUIButtonCreate, hWin, Addr szConfirmNo, 350, 500, 90, 28, IDC_BTNCONFIRMNO, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hMUIBtnConfirmNo, eax        
        Invoke MUIButtonSetProperty, hMUIBtnConfirmNo, @ButtonTextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmNo, @ButtonTextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmNo, @ButtonBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmNo, @ButtonBackColorAlt, MUI_RGBCOLOR(66,66,68)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmNo, @ButtonBorderStyle, MUIBBS_ALL
        Invoke MUIButtonSetProperty, hMUIBtnConfirmNo, @ButtonBorderColor, MUI_RGBCOLOR(103,103,106)
        Invoke MUIButtonSetProperty, hMUIBtnConfirmNo, @ButtonBorderColorAlt, MUI_RGBCOLOR(56,163,254)


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Text: Confirm Cancellation of installer
        ;-----------------------------------------------------------------------------------------------------        
        Invoke MUITextCreate, hWin, Addr szConfirmCancel, 3, 250, 450, 80, IDC_TEXTCONFIRMCANCEL, MUITS_11PT or MUITS_FONT_BOLD or MUITS_ALIGN_CENTER or MUITS_FONT_SEGOE 
        mov hMUITextConfirmCancel, eax
        Invoke MUITextSetProperty, hMUITextConfirmCancel, @TextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextConfirmCancel, @TextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextConfirmCancel, @TextBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUITextSetProperty, hMUITextConfirmCancel, @TextBackColorAlt, MUI_RGBCOLOR(45,45,48)



    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        shr eax, 16
        mov wNotifyCode, eax
        mov eax,wParam
        and eax,0FFFFh
        
        .IF eax == IDC_BTNCONFIRMYES
            Invoke SendMessage, hWnd, WM_CLOSE, 0, 0
        
        .ELSEIF eax == IDC_BTNCONFIRMNO

            mov eax, dwInstallStage
            .IF eax == 0 ; before prep has finished
                Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 1, FALSE ; 2nd dialog - prep install
                Invoke MUIProgressDotsAnimateStart, hMUIPD
                .IF hPreThread != NULL
                    Invoke ResumeThread, hPreThread
                .ENDIF
                .IF dwInstallStage == 1
                    Invoke MUIProgressDotsAnimateStop, hMUIPD
                    Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 2, FALSE ; 3rd dialog - choose components
                .ENDIF       
            
            .ELSEIF eax == 1 ; after prep has finished
                Invoke MUIProgressDotsAnimateStop, hMUIPD
                Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 2, FALSE ; 3rd dialog - choose components


            .ENDIF

        .ENDIF


    ;-----------------------------------------------------------------------------------------------------
    ; ModernUI - Color background and border
    ;-----------------------------------------------------------------------------------------------------
;    .ELSEIF eax == WM_ERASEBKGND
;        mov eax, 1
;        ret
;
;    .ELSEIF eax == WM_PAINT
;        invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(45,45,48), 0
;        mov eax, 0
;        ret
    ;-----------------------------------------------------------------------------------------------------

    .ELSEIF eax==WM_CLOSE
        invoke DestroyWindow, hWin
    .ELSE
        mov eax,FALSE
        ret
    .ENDIF
    mov  eax,TRUE
    ret

Panel1Proc ENDP


;------------------------------------------------------------------------------
; Download Dialog - Panel2 - Prepare installation dialog
;------------------------------------------------------------------------------
Panel2Proc PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    LOCAL wNotifyCode:DWORD
    
    mov eax, uMsg
    .IF eax==WM_INITDIALOG
    
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button: Cancel
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szBtnCancelText, 350, 500, 90, 28, IDC_BTNCANCEL, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hMUIBtnCancel, eax        
        Invoke MUIButtonSetProperty, hMUIBtnCancel, @ButtonTextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnCancel, @ButtonTextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnCancel, @ButtonBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIButtonSetProperty, hMUIBtnCancel, @ButtonBackColorAlt, MUI_RGBCOLOR(66,66,68)
        Invoke MUIButtonSetProperty, hMUIBtnCancel, @ButtonBorderStyle, MUIBBS_ALL
        Invoke MUIButtonSetProperty, hMUIBtnCancel, @ButtonBorderColor, MUI_RGBCOLOR(103,103,106)
        Invoke MUIButtonSetProperty, hMUIBtnCancel, @ButtonBorderColorAlt, MUI_RGBCOLOR(56,163,254)


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Text: Installing...
        ;-----------------------------------------------------------------------------------------------------        
        Invoke MUITextCreate, hWin, Addr szInstalling, 15, 20, 379, 80, IDC_TEXTINSTALLING, MUITS_10PT or MUITS_FONT_SEGOE
        mov hMUITextInstalling, eax
        Invoke MUITextSetProperty, hMUITextInstalling, @TextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextInstalling, @TextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextInstalling, @TextBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUITextSetProperty, hMUITextInstalling, @TextBackColorAlt, MUI_RGBCOLOR(45,45,48)


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_ProgressDot    . . . . . 
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIProgressDotsCreate, hWin, 250, 3, IDC_MUIPD, 0
        mov hMUIPD, eax
        Invoke MUIProgressDotsSetProperty, hMUIPD, @ProgressDotsBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIProgressDotsAnimateStart, hMUIPD

        ;-----------------------------------------------------------------------------------------------------
        ; If this was a real installation program it might do the following
        ; Launch Thread to do the installation preperation
        ; Once thread has finished maybe do something like this:
        ; Invoke MUIProgressDotsAnimateStop, hMUIPD ; stop dots
        ; Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 2, FALSE ; move to dialog 3
        
        Invoke PreInstallation


    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        shr eax, 16
        mov wNotifyCode, eax
        mov eax,wParam
        and eax,0FFFFh

        .IF eax == IDC_BTNCANCEL
            .IF hPreThread != NULL
                Invoke SuspendThread, hPreThread
            .ENDIF
            Invoke MUIProgressDotsAnimateStop, hMUIPD
            Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 0, FALSE ; 1st dialog
        .ENDIF

    ;-----------------------------------------------------------------------------------------------------
    ; ModernUI - Color background and border
    ;-----------------------------------------------------------------------------------------------------
;    .ELSEIF eax == WM_ERASEBKGND
;        mov eax, 1
;        ret
;
;    .ELSEIF eax == WM_PAINT
;        invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(45,45,48), 0
;        mov eax, 0
;        ret
    ;-----------------------------------------------------------------------------------------------------

    .ELSEIF eax==WM_CLOSE
        invoke DestroyWindow, hWin
    .ELSE
        mov eax,FALSE
        ret
    .ENDIF
    mov  eax,TRUE
    ret

Panel2Proc ENDP


;------------------------------------------------------------------------------
; Download Dialog - Panel3 - Choose installation components?
;------------------------------------------------------------------------------
Panel3Proc PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    LOCAL wNotifyCode:DWORD
    
    mov eax, uMsg
    .IF eax==WM_INITDIALOG

        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button: Next & Cancel
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szChooseNext, 245, 500, 90, 28, IDC_BTNCHOOSENEXT, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hMUIBtnChooseNext, eax        
        Invoke MUIButtonSetProperty, hMUIBtnChooseNext, @ButtonTextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnChooseNext, @ButtonTextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnChooseNext, @ButtonBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIButtonSetProperty, hMUIBtnChooseNext, @ButtonBackColorAlt, MUI_RGBCOLOR(66,66,68)
        Invoke MUIButtonSetProperty, hMUIBtnChooseNext, @ButtonBorderStyle, MUIBBS_ALL
        Invoke MUIButtonSetProperty, hMUIBtnChooseNext, @ButtonBorderColor, MUI_RGBCOLOR(103,103,106)
        Invoke MUIButtonSetProperty, hMUIBtnChooseNext, @ButtonBorderColorAlt, MUI_RGBCOLOR(56,163,254)

        Invoke MUIButtonCreate, hWin, Addr szChooseCancel, 350, 500, 90, 28, IDC_BTNCHOOSECANCEL, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hMUIBtnChooseCancel, eax        
        Invoke MUIButtonSetProperty, hMUIBtnChooseCancel, @ButtonTextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnChooseCancel, @ButtonTextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnChooseCancel, @ButtonBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIButtonSetProperty, hMUIBtnChooseCancel, @ButtonBackColorAlt, MUI_RGBCOLOR(66,66,68)
        Invoke MUIButtonSetProperty, hMUIBtnChooseCancel, @ButtonBorderStyle, MUIBBS_ALL
        Invoke MUIButtonSetProperty, hMUIBtnChooseCancel, @ButtonBorderColor, MUI_RGBCOLOR(103,103,106)
        Invoke MUIButtonSetProperty, hMUIBtnChooseCancel, @ButtonBorderColorAlt, MUI_RGBCOLOR(56,163,254)


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Text: Choose components
        ;-----------------------------------------------------------------------------------------------------        
        Invoke MUITextCreate, hWin, Addr szChooseComponents, 15, 20, 379, 80, IDC_TEXTCHOOSE, MUITS_10PT or MUITS_FONT_SEGOE
        mov hMUITextChoose, eax
        Invoke MUITextSetProperty, hMUITextChoose, @TextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextChoose, @TextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextChoose, @TextBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUITextSetProperty, hMUITextChoose, @TextBackColorAlt, MUI_RGBCOLOR(45,45,48)


    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        shr eax, 16
        mov wNotifyCode, eax
        mov eax,wParam
        and eax,0FFFFh

        .IF eax == IDC_BTNCHOOSECANCEL
            Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 0, FALSE
        .ELSEIF eax == IDC_BTNCHOOSENEXT
            mov dwInstallStage, 2
            Invoke MUISmartPanelSetCurrentPanel, hMUISmartPanel, 3, FALSE ; 4th dialog
        .ENDIF

    ;-----------------------------------------------------------------------------------------------------
    ; ModernUI - Color background and border
    ;-----------------------------------------------------------------------------------------------------
;    .ELSEIF eax == WM_ERASEBKGND
;        mov eax, 1
;        ret
;
;    .ELSEIF eax == WM_PAINT
;        invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(45,45,48), 0
;        mov eax, 0
;        ret
    ;-----------------------------------------------------------------------------------------------------

    .ELSEIF eax==WM_CLOSE
        invoke DestroyWindow, hWin
    .ELSE
        mov eax,FALSE
        ret
    .ENDIF
    mov  eax,TRUE
    ret

Panel3Proc ENDP


;------------------------------------------------------------------------------
; Download Dialog - Panel4 - Finish dialog?
;------------------------------------------------------------------------------
Panel4Proc PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    LOCAL wNotifyCode:DWORD
    
    mov eax, uMsg
    .IF eax==WM_INITDIALOG
    
        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button: Finish
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szBtnFinishText, 350, 500, 90, 28, IDC_BTNFINISH, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON or MUIBS_CENTER
        mov hMUIBtnFinish, eax        
        Invoke MUIButtonSetProperty, hMUIBtnFinish, @ButtonTextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnFinish, @ButtonTextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUIButtonSetProperty, hMUIBtnFinish, @ButtonBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUIButtonSetProperty, hMUIBtnFinish, @ButtonBackColorAlt, MUI_RGBCOLOR(66,66,68)
        Invoke MUIButtonSetProperty, hMUIBtnFinish, @ButtonBorderStyle, MUIBBS_ALL
        Invoke MUIButtonSetProperty, hMUIBtnFinish, @ButtonBorderColor, MUI_RGBCOLOR(103,103,106)
        Invoke MUIButtonSetProperty, hMUIBtnFinish, @ButtonBorderColorAlt, MUI_RGBCOLOR(56,163,254)


        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Text: Installation completed
        ;-----------------------------------------------------------------------------------------------------        
        Invoke MUITextCreate, hWin, Addr szFinished, 15, 20, 379, 80, IDC_TEXTFINISHED, MUITS_10PT or MUITS_FONT_SEGOE
        mov hMUITextFinished, eax
        Invoke MUITextSetProperty, hMUITextFinished, @TextColor, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextFinished, @TextColorAlt, MUI_RGBCOLOR(179,179,179)
        Invoke MUITextSetProperty, hMUITextFinished, @TextBackColor, MUI_RGBCOLOR(45,45,48)
        Invoke MUITextSetProperty, hMUITextFinished, @TextBackColorAlt, MUI_RGBCOLOR(45,45,48)  


    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        shr eax, 16
        mov wNotifyCode, eax
        mov eax,wParam
        and eax,0FFFFh
        
        .IF eax == IDC_BTNFINISH
            mov dwInstallStage, 3
            Invoke SendMessage, hWnd, WM_CLOSE, 0, 0
        .ENDIF


    ;-----------------------------------------------------------------------------------------------------
    ; ModernUI - Color background and border
    ;-----------------------------------------------------------------------------------------------------
;    .ELSEIF eax == WM_ERASEBKGND
;        mov eax, 1
;        ret
;
;    .ELSEIF eax == WM_PAINT
;        invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(45,45,48), 0
;        mov eax, 0
;        ret
    ;-----------------------------------------------------------------------------------------------------

    .ELSEIF eax==WM_CLOSE
        invoke DestroyWindow, hWin
    .ELSE
        mov eax,FALSE
        ret
    .ENDIF
    mov  eax,TRUE
    ret

Panel4Proc ENDP





