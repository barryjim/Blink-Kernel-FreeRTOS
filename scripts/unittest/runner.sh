#!/usr/bin/env bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
MY_PWD=${PWD}
NO_CLEAR=0

usage()
{
    echo -e "Usage: $0 [-f <filter>|-n|-h]\n"
}

help()
{
  usage
    echo -e "DESCRIPTION:"
    echo -e "Run unit tests for the project."
    echo -e
    echo -e "OPTIONS:"
    echo -e "  -f   Filter a specific unittest name."
    echo -e "  -n   Doesnt clean the old build."
    echo -e "  -h   Prints this help\n"
}

while getopts f:,nh opts
do
    case "${opts}" in
        f)  FILTER="$OPTARG";;
        n)  NO_CLEAR=1;;
        h)  help; exit;;
        \?) help; exit;;
    esac
done

pushd "${SCRIPT_PATH}"

if [ -d "${SCRIPT_PATH}/build" ]; then
    if [ "${NO_CLEAR}" == 0 ]; then
        rm -rf $SCRIPT_PATH/build
    fi
fi

cmake -DCMAKE_INSTALL_PREFIX=${HOME}/opt \
            -DCMAKE_BUILD_TYPE=Debug \
            -DROOT_DIR="${PROJECT_ROOT}" \
            -DFILTER:STRING=$FILTER -B build

make -C build
make CTEST_OUTPUT_ON_FAILURE=TRUE test -C build

cd -

popd