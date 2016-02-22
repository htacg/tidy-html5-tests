#!/usr/bin/env bash

#=================================================================
# testaccess.sh - execute all testcases for regression testing
#
# (c) 2005 (W3C) MIT, ERCIM, Keio University
# See tidy.c for the copyright notice.
#
# <URL:http://www.html-tidy.org/>
#=================================================================

# setup the ENVIRONMENT
source "_environment.sh"
set_environment

# check critical inputs
test_results_dir || exit 1
test_tidy_path || exit 1


# Override the built-in cases for this test.
original_cases_dir="${TY_CASES_DIR}"
TY_CASES_DIR="${TY_CASES_BASE_DIR}/cases-access"

VERSION='$Id'

if [ -f "${TY_LOG_FILE}" ]; then
    rm "${TY_LOG_FILE}"
fi

cat "${TY_CASES_BASE_DIR}/expects-accesscases.txt" | sed 1d | \
{
while read bugNo expected
do
    ./testaccessone.sh $bugNo $expected "$@" | tee -a "${TY_LOG_FILE}"
done
}

TY_CASES_DIR="${original_cases_dir}"
