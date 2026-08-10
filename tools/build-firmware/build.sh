#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IMAGE_NAME="firmware-builder"
REGISTRY="${REGISTRY:-ghcr.io}"
OWNER="${OWNER:-barryjim}"
TAG="${1:-latest}"

usage() {
    echo "Usage: $0 [tag] [--push]"
    echo ""
    echo "Build the firmware-builder Docker image."
    echo ""
    echo "Arguments:"
    echo "  tag     Image tag (default: latest)"
    echo "  --push  Push image to registry after build"
    echo ""
    echo "Environment variables:"
    echo "  REGISTRY  Container registry (default: ghcr.io)"
    echo "  OWNER     Registry owner/namespace (default: barryjim)"
    exit 0
}

PUSH_IMAGE=0
for arg in "$@"; do
    case "$arg" in
        --push) PUSH_IMAGE=1 ;;
        -h|--help) usage ;;
        *) TAG="$arg" ;;
    esac
done

FULL_IMAGE="${REGISTRY}/${OWNER}/${IMAGE_NAME}:${TAG}"

echo "============================================"
echo "  Build firmware-builder Docker Image"
echo "============================================"
echo ""
echo "  Image:  ${FULL_IMAGE}"
echo "  Docker: $(docker --version)"
echo ""

cd "${SCRIPT_DIR}"

echo "[1/3] Building image..."
docker build -t "${FULL_IMAGE}" .
echo "Build completed."

echo "[2/3] Verifying image..."
docker run --rm "${FULL_IMAGE}" bash -c "
    echo 'Tools check:'
    arm-none-eabi-gcc --version 2>/dev/null | head -1 || echo '  ARM GCC: MISSING'
    cmake --version 2>/dev/null | head -1 || echo '  CMake: MISSING'
    ninja --version 2>/dev/null || echo '  Ninja: MISSING'
    echo 'Done.'
"

if [ ${PUSH_IMAGE} -eq 1 ]; then
    echo "[3/3] Pushing image to ${REGISTRY}..."
    if [[ "${REGISTRY}" == "ghcr.io" ]]; then
        echo "Please login first: docker login ghcr.io"
        echo "Username: \${GITHUB_ACTOR}"
        echo "Password: \${GITHUB_TOKEN}"
    fi
    docker push "${FULL_IMAGE}"
    echo "Push completed: ${FULL_IMAGE}"
else
    echo "[3/3] Skipping push (use --push to enable)"
fi

echo ""
echo "============================================"
echo "  Image ready: ${FULL_IMAGE}"
echo "============================================"