@echo off
setlocal enabledelayedexpansion

REM #======================================================================
REM # execute all test cases of the accessibility test suite
REM #======================================================================


REM ------------------------------------------------
REM  Allow user to specify a different Tidy.
REM ------------------------------------------------
IF NOT "%~1" == "" (
    echo Setting TY_TIDY_PATH to "%~1"
    set TY_TIDY_PATH=%~1
)

REM ------------------------------------------------
REM  Setup the ENVIRONMENT.
REM ------------------------------------------------
set TY_CASES_SETNAME=access
call _environment.bat :set_environment

REM ------------------------------------------------
REM  Requirements checks
REM ------------------------------------------------
if NOT EXIST %TY_TIDY_PATH% goto ERR1
if NOT EXIST %TY_CONFIG_DEFAULT% goto ERR2
if NOT EXIST %TY_EXPECTS_FILE% goto ERR3
if NOT EXIST %TY_RESULTS_DIR%\nul md %TY_RESULTS_DIR%

REM ------------------------------------------------
REM  Report header
REM ------------------------------------------------
echo Running ACCESS TEST suite
echo Executable = %TY_TIDY_PATH%
echo Input Folder = %TY_CASES_DIR%
echo Output Folder = %TY_RESULTS_DIR%

echo Running ACCESS TEST suite >%TY_RESULTS_FILE%
echo Executable = %TY_TIDY_PATH% >>%TY_RESULTS_FILE%
echo Input Folder = %TY_CASES_DIR% >>%TY_RESULTS_FILE%
echo Output Folder = %TY_RESULTS_DIR% >>%TY_RESULTS_FILE%

REM ------------------------------------------------
REM  Peform the testing
REM ------------------------------------------------
set FAILEDACC=
for /F "skip=1 tokens=1,2*" %%i in (%TY_EXPECTS_FILE%) do (call onetesta.bat %%i %%j %%k)
if "%FAILEDACC%." == "." goto SUCCESS
echo FAILED [%FAILEDACC%] ...
goto END

REM ------------------------------------------------
REM  Messages and Exception Handlers
REM ------------------------------------------------

:SUCCESS
echo Appears ALL tests ran fine ...
goto END


:ERR1
echo ERROR: Unable to locate executable - [%TY_TIDY_PATH%] - check name and location ...
goto END

:ERR2
echo ERROR: Cannot locate file - [%TY_CONFIG_DEFAULT%] check name and location ...
goto END

:ERR3
echo ERROR: Cannot locate file - [%TY_EXPECTS_FILE%] - check name and location ...
goto END

:END
