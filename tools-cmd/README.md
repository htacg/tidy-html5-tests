# tools-cmd

#### Files: alltest.cmd

The chain is `alltest.cmd` runs `alltest1.cmd`, which then uses `onetest.cmd` for each test.

This tool chain uses the `cases-testbase-expects.txt` file for the list of all of the test cases.

There is now a `README/testinfo.txt` file which give some desciption of the tests. Well actually the title of the [original SF bug report](https://sourceforge.net/p/tidy/bugs/#number/).


#### Files: xmltest.cmd

Additionally there are some 27 xml tests, run using `xmltest.cmd`, reading the test list from `cases-xml-expects.txt`, and using the same `onetest.cmd` for each test.


#### Files: acctest.cmd

Another series of tests in this folder are the accessability tests, executed by running the `acctest.cmd.`

It uses `onetesta.cmd` to process each of the some 118 tests in `cases-access-expects.txt`. 

The test files for these accessability tests are in the `cases-access` directory.


#### Files: alltestc.bat

This is essentially similar to the above, except it includes a COMPARE of the previous established output in the `cases-testbase-expects` folder with the NEW output in `cases-testbase-results`, hence the addition of a `c`.

As indicated above, this is an attempt to create such a BASE set of output files when Tidy is run on the input test cases.

Then when `alltestc.bat` is run, it runs `alltest2.bat`, which like the above it reads the tests from `cases-testbase-expects.txt`, and uses `onetest2.bat` for each test.

So the difference between this and the above is, it further immediately compares the output of Tidy, if there is one, with the equivalent file in the `cases-testbase-expects` directory using a windows port of diff.

It is a success if there is **NO** diff! A difference means this newer version of tidy has modified the output. That modification needs to be carefully inspected, and if it is thought exact and suitable, then that new output should be copied to the `cases-testbase-expects` folder for future compares.

; eof
