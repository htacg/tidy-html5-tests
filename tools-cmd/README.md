# tools-cmd

## Testing Utilities

The two main utilities are `alltest.bat` which is capable of running any of the case sets in the suite, and `t1.bat` for quicks checks of a single file. The other batch files are supporting files that offer library utilities for writing additional tests and supporting the current tests.


## Testing environment

All of the test utilities conform to a single environment and share a single set of command line options.

The default cases set is `testbase`.

The default output directory and test report file are based on the active cases set. For example, `testbase-results\` and `testbase-results.txt`.


### Environment Variables

`TY_TIDY_PATH`
 : You _must_ set `TIDY_TIDY_PATH` or use the `-t` option so that the utilities
   will know which version of Tidy to use for testing. Your operating system's
   built-in Tidy will never be used by default. This is by design.
   
`TY_CASES_SETNAME`
 : You may specify the name of the cases set name to use by default if you wish
   to use other than the built-in default. This is convenient if you want to
   avoid using the `-c` option all of the time.
   
`TY_MKDIR_CONFIRM`
 : The testing utilities will normally created the output directory for you
   automatically if required. If you prefer to answer a confirmation prompt for
   some reason, set this environment variable to any value and directories will
   only be created after you give confirmation.
   
   
### Command line options

Command line options can be used with either a `/` or a `-`; the examples below use a hyphen. Additionally options that take values can be separated with a space (e.g., `-c access`) or an equals sign (e.g., `-c=xml`).

`-help`
`-h`
`-?`
`/h`
`/help`
 : Provides help for the utility in question.


`-t`
 : Provides the path to the Tidy that you want to test. Alternatively you can
   set the `TY_TIDY_PATH` environment variable.
   
`-c`
 : Provides the test case set name to use for the test. A "set" is simply a
   directory with appropriately named files, a manifest, and a default config
   file for Tidy. Alternatively you can set the `TY_CASES_SETNAME` environment
   variable.

`-o`
 : Allows you to specify an alternate directory for testing results. The test
   report file will also bear the name specified. This may be useful if you
   don't want to use the default name for some reason.


## The Utilities

## `t1.bat`

A convenient run one test giving the number and expected exit code.

~~~
Usage: `t1 "value" "expected exit value" [options]`

   That is give test number, and expected result, like
   t1 1642186 1
~~~

This utility uses `_onetest.bat` to perform the actual test.


## `alltest.bat`

This test generates results directories suitable for use with `diff` to perform
complete regression testing. It also provides realtime exit code feedback in
the event that a test provides a different exit code than expected. It is capable of handling every test case set in the suite, including the accessibility tests.

By default it will use `testbase`, but specifying the `-c` argument will successfully test the other case sets as well.

This utility uses `_onetest.bat` or `_onetesta.bat` for each test, depending on the type of test being performed.
