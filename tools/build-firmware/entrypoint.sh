#!/bin/bash

set +e

echo "============================================"
echo "  Embedded Firmware Builder"
echo "============================================"
echo ""

echo "[Builder] Environment check:"
echo "  ARM GCC: $(arm-none-eabi-gcc --version 2>/dev/null | head -1 || echo 'NOT FOUND')"
echo "  CMake:   $(cmake --version 2>/dev/null | head -1 || echo 'NOT FOUND')"
echo "  Ninja:   $(ninja --version 2>/dev/null || echo 'NOT FOUND')"
echo ""

WORKSPACE="${GITHUB_WORKSPACE:-/github/workspace}"
CMAKE_PRESET="${INPUT_CMAKE_PRESET:-project}"
BUILD_CONFIG="${INPUT_BUILD_CONFIG:-base}"
SDK_PATH="${INPUT_SDK_PATH:-/opt/simplicity-sdk}"
FAIL_ON_ERROR="${INPUT_FAIL_ON_ERROR:-false}"
TIMEOUT="${INPUT_TIMEOUT:-10}"

echo "[Builder] Workspace: ${WORKSPACE}"
echo "[Builder] CMake preset: ${CMAKE_PRESET}"
echo "[Builder] Build config: ${BUILD_CONFIG}"
echo "[Builder] SDK path: ${SDK_PATH}"
echo ""

detect_project() {
    local cmake_dir=""
    if [ -f "${WORKSPACE}/cmake_gcc/CMakePresets.json" ]; then
        cmake_dir="${WORKSPACE}/cmake_gcc"
    elif [ -f "${WORKSPACE}/CMakePresets.json" ]; then
        cmake_dir="${WORKSPACE}"
    elif [ -f "${WORKSPACE}/CMakeLists.txt" ]; then
        cmake_dir="${WORKSPACE}"
    fi
    echo "${cmake_dir}"
}

CMAKE_DIR=$(detect_project)

if [ -z "${CMAKE_DIR}" ]; then
    echo "::error::No CMake project found (CMakePresets.json or CMakeLists.txt)"
    echo "::set-output name=success::false"
    exit 1
fi

echo "[Builder] Project CMake directory: ${CMAKE_DIR}"

PROJECT_NAME=$(basename "${WORKSPACE}")
OUT_DIR="${WORKSPACE}/artifacts/${PROJECT_NAME}"
mkdir -p "${OUT_DIR}"

echo ""
echo "[Builder] Configuring CMake..."

cd "${CMAKE_DIR}"

CONFIGURE_ARGS=""
if [ -d "${SDK_PATH}" ]; then
    echo "[Builder] SDK found at: ${SDK_PATH}"
    CONFIGURE_ARGS="-DSIMPLICITY_SDK=${SDK_PATH}"
else
    echo "::warning::SDK directory not found at ${SDK_PATH}"
    echo "[Builder] Attempting build anyway..."
fi

cmake --preset "${CMAKE_PRESET}" \
    -D"CMAKE_CONFIGURATION_TYPES=${BUILD_CONFIG}" \
    ${CONFIGURE_ARGS} \
    2>&1
CONFIGURE_RESULT=$?

if [ ${CONFIGURE_RESULT} -ne 0 ]; then
    echo "::warning::CMake configure failed with exit code ${CONFIGURE_RESULT}"
    if [ "${FAIL_ON_ERROR}" == "true" ]; then
        echo "::error::Configuration failed"
        echo "::set-output name=success::false"
        exit 1
    fi
fi

BUILD_DIR="${CMAKE_DIR}/build"
if [ ! -d "${BUILD_DIR}" ]; then
    echo "[Builder] Build directory not created. Aborting."
    echo "::set-output name=success::false"
    if [ "${FAIL_ON_ERROR}" == "true" ]; then
        exit 1
    fi
fi

echo ""
echo "[Builder] Building project (config: ${BUILD_CONFIG})..."
echo "[Builder] Timeout: ${TIMEOUT} minutes"

cd "${CMAKE_DIR}"

timeout "${TIMEOUT}m" cmake --build "${BUILD_DIR}" --config "${BUILD_CONFIG}" 2>&1
BUILD_RESULT=$?

cd "${WORKSPACE}"

if [ ${BUILD_RESULT} -eq 124 ]; then
    echo "::error::Build timed out after ${TIMEOUT} minutes"
    echo "::set-output name=success::false"
    exit 1
fi

if [ ${BUILD_RESULT} -ne 0 ]; then
    echo "::error::Build failed with exit code ${BUILD_RESULT}"
    echo "::set-output name=success::false"
    if [ "${FAIL_ON_ERROR}" == "true" ]; then
        exit 1
    fi
fi

FW_DIR="${BUILD_DIR}/${BUILD_CONFIG}"
if [ ! -d "${FW_DIR}" ]; then
    FW_DIR="${BUILD_DIR}"
fi

echo ""
echo "[Builder] Copying firmware artifacts from ${FW_DIR}..."

copied=0
for ext in .bin .hex .s37 .map .out; do
    src="${FW_DIR}/${PROJECT_NAME}${ext}"
    if [ -f "${src}" ]; then
        cp "${src}" "${OUT_DIR}/"
        echo "  Copied: ${PROJECT_NAME}${ext}"
        copied=$((copied + 1))
    fi
done

if [ ${copied} -eq 0 ]; then
    echo "::warning::No firmware artifacts found in ${FW_DIR}"
    echo "[Builder] Directory contents:"
    ls -la "${FW_DIR}/" 2>/dev/null || echo "  (directory not found)"
else
    echo ""
    echo "[Builder] Build completed successfully!"
    echo "[Builder] Artifacts:"
    ls -la "${OUT_DIR}/"
fi

cat > "${GITHUB_OUTPUT}" << EOF
success=$([ ${copied} -gt 0 ] && echo "true" || echo "false")
artifacts_dir=${OUT_DIR}
EOF

echo ""
echo "============================================"
echo "  Build finished: $([ ${copied} -gt 0 ] && echo 'SUCCESS' || echo 'FAILED')"
echo "============================================"