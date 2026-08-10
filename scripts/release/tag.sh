#!/bin/bash

usage() 
{
    echo -e "Usage: $0 [-r <remote>] [-p <project>] [-h]\n"
}

help()
{
  usage
    echo -e "DESCRIPTION:"
    echo -e "This script tags a specific project with a release version."
    echo -e
    echo -e "Options:"
    echo -e "  -r <remote>          Specify the remote repository (default: origin)"
    echo -e "  -p <project>         Specify the project name"
    echo -e "  -h                   Show this help message"
}

tag_project()
{
    local VERSION_FILE="./config/version.h"

    if [ ! -f "$VERSION_FILE" ]; then
        echo "Error: version.h not found at $VERSION_FILE"
        exit 1
    fi

    local VERSION=$(grep -m1 '#define SOFTWARE_VERSION ' "$VERSION_FILE" | cut -d '"' -f 2)
    if [ -z "${VERSION}" ]; then
        echo "Error: Could not find version in ${VERSION_FILE}"
        exit 1
    fi

    local RELEASE_TAG="${PROJECT_NAME}-v${VERSION}"
    echo "Release project: ${PROJECT_NAME}-${VERSION}"
    echo "Tag: ${RELEASE_TAG}"

    if git rev-parse "${RELEASE_TAG}" >/dev/null 2>&1; then
        echo "Tag ${RELEASE_TAG} already exists. Skipping tag creation."
    else
        git tag -a "${RELEASE_TAG}" -m "Release ${RELEASE_TAG}"
        if [ $? -eq 0 ]; then
            echo "Tag ${RELEASE_TAG} created successfully."
            echo "Run: git push ${REMOTE} ${RELEASE_TAG}"
            git push ${REMOTE} "${RELEASE_TAG}"
        else
            echo "Failed to create tag ${RELEASE_TAG}."
            exit 1
        fi
    fi
}

REMOTE="origin"
unset SINGLE_PROJECT

while getopts r:p:h opts; do
    case "${opts}" in
        r) REMOTE="$OPTARG";;
        p) SINGLE_PROJECT="$OPTARG";;
        h) help; exit 0;;
        *) help; exit 1;;
    esac
done

if [ -z "${SINGLE_PROJECT}" ]; then
    SINGLE_PROJECT=$(basename "$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )")
fi

CURRENT_PATH=$(pwd)
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
PROJECT_NAME=${SINGLE_PROJECT}

cd "${PROJECT_ROOT}" || { echo "Error: Failed to change directory to ${PROJECT_ROOT}"; exit 1; }

tag_project

cd "${CURRENT_PATH}" || { echo "Error: Failed to return to original directory ${CURRENT_PATH}"; exit 1; }