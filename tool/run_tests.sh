#!/bin/bash

# 确保目录存在
mkdir -p coverage

# 安装依赖
echo "正在安装依赖..."
flutter pub get

# 生成mockito Mock类
echo "生成Mock类..."
flutter pub run build_runner build --delete-conflicting-outputs

# 运行测试并收集覆盖率
echo "运行测试..."
flutter test --coverage

echo "测试完成，覆盖率报告生成在 coverage/lcov.info"
echo "如需HTML报告，请安装lcov然后运行: lcov --list coverage/lcov.info"
echo "或者访问 https://app.codecov.io/ 上传lcov.info文件查看报告"

# 如果有安装lcov就生成HTML报告
if command -v genhtml >/dev/null 2>&1; then
  echo "正在生成HTML报告..."
  genhtml coverage/lcov.info -o coverage/html
  echo "HTML报告生成在 coverage/html/index.html"
fi 