# Kysion Storage

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | [中文](README.zh-CN.md)

A powerful, flexible, and type-safe Flutter local storage solution supporting multiple storage engines and multi-level security encryption.

## Installation

```yaml
dependencies:
  kysion_storage: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Key Features

- **Multiple Storage Engines**: Smart combination of SharedPreferences and Hive, automatically selects the most suitable storage engine
- **Multi-level Security Encryption**: Supports multiple security levels from no encryption to advanced platform secure storage
- **Automatic Data Expiration**: Built-in support for data expiration settings
- **Type Safety**: Complete generic support and type checking
- **Cross-platform**: Supports mobile, web, and desktop, automatically adapting to different platform features
- **Storage Optimization**: Uses engine mapping records to improve read performance
- **Chained API**: Elegant builder pattern supports fluent chained calls
- **Modular Design**: Layered architecture implements separation of concerns
- **High Test Coverage**: Comprehensive unit tests ensure library quality and stability

## Architecture Design

Kysion Storage adopts a layered architecture design, implementing high scalability and testability:

```
interfaces.dart   ← Define interfaces and types
    ↑
    ├── models.dart       ← Data models
    ├── options.dart      ← Configuration options
    ├── exceptions.dart   ← Exception handling
    ├── encryption.dart   ← Encryption service
    └── builders.dart     ← Builder implementation
            ↓
storage_service.dart ← Core service implementation
```

## Quick Start

### 1. Initialization

Initialize the storage service when starting the application:

```dart
import 'package:kysion_storage/kysion_storage.dart';

Future<void> initServices() async {
  final storage = KysionStorageService.instance;
  await storage.init();
}
```

### 2. Basic Usage

```dart
// Store basic types
await storage.set('username', 'John Doe');
await storage.set('isLoggedIn', true);
await storage.set('age', 28);

// Read data (asynchronous)
final username = await storage.get<String>('username');
final isLoggedIn = await storage.get<bool>('isLoggedIn') ?? false;
final age = await storage.get<int>('age') ?? 0;

// Check and delete
final hasUsername = await storage.has('username');
await storage.remove('username');

// Clear all data
await storage.clear();
```

### 3. Advanced Usage

#### Chained Calls

```dart
// Use builder API
final token = await storage.builder()
    .engine(KysionStorageEngine.hive)           // Specify storage engine
    .expiresIn(Duration(days: 7))         // Set expiration time
    .withSecurityLevel(KysionSecurityLevel.high) // Set encryption level
    .get<String>('authToken');
```

#### Storing Objects

```dart
// Store complex objects
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

// Store User object
final user = User(id: 1, name: 'John Doe');
await storage.set('currentUser', user);

// Read User object
final savedUser = await storage.get<User>(
  'currentUser', 
  fromJson: (map) => User.fromMap(map)
);
```

#### Setting Expiration Time

```dart
// Store data with expiration time
await storage.set(
  'sessionToken', 
  'abc123',
  KysionStorageOptions(expiresIn: Duration(hours: 1))
);

// Or use builder
await storage.builder()
    .expiresIn(Duration(minutes: 30))
    .set('tempCode', '123456');
```

#### Encrypting Data

```dart
// Store encrypted data
await storage.set(
  'secretKey', 
  'sensitive_data',
  KysionStorageOptions(securityLevel: KysionSecurityLevel.high)
);

// Or use builder
await storage.builder()
    .withSecurityLevel(KysionSecurityLevel.medium)
    .set('apiKey', 'xyz789');
```

## Security Levels

Kysion Storage provides four security levels:

| Level | Description | Implementation | Use Cases |
|------|------|----------|----------|
| `none` | No encryption | Plain text storage | Non-sensitive data |
| `low` | Low-level encryption | Simple XOR encryption | Slightly sensitive data |
| `medium` | Medium-level encryption | AES encryption | Generally sensitive data |
| `high` | High-level encryption | Platform security API | Highly sensitive data |

Highest security level supported on each platform:

- **Mobile**: Supports all levels, including `high`
- **Desktop**: Windows/macOS supports `high`, Linux supports `medium`
- **Web**: Maximum support for `medium`, automatic downgrade

## Testing

This library has comprehensive test coverage. To run the tests:

```bash
cd kysion_storage
./tool/run_tests.sh
```

For detailed test documentation, see [TESTING.md](TESTING.md) ([中文版](TESTING.zh-CN.md)).

## More Documentation

For more details, please refer to the [GitHub repository](https://github.com/kysion/kysion_storage).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
