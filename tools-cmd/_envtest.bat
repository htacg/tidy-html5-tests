@setlocal
@echo off

rem # Allow user to specify a different Tidy.
IF NOT "%~1" == "" (
    echo setting TY_TIDY_PATH
    set TY_TIDY_PATH="%~1"
)

call _environment.bat :set_environment

call _environment.bat :report_environment

endlocal

call _environment.bat :report_environment
