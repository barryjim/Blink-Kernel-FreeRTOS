#!/bin/bash

set +e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."

echo "============================================"
echo "  Test Composite Action Locally"
echo "============================================"
echo ""
echo "This script simulates what the composite GitHub Action does,"
echo "but runs it locally against your project."
echo ""

usage() {
    echo "Usage: $0 [--configure] [--build] [--artifacts] [--all] [--clean]"
    echo ""
    echo "Options:"
    echo "  --configure   Run CMake configure only"
    echo "  --build       Run CMake build only"
    echo "  --artifacts   Collect firmware artifacts"
    echo "  --all         Run configure + build + artifacts (default)"
    echo "  --clean       Remove build artifacts"
    echo "  --help        Show this help"
    echo ""
    echo "Environment variables:"
    echo "  CMAKE_PRESET  CMake preset name (default: project)"
    echo "  BUILD_CONFIG  Build config name (default: base)"
    echo "  FAIL_ON_ERROR Exit non-zero on build failure (default: no)"
    exit 0
}

DO_CONFIGURE=0
DO_BUILD=0
DO_ARTIFACTS=0
DO_CLEAN=0

CMAKE_PRESET="${CMAKE_PRESET:-project}"
BUILD_CONFIG="${BUILD_CONFIG:-base}"
FAIL_ON_ERROR="${FAIL_ON_ERROR:-false}"

if [ $# -eq 0 ]; then
    DO_CONFIGURE=1
    DO_BUILD=1
    DO_ARTIFACTS=1
fi

for arg in "$@"; do
    case "$arg" in
        --configure) DO_CONFIGURE=1 ;;
        --build) DO_BUILD=1 ;;
        --artifacts) DO_ARTIFACTS=1 ;;
        --all) DO_CONFIGURE=1; DO_BUILD=1; DO_ARTIFACTS=1 ;;
        --clean) DO_CLEAN=1 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg"; usage ;;
    esac
done

CMAKE_DIR="${PROJECT_ROOT}/cmake_gcc"
BUILD_DIR="${CMAKE_DIR}/build"
PROJECT_NAME="blink_kernel_freertos_s3"
OUT_DIR="${PROJECT_ROOT}/artifacts/${PROJECT_NAME}"

cd "${PROJECT_ROOT}"

if [ "${DO_CLEAN}" -eq 1 ]; then
    echo "[CLEAN] Removing build artifacts..."
    rm -rf "${BUILD_DIR}"
    rm -rf "${PROJECT_ROOT}/artifacts"
    rm -rf "${PROJECT_ROOT}/code_quality_report"
    echo "[CLEAN] Done."
    exit 0
fi

CMAKE_DIR_FOUND=""
if [ -f "${CMAKE_DIR}/CMakePresets.json" ]; then
    CMAKE_DIR_FOUND="${CMAKE_DIR}"
elif [ -f "${PROJECT_ROOT}/CMakePresets.json" ]; then
    CMAKE_DIR_FOUND="${PROJECT_ROOT}"
else
    echo "Error: No CMakePresets.json found."
    echo "Searched:"
    echo "  ${CMAKE_DIR}/CMakePresets.json"
    echo "  ${PROJECT_ROOT}/CMakePresets.json"
    exit 1
fi

echo "[INFO] CMake directory: ${CMAKE_DIR_FOUND}"
echo "[INFO] CMake preset:    ${CMAKE_PRESET}"
echo "[INFO] Build config:    ${BUILD_CONFIG}"
echo ""

if [ "${DO_CONFIGURE}" -eq 1 ]; then
    echo "--- Step 1: CMake Configure ---"
    cd "${CMAKE_DIR_FOUND}"

    if ! command -v cmake &>/dev/null; then
        echo "Error: cmake not found. Install cmake first."
        exit 1
    fi

    echo "Running: cmake --preset ${CMAKE_PRESET} -D'CMAKE_CONFIGURATION_TYPES=${BUILD_CONFIG}'"
    if cmake --preset "${CMAKE_PRESET}" -D"CMAKE_CONFIGURATION_TYPES=${BUILD_CONFIG}" 2>&1; then
        echo "[OK] CMake configure succeeded."
    else
        echo "[WARN] CMake configure had issues. Check the output above."
        if [ "${FAIL_ON_ERROR}" == "true" ]; then
            exit 1
        fi
    fi
    cd "${PROJECT_ROOT}"
    echo ""
fi

if [ "${DO_BUILD}" -eq 1 ]; then
    echo "--- Step 2: CMake Build ---"

    if [ ! -d "${BUILD_DIR}" ]; then
        echo "Error: Build directory not found. Run --configure first."
        exit 1
    fi

    if ! command -v cmake &>/dev/null; then
        echo "Error: cmake not found."
        exit 1
    fi

    cd "${CMAKE_DIR_FOUND}"
    echo "Running: cmake --build ${BUILD_DIR} --config ${BUILD_CONFIG}"
    if cmake --build "${BUILD_DIR}" --config "${BUILD_CONFIG}" 2>&1; then
        echo "[OK] Build succeeded."
    else
        BUILD_RESULT=$?
        echo "[WARN] Build failed with exit code ${BUILD_RESULT}."
        if [ "${FAIL_ON_ERROR}" == "true" ]; then
            exit 1
        fi
    fi
    cd "${PROJECT_ROOT}"
    echo ""
fi

if [ "${DO_ARTIFACTS}" -eq 1 ]; then
    echo "--- Step 3: Collect Artifacts ---"
    mkdir -p "${OUT_DIR}"

    FW_DIR="${BUILD_DIR}/${BUILD_CONFIG}"
    if [ ! -d "${FW_DIR}" ]; then
        FW_DIR="${BUILD_DIR}"
    fi

    echo "Source directory: ${FW_DIR}"
    echo "Destination:      ${OUT_DIR}"
    echo ""

    if [ ! -d "${FW_DIR}" ]; then
        echo "[WARN] Build directory does not exist. No artifacts to collect."
        echo "       Run with --configure and --build first."
    else
        copied=0
        for ext in .bin .hex .s37 .map .out; do
            src="${FW_DIR}/${PROJECT_NAME}${ext}"
            if [ -f "${src}" ]; then
                cp "${src}" "${OUT_DIR}/"
                size=$(stat --format=%s "${src}" 2>/dev/null || stat -f%z "${src}" 2>/dev/null || echo "?")
                echo "  [OK] Copied: ${PROJECT_NAME}${ext} (${size} bytes)"
                copied=$((copied + 1))
            fi
        done

        if [ ${copied} -eq 0 ]; then
            echo "[WARN] No firmware artifacts found in ${FW_DIR}"
            echo "       Directory contents:"
            ls -la "${FW_DIR}/" 2>/dev/null || echo "       (empty or not found)"
        else
            echo ""
            echo "[OK] Collected ${copied} artifact(s):"
            ls -la "${OUT_DIR}/"
        fi
    fi

    echo ""
    echo "[INFO] Artifact collection complete."
    echo "[INFO] In GitHub Actions, these would be uploaded via actions/upload-artifact."
fi

echo ""
echo "============================================"
echo "  Composite action simulation finished"
echo "============================================"