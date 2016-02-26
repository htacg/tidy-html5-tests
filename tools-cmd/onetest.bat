@echo off
setlocal enabledelayedexpansion

REM #======================================================================
REM # onetest.bat - execute a single test case
REM #
REM # (c) 1998-2006 (W3C) MIT, ERCIM, Keio University
REM # See tidy.c for the copyright notice.
REM #
REM # <URL:http://www.html-tidy.org/>
REM #
REM # used-by t1.bat, alltest.bat, xmltest.bat
REM #======================================================================


REM ------------------------------------------------
REM  Requirements checks
REM ------------------------------------------------
if "%TIDY%." == "." goto Err1
if NOT EXIST %TIDY% goto Err2
if "%TIDYOUT%." == "." goto Err3
if NOT EXIST %TIDYOUT%\nul goto Err4
if NOT EXIST %TY_CASES_DIR%\nul goto Err5
if "%TMPTEST%x" == "x" goto Err10

if "%1x" == "x" goto Err8
if "%2x" == "x" goto Err9

REM ------------------------------------------------
REM  Setup test parameters and files
REM ------------------------------------------------
set TESTNO=%1
set EXPECTED=%2

set INFILES==%TY_CASES_DIR%\case-%1.*ml
set CFGFILE=%TY_CASES_DIR%\case-%1.conf

set TIDYFILE=%TY_RESULTS_DIR%\case-%1.html
set MSGFILE=%TY_RESULTS_DIR%\case-%1.txt

IF NOT EXIST %TY_RESULTS_DIR% mkdir %TY_RESULTS_DIR%

set HTML_TIDY=

REM If no test specific config file, use default.
if NOT exist %CFGFILE% set CFGFILE=%TY_CONFIG_DEFAULT%

REM ------------------------------------------------
REM  Get specific input file names, and check them
REM ------------------------------------------------
set INFILE=
for %%F in ( %INFILES% ) do set INFILE=%%F 
if "%INFILE%." == "." goto Err6
if NOT EXIST %INFILE% goto Err7

REM ------------------------------------------------
REM  Remove any pre-exising test outputs
REM ------------------------------------------------
if exist %MSGFILE%  del %MSGFILE%
if exist %TIDYFILE% del %TIDYFILE%

REM ------------------------------------------------
REM  Begin tidying and testing
REM ------------------------------------------------
echo Doing: '%TIDY% -f %MSGFILE% -config %CFGFILE% %3 %4 %5 %6 %7 %8 %9 --tidy-mark no -o %TIDYFILE% %INFILE% >> %TMPTEST%

%TIDY% -f %MSGFILE% -config %CFGFILE% %3 %4 %5 %6 %7 %8 %9 --tidy-mark no -o %TIDYFILE% %INFILE%
set STATUS=%ERRORLEVEL%
echo Testing %1, expect %EXPECTED%, got %STATUS%, msg %MSGFILE%
echo Testing %1, expect %EXPECTED%, got %STATUS%, msg %MSGFILE% >> %TMPTEST%

if %STATUS% EQU %EXPECTED% goto done
set ERRTESTS=%ERRTESTS% %TESTNO%
echo *** Failed - got %STATUS%, expected %EXPECTED% ***
type %MSGFILE%
echo *** Failed - got %STATUS%, expected %EXPECTED% *** >> %TMPTEST%
type %MSGFILE% >> %TMPTEST%
goto done

REM ------------------------------------------------
REM  Messages and Exception Handlers
REM ------------------------------------------------
:Err1
echo ==============================================================
echo ERROR: runtime exe not set in TIDY environment variable ...
echo ==============================================================
goto TRYAT

:Err2
echo ==============================================================
echo ERROR: runtime exe %TIDY% not found ... check name, location ...
echo ==============================================================
goto TRYAT

:Err3
echo ==============================================================
echo ERROR: output folder TIDYOUT not set in environment ...
echo ==============================================================
goto TRYAT

:Err4
echo ==============================================================
echo ERROR: output folder %TIDYOUT% does not exist ...
echo ==============================================================
goto TRYAT

:Err5
echo ==============================================================
echo ERROR: input folder 'input' does not exist ... check name, location ..
echo ==============================================================
goto TRYAT

:TRYAT
echo Try running alltest.bat ..\build\cmake\Release\Tidy5.exe tmp
echo ==============================================================
pause
goto done

:Err6
echo ==============================================================
echo ERROR: Failed to find input matching '%INFILES%'!!!
echo ==============================================================
pause
goto done

:Err7
echo ==============================================================
echo ERROR: Failed to find input file '%INFILE%'!!!
echo ==============================================================
pause
goto done

:Err8
echo.
echo ERROR: No input test number given!
:Err9
echo ERROR: No expected exit value given!
echo.
goto done

:Err10
echo ERROR: TMPTEST not set in evironment!
echo.
goto done


:done
