#!/usr/bin/env bash

set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
MY_PWD=${PWD}

usage()
{
    echo -e "Usage: $0 [-f <filter>|-h]\n"
}

help()
{
  usage
    echo -e "DESCRIPTION:"
    echo -e "Build unit tests without running them."
    echo -e
    echo -e "OPTIONS:"
    echo -e "  -f   Filter a specific unittest."
    echo -e "  -h   Prints this help\n"
}

while getopts f:,h opts
do
    case "${opts}" in
        f)  FILTER="$OPTARG";;
        h)  help; exit;;
        \?) help; exit;;
    esac
done

pushd $SCRIPT_PATH

cmake -DCMAKE_INSTALL_PREFIX=${HOME}/opt \
            -DCMAKE_BUILD_TYPE=Debug \
            -DROOT_DIR="${PROJECT_ROOT}" \
            -DFILTER:STRING=$FILTER -B build

make -C build
popd