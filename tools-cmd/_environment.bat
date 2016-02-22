@echo off

rem # Setup a common environment for all batch scripts to use. This will ensure
rem # portability for all of the test scripts without having to figure out which
rem # items to always edit.

rem # This script is run at the start of all batch scripts; batch scripts can
rem # accept parameters to override these.


rem ###########################################################################
rem # Call our appropriate function.
rem #  Note: we're not going to take the Unix approach and embed too many
rem #  functions here. CMD doesn't have a source/include mechanism, and so
rem #  this file would be reloaded every time a function is called!
rem ###########################################################################
call %* 
exit /b


rem ###########################################################################
rem # Change these if necessary:
rem #   You should not call this function; it's used internally only.
rem ###########################################################################
:preset_environment

    rem # Relative path from this script to the top-level tidy-html5-tests directory.
    set TY_PROJECT_ROOT_DIR=..

    rem # These are all relative from the TY_PROJECT_ROOT_DIR directory.
    set TY_CASES_BASE_DIR=cases
    set TY_RESULTS_DIR=results

    rem # These are relative to the TY_CASES_BASE_DIR directory.
    set TY_CASES_DIR_tmp=cases-testbase
    set TY_LOG_FILE=results-log.txt
    set TY_RESULTS_FILE=results-results.txt
    set TY_TMP_DIR=tmp
    set TY_TMP_FILE=results-temp.txt

    rem # These are expected to be in cases_base_dir directory.
    set TY_EXPECTS_TESTBASE=expects-testbase.txt
    set TY_EXPECTS_ACCESS=expects-accesscases.txt
    set TY_EXPECTS_XML=expects-xmlcases.txt
    set TY_VERSION_FILE=version.txt

    rem # This file must exist in any test cases directory.
    set TY_CONFIG_DEFAULT=config_default.conf

GOTO:EOF

rem ###########################################################################
rem # Unset environment variables.
rem ###########################################################################
:unset_environment

    set TY_PROJECT_ROOT_DIR=
    set TY_CASES_BASE_DIR=
    set TY_RESULTS_DIR=
    set TY_CASES_DIR=
    set TY_LOG_FILE=
    set TY_RESULTS_FILE=
    set TY_TMP_DIR=
    set TY_TMP_FILE=
    set TY_EXPECTS_TESTBASE=
    set TY_EXPECTS_ACCESS=
    set TY_EXPECTS_XML=
    set TY_VERSION_FILE=
    set TY_CONFIG_DEFAULT=
    
GOTO:EOF


rem ###########################################################################
rem # Set environment variables.
rem ###########################################################################
:set_environment

    call :preset_environment

    rem # We'll use this to get the full, absolute path.
    pushd %TY_PROJECT_ROOT_DIR%
    set TY_PROJECT_ROOT_DIR=%CD%
    popd

    set TY_PROJECT_ROOT_DIR=%TY_PROJECT_ROOT_DIR%
    set TY_CASES_BASE_DIR=%TY_PROJECT_ROOT_DIR%\%TY_CASES_BASE_DIR%
    set TY_RESULTS_DIR=%TY_PROJECT_ROOT_DIR%\%TY_RESULTS_DIR%

    rem # *Only* set TY_CASES_DIR if it's not already set!
    IF NOT DEFINED TY_CASES_DIR (set TY_CASES_DIR=%TY_CASES_BASE_DIR%\%TY_CASES_DIR_tmp%)

    set TY_LOG_FILE=%TY_RESULTS_DIR%\%TY_LOG_FILE%
    set TY_RESULTS_FILE=%TY_RESULTS_DIR%\%TY_RESULTS_FILE%
    set TY_TMP_DIR=%TY_RESULTS_DIR%\%TY_TMP_DIR%
    set TY_TMP_FILE=%TY_RESULTS_DIR%\%TY_TEMP_DIR%\%TY_TMP_FILE%
    set TY_EXPECTS_TESTBASE=%TY_CASES_BASE_DIR%\%TY_EXPECTS_TESTBASE%
    set TY_EXPECTS_ACCESS=%TY_CASES_BASE_DIR%\%TY_EXPECTS_ACCESS%
    set TY_EXPECTS_XML=%TY_CASES_BASE_DIR%\%TY_EXPECTS_XML%
    set TY_VERSION_FILE=%TY_CASES_BASE_DIR%\%TY_VERSION_FILE%
    set TY_CONFIG_DEFAULT=%TY_CASES_DIR%\%TY_CONFIG_DEFAULT%

    set TY_CASES_DIR_tmp=

GOTO:EOF

rem ###########################################################################
rem # Print out the environment variables.
rem ###########################################################################
:report_environment

    echo TY_PROJECT_ROOT_DIR = %TY_PROJECT_ROOT_DIR%
    echo   TY_CASES_BASE_DIR = %TY_CASES_BASE_DIR%
    echo      TY_RESULTS_DIR = %TY_RESULTS_DIR%
    echo        TY_CASES_DIR = %TY_CASES_DIR%
    echo         TY_LOG_FILE = %TY_LOG_FILE%
    echo     TY_RESULTS_FILE = %TY_RESULTS_FILE%
    echo          TY_TMP_DIR = %TY_TMP_DIR%
    echo         TY_TMP_FILE = %TY_TMP_FILE%
    echo TY_EXPECTS_TESTBASE = %TY_EXPECTS_TESTBASE%
    echo   TY_EXPECTS_ACCESS = %TY_EXPECTS_ACCESS%
    echo      TY_EXPECTS_XML = %TY_EXPECTS_XML%
    echo     TY_VERSION_FILE = %TY_VERSION_FILE%
    echo   TY_CONFIG_DEFAULT = %TY_CONFIG_DEFAULT%
    echo        TY_TIDY_PATH = %TY_TIDY_PATH%

GOTO:EOF

