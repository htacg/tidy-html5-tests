#!/usr/bin/env bash

#=================================================================
# testone.sh - execute a single testcase
#   Don't use this script directly. Use t1.sh, testall.sh, or testxml.sh,
#   instead, as they will setup the environment for proper testing.
#
# (c) 1998-2006 (W3C) MIT, ERCIM, Keio University
# See tidy.c for the copyright notice.
#
# <URL:http://www.html-tidy.org/>
#=================================================================


# If not enough parameters then abort.
if [ "$#" -ne 2 ]; then
    echo "Don't use this script directly. Use t1.sh, testall.sh, or testxml.sh."
    exit
fi

# setup the ENVIRONMENT
source "_environment.sh"
set_environment

# check critical inputs
test_results_base_dir || exit 1
test_tidy_path || exit 1

echo Testing $1
set +f # ensure wildcard expansion is on

TESTNO=$1
EXPECTED=$2

INFILES="${TY_CASES_DIR}/case-${TESTNO}.*ml"
CFGFILE="${TY_CASES_DIR}/case-${TESTNO}.conf"

TIDYFILE="${TY_RESULTS_DIR}/case-${TESTNO}.html"
MSGFILE="${TY_RESULTS_DIR}/case-${TESTNO}.txt"

# Remove any pre-exising test outputs
for INFIL in $MSGFILE $TIDYFILE
do
  if [ -f $INFIL ]
  then
    rm $INFIL
  fi
done

for INFILE in $INFILES
do
    if [ -r $INFILE ]
    then
      break
    fi
done

# If no test specific config file, use default.
if [ ! -f $CFGFILE ]
then
  CFGFILE="${TY_CONFIG_DEFAULT}"
fi

# Make sure output directories exist.
if [ ! -d "${TY_RESULTS_DIR}" ]; then
  mkdir -p "${TY_RESULTS_DIR}"
fi
if [ ! -d "${TY_TMP_DIR}" ]; then
  mkdir -p "${TY_TMP_DIR}"
fi


# Clear the first two input arguments.
unset HTML_TIDY
shift
shift

# Execute the test
echo "Doing: '${TY_TIDY_PATH} -f $MSGFILE -config $CFGFILE "$@" --tidy-mark no -o $TIDYFILE $INFILE'" >> "${TY_TMP_FILE}"
${TY_TIDY_PATH} -f $MSGFILE -config $CFGFILE "$@" --tidy-mark no -o $TIDYFILE $INFILE
STATUS=$?

if [ $STATUS -ne $EXPECTED ]
then
  echo "== $TESTNO failed (Status received: $STATUS vs expected: $EXPECTED)"
  echo ""
  cat $MSGFILE
  echo "== $TESTNO failed (Status received: $STATUS vs expected: $EXPECTED)" >> "${TY_TMP_FILE}"
  echo ""
  cat $MSGFILE >> "${TY_TMP_FILE}"
  exit 1
fi

exit 0

