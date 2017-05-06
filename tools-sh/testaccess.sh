#!/usr/bin/env bash

#=================================================================
# testaccess.sh - execute all testcases for regression testing
#
# (c) 2005 (W3C) MIT, ERCIM, Keio University
# See tidy.c for the copyright notice.
#
# <URL:http://www.html-tidy.org/>
#=================================================================

# Change our set name for this test.
original_set="${TY_CASES_SETNAME}"
export TY_CASES_SETNAME="access"

DIR="$(readlink -e $(dirname $0))"

# setup the ENVIRONMENT
source "${DIR}/_environment.sh"
set_environment

# check critical inputs
test_results_base_dir || exit 1
test_tidy_path || exit 1


VERSION='${Id}'

if [ -f "${TY_RESULTS_FILE}" ]; then
    rm "${TY_RESULTS_FILE}"
fi

cat "${TY_EXPECTS_FILE}" | sed 1d | \
{
while read bugNo expected accessLevel
do
    "${DIR}/testaccessone.sh" "${bugNo}" "${expected}" "${accessLevel}" | tee -a "${TY_RESULTS_FILE}"
done
}

# Restore the original set name
export TY_CASES_SETNAME="${original_set}"
