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

if [ -d "$TY_RESULTS_DIR" ]; then
	echo "$BN: Removing existing dir, and re-create $TY_RESULTS_DIR"
	rm -rf "$TY_RESULTS_DIR"
	mkdir "$TY_RESULTS_DIR"
	if [ ! "$?" = "0" ]; then
	    echo "$BN: Unable to recreate $TY_RESULTS_DIR!"
    	exit 1
    fi
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
    echo ""
	echo "======================================================" >> "${TY_RESULTS_FILE}"
	echo "$BN: Appear to have PASSED test 2"
	echo "$BN: Appear to have PASSED test 2" >> "${TY_RESULTS_FILE}"
    echo ""
else
    echo ""
	echo "======================================================" >> "${TY_RESULTS_FILE}"
	echo "$BN: Appears test 2 FAILED!"
	echo "$BN: Appears test 2 FAILED!" >> "${TY_RESULTS_FILE}"
    echo ""
fi
echo "$BN: See full results in $TY_RESULTS_FILE"

# eof
