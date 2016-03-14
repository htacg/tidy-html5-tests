@echo off

rem ###########################################################################
rem ## This library sets common variables for *all* Tidy regression scripts
rem ## to use, as well as handles a common set of CLI parameters. In Windows
rem ## this script will reload each time it is called rather than being
rem ## included, so call judiciously.
rem ##
rem ## The batch language seems to automatically recognize = as being
rem ## argument/parameter separators, so -t=something and -t something will
rem ## both work.
rem ##
rem ## - TY_TIDY_PATH can be set in your environment, cli will override.
rem ## - TY_CASES_SETNAME can be set in your environment, cli will override.
rem ## - The output directory is based on the cases setname, unless overriden
rem ##   by the CLI here. It will be created automatically unless the env
rem ##   variable TY_MKDIR_CONFIRM is set to something.
rem ###########################################################################

IF "%1" == "" (
  echo.
  echo This is a library file that should not be run from the command line.
  echo It's used by most of the other scripts in this directory. Use those instead.
  echo.
  exit /b
 )

set TY_ERRORS=0
call %*
exit /b
GOTO:EOF

rem ###########################################################################
rem ## PRESET_ENVIRONMENT -- Change these if necessary!
rem ##   You should not call this function; it's used internally only.
rem ###########################################################################
:PRESET_ENVIRONMENT

    rem # Relative path from this script to the top-level tidy-html5-tests directory.
    set TY_PROJECT_ROOT_DIR=..

    rem # These are all relative from the TY_PROJECT_ROOT_DIR directory.
    set TY_CASES_BASE_DIR=cases
    set TY_RESULTS_BASE_DIR=cases

    rem # These are relative to the TY_CASES_BASE_DIR directory.
    set TY_TMP_DIR=_tmp

    rem # These are expected to be in cases_base_dir directory.
    set TY_VERSION_FILE=_version.txt

    rem # This file must exist in any test cases directory.
    set TY_CONFIG_DEFAULT=config_default.conf
    
    rem # The CLI cases set name, or the the default cases set name.
    IF "%TY_CASES_SETNAME_CLI%" == "" set TY_CASES_SETNAME_CLI=testbase

GOTO:EOF


rem ###########################################################################
rem ## UNSET_ENVIRONMENT
rem ##   Unset environment variables. You might want to use this to clean up
rem ##   your environment if your batch file is not using `setlocal`.
rem ###########################################################################
:UNSET_ENVIRONMENT

    set TY_PROJECT_ROOT_DIR=
    set TY_CASES_BASE_DIR=
    set TY_CASES_DIR=
    set TY_EXPECTS_DIR=
    set TY_EXPECTS_FILE=
    set TY_CONFIG_DEFAULT=
    set TY_VERSION_FILE=
    set TY_RESULTS_BASE_DIR=
    set TY_RESULTS_DIR=
    set TY_RESULTS_FILE=
    set TY_TMP_DIR=
    set TY_TMP_FILE=
    
    set TY_ERRORS=
    set TY_WANTS_HELP=
    set TY_RESULTS_DIR_CLI=
    set TY_CASES_SETNAME_CLI=
    
    rem # TY_TIDY_PATH
    rem # TY_CASES_SETNAME
    
GOTO:EOF


rem ###########################################################################
rem ## SET_ENVIRONMENT
rem ##   Set environment variables.
rem ###########################################################################
:SET_ENVIRONMENT

    call :preset_environment

    rem # We'll use this to get the full, absolute path.
    pushd %TY_PROJECT_ROOT_DIR%
    set TY_PROJECT_ROOT_DIR=%CD%
    popd
    
    rem # *Only* set TY_CASES_SETNAME if it's not already set! This allows
    rem # setting it via an environment variable.
    echo TY_CASES_SETNAME==%TY_CASES_SETNAME%
    echo TY_CASES_SETNAME_CLI==%TY_CASES_SETNAME_CLI%
    IF "%TY_CASES_SETNAME%" == "" set TY_CASES_SETNAME=%TY_CASES_SETNAME_CLI%

    set TY_PROJECT_ROOT_DIR=%TY_PROJECT_ROOT_DIR%
    set TY_CASES_BASE_DIR=%TY_PROJECT_ROOT_DIR%\%TY_CASES_BASE_DIR%
    set TY_CASES_DIR=%TY_CASES_BASE_DIR%\%TY_CASES_SETNAME%
    set TY_EXPECTS_DIR=%TY_CASES_BASE_DIR%\%TY_CASES_SETNAME%-expects
    set TY_EXPECTS_FILE=%TY_CASES_DIR%\_manifest.txt
    set TY_CONFIG_DEFAULT=%TY_CASES_DIR%\%TY_CONFIG_DEFAULT%
    set TY_VERSION_FILE=%TY_CASES_BASE_DIR%\%TY_VERSION_FILE%
    set TY_RESULTS_BASE_DIR=%TY_PROJECT_ROOT_DIR%\%TY_RESULTS_BASE_DIR%
    set TY_TMP_DIR=%TY_RESULTS_BASE_DIR%\%TY_TMP_DIR%
    set TY_TMP_FILE=%TY_TMP_DIR%\temp.txt

    rem # Set the default output directory and file...
    set TY_RESULTS_DIR=%TY_RESULTS_BASE_DIR%\%TY_CASES_SETNAME%-results
    set TY_RESULTS_FILE=%TY_RESULTS_BASE_DIR%\%TY_CASES_SETNAME%-results.txt

    rem # ...but if TY_RESULTS_DIR_CLI is defined, use that instead of the above.
    IF NOT "%TY_RESULTS_DIR_CLI%" == "" set TY_RESULTS_DIR=%TY_RESULTS_BASE_DIR%\%TY_RESULTS_DIR_CLI%-results
    IF NOT "%TY_RESULTS_DIR_CLI%" == "" set TY_RESULTS_FILE=%TY_RESULTS_BASE_DIR%\%TY_RESULTS_DIR_CLI%-results.txt

GOTO:EOF


rem ###########################################################################
rem ## REPORT_ENVIRONMENT
rem ##  Print out the environment variables.
rem ###########################################################################
:REPORT_ENVIRONMENT

    echo Standard:
    echo           TY_TIDY_PATH = %TY_TIDY_PATH%
    echo    TY_PROJECT_ROOT_DIR = %TY_PROJECT_ROOT_DIR%
    echo      TY_CASES_BASE_DIR = %TY_CASES_BASE_DIR%
    echo           TY_CASES_DIR = %TY_CASES_DIR%
    echo         TY_EXPECTS_DIR = %TY_EXPECTS_DIR%
    echo        TY_EXPECTS_FILE = %TY_EXPECTS_FILE%
    echo      TY_CONFIG_DEFAULT = %TY_CONFIG_DEFAULT%
    echo        TY_VERSION_FILE = %TY_VERSION_FILE%
    echo    TY_RESULTS_BASE_DIR = %TY_RESULTS_BASE_DIR%
    echo         TY_RESULTS_DIR = %TY_RESULTS_DIR%
    echo        TY_RESULTS_FILE = %TY_RESULTS_FILE%
    echo             TY_TMP_DIR = %TY_TMP_DIR%
    echo            TY_TMP_FILE = %TY_TMP_FILE%
    echo.
    echo Miscellaneous:
    echo          TY_WANTS_HELP = %TY_WANTS_HELP%
    echo     TY_RESULTS_DIR_CLI = %TY_RESULTS_DIR_CLI%
    echo   TY_CASES_SETNAME_CLI = %TY_CASES_SETNAME_CLI%
    echo              TY_ERRORS = %TY_ERRORS%
    echo           TY_INPUT_FMT =
    echo          TY_CONFIG_FMT =
    echo          TY_OUTPUT_FMT =
    echo           TY_ERROR_FMT =
    echo       TY_MKDIR_CONFIRM = %TY_MKDIR_CONFIRM%

GOTO:EOF


rem ###########################################################################
rem ## PROCESS_CLI
rem ###########################################################################
:PROCESS_CLI

  set proposed_argument=%~1

  rem # If there's nothing to process, then we're done.
  IF "%proposed_argument%" == "" GOTO :SET_ENVIRONMENT

  rem # Treat help specially because it has many potential forms.
  IF "%proposed_argument%" == "-h" GOTO :SET_WANTS_HELP
  IF "%proposed_argument%" == "/h" GOTO :SET_WANTS_HELP
  IF "%proposed_argument%" == "-?" GOTO :SET_WANTS_HELP
  IF "%proposed_argument%" == "/?" GOTO :SET_WANTS_HELP
  IF "%proposed_argument%" == "/help" GOTO :SET_WANTS_HELP
  IF "%proposed_argument%" == "--help" GOTO :SET_WANTS_HELP

  rem # At this point we're expecting a real argument and value.
  IF "%proposed_argument:~0,1%" == "/" GOTO :PROCESS_ARGUMENT
  IF "%proposed_argument:~0,1%" == "-" GOTO :PROCESS_ARGUMENT
  

  rem # If there was no argument, then something is wrong.
  GOTO ERROR_BAD_ARGUMENT

GOTO:EOF


rem ###########################################################################
rem ## PROCESS_ARGUMENT
rem ###########################################################################
:PROCESS_ARGUMENT

  set proposed_argument=%proposed_argument:~1%
  set proposed_parameter=%~2

  IF "%proposed_parameter%" == "" GOTO :ERROR_BAD_ARGUMENT
  IF "%proposed_parameter:~0,1%" == "/" GOTO :ERROR_BAD_ARGUMENT
  IF "%proposed_parameter:~0,1%" == "-" GOTO :ERROR_BAD_ARGUMENT

  rem # shift the input arguments for the next pass.
  shift
  shift
  
  rem # Go to the setters. We could assign the variables directly
  rem # here but the setters can do some additional sanity
  rem # checking before returning to PROCESS_CLI
  IF /I "%proposed_argument%" == "t" GOTO :SET_TIDY_PATH
  IF /I "%proposed_argument%" == "o" GOTO :SET_RESULTS_DIR
  IF /I "%proposed_argument%" == "c" GOTO :SET_SETNAME

  
  rem # At this point there must be an argument that's not specified
  rem # above, so warn the user.
  GOTO ERROR_BAD_ARGUMENT
  
GOTO:EOF


rem ###########################################################################
rem ## SET_TIDY_PATH
rem ##   Test and then set the Tidy path.
rem ###########################################################################
:SET_TIDY_PATH

  IF NOT EXIST "%proposed_parameter%" GOTO :ERROR_NO_EXE

  "%proposed_parameter%" -v > NUL
  if ERRORLEVEL 1 goto :ERROR_NOT_TIDY
  
  set TY_TIDY_PATH=%proposed_parameter%
  
GOTO PROCESS_CLI


rem ###########################################################################
rem ## SET_RESULTS_DIR
rem ###########################################################################
:SET_RESULTS_DIR
  echo SETTING RESULTS DIR
  set TY_RESULTS_DIR_CLI=%proposed_parameter%
  echo set to %TY_RESULTS_DIR_CLI%
GOTO PROCESS_CLI


rem ###########################################################################
rem ## SET_SETNAME
rem ###########################################################################
:SET_SETNAME
  set TY_CASES_SETNAME_CLI=%proposed_parameter%
GOTO PROCESS_CLI


rem ###########################################################################
rem ## SET_WANTS_HELP
rem ###########################################################################
:SET_WANTS_HELP
  set TY_WANTS_HELP=y
  shift
GOTO PROCESS_CLI


rem ###########################################################################
rem ## ERROR_BAD_ARGUMENT
rem ##   Increments the TY_ERRORS count, but returns to the caller.
rem ###########################################################################
:ERROR_BAD_ARGUMENT
  echo.
  echo Argument or Parameter Error
  echo Arguments must be specified with a leading / or -, and each argument
  echo must be followed by a parameter value that does not begin with / or -.
  echo.
  echo Valid arguments are:
  echo   -t path/to/tidy.exe
  echo   -o path/to/output/directory/
  echo   -c setname_to_test
  echo.
  echo Arguments can be specified in any order or omitted in which case the
  echo default values will be used. Note that the only default for the Tidy
  echo executable must be set in your TY_TIDY_PATH environment variable.
  echo.
  echo The current defaults are:
  echo     TY_TIDY_PATH = %TY_TIDY_PATH%
  echo   TY_RESULTS_DIR = %TY_RESULTS_DIR%
  echo TY_CASES_SETNAME = %TY_CASES_SETNAME%
  echo.
  rem # Let the calling script decide whether or not to abort.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_NO_EXE
rem ##   Increments the TY_ERRORS count, but returns to the caller.
rem ###########################################################################
:ERROR_NO_EXE
  echo.
  echo Tidy not Found Error
  echo You must specify a valid, full path to a Tidy executable. Tidy was not
  echo found at %proposed_parameter%.
  echo.
  rem # Let the calling script decide whether or not to abort.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_NOT_TIDY
rem ##   Increments the TY_ERRORS count, but returns to the caller.
rem ###########################################################################
:ERROR_NOT_TIDY
  echo.
  echo This Isn't Tidy Error
  echo The file you specified doesn't appear to be a valid Tidy. Specifically
  echo an error was returned when trying to check its version. Check the file
  echo %proposed_parameter%.
  echo.
  rem # Let the calling script decide whether or not to abort.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_OUTPUT_DIR_NOT_EXIST
rem ##   The output directory doesn't exist, so increment TY_ERRORS count,
rem ##   and return to the caller.
rem ###########################################################################
:ERROR_OUTPUT_DIR_NOT_EXIST
  echo.
  echo %TY_RESULTS_DIR%
  echo This directory doesn't exist but is required, and it couldn't be created.
  echo.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## CREATE_RESULTS_DIR
rem ##   Checks the existence of the TY_RESULTS_DIR, and creates it if not
rem ##   present. If TY_MKDIR_CONFIRM is set to any value in the environment,
rem ##   then permission to create the directory will be requested before
rem ##   creating the directory. Returns an error if directory is not created.
rem ###########################################################################
:CREATE_RESULTS_DIR

  set result=y
  set exists=true
  IF NOT EXIST "%TY_RESULTS_DIR%" set exists=false
  
  rem # Get confirmation if TY_MKDIR_CONFIRM is set.
  IF %exists%==false IF NOT %TY_MKDIR_CONFIRM% == "" echo The results output directory does not exist. Do you wish to create it now?
  IF %exists%==false IF NOT %TY_MKDIR_CONFIRM% == "" set /p result=Create %TY_RESULTS_DIR% [Y]/N?
  
  rem # IF we have implicit or explicit permission to make the directory:
  IF %exists%==false IF /i %result%==y echo Attempting to create %TY_RESULTS_DIR%...
  IF %exists%==false IF /i %result%==y MKDIR %TY_RESULTS_DIR%
  
  rem # cleanup in case we're not setlocal
  set result=
  set exists=
  
  rem # If the directory doesn't exist now, something really went wrong.
  IF NOT EXIST "%TY_RESULTS_DIR%" (
    call :ERROR_OUTPUT_DIR_NOT_EXIST
    exit /b 1
  )  
    
GOTO:EOF


