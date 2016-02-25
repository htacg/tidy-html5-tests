@echo off
setlocal enabledelayedexpansion

REM #======================================================================
REM # execute a single test case of the accessibility test suite
REM # 
REM # (c) 2006 (W3C) MIT, ERCIM, Keio University
REM # See tidy.c for the copyright notice.
REM # 
REM # <URL:http://www.html-tidy.org/>
REM #======================================================================

REM setup the ENVIRONMENT.
call _environment.bat :set_environment

echo Testing %1 %2 %3
set TESTNO=%1
set TESTEXPECTED=%2
set ACCESSLEVEL=%3
if "%1x" == "x" goto NOTEST
if "%2x" == "x" goto NOEXPECT
if "%3x" == "x" goto NOLEVEL
if "%TY_RESULTS_FILE%x" == "x" goto NOLOG

set INFILES=%TY_CASES_DIR%\case-%1.*ml
set CFGFILE=%TY_CASES_DIR%\case-%1.conf

set TIDYFILE=%TY_RESULTS_DIR%\case-%1.html
set MSGFILE=%TY_RESULTS_DIR%\case-%1.txt

set HTML_TIDY=

REM If no test specific config file, use default.
if NOT exist %CFGFILE% @set CFGFILE=%TY_CONFIG_DEFAULT%

REM Get specific input file name
for %%F in ( %INFILES% ) do @set INFILE=%%F

if EXIST %INFILE% goto DOIT
echo ERROR: Can NOT locate [%INFILE%] ... aborting test ...
echo ======================================= >>%TY_RESULTS_FILE%
echo Testing %1 %2 %3 >>%TY_RESULTS_FILE%
echo ERROR: Can NOT locate [%INFILE%] ... aborting test ... >>%TY_RESULTS_FILE%
goto done

:DOIT
REM Remove any pre-existing test outputs
if exist %MSGFILE%  del %MSGFILE%
if exist %TIDYFILE% del %TIDYFILE%

REM this has to all one line ...
%TY_TIDY_PATH% -f %MSGFILE% --accessibility-check %ACCESSLEVEL% -config %CFGFILE% --gnu-emacs yes --tidy-mark no -o %TIDYFILE% %INFILE%


REM Create temp directory if necessary.
if NOT EXIST %TY_TMP_DIR%\nul @md %TY_TMP_DIR%

REM output the FIND count to the a result file
find /c "%TESTEXPECTED%" %MSGFILE% > %TY_TMP_FILE%
REM load the find count, token 3, into variable RESULT
for /F "tokens=3" %%i in (%TY_TMP_FILE%) do @set RESULT=%%i
REM test the RESULT variable ...
if "%RESULT%." == "0." goto Err
if "%RESULT%." == "1." goto done
REM echo note - test '%TESTEXPECTED%' found %RESULT% times in file '%INFILE%'
goto done

:Err
echo FAILED --- test '%TESTEXPECTED%' not detected in file '%INFILE%'
type %MSGFILE%
echo FAILED --- test '%TESTEXPECTED%' not detected in above
set FAILEDACC=%FAILEDACC% %1
REM append results to the results file
echo ======================================= >>%TY_RESULTS_FILE%
echo %TY_TIDY_PATH% -f %MSGFILE% --accessibility-check %ACCESSLEVEL% -config %CFGFILE% --gnu-emacs yes --tidy-mark no -o %TIDYFILE% %INFILE% >>%TY_RESULTS_FILE%
echo FAILED --- test '%TESTEXPECTED%' not detected in file '%MSGFILE%', as follows - >>%TY_RESULTS_FILE%
type %MSGFILE% >>%TY_RESULTS_FILE%
echo FAILED --- test '%TESTEXPECTED%' not detected in above >>%TY_RESULTS_FILE%
goto done

:NOTEST
echo Error: NO test number given as the first command!
:NOEXPECT
echo Error: NO expected result given as the second command!
:NOLEVEL
echo Error: NO accesslevel given as the thrid command!
goto HELP

:NOLOG
echo.
echo Error: TY_RESULTS_FILE not set in the environment!!!

:HELP
echo The file acctest.bat should be used to run this batch...
echo Use Ctrl+c to abort, to fix...
pause
goto NOLOG

:done
