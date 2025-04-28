import 'package:kysion_storage/kysion_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks.dart';

/// 创建一个配置了mock依赖的StorageService实例
///
/// 返回服务实例和mock对象，方便测试
Future<TestStorageBundle> createTestStorage() async {
  final mockPrefs = MockSharedPreferences();
  final mockBox = MockHiveBox();
  final mockMetaBox = MockHiveBox();

  final storageService = KysionStorageService.instance;

  // 注入依赖
  storageService.setDependencies(
    prefs: mockPrefs,
    box: mockBox,
    metaBox: mockMetaBox,
  );

  // 标记为已初始化
  storageService.markInitialized();

  return TestStorageBundle(
    service: storageService,
    prefs: mockPrefs,
    box: mockBox,
    metaBox: mockMetaBox,
  );
}

/// 释放测试存储资源
Future<void> disposeTestStorage(TestStorageBundle bundle) async {
  await bundle.service.dispose();
}

/// 测试数据包，包含存储服务和所有mock对象
class TestStorageBundle {
  final KysionStorageService service;
  final MockSharedPreferences prefs;
  final MockHiveBox box;
  final MockHiveBox metaBox;

  TestStorageBundle({
    required this.service,
    required this.prefs,
    required this.box,
    required this.metaBox,
  });
}

/// 创建测试用户
TestUser createTestUser({int id = 1, String name = 'Test User'}) {
  return TestUser(id: id, name: name);
}

/// 设置测试环境的StorageService实例
Future<KysionStorageService> setupTestStorageService() async {
  // 创建所有所需的mock对象
  final mockPrefs = MockSharedPreferences();
  final mockBox = MockHiveBox();
  final mockMetaBox = MockHiveBox();

  // 创建并返回StorageService实例
  final storage = KysionStorageService(identifier: 'test_storage');

  // 注入所有必要的依赖
  storage.setDependencies(
    prefs: mockPrefs,
    box: mockBox,
    metaBox: mockMetaBox,
  );

  // 直接标记为已初始化，避免调用init()
  storage.markInitialized();

  return storage;
}

/// 测试用户类，用于测试对象存储
class TestUser {
  final int id;
  final String name;

  TestUser({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory TestUser.fromJson(Map<String, dynamic> json) => TestUser(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
