# firmware-builder

Reusable GitHub Action for building embedded firmware targeting Silicon Labs MG301 series (ARM Cortex-M).

## Features

- **ARM GCC cross-compiler** (arm-none-eabi-gcc)
- **CMake + Ninja** build system
- **Docker-based** for reproducible builds
- **Composite fallback** for environments without Docker
- **Auto-detect** CMake project structure
- **Best-effort** build with graceful fallback

## Repository Structure

```
firmware-builder/
├── action.yml              # Docker-based Action definition
├── Dockerfile              # Docker image with toolchain
├── entrypoint.sh           # Build logic inside container
├── composite/
│   └── action.yml          # Composite Action (no Docker needed)
├── build.sh                # Local build script
├── test-local.sh           # Local test script
└── .github/workflows/
    └── build-image.yml     # CI: build & publish Docker image
```

## Usage

### As a Docker-based Action

```yaml
jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4

      - name: Build firmware
        id: build
        uses: barryjim/firmware-builder@v1
        with:
          cmake_preset: project
          build_config: base
          sdk_path: /opt/simplicity-sdk
          fail_on_error: false

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        if: steps.build.outputs.success == 'true'
        with:
          name: firmware
          path: ${{ steps.build.outputs.artifacts_dir }}
```

### As a Composite Action (simpler, no Docker)

```yaml
jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4

      - name: Build firmware
        id: build
        uses: barryjim/firmware-builder/composite@v1
        with:
          cmake_preset: project
          build_config: base
          fail_on_error: false
```

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `cmake_preset` | No | `project` | CMake preset name |
| `build_config` | No | `base` | Build configuration |
| `sdk_path` | No | `/opt/simplicity-sdk` | Silicon Labs SDK path |
| `fail_on_error` | No | `false` | Fail workflow if build fails |
| `timeout` | No | `10` | Build timeout in minutes (Docker only) |

### Outputs

| Output | Description |
|--------|-------------|
| `success` | Build result (`true`/`false`) |
| `artifacts_dir` | Path to built firmware files |

## Local Development

```bash
# Build Docker image locally
./build.sh

# Build and push to GitHub Container Registry
./build.sh v1.0.0 --push
```

## Setup

1. Push this repository to GitHub: `https://github.com/barryjim/firmware-builder`
2. Create a tag: `git tag -a v1.0.0 -m "v1.0.0"` and push
3. In your project workflow, reference `barryjim/firmware-builder@v1.0.0`

## Notes

- Silicon Labs SDK is **not included** (commercial software)
- The Docker image includes only open-source build tools
- For full compilation, mount SDK at `/opt/simplicity-sdk`
- Or use the Composite Action variant which works without Docker