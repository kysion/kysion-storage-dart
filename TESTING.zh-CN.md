# Kysion Storage 测试文档

[English](TESTING.md) | 中文

## 概述

Kysion Storage库包含全面的单元测试，确保功能稳定可靠。我们的目标是保持高测试覆盖率（80%以上）和高质量的测试用例。

## 测试范围

测试套件涵盖以下主要方面：

- **基本存储操作** - 存储、读取、删除和清理操作
- **类型安全** - 不同类型数据的存储和读取
- **存储引擎选择** - 自动和强制选择存储引擎
- **过期机制** - 数据自动过期功能
- **加密功能** - 不同安全级别的加密和解密
- **构建器模式** - 链式调用API和配置设置

## 运行测试

### 本地运行

```bash
# 在kysion_storage目录下运行
./tool/run_tests.sh
```

上述脚本会:

1. 安装必要的依赖
2. 生成mockito Mock类
3. 运行测试并收集覆盖率
4. 如果安装了lcov，生成HTML覆盖率报告

### CI环境

我们使用GitHub Actions自动运行测试。每次提交和PR都会触发测试流程。

可以在本地模拟CI环境测试：

```bash
./tool/ci_test.sh
```

## 添加新测试

在添加新功能时，请同时添加相应的测试：

1. 针对一个功能点创建单独的测试方法
2. 使用`test_helpers.dart`中的辅助函数简化测试设置
3. 确保覆盖正常情况和边缘情况

例如：

```dart
test('存储和读取对象', () async {
  final user = TestUser(id: 1, name: 'Test User');
  await storageService.set('userKey', user);
  
  final retrievedUser = await storageService.get<TestUser>(
    'userKey',
    fromJson: (map) => TestUser.fromMap(map),
  );
  
  expect(retrievedUser?.id, 1);
  expect(retrievedUser?.name, 'Test User');
});
```

## Mock对象

为了隔离测试依赖，我们使用以下Mock对象：

- **MockSharedPreferences** - 模拟SharedPreferences的行为
- **MockHiveBox** - 模拟Hive Box的行为

如需修改或增强Mock对象，请编辑`mocks.dart`文件。

## 测试环境注意事项

测试时需要注意以下几点：

1. 使用`markInitialized()`方法跳过实际平台初始化
2. 使用`setDependencies()`方法注入Mock对象
3. 避免直接导入内部实现类（`src/`目录下的类）
4. 对于复杂对象测试，使用显式的反序列化函数

## 覆盖率报告

测试覆盖率报告在以下位置可用：

- **本地**: `coverage/html/index.html` (需安装lcov)
- **CI**: 通过Codecov查看 [![codecov](https://img.shields.io/badge/codecov-1.1.0+-blue)](https://codecov.io/gh/kysion/kysion_storage)

## 最佳实践

- 每个功能点至少有一个测试
- 测试名称应清晰描述被测试的行为
- 使用`group`组织相关测试
- 每个测试专注于一个方面，不要在一个测试中测试多个功能点
- 使用`setUp`和`tearDown`管理测试环境
