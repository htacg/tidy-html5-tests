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
if [ -z "$1" ]; then
    export TY_TIDY_PATH="../../tidy-html5/build/cmake/tidy"
else
    export TY_TIDY_PATH="$1"
fi

# Change our set name for this test.
original_set="$TY_CASES_SETNAME"
export TY_CASES_SETNAME="special"

# setup the ENVIRONMENT
source "_environment.sh"
set_environment
# report_environment

# check critical inputs
test_results_base_dir || exit 1
test_tidy_path || exit 1

if [ -f "$TY_RESULTS_FILE" ]; then
    rm -fv $TY_RESULTS_FILE
fi

while read bugNo expected
do
  # echo "Testing $bugNo $expected"
  ./testone.sh "$bugNo" "$expected" | tee -a "${TY_RESULTS_FILE}"
done < "${TY_EXPECTS_FILE}"

echo "$BN: Running 'diff -ua $TY_EXPECTS_DIR $TY_RESULTS_DIR'"
echo "$BN: Running 'diff -ua $TY_EXPECTS_DIR $TY_RESULTS_DIR'" >> "${TY_RESULTS_FILE}"
echo "======================================================" >> "${TY_RESULTS_FILE}"
diff -ua "$TY_EXPECTS_DIR" "$TY_RESULTS_DIR" >> "${TY_RESULTS_FILE}"
if [ "$?" = "0" ]; then
	echo "======================================================" >> "${TY_RESULTS_FILE}"
	echo "$BN: Appear to have PASSED test 2"
	echo "$BN: Appear to have PASSED test 2" >> "${TY_RESULTS_FILE}"
else
	echo "======================================================" >> "${TY_RESULTS_FILE}"
	echo "$BN: Appears test 2 FAILED!"
	echo "$BN: Appears test 2 FAILED!" >> "${TY_RESULTS_FILE}"
fi
echo "$BN: See full results in $TY_RESULTS_FILE"

# Restore the original set name
export TY_CASES_SETNAME="$original_set"

# eof

