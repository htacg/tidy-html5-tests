#!/usr/bin/env bash

#=================================================================
# testxml.sh - execute all XML testcases
#
# (c) 1998-2005 (W3C) MIT, ERCIM, Keio University
# See tidy.c for the copyright notice.
#
# <URL:http://www.html-tidy.org/>
#=================================================================

# Allow user-supplied Tidy via command line. Note that setting
# the TY_TIDY_PATH environment variable is a valid alternative.
if [ ! -z "$1" ]; then
    export TY_TIDY_PATH="$1"
fi

# setup the ENVIRONMENT
source "_environment.sh"
set_environment

# check critical inputs
test_results_dir || exit 1
test_tidy_path || exit 1


# Override the built-in cases for this test.
original_cases_dir="${TY_CASES_DIR}"
TY_CASES_DIR="${TY_CASES_BASE_DIR}/cases-xml"


VERSION='$Id'
BUGS="427837 431956 433604 433607 433670 434100\
 480406 480701 500236 503436 537604 616744 640474 646946"

while read bugNo expected
do
#  echo Testing $bugNo | tee -a testxml.log
  ./testone.sh "$bugNo" "$expected" "$@" | tee -a "${TY_LOG_FILE}"
  if test -f "${TY_RESULTS}/case-${bugNo}-result.html"
  then
    mv "${TY_RESULTS}/case-${bugNo}-result.html" "${TY_RESULTS}/case-${bugNo}-result.xml"
  fi
done < "${TY_CASES_BASE_DIR}/expects-xmlcases.txt"

TY_CASES_DIR="${original_cases_dir}"
