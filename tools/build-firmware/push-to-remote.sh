#!/bin/bash

set -e

TOOL_SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOL_SRC="${TOOL_SRC}/../tools/build-firmware"
TEMP_DIR="/tmp/firmware-builder-push"
REMOTE_URL="https://github.com/barryjim/firmware-builder.git"

usage() {
    echo "Usage: $0 [--init] [--tag v1.0.0]"
    echo ""
    echo "Push firmware-builder tools to remote GitHub repository."
    echo ""
    echo "Options:"
    echo "  --init     Initialize a new git repo and push (first time only)"
    echo "  --tag      Create and push a git tag (e.g., --tag v1.0.0)"
    echo "  --force    Force push (use with caution)"
    echo ""
    echo "Examples:"
    echo "  $0 --init                    # First time setup"
    echo "  $0                           # Sync latest changes"
    echo "  $0 --tag v1.0.0              # Push and create tag v1.0.0"
    echo "  $0 --tag v1.0.0 --force      # Force push with tag"
    exit 0
}

INIT_REPO=0
FORCE_PUSH=0
TAG_NAME=""

for arg in "$@"; do
    case "$arg" in
        --init) INIT_REPO=1 ;;
        --force) FORCE_PUSH=1 ;;
        -h|--help) usage ;;
        --tag) TAG_NAME="${2:-}" ; shift ;;
        *) if [ -z "$TAG_NAME" ] && [[ "$arg" =~ ^v ]]; then TAG_NAME="$arg"; fi ;;
    esac
done

echo "============================================"
echo "  Push firmware-builder to ${REMOTE_URL}"
echo "============================================"
echo ""
echo "  Source: ${TOOL_SRC}"
echo "  Temp:   ${TEMP_DIR}"
echo ""

if [ ! -d "${TOOL_SRC}" ]; then
    echo "Error: Tool source not found at ${TOOL_SRC}"
    exit 1
fi

echo "[1/4] Preparing files..."
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"

cp "${TOOL_SRC}/action.yml" "${TEMP_DIR}/"
cp "${TOOL_SRC}/Dockerfile" "${TEMP_DIR}/"
cp "${TOOL_SRC}/entrypoint.sh" "${TEMP_DIR}/"
cp "${TOOL_SRC}/build.sh" "${TEMP_DIR}/"
cp "${TOOL_SRC}/test-local.sh" "${TEMP_DIR}/"
cp "${TOOL_SRC}/README.md" "${TEMP_DIR}/"

mkdir -p "${TEMP_DIR}/composite"
cp "${TOOL_SRC}/composite/action.yml" "${TEMP_DIR}/composite/"

mkdir -p "${TEMP_DIR}/.github/workflows"
cp "${TOOL_SRC}/.github/workflows/build-image.yml" "${TEMP_DIR}/.github/workflows/"

chmod +x "${TEMP_DIR}/build.sh" "${TEMP_DIR}/test-local.sh" "${TEMP_DIR}/entrypoint.sh"

cd "${TEMP_DIR}"

if [ "${INIT_REPO}" -eq 1 ]; then
    echo "[2/4] Initializing new repository..."
    git init
    git checkout -b main
    git add .
    git commit -m "Initial commit: firmware-builder GitHub Action"
    git remote add origin "${REMOTE_URL}"

    echo "[3/4] Pushing to remote (first time)..."
    git push -u origin main
    echo "Pushed to ${REMOTE_URL}"
else
    if [ ! -d "${TEMP_DIR}/.git" ]; then
        echo "[2/4] Cloning existing repository..."
        git clone "${REMOTE_URL}" .
        git checkout main
    fi

    echo "[3/4] Updating files..."
    git add .
    git commit -m "Update: sync firmware-builder GitHub Action" || echo "No changes to commit."

    echo "[4/4] Pushing to remote..."
    if [ "${FORCE_PUSH}" -eq 1 ]; then
        git push --force origin main
    else
        git push origin main
    fi
    echo "Pushed to ${REMOTE_URL}"
fi

if [ -n "${TAG_NAME}" ]; then
    echo ""
    echo "Creating tag: ${TAG_NAME}"
    git tag -a "${TAG_NAME}" -m "Release ${TAG_NAME}"
    git push origin "${TAG_NAME}"
    echo "Tag ${TAG_NAME} pushed."
fi

echo ""
echo "============================================"
echo "  Done! Tools pushed to ${REMOTE_URL}"
if [ -n "${TAG_NAME}" ]; then
    echo "  Tag: ${TAG_NAME}"
    echo "  Usage in workflows: barryjim/firmware-builder@${TAG_NAME}"
    echo "  Composite: barryjim/firmware-builder/composite@${TAG_NAME}"
fi
echo "============================================"