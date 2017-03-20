@echo off
@REM Can NOT setlocal in here!

@REM #======================================================================
@REM # _onetesta.bat - execute a single accessibility test case
@REM #
@REM # You should use alltest instead of this file!
@REM # 
@REM # (c) 2006 (W3C) MIT, ERCIM, Keio University
@REM # See tidy.c for the copyright notice.
@REM # <URL:http://www.html-tidy.org/>
@REM #
@REM # used-by alltest.bat
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


@REM ------------------------------------------------
@REM  Echo here so we know what we're testing if
@REM  the script fails for some reason.
@REM ------------------------------------------------
@echo Testing %1 %2 %3


@REM ------------------------------------------------
@REM  Setup test parameters and files, and check
@REM  them.
@REM ------------------------------------------------
@set TESTNO=%1
@set TESTEXPECTED=%2
@set ACCESSLEVEL=%3
@if "%1x" == "x" goto NOTEST
@if "%2x" == "x" goto NOEXPECT
@if "%3x" == "x" goto NOLEVEL

@set INFILES=%TY_CASES_DIR%\case-%1.*ml
@set CFGFILE=%TY_CASES_DIR%\case-%1.conf

@set TIDYFILE=%TY_RESULTS_DIR%\case-%1.html
@set MSGFILE=%TY_RESULTS_DIR%\case-%1.txt

@set HTML_TIDY=

@if NOT exist "%CFGFILE%" set CFGFILE=%TY_CONFIG_DEFAULT%


@REM ------------------------------------------------
@REM  Get the specific input filename.
@REM ------------------------------------------------
@for %%F in ( %INFILES% ) do set INFILE=%%F
@if NOT EXIST "%INFILE%" goto NO_FILE


@REM ------------------------------------------------
@REM  Cleanup and then run the test.
@REM ------------------------------------------------
@if exist "%MSGFILE%"  del "%MSGFILE%"
@if exist "%TIDYFILE%" del "%TIDYFILE%"

@echo Doing: %TY_TIDY_PATH% -f %MSGFILE% --accessibility-check %ACCESSLEVEL% -config %CFGFILE% --show-info no --tidy-mark no -o %TIDYFILE% %INFILE% >> "%TY_RESULTS_FILE%"

@REM this has to all one line.
@"%TY_TIDY_PATH%" -f "%MSGFILE%" --accessibility-check %ACCESSLEVEL% -config "%CFGFILE%" --show-info no --tidy-mark no -o "%TIDYFILE%" "%INFILE%"

@REM Create temp directory if necessary.
@if NOT EXIST "%TY_TMP_DIR%\" md "%TY_TMP_DIR%"

@REM output the FIND count to the a result file
@find /c "%TESTEXPECTED%" "%MSGFILE%" > "%TY_TMP_FILE%"
@REM load the find count, token 3, into variable RESULT
@for /F "tokens=3" %%i in (%TY_TMP_FILE%) do set RESULT=%%i
@REM test the RESULT variable ...
@if "%RESULT%." == "0." goto Err
@if "%RESULT%." == "1." goto done
@goto done


@REM ------------------------------------------------
@REM  Report result is an error.
@REM ------------------------------------------------
@:Err
@echo FAILED --- test '%TESTEXPECTED%' not detected in file '%INFILE%'
@type %MSGFILE%
@echo FAILED --- test '%TESTEXPECTED%' not detected in above
@set ERRTESTS=%ERRTESTS% %1

@REM append results to the results file
@echo FAILED --- test '%TESTEXPECTED%' not detected in file '%MSGFILE%', as follows - >> "%TY_RESULTS_FILE%"
@type %MSGFILE% >>                                                                       "%TY_RESULTS_FILE%"
@echo FAILED --- test '%TESTEXPECTED%' not detected in above >>                          "%TY_RESULTS_FILE%"
@echo ======================================= >>                                         "%TY_RESULTS_FILE%"
@goto done


@REM ------------------------------------------------
@REM  Messages and Exception Handlers
@REM ------------------------------------------------

:NO_FILE
  @echo ======================================= >>                "%TY_RESULTS_FILE%"
  @echo Testing %1 %2 %3 >>                                       "%TY_RESULTS_FILE%"
  @echo ERROR: Can NOT locate [%INFILE%] ... aborting test ... >> "%TY_RESULTS_FILE%"
  @echo ERROR: Can NOT locate [%INFILE%] ... aborting test ...
@goto DONE


:NOTEST
  @echo Error: NO test number given as the first argument!
:NOEXPECT
  @echo Error: NO expected result given as the second argument!
:NOLEVEL
  @echo Error: NO accesslevel given as the third argument!

:HELP
  @echo.
  @echo Don't attempt to run this file. Run alltest.bat instead.
  @echo Use Ctrl+c to abort, to fix...
  @pause
@goto DONE

:done
