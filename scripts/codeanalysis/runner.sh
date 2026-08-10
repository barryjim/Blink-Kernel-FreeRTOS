#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..

REPORT_PATH=${PROJECT_ROOT}/code_quality_report

bash ${SCRIPT_PATH}/../linter/linter.sh -p

bash ${SCRIPT_PATH}/../cppcheck/runner.sh

cd "${PROJECT_ROOT}"
tar -zcvf code_quality_report.tar.gz code_quality_report