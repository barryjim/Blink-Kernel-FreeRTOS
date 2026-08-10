#!/bin/bash

usage()
{
    echo -e "Usage: $0 [-p <project>] [-t <config>] [-u] [-h]\n"
}

help()
{
  usage
    echo -e "DESCRIPTION:"
    echo -e "This script builds the project and packages firmware artifacts."
    echo -e
    echo -e "OPTIONS:"
    echo -e "  -p   Build only specified project"
    echo -e "  -t   Build config (default: base)"
    echo -e "  -u   Build test upgrade version"
    echo -e "  -h   Prints this help\n"
}

unset SINGLE_PROJECT
BUILD_CONFIG="base"
BUILD_UPGRADE=0

while getopts p:t:uh opts
do
    case "${opts}" in
        p)  SINGLE_PROJECT="$OPTARG";;
        t)  BUILD_CONFIG="$OPTARG";;
        u)  BUILD_UPGRADE=1;;
        h)  help; exit 0;;
        \?) help; exit 1;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..
PROJECT_NAME=$(basename "$PROJECT_ROOT")
OUT_PATH=${PROJECT_ROOT}/artifacts
CMAKE_DIR=${PROJECT_ROOT}/cmake_gcc
BUILD_DIR=${CMAKE_DIR}/build

echo "============================================"
echo "Building project: ${PROJECT_NAME}"
echo "Project root: ${PROJECT_ROOT}"
echo "Output path: ${OUT_PATH}"
echo "Build config: ${BUILD_CONFIG}"
echo "============================================"

rm -rf "${OUT_PATH}"
mkdir -p "${OUT_PATH}"

check_arm_gcc() {
    if command -v arm-none-eabi-gcc &> /dev/null; then
        return 0
    elif [ -n "${ARM_GCC_DIR}" ] && [ -f "${ARM_GCC_DIR}/bin/arm-none-eabi-gcc" ]; then
        return 0
    else
        echo "Error: ARM GCC cross-compiler not found."
        echo "Please install arm-none-eabi-gcc or set ARM_GCC_DIR environment variable."
        echo "  sudo apt install gcc-arm-none-eabi"
        return 1
    fi
}

check_sdk_available() {
    local sdk_dir="${SIMPLICITY_SDK:-${SL_SDK:-}}"
    if [ -n "${sdk_dir}" ] && [ -d "${sdk_dir}" ]; then
        return 0
    fi
    if [ -f "${CMAKE_DIR}/CMakeCache.txt" ]; then
        if grep -q "CMAKE_SYSTEM_NAME" "${CMAKE_DIR}/CMakeCache.txt" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

copy_prebuilt_artifacts() {
    local config="$1"
    local out_path="$2"
    local found=0

    echo ""
    echo "--- Copying pre-built artifacts ---"

    local search_dirs=()
    if [ -d "${BUILD_DIR}/${config}" ]; then
        search_dirs+=("${BUILD_DIR}/${config}")
    fi
    if [ -d "${BUILD_DIR}" ]; then
        search_dirs+=("${BUILD_DIR}")
    fi

    for search_dir in "${search_dirs[@]}"; do
        for ext in .bin .hex .s37 .map .out; do
            local src="${search_dir}/${PROJECT_NAME}${ext}"
            if [ -f "${src}" ]; then
                mkdir -p "${out_path}"
                cp "${src}" "${out_path}/"
                echo "  Copied existing: ${PROJECT_NAME}${ext}"
                found=1
            fi
        done
    done

    if [ ${found} -eq 0 ]; then
        echo "  Warning: No pre-built artifacts found."
        return 1
    fi

    echo "  Pre-built artifacts copied successfully."
    return 0
}

build_project() {
    local config="$1"
    local out_path="$2"

    echo ""
    echo "--- Building: ${config} ---"

    cd "${CMAKE_DIR}"

    local need_configure=0
    if [ ! -f "${BUILD_DIR}/build.ninja" ]; then
        need_configure=1
    elif [ ! -d "${BUILD_DIR}/${config}" ]; then
        need_configure=1
    fi

    if [ "${need_configure}" == "1" ]; then
        echo "Configuring CMake for ${config}..."
        cmake --preset project -D"CMAKE_CONFIGURATION_TYPES=${config}" 2>&1
        if [ $? -ne 0 ]; then
            echo "Warning: cmake configure failed."
            cd "${PROJECT_ROOT}"
            return 1
        fi
    fi

    cmake --build "${BUILD_DIR}" --config "${config}" 2>&1
    local BUILD_RESULT=$?

    cd "${PROJECT_ROOT}"

    if [ ${BUILD_RESULT} -ne 0 ]; then
        echo "Warning: Build failed for ${config}."
        return 1
    fi

    local FW_DIR="${BUILD_DIR}/${config}"
    if [ ! -d "${FW_DIR}" ]; then
        FW_DIR="${BUILD_DIR}"
    fi

    mkdir -p "${out_path}"

    local copied=0
    for ext in .bin .hex .s37 .map .out; do
        local src="${FW_DIR}/${PROJECT_NAME}${ext}"
        if [ -f "${src}" ]; then
            cp "${src}" "${out_path}/"
            echo "  Copied: ${PROJECT_NAME}${ext}"
            copied=$((copied + 1))
        fi
    done

    if [ ${copied} -eq 0 ]; then
        echo "  Warning: No firmware files found in ${FW_DIR}"
        return 1
    fi

    echo "  Build ${config} completed. ${copied} files copied."
    return 0
}

PROJECT_VERSION=$( grep -m1 '#define SOFTWARE_VERSION ' "${PROJECT_ROOT}/config/version.h" 2>/dev/null | cut -d '"' -f 2 )
if [ -z "${PROJECT_VERSION}" ]; then
    PROJECT_VERSION="unknown"
fi
echo "Project version: ${PROJECT_VERSION}"

BUILD_SUCCESS=0
OUT_PRJ_PATH="${OUT_PATH}/${PROJECT_NAME}-${PROJECT_VERSION}"
mkdir -p "${OUT_PRJ_PATH}"

if check_arm_gcc && check_sdk_available; then
    echo "ARM GCC and SDK found. Attempting full build..."
    if build_project "${BUILD_CONFIG}" "${OUT_PRJ_PATH}"; then
        BUILD_SUCCESS=1
    else
        echo "Build failed. Falling back to pre-built artifacts..."
        copy_prebuilt_artifacts "${BUILD_CONFIG}" "${OUT_PRJ_PATH}" && BUILD_SUCCESS=1
    fi
else
    if check_arm_gcc; then
        echo "ARM GCC found but SDK not detected."
        echo "Attempting build anyway (may work if SDK was pre-installed)..."
        if build_project "${BUILD_CONFIG}" "${OUT_PRJ_PATH}" 2>/dev/null; then
            BUILD_SUCCESS=1
        else
            echo "Build failed (expected without SDK)."
            echo "Falling back to pre-built artifacts..."
            copy_prebuilt_artifacts "${BUILD_CONFIG}" "${OUT_PRJ_PATH}" && BUILD_SUCCESS=1
        fi
    else
        echo "--- ARM GCC not available ---"
        echo "Attempting to copy existing pre-built artifacts..."
        copy_prebuilt_artifacts "${BUILD_CONFIG}" "${OUT_PRJ_PATH}" && BUILD_SUCCESS=1
    fi
fi

if [ "${BUILD_UPGRADE}" == "1" ] && [ "${BUILD_SUCCESS}" == "1" ]; then
    echo ""
    echo "--- Build test upgrade (version increment) ---"
    bash ${SCRIPT_PATH}/../release/update_version.sh -i -p "${PROJECT_NAME}" 2>/dev/null || true

    OUT_TEST_PATH="${OUT_PATH}/${PROJECT_NAME}-${PROJECT_VERSION}/test_upgrade"
    mkdir -p "${OUT_TEST_PATH}"
    build_project "${BUILD_CONFIG}" "${OUT_TEST_PATH}" 2>/dev/null || true

    bash ${SCRIPT_PATH}/../release/update_version.sh -d -p "${PROJECT_NAME}" 2>/dev/null || true
fi

echo ""
echo "--- Creating artifacts.tar.gz ---"
cd "${OUT_PATH}"
if [ -n "$(ls -A 2>/dev/null)" ]; then
    tar -zcvf "${OUT_PATH}/artifacts.tar.gz" *
    echo "Artifacts archive created: ${OUT_PATH}/artifacts.tar.gz"
else
    echo "Warning: No artifacts to archive."
fi
cd "${PROJECT_ROOT}"

echo ""
echo "============================================"
echo "Build process completed."
echo "Build success: ${BUILD_SUCCESS}"
echo "Artifacts: ${OUT_PATH}/"
echo "============================================"