Place prebuilt firmware files here after building with Simplicity Studio.

Quick workflow:
  1. Build in Simplicity Studio
  2. Run: bash scripts/fw_packaging/artifacts.sh --sync
     (This auto-copies build/ output to prebuilt/ and creates artifacts.tar.gz)
  3. Commit: git add prebuilt/ && git commit -m 'update firmware'
  4. Push and tag: git push && git tag v1.x.x && git push --tags

Manual sync (alternative):
  bash scripts/fw_packaging/sync_prebuilt.sh          # Sync only
  bash scripts/fw_packaging/sync_prebuilt.sh -f      # Force overwrite

Expected files (built by Simplicity Studio):
  blink_kernel_freertos_s3.bin
  blink_kernel_freertos_s3.hex
  blink_kernel_freertos_s3.s37
  blink_kernel_freertos_s3.map
  blink_kernel_freertos_s3.out