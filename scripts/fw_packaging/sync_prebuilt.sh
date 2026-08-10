#!/bin/bash
#
# sync_prebuilt.sh - Sync local build artifacts to prebuilt/
#
# After building with Simplicity Studio, this script copies firmware
# files from cmake_gcc/build/<config>/ to prebuilt/ for git commit.
#
# Usage: bash sync_prebuilt.sh [-t <config>] [-f]
#   -t   Build config (default: base)
#   -f   Force overwrite existing files in prebuilt/

usage() {
    echo -e "Usage: $0 [-t <config>] [-f]\n"
}

help() {
    usage
    echo -e "DESCRIPTION:"
    echo -e "  Sync local build artifacts from cmake_gcc/build/ to prebuilt/."
    echo -e ""
    echo -e "  Run this after building firmware in Simplicity Studio:"
    echo -e "    1. Build target in Simplicity Studio"
    echo -e "    2. Run: bash scripts/fw_packaging/sync_prebuilt.sh"
    echo -e "    3. Commit: git add prebuilt/ && git commit -m 'update firmware'"
    echo -e ""
    echo -e "OPTIONS:"
    echo -e "  -t   Build config (default: base)"
    echo -e "  -f   Force overwrite existing files"
    echo -e "  -h   Print this help"
}

BUILD_CONFIG="base"
FORCE=0

while getopts t:fh opts; do
    case "${opts}" in
        t) BUILD_CONFIG="$OPTARG" ;;
        f) FORCE=1 ;;
        h) help; exit 0 ;;
        *) help; exit 1 ;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
PROJECT_NAME=$(basename "$PROJECT_ROOT")
BUILD_DIR=${PROJECT_ROOT}/cmake_gcc/build
SRC_DIR=${BUILD_DIR}/${BUILD_CONFIG}
DEST_DIR=${PROJECT_ROOT}/prebuilt

echo "============================================"
echo "Sync prebuilt firmware"
echo "Project:  ${PROJECT_NAME}"
echo "Source:   ${SRC_DIR}"
echo "Dest:     ${DEST_DIR}"
echo "Config:   ${BUILD_CONFIG}"
echo "============================================"

if [ ! -d "${SRC_DIR}" ]; then
    echo "::error::Build directory not found: ${SRC_DIR}"
    echo "  Please build the firmware first in Simplicity Studio."
    exit 1
fi

mkdir -p "${DEST_DIR}"

FOUND=0
COPIED=0
SKIPPED=0

for ext in bin hex s37 map out; do
    src="${SRC_DIR}/${PROJECT_NAME}.${ext}"
    if [ -f "$src" ]; then
        FOUND=$((FOUND + 1))
        dest="${DEST_DIR}/${PROJECT_NAME}.${ext}"

        if [ -f "$dest" ] && [ "${FORCE}" -ne 1 ]; then
            if cmp -s "$src" "$dest"; then
                echo "  [SKIP] ${PROJECT_NAME}.${ext} (unchanged)"
                SKIPPED=$((SKIPPED + 1))
                continue
            fi
        fi

        cp "$src" "$dest"
        echo "  [COPY] ${PROJECT_NAME}.${ext} ($(stat --format=%s "$src") bytes)"
        COPIED=$((COPIED + 1))
    fi
done

if [ ${FOUND} -eq 0 ]; then
    echo "::warning::No firmware files found in ${SRC_DIR}"
    echo "  Please build the firmware first in Simplicity Studio."
    exit 1
fi

echo ""
echo "--- Git status ---"
if command -v git &>/dev/null && [ -d "${PROJECT_ROOT}/.git" ]; then
    cd "${PROJECT_ROOT}"
    git status --short prebuilt/ 2>/dev/null || true
    cd "${SCRIPT_PATH}"
fi

echo ""
echo "============================================"
echo "Sync completed."
echo "Files found:  ${FOUND}"
echo "Files copied: ${COPIED}"
echo "Files skipped: ${SKIPPED} (unchanged)"
echo "============================================"

if [ ${COPIED} -gt 0 ]; then
    echo ""
    echo "Next steps:"
    echo "  git add prebuilt/"
    echo "  git commit -m 'chore: update prebuilt firmware'"
    echo "  git push origin main"
fi

exit 0