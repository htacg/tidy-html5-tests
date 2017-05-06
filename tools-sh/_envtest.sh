#!/usr/bin/env bash

DIR="$(readlink -e $(dirname $0))"
source "${DIR}/_environment.sh"

set_environment

report_environment

report_testbase_version

test_tidy_path

test_results_base_dir

version=$(report_tidy_version)

echo "${version}"
