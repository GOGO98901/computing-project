@echo off
title Development manager - Computing Project
cd ../
SET option=-1
:MENU
cls
echo (0) exit
echo (1) pub get 				- Collects the current dart dependencies
echo (2) jekyll build 			- Builds the liquid html
echo (3) copy dart 				- Copys the dart code to the output of (2).
echo (4) serve 				- Starts a python server
echo (5) dartium 				- Opens dartium browser
echo.
SET /P option="To select an option enter the corresponding number: "
IF %option% == 0 exit
IF %option% == 1 GOTO PUB
IF %option% == 2 GOTO BUILD
IF %option% == 3 GOTO COPY
IF %option% == 4 GOTO SERVE
IF %option% == 5 GOTO DARTIUM
GOTO MENU

:PUB
start cmd /C pub get --packages-dir
GOTO MENU

:BUILD
start cmd /C jekyll build --config _config.yml,_config-dev.yml | cp dart _site/assets/script/
GOTO MENU

:COPY
start cmd /C cp dart _site/assets/script/
GOTO MENU

:SERVE
start cmd /k "cd _site/static && python -m SimpleHTTPServer 3694"
GOTO MENU

:DARTIUM
start "" "C:/Program Files/Dart/chromium/chrome.exe" --use-spdy=off --allow-file-access-from-files --app=http://127.0.0.1:3694/
GOTO MENU
