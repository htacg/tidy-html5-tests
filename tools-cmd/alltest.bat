@echo off
setlocal enabledelayedexpansion

REM #======================================================================
REM # alltest.bat
REM #   Execute all test cases, optionally specifying a tidy instance
REM #   and different output folder.
REM # 
REM # (c) 1998-2006 (W3C) MIT, ERCIM, Keio University
REM # See tidy.c for the copyright notice.
REM # 
REM # <URL:http://www.html-tidy.org/>
REM # 
REM #    $Author: arnaud02 $
REM #    $Date: 2006/12/28 10:01:44 $
REM #    $Revision: 1.1 $
REM #
REM # requires onetest.bat
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
call _environment.bat :set_environment

set TMPTEST=%TY_RESULTS_FILE%

REM ------------------------------------------------
REM  Requirements checks
REM ------------------------------------------------
if "%1" == "/help" goto USE
if "%1" == "/h" goto USE

if NOT EXIST %TY_EXPECTS_FILE% goto Err0
if NOT EXIST onetest.bat goto Err3
if NOT EXIST %TY_CASES_DIR%\nul goto Err4

if NOT DEFINED TY_TIDY_PATH goto ERR5
set TIDY=%TY_TIDY_PATH%
if NOT EXIST %TIDY% goto ERR1

REM ------------------------------------------------
REM  Set the output folder. We will actually build
REM  into the standard output folder, and then move
REM  them later if necessary.
REM ------------------------------------------------
set TIDYOUT=%TY_RESULTS_DIR%
set FINALOUT=%TY_RESULTS_DIR%

IF NOT "%~2" == "" (
    echo Will move final output to "%~2"
    set FINALOUT=%~2
)

if NOT EXIST %TIDYOUT%\nul md %TIDYOUT%
if NOT EXIST %TIDYOUT%\nul goto Err2

REM ------------------------------------------------
REM  Setup the report header
REM ------------------------------------------------
set TMPCNT=0
for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do set /A TMPCNT+=1
echo =============================== > %TMPTEST%
echo Date %DATE% %TIME% >> %TMPTEST%
echo Tidy EXE %TIDY%, version >> %TMPTEST%
%TIDY% -v >> %TMPTEST%
echo Input list of %TMPCNT% tests from '%TY_EXPECTS_FILE%' file >> %TMPTEST%
echo Outut will be to the '%FINALOUT%' folder >> %TMPTEST%
echo =============================== >> %TMPTEST%

echo Doing %TMPCNT% tests from '%TY_EXPECTS_FILE%' file...

REM ------------------------------------------------
REM  Perform the testing
REM ------------------------------------------------
set ERRTESTS=
for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do call onetest.bat %%i %%j

REM ------------------------------------------------
REM  Output failing test information
REM ------------------------------------------------
echo =============================== >> %TMPTEST%
if "%ERRTESTS%." == "." goto DONE
echo ERROR TESTS [%ERRTESTS%] ...
echo ERROR TESTS [%ERRTESTS%] ... >> %TMPTEST%

REM ------------------------------------------------
REM  Final testing report
REM ------------------------------------------------
:DONE
echo End %DATE% %TIME% >> %TMPTEST%
echo =============================== >> %TMPTEST%
IF NOT "%TIDYOUT%" == "%FINALOUT%" (
    IF EXIST %TY_RESULTS_BASE_DIR%\%FINALOUT% goto WARNING1
    IF EXIST %TY_RESULTS_BASE_DIR%\%FINALOUT%.txt WARNING1
    echo Setting %TIDYOUT% to desired %FINALOUT%...
    RENAME %TIDYOUT% %FINALOUT%
    RENAME %TMPTEST% %FINALOUT%.txt
    set TMPTEST=%TY_RESULTS_BASE_DIR%\%FINALOUT%.txt
    )
echo.
echo See %TMPTEST% file for list of tests done...
echo And compare folders 'diff -u testbase %FINALOUT% ^> temp.diff'
echo and check any differences carefully... If acceptable update 'testbase' accordingly...
echo.
goto END

REM ------------------------------------------------
REM  Messages and Exception Handlers
REM ------------------------------------------------

:ERR0
echo ERROR: Can not locate 'testcases.txt' ... check name, and location ...
goto END

:ERR1
echo ERROR: Can not locate %TIDY% ... check name, and location ...
goto END

:ERR2
echo ERROR: Can not create %TIDYOUT% folder ... check name, and location ...
goto END

:ERR3
echo ERROR: Can not locate 'onetest.bat' ... check name, and location ...
goto END

:ERR4
echo ERROR: Can not locate 'input' folder ... check name, and location ...
goto END

:ERR5
echo ERROR: You must define TY_TIDY_PATH, or specify the path as an argument ...
goto END

:WARNING1
echo WARNING: You specified a directory name that already exists, so output
echo will be in %TY_RESULTS_DIR% and %TY_RESULTS_FILE%.
GOTO:EOF


:USE
echo  Usage of ALLTEST.BAT
echo  AllTest [tidy.exe [Out_Folder]]
echo  tidy.exe - This is the Tidy.exe you want to use for the test.
echo  Out_Folder  - This is the FOLDER where you want the results put,
echo  relative to the %TY_RESULTS_BASE_DIR% folder.
echo  This folder will be created if it does not already exist.
echo  These are both optional, but you must specify [tidy.exe] if you
echo  wish to specify [Out_Folder].
echo  ==================================
echo  ALLTEST.BAT will run a battery of test files in the input folder
echo  Each test name, has an expected result, given in its table.
echo  There will be a warning if any test file fails to give this result.
echo  ==================================
echo  But the main purpose is to compare the 'results' of two version of
echo  any two Tidy runtime exe's. Thus after you have two sets of results,
echo  in separate folders, the idea is to compare these two folders.
echo  Any directory compare utility will do, or you can download, and use
echo  a WIN32 port of GNU diff.exe from http://unxutils.sourceforge.net/
echo  ................................................................
goto END

:END
