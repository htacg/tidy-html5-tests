@echo off
@setlocal

@REM #======================================================================
@REM # A convenient run one test giving the number and expected exit.
@REM #
@REM # This is to run just one, like "t1 1642186-1 0 [options]"
@REM #
@REM # Note that you must have the TY_TIDY_PATH environment variable set to
@REM # the path of a valid tidy, or specify the `-t path/to/tidy.exe`
@REM # option.
@REM #
@REM # requires TY_ONETEST
@REM #======================================================================


@REM ------------------------------------------------
@REM  Ensure that %1 and %2 are present and numbers.
@REM  While checking make sure %2 is reasonable.
@REM ------------------------------------------------
@if "%~1x" == "x" goto :HELP
@if "%~2x" == "x" goto :HELP
@echo %~1| findstr /r ^[1-9][0-9].*$ > nul
@if ERRORLEVEL 1 goto :HELP
@echo %~2| findstr /r ^[0-2]$ > nul
@if ERRORLEVEL 1 goto :HELP


@REM ------------------------------------------------
@REM  Handle the CLI, and setup and test the 
@REM  environment.
@REM ------------------------------------------------
@call _environment.bat :PROCESS_CLI %3 %4 %5 %6 %7 %8
@if ERRORLEVEL 1 IF "%TY_WANTS_HELP%" == "" (
  @echo.
  @echo Stopping because something is wrong. See error messages above.
  @echo.
  @exit /b 1
)
@if NOT "%TY_WANTS_HELP%" == "" goto :HELP


@REM ------------------------------------------------
@REM  Setup our file names, and additional checks.
@REM ------------------------------------------------
@set TMPFIL=%TY_CASES_DIR%\case-%1.xhtml
@if NOT EXIST "%TMPFIL%" (
    @set TMPFIL=%TY_CASES_DIR%\case-%1.xml
)
@if NOT EXIST "%TMPFIL%" (
    @set TMPFIL=%TY_CASES_DIR%\case-%1.html
)
@set TMPCFG=%TY_CASES_DIR%\case-%1.conf
    @if NOT EXIST "%TMPCFG%" (
@set TMPCFG=%TY_CONFIG_DEFAULT%
)

@if NOT EXIST "%TMPFIL%" goto :NOFIL
@if NOT EXIST "%TMPCFG%" goto :NOCFG


@REM ------------------------------------------------
@REM  Begin the test report and testing.
@REM ------------------------------------------------
@echo Test 1 case %DATE% %TIME%
@echo Test 1 case %DATE% %TIME% > "%TY_RESULTS_FILE%"
@"%TY_TIDY_PATH%" -v >> "%TY_RESULTS_FILE%"
@"%TY_TIDY_PATH%" -v
@echo.
@echo Doing 'call %TY_ONETEST% %1 %2'
@echo Doing 'call %TY_ONETEST% %1 %2' >> "%TY_RESULTS_FILE%"
@echo.

@call "%TY_ONETEST%" %1 %2

@echo.
@echo See output in %TY_RESULTS_FILE%

@set TMPFIL1=%TY_EXPECTS_DIR%\case-%1.html
@set TMPOUT1=%TY_EXPECTS_DIR%\case-%1.txt
@set TMPFIL2=%TY_RESULTS_DIR%\case-%1.html
@set TMPOUT2=%TY_RESULTS_DIR%\case-%1.txt

@if NOT EXIST "%TMPFIL1%" goto NOFIL1
@if NOT EXIST "%TMPFIL2%" goto NOFIL1

@if NOT EXIST "%TMPOUT1%" goto NOFIL2
@if NOT EXIST "%TMPOUT2%" goto NOFIL2


@REM ------------------------------------------------
@REM  Compare the outputs, exactly
@REM ------------------------------------------------
@set TMPOPTS=-ua
@set ERRCNT=0

@echo.
@echo Doing: 'diff %TMPOPTS% ...%TMPFIL1:~-35% ...%TMPFIL2:~-35%'
@diff %TMPOPTS% "%TMPFIL1%" "%TMPFIL2%"
@if ERRORLEVEL 1 goto GOTD1
@echo Files appear exactly the same...
@goto DODIF2


@REM ------------------------------------------------
@REM  Messages and Exception Handlers
@REM ------------------------------------------------

:GOTD1
@call :ISDIFF
@set /A ERRCNT+=1


:DODIF2
@echo.
@echo Doing: 'diff %TMPOPTS% ...%TMPOUT1:~-35% ...%TMPOUT2:~-35%'
@diff %TMPOPTS% %TMPOUT1% %TMPOUT2%
@if ERRORLEVEL 1 goto GOTD2
@echo Files appear exactly the same...
@goto DODIF3


:GOTD2
@call :ISDIFF
@set /A ERRCNT+=1


:DODIF3
@echo.
@if "%ERRCNT%x" == "0x" (
    echo Appears a successful test of %1 %2
) else (
    echo Carefully REVIEW the above differences on %1 %2! *** ACTION REQUIRED ***
)

@goto END


:ISDIFF
  @echo.
  @echo Check the above diff carefully. This may indicate a 'testbase', or
  @echo a 'regression' in tidy output.
  @echo.
@goto :EOF


:NOFIL1
  @echo.
  @echo Can NOT locate %TMPFIL1% or %TMPFIL2% 
  @echo needed for the compare... but this may not be a problem...
  @echo Maybe there is no 'testbase' file for test %1!
  @echo.
@goto END


:NOFIL2
  @echo.
  @echo Can NOT locate  %TMPOUT1% or %TMPOUT2% 
  @echo needed for the compare... but this may not be a problem...
  @echo but it is strange one or both were not created!!! *** NEEDS CHECKING ***
  @echo.
@goto END


:NOFIL
  @echo.
  @dir %TY_CASES_DIR%\*%1*
  @echo.
  @echo Error: Can NOT locate %TMPFIL%! Is number correct? 
  @echo.
@goto END


:NOCFG
  @echo.
  @echo Error: Can NOT locate %TMPCFG%!
  @echo.
@goto END


:HELP
  @echo.
  @echo Usage: %0 "value" "expected exit value" [options]
  @echo   That is give test number, and expected result, like
  @echo   %0 1642186 1
  @if "%~1x" == "x" goto HELP2
  @echo   Missing expected exit value. See _manifest.txt for list available.
  @echo   This is a @todo. There's no reason we can't just get this value from
  @echo   the manifest within this script.

:HELP2
  @echo.
@goto END


:END
