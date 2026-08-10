# Local Testing Guide

This document describes how to test the embedded project locally before pushing to GitHub.

## Prerequisites

### Required Tools

| Tool | Install | Purpose |
|------|---------|---------|
| ARM GCC | `sudo apt install gcc-arm-none-eabi` | Cross-compiler |
| CMake | `sudo apt install cmake ninja-build` | Build system |
| SLT (Simplicity Studio) | Install from Silicon Labs | SDK + toolchain manager |
| Python 3 | Usually pre-installed | Scripts |
| cpplint | Auto-installed by scripts | Code style check |
| cppcheck | Auto-installed by scripts | Static analysis |
| clang-format | `sudo apt install clang-format` | Code formatting |

### Verify Environment

```bash
# Check all tools
arm-none-eabi-gcc --version
cmake --version
ninja --version
slt --version
python3 --version
```

## Test Scripts

### Quick Start: Run Full Test Suite

```bash
cd tools/
bash test-suite.sh
```

This runs 8 test categories:
1. Toolchain check (ARM GCC, CMake, Ninja, SLT)
2. Project structure validation
3. GitHub Actions YAML validation
4. CMake configure test
5. Build test + firmware artifact verification
6. Code quality tools test (cpplint, clang-format)
7. Composite action simulation
8. Version info

### Test GitHub Actions Simulation

```bash
# Simulate CI workflow
bash tools/test-actions.sh ci

# Simulate Release workflow
bash tools/test-actions.sh release

# Simulate both
bash tools/test-actions.sh all

# With specific tag
TAG_NAME=v1.0.1 bash tools/test-actions.sh release

# Dry run (preview steps without executing)
bash tools/test-actions.sh ci --dry-run
```

### Test Composite Action Independently

```bash
# Configure only
bash tools/test-composite.sh --configure

# Build only
bash tools/test-composite.sh --build

# Collect artifacts only
bash tools/test-composite.sh --artifacts

# Full pipeline
bash tools/test-composite.sh --all

# Clean build artifacts
bash tools/test-composite.sh --clean
```

### Individual Tool Tests

```bash
# Code style check
bash scripts/linter/linter.sh -p
cat code_quality_report/cpplint_report.xml

# Static analysis
bash scripts/cppcheck/runner.sh
cat code_quality_report/cppcheck_report.html

# Format check
bash scripts/format/format.sh -d
```

## CI/CD Pipeline Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    Local Development                          │
├──────────────────────────────────────────────────────────────┤
│  1. Edit code in VS Code / Simplicity Studio                 │
│  2. Run: bash tools/test-suite.sh                            │
│  3. Fix any issues                                           │
│  4. Run: bash tools/test-actions.sh ci                       │
│  5. Verify CI simulation passes                              │
│  6. Commit and push                                          │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                    GitHub Actions                             │
├──────────────────────────────────────────────────────────────┤
│  CI Workflow (on push to main/PR):                           │
│    ├── CodeAnalysis (cpplint + cppcheck)                     │
│    ├── FormatCheck (clang-format)                            │
│    └── Build (composite action, best effort)                 │
│                                                              │
│  Release Workflow (on tag push):                             │
│    ├── CodeAnalysis                                          │
│    ├── Build (best effort)                                   │
│    └── Create GitHub Release                                 │
└──────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Build fails: "No CMake project found"

- Ensure `cmake_gcc/CMakePresets.json` exists
- Run test-suite.sh diagnostic section

### Build fails: "SLT tool not found"

- Install Simplicity Studio or configure `slt` on PATH
- Set environment variables in `cmake_gcc/toolchain.cmake`

### Build fails: "No build directory"

- Run CMake configure first: `bash tools/test-composite.sh --configure`
- Or use: `bash tools/test-composite.sh --all`

### cpplint report empty

- Run: `bash scripts/linter/linter.sh -p`
- Check `code_quality_report/cpplint_report.xml`

### cppcheck analysis fails

- Ensure cppcheck is installed: `bash scripts/cppcheck/setup.sh`
- Run analysis: `bash scripts/cppcheck/runner.sh`

## Release Tag Format

Two tag formats are supported:

```bash
# Format 1: Simple version
git tag -a v1.0.0 -m "Release v1.0.0"

# Format 2: Project-prefixed
git tag -a blink_kernel_freertos_s3-v1.0.0 -m "Release v1.0.0"
```

Both trigger the Release workflow.