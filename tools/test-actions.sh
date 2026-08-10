#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/.."

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [ci|release] [event]"
    echo ""
    echo "Simulate GitHub Actions workflows locally."
    echo ""
    echo "Commands:"
    echo "  ci          Run CI workflow simulation"
    echo "  release     Run Release workflow simulation"
    echo "  all         Run CI + Release simulation"
    echo ""
    echo "Options:"
    echo "  --use-act   Use 'act' tool to run real GitHub Actions"
    echo "  --dry-run   Only print what would be done"
    echo ""
    echo "Examples:"
    echo "  $0 ci                    # Simulate CI workflow"
    echo "  $0 release               # Simulate Release workflow"
    echo "  $0 ci --use-act          # Run CI with act tool"
    echo "  $0 release --dry-run     # Preview Release workflow steps"
    exit 0
}

COMMAND="${1:-all}"
USE_ACT=0
DRY_RUN=0

for arg in "$@"; do
    case "$arg" in
        --use-act) USE_ACT=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help) usage ;;
    esac
done

run_step() {
    local name="$1"
    local cmd="$2"
    local critical="${3:-false}"

    echo -e "  ${CYAN}▶${NC} ${name}"
    if [ "${DRY_RUN}" -eq 1 ]; then
        echo -e "    ${YELLOW}[DRY-RUN]${NC} Would run: ${cmd}"
        return 0
    fi

    if eval "${cmd}" 2>&1; then
        echo -e "  ${GREEN}✔${NC} ${name}"
        return 0
    else
        echo -e "  ${RED}✘${NC} ${name} (exit: $?)"
        if [ "${critical}" == "true" ]; then
            echo -e "  ${RED}FATAL: Critical step failed.${NC}"
            exit 1
        fi
        return 1
    fi
}

print_banner() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   GitHub Actions Local Simulation            ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

simulate_ci() {
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  CI Workflow Simulation${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""
    echo "Jobs: CodeAnalysis, FormatCheck, Build"
    echo ""

    echo -e "${YELLOW}--- Job: CodeAnalysis ---${NC}"

    run_step "Make scripts executable" \
        "chmod +x scripts/*/*.sh scripts/**/*.sh"

    run_step "Setup tools (apt)" \
        "sudo apt-get update -qq && sudo apt-get install -y -qq git python3-pip"

    run_step "Setup cpplint" \
        "mkdir -p third_party && [ -d third_party/cpplint ] || git clone --depth 1 https://github.com/cpplint/cpplint.git third_party/cpplint"

    run_step "Setup cppcheck" \
        "bash scripts/cppcheck/setup.sh"

    run_step "Run cpplint" \
        "bash scripts/linter/linter.sh -p"

    run_step "Run cppcheck" \
        "bash scripts/cppcheck/runner.sh"

    echo ""
    echo -e "${YELLOW}--- Job: FormatCheck ---${NC}"

    run_step "Install clang-format" \
        "sudo apt-get install -y -qq clang-format"

    run_step "Check formatting (dry run)" \
        "bash scripts/format/format.sh -d"

    echo ""
    echo -e "${YELLOW}--- Job: Build (on push to main) ---${NC}"

    run_step "Simulate composite action build" \
        "bash tools/test-composite.sh --configure --build --artifacts"
}

simulate_release() {
    local tag_name="${TAG_NAME:-v1.0.0}"

    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Release Workflow Simulation${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════${NC}"
    echo ""
    echo "Trigger: push tag '${tag_name}'"
    echo "Jobs: CodeAnalysis, Build, Release"
    echo ""

    echo -e "${YELLOW}--- Job: CodeAnalysis ---${NC}"

    run_step "Make scripts executable" \
        "chmod +x scripts/*/*.sh scripts/**/*.sh"

    run_step "Setup tools" \
        "sudo apt-get update -qq && sudo apt-get install -y -qq git python3-pip"

    run_step "Setup cpplint" \
        "mkdir -p third_party && [ -d third_party/cpplint ] || git clone --depth 1 https://github.com/cpplint/cpplint.git third_party/cpplint"

    run_step "Run cpplint" \
        "bash scripts/linter/linter.sh -p"

    echo ""
    echo -e "${YELLOW}--- Job: Build ---${NC}"

    run_step "Determine tag version" \
        "VERSION=\$(echo '${tag_name}' | sed 's/^v//' | sed 's/^blink_kernel_freertos_s3-//'); echo \"Version: \${VERSION}\""

    run_step "Build firmware (best effort)" \
        "bash tools/test-composite.sh --configure --build --artifacts || true"

    run_step "Package artifacts" \
        "cd artifacts && tar -zcvf artifacts.tar.gz blink_kernel_freertos_s3/ 2>/dev/null || touch artifacts.tar.gz"

    echo ""
    echo -e "${YELLOW}--- Job: Create GitHub Release ---${NC}"

    echo -e "  ${CYAN}▶${NC} Creating GitHub Release for tag '${tag_name}'..."
    echo -e "  ${YELLOW}[DRY-RUN]${NC} Would call: softprops/action-gh-release@v2"
    echo -e "    - files: artifacts/artifacts.tar.gz"
    echo -e "    - generate_release_notes: true"
    echo ""

    if [ -f "artifacts/artifacts.tar.gz" ] && [ -s "artifacts/artifacts.tar.gz" ]; then
        echo -e "  ${GREEN}✔${NC} Release would be created with artifacts"
        echo -e "  ${GREEN}✔${NC} File: artifacts/artifacts.tar.gz ($(stat --format=%s artifacts/artifacts.tar.gz 2>/dev/null || echo '?') bytes)"
    else
        echo -e "  ${YELLOW}⚠${NC} No firmware artifacts (expected on non-SDK machines)"
        echo -e "  ${YELLOW}⚠${NC} Release would be created with code quality reports only"
        echo -e "  ${CYAN}ℹ${NC} Build locally with Simplicity Studio and upload .bin/.hex manually"
    fi
}

use_act() {
    if ! command -v act &>/dev/null; then
        echo "Error: 'act' tool not found."
        echo "Install it from: https://github.com/nektos/act"
        echo ""
        echo "Quick install:"
        echo "  curl -fsSL https://raw.githubusercontent.com/nektos/act/master/install.sh | bash"
        echo ""
        echo "Or use: $0 ci (local simulation without act)"
        exit 1
    fi

    echo "Using 'act' to run real GitHub Actions..."
    echo ""

    case "${COMMAND}" in
        ci)
            act -W .github/workflows/ci.yml
            ;;
        release)
            act -W .github/workflows/release.yml -e "{\"ref\":\"refs/tags/${TAG_NAME:-v1.0.0}\"}"
            ;;
        *)
            act -W .github/workflows/ci.yml
            act -W .github/workflows/release.yml -e "{\"ref\":\"refs/tags/${TAG_NAME:-v1.0.0}\"}"
            ;;
    esac
}

# ============================================================
# Main
# ============================================================

print_banner

if [ "${USE_ACT}" -eq 1 ]; then
    use_act
    exit $?
fi

cd "${PROJECT_ROOT}"

case "${COMMAND}" in
    ci)
        simulate_ci
        ;;
    release)
        simulate_release
        ;;
    all)
        simulate_ci
        echo ""
        echo "============================================================"
        echo ""
        simulate_release
        ;;
    *)
        echo "Unknown command: ${COMMAND}"
        usage
        ;;
esac

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Simulation Complete                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo "For real GitHub Actions execution, push to GitHub and:"
echo "  - Actions page: https://github.com/barryjim/blink_kernel_freertos_s3/actions"
echo "  - Or install 'act' and run: $0 ${COMMAND} --use-act"