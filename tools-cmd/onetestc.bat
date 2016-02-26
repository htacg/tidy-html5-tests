@echo off
setlocal enabledelayedexpansion

REM #======================================================================
REM # onetestc.bat - execute a single test case
REM #======================================================================


REM ------------------------------------------------
REM  Setup the ENVIRONMENT.
REM ------------------------------------------------
call _environment.bat :set_environment

REM ------------------------------------------------
REM  Requirements checks
REM ------------------------------------------------
if "%TY_TIDY_PATH%." == "." goto Err1
if NOT EXIST %TY_TIDY_PATH% goto Err2
if "%TY_RESULTS_DIR%." == "." goto Err3
if NOT EXIST %TY_RESULTS_DIR%\nul goto Err4
if NOT EXIST %TY_CASES_DIR%\nul goto Err5
if NOT EXIST %TY_EXPECTS_DIR%\nul goto Err8
if "%1x" == "x" goto Err9
if "%2x" == "x" goto Err10

REM ------------------------------------------------
REM  Setup parameters and files, and check them.
REM ------------------------------------------------
set TESTNO=%1
set EXPECTED=%2

set INFILES=%TY_CASES_DIR%\case-%1.*ml
set CFGFILE=%TY_CASES_DIR%\case-%1.conf

set TIDYFILE=%TY_RESULTS_DIR%\case-%1.html
set MSGFILE=%TY_RESULTS_DIR%\case-%1.txt

set TIDYBASE=%TY_EXPECTS_DIR%\case-%1.html

set HTML_TIDY=

if NOT exist %CFGFILE% set CFGFILE=%TY_CONFIG_DEFAULT%

REM ------------------------------------------------
REM  Get specific input file name.
REM ------------------------------------------------
set INFILE=
for %%F in ( %INFILES% ) do set INFILE=%%F 
if "%INFILE%." == "." goto Err6
if NOT EXIST %INFILE% goto Err7

REM ------------------------------------------------
REM Remove any pre-exising test outputs
REM ------------------------------------------------
if exist %MSGFILE%  del %MSGFILE%
if exist %TIDYFILE% del %TIDYFILE%

REM ------------------------------------------------
REM  Begin testing
REM ------------------------------------------------
echo Doing: '%TY_TIDY_PATH% -f %MSGFILE% -config %CFGFILE% %3 %4 %5 %6 %7 %8 %9 --tidy-mark no -o %TIDYFILE% %INFILE% >> %TY_RESULTS_FILE%

%TY_TIDY_PATH% -f %MSGFILE% -config %CFGFILE% %3 %4 %5 %6 %7 %8 %9 --tidy-mark no -o %TIDYFILE% %INFILE%

set STATUS=%ERRORLEVEL%
echo Testing %1, expect %EXPECTED%, got %STATUS%
echo Testing %1, expect %EXPECTED%, got %STATUS% >> %TY_RESULTS_FILE%

if %STATUS% EQU %EXPECTED% goto EXITOK

set ERRTESTS=%ERRTESTS% %TESTNO%
echo *** Failed - got %STATUS%, expected %EXPECTED% ***
type %MSGFILE%
echo *** Failed - got %STATUS%, expected %EXPECTED% *** >> %TY_RESULTS_FILE%
type %MSGFILE% >> %TY_RESULTS_FILE%

REM ------------------------------------------------
REM  Messages and Exception Handlers
REM ------------------------------------------------

:EXITOK
if NOT EXIST %TIDYBASE% goto NOBASE
if NOT EXIST %TIDYFILE% goto NOOUT
echo Doing: 'diff -u %TIDYBASE% %TIDYFILE%' >> %TY_RESULTS_FILE%
diff -u %TIDYBASE% %TIDYFILE% >> %TY_RESULTS_FILE%
if ERRORLEVEL 1 goto GOTDIFF
goto done

:GOTDIFF
echo Got a DIFFERENCE between %TIDYBASE% and %TIDYFILE% 
echo Got a DIFFERENCE between %TIDYBASE% and %TIDYFILE% >> %TY_RESULTS_FILE%
goto done

:NOBASE
REM If errorlevel 2 then normally no output generated, to this is OK
if "%STATUS%" == "2" goto done
REM If no output generated this time, then this is probably OK
if NOT EXIST %TIDYFILE% goto done
echo Can NOT locate %TIDYBASE%. This may be ok if not file generated
goto done

:NOOUT
echo *** FAILED: A base file exists, but none generated this time!
echo *** FAILED: A base file exists, but none generated this time! >> %TY_RESULTS_FILE%
goto done

:Err1
echo.
echo ERROR: runtime exe not set in TY_TIDY_PATH environment variable ...
echo.
goto TRYAT

:Err2
echo.
echo ERROR: runtime exe %TY_TIDY_PATH% not found ... check name, location ...
echo.
goto TRYAT

:Err3
echo.
echo ERROR: output folder TY_RESULTS_DIR not set in environment ...
echo.
goto TRYAT

:Err4
echo.
echo ERROR: output folder %TY_RESULTS_DIR% does not exist ...
echo.
goto TRYAT

:Err5
echo.
echo ERROR: input folder 'input' does not exist ... check name, location ..
echo.
goto TRYAT

:TRYAT
echo You could try running alltest1.bat ..\build\cmake\Release\Tidy5.exe tmp
echo but essentially this file should be run using the alltestc.bat batch file.
echo.
pause
goto done

:Err6
echo.
echo ERROR: Failed to find input matching '%INFILES%'!!!
echo.
pause
goto done

:Err7
echo.
echo ERROR: Failed to find input file '%INFILE%'!!!
echo.
pause
goto done

:Err8
echo.
echo ERROR: Failed to find 'testbase' folder!!!
echo.
pause
goto done

:Err9
echo.
echo ERROR: No input test number given as 1st parameter!
:Err10
echo ERROR: No expected exit value given as 2nd parameter!
echo.
echo Essentially this bat is intended to be used by alltestc.bat.,
echo It is not intended that this batch file be run in isolation,
echo even when TY_TIDY_PATH and TY_RESULTS_BASE_DIR have been set
echo in the environent.
echo.
goto done

:done
