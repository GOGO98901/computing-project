# Copyright 2016 Rory Claasen
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and

@echo off
title Development manager - Computing Project
cd ../
set bar=-------------------------------------------------------------------------------
:loop
cls
echo %bar%
echo Main Menu
echo %bar%
echo   (0) exit
echo   (1) pub get              - Collects the current dart dependencies
echo   (2) jekyll build         - Builds the liquid html
echo   (3) copy dart            - Copys the dart code to the output of (2).
echo   (4) serve                - Starts a python server
echo   (5) dartium              - Opens dartium browser
echo %bar%
set option=-1
set /P option="To select an option enter the corresponding number: "
if %option% == 0 (
	exit
) else (
	if %option% == 1 (
		start cmd /C pub get --packages-dir
	)
	if %option% == 2 (
		start cmd /C jekyll build --config _config.yml,_config-dev.yml | cp dart _site/assets/script/
	)
	if %option% == 3 (
		start cmd /C cp dart _site/assets/script/
	)
	if %option% == 4 (
		start cmd /k "cd _site/static && python -m SimpleHTTPServer 3694"
	)
	if %option% == 5 (
		start "" "C:/Program Files/Dart/chromium/chrome.exe" --use-spdy=off --allow-file-access-from-files --app=http://127.0.0.1:3694/
	)
)
goto loop
