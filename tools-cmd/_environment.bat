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
rem ##
rem ## To change DEFAULTS permanently, change them in :PRESET_ENVIRONMENT.
rem ## Otherwise it's best to use the CLI arguments or environment variables
rem ## for less persistent changes.
rem ##
rem ## If a script crashes and you pollute your environment, you can call this
rem ## script via `call _environment :UNSET_ENVIRONMENT` to clean it up easily.
rem ##
rem ## To use this with your own scripts, you'll want to :SET_ENVIRONMENT to
rem ## use the environment as it is, or :PROCESS_CLI if you want to process
rem ## CLI arguments (which also calls :SET_ENVIRONMENT). You can use
rem ## :REPORT_ENVIRONMENT for debugging purposes.
rem ###########################################################################

IF "%1" == "" (
  echo.
  echo This is a library file that should not be run from the command line.
  echo It's used by most of the other scripts in this directory. Use those instead.
  echo.
  exit /b
 )

set TY_WANTS_HELP=
set TY_ERRORS=0
call %*
exit /b
GOTO:EOF

rem ###########################################################################
rem ## PRESET_ENVIRONMENT -- Change these if necessary!
rem ##   You should not call this function; it's used internally only.
rem ###########################################################################
:PRESET_ENVIRONMENT

    rem # set a default relative path if none given
    if "%TY_TIDY_PATH%x" == "x" (
        rem # Relative path to a normal tidy windows build
        set TY_TIDY_PATH=..\..\tidy-html5\build\cmake\release\tidy.exe
    )

    rem # Relative path from this script to the top-level tidy-html5-tests directory.
    set TY_PROJECT_ROOT_DIR=..

    rem # These are all relative from the TY_PROJECT_ROOT_DIR directory.
    set TY_CASES_BASE_DIR=cases
    set TY_RESULTS_BASE_DIR=cases

    rem # Use 'standard windows TEMP directory, rather than creating a new one!
    set TY_TMP_DIR=%TEMP%

    rem # These are expected to be in cases_base_dir directory.
    set TY_VERSION_FILE=_version.txt

    rem # This file must exist in any test cases directory.
    set TY_CONFIG_DEFAULT=config_default.conf
    
    rem # The CLI cases set name, or the the default cases set name.
    set TY_CASES_SETNAME_DEFAULT=testbase
    
    rem # Supporting script filenames.
    set TY_ONETEST=_onetest.bat
    set TY_ONETESTA=_onetesta.bat

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
    set TY_CASES_SETNAME_DEFAULT=

    set TY_ONETEST=
    set TY_ONETESTA=

    rem # TY_TIDY_PATH
    rem # TY_CASES_SETNAME
    
GOTO:EOF


rem ###########################################################################
rem ## SET_ENVIRONMENT
rem ##   Set environment variables.
rem ###########################################################################
:SET_ENVIRONMENT

    call :preset_environment

    rem # Uncomment if you want the full, absolute path.
    rem pushd %TY_PROJECT_ROOT_DIR%
    rem set TY_PROJECT_ROOT_DIR=%CD%
    rem popd
    
    rem # TY_CASES_SETNAME - if set in the CLI, use it; otherwise use
    rem # use the TY_CASES_SETNAME ENV; finally use the default.
    IF NOT "%TY_CASES_SETNAME_CLI%" == "" set TY_CASES_SETNAME=%TY_CASES_SETNAME_CLI%
    IF "%TY_CASES_SETNAME%" == "" set TY_CASES_SETNAME=%TY_CASES_SETNAME_DEFAULT%

    set TY_PROJECT_ROOT_DIR=%TY_PROJECT_ROOT_DIR%
    set TY_CASES_BASE_DIR=%TY_PROJECT_ROOT_DIR%\%TY_CASES_BASE_DIR%
    set TY_CASES_DIR=%TY_CASES_BASE_DIR%\%TY_CASES_SETNAME%
    set TY_EXPECTS_DIR=%TY_CASES_BASE_DIR%\%TY_CASES_SETNAME%-expects
    set TY_EXPECTS_FILE=%TY_CASES_DIR%\_manifest.txt
    set TY_CONFIG_DEFAULT=%TY_CASES_DIR%\%TY_CONFIG_DEFAULT%
    set TY_VERSION_FILE=%TY_CASES_BASE_DIR%\%TY_VERSION_FILE%
    set TY_RESULTS_BASE_DIR=%TY_PROJECT_ROOT_DIR%\%TY_RESULTS_BASE_DIR%
    rem # set TY_TMP_DIR=%TY_RESULTS_BASE_DIR%\%TY_TMP_DIR%
    set TY_TMP_FILE=%TY_TMP_DIR%\temp.txt

    rem # Set the default output directory and file...
    set TY_RESULTS_DIR=%TY_RESULTS_BASE_DIR%\%TY_CASES_SETNAME%-results
    set TY_RESULTS_FILE=%TY_RESULTS_BASE_DIR%\%TY_CASES_SETNAME%-results.txt

    rem # ...but if TY_RESULTS_DIR_CLI is defined, use that instead of the above.
    IF NOT "%TY_RESULTS_DIR_CLI%" == "" set TY_RESULTS_DIR=%TY_RESULTS_BASE_DIR%\%TY_RESULTS_DIR_CLI%-results
    IF NOT "%TY_RESULTS_DIR_CLI%" == "" set TY_RESULTS_FILE=%TY_RESULTS_BASE_DIR%\%TY_RESULTS_DIR_CLI%-results.txt

    rem # cleanup in case we're not setlocal
    set TY_CASES_SETNAME_CLI=
    set TY_CASES_SETNAME_DEFAULT=
    set proposed_argument=
    set proposed_parameter=
    
    rem # Let's test the environment, too.
    call :TEST_ENVIRONMENT
    
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

  rem IF NOT EXIST "%proposed_parameter%" GOTO :ERROR_NO_EXE

  "%proposed_parameter%" -v > NUL
  IF ERRORLEVEL 1 goto :ERROR_NOT_TIDY
  
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
rem ## TEST_ENVIRONMENT
rem ##   Pre-checks many of the items in the environment that testing scripts
rem ##   will depend on. Failing checks will return from this script with an
rem ##   error.
rem ###########################################################################
:TEST_ENVIRONMENT

  rem # Ensure that the workhorse scripts are both present.
  IF NOT EXIST "%TY_ONETEST%" call :ERROR_MISSING_FILE "%TY_ONETEST%"
  IF NOT EXIST "%TY_ONETESTA%" call :ERROR_MISSING_FILE "%TY_ONETESTA%"

  rem # Ensure that Tidy path leads to something and provides output.
  rem # If specified in CLI it was already checked and this is redundant,
  rem # however we still check because we may not have been set via CLI.
  IF "%TY_TIDY_PATH%" == "" call :ERROR_NO_TIDY_PATH
  rem # IF NOT EXIST "%TY_TIDY_PATH%" call :ERROR_NO_EXE_ERROR
  "%TY_TIDY_PATH%" -v > NUL
  IF ERRORLEVEL 1 call :ERROR_NOT_TIDY_ERROR
  
  rem # Ensure that diff is installed and responsive.
  diff -v > NUL
  IF ERRORLEVEL 1 call :ERROR_DIFF_NOT_INSTALLED
  
  rem # Ensure that important directories exist
  IF NOT EXIST "%TY_CASES_DIR%\" call :ERROR_DIR_NOT_EXIST "%TY_CASES_DIR%"
  IF NOT EXIST "%TY_RESULTS_BASE_DIR%\" call :ERROR_OUTPUT_BASEDIR_NOT_EXIST
  
  rem # Don't do this if user only requested help. The other messages are
  rem # diagnostic in nature and do help the user, but we shouldn't be
  rem # potentially creating files.
  IF NOT EXIST "%TY_RESULTS_DIR%" IF "%TY_WANTS_HELP%" == "" call :CREATE_RESULTS_DIR
  
  rem # Ensure the manifest file is present. This isn't needed by t1.bat
  rem # because we already provide the expected output; however we'll check
  rem # it anyway because it's probably not being used in isolation but as
  rem # part of the greater test suite.
  IF NOT EXIST %TY_EXPECTS_FILE% call :ERROR_MISSING_FILE "%TY_EXPECTS_FILE%"
  
  rem # Exit if there are errors; caller should check error status and act.
  IF %TY_ERRORS% GTR 0 exit /b 1

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
  IF %exists% == false IF NOT "%TY_MKDIR_CONFIRM%" == "" echo The results output directory does not exist. Do you wish to create it now?
  IF %exists% == false IF NOT "%TY_MKDIR_CONFIRM%" == "" set /p result=Create %TY_RESULTS_DIR% [Y]/N?
  
  rem # IF we have implicit or explicit permission to make the directory:
  IF %exists% == false IF /i %result% == y echo Attempting to create %TY_RESULTS_DIR%...
  IF %exists% == false IF /i %result% == y MKDIR %TY_RESULTS_DIR%
  
  rem # cleanup in case we're not setlocal
  set result=
  set exists=
  
  rem # If the directory doesn't exist now, something really went wrong.
  IF NOT EXIST "%TY_RESULTS_DIR%" (
    call :ERROR_OUTPUT_DIR_NOT_EXIST
    exit /b 1
  )  
    
GOTO:EOF


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
rem ## ERROR_DIFF_NOT_INSTALLED
rem ##   Increments the TY_ERRORS count, but returns to the caller.
rem ###########################################################################
:ERROR_DIFF_NOT_INSTALLED
  echo.
  echo diff not installed
  echo diff is required for these tests but it's not responding. Is it in your
  echo PATH? Is it installed?
  echo.
  rem # Let the calling script decide whether or not to abort.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_MISSING_FILE
rem ##   Indicates that %1 is missing, and exits with an error.
rem ###########################################################################
:ERROR_MISSING_FILE
  echo.
  echo %1 not found
  echo This file is required in order to conduct regression testing! Check the
  echo name, location, etc.
  echo.
  exit /b 1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_NO_EXE / ERROR_NO_EXE_ERROR
rem ##   Increments the TY_ERRORS count, but returns to the caller.
rem ###########################################################################
:ERROR_NO_EXE
  call :ERROR_NO_EXE_ERROR %proposed_parameter%
GOTO:EOF

:ERROR_NO_EXE_ERROR
  echo.
  echo Tidy not Found Error
  echo You must specify a valid, full path to a Tidy executable. Tidy was not
  echo found at %1.
  echo.
  rem # Let the calling script decide whether or not to abort.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_NO_TIDY_PATH
rem ##   Increments the TY_ERRORS count, but returns to the caller.
rem ###########################################################################
:ERROR_NO_TIDY_PATH
  echo.
  echo TY_TIDY_PATH not set.
  echo You must specify a valid, full path to a Tidy executable, either by
  echo setting the TY_TIDY_PATH environment variable yourself, or by specifying
  echo the path to Tidy using the `-t` argument.
  echo.
  rem # Let the calling script decide whether or not to abort.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_NOT_TIDY / ERROR_NOT_TIDY_ERROR
rem ##   Increments the TY_ERRORS count, but returns to the caller.
rem ###########################################################################
:ERROR_NOT_TIDY
  call :ERROR_NOT_TIDY_ERROR %proposed_parameter%
GOTO:EOF

:ERROR_NOT_TIDY_ERROR
  echo.
  echo This Isn't Tidy Error
  echo The file you specified doesn't appear to be a valid Tidy. Specifically
  echo an error was returned when trying to check its version. Check the file
  echo %1.
  echo.
  rem # Let the calling script decide whether or not to abort.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF


rem ###########################################################################
rem ## ERROR_DIR_NOT_EXIST
rem ##   The directory doesn't exist, so increment TY_ERRORS count,
rem ##   and return to the caller.
rem ###########################################################################
:ERROR_DIR_NOT_EXIST
  echo.
  echo %1
  echo This directory doesn't exist but is required. Please check it.
  echo.
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
rem ## ERROR_OUTPUT_BASEDIR_NOT_EXIST
rem ##   The output base directory doesn't exist, so increment TY_ERRORS count,
rem ##   and return to the caller.
rem ###########################################################################
:ERROR_OUTPUT_BASEDIR_NOT_EXIST
  echo.
  echo %TY_RESULTS_BASE_DIR%
  echo This directory doesn't exist but is required. It's an integral part of
  echo the testing suite and it's strange that doesn't exist. In any case, you
  echo will have to create this directory yourself.
  echo.
  set /a TY_ERRORS=TY_ERRORS+1
GOTO:EOF



