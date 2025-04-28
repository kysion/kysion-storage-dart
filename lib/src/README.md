# Kysion Storage Service

[English](README.md) | [中文](README.zh-CN.md)

A powerful, flexible, and type-safe local storage solution supporting multiple storage engines and multi-level security encryption.

## Key Features

- **Multiple Storage Engines**: Smart combination of SharedPreferences and Hive, automatically selects the most suitable storage engine
- **Multi-level Security Encryption**: Supports multiple security levels from no encryption to advanced platform secure storage
- **Automatic Data Expiration**: Built-in support for data expiration settings
- **Type Safety**: Complete generic support and type checking
- **Cross-platform**: Supports mobile, web, and desktop, automatically adapting to different platform features
- **Storage Optimization**: Uses engine mapping records to improve read performance
- **Chained API**: Elegant builder pattern supports fluent chained calls
- **Modular Design**: Layered architecture implements separation of concerns

## Architecture Design

The Storage module adopts a layered architecture design, implementing high scalability and testability:

```txt
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

The Storage module provides four security levels:

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

## Storage Engine Selection Strategy

The Storage module intelligently selects the most suitable storage engine:

- `KysionStorageEngine.auto`: Default value, automatic selection
  - Simple types and no encryption: Use SharedPreferences
  - Complex objects or encryption needed: Use Hive
- `KysionStorageEngine.prefs`: Force use of SharedPreferences
- `KysionStorageEngine.hive`: Force use of Hive

## Error Handling

All operations handle exceptions gracefully:

```dart
try {
  final data = await storage.get<Map<String, dynamic>>('config');
} catch (e) {
  if (e is StorageException) {
    // Handle storage-related exceptions
    print('Storage error: ${e.message}');
  } else if (e is EncryptionException) {
    // Handle encryption-related exceptions
    print('Encryption error: ${e.message}');
  }
}
```

## Resource Release

Release resources when storage service is no longer needed:

```dart
await storage.dispose();
```

## Platform-specific Features

### Web Platform

On the Web platform, high security levels automatically downgrade to medium level, with a prompt:

```dart
// On Web platform, automatically downgraded to KysionSecurityLevel.medium
await storage.builder()
    .withSecurityLevel(KysionSecurityLevel.high) // Automatic downgrade
    .set('authToken', token);
```

## Best Practices

1. **Avoid storing large amounts of data**: Local storage should prioritize configuration and small-volume data
2. **Encrypt sensitive data**: Set appropriate security level for all sensitive information
3. **Set reasonable expiration times**: Set expiration times for temporary data
4. **Prefer async API**: All read/write operations are asynchronous, use await
5. **Exception handling**: Catch and properly handle possible exceptions
6. **Platform adaptation**: Understand limitations of different platforms, especially Web

## API Reference

### Main Classes

- `KysionStorageService` - Core storage service implementation
- `KysionStorageOptions` - Storage options configuration
- `KysionStorageBuilder` - Chain call builder
- `EncryptionService` - Encryption service implementation

### Main Enums

- `KysionStorageEngine` - Storage engine types: `prefs`, `hive`, `auto`
- `KysionSecurityLevel` - Security levels: `none`, `low`, `medium`, `high`

### Main Interfaces

- `IKysionStorage` - Storage service interface
- `IKysionStorageBuilder` - Builder interface
- `IKysionSerializable` - Serializable object interface
- `IEncryptionService` - Encryption service interface

## Performance Considerations

- Key engine mapping: Records which engine each key is stored in, optimizing read performance
- On-demand encryption: Only data with a specified security level is encrypted
- Lazy loading: Object data is only deserialized when needed

## Compatibility

- **Flutter version**: 3.0.0+
- **Dart version**: 2.17.0+ (supports null safety)
