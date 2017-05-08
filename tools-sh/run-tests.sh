#!/usr/bin/env bash
#< run-tests.sh - 20160309
BN=`basename $0`

TMPTIDY="../../tidy-html5/build/cmake/tidy"
if [ ! -x "$TMPTIDY" ]; then
	echo "$BN: Can NOT locate $TMPTIDY! *** FIX ME ***"
	exit 1
fi
TMPSCR="testall.sh"
if [ ! -x "$TMPSCR" ]; then
	echo "$BN: Can NOT locate $TMPSCR! *** FIX ME ***"
	exit 1
fi
TMPENV="_environment.sh"
if [ ! -x "$TMPENV" ]; then
	echo "$BN: Can NOT locate $TMPENV! *** FIX ME ***"
	exit 1
fi

#set the ENVIRONMENT

source "$TMPENV"
set_environment
#report_environment

if [ ! -d "$TY_EXPECTS_DIR" ]; then
	echo "$BN: Can NOT find the expects directory $TY_EXPECTS_DIR!"
	exit 1
fi

./$TMPSCR $TMPTIDY

if [ ! -d "$TY_RESULTS_DIR" ]; then
	echo "$BN: Error: The results dir NOT created $TY_RESULTS_DIR"
	exit 1
fi

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

# eof
