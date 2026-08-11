#!/bin/bash

INCLUDE_SDK=0
PACKAGING_REPORT=0

usage()
{
    echo -e "Usage: $0 [-p|-s|-f <path/to/file>|-h]\n"
}

help()
{
  usage
    echo -e "DESCRIPTION:"
    echo -e "This script runs cpplinter on c and h files.."
    echo -e
    echo -e "OPTIONS:"
    echo -e "  -p   Packaging lint report."
    echo -e "  -s   Include SDK files to be linted."
    echo -e "  -f   Lint only specified file. Cannot be used with -s flag."
    echo -e "  -h   Prints this help\n"
}

while getopts p,s,f:,h opts
do
    case "${opts}" in
        p)  PACKAGING_REPORT=1;;
        s)  INCLUDE_SDK=1;;
        f)  SINGLE_FILE="$OPTARG";;
        h)  help; exit;;
        \?) help; exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

REPORT_PATH=${SCRIPT_PATH}/../../code_quality_report
CPPLINT_REPORT_PATH=${REPORT_PATH}/cpplint

if [ "${PACKAGING_REPORT}" == 1 ]; then
    if [ ! -d ${REPORT_PATH} ];then
        mkdir ${REPORT_PATH}
    fi

    if [ ! -d ${CPPLINT_REPORT_PATH} ];then
        mkdir ${CPPLINT_REPORT_PATH}
    else
        rm ${CPPLINT_REPORT_PATH}/*
    fi
fi

pushd "$PWD" > /dev/null 2>&1

    cd ${SCRIPT_PATH}/../..

    if [ -n "${SINGLE_FILE}" ]; then
        ./third_party/cpplint/cpplint.py "${SINGLE_FILE}"
    else
        patterns=('*.c' '*.h')
        excludes=('./sdk/*' './third_party/*' './cmake_gcc/*' './scripts/*' './autogen/*' './.git/*' './.github/*')

        if [ "${INCLUDE_SDK}" == 0 ]; then
            excludes+=('./sdk/*')
        fi

        exclude_args=()
        for exclude in "${excludes[@]}"; do
            exclude_args+=('!' -path "$exclude" -a)
        done

        pattern_args=()
        for pattern in "${patterns[@]}"; do
            pattern_args+=(-o -name "$pattern")
        done

        CPPLINT_ARGS="--filter=-whitespace/indent,-readability/alt_tokens,-build/include_subdir,-whitespace/braces,-build/include_order,-build/include_alpha"
        CPPLINT_ARGS="${CPPLINT_ARGS} --linelength=100"

        if [ "${PACKAGING_REPORT}" == 0 ]; then
            find . "${exclude_args[@]}" '(' "${pattern_args[@]:1}" ')' -type f -exec ./third_party/cpplint/cpplint.py ${CPPLINT_ARGS} {} +
        else
            find . "${exclude_args[@]}" '(' "${pattern_args[@]:1}" ')' -type f -exec ./third_party/cpplint/cpplint.py ${CPPLINT_ARGS} --output=junit {} + > ${CPPLINT_REPORT_PATH}/cpplint_report.xml
            echo "Cpplint report saved to ${CPPLINT_REPORT_PATH}/cpplint_report.xml"
        fi
    fi

    cd -

popd > /dev/null 2>&1