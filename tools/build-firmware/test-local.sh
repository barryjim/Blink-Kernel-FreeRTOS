#!/bin/bash

set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT="${SCRIPT_PATH}/.."
COMPOSITE_ACTION="${PROJECT_ROOT}/tools/build-firmware/composite"

echo "============================================"
echo "  Test Build Firmware Composite Action"
echo "============================================"
echo ""

if [ ! -d "${COMPOSITE_ACTION}" ]; then
    echo "Error: Composite action not found at ${COMPOSITE_ACTION}"
    exit 1
fi

cat > /tmp/test_composite.sh << 'TESTSCRIPT'
#!/bin/bash

set +e

WORKSPACE="${PROJECT_ROOT}"
CMAKE_PRESET="${1:-project}"
BUILD_CONFIG="${2:-base}"
FAIL_ON_ERROR="${3:-false}"
PROJECT_NAME=$(basename "${WORKSPACE}")

echo "Workspace: ${WORKSPACE}"
echo "CMake preset: ${CMAKE_PRESET}"
echo "Build config: ${BUILD_CONFIG}"
echo ""

CMAKE_DIR=""
if [ -f "${WORKSPACE}/cmake_gcc/CMakePresets.json" ]; then
    CMAKE_DIR="${WORKSPACE}/cmake_gcc"
elif [ -f "${WORKSPACE}/CMakePresets.json" ]; then
    CMAKE_DIR="${WORKSPACE}"
else
    echo "No CMake project found"
    exit 1
fi

echo "CMake directory: ${CMAKE_DIR}"
OUT_DIR="${WORKSPACE}/artifacts/${PROJECT_NAME}"
mkdir -p "${OUT_DIR}"

cd "${CMAKE_DIR}"

echo "Configuring CMake..."
cmake --preset "${CMAKE_PRESET}" -D"CMAKE_CONFIGURATION_TYPES=${BUILD_CONFIG}" 2>&1
CONFIGURE_RESULT=$?

if [ ${CONFIGURE_RESULT} -ne 0 ]; then
    echo "CMake configure failed"
    if [ "${FAIL_ON_ERROR}" == "true" ]; then
        exit 1
    fi
fi

BUILD_DIR="${CMAKE_DIR}/build"
if [ ! -d "${BUILD_DIR}" ]; then
    echo "Build directory not created"
    exit 1
fi

echo "Building..."
cmake --build "${BUILD_DIR}" --config "${BUILD_CONFIG}" 2>&1
BUILD_RESULT=$?

cd "${WORKSPACE}"

if [ ${BUILD_RESULT} -ne 0 ]; then
    echo "Build failed with exit code ${BUILD_RESULT}"
    if [ "${FAIL_ON_ERROR}" == "true" ]; then
        exit 1
    fi
fi

FW_DIR="${BUILD_DIR}/${BUILD_CONFIG}"
if [ ! -d "${FW_DIR}" ]; then
    FW_DIR="${BUILD_DIR}"
fi

echo "Copying artifacts from ${FW_DIR}..."

copied=0
for ext in .bin .hex .s37 .map .out; do
    src="${FW_DIR}/${PROJECT_NAME}${ext}"
    if [ -f "${src}" ]; then
        cp "${src}" "${OUT_DIR}/"
        echo "  Copied: ${PROJECT_NAME}${ext}"
        copied=$((copied + 1))
    fi
done

echo ""
echo "Artifacts:"
ls -la "${OUT_DIR}/" 2>/dev/null || echo "  (none)"
echo ""
echo "Result: $([ ${copied} -gt 0 ] && echo 'SUCCESS' || echo 'NO ARTIFACTS')"
TESTSCRIPT

bash /tmp/test_composite.sh "${PROJECT_ROOT}" "project" "base" "false"

rm -f /tmp/test_composite.sh

echo ""
echo "============================================"
echo "  Test completed"
echo "============================================"