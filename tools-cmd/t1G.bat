@setlocal
@REM #======================================================================
@REM # A convenient run one test giving the number and expected exit.
@REM #
@REM # This is to run just one, like "t1 1642186-1 0 [tidy_path]"
@REM #
@REM # Note that you must specify as the third argument a path to tidy,
@REM # or alternatively set the TY_TIDY_PATH environment variable. In
@REM # addition the output folder has to exist.
@REM #
@REM # requires onetest.bat and _setenv.bat
@REM #======================================================================
@REM Uses onetest.bat and _setenv.bat
@set TY_ONETEST=onetestG.bat
@set TY_ENVBAT=_setenvG.bat

@if "%~1x" == "x" goto HELP
@if "%~2x" == "x" goto HELP
@REM ------------------------------------------------
@REM  Check for HELP, in many forms...
@REM ------------------------------------------------
@if /I "%1" == "/help" goto HELP
@if /I "%1" == "/h" goto HELP
@if "%1" == "/?" goto HELP
@if /I "%1" == "-h" goto HELP
@if /I "%1" == "--help" goto HELP
@if "%1" == "-?" goto HELP

@REM ------------------------------------------------
@REM  Allow user to specify a different Tidy.
@REM ------------------------------------------------
@IF "%~3x" == "x" goto DNCMD3
    @set TY_TIDY_PATH=%3
    @echo Set USER TY_TIDY_PATH=%TY_TIDY_PATH%
@REM  Allow user to specify a output/results folder.
@if "%~4x" == "x" goto DNCMD3
    @set TY_RESULTS_DIR=%4
    @set TY_RESULTS_FILE=%TY_RESULTS_DIR%-results.txt
    @echo Set USER TY_RESULTS_DIR=%TY_RESULTS_DIR%
    @echo Set USER TY_RESULTS_FILE=%TY_RESULTS_FILE%
:DNCMD3

@REM  Check we have a set 'environment' file
@if NOT EXIST %TY_ENVBAT% goto ERR1
@REM ------------------------------------------------
@REM  Setup the ENVIRONMENT.
@REM ------------------------------------------------
@call %TY_ENVBAT% :set_environment

@REM ------------------------------------------------
@REM  Requirements checks
@REM ------------------------------------------------
@if NOT EXIST %TY_RESULTS_BASE_DIR%\nul goto NOOUT
@if NOT DEFINED TY_TIDY_PATH goto SET_TY_TIDY_PATH
@if "%TY_TIDY_PATH%x" == "x" goto NOTP
@%TY_TIDY_PATH% -v >nul
@if ERRORLEVEL 1 goto NOEXE

@REM ------------------------------------------------
@REM  Setup our file names, and additional checks.
@REM ------------------------------------------------
@set TMPFIL=%TY_CASES_DIR%\case-%1.xhtml
@if NOT EXIST %TMPFIL% (
    @set TMPFIL=%TY_CASES_DIR%\case-%1.xml
)
@if NOT EXIST %TMPFIL% (
    @set TMPFIL=%TY_CASES_DIR%\case-%1.html
)
set TMPCFG=%TY_CASES_DIR%\case-%1.conf
@if NOT EXIST %TMPCFG% (
    @set TMPCFG=%TY_CONFIG_DEFAULT%
)

@if NOT EXIST %TMPFIL% goto NOFIL
@if NOT EXIST %TMPCFG% goto NOCFG

@REM ------------------------------------------------
@REM  Begin testing by ensuring tidy works, and
@REM  capture and check the expected output files.
@REM ------------------------------------------------
@echo Test 1 case %DATE% %TIME% > %TY_RESULTS_FILE%
@%TY_TIDY_PATH% -v >> %TY_RESULTS_FILE%
@if ERRORLEVEL 1 goto NOTIDY

@%TY_TIDY_PATH% -v
@echo.
@echo Doing 'call %TY_ONETEST% %1 %2'
@echo Doing 'call %TY_ONETEST% %1 %2' >> %TY_RESULTS_FILE%

@call %TY_ONETEST% %1 %2

@echo See ouput in %TY_RESULTS_FILE%

@diff -v > nul
@if ERRORLEVEL 1 goto NODIFF

set TMPFIL1=%TY_EXPECTS_DIR%\case-%1.html
set TMPOUT1=%TY_EXPECTS_DIR%\case-%1.txt
set TMPFIL2=%TY_RESULTS_DIR%\case-%1.html
set TMPOUT2=%TY_RESULTS_DIR%\case-%1.txt

@if NOT EXIST %TMPFIL1% goto NOFIL1
@if NOT EXIST %TMPFIL2% goto NOFIL1

@if NOT EXIST %TMPOUT1% goto NOFIL2
@if NOT EXIST %TMPOUT2% goto NOFIL2

@REM ------------------------------------------------
@REM  Compare the outputs, exactly
@REM ------------------------------------------------
@set TMPOPTS=-ua
@set ERRCNT=0

@echo.
@echo Doing: 'diff %TMPOPTS% %TMPFIL1% %TMPFIL2%'
@diff %TMPOPTS% %TMPFIL1% %TMPFIL2%
@if ERRORLEVEL 1 goto GOTD1
@echo Files appear exactly the same...
@goto DODIF2

:GOTD1
@call :ISDIFF
@set /A ERRCNT+=1

:DODIF2
@echo.
@echo Doing: 'diff %TMPOPTS% %TMPOUT1% %TMPOUT2%'
@diff %TMPOPTS% %TMPOUT1% %TMPOUT2%
if ERRORLEVEL 1 goto GOTD2
@echo Files appear exactly the same...
@goto DODIF3

:GOTD2
@call :ISDIFF
@set /A ERRCNT+=1

:DODIF3
@echo.
if "%ERRCNT%x" == "0x" (
    @echo Appears a successful test of %1 %2
) else (
    @echo Carefully REVIEW the above differences on %1 %2! *** ACTION REQUIRED ***
)

@goto END

:ISDIFF
@echo.
@echo Check the above diff carefully. This may indicate a 'testbase', or
@echo a 'regression' in tidy output.
@echo.
@goto :EOF

@REM ------------------------------------------------
@REM  Messages and Exception Handlers
@REM ------------------------------------------------

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

:SET_TY_TIDY_PATH
@echo.
@echo Error: You must set TY_TIDY_PATH! *** FIX ME ***
@echo.
@goto END

:NOTP
@echo.
@echo Error: TY_TIDY_PATH not set in environment!
@goto HELP

:ERR1
@echo ERROR: Can not locate '%TY_ENVBAT%'! Check name, and location ...
@goto END

:NOEXE
@echo.
@echo Error: Unable to locate file '%TY_TIDY_PATH%'! Has it been built? *** FIX ME ***
@echo.
@goto END

:NOTIDY
@echo.
@echo Error: Unable to run '%TY_TIDY_PATH% -v' successfully! *** FIX ME ***
@echo.
@@goto END

:NOOUT
@echo.
@echo Error: Can NOT locate %TY_RESULTS_BASE_DIR%! This MUST be created!
@echo This script does NOT create any directories...
@echo.
@goto END

:NOFIL
@echo.
dir input\*%1*
@echo.
@echo Error: Can NOT locate %TMPFIL%! Is number correct? 
@echo.
@goto END

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
@echo.
@goto END

:NOCFG
@echo.
@echo Error: Can NOT locate %TMPCFG%!
@echo.
@goto END

:HELP
@echo.
@echo - Usage: %0 "value" "expected exit value" [path to tidy]
@echo - That is give test number, and expected result, like
@echo - %0 1642186 1
@if "%~1x" == "x" goto HELPEND
@if NOT EXIST %TY_ENVBAT% goto HELPEND
@call %TY_ENVBAT% :set_environment
@echo - Missing expected value. See %TY_EXPECTS_FILE% for list available...
@echo - Checking %TY_EXPECTS_FILE% for test %1
@fa4 "%~1" %TY_EXPECTS_FILE%
@if ERRORLEVEL 1 goto HELP2
@echo Warning %1 not found in %TY_EXPECTS_FILE%
@type %TY_EXPECTS_FILE%
:HELP2
@echo Choose one of the above...
:HELPEND
@echo.
@goto END

:END

@REM EOF
