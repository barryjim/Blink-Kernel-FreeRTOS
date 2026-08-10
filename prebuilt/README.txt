Place prebuilt firmware files here after building with Simplicity Studio.

Workflow:
  1. Open project in Simplicity Studio
  2. Build the target (Base configuration)
  3. Copy output files from cmake_gcc/build/base/ to this directory:
       blink_kernel_freertos_s3.bin
       blink_kernel_freertos_s3.hex
       blink_kernel_freertos_s3.s37
       blink_kernel_freertos_s3.map
       blink_kernel_freertos_s3.out
  4. Commit and push
  5. Create a tag (e.g., v1.0.1) to trigger the Release workflow