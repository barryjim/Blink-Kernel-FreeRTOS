#!/bin/bash

SMALLEST_SDK=0

usage()
{
    echo -e "Usage: $0 [-s|-h]\n"
}

help()
{
  usage
    echo -e "DESCRIPTION:"
    echo -e "This script sets up third-party tools (cpplint, cppcheck, cmocka)."
    echo -e
    echo -e "OPTIONS:"
    echo -e "  -s   Minimal setup (skip heavy tools)"
    echo -e "  -h   Prints this help\n"
}

unset OPTIND
while getopts s,h opts
do
    case "${opts}" in
        s)  SMALLEST_SDK=1;;
        h)  help; exit;;
        \?) help; exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
THIRD_PARTY_DIR=${PROJECT_ROOT}/third_party

echo "Setting up tools for: $(basename ${PROJECT_ROOT})"
echo "Third-party directory: ${THIRD_PARTY_DIR}"

mkdir -p "${THIRD_PARTY_DIR}"

# Setup cpplint
if [ ! -d "${THIRD_PARTY_DIR}/cpplint" ]; then
    echo "Cloning cpplint..."
    git clone --depth 1 https://github.com/cpplint/cpplint.git "${THIRD_PARTY_DIR}/cpplint"
else
    echo "cpplint already installed"
fi

# Setup cppcheck
if [ ! -d "${THIRD_PARTY_DIR}/cppcheck" ]; then
    if [ "${SMALLEST_SDK}" == 0 ]; then
        echo "Cloning cppcheck..."
        source ${SCRIPT_PATH}/../cppcheck/setup.sh
    else
        echo "Skipping cppcheck setup (minimal mode)"
    fi
else
    echo "cppcheck already installed"
fi

# Setup cmocka (for unit tests)
if [ ! -d "${THIRD_PARTY_DIR}/cmocka" ]; then
    if [ "${SMALLEST_SDK}" == 0 ]; then
        echo "Cloning cmocka for unit tests..."
        git clone --depth 1 https://git.cryptomilk.org/projects/cmocka.git "${THIRD_PARTY_DIR}/cmocka"
        sudo apt-get update -qq
        sudo apt-get install -y -qq cmake build-essential libcmocka0 libcmocka-dev gcovr
    else
        echo "Skipping cmocka setup (minimal mode)"
    fi
else
    echo "cmocka already installed"
fi

echo ""
echo "Setup complete."