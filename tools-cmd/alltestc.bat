@echo off
setlocal enabledelayedexpansion

REM #======================================================================
REM # alltestc.bat - execute all test cases, with compare. Optionally
REM #   accept parameters for Tidy executable and output directory.
REM #======================================================================

REM setup the ENVIRONMENT.
call _environment.bat :set_environment

REM Allow user to specify a different Tidy.
IF NOT "%~1" == "" (
    echo Setting TY_TIDY_PATH to "%~1"
    set TY_TIDY_PATH=%~1
)

if "%1" == "/help" goto USE
if "%1" == "/h" goto USE

REM check for input file
if NOT EXIST %TY_EXPECTS_FILE% goto Err0
if NOT EXIST onetestc.bat goto Err3
if NOT EXIST %TY_CASES_DIR%\nul goto Err4
if NOT EXIST %TY_EXPECTS_DIR%\nul goto Err5
diff --version >nul
if ERRORLEVEL 1 goto Err6

REM set the runtime exe file
if NOT DEFINED TY_TIDY_PATH goto ERR7
set TIDY=%TY_TIDY_PATH%
if NOT EXIST %TIDY% goto ERR1

REM set the OUTPUT folder (will move later, if necessary)
set TIDYOUT=%TY_RESULTS_DIR%
set FINALOUT=%TY_RESULTS_DIR%

REM Allow user to specify a different output directory.
IF NOT "%~2" == "" (
    echo Will move final output to "%~2"
    set FINALOUT=%~2
)

REM Create output directory if necessary.
if EXIST %TIDYOUT%\nul goto GOTDIR
md %TIDYOUT%
if NOT EXIST %TIDYOUT%\nul goto Err2

:GOTDIR

set TMPTEST=%TY_RESULTS_FILE%
if EXIST %TMPTEST% del %TMPTEST%

echo Processing input test case list from %TY_CASES_DIR%
echo Each test will be passed to onetestc.bat for processing...

set ERRTESTS=
for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do call onetestc.bat %%i %%j
if "%ERRTESTS%." == "." goto DONE
echo ERROR TESTS [%ERRTESTS%] ...
:DONE
IF NOT "%TIDYOUT%" == "%FINALOUT%" (
    IF EXIST %TY_RESULTS_BASE_DIR%\%FINALOUT% goto WARNING1
    IF EXIST %TY_RESULTS_BASE_DIR%\%FINALOUT%.txt WARNING1
    echo Setting %TIDYOUT% to desired %FINALOUT%...
    RENAME %TIDYOUT% %FINALOUT%
    RENAME %TMPTEST% %FINALOUT%.txt
    set TMPTEST=%TY_RESULTS_BASE_DIR%\%FINALOUT%.txt
    )

echo Completed all test... full output written to %TMPTEST%
goto END

:ERR0
echo    ERROR: Can not locate 'testcases.txt' ... check name, and location ...
goto END
:ERR1
echo    ERROR: Can not locate %TIDY% ... check name, and location ...
goto END
:ERR2
echo    ERROR: Can not create %TIDYOUT% folder ... check name, and location ...
goto END
:ERR3
echo    ERROR: Can not locate 'onetest2.bat' ... check name, and location ...
goto END
:ERR4
echo    ERROR: Can not locate 'input' folder ... check name, and location ...
goto END
:ERR5
echo    ERROR: Can not locate 'testbase' folder ... check name, and location ...
goto END
:ERR6
echo    ERROR: Seem unable to run 'diff'! Either intall 'diff' in your path,
echo   or *** FIX ME *** to use a some other file compare untility.
goto END
:ERR7
echo    ERROR: You must define TY_TIDY_PATH, or specify the path as an argument ...
goto END

:WARNING1
echo    WARNING: You specified a directory name that already exists, so output
echo    will be in %TY_RESULTS_DIR% and %TY_RESULTS_FILE%.
GOTO:EOF


:USE
echo  Usage of ALLTESTC.BAT 
echo  AllTestC [tidy.exe [Out_Folder]]
echo  tidy.exe - This is the Tidy.exe you want to use for the test.
echo  Out_Folder  - This is the FOLDER where you want the results put,
echo  relative to the %TY_RESULTS_BASE_DIR% folder.
echo  This folder will be created if it does not already exist.
echo  These are both optional, but you must specify [tidy.exe] if you
echo  wish to specify [Out_Folder].
echo  ==================================
echo  ALLTESTC.BAT will run a battery of test files in the input folder.
echo  Each test name, has an expected result, given in its manifest.
echo  There will be a warning if any test file fails to give this result.
echo  ==================================
echo  But the main purpose is to compare the 'results' of two version of
echo  any two Tidy runtime exe's. Thus the NEW sets of results,
echo  will be compareed these two folders.
echo  Probably any file compare utility can be used, but here 'diff'
echo  is used.
echo  ................................................................
goto END

:END
