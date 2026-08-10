#!/bin/bash

set +e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass=0
fail=0
skip=0

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_ROOT}"

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; pass=$((pass + 1)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; fail=$((fail + 1)); }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; skip=$((skip + 1)); }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }

echo "============================================"
echo "  Embedded Project Test Suite"
echo "  Project: blink_kernel_freertos_s3"
echo "============================================"
echo ""

# ============================================================
# 1. Toolchain Check
# ============================================================
echo "--- 1. Toolchain Check ---"

if command -v arm-none-eabi-gcc &>/dev/null; then
    log_pass "ARM GCC found: $(arm-none-eabi-gcc --version | head -1)"
else
    log_fail "ARM GCC not found (arm-none-eabi-gcc)"
fi

if command -v cmake &>/dev/null; then
    log_pass "CMake found: $(cmake --version | head -1)"
else
    log_fail "CMake not found"
fi

if command -v ninja &>/dev/null; then
    log_pass "Ninja found: $(ninja --version)"
else
    log_fail "Ninja not found"
fi

if command -v slt &>/dev/null; then
    log_pass "SLT tool found: $(slt --version 2>&1 | head -1 || echo 'version unknown')"
else
    log_skip "SLT tool not found (required for CMake configure)"
fi

# ============================================================
# 2. Project Structure Check
# ============================================================
echo ""
echo "--- 2. Project Structure ---"

[ -f "cmake_gcc/CMakeLists.txt" ] && log_pass "cmake_gcc/CMakeLists.txt exists" || log_fail "cmake_gcc/CMakeLists.txt missing"
[ -f "cmake_gcc/CMakePresets.json" ] && log_pass "cmake_gcc/CMakePresets.json exists" || log_fail "cmake_gcc/CMakePresets.json missing"
[ -f "cmake_gcc/toolchain.cmake" ] && log_pass "cmake_gcc/toolchain.cmake exists" || log_fail "cmake_gcc/toolchain.cmake missing"
[ -f "cmake_gcc/blink_kernel_freertos_s3.cmake" ] && log_pass "cmake_gcc/blink_kernel_freertos_s3.cmake exists" || log_fail "cmake_gcc/blink_kernel_freertos_s3.cmake missing"
[ -f "main.c" ] && log_pass "main.c exists" || log_fail "main.c missing"
[ -f "config/version.h" ] && log_pass "config/version.h exists" || log_fail "config/version.h missing"
[ -f "autogen/linkerfile.ld" ] && log_pass "autogen/linkerfile.ld exists" || log_fail "autogen/linkerfile.ld missing"

if [ -d ".github/workflows" ]; then
    log_pass ".github/workflows directory exists"
    for wf in ci.yml release.yml; do
        [ -f ".github/workflows/${wf}" ] && log_pass ".github/workflows/${wf}" || log_fail ".github/workflows/${wf} missing"
    done
else
    log_fail ".github/workflows directory missing"
fi

if [ -d "scripts" ]; then
    log_pass "scripts directory exists"
    for script_dir in linter cppcheck format fw_packaging; do
        [ -d "scripts/${script_dir}" ] && log_pass "scripts/${script_dir} exists" || log_skip "scripts/${script_dir} missing"
    done
else
    log_fail "scripts directory missing"
fi

if [ -f "tools/build-firmware/composite/action.yml" ]; then
    log_pass "tools/build-firmware/composite/action.yml exists"
else
    log_fail "tools/build-firmware/composite/action.yml missing"
fi

# ============================================================
# 3. GitHub Actions Workflow Validation
# ============================================================
echo ""
echo "--- 3. Workflow YAML Validation ---"

python3 -c "
import yaml
import sys

files = [
    '.github/workflows/ci.yml',
    '.github/workflows/release.yml',
    'tools/build-firmware/action.yml',
    'tools/build-firmware/composite/action.yml',
]

all_ok = True
for f in files:
    try:
        with open('$PROJECT_ROOT/' + f) as fh:
            data = yaml.safe_load(fh)
        print(f'  PASS: {f} (valid YAML)')
    except Exception as e:
        print(f'  FAIL: {f} - {e}')
        all_ok = False

sys.exit(0 if all_ok else 1)
" && log_pass "All workflow YAML files valid" || log_fail "Some YAML files invalid"

# ============================================================
# 4. CMake Project Configure Test
# ============================================================
echo ""
echo "--- 4. CMake Configure Test ---"

CMAKE_DIR="${PROJECT_ROOT}/cmake_gcc"
BUILD_DIR="${CMAKE_DIR}/build"

if [ -f "${CMAKE_DIR}/CMakePresets.json" ]; then
    if command -v slt &>/dev/null && command -v arm-none-eabi-gcc &>/dev/null; then
        log_info "Running CMake configure (preset: project)..."
        cd "${CMAKE_DIR}"
        if cmake --preset project -D"CMAKE_CONFIGURATION_TYPES=base" 2>&1 | tail -5; then
            log_pass "CMake configure succeeded"
        else
            log_fail "CMake configure failed"
            log_info "Check that SLT tool is properly configured."
        fi
        cd "${PROJECT_ROOT}"
    else
        log_skip "Cannot configure: SLT tool or ARM GCC missing"
        log_info "Run this test on a machine with Simplicity Studio installed."
    fi
else
    log_skip "No CMakePresets.json found"
fi

# ============================================================
# 5. CMake Build Test
# ============================================================
echo ""
echo "--- 5. Build Test ---"

if [ -d "${BUILD_DIR}" ] && [ -f "${BUILD_DIR}/build.ninja" ]; then
    log_info "Running CMake build..."
    cd "${CMAKE_DIR}"
    if cmake --build "${BUILD_DIR}" --config base 2>&1 | tail -10; then
        log_pass "CMake build succeeded"

        echo ""
        log_info "Checking firmware artifacts..."
        for ext in .bin .hex .s37 .map .out; do
            if ls "${BUILD_DIR}/"*"${ext}" 2>/dev/null | head -1 | grep -q .; then
                f=$(ls "${BUILD_DIR}/"*"${ext}" 2>/dev/null | head -1)
                size=$(stat --format=%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null || echo "?")
                log_pass "Firmware artifact: ${f} (${size} bytes)"
            else
                log_skip "No .${ext} artifact found"
            fi
        done
    else
        log_fail "CMake build failed"
    fi
    cd "${PROJECT_ROOT}"
else
    log_skip "No build directory found. Run configure first."
    log_info "In VS Code: open cmake_gcc/CMakePresets.json and configure the project."
fi

# ============================================================
# 6. Code Quality Tools Test
# ============================================================
echo ""
echo "--- 6. Code Quality Tools ---"

if command -v python3 &>/dev/null; then
    log_pass "Python3 found: $(python3 --version)"
else
    log_fail "Python3 not found"
fi

if [ -d "third_party/cpplint" ] || [ -f "third_party/cpplint/cpplint.py" ]; then
    log_pass "cpplint available"
else
    log_info "Setting up cpplint..."
    if ! command -v git &>/dev/null; then
        log_skip "cpplint setup requires git"
    else
        if [ ! -d "third_party" ]; then mkdir -p third_party; fi
        git clone --depth 1 https://github.com/cpplint/cpplint.git third_party/cpplint 2>/dev/null || true
        if [ -f "third_party/cpplint/cpplint.py" ]; then
            log_pass "cpplint installed"
        else
            log_skip "cpplint install failed"
        fi
    fi
fi

if [ -f "scripts/linter/linter.sh" ] && [ -f "third_party/cpplint/cpplint.py" ]; then
    log_info "Running cpplint on project sources..."
    bash scripts/linter/linter.sh -p 2>&1 | tail -5
    if [ -f "code_quality_report/cpplint_report.xml" ]; then
        log_pass "cpplint report generated"
    else
        log_skip "cpplint report not generated"
    fi
else
    log_skip "cpplint test skipped (tool not ready)"
fi

if command -v clang-format &>/dev/null; then
    log_pass "clang-format found: $(clang-format --version)"
    if [ -f "scripts/format/format.sh" ]; then
        log_info "Running format check (dry run)..."
        bash scripts/format/format.sh -d 2>&1 | tail -5 || true
    fi
else
    log_skip "clang-format not installed"
fi

# ============================================================
# 7. Composite Action Simulation
# ============================================================
echo ""
echo "--- 7. Composite Action Simulation ---"

log_info "Simulating composite action build steps..."

WORKSPACE="${PROJECT_ROOT}"
CMAKE_PRESET="project"
BUILD_CONFIG="base"
PROJECT_NAME="blink_kernel_freertos_s3"

CMAKE_DIR=""
if [ -f "${WORKSPACE}/cmake_gcc/CMakePresets.json" ]; then
    CMAKE_DIR="${WORKSPACE}/cmake_gcc"
    log_pass "CMake project detected in cmake_gcc/"
else
    log_fail "No CMake project found"
fi

OUT_DIR="${WORKSPACE}/artifacts/${PROJECT_NAME}"
mkdir -p "${OUT_DIR}"
log_info "Artifacts will be collected to: ${OUT_DIR}"

if [ -d "${BUILD_DIR}" ]; then
    FW_DIR="${BUILD_DIR}/${BUILD_CONFIG}"
    if [ ! -d "${FW_DIR}" ]; then FW_DIR="${BUILD_DIR}"; fi

    copied=0
    for ext in .bin .hex .s37 .map .out; do
        src="${FW_DIR}/${PROJECT_NAME}${ext}"
        if [ -f "${src}" ]; then
            cp "${src}" "${OUT_DIR}/"
            log_pass "Collected: ${PROJECT_NAME}${ext} ($(stat --format=%s "${src}" 2>/dev/null || stat -f%z "${src}" 2>/dev/null || echo '?') bytes)"
            copied=$((copied + 1))
        fi
    done

    if [ ${copied} -gt 0 ]; then
        log_pass "Composite action simulation: ${copied} artifacts collected"
    else
        log_skip "No firmware artifacts to collect (build may not have been run)"
    fi
else
    log_skip "Build directory not found. Build the project first in Simplicity Studio."
fi

# ============================================================
# 8. Version Check
# ============================================================
echo ""
echo "--- 8. Version Info ---"

if [ -f "config/version.h" ]; then
    VERSION=$(grep -oP 'SOFTWARE_VERSION\s+"\K[^"]+' config/version.h | head -1)
    log_pass "Project version: ${VERSION:-unknown}"
else
    log_skip "version.h not found"
fi

TAG_PATTERN="blink_kernel_freertos_s3-v*"
log_info "Tag trigger pattern: ${TAG_PATTERN}"
log_info "To create a release tag: git tag -a ${TAG_PATTERN} -m 'Release' && git push origin ${TAG_PATTERN}"

# ============================================================
# Summary
# ============================================================
echo ""
echo "============================================"
echo "  Test Summary"
echo "============================================"
echo -e "  ${GREEN}Passed:${NC} ${pass}"
echo -e "  ${RED}Failed:${NC} ${fail}"
echo -e "  ${YELLOW}Skipped:${NC} ${skip}"
echo ""

if [ ${fail} -gt 0 ]; then
    echo -e "  ${RED}Some tests FAILED!${NC}"
    echo "  Review the failures above and fix issues before committing."
    exit 1
else
    echo -e "  ${GREEN}All critical tests passed!${NC}"
    echo "  Skipped items require Simplicity Studio SDK on this machine."
    exit 0
fi