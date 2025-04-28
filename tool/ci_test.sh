#!/bin/bash
# CI环境下的测试脚本

set -e  # 任何命令失败立即退出

# 安装依赖
flutter pub get

# 生成mockito Mock类
flutter pub run build_runner build --delete-conflicting-outputs

# 分析代码
flutter analyze

# 运行测试
flutter test --coverage

echo "测试成功完成，覆盖率报告生成在 coverage/lcov.info" 