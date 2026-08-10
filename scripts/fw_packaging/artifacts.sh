#!/bin/bash
#
# artifacts.sh - Package prebuilt firmware artifacts for Release
#
# This script collects firmware files from the prebuilt/ directory
# (or cmake_gcc/build/ as fallback) and packages them into artifacts.tar.gz.
#
# The Silicon Labs SDK is NOT required - firmware must be built locally
# using Simplicity Studio and committed to the repository.
#
# Usage:
#   bash artifacts.sh [-t <config>] [--sync] [-h]
#   bash artifacts.sh --sync              # Sync build artifacts to prebuilt/ first
#   bash artifacts.sh -t base --sync      # Sync + package

usage() {
    echo -e "Usage: $0 [-t <config>] [--sync] [-h]\n"
}

help() {
    usage
    echo -e "DESCRIPTION:"
    echo -e "  Package prebuilt firmware artifacts for GitHub Release."
    echo -e ""
    echo -e "OPTIONS:"
    echo -e "  -t        Build config (default: base)"
    echo -e "  --sync    Auto-sync cmake_gcc/build/ to prebuilt/ before packaging"
    echo -e "  --force   Force overwrite existing files (used with --sync)"
    echo -e "  -h        Print this help"
    echo -e ""
    echo -e "WORKFLOW:"
    echo -e "  1. Build firmware locally with Simplicity Studio"
    echo -e "  2. Run: bash artifacts.sh --sync"
    echo -e "     (This automatically copies build/ output to prebuilt/)"
    echo -e "  3. Commit prebuilt/ and push"
    echo -e "  4. Create tag v* to trigger GitHub Release"
}

BUILD_CONFIG="base"
DO_SYNC=0
FORCE=0

while getopts t:fh-: opts; do
    case "${opts}" in
        t) BUILD_CONFIG="$OPTARG" ;;
        f) FORCE=1 ;;
        h) help; exit 0 ;;
        -)
            case "${OPTARG}" in
                sync) DO_SYNC=1 ;;
                force) FORCE=1 ;;
                *) help; exit 1 ;;
            esac ;;
        *) help; exit 1 ;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
PROJECT_NAME=$(basename "$PROJECT_ROOT")
OUT_PATH=${PROJECT_ROOT}/artifacts
PREBUILT_DIR=${PROJECT_ROOT}/prebuilt
BUILD_DIR=${PROJECT_ROOT}/cmake_gcc/build
SYNC_SCRIPT="${SCRIPT_PATH}/sync_prebuilt.sh"

echo "============================================"
echo "Packaging project: ${PROJECT_NAME}"
echo "Project root:     ${PROJECT_ROOT}"
echo "Output path:      ${OUT_PATH}"
echo "Build config:     ${BUILD_CONFIG}"
echo "============================================"

# Optionally sync build artifacts to prebuilt/ first
if [ "${DO_SYNC}" -eq 1 ]; then
    echo ""
    echo "--- Step 1: Sync build artifacts to prebuilt/ ---"
    if [ -f "${SYNC_SCRIPT}" ]; then
        SYNC_ARGS="-t ${BUILD_CONFIG}"
        [ "${FORCE}" -eq 1 ] && SYNC_ARGS="${SYNC_ARGS} -f"
        bash "${SYNC_SCRIPT}" ${SYNC_ARGS}
        SYNC_RC=$?
        if [ ${SYNC_RC} -ne 0 ]; then
            echo "::warning::Sync failed, continuing with existing prebuilt/ files"
        fi
    else
        echo "::warning::sync_prebuilt.sh not found, skipping sync"
    fi
fi

rm -rf "${OUT_PATH}"
mkdir -p "${OUT_PATH}"

PROJECT_VERSION=$( grep -m1 '#define SOFTWARE_VERSION ' "${PROJECT_ROOT}/config/version.h" 2>/dev/null | cut -d '"' -f 2 )
if [ -z "${PROJECT_VERSION}" ]; then
    PROJECT_VERSION="unknown"
fi
echo ""
echo "Project version: ${PROJECT_VERSION}"

OUT_PRJ_PATH="${OUT_PATH}/${PROJECT_NAME}-${PROJECT_VERSION}"
mkdir -p "${OUT_PRJ_PATH}"

echo ""
echo "--- Step 2: Collecting firmware artifacts ---"

FOUND=0
SEARCH_DIRS=("${PREBUILT_DIR}" "${BUILD_DIR}/${BUILD_CONFIG}" "${BUILD_DIR}")

for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        for ext in bin hex s37 map out; do
            src="${dir}/${PROJECT_NAME}.${ext}"
            if [ -f "$src" ]; then
                cp "$src" "${OUT_PRJ_PATH}/"
                echo "  [OK] Copied: ${PROJECT_NAME}.${ext} (from ${dir}/)"
                FOUND=$((FOUND + 1))
            fi
        done
    fi
done

if [ ${FOUND} -eq 0 ]; then
    echo ""
    echo "  Warning: No firmware files found."
    echo "  Creating placeholder artifacts so Release can still be created."
    echo ""
    echo "  To build real firmware:"
    echo "    1. Open project in Simplicity Studio"
    echo "    2. Build the target"
    echo "    3. Run: bash artifacts.sh --sync"
    echo "    4. Commit and push"

    for ext in bin hex s37 map out; do
        {
            echo "# ${PROJECT_NAME}.${ext}"
            echo "# Version: ${PROJECT_VERSION}"
            echo "# Build mode: placeholder (no prebuilt firmware)"
            echo "# Build with Simplicity Studio to generate real firmware"
            echo "# Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        } > "${OUT_PRJ_PATH}/${PROJECT_NAME}.${ext}"
        echo "  [PLACEHOLDER] ${PROJECT_NAME}.${ext}"
        FOUND=$((FOUND + 1))
    done
else
    echo ""
    echo "  Collected ${FOUND} firmware file(s)."
fi

echo ""
echo "--- Step 3: Creating artifacts.tar.gz ---"
cd "${OUT_PATH}"
tar -zcvf "${OUT_PATH}/artifacts.tar.gz" *
echo "Artifacts archive created: ${OUT_PATH}/artifacts.tar.gz"
cd "${PROJECT_ROOT}"

echo ""
echo "============================================"
echo "Packaging completed."
echo "Files found:   ${FOUND}"
echo "Output:        ${OUT_PATH}/"
echo "Archive:       ${OUT_PATH}/artifacts.tar.gz"
echo "============================================"

exit 0