# Kysion Storage

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | 中文

一个强大、灵活且类型安全的Flutter本地存储解决方案，支持多种存储引擎和多级安全加密。

## 安装

```yaml
dependencies:
  kysion_storage: ^0.1.0
```

然后运行:

```bash
flutter pub get
```

## 主要特性

- **多存储引擎**：智能组合SharedPreferences和Hive，自动选择最合适的存储引擎
- **多级安全加密**：支持从无加密到高级平台安全存储的多个安全级别
- **数据自动过期**：内置支持数据过期时间设置
- **类型安全**：完整的泛型支持和类型检查
- **跨平台**：支持移动端、Web和桌面，自动适应不同平台特性
- **存储优化**：使用引擎映射记录提高读取性能
- **链式API**：优雅的构建器模式支持流畅的链式调用
- **模块化设计**：分层架构实现关注点分离
- **高测试覆盖率**：全面的单元测试确保库质量和稳定性

## 架构设计

Kysion Storage采用分层架构设计，实现了高度的可扩展性和可测试性：

```
interfaces.dart   ← 定义接口和类型
    ↑
    ├── models.dart       ← 数据模型
    ├── options.dart      ← 配置选项
    ├── exceptions.dart   ← 异常处理
    ├── encryption.dart   ← 加密服务
    └── builders.dart     ← 构建器实现
            ↓
storage_service.dart ← 核心服务实现
```

## 快速开始

### 1. 初始化

在应用启动时初始化存储服务：

```dart
import 'package:kysion_storage/kysion_storage.dart';

Future<void> initServices() async {
  final storage = KysionStorageService.instance;
  await storage.init();
}
```

### 2. 基本使用

```dart
// 存储基本类型
await storage.set('username', 'Zhang San');
await storage.set('isLoggedIn', true);
await storage.set('age', 28);

// 读取数据 (异步)
final username = await storage.get<String>('username');
final isLoggedIn = await storage.get<bool>('isLoggedIn') ?? false;
final age = await storage.get<int>('age') ?? 0;

// 检查和删除
final hasUsername = await storage.has('username');
await storage.remove('username');

// 清空所有数据
await storage.clear();
```

### 3. 高级使用

#### 链式调用

```dart
// 使用构建器API
final token = await storage.builder()
    .engine(KysionStorageEngine.hive)           // 指定存储引擎
    .expiresIn(Duration(days: 7))         // 设置过期时间
    .withSecurityLevel(KysionSecurityLevel.high) // 设置加密级别
    .get<String>('authToken');
```

#### 存储对象

```dart
// 存储复杂对象
class User implements IKysionSerializable {
  final int id;
  final String name;
  
  User({required this.id, required this.name});
  
  @override
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'], name: map['name']);
  }
}

// 存储User对象
final user = User(id: 1, name: 'Zhang San');
await storage.set('currentUser', user);

// 读取User对象
final savedUser = await storage.get<User>(
  'currentUser', 
  fromJson: (map) => User.fromMap(map)
);
```

#### 设置过期时间

```dart
// 存储带过期时间的数据
await storage.set(
  'sessionToken', 
  'abc123',
  KysionStorageOptions(expiresIn: Duration(hours: 1))
);

// 或使用构建器
await storage.builder()
    .expiresIn(Duration(minutes: 30))
    .set('tempCode', '123456');
```

#### 加密数据

```dart
// 存储加密数据
await storage.set(
  'secretKey', 
  'sensitive_data',
  KysionStorageOptions(securityLevel: KysionSecurityLevel.high)
);

// 或使用构建器
await storage.builder()
    .withSecurityLevel(KysionSecurityLevel.medium)
    .set('apiKey', 'xyz789');
```

## 安全级别

Kysion Storage提供四种安全级别：

| 级别 | 描述 | 实现方式 | 使用场景 |
|------|------|----------|----------|
| `none` | 不加密 | 明文存储 | 非敏感数据 |
| `low` | 低级加密 | 简单异或加密 | 轻度敏感数据 |
| `medium` | 中级加密 | AES加密 | 一般敏感数据 |
| `high` | 高级加密 | 平台安全API | 高度敏感数据 |

每个平台支持的最高安全级别：

- **移动端**：支持全部级别，包括`high`
- **桌面端**：Windows/macOS支持`high`，Linux支持`medium`
- **Web端**：最高支持`medium`，自动降级

## 测试

这个库有全面的测试覆盖。如需运行测试：

```bash
cd kysion_storage
./tool/run_tests.sh
```

详细的测试文档请参见[TESTING.md](TESTING.md)（[中文版](TESTING.zh-CN.md)）。

## 更多文档

更多详细信息请参考[GitHub仓库](https://github.com/kysion/kysion_storage)。

## 许可证

本项目根据MIT许可证授权 - 详见[LICENSE](LICENSE)文件。
