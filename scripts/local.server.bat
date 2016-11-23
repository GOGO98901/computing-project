@echo off
title Jekyll server
cd ../
jekyll serve --config _config.yml,_config-dev.yml --watch --incremental 
pause
