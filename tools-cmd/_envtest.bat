@echo off

rem # Allow user to specify a different Tidy. Do this before any setlocal!
IF NOT "%~1" == "" (
    echo setting TY_TIDY_PATH
    set TY_TIDY_PATH="%~1"
)

rem # Do this before any type of setlocal!
call _environment.bat :set_environment

rem # Now we can do setlocal and do normal script stuff.
setlocal

rem # See that our env vars are still set.
call _environment.bat :report_environment

rem # Let's unset our env for a clean exit.
endlocal
call _environment.bat :unset_environment
