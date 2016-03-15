@echo off
setlocal

echo ---------------------------
echo PROCESS CLI
echo ---------------------------
call _environment.bat :process_cli %*

echo ---------------------------
echo REPORTING ENVIRONMENT
echo ---------------------------
call _environment.bat :report_environment

echo ---------------------------
echo CREATE RESULTS DIR
echo ---------------------------
call _environment.bat :create_results_dir
if ERRORLEVEL 1 (
  echo Exiting script due to errors.
  exit /b 1
)

echo ---------------------------
echo CHECK ENVIRONMENT
echo ---------------------------
call _environment.bat :test_environment


echo ---------------------------
echo UNSET ENVIRONMENT
echo ---------------------------
call _environment.bat :unset_environment

echo.
echo ---------------------------
echo All done!
echo ---------------------------


