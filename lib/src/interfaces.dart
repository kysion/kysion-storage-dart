import 'dart:convert';

import 'options.dart';

/// 从JSON数据创建对象的函数类型
typedef FromJson<T> = T Function(Map<String, dynamic> json);

/// 存储服务接口
abstract class IKysionStorageService {
  /// 初始化存储服务
  Future<void> init();

  /// 存储数据
  Future<bool> set<T>(String key, T val, [KysionStorageOptions? options]);

  /// 读取数据
  Future<T?> get<T>(String key, {T? defaultValue, FromJson<T>? fromJson});

  /// 移除指定键的数据
  Future<bool> remove(String key);

  /// 检查键是否存在
  Future<bool> has(String key);

  /// 清空所有数据
  Future<bool> clear();

  /// 释放资源
  Future<void> dispose();

  /// 获取构建器用于链式调用
  IKysionStorageBuilder builder({
    KysionStorageEngine? engine,
    Duration? expiresIn,
    KysionSecurityLevel? securityLevel,
  });
}

/// 存储构建器接口
abstract class IKysionStorageBuilder {
  /// 设置存储引擎
  IKysionStorageBuilder engine(KysionStorageEngine engine);

  /// 设置数据过期时间
  IKysionStorageBuilder expiresIn(Duration duration);

  /// 设置加密级别
  IKysionStorageBuilder withSecurityLevel(KysionSecurityLevel level);

  /// 存储数据
  Future<bool> set<T>(String key, T value);

  /// 读取数据
  Future<T?> get<T>(String key, {T? defaultValue, FromJson<T>? fromJson});

  /// 存储对象
  Future<bool> setObject<T>(
    String key,
    T value, {
    required FromJson<T> fromJson,
  });

  /// 读取对象
  Future<T?> getObject<T>(
    String key, {
    required FromJson<T> fromJson,
    T? defaultValue,
  });
}

/// 可序列化对象接口
abstract class IStorageSerializable {
  /// 转换为JSON字符串
  String toJson() {
    return json.encode(toMap());
  }

  /// 转换为Map
  Map<String, dynamic> toMap();

  /// 解析JSON字符串
  Map<String, dynamic> parseJson(String jsonString) {
    return json.decode(jsonString);
  }

  /// 从Map创建
  static T fromMap<T extends IStorageSerializable>(
    Map<String, dynamic> map,
    Function factory,
  ) {
    return factory(map) as T;
  }

  /// 从JSON字符串创建对象
  static T fromJson<T extends IStorageSerializable>(
    String jsonString,
    Function factory,
  ) {
    return factory(json.decode(jsonString)) as T;
  }
}
