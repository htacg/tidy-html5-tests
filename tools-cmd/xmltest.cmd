@echo off

@REM =================================================================
@REM xmltest.cmd - execute all XML test cases
@REM
@REM (c) 1998-2003 (W3C) MIT, ERCIM, Keio University
@REM See tidy.c for the copyright notice.
@REM
@REM <URL:http://www.html-tidy.org/>
@REM =================================================================

@REM # Allow user to specify a different Tidy. Do this before any setlocal!
@IF NOT "%~1" == "" (
    echo Setting TY_TIDY_PATH to "%~1"
    set TY_TIDY_PATH="%~1"
)

@REM setup the ENVIRONMENT. Do this before any setlocal!
set original_cases_setname=%TY_CASES_SETNAME%
set TY_CASES_SETNAME=xml
@call _environment.bat :set_environment

@setlocal

@if NOT DEFINED TY_TIDY_PATH goto SET_TY_TIDY_PATH
@set TIDY=%TY_TIDY_PATH%
@if NOT EXIST %TIDY% goto NOEXE
@if NOT EXIST %TY_EXPECTS_FILE% goto NOXML
@REM set OUTPUT folder
@set TIDYOUT=%TY_RESULTS_BASE_DIR%
@if EXIST %TIDYOUT%\nul goto DOTEST
@md %TY_TMP_DIR%
:DOTEST
@set TMPTEST=%TY_RESULTS_FILE%
@if EXIST %TMPTEST% @del %TMPTEST%
@echo Commencing xml tests from %TY_EXPECTS_FILE%

@for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do @(call onetest.cmd %%i %%j)

@echo Full output written to %TMPTEST%

@goto END

:NOXML
@echo Error: Can NOT locate %TY_EXPECTS_FILE%! *** FIX ME ***
@goto END

:NOEXE
@echo Can NOT locate %TIDY% executable! *** FIX ME ***
@goto END

:SET_TY_TIDY_PATH
@echo.
@echo Error: You must set TY_TIDY_PATH! *** FIX ME ***
@echo.
@goto END

:END

set TY_CASES_SETNAME=%original_cases_setname%
