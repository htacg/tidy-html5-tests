#!/usr/bin/env bash

#=================================================================
# A convenient shortcut for opening all associated case, -expects,
# and -results with BBEdit on macOS.
# 
# For example, "./qo.sh 1642186"
# 
# Note it expects the -results folder to already exist.
#=================================================================

DIR="$(readlink -e $(dirname $0))"

# setup the ENVIRONMENT
source "${DIR}/_environment.sh"
set_environment

# check critical inputs
test_results_base_dir

if [ "${ERROR_COUNT}" -gt 0 ]; then
    echo ""
    echo "${BN}: Aborted. Please resolve the ${ERROR_COUNT} error(s), above."
    echo ""
    exit 1
fi

give_help()
{
    echo ""
    echo "Usage: $0 <value>"
    echo "  That is give test number, like"
    echo "  $0 1642186"
    echo "  See testcases.txt for a list of available cases."
    echo ""
    echo "Cases: ${TY_CASES_DIR}."
    echo "Results: ${TY_RESULTS_DIR}."
    echo "  Set the TY_CASES_SETNAME environment variable in order to override."  
    echo ""
}

# Check user input
TMPCASE="$1"

if [ -z "${TMPCASE}" ]; then
    give_help
    exit 1
fi    

# Find our case file
TMPFIL="${TY_CASES_DIR}/case-${TMPCASE}.xhtml"
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_CASES_DIR}/case-${TMPCASE}.xml"
fi
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_CASES_DIR}/case-${TMPCASE}.html"
fi
test_case_file "${TMPFIL}" || exit 1
bbedit "${TMPFIL}"

# Find our config file
TMPFIL="${TY_CASES_DIR}/case-${TMPCASE}.conf"
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_CONFIG_DEFAULT}"
fi
test_case_config "${TMPFIL}"  || exit 1
bbedit "${TMPFIL}"

# Find our expects HTML file
TMPFIL="${TY_EXPECTS_DIR}/case-${TMPCASE}.xhtml"
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_EXPECTS_DIR}/case-${TMPCASE}.xml"
fi
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_EXPECTS_DIR}/case-${TMPCASE}.html"
fi
if [ -f "${TMPFIL}" ]; then
bbedit "${TMPFIL}"
fi

# Find our expects TXT file
TMPFIL="${TY_EXPECTS_DIR}/case-${TMPCASE}.txt"
if [ -f "${TMPFIL}" ]; then
bbedit "${TMPFIL}"
fi

# Find our results HTML file
TMPFIL="${TY_RESULTS_DIR}/case-${TMPCASE}.xhtml"
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_RESULTS_DIR}/case-${TMPCASE}.xml"
fi
if [ ! -f "${TMPFIL}" ]; then
TMPFIL="${TY_RESULTS_DIR}/case-${TMPCASE}.html"
fi
if [ -f "${TMPFIL}" ]; then
bbedit "${TMPFIL}"
fi

# Find our results TXT file
TMPFIL="${TY_RESULTS_DIR}/case-${TMPCASE}.txt"
if [ -f "${TMPFIL}" ]; then
bbedit "${TMPFIL}"
fi

# eof
