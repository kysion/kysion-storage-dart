/// 存储服务异常基类
class StorageException implements Exception {
  /// 错误消息
  final String message;

  /// 原始错误
  final dynamic error;

  /// 创建存储异常
  StorageException(this.message, [this.error]);

  @override
  String toString() {
    return 'StorageException: $message ${error != null ? '($error)' : ''}';
  }
}

/// 初始化异常
class StorageInitException extends StorageException {
  StorageInitException(String message, [dynamic error])
    : super('初始化失败: $message', error);
}

/// 加密相关异常
class EncryptionException extends StorageException {
  EncryptionException(String message, [dynamic error])
    : super('加密错误: $message', error);
}

/// 过期数据异常
class ExpiredDataException extends StorageException {
  ExpiredDataException(String key) : super('数据已过期: $key');
}

/// 不支持的平台异常
class UnsupportedPlatformException extends StorageException {
  UnsupportedPlatformException(String feature, String platform)
    : super('$platform平台不支持$feature功能');
}

/// 类型转换异常
class TypeConversionException extends StorageException {
  TypeConversionException(String key, Type expectedType, Type actualType)
    : super('类型转换错误: 键[$key]期望类型[$expectedType]，实际类型[$actualType]');
}
