@ECHO OFF
CLS
ECHO.[ModernUI Installation]
ECHO.
IF "%~1" == "" GOTO TryMasmDefaultDir
GOTO CheckFolderProvided

:CheckFolderProvided
REM ECHO :CheckFolderProvided
SET INSTALLFOLDER=%~1
IF NOT EXIST "%INSTALLFOLDER%\" GOTO DIRERROR
ECHO - Installation folder specified exists.
IF NOT EXIST "%INSTALLFOLDER%\LIB\" MD "%INSTALLFOLDER%\LIB\"
IF NOT EXIST "%INSTALLFOLDER%\INCLUDE\" MD "%INSTALLFOLDER%\INCLUDE\"
GOTO COPYMODERNUIFILES

:TryMasmDefaultDir
REM ECHO :TryMasmDefaultDir
SET INSTALLFOLDER=\MASM32\
IF NOT EXIST "%INSTALLFOLDER%" GOTO NOMASMDIR
ECHO - MASM32 default folder exists.
GOTO COPYMODERNUIFILES


:COPYMODERNUIFILES
ECHO - Copying ModernUI files...
copy .\ModernUI\ModernUI.lib "%INSTALLFOLDER%\lib" /y > NUL
copy .\ModernUI\ModernUI.inc "%INSTALLFOLDER%\include" /y > NUL

copy .\Controls\ModernUI_Button\ModernUI_Button.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_Button\ModernUI_Button.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_CaptionBar\ModernUI_CaptionBar.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_CaptionBar\ModernUI_CaptionBar.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_Checkbox\ModernUI_Checkbox.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_Checkbox\ModernUI_Checkbox.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_DesktopFace\ModernUI_DesktopFace.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_DesktopFace\ModernUI_DesktopFace.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_Icon\ModernUI_Icon.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_Icon\ModernUI_Icon.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_Map\ModernUI_Map.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_Map\ModernUI_Map.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_ProgressBar\ModernUI_ProgressBar.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_ProgressBar\ModernUI_ProgressBar.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_ProgressDots\ModernUI_ProgressDots.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_ProgressDots\ModernUI_ProgressDots.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_Region\ModernUI_Region.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_Region\ModernUI_Region.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_SmartPanel\ModernUI_SmartPanel.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_SmartPanel\ModernUI_SmartPanel.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_Text\ModernUI_Text.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_Text\ModernUI_Text.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_Tooltip\ModernUI_Tooltip.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_Tooltip\ModernUI_Tooltip.inc %INSTALLFOLDER%\include /y > NUL
copy .\Controls\ModernUI_TrayMenu\ModernUI_TrayMenu.lib %INSTALLFOLDER%\lib /y > NUL
copy .\Controls\ModernUI_TrayMenu\ModernUI_TrayMenu.inc %INSTALLFOLDER%\include /y > NUL
ECHO - Finished copying files.
ECHO.
GOTO END


:DIRERROR
ECHO ! Folder provided for installation doesnt exist
ECHO   Usage: Install <folder location> 
ECHO
GOTO END

:NOMASMDIR
ECHO ! No MASM32 default folder found on current drive
ECHO   Usage: Install <folder location> 
ECHO
GOTO END

:END