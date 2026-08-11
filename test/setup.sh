#!/bin/bash
set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_PATH"

echo "=== CMock Unit Test Setup ==="

# 1. Install build essentials if needed
if ! command -v gcc &> /dev/null; then
    echo "Installing build essentials..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq build-essential git
fi

# 2. Download Unity test framework
if [ ! -d "Unity/src" ]; then
    echo "Downloading Unity..."
    git clone --depth 1 https://github.com/ThrowTheSwitch/Unity.git Unity
else
    echo "Unity already present."
fi

echo ""
echo "=== Setup Complete ==="
echo "Run 'make' to build and run the unit tests."