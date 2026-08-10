# Blink Kernel FreeRTOS

This sample application demonstrates LED blink in a FreeRTOS task. 
The LED blinks in the period of 1000 ms. LED instance, toggle period and task priority can be changed in `blink.c` file.

## Requirements

Silicon Labs board with on-board LED.

## 
v1.0.0  最基础版本

GitHub Actions 工作流说明：
1. CI 工作流 (ci.yml)

触发条件：push/PR 到 main/master 分支
Job CodeAnalysis：运行 cpplint + cppcheck，上传报告
Job FormatCheck：检查 clang-format 格式一致性
Job Build：在 CodeAnalysis 和 FormatCheck 通过后，在 push 到 main 时自动构建
2. Release 工作流 (release.yml)

触发条件：推送 v* 或 blink_kernel_freertos_s3-v* 标签
流程：代码检查 → 构建 → 打包 → 创建 GitHub Release
二、使用步骤

Bash

# 1. 设置脚本可执行权限
chmod +x scripts/*/*.sh scripts/**/*.sh

# 2. 安装本地依赖（首次使用）
./scripts/setup/checkout.sh
./scripts/setup/activate.sh

# 3. 本地代码检查
./scripts/linter/linter.sh -p          # cpplint 检查
./scripts/cppcheck/runner.sh          # 静态分析
./scripts/format/format.sh -d         # 格式化检查
./scripts/codeanalysis/runner.sh       # 一键生成报告

# 4. 本地构建
./scripts/fw_packaging/artifacts.sh -t base

# 5. 手动打 Tag 发布
# 编辑 config/version.h 设定版本号后：
./scripts/release/tag.sh
# 或手动：
git tag -a blink_kernel_freertos_s3-v1.0.0 -m "Release v1.0.0"
git push origin blink_kernel_freertos_s3-v1.0.0
三、注意事项
Simplicity SDK 依赖：完整编译需要 Silicon Labs Simplicity Studio SDK。如果 GitHub Actions runner 没有 SDK，构建步骤会跳过（代码质量检查仍可运行）
ARM GCC：需要 arm-none-eabi-gcc，Ubuntu 下通过 sudo apt install gcc-arm-none-eabi 安装
版本号手动管理：编辑 config/version.h 中的 SOFTWARE_VERSION 即可
Tag 命名规则：blink_kernel_freertos_s3-v{X.Y.Z} 或 v{X.Y.Z}
排除目录：sdk/、third_party/、cmake_gcc/ 已在 lint/cppcheck 中排除
四、架构权衡
方案	实时性	内存占用	说明
cpplint + cppcheck	低	低	纯静态分析，不占用目标资源
clang-format	无	无	开发阶段格式化工具
Tag 触发发布	按需	低	仅在打 tag 时触发，不影响日常开发
该方案将 CI/CD 流程与嵌入式开发流程解耦：代码质量检查（lint + cppcheck + format）可在 GitHub Actions 上完整运行，而构建步骤在缺少 SDK 时可降级执行，确保流程不会因环境问题而阻塞。