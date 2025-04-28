/// 存储引擎类型
enum KysionStorageEngine {
  /// SharedPreferences 存储引擎，适用于简单配置和小量数据
  prefs,

  /// Hive 存储引擎，适用于复杂对象和大量数据
  hive,

  /// 自动选择最合适的存储引擎
  auto,
}

/// 安全级别枚举
enum KysionSecurityLevel {
  /// 不加密
  none,

  /// 低安全级别，简单加密
  low,

  /// 中等安全级别，AES加密
  medium,

  /// 高安全级别，双层加密或平台安全存储
  high,
}

/// 存储选项配置
class KysionStorageOptions {
  /// 存储引擎
  final KysionStorageEngine engine;

  /// 数据过期时间
  final Duration? expiresIn;

  /// 安全级别
  final KysionSecurityLevel securityLevel;

  /// 默认存储选项
  const KysionStorageOptions({
    this.engine = KysionStorageEngine.auto,
    this.expiresIn,
    this.securityLevel = KysionSecurityLevel.none,
  });

  /// 创建新的存储选项实例，用于修改部分配置
  KysionStorageOptions copyWith({
    KysionStorageEngine? engine,
    Duration? expiresIn,
    KysionSecurityLevel? securityLevel,
  }) {
    return KysionStorageOptions(
      engine: engine ?? this.engine,
      expiresIn: expiresIn ?? this.expiresIn,
      securityLevel: securityLevel ?? this.securityLevel,
    );
  }
}
