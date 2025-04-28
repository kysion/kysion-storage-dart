import 'interfaces.dart';
import 'options.dart';

/// 存储构建器实现
class StorageBuilder implements IKysionStorageBuilder {
  /// 关联的存储服务
  final IKysionStorageService _storage;

  /// 存储选项
  KysionStorageOptions _options;

  /// 创建构建器
  StorageBuilder(this._storage, [KysionStorageOptions? options])
      : _options = options ?? const KysionStorageOptions();

  @override
  IKysionStorageBuilder engine(KysionStorageEngine engine) {
    _options = _options.copyWith(engine: engine);
    return this;
  }

  @override
  IKysionStorageBuilder expiresIn(Duration duration) {
    _options = _options.copyWith(expiresIn: duration);
    return this;
  }

  @override
  IKysionStorageBuilder withSecurityLevel(KysionSecurityLevel level) {
    _options = _options.copyWith(securityLevel: level);
    return this;
  }

  @override
  Future<bool> set<T>(String key, T value) {
    return _storage.set(key, value, _options);
  }

  @override
  Future<T?> get<T>(String key, {T? defaultValue, FromJson<T>? fromJson}) {
    return _storage.get(key, defaultValue: defaultValue, fromJson: fromJson);
  }

  @override
  Future<bool> setObject<T>(
    String key,
    T value, {
    required FromJson<T> fromJson,
  }) {
    // 对象必须能转为Map，由存储服务负责处理
    return _storage.set(key, value, _options);
  }

  @override
  Future<T?> getObject<T>(
    String key, {
    required FromJson<T> fromJson,
    T? defaultValue,
  }) {
    return _storage.get(key, defaultValue: defaultValue, fromJson: fromJson);
  }
}
