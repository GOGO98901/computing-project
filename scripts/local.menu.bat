@echo off
set title=Development manager - Computing Project
set doExit=0
set bar=-------------------------------------------------------------------------------

if NOT [%1] == [] (
	set option=%1
	set doExit=1
	goto command
) else (
	cd ../
)

:menu
title %title%
cls
echo %bar%
echo Main Menu - %title%
echo %bar%
echo General:
echo   -  (1) Get the pub dependencies
echo   -  (2) Clean build directory
echo   -  (3) Serve the build folder
echo   -  (4) Open dartium
echo   -  (5) Quick Start
echo   -  (6) Develop Dart and open dartium (use only for developing the game.html/dart code)

echo %bar%
set option=-1
set /p option="To select an option enter the corresponding number: "

:command
cls
title %title% - [option = %option%]
if %option%==1 (
	:: Collects pub dependencies and saves them
	start cmd /C pub get --packages-dir
)
if %option%==2 (
	:: Deletes the build directory
	rd /s /q "_site/"
)
if %option%==3 (
	:: Builds the liquid html
	start cmd /C jekyll serve --watch --config _config.yml,_config-dev.yml
)
if %option%==4 (
	:: Starts dartium
	start "" "C:/Program Files/Dart/chromium/chrome.exe" --disable-web-security --use-spdy=off --allow-file-access-from-files --app=http://127.0.0.1:3694
)
if %option%==5 (
	:: Starts with 3 and 4
	start %CD%\scripts\local.menu.bat 3
	start %CD%\scripts\local.menu.bat 4
)
if %option%==6 (
	rd /s /q "_site/assets/images"
	rd /s /q "_site/assets/problems"
	rd /s /q "_site/assets/script/dart"
	rd /s /q "_site/assets/script/javascript"

	runas /user:Administrator /savecred "cmd /c mklink /d %CD%\_site\assets\images ..\..\src\images"
	runas /user:Administrator /savecred "cmd /c mklink /d %CD%\_site\assets\problems ..\..\src\problems"
	runas /user:Administrator /savecred "cmd /c mklink /d %CD%\_site\assets\script\dart ..\..\..\src\dart"
	runas /user:Administrator /savecred "cmd /c mklink /d %CD%\_site\assets\script\javascript ..\..\..\src\javascript"

	start cmd /k "cd _site && python -m http.server 3694"
	start "" "C:/Program Files/Dart/chromium/chrome.exe" --disable-web-security --use-spdy=off --allow-file-access-from-files --app=http://127.0.0.1:3694/game.html
)
if %doExit%==1 (
	exit
)
goto menu
