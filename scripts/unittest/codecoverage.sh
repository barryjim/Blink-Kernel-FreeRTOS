#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
CC_DIR="${SCRIPT_PATH}/code_coverage"
OBJ_DIR="${SCRIPT_PATH}/build"

OUTPUT=stdout
FAIL_UNDER_LINE=0
CODE_COV_PERCENT=80

usage()
{
    echo "Prints code coverage of the host unit tests."
    echo
    echo "Syntax: $0 [-h|-t|-w|-j]"
    echo "OPTIONS:"
    echo "-h        Print this Help."
    echo "-t        Generate text report to file"
    echo "-w        Generate html report to file"
    echo "-j        Generate json report"
}

if ! type "gcovr" > /dev/null; then
    echo "Error: You need to install gcovr to run this script!"; exit 1;
fi

while getopts ":hwjtf" option; do
    case "${option}" in
        h)  usage; exit;;
        w)  OUTPUT=html; shift;;
        j)  OUTPUT=json; shift;;
        t)  OUTPUT=text; shift;;
        f)  FAIL_UNDER_LINE=1; shift;
            if [ -n "$1" ]; then
                CODE_COV_PERCENT="$1"
            fi
            ;;
        *) echo "Error: Invalid option"; exit 1;;
    esac
done

if [ ! -d "${OBJ_DIR}" ]
then
  echo "Error: Code coverage files does not exist, run runner.sh to generate them."
  exit 1
fi

PARAMS=
if [ "${FAIL_UNDER_LINE}" == 1 ]; then
    PARAMS="${PARAMS} --fail-under-line ${CODE_COV_PERCENT}"
fi

mkdir -p "${CC_DIR}"

RESULT=$(find "${OBJ_DIR}" -name "*test*")

if [ -z "${RESULT}" ]; then
    echo -e "No test were executed. Exiting."; exit;
fi

case "$OUTPUT" in
    html)
        gcovr "${OBJ_DIR}"/*/CMakeFiles/*/ -r "${PROJECT_ROOT}" -p -e '.*test.*' -e '.*mock.*' -e '.*\.h' \
           --exclude-directories '.*third_party.*' --html-details "${CC_DIR}"/coverage.html ${PARAMS}
        echo "Generated html report: file://${CC_DIR}/coverage.html"
        ;;
    json)
        gcovr "${OBJ_DIR}"/*/CMakeFiles/*/ -r "${PROJECT_ROOT}" -p -e '.*test.*' -e '.*mock.*' -e '.*\.h' \
            --exclude-directories '.*third_party.*' --json "${CC_DIR}"/coverage.json ${PARAMS}
        echo "Generated json report: file://${CC_DIR}/coverage.json"
        ;;
    text)
        gcovr "${OBJ_DIR}"/*/CMakeFiles/*/ -r "${PROJECT_ROOT}" -p -e '.*test.*' -e '.*mock.*' -e '.*\.h' \
            --exclude-directories '.*third_party.*' --fail-under-line 80 -o "${CC_DIR}"/coverage.txt ${PARAMS}
        echo "Generated text report: file://${CC_DIR}/coverage.txt"
        ;;
    stdout)
        gcovr "${OBJ_DIR}"/*/CMakeFiles/*/ -r "${PROJECT_ROOT}" -p -e '.*test.*' -e '.*mock.*' -e '.*\.h' \
           --exclude-directories '.*third_party.*' ${PARAMS}
        ;;
    *)  echo "Error: Invalid output format"; exit 1;;
esac