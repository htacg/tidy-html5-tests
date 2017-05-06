#!/usr/bin/env bash

#=================================================================
# A convenient run one test giving the number and expected exit
# 
# This is to run just one, like "./t1.sh 1642186-1 0"
# By default ${TY_TIDY_PATH} will be used. To use another, specify
# the path to a different tidy as the third argument, e.g.,
# "./t1.sh 1642186-1 0 path/to/tidy"
# 
# Note it expects the ouput folder already exists.
#=================================================================

# Allow user-supplied Tidy via command line. Note that setting
# the TY_TIDY_PATH environment variable is a valid alternative.
if [ ! -z "$3" ]; then
    export TY_TIDY_PATH="$3"
fi

DIR="$(readlink -e $(dirname $0))"

# setup the ENVIRONMENT
source "${DIR}/_environment.sh"
set_environment

# check critical inputs
test_results_base_dir
test_tidy_path

if [ "${ERROR_COUNT}" -gt 0 ]; then
    echo ""
    echo "${BN}: Aborted. Please resolve the ${ERROR_COUNT} error(s), above."
    echo ""
    exit 1
fi

give_help()
{
    echo ""
    echo "Usage: $0 <value> <expected_exit_value> [path/to/tidy]"
    echo "  That is give test number, and expected result, like"
    echo "  $0 1642186 1"
    echo "  See testcases.txt for a list of available cases."
    echo ""
    echo "Tidy: ${TY_TIDY_PATH}"
    echo "  Optionally specify [path/to/tidy] as third argument, or set"
    echo "  the TY_TIDY_PATH environment variable in order to override."
    echo ""
    echo "Cases: ${TY_CASES_DIR}."
    echo "Results: ${TY_RESULTS_DIR}."
    echo "  Set the TY_CASES_SETNAME environment variable in order to override."  
    echo ""
}

# Check user input
TMPCASE="$1"
TMPEXIT="$2"
TMPNOW=`d_now`

if [ -z "${TMPCASE}" ]; then
    give_help
    exit 1
fi    
if [ -z "${TMPEXIT}" ]; then
    give_help
    exit 1
fi

# Find our case file and its config file, and verify them.
TMPFIL="${TY_CASES_DIR}/case-${TMPCASE}.xhtml"
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_CASES_DIR}/case-${TMPCASE}.xml"
fi
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_CASES_DIR}/case-${TMPCASE}.html"
fi
TMPCFG="${TY_CASES_DIR}/case-${TMPCASE}.conf"
if [ ! -f "${TMPCFG}" ]; then
TMPCFG="${TY_CONFIG_DEFAULT}"
fi

test_case_file "${TMPFIL}" || exit 1
test_case_config "${TMPCFG}"  || exit 1


# Start logging.
if [ -f "${TY_RESULTS_FILE}" ]; then
    rm -f ${TY_RESULTS_FILE}
fi
echo "${BN}: Test 1 case ${TMPCASE} ${TMPEXIT} on ${TMPNOW}" > "${TY_RESULTS_FILE}"
echo "${BN}: Version of tidy in use..." >> "${TY_RESULTS_FILE}"
version=$(report_tidy_version) || exit 1
echo ${version} >> "${TY_RESULTS_FILE}"
version=$(report_testbase_version)
echo ${version} >> "${TY_RESULTS_FILE}"


echo ""
echo "${BN}: Doing '${DIR}/testone.sh ${TMPCASE} ${TMPEXIT}'"
echo "${BN}: Doing '${DIR}/testone.sh ${TMPCASE} ${TMPEXIT}'" >> "${TY_RESULTS_FILE}"
echo "${BN}: testone.sh run '${TY_TIDY_PATH} ... -config ${TMPCFG} ${TMPFIL}'" >> "${TY_RESULTS_FILE}"

# Clear the temporary results file.
if [ -f "${TY_TMP_FILE}" ]; then
    rm -f "${TY_TMP_FILE}"
fi

# Run the test
"${DIR}/testone.sh" "${TMPCASE}" "${TMPEXIT}"

# Append test results to the log.
if [ -f "${TY_TMP_FILE}" ]; then
    echo "==========================" >> "${TY_RESULTS_FILE}"
    cat "${TY_TMP_FILE}" >> "${TY_RESULTS_FILE}"
    echo "==========================" >> "${TY_RESULTS_FILE}"
else
    echo "Why no ${TY_TMP_FILE} created???" >> "${TY_RESULTS_FILE}"
fi

echo ""
echo "${BN}: See output in ${TY_RESULTS_FILE}"
echo ""

# Start the comparison phase
echo "${BN}: Checking for compare phase..." >> "${TY_RESULTS_FILE}"

TMPFIL1="${TY_EXPECTS_DIR}/case-${TMPCASE}.html"
TMPOUT1="${TY_EXPECTS_DIR}/case-${TMPCASE}.txt"
TMPFIL2="${TY_RESULTS_DIR}/case-${TMPCASE}.html"
TMPOUT2="${TY_RESULTS_DIR}/case-${TMPCASE}.txt"

test_file_expects "${TMPFIL1}" "${TMPCASE}"
test_file_expects "${TMPOUT1}" "${TMPCASE}"
test_file_output "${TMPFIL2}"
test_file_output "${TMPOUT2}"
if [ "${ERROR_COUNT}" -gt 0 ]; then exit 1; fi


is_diff()
{
    echo ""
    echo "${BN}: Check the above diff carefully. This may indicate a 'testbase', or"
    echo "${BN}: a 'regression' in tidy output."
    echo ""
}


# Compare the outputs, exactly
TMPOPTS="-ua"
ERRCNT=0

echo ""
echo "${BN}: Doing: 'diff ${TMPOPTS} ${TMPFIL1} ${TMPFIL2}'"
echo "${BN}: Doing: 'diff ${TMPOPTS} ${TMPFIL1} ${TMPFIL2}'" >> "${TY_RESULTS_FILE}"
diff ${TMPOPTS} ${TMPFIL1} ${TMPFIL2}
if [ "$?" = "0" ]; then
    echo "Files appear exactly the same..."
else
    is_diff
    ERRCNT=`expr ${ERRCNT} + 1`
fi

echo ""
echo "${BN}: Doing: 'diff ${TMPOPTS} ${TMPOUT1} ${TMPOUT2}'"
echo "${BN}: Doing: 'diff ${TMPOPTS} ${TMPOUT1} ${TMPOUT2}'" >> "${TY_RESULTS_FILE}"
diff ${TMPOPTS} ${TMPOUT1} ${TMPOUT2}
if [ "$?" = "0" ]; then
    echo "${BN}: Files appear exactly the same..."
else
    is_diff
    ERRCNT=`expr ${ERRCNT} + 1`
fi

echo ""
if [ "${ERRCNT}" = "0" ]; then
    echo "${BN}: Appears a successful test of ${TMPCASE} ${TMPEXIT}"
    echo "${BN}: Appears a successful test of ${TMPCASE} ${TMPEXIT}" >> "${TY_RESULTS_FILE}"
else
    echo "${BN}: Carefully REVIEW the above differences on ${TMPCASE} ${TMPEXIT}! *** ACTION REQUIRED ***"
    echo "${BN}: Carefully REVIEW the above differences on ${TMPCASE} ${TMPEXIT}! *** ACTION REQUIRED ***" >> "${TY_RESULTS_FILE}"
fi
echo ""
echo "# eof" >> "${TY_RESULTS_FILE}"
echo "${BN}: See full ouput in ${TY_RESULTS_FILE}"

# eof
