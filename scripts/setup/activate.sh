#!/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT=${SCRIPT_PATH}/../..

echo "Activating environment for: $(basename ${PROJECT_ROOT})"

if [ ! -d "${SCRIPT_PATH}/../../third_party" ]; then
    echo "Third-party tools not found. Running checkout.sh..."
    source ${SCRIPT_PATH}/checkout.sh
fi

# Install Python tools if needed
pip install dload dotenv 2>/dev/null || true

# Check for ARM GCC
if command -v arm-none-eabi-gcc &> /dev/null; then
    echo "ARM GCC: $(arm-none-eabi-gcc --version | head -1)"
else
    echo "Warning: ARM GCC not found. Install with: sudo apt install gcc-arm-none-eabi"
fi

# Check for cmake
if command -v cmake &> /dev/null; then
    echo "CMake: $(cmake --version | head -1)"
else
    echo "Warning: CMake not found. Install with: sudo apt install cmake"
fi

# Check for ninja
if command -v ninja &> /dev/null; then
    echo "Ninja: $(ninja --version)"
else
    echo "Warning: Ninja not found. Install with: sudo apt install ninja-build"
fi

# Check for clang-format
if command -v clang-format &> /dev/null; then
    echo "Clang-Format: $(clang-format --version)"
else
    echo "Warning: clang-format not found. Install with: sudo apt install clang-format"
fi

echo ""
echo "Environment ready."