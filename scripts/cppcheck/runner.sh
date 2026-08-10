#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

REPORT_PATH=${SCRIPT_PATH}/../../code_quality_report
CPPCHECK_REPORT_PATH=${REPORT_PATH}/cppcheck
CPPCHECK_BIN=${SCRIPT_PATH}/../../third_party/cppcheck/cppcheck
CPPCHECK_HTMLREPORT=${SCRIPT_PATH}/../../third_party/cppcheck/htmlreport/cppcheck-htmlreport

if [ ! -d ${REPORT_PATH} ];then
    mkdir ${REPORT_PATH}
fi

if [ ! -d ${CPPCHECK_REPORT_PATH} ];then
    mkdir ${CPPCHECK_REPORT_PATH}
else
    rm ${CPPCHECK_REPORT_PATH}/*
fi

PROJECT_ROOT=${SCRIPT_PATH}/../..

${CPPCHECK_BIN} -j$(nproc) \
    --enable=warning,style,performance,portability \
    --xml \
    '-D__ALIGNED(x)=' \
    ${PROJECT_ROOT}/ \
    --suppress=*:*/test/* \
    --suppress=*:*/third_party/* \
    --suppress=*:*/sdk/* \
    &> ${CPPCHECK_REPORT_PATH}/cppcheck_report.xml

if [ -f "${CPPCHECK_HTMLREPORT}" ]; then
    ${CPPCHECK_HTMLREPORT} --file=${CPPCHECK_REPORT_PATH}/cppcheck_report.xml \
        --title=blink_kernel_freertos_s3 \
        --report-dir=${CPPCHECK_REPORT_PATH} \
        --source-dir=${PROJECT_ROOT}/
fi