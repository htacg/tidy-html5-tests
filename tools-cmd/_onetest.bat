@echo off
@REM Can NOT setlocal in here!

@REM #======================================================================
@REM # _onetest.bat - execute a single test case
@REM #
@REM # You should use alltest or t1 instead of this file!
@REM #
@REM # (c) 1998-2006 (W3C) MIT, ERCIM, Keio University
@REM # See tidy.c for the copyright notice.
@REM # <URL:http://www.html-tidy.org/>
@REM #
@REM # used-by t1.bat, alltest.bat
@REM #======================================================================


REM ------------------------------------------------
REM  Requirements checks
REM ------------------------------------------------
@call _environment.bat :TEST_ENVIRONMENT
@if ERRORLEVEL 1 (
  @echo.
  @echo Stopping because something is wrong. See error messages above.
  @echo.
  @exit /b 1
)

@if "%1x" == "x" goto :Err1
@if "%2x" == "x" goto :Err2


@REM ------------------------------------------------
@REM  Setup test parameters and files
@REM ------------------------------------------------
@set TESTNO=%1
@set EXPECTED=%2

@set INFILES==%TY_CASES_DIR%\case-%1.*ml
@set CFGFILE=%TY_CASES_DIR%\case-%1.conf

@set TIDYFILE=%TY_RESULTS_DIR%\case-%1.html
@set MSGFILE=%TY_RESULTS_DIR%\case-%1.txt

@set HTML_TIDY=


@REM ------------------------------------------------
@REM If no test specific config file, use default.
@REM ------------------------------------------------
@if NOT exist "%CFGFILE%" set CFGFILE=%TY_CONFIG_DEFAULT%


@REM ------------------------------------------------
@REM  Get specific input file names, and check them
@REM ------------------------------------------------
@set INFILE=
@for %%F in ( %INFILES% ) do set INFILE=%%F 
@if "%INFILE%." == "." goto :Err3
@if NOT EXIST "%INFILE%" goto :Err4


@REM ------------------------------------------------
@REM  Remove any pre-exising test outputs
@REM ------------------------------------------------
@if exist "%MSGFILE%"  del "%MSGFILE%"
@if exist "%TIDYFILE%" del "%TIDYFILE%"


@REM ------------------------------------------------
@REM  Begin tidying and testing
@REM ------------------------------------------------
@echo Doing: %TY_TIDY_PATH% -lang en_us -f %MSGFILE% -config %CFGFILE% %3 %4 %5 %6 %7 %8 %9 --tidy-mark no -o %TIDYFILE% %INFILE% >> "%TY_RESULTS_FILE%"

@"%TY_TIDY_PATH%" -lang en_us -f "%MSGFILE%" -config "%CFGFILE%" %3 %4 %5 %6 %7 %8 %9 --tidy-mark no -o "%TIDYFILE%" "%INFILE%"
@set STATUS=%ERRORLEVEL%
@echo Testing %1, expect %EXPECTED%, got %STATUS%
@echo Testing %1, expect %EXPECTED%, got %STATUS% >> "%TY_RESULTS_FILE%"
@REM echo. >> "%TY_RESULTS_FILE%"

@if %STATUS% EQU %EXPECTED% goto :done
@set ERRTESTS=%ERRTESTS% %TESTNO%
@echo *** Failed - got %STATUS%, expected %EXPECTED% ***
@REM type %MSGFILE%
@echo *** Failed - got %STATUS%, expected %EXPECTED% *** >> "%TY_RESULTS_FILE%"
@type %MSGFILE% >> "%TY_RESULTS_FILE%"
@goto :done


@REM ------------------------------------------------
@REM  Messages and Exception Handlers
@REM ------------------------------------------------

:Err1
  @echo.
  @echo ERROR: No input test number given!
:Err2
  @echo ERROR: No expected exit value given!
  @echo.
@goto :done

:Err3
  @echo ==============================================================
  @echo ERROR: Failed to find input matching '%INFILES%'!!!
  @echo ==============================================================
  @pause
@goto :done

:Err4
  @echo ==============================================================
  @echo ERROR: Failed to find input file '%INFILE%'!!!
  @echo ==============================================================
  @pause
@goto :done


:done
