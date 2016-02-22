#!/usr/bin/env bash

source _environment.sh

set_environment

report_environment

report_testbase_version

test_tidy_path

test_results_dir

version=$(report_tidy_version)

echo $version
