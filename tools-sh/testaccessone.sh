#!/usr/bin/env bash

#=================================================================
# execute a single testcase
#
# (c) 2005 (W3C) MIT, ERCIM, Keio University
# See tidy.c for the copyright notice.
#
# <URL:http://www.html-tidy.org/>
#=================================================================

# If not enough parameters then abort.
if [ "$#" -ne 3 ]; then
    echo "Don't use this script directly. Use testaccess.sh."
    exit
fi

# setup the ENVIRONMENT
source "_environment.sh"
set_environment

# check critical inputs
test_results_dir || exit 1
test_tidy_path || exit 1

VERSION='$Id'

echo Testing $1

set +f

TESTNO=$1
TESTEXPECTED=$2
ACCESSLEVEL=$3

INFILES="${TY_CASES_BASE_DIR}/cases-access/case-access_$1.*ml"
CFGFILE="${TY_CASES_BASE_DIR}/cases-access/case-access_$1.conf"

TIDYFILE="${TY_RESULTS_DIR}/case-$1-result.html"
MSGFILE="${TY_RESULTS_DIR}/case-$1-result.txt"

unset HTML_TIDY

shift
shift
shift

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

# Perform the testing
${TY_TIDY_PATH} -f $MSGFILE --accessibility-check $ACCESSLEVEL -config $CFGFILE "$@" --gnu-emacs yes --tidy-mark no -o $TIDYFILE $INFILE
STATUS=$?

if [ `grep -c -e ' \['$TESTEXPECTED'\]: ' $MSGFILE` = 0 ]
then
  echo "--- test '$TESTEXPECTED' not detected in file '$INFILE'"
  cat $MSGFILE
  exit 1
fi

exit 0

