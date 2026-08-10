#!/bin/bash

set -e

usage() 
{
    echo -e "Usage: $0 [-i|-d] [-p <project>] [-h]\n"
}

help() 
{
  usage
    echo -e "DESCRIPTION:"
    echo -e "This script updates the project version in config/version.h."
    echo -e
    echo -e "Options:"
    echo -e "  -i                   Increment version"
    echo -e "  -d                   Decrement version"
    echo -e "  -p <project>         Specify the project name"
    echo -e "  -h                   Show this help message"
}

update_version()
{
    local VERSION_FILE="./config/version.h"

    if [ ! -f "$VERSION_FILE" ]; then
        echo "Error: version.h not found at $VERSION_FILE"
        exit 1
    fi

    local CURRENT_VERSION=$(grep -m1 '#define SOFTWARE_VERSION ' "$VERSION_FILE" | cut -d '"' -f 2)
    if [ -z "$CURRENT_VERSION" ]; then
        echo "Error: Could not find SOFTWARE_VERSION in $VERSION_FILE"
        exit 1
    fi

    local MAJOR=$(echo "$CURRENT_VERSION" | awk -F'[".]' '{print $2}')
    local MINOR=$(echo "$CURRENT_VERSION" | awk -F'[".]' '{print $3}')
    local PATCH=$(echo "$CURRENT_VERSION" | awk -F'[".]' '{print $4}')

    local NEW_PATCH=$((PATCH + UPDATE_VALUE))
    if [ "$NEW_PATCH" -lt 0 ]; then
        NEW_PATCH=0
    fi
    local NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"

    sed -i "s/#define SOFTWARE_VERSION \"${CURRENT_VERSION}\"/#define SOFTWARE_VERSION \"${NEW_VERSION}\"/" "$VERSION_FILE"
    sed -i "s/#define SOFTWARE_VERSION_PATCH ${PATCH}/#define SOFTWARE_VERSION_PATCH ${NEW_PATCH}/" "$VERSION_FILE"

    echo "Version updated from ${CURRENT_VERSION} to ${NEW_VERSION}"
}

unset SINGLE_PROJECT
UPDATE_VALUE=1

while getopts p:idh opts; do
    case "${opts}" in
        p) SINGLE_PROJECT="$OPTARG";;
        i) UPDATE_VALUE=1;;
        d) UPDATE_VALUE=-1;;
        h) help; exit 0;;
        *) help; exit 1;;
    esac
done

ORIGINAL_PATH=$(pwd)
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..

cd "${PROJECT_ROOT}" || { echo "Error: Failed to change directory to ${PROJECT_ROOT}"; exit 1; }

update_version

cd "${ORIGINAL_PATH}" || { echo "Error: Failed to return to original directory ${ORIGINAL_PATH}"; exit 1; }