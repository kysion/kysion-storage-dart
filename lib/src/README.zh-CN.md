# Kysion存储服务 (Storage Service)

[English](README.md) | 中文

一个强大、灵活且类型安全的本地存储解决方案，支持多种存储引擎和多级安全加密。

## 主要特性

- **多存储引擎**：智能组合SharedPreferences和Hive，自动选择最合适的存储引擎
- **多级安全加密**：支持从无加密到高级平台安全存储的多个安全级别
- **数据自动过期**：内置支持数据过期时间设置
- **类型安全**：完整的泛型支持和类型检查
- **跨平台**：支持移动端、Web和桌面，自动适应不同平台特性
- **存储优化**：使用引擎映射记录提高读取性能
- **链式API**：优雅的构建器模式支持流畅的链式调用
- **模块化设计**：分层架构实现关注点分离

## 架构设计

Storage模块采用分层架构设计，实现了高度的可扩展性和可测试性：

```txt
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

Storage模块提供四种安全级别：

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

## 存储引擎选择策略

Storage模块智能选择最合适的存储引擎：

- `KysionStorageEngine.auto`：默认值，自动选择
  - 简单类型且不加密：使用SharedPreferences
  - 复杂对象或需要加密：使用Hive
- `KysionStorageEngine.prefs`：强制使用SharedPreferences
- `KysionStorageEngine.hive`：强制使用Hive

## 错误处理

所有操作都会优雅地处理异常：

```dart
try {
  final data = await storage.get<Map<String, dynamic>>('config');
} catch (e) {
  if (e is StorageException) {
    // 处理存储相关异常
    print('存储错误: ${e.message}');
  } else if (e is EncryptionException) {
    // 处理加密相关异常
    print('加密错误: ${e.message}');
  }
}
```

## 资源释放

在不再需要存储服务时释放资源：

```dart
await storage.dispose();
```

## 平台特定功能

### Web平台

在Web平台上，高安全级别会自动降级为中等级别，并提供提示：

```dart
// Web平台上会自动降级为KysionSecurityLevel.medium
await storage.builder()
    .withSecurityLevel(KysionSecurityLevel.high) // 自动降级
    .set('authToken', token);
```

## 最佳实践

1. **避免存储大量数据**：本地存储应优先用于配置和小体积数据
2. **敏感数据加密**：对所有敏感信息设置适当的安全级别
3. **设置合理的过期时间**：为临时性数据设置过期时间
4. **优先使用异步API**：所有读写操作都是异步的，使用await处理
5. **异常处理**：捕获并妥善处理可能的异常
6. **根据平台适配**：了解不同平台的限制，特别是Web平台

## API参考

### 主要类

- `KysionStorageService` - 核心存储服务实现
- `KysionStorageOptions` - 存储选项配置
- `KysionStorageBuilder` - 链式调用构建器
- `EncryptionService` - 加密服务实现

### 主要枚举

- `KysionStorageEngine` - 存储引擎类型：`prefs`, `hive`, `auto`
- `KysionSecurityLevel` - 安全级别：`none`, `low`, `medium`, `high`

### 主要接口

- `IKysionStorage` - 存储服务接口
- `IKysionStorageBuilder` - 构建器接口
- `IKysionSerializable` - 可序列化对象接口
- `IEncryptionService` - 加密服务接口

## 性能考虑

- 键引擎映射：记录每个键存储在哪个引擎中，优化读取性能
- 按需加密：只有指定了安全级别的数据才会进行加密处理
- 延迟加载：对象数据在需要时才进行反序列化

## 兼容性

- **Flutter版本**: 3.0.0+
- **Dart版本**: 2.17.0+（支持空安全）
