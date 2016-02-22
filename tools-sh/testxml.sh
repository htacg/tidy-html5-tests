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

# Change our set name for this test.
original_set="$TY_CASES_SETNAME"
export TY_CASES_SETNAME="xml"

# setup the ENVIRONMENT
source "_environment.sh"
set_environment

# check critical inputs
test_results_base_dir || exit 1
test_tidy_path || exit 1


VERSION='$Id'
BUGS="427837 431956 433604 433607 433670 434100\
 480406 480701 500236 503436 537604 616744 640474 646946"

while read bugNo expected
do
#  echo Testing $bugNo | tee -a testxml.log
  ./testone.sh "$bugNo" "$expected" "$@" | tee -a "${TY_RESULTS_FILE}"
  if test -f "${TY_RESULTS_DIR}/case-${bugNo}.html"
  then
    mv "${TY_RESULTS_DIR}/case-${bugNo}.html" "${TY_RESULTS_DIR}/case-${bugNo}.xml"
  fi
done < "${TY_EXPECTS_FILE}"

# Restore the original set name
export TY_CASES_SETNAME="$original_set"
