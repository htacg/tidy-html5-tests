#!/usr/bin/env bash

#=================================================================
# testall.sh - execute all testcases for regression testing
#
# (c) 1998-2015 (W3C) MIT, ERCIM, Keio University
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
test_results_base_dir || exit 1
test_tidy_path || exit 1


TMPNOW=`d_now`
TMPINP="${TY_EXPECTS_FILE}"

test_file_general "testone.sh" || exit 1
test_file_general "$TMPINP" || exit 1


# count the tests
TMPCNT=0
while read bugNo expected
do
    TMPCNT=`expr $TMPCNT + 1`
done < $TMPINP

# output a header
if [ -f "${TY_RESULTS_FILE}" ]; then
	rm -f ${TY_RESULTS_FILE}
fi
echo "$BN: Will process $TMPCNT tests from $TMPINP on $TMPNOW"
echo "$BN: Will process $TMPCNT tests from $TMPINP on $TMPNOW" > "${TY_RESULTS_FILE}"
echo "$BN: Tidy version in use..." >> "${TY_RESULTS_FILE}"
version=$(report_tidy_version) || exit 1
echo ${version} >> "${TY_RESULTS_FILE}"
version=$(report_testbase_version)
echo ${version} >> "${TY_RESULTS_FILE}"


echo "========================================" >> "${TY_RESULTS_FILE}"
# do the tests
while read bugNo expected
do
#  echo Testing $bugNo | tee -a "${TY_RESULTS_FILE}"
  ./testone.sh $bugNo $expected | tee -a "${TY_RESULTS_FILE}"
done < $TMPINP
echo "========================================" >> "${TY_RESULTS_FILE}"

echo "$BN: Done $TMPCNT tests..." >> "${TY_RESULTS_FILE}"
echo "# eof"
echo "$BN: Done $TMPCNT tests - see ${TY_RESULTS_FILE}"


# eof

