Tidy Regression Testing Specification
=====================================

General
-------
This directory contains test cases and tools for executing them in order to
perform Tidy output regression testing.

All cases can be found in subdirectories of `cases/`.

Testing tools can be found in the `tools-*` directories, and contain general
language and platform-specific tools that can perform testing in accordance with
this specification.

Each directory should have a README describing the contents of tools, test
cases contained, etc.


Input Specification
-------------------

The test cases consist of the following:

- Documents to tidy.
- Optional configuration settings to be used for tidying.
- Expected, tidied file.
- Expected warning/error output.
- A table of expected Tidy exit codes for each test.

Each set of cases consists of directories and a text file within the `cases/`
directory. Each test set shall consist of the following directories/files, where
`setname` indicates the name of the testing set, e.g., `testbase` (our default
set of case files).

- `setname/`, which contains the HTML files to tidy, optional
  configuration file for each case, and the testing manifest.
  - Test files shall have the format `case-nnn.html|xml|xhtml`, where `nnn`
    represents the test case identification. The test case identification shall
    not contain hyphens.
  - Optional Tidy configuration files shall be named `case-nnn.conf`.
  - In the absense of a configuration file, the file `config_default.conf` in
    each directory will be used instead.
  - `manifest.txt`, which consists of a table of test cases, expected
    Tidy exit codes, and additional data (for some tests).

- `setname-expects/`, which contains the expected output from HTML Tidy.
  - Files in the format `case-nnn.html` represent the expected HTML file as
    generated by Tidy.
  - Files in the format `case-nnn.txt` represent the expected warning/error
    output from Tidy.
  
### Example

~~~
cases/
   testbase/
      _manifest.txt
      config_default.cong
      case-427821.html
      case-427821.conf
   testbase-expects/
      case-427821.html
      case-427821.txt
~~~


Output Specification
--------------------

The output specification is written such that it makes it trivial to easily
`diff` a `setname-expects` directory with the output of a test in order
to check for differences.

Test results consist of Tidy's HTML output, Tidy's warning/error output, and
a test report. Testing tools may leave additional temporary files behind as
well.

Each set of results consists of directories within the `cases/` directory.

- `setname-results` contains Tidy's HTML and warning/error output.
  - Files in the format `case-nnn.html` are the HTML file generated by Tidy.
  - Files in the format `case-nnn.txt` are the warning/error output from Tidy.

- `setname-results.txt` contains the test report generated by the testing
  tools.

### Example

~~~
cases/
   testbase-results/
      case-427821.html
      case-427821.txt
   testbase-results.txt
~~~


Additional Notes and Comments
-----------------------------

In essence it is an attempt to automate some regression testing. The idea is
that after making a code change to Tidy, testing can be run using the new Tidy
executable. This would produce an output in the `cases/` directory.

For example, comparing `testbase-expects/` with `testbase-results`  
will show you what file output was changed by your code modification, if any.
In WIN32 there should be none.

In Unix the `$ diff -ua cases-testbase-expects cases-testbase-results` will
normally yield 3 changes: tests 431895, 500236 and 616606. 431895 is because it
uses the `gnu-emacs: yes` option and we can thus expect the path separator in
the file names to change.

The other two 500236 and 616606 just seem to have some spaces changes. Not sure
exactly why. If `-w` or `-b` option is use there should be no difference. So
these 3 tests must be especially checked.

Difficult, and tedious! Yes, but is a sure way to see if your changes adversely
effected Tidy. Unfortunately, only such a visual comparison would show the
results. If the output changes are fully acceptable, like a warning message
changed, then this should become the new base file for that test.

Of course some of the tests were to, say, avoid a segfault found. Other tests 
were to visually compare the original input test file in a browser, with how the
new output displayed in a browser. This is a purely VISUAL compare, and can not
be done in code.

And what about if there was NO current test existing to test what you were
trying to fix. Well that means a NEW test should be added. Its output added to
the base, then there would be a comparison.
