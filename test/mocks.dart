import 'package:hive_flutter/hive_flutter.dart';
import 'package:kysion_storage/kysion_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 生成mock类
@GenerateMocks([Box])
class MockBox<T> extends Mock implements Box<T> {}

// SharedPreferences的模拟实现
class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) {
    return _data[key] as String?;
  }

  @override
  bool? getBool(String key) {
    return _data[key] as bool?;
  }

  @override
  int? getInt(String key) {
    return _data[key] as int?;
  }

  @override
  double? getDouble(String key) {
    return _data[key] as double?;
  }

  @override
  List<String>? getStringList(String key) {
    return _data[key] as List<String>?;
  }

  @override
  Set<String> getKeys() {
    return _data.keys.toSet();
  }

  @override
  Object? get(String key) {
    return _data[key];
  }

  @override
  bool containsKey(String key) {
    return _data.containsKey(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }
}

// Hive Box的模拟实现
class MockHiveBox extends Mock implements Box<dynamic> {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) {
    return _data.containsKey(key) ? _data[key] : defaultValue;
  }

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }

  @override
  bool containsKey(dynamic key) {
    return _data.containsKey(key);
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Future<int> clear() async {
    final count = _data.length;
    _data.clear();
    return count;
  }

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  Future<void> close() async {}
}

// 测试用序列化对象类
class TestUser implements IKysionSerializable {
  final int id;
  final String name;

  TestUser({required this.id, required this.name});

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory TestUser.fromMap(Map<String, dynamic> map) {
    return TestUser(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  // 添加fromJson方法，与fromMap功能相同
  static TestUser fromJson(Map<String, dynamic> json) {
    return TestUser.fromMap(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestUser && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
