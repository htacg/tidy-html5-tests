@echo off
@setlocal

@REM #======================================================================
@REM # alltest.bat
@REM #
@REM # Execute all test cases.
@REM # 
@REM # (c) 1998-2006 (W3C) MIT, ERCIM, Keio University
@REM # See tidy.c for the copyright notice.
@REM # <URL:http://www.html-tidy.org/>
@REM #
@REM # requires TY_ONETEST
@REM #======================================================================


@REM ------------------------------------------------
@REM  Handle the CLI, and setup and test the 
@REM  environment. With the CLI support we can
@REM  simply use this with -c xml, and eliminate
@REM  the xmltest.bat script, I think.
@REM ------------------------------------------------
@call _environment.bat :PROCESS_CLI %*
@if ERRORLEVEL 1 IF "%TY_WANTS_HELP%" == "" (
  @echo.
  @echo Stopping because something is wrong. See error messages above.
  @echo.
  @exit /b 1
)
@if NOT "%TY_WANTS_HELP%" == "" goto :HELP


@REM ------------------------------------------------
@REM  Setup the report header
@REM ------------------------------------------------
@set TMPCNT=0
@for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do set /A TMPCNT+=1
@for /F "delims=" %%i IN ('"%TY_TIDY_PATH%" -v') DO set version=%%i
@if "%TY_VERSION_FILE%x" == "x" goto NOVERS
@if NOT EXIST %TY_VERSION_FILE% goto NOVERS
@set /p TY_VERSION=<%TY_VERSION_FILE%

@echo ==================================================== > "%TY_RESULTS_FILE%"
@echo  Testing setname: %TY_CASES_SETNAME% >>                "%TY_RESULTS_FILE%"
@echo             Date: %DATE% %TIME% >>                     "%TY_RESULTS_FILE%"
@echo         Tidy EXE: %TY_TIDY_PATH% >>                    "%TY_RESULTS_FILE%"
@echo     Tidy Version: %version% >>                         "%TY_RESULTS_FILE%"
@echo     Test Version: %TY_VERSION% from %TY_VERSION_FILE% >> "%TY_RESULTS_FILE%"
@echo   Input Manifest: %TY_EXPECTS_FILE% >>                 "%TY_RESULTS_FILE%"
@echo    Output folder: %TY_RESULTS_DIR%\ >>                 "%TY_RESULTS_FILE%"
@echo Tests to Perform: %TMPCNT% >>                          "%TY_RESULTS_FILE%"
@echo ==================================================== >>"%TY_RESULTS_FILE%"

@echo Doing %TMPCNT% tests from '%TY_EXPECTS_FILE%' file...


@REM ------------------------------------------------
@REM  Perform the testing
@REM ------------------------------------------------
@set ERRTESTS=
@if /i not "%TY_CASES_SETNAME%" == "access" for /F "tokens=1*"          %%i in (%TY_EXPECTS_FILE%) do (call "%TY_ONETEST%" %%i %%j)
@if /i     "%TY_CASES_SETNAME%" == "access" for /F "skip=1 tokens=1,2*" %%i in (%TY_EXPECTS_FILE%) do (call "%TY_ONETESTA%" %%i %%j %%k)

@REM ------------------------------------------------
@REM  Output failing test information
@REM ------------------------------------------------
@echo ==================================================== >> "%TY_RESULTS_FILE%"
echo.
@if "%ERRTESTS%." == "." (
  @echo It appears the tests executed correctly.
  @goto DONE
)
@echo ERROR TESTS [%ERRTESTS%] ...
@echo ERROR TESTS [%ERRTESTS%] ... >> "%TY_RESULTS_FILE%"


@REM ------------------------------------------------
@REM  Final testing report
@REM ------------------------------------------------
:DONE
@echo Completed: %DATE% %TIME% >> "%TY_RESULTS_FILE%"
@echo ==================================================== >> "%TY_RESULTS_FILE%"
@echo.
@echo See %TY_RESULTS_FILE% file for list of tests done.
@if /i "%TY_CASES_SETNAME%" == "access" goto END
@echo.
@diff -v > NUL
@if ERRORLEVEL 1 goto NODIFF
@echo Doing: 'diff -u %TY_EXPECTS_DIR% %TY_RESULTS_DIR%'
@echo Doing: 'diff -u %TY_EXPECTS_DIR% %TY_RESULTS_DIR%' >> "%TY_RESULTS_FILE%"
@diff -u %TY_EXPECTS_DIR% %TY_RESULTS_DIR% >> "%TY_RESULTS_FILE%"
@if ERRORLEVEL 1 goto DNDIFF
@echo.
@echo SUCCESS: Appears a successful compare of folders...
@echo SUCCESS: Appears a successful compare of folders... >> "%TY_RESULTS_FILE%"
@echo.
@goto END

:NODIFF
@echo If this is an output regression test, then also:
@echo   Compare folders:
@echo   Get the WIN32 port of GNU diff.exe from http://unxutils.sourceforge.net/
@echo   and use -
@echo     - 'diff -u %TY_EXPECTS_DIR% %TY_RESULTS_DIR%'
@echo.
@echo   Or use any other folder compare utility you have
:DNDIFF
@echo.
@echo   FAILED: Check any differences carefully:
@echo     - if acceptable update '%TY_EXPECTS_DIR%' accordingly.
@echo.
@goto END


@REM ------------------------------------------------
@REM  Messages and Exception Handlers
@REM ------------------------------------------------

:HELP
  @echo.
  @echo  Usage:
  @echo.
  @echo    %0 [-t path/to/tidy.exe] [-o output_directory/] [-c case_set_name]
  @echo.
  @echo    You must use the -t argument to specify the path to the tidy that
  @echo    you want to use for testing, unless you set TY_TIDY_PATH environment
  @echo    variable.
  @echo.
  @echo    Override the default output folder using the -o argument. This folder
  @echo    is relative to the %TY_RESULTS_BASE_DIR% 
  @echo    folder. The output folder will be created if it does not already exist.
  @echo    You can prevent automatic creation by setting TY_MKDIR_CONFIRM to
  @echo    something (you will be given a chance to confirm, instead).
  @echo.
  @echo    You can use the -c argument to specify a different case set folder.
  @echo    A case set is just a directory with a manifest and testing files
  @echo    with appropriate filenames. The default case set folder is
  @echo    %TY_CASES_DIR%. For example to run the XML test cases, you can
  @echo    specify `-c xml`.
  @echo.
  @echo  %0 will run a battery of test files in the input folder. Each
  @echo  test name has an expected result given in its manifest. A warning will
  @echo  be produced if any test file fails to give this result.
  @echo.
  @echo  But the main purpose is to compare the 'results' of two version of
  @echo  any two Tidy runtime exe's. Thus after you have two sets of results,
  @echo  in separate folders, the idea is to compare these two folders.
  @echo  Any directory compare utility will do, or you can download, and use
  @echo  a WIN32 port of GNU diff.exe from http://unxutils.sourceforge.net/
  @echo.
@goto END

:NOVERS
@echo A problem. Can NOT locate '%TY_VERSION_FILE%' file! *** FIX ME ***
@goto END

:END
