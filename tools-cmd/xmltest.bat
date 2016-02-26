@echo off
setlocal enabledelayedexpansion

REM #======================================================================
REM # xmltest.bat - execute all XML test cases
REM #
REM # (c) 1998-2003 (W3C) MIT, ERCIM, Keio University
REM # See tidy.c for the copyright notice.
REM #
REM # <URL:http://www.html-tidy.org/>
REM #
REM # requires onetest.bat
REM #======================================================================


REM ------------------------------------------------
REM  Allow user to specify a different Tidy.
REM ------------------------------------------------
IF NOT "%~1" == "" (
    echo Setting TY_TIDY_PATH to "%~1"
    set TY_TIDY_PATH="%~1"
)

REM ------------------------------------------------
REM  Setup the ENVIRONMENT.
REM ------------------------------------------------
set TY_CASES_SETNAME=xml
call _environment.bat :set_environment

REM ------------------------------------------------
REM  Requirements checks and verification
REM ------------------------------------------------
if NOT DEFINED TY_TIDY_PATH goto SET_TY_TIDY_PATH
if NOT EXIST %TY_TIDY_PATH% goto NOEXE
if NOT EXIST %TY_EXPECTS_FILE% goto NOXML

if NOT EXIST %TY_RESULTS_BASE_DIR%\nul md %TY_TMP_DIR%

if EXIST %TY_RESULTS_FILE% del %TY_RESULTS_FILE%

REM ------------------------------------------------
REM  Performing the testing
REM ------------------------------------------------
echo Commencing xml tests from %TY_EXPECTS_FILE%

for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do (call onetest.bat %%i %%j)

echo Full output written to %TY_RESULTS_FILE%

goto END

REM ------------------------------------------------
REM  Messages and Exception Handlers
REM ------------------------------------------------

:NOXML
echo Error: Can NOT locate %TY_EXPECTS_FILE%! *** FIX ME ***
goto END

:NOEXE
echo Can NOT locate %TY_TIDY_PATH% executable! *** FIX ME ***
goto END

:SET_TY_TIDY_PATH
echo.
echo Error: You must set TY_TIDY_PATH! *** FIX ME ***
echo.
goto END

:END
