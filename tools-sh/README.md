README.md tools-sh
==================

This directory contains shell tools for running Tidy's regression tests. The
main utility is `run-tests.sh`, which runs all the tests in a case set name. By
default it uses the `testbase` case set, but this can be configured by setting
the `TY_CASES_SETNAME` ENVironment variable.

Tests
-----

- `run-tests.sh`
	- Runs all the tests in `cases/${TY_CASES_SETNAME}` and then diffs the output
		of the tests in `cases/${TY_CASES_SETNAME}-results` against
		`cases/${TY_CASES_SETNAME}-expects`.
	- It uses `testall.sh` to conduct tests.
- `t1.sh`
  - A convenient tool for running a single test case and comparing output.
    Use it like `./t1.sh 1642186-1 0`, specifying the case number and expected
    Tidy exit code.
  - It will use test cases in `cases/${TY_CASES_SETNAME}`.
  - It uses `testone.sh` to conduct tests.
- `testaccess.sh`
  - Performs all of the accessibility suite checks.
  - It will use test cases in `cases/access`.
  - It uses `testaccessone.sh` to conduct tests.
- `testaccessone.sh`
  - This is a dependency of `testaccess.sh` and you don't need to use it.
- `testall.sh`
  - Will run all regression tests in `cases/${TY_CASES_SETNAME}`.
  - It uses `testone.sh` to conduct tests.
- `testone.sh`
  - This is a dependency for many of the other tests, and you don't need to
    use it.
- `testxml.sh`
  - Will conduct XML specific tests.
  - It will use test cases in `cases/xml`
  - It uses `testone.sh` to conduct tests.


ENVironment variables
---------------------

`TY_CASES_SETNAME`: The test set to use. By default, `testbase` is used when
this variable is not set.

`TY_TIDY_PATH`: Set this to the path of the Tidy you would like to use for
conducting the tests. **You must set this yourself!**

`TY_CASES_DIR`: Set this to the directory containing the tests cases you would
like to use.

The environment is set up by every script in the `_environment.sh` script, which
is sourced in and contains some extra functions.

Path names
----------

Currently paths that include spaces in their names are not supported. It would
be a simple matter to replace for-each with something else, but I've simply
not done it.
