@echo off
setlocal

call _environment.bat :process_cli %*

call _environment.bat :report_environment

call _environment.bat :create_results_dir
if ERRORLEVEL 1 exit /b 1

call _environment.bat :unset_environment
echo.
echo This script is done.
