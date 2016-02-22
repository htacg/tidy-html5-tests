#!/usr/bin/env bash

# Setup a common environment for all shell scripts to use. This will ensure
# portability for all of the test scripts without having to figure out which
# items to always edit.

# This script is sourced by all shell scripts; shell scripts can
# accept parameters to override these.


#############################################################################
# Ensure that we are sourced:
#############################################################################
if [ "`basename $0`" == "_environment.sh" ]; then
    echo "This file is meant to be sourced from within other scripts. Do not run it directly."
    exit
fi


#############################################################################
# Change these if necessary:
#############################################################################

# Relative path from this script to the top-level tidy-html5-tests directory.
project_root_dir=".."

# These are all relative from the project_root_dir directory.
cases_base_dir="cases"
results_base_dir="results"

# These are relative to the results_base_dir directory.
tmp_dir="tmp"

# These are expected to be in cases_base_dir directory.
version_file="version.txt"

# This file must exist in any test cases directory.
config_default="config_default.conf"

# The default cases set name
cases_setname="testbase"

#############################################################################
# Useful functions:
#############################################################################

unset_environment()
{
    unset TY_PROJECT_ROOT_DIR  # represents the project root.
    unset TY_CASES_BASE_DIR    # the top level cases directory.
    unset TY_CASES_DIR         # the specific cases- we are using.
    unset TY_EXPECTS_DIR       # the directory where expects files are.
    unset TY_EXPECTS_FILE      # the expects file with results table.
    unset TY_CONFIG_DEFAULT    # default config if none specified.
    unset TY_VERSION_FILE      # version of Tidy this repo represents.
    unset TY_RESULTS_BASE_DIR  # the top level results directory.
    unset TY_RESULTS_DIR       # the specific -results we are using.
    unset TY_RESULTS_FILE      # the file to write the log to.
    unset TY_TMP_DIR           # temporary directory for intermediate files.
    unset TY_TMP_FILE          # temporary filename to use.
    
    # TY_TIDY_PATH             # is required so we know which Tidy to use.
    # TY_CASES_SETNAME         # tells use which cases directory set to use.
}

set_environment()
{
    # We'll use this to get the full, absolute path.
    cwd=`pwd`
    cd "${project_root_dir}"
    project_root_dir="`pwd`"
    cd "${cwd}"
    
    # *Only* set TY_CASES_SETNAME if it's not already set!
    if [ -z "$TY_CASES_SETNAME" ]; then
        export TY_CASES_SETNAME="${cases_setname}"   
    fi
    
    export TY_PROJECT_ROOT_DIR="${project_root_dir}"
    export TY_CASES_BASE_DIR="${TY_PROJECT_ROOT_DIR}/${cases_base_dir}"
    export TY_CASES_DIR="${TY_CASES_BASE_DIR}/cases-${cases_setname}"
    export TY_EXPECTS_DIR="${TY_CASES_BASE_DIR}/cases-${cases_setname}-expects"
    export TY_EXPECTS_FILE="${TY_CASES_BASE_DIR}/cases-${cases_setname}-expects.txt"
    export TY_CONFIG_DEFAULT="${TY_CASES_DIR}/${config_default}"
    export TY_VERSION_FILE="${TY_CASES_BASE_DIR}/${version_file}"
    export TY_RESULTS_BASE_DIR="${TY_PROJECT_ROOT_DIR}/${results_base_dir}" 
    export TY_RESULTS_DIR="${TY_RESULTS_BASE_DIR}/cases-${cases_setname}-results"
    export TY_RESULTS_FILE="${TY_RESULTS_BASE_DIR}/cases-${cases_setname}-results.txt"
    export TY_TMP_DIR="${TY_RESULTS_BASE_DIR}/${tmp_dir}"
    export TY_TMP_FILE="${TY_TMP_DIR}/temp.txt"
}

report_environment()
{
    echo "TY_PROJECT_ROOT_DIR = $TY_PROJECT_ROOT_DIR"
    echo "  TY_CASES_BASE_DIR = $TY_CASES_BASE_DIR"
    echo "       TY_CASES_DIR = $TY_CASES_DIR"
    echo "     TY_EXPECTS_DIR = $TY_EXPECTS_DIR"
    echo "    TY_EXPECTS_FILE = $TY_EXPECTS_FILE"
    echo "  TY_CONFIG_DEFAULT = $TY_CONFIG_DEFAULT"
    echo "    TY_VERSION_FILE = $TY_VERSION_FILE"
    echo "TY_RESULTS_BASE_DIR = $TY_RESULTS_BASE_DIR"
    echo "     TY_RESULTS_DIR = $TY_RESULTS_DIR"
    echo "    TY_RESULTS_FILE = $TY_RESULTS_FILE"
    echo "         TY_TMP_DIR = $TY_TMP_DIR"
    echo "        TY_TMP_FILE = $TY_TMP_FILE"
    echo "       TY_TIDY_PATH = $TY_TIDY_PATH"
    echo "   TY_CASES_SETNAME = $TY_CASES_SETNAME"
}

report_testbase_version()
{
    read version < "${TY_VERSION_FILE}"
    echo "Testbase is for HTML Tidy version ${version}."
}

report_tidy_version()
{
    local version=$(${TY_TIDY_PATH} -v)
    if [ ! "$?" = "0" ]; then
        echo ""
        echo "$BN: ${TY_TIDY_PATH}"
        echo "$BN: Tidy was unable to run '${TY_TIDY_PATH} -v' successfully."
        echo ""
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi    
    echo $version
}

d_now()
{
    date +%Y%m%d%H%M%S
}

test_case_file()
{
    if [ ! -f "$1" ]; then
        echo ""
        echo "$BN: Case file: $1"
        echo "$BN: This case file was not found. Is the number correct?"
        echo ""
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
}
 
test_case_config()
{
    if [ ! -f "$1" ]; then
        echo ""
        echo "$BN: Config file: $1"
        echo "$BN: This configuration file was not found."
        echo ""
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
}

# Provide $1 = file to check
test_file_general()
{
    if [ ! -f "$1" ]; then
        echo ""
        echo "$BN: $1"
        echo "$BN: This file is needed but was not found."
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
}

# Provide $1 = expected file, $2 = case number.
test_file_expects()
{
    if [ ! -f "$1" ]; then
        echo ""
        echo "$BN: Expects file: $1"
        echo "$BN: This file is needed for the compare, but this may not be a problem."
        echo "$BN: Maybe there is no 'expects' file for test $1!"
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
}

# Provide $1 = expected file
test_file_output()
{
    if [ ! -f "$1" ]; then
        echo ""
        echo "$BN: Tidy output: $1"
        echo "$BN: This file is needed for the compare. It is strange this it was not created."
        echo "$BN: *** NEEDS CHECKING ***"
        echo ""
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
}

test_results_base_dir()
{
    if [ ! -d "${TY_RESULTS_BASE_DIR}" ]; then
        echo ""
        echo "$BN: ${TY_RESULTS_BASE_DIR}"
        echo "$BN: This results directory was not found; it must be created yourself."
        echo "$BN: This script does NOT create this directory."
        echo ""
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
}

test_tidy_path()
{
    if [ -z "${TY_TIDY_PATH+x}" ]; then
        echo ""
        echo "$BN: TY_TIDY_PATH is not set"
        echo "$BN: You must call this script with an argument pointing to an instance"
        echo "$BN: of HTML Tidy, or set the TY_TIDY_PATH environment variable to"
        echo "$BN: point to an instance of HTML Tidy."
        echo ""
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
    
    if [ ! -x "${TY_TIDY_PATH}" ]; then
        echo ""
        echo "$BN: ${TY_TIDY_PATH}"
        echo "$BN: This instance of Tidy was not found. Is it on your path?"
        echo ""
        ERROR_COUNT=$(($ERROR_COUNT + 1))
        return 1
    fi
}


#############################################################################
# main()
#############################################################################

# Because we're sourced, we can setup other convenience variables here, too.
BN="`basename $0`"
ERROR_COUNT=0
