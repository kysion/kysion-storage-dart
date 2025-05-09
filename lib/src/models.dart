import 'dart:convert';

import 'interfaces.dart';

/// 数据包装类，包含数据本身和元数据（如过期时间）
class StorageItem<T> extends IStorageSerializable {
  /// 实际存储的数据
  final T data;

  /// 存储时间
  final DateTime createdAt;

  /// 过期秒数（为null表示永不过期）
  final int? expiresInSeconds;

  /// 创建存储项
  StorageItem({required this.data, this.expiresInSeconds, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  /// 判断数据是否已过期
  bool get isExpired {
    if (expiresInSeconds == null) return false;

    final expiryTime = createdAt.add(Duration(seconds: expiresInSeconds!));
    // 增加一点容错时间（100毫秒）
    return DateTime.now().isAfter(
      expiryTime.add(const Duration(milliseconds: 100)),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'data': data is IStorageSerializable
          ? (data as IStorageSerializable).toMap()
          : data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresInSeconds': expiresInSeconds,
    };
  }

  /// 从Map创建StorageItem
  factory StorageItem.fromMap(Map<String, dynamic> map) {
    return StorageItem<T>(
      data: map['data'] as T,
      expiresInSeconds: map['expiresInSeconds'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  /// 从JSON字符串创建StorageItem
  factory StorageItem.fromJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return StorageItem.fromMap(map);
  }
}

/// 存储引擎记录，用于追踪键存储在哪个引擎
class StorageRecord {
  /// 存储引擎
  final String engine;

  /// 最后访问时间
  DateTime lastAccessed;

  /// 创建时间
  final DateTime createdAt;

  /// 创建存储记录
  StorageRecord({
    required this.engine,
    DateTime? lastAccessed,
    DateTime? createdAt,
  })  : lastAccessed = lastAccessed ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 更新访问时间
  void updateAccessTime() {
    lastAccessed = DateTime.now();
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'engine': engine,
      'lastAccessed': lastAccessed.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// 从Map创建
  factory StorageRecord.fromMap(Map<String, dynamic> map) {
    return StorageRecord(
      engine: map['engine'],
      lastAccessed: DateTime.fromMillisecondsSinceEpoch(map['lastAccessed']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}
