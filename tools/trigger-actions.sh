#!/bin/bash
# ============================================================
# Trigger GitHub Actions workflow via GitHub CLI (gh)
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [ci|release|tag] [options]"
    echo ""
    echo "Commands:"
    echo "  ci             Trigger CI workflow (workflow_dispatch)"
    echo "  release        Trigger Release workflow via workflow_dispatch"
    echo "  tag            Create and push a tag to trigger Release"
    echo ""
    echo "Options:"
    echo "  -t, --tag VERSION    Tag version (e.g., v1.0.0)"
    echo "  -b, --branch BRANCH  Target branch (default: main)"
    echo "  -w, --wait           Wait for workflow to complete"
    echo "  -n, --name NAME      Repository name (default: from .git config)"
    echo "  -h, --help           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 ci                           # Trigger CI via workflow_dispatch"
    echo "  $0 release                      # Trigger Release via workflow_dispatch"
    echo "  $0 tag -t v1.0.1               # Create tag v1.0.1, trigger Release"
    echo "  $0 ci --wait                    # Trigger CI and wait for result"
    echo ""
    exit 0
}

COMMAND="${1:-}"
shift || true

BRANCH="main"
WAIT=0
TAG_VERSION=""
REPO_NAME=""

while [ $# -gt 0 ]; do
    case "$1" in
        -t|--tag)     TAG_VERSION="$2"; shift 2 ;;
        -b|--branch)  BRANCH="$2"; shift 2 ;;
        -w|--wait)    WAIT=1; shift ;;
        -n|--name)    REPO_NAME="$2"; shift 2 ;;
        -h|--help)    usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [ -z "$COMMAND" ]; then
    usage
fi

if ! command -v gh &>/dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) not found.${NC}"
    echo "Install: https://cli.github.com/"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt install gh"
    echo "  or: sudo snap install gh"
    echo ""
    echo "Then login:"
    echo "  gh auth login"
    exit 1
fi

if ! gh auth status 2>/dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub.${NC}"
    echo "Run: gh auth login"
    exit 1
fi

if [ -z "$REPO_NAME" ]; then
    REPO_NAME=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null || echo "")
    if [ -z "$REPO_NAME" ]; then
        REPO_NAME="blink_kernel_freertos_s3"
    fi
fi

OWNER=$(gh auth status 2>/dev/null | grep -oP 'Logged in as \K[^ ]+' || echo "")
if [ -z "$OWNER" ]; then
    OWNER=$(gh api user -q .login 2>/dev/null || echo "barryjim")
fi

REPO="${OWNER}/${REPO_NAME}"

echo -e "${CYAN}Repository: ${REPO}${NC}"
echo ""

check_workflow_exists() {
    local wf_name="$1"
    if gh workflow list --repo "${REPO}" 2>/dev/null | grep -qi "${wf_name}"; then
        return 0
    else
        echo -e "${YELLOW}Warning: Workflow '${wf_name}' not found in repository.${NC}"
        echo "Make sure you have pushed the .github/workflows/ files."
        return 1
    fi
}

wait_for_run() {
    local run_id="$1"
    local wf_name="$2"

    echo ""
    echo -e "${CYAN}Waiting for workflow to complete...${NC}"
    echo ""

    while true; do
        RUN_LIST=$(gh run list --repo "${REPO}" --workflow "${wf_name}" --limit 1 2>/dev/null)
        if [ -z "$RUN_LIST" ]; then
            sleep 5
            continue
        fi

        STATUS=$(echo "$RUN_LIST" | awk '{print $4}')
        CONCLUSION=$(echo "$RUN_LIST" | awk '{print $5}')

        if [ "$STATUS" = "completed" ]; then
            if [ "$CONCLUSION" = "success" ]; then
                echo -e "${GREEN}Workflow completed: ${CONCLUSION}${NC}"
                return 0
            else
                echo -e "${RED}Workflow completed: ${CONCLUSION}${NC}"
                echo ""
                echo "View details: https://github.com/${REPO}/actions/runs/${run_id}"
                return 1
            fi
        fi

        echo -e "  Status: ${STATUS}..."
        sleep 10
    done
}

case "$COMMAND" in
    ci)
        echo -e "${GREEN}Triggering CI workflow...${NC}"
        check_workflow_exists "CI" || true
        gh workflow run "CI" --repo "${REPO}" --ref "${BRANCH}"

        if [ "${WAIT}" -eq 1 ]; then
            sleep 3
            RUN_ID=$(gh run list --repo "${REPO}" --workflow "CI" --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null)
            wait_for_run "${RUN_ID}" "CI"
        else
            echo ""
            echo -e "${GREEN}CI workflow triggered!${NC}"
            echo "View: https://github.com/${REPO}/actions"
        fi
        ;;

    release)
        echo -e "${GREEN}Triggering Release workflow...${NC}"
        check_workflow_exists "Release" || true

        INPUTS=""
        if [ -n "${TAG_VERSION}" ]; then
            INPUTS="--field tag_name=${TAG_VERSION}"
        fi

        gh workflow run "Release" --repo "${REPO}" --ref "${BRANCH}" ${INPUTS}

        if [ "${WAIT}" -eq 1 ]; then
            sleep 3
            wait_for_run "" "Release"
        else
            echo ""
            echo -e "${GREEN}Release workflow triggered!${NC}"
            echo "View: https://github.com/${REPO}/actions"
        fi
        ;;

    tag)
        if [ -z "${TAG_VERSION}" ]; then
            echo -e "${RED}Error: Tag version required. Use -t v1.0.0${NC}"
            exit 1
        fi

        echo -e "${GREEN}Creating tag ${TAG_VERSION}...${NC}"

        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        PROJECT_ROOT="${SCRIPT_DIR}/.."

        cd "${PROJECT_ROOT}"

        git tag -a "${TAG_VERSION}" -m "Release ${TAG_VERSION}" 2>/dev/null || \
            git tag -a "blink_kernel_freertos_s3-${TAG_VERSION}" -m "Release ${TAG_VERSION}"

        if git ls-remote --tags origin "${TAG_VERSION}" 2>/dev/null | grep -q .; then
            echo -e "${YELLOW}Tag ${TAG_VERSION} already exists. Deleting and recreating...${NC}"
            git tag -d "${TAG_VERSION}" 2>/dev/null
            git push origin ":refs/tags/${TAG_VERSION}" 2>/dev/null
        fi

        git push origin "${TAG_VERSION}"
        echo -e "${GREEN}Tag ${TAG_VERSION} pushed!${NC}"
        echo ""
        echo "This should trigger the Release workflow."
        echo -e "${GREEN}View: https://github.com/${REPO}/actions${NC}"

        if [ "${WAIT}" -eq 1 ]; then
            sleep 5
            wait_for_run "" "Release"
        fi
        ;;

    *)
        echo "Unknown command: $COMMAND"
        usage
        ;;
esac