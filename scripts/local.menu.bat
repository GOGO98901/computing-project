@echo off
set title=Development manager - Computing Project
set /A doExit=0
set bar=-------------------------------------------------------------------------------

title %title%

if NOT [%1] == [] (
	set /A option=%1
	set /A doExit=1
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
echo   -  (3) Jekyll build
echo After Jekyll:
echo   -  (4) Link filesystem
echo Non Dependent (but shoud be after Jekyll):
echo   -  (5) Serve the build folder
echo   -  (6) Open dartium

echo %bar%
set /A option=-1
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
	start cmd /C jekyll build --config _config.yml,_config-dev.yml
)
if %option%==4 (
	:: Copy's pubspec
	cp _site\pubspec.yaml _site\static

	:: linsk dart to script directory
	mkdir  %CD%\_site\static\assets\script\
	runas /user:Administrator /savecred "cmd /c mklink /J %CD%\_site\static\assets\script\dart %CD%\dart"

	:: links packages to dart dir
	runas /user:Administrator /savecred "cmd /c mklink /J %CD%\dart\packages %CD%\packages"
	runas /user:Administrator /savecred "cmd /c mklink /J %CD%\dart\util\packages %CD%\packages"

	:: links javascript to script directory
	runas /user:Administrator /savecred "cmd /c mklink /J %CD%\_site\static\assets\script\javascript %CD%\static\assets\script\javascript"

	:: link images to assets directory
	runas /user:Administrator /savecred "cmd /c mklink /J %CD%\_site\static\assets\images %CD%\static\assets\images"
)
if %option%==5 (
	:: Starts python webserver
	start cmd /k "cd _site/static && python -m SimpleHTTPServer 3694"
)
if %option%==6 (
	:: Starts dartium
	start "" "C:/Program Files/Dart/chromium/chrome.exe" --use-spdy=off --allow-file-access-from-files --app=http://127.0.0.1:3694/
)
if %doExit%==1 (
	::exit
)
goto menu
