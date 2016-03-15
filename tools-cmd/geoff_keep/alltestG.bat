@setlocal
@REM alltest.bat - execute all test cases
@REM Uses onetest.bat and _setenv.bat
@set TY_ONETEST=onetestG.bat
@set TY_ENVBAT=_setenvG.bat

@REM ------------------------------------------------
@REM  Check for HELP, in many forms...
@REM ------------------------------------------------
@if /I "%1" == "/help" goto USE
@if /I "%1" == "/h" goto USE
@if "%1" == "/?" goto USE
@if /I "%1" == "-h" goto USE
@if /I "%1" == "--help" goto USE
@if "%1" == "-?" goto USE

@REM ########################################################
@REM ### *** SET LOCATION OF TIDY EXE TO USE FOR TEST *** ###
@REM ########################################################
@REM ------------------------------------------------
@REM  Allow user to specify a different Tidy.
@REM ------------------------------------------------
@if "%~1x" == "x" goto DNCMD
    @set TY_TIDY_PATH=%~1
    @echo Set USER TY_TIDY_PATH=%TY_TIDY_PATH%
@REM  Allow user to specify a output/results folder.
@if "%~2x" == "x" goto DNCMD
    @set TY_RESULTS_DIR=%~2
    @set TY_RESULTS_FILE=%TY_RESULTS_DIR%-results.txt
    @echo Set USER TY_RESULTS_DIR=%TY_RESULTS_DIR%
    @echo Set USER TY_RESULTS_FILE=%TY_RESULTS_FILE%
:DNCMD

@REM  Check we have a set 'environment' file
@if NOT EXIST %TY_ENVBAT% goto ERR1
@REM ------------------------------------------------
@REM  Setup the ENVIRONMENT.
@REM ------------------------------------------------
@call %TY_ENVBAT% :set_environment
@REM  Show the established environment
@call %TY_ENVBAT% :report_environment

@REM ------------------------------------------------
@REM  Requirements checks
@REM ------------------------------------------------
@if NOT EXIST %TY_EXPECTS_FILE% goto ERR0
@if NOT EXIST %TY_ONETEST% goto ERR3
@if NOT EXIST %TY_CASES_DIR%\nul goto ERR4
@if NOT EXIST %TY_VERSION_FILE% goto ERR7
@set /p TY_TEST_VERS=< %TY_VERSION_FILE%

@if NOT EXIST %TY_RESULTS_BASE_DIR%\nul md %TY_RESULTS_BASE_DIR%
@if NOT EXIST %TY_RESULTS_BASE_DIR%\nul goto ERR2

@if "%TY_TIDY_PATH%x" == "x" goto NOTP
%TY_TIDY_PATH% -v
@if ERRORLEVEL 1 goto NOEXE

@set TMPCNT=0
@for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do set /A TMPCNT+=1
@if "%TMPCNT%x" == "0x" goto NOTESTS

@REM Show and pause for 10 seconds...
@echo.
@if EXIST %TY_RESULTS_DIR%\nul (
    @echo Note OUTPUT directory %TY_RESULTS_DIR% aleady exists, and will be overwritten!
) else (
    @echo Note OUTPUT directory %TY_RESULTS_DIR% does not exist, and will be created!
)
@echo.
@echo CHECK: Is this the correct version of tidy you want to use?
@echo The current test version file %TY_VERSION_FILE% shows %TY_TEST_VERS%
@echo Will perform %TMPCNT% different tests...
@echo.
@choice /D Y /T 10 /M "Pausing for 10 seconds. Def=Y"
@if ERRORLEVEL 2 goto GOTNO

@REM ------------------------------------------------
@REM  Setup the report header
@REM ------------------------------------------------
@echo =============================== > %TY_RESULTS_FILE%
@echo Date %DATE% %TIME% >> %TY_RESULTS_FILE%
@echo Tidy EXE %TY_TIDY_PATH%, version >> %TY_RESULTS_FILE%
%TY_TIDY_PATH% -v >> %TY_RESULTS_FILE%
@echo Input list of %TMPCNT% tests from '%TY_EXPECTS_FILE%' file >> %TY_RESULTS_FILE%
@echo Outut will be to the '%TY_RESULTS_DIR%' folder >> %TY_RESULTS_FILE%
@echo =============================== >> %TY_RESULTS_FILE%
@echo.
@echo Doing %TMPCNT% tests from '%TY_EXPECTS_FILE%' file...
@echo.
@REM ------------------------------------------------
@REM  Perform the testing
@REM ------------------------------------------------
@set ERRTESTS=
@for /F "tokens=1*" %%i in (%TY_EXPECTS_FILE%) do @call %TY_ONETEST% %%i %%j

@REM ------------------------------------------------
@REM  Output failing test information
@REM ------------------------------------------------
@echo =============================== >> %TY_RESULTS_FILE%
@if "%ERRTESTS%." == "." goto NOERRS
@echo ERROR TESTS [%ERRTESTS%] ... FAILED TEST 1!
@echo ERROR TESTS [%ERRTESTS%] ... FAILED TEST 1! >> %TY_RESULTS_FILE%
@echo.
@echo Appears there are changes in the exit value for %TMPCNT% tests - FAILED 1
@echo Appears there are changes in the exit value for %TMPCNT% tests - FAILED 1 >> %TY_RESULTS_FILE%
@goto DONE1
:NOERRS
@echo.
@echo Appears there are no changes in the exit value for %TMPCNT% tests - SUCCESS 1
@echo Appears there are no changes in the exit value for %TMPCNT% tests - SUCCESS 1 >> %TY_RESULTS_FILE%

:DONE1
@REM ------------------------------------------------
@REM  Final testing report
@REM ------------------------------------------------
@diff -v > nul
@if ERRORLEVEL 1 goto NODIFF
@echo.
@echo Running 'diff -ua %TY_EXPECTS_DIR% %TY_RESULTS_DIR%'
@echo Running 'diff -ua %TY_EXPECTS_DIR% %TY_RESULTS_DIR%' >> %TY_RESULTS_FILE%
@echo =============================== >> %TY_RESULTS_FILE%
@diff -ua %TY_EXPECTS_DIR% %TY_RESULTS_DIR% >> %TY_RESULTS_FILE%
@if ERRORLEVEL 1 goto GOTDIF
@echo =============================== >> %TY_RESULTS_FILE%
@echo.
@echo Appears there are no changes in the output files for %TMPCNT% tests - SUCCESS 2
@echo Appears there are no changes in the output files for %TMPCNT% tests - SUCCESS 2 >> %TY_RESULTS_FILE%
@echo.
@goto DONE
:GOTDIF
@echo =============================== >> %TY_RESULTS_FILE%
@echo.
@echo Appear to have differences in some output files for %TMPCNT% tests - FAILED 2
@echo Appear to have differences in some output files for %TMPCNT% tests - FAILED 2 >> %TY_RESULTS_FILE%
@echo These results must be carefully checked in %TY_RESULTS_FILE%!
@echo.
@goto DONE
:NODIFF
@echo.
@echo Unable to run 'diff' in your environment! 
@echo Do you have a WIN32 port of GNU diff.exe from http://unxutils.sourceforge.net/
@echo Or use an alternative app to compare folders %TY_EXPECTS_DIR% %TY_RESULTS_DIR% ... 
@echo This is needed as the final compare to complete the tests...
@echo.
@echo Unable to run 'diff' in your environment!  >> %TY_RESULTS_FILE%
@echo Do you have a WIN32 port of GNU diff.exe from http://unxutils.sourceforge.net/  >> %TY_RESULTS_FILE%
@echo Or use an alternative app to compare folder %TY_EXPECTS_DIR% %TY_RESULTS_DIR% ...  >> %TY_RESULTS_FILE%
@echo This is needed as the final compare to complete the tests...  >> %TY_RESULTS_FILE%
:DONE
@echo End %DATE% %TIME% >> %TY_RESULTS_FILE%
@echo =============================== >> %TY_RESULTS_FILE%
@echo See %TY_RESULTS_FILE% for full test details...
echo.
@goto END

@REM ------------------------------------------------------------
@REM Errors encountered
@REM ------------------------------------------------------------

:ERR0
@echo ERROR: Can not locate '%TY_EXPECTS_FILE%'! Check name, and location ...
@goto END

:ERR1
@echo ERROR: Can not locate '%TY_ENVBAT%'! Check name, and location ...
@goto END

:ERR2
echo ERROR: Can not create %TY_RESULTS_BASE_DIR% folder! Check name, and location ...
goto END

:ERR3
@echo ERROR: Can not locate '%TY_ONETEST%'! Check name, and location ...
@goto END

:ERR4
@echo ERROR: Can not locate '%TY_CASES_DIR%' folder! Check name, and location ...
@goto END

:ERR7
@echo ERROR: Can NOT locate file %TY_VERSION_FILE%! Check name, location...
@goto END

:NOTP
@echo.
@echo Error: TY_TIDY_PATH not set in environment!
@goto USE2

:NOEXE
@echo.
@echo Error: Can NOT run %TY_TIDY_PATH%! Has it been built? Check location, name
@echo *** FIX ME *** adding the location of the tidy EXE to use for the test.
@echo The current test version file %TY_VERSION_FILE% shows %TY_TEST_VERS%!
@echo.
@goto END

:NOTESTS
@echo UGH: Got no tests from %TY_EXPECTS_FILE%! Check file...
@goto END

:USE
@REM  Establish DEFAULT environment
@call %TY_ENVBAT% :set_environment
@REM  Show the established environment
@echo.
@echo Display of the default setup environment -
@call %TY_ENVBAT% :report_environment
:USE2
@echo.
@echo  Usage of ALLTEST.BAT
@echo  AllTest [tidy.exe [Out_Folder]]
@echo  tidy.exe    - This is the Tidy.exe you want to use for the test.
@echo  Out_Folder  - This is the FOLDER where you want the results put.
@echo  This folder will be created if it does not already exist.
@echo  These are both optional, but you must specify [tidy.exe] if you
@echo  wish to specify an [Out_Folder] different to the default.
@echo  Test 1 ==================================
@echo  ALLTEST.BAT will run a battery of test files in the input folder
@echo  Each test name, has an expected exit value, given in its table.
@echo  There will be a warning if any test file fails to give this value.
@echo   Test 2 ==================================
@echo  But the main purpose is to compare the 'results' of two version of
@echo  any two Tidy runtime exe's. Thus after you have two sets of results,
@echo  in separate folders, the idea is to compare these two folders.
@echo  By default diff.exe will be used, if it is available in your PATH.
@echo  If not any directory compare utility will do, or you can download, and use
@echo  a WIN32 port of GNU diff.exe from http://unxutils.sourceforge.net/
@echo  ................................................................
@echo.
@goto END



:GOTNO
@echo Got choice No... aborted testing...
:END
@REM EOF
