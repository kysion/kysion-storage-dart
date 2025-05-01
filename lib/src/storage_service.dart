import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'builders.dart';
import 'encryption.dart';
import 'exceptions.dart';
import 'interfaces.dart';
import 'models.dart';
import 'options.dart';

/// 本地存储服务实现
class KysionStorageService implements IKysionStorageService {
  /// 日志标签
  static const String _logTag = 'KysionStorageService';

  /// 单例实例
  static KysionStorageService? _instance;

  /// SharedPreferences实例
  SharedPreferences? _prefs;

  /// Hive盒子实例
  Box<dynamic>? _box;

  /// 元数据盒子实例，用于存储键与引擎的映射关系
  Box<dynamic>? _metaBox;

  /// 是否已初始化
  bool _initialized = false;

  /// Hive盒子名称
  static const String _boxName = 'kysion_box';

  /// 元数据盒子名称
  static const String _metaBoxName = 'kysion_meta_box';

  /// 服务标识符
  String identifier = "kysion_storage";

  /// 上一次使用的标识符
  String? _lastIdentifier;

  /// 初始化是否正在进行中
  bool _initializing = false;

  /// 加密服务
  final IEncryptionService _encryptionService;

  /// 存储键与引擎的映射，用于优化读取性能
  final Map<String, String> _keyEngineMap = {};

  /// 获取实例（单例模式）
  static KysionStorageService get instance {
    _instance ??= KysionStorageService._();
    // 自动初始化处理
    _instance!._ensureInitializedAsync();
    return _instance!;
  }

  /// 私有构造函数
  KysionStorageService._() : _encryptionService = EncryptionService.instance {
    _lastIdentifier = identifier;
  }

  /// 创建实例，支持可选的标识符
  factory KysionStorageService({String identifier = "kysion_storage"}) {
    if (_instance == null) {
      _instance = KysionStorageService._();
      _instance!.identifier = identifier;
      _instance!._lastIdentifier = identifier;
      // 自动初始化
      _instance!._ensureInitializedAsync();
    } else if (_instance!.identifier != identifier) {
      // 标识符变更，触发重新初始化
      _instance!.identifier = identifier;
      _instance!._reinitialize();
    }
    return _instance!;
  }

  /// 供测试使用：设置依赖
  @visibleForTesting
  void setDependencies({
    SharedPreferences? prefs,
    Box<dynamic>? box,
    Box<dynamic>? metaBox,
  }) {
    _prefs = prefs;
    _box = box;
    _metaBox = metaBox;
  }

  /// 供测试使用：标记为已初始化状态
  @visibleForTesting
  void markInitialized() {
    _initialized = true;
    _lastIdentifier = identifier;
  }

  /// 创建构建器，用于链式调用
  @override
  IKysionStorageBuilder builder({
    KysionStorageEngine? engine,
    Duration? expiresIn,
    KysionSecurityLevel? securityLevel,
  }) {
    // 确保已初始化
    _ensureInitializedAsync();

    return StorageBuilder(
      this,
      KysionStorageOptions(
        engine: engine ?? KysionStorageEngine.auto,
        expiresIn: expiresIn,
        securityLevel: securityLevel ?? KysionSecurityLevel.none,
      ),
    );
  }

  /// 检查是否需要重新初始化
  bool _needsReinitialize() {
    return _lastIdentifier != identifier;
  }

  /// 标识符变更时重新初始化
  Future<void> _reinitialize() async {
    if (!_needsReinitialize()) return;

    developer.log('标识符已变更，从 $_lastIdentifier 到 $identifier，正在重新初始化',
        name: _logTag);

    // 如果已初始化，先释放资源
    if (_initialized) {
      await dispose();
    }

    _initialized = false;
    await init();
  }

  /// 自动确保服务已初始化（异步方式）
  void _ensureInitializedAsync() {
    if (!_initialized && !_initializing) {
      _initializing = true;
      Future.microtask(() async {
        try {
          await init();
        } catch (e) {
          developer.log('自动初始化失败: $e', name: _logTag, error: e);
        } finally {
          _initializing = false;
        }
      });
    }
  }

  /// 初始化存储服务
  @override
  Future<void> init() async {
    if (_initialized && !_needsReinitialize()) {
      developer.log('StorageService已经初始化', name: _logTag);
      return;
    }

    _initializing = true;
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // 初始化Hive
      await Hive.initFlutter();

      // 使用标识符创建唯一的盒子名称
      final String boxName = '${_boxName}_$identifier';
      final String metaBoxName = '${_metaBoxName}_$identifier';

      // 关闭现有盒子（如果存在）
      await _box?.close();
      await _metaBox?.close();

      // 创建盒子
      _box = await Hive.openBox(boxName);
      _metaBox = await Hive.openBox(metaBoxName);

      // 加载键引擎映射
      await _loadKeyEngineMap();

      _initialized = true;
      _lastIdentifier = identifier;
      developer.log('StorageService初始化成功，标识符: $identifier', name: _logTag);
    } catch (e) {
      developer.log('StorageService初始化失败: $e', name: _logTag, error: e);
      throw StorageInitException('初始化失败', e);
    } finally {
      _initializing = false;
    }
  }

  /// 加载键与引擎的映射关系
  Future<void> _loadKeyEngineMap() async {
    if (_metaBox == null) return;

    try {
      _keyEngineMap.clear();
      final keys = _metaBox!.keys;
      for (var key in keys) {
        final recordJson = _metaBox!.get(key);
        if (recordJson != null) {
          final record = StorageRecord.fromMap(
            jsonDecode(recordJson) as Map<String, dynamic>,
          );
          _keyEngineMap[key.toString()] = record.engine;
        }
      }
      developer.log('已加载${_keyEngineMap.length}个键映射', name: _logTag);
    } catch (e) {
      developer.log('加载键映射失败: $e', name: _logTag, error: e);
    }
  }

  /// 确保服务已初始化
  void _ensureInitialized() {
    if (!_initialized) {
      if (_initializing) {
        throw StorageException('存储服务正在初始化中，请稍后再试');
      } else {
        throw StorageException('存储服务尚未初始化，请先调用init()');
      }
    }

    if (_needsReinitialize()) {
      throw StorageException('标识符已变更，需要重新初始化');
    }
  }

  /// 根据数据类型和选项选择最合适的存储引擎
  KysionStorageEngine _selectEngine<T>(T value, KysionStorageOptions options) {
    if (options.engine != KysionStorageEngine.auto) {
      return options.engine;
    }

    // 根据数据类型选择引擎
    if (_isSimpleType(value) &&
        options.securityLevel == KysionSecurityLevel.none) {
      return KysionStorageEngine.prefs;
    }
    return KysionStorageEngine.hive;
  }

  /// 判断是否为简单类型（SharedPreferences支持的类型）
  bool _isSimpleType(dynamic value) {
    return value is String ||
        value is bool ||
        value is int ||
        value is double ||
        value is List<String>;
  }

  /// 记录键与引擎的映射关系
  Future<void> _recordKeyEngine(String key, KysionStorageEngine engine) async {
    final engineName = engine.toString().split('.').last;
    _keyEngineMap[key] = engineName;

    try {
      final record = StorageRecord(engine: engineName);
      await _metaBox?.put(key, jsonEncode(record.toMap()));
    } catch (e) {
      developer.log('记录键引擎映射失败: $e', name: _logTag, error: e);
    }
  }

  /// 存储数据
  @override
  Future<bool> set<T>(String key, T value,
      [KysionStorageOptions? options]) async {
    options ??= const KysionStorageOptions();

    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    return _set(key, value, options);
  }

  /// 内部存储实现
  Future<bool> _set<T>(
      String key, T value, KysionStorageOptions options) async {
    final engine = _selectEngine(value, options);

    try {
      // 创建存储项
      final item = StorageItem<T>(
        data: value,
        expiresInSeconds: options.expiresIn?.inSeconds,
      );

      // 根据安全级别处理加密
      String dataToStore;
      if (options.securityLevel != KysionSecurityLevel.none) {
        // 加密数据
        final jsonData = item.toJson();
        dataToStore = await _encryptionService.encrypt(
          jsonData,
          options.securityLevel,
        );
      } else {
        // 不加密，直接使用JSON
        dataToStore = item.toJson();
      }

      // 根据引擎存储
      bool result = false;
      switch (engine) {
        case KysionStorageEngine.prefs:
          result = await _prefs?.setString(key, dataToStore) ?? false;
          break;
        case KysionStorageEngine.hive:
          await _box?.put(key, dataToStore);
          result = true;
          break;
        default:
          throw StorageException('未知存储引擎: $engine');
      }

      // 记录键与引擎的映射关系
      if (result) {
        await _recordKeyEngine(key, engine);
      }

      return result;
    } catch (e) {
      developer.log('存储数据失败 [key=$key]: $e', name: _logTag, error: e);
      return false;
    }
  }

  /// 读取数据
  @override
  Future<T?> get<T>(
    String key, {
    T? defaultValue,
    FromJson<T>? fromJson,
  }) async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    return await _get(key, defaultValue: defaultValue, fromJson: fromJson);
  }

  /// 内部读取实现
  Future<T?> _get<T>(
    String key, {
    T? defaultValue,
    FromJson<T>? fromJson,
  }) async {
    try {
      // 查找键存储在哪个引擎中
      final engineName = _keyEngineMap[key];

      String? rawData;

      // 如果知道引擎，直接从对应引擎读取
      if (engineName != null) {
        if (engineName == 'prefs') {
          rawData = _prefs?.getString(key);
        } else if (engineName == 'hive') {
          rawData = _box?.get(key) as String?;
        }
      } else {
        // 如果不知道引擎，先尝试从SharedPreferences读取
        rawData = _prefs?.getString(key);

        // 如果SharedPreferences没有，尝试从Hive读取
        if (rawData == null) {
          rawData = _box?.get(key) as String?;
          if (rawData != null) {
            _keyEngineMap[key] = 'hive';
          }
        } else {
          _keyEngineMap[key] = 'prefs';
        }
      }

      if (rawData == null) {
        return defaultValue;
      }

      // 尝试解析为StorageItem
      try {
        // 先尝试作为JSON解析
        dynamic decodedData = rawData;

        try {
          // 检查是否需要解密
          if (_isEncryptedData(rawData)) {
            // 先使用中等安全级别尝试解密
            decodedData = await _encryptionService.decrypt(
              rawData,
              KysionSecurityLevel.medium,
            );
          }

          final item = StorageItem<T>.fromJson(decodedData);

          // 检查是否过期
          if (item.isExpired) {
            await remove(key);
            return defaultValue;
          }

          final data = item.data;

          // 如果数据是Map且提供了fromJson函数，则将Map转为对象
          if (data is Map<String, dynamic> && fromJson != null) {
            return fromJson(data);
          }

          return data as T?;
        } catch (e) {
          // 如果解析失败，可能是旧数据，直接返回
          if (rawData is T) {
            return rawData as T;
          }
        }
      } catch (e) {
        developer.log('读取数据解析错误 [key=$key]: $e', name: _logTag, error: e);
      }

      return defaultValue;
    } catch (e) {
      developer.log('读取数据失败 [key=$key]: $e', name: _logTag, error: e);
      return defaultValue;
    }
  }

  /// 判断数据是否被加密
  bool _isEncryptedData(String data) {
    // 简单启发式检查，实际应用中可能需要更复杂的检测
    try {
      jsonDecode(data);
      // 如果能直接解析为JSON，说明没有加密
      return false;
    } catch (e) {
      // 解析失败，可能是加密数据
      return true;
    }
  }

  /// 检查键是否存在
  @override
  Future<bool> has(String key) async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    final engineName = _keyEngineMap[key];
    if (engineName != null) {
      if (engineName == 'prefs') {
        return _prefs?.containsKey(key) ?? false;
      } else if (engineName == 'hive') {
        return _box?.containsKey(key) ?? false;
      }
    }

    return (_prefs?.containsKey(key) ?? false) ||
        (_box?.containsKey(key) ?? false);
  }

  /// 移除数据
  @override
  Future<bool> remove(String key) async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    bool result = true;
    final engineName = _keyEngineMap[key];

    try {
      if (engineName != null) {
        if (engineName == 'prefs') {
          result = await _prefs?.remove(key) ?? false;
        } else if (engineName == 'hive') {
          await _box?.delete(key);
        }
      } else {
        // 如果不知道引擎，尝试从两个引擎都删除
        if (_prefs?.containsKey(key) ?? false) {
          result = await _prefs?.remove(key) ?? false;
        }

        if (_box?.containsKey(key) ?? false) {
          await _box?.delete(key);
        }
      }

      // 移除元数据
      _keyEngineMap.remove(key);
      await _metaBox?.delete(key);

      return result;
    } catch (e) {
      developer.log('移除数据失败 [key=$key]: $e', name: _logTag, error: e);
      return false;
    }
  }

  /// 只从SharedPreferences移除
  Future<bool> removeFromPrefs(String key) async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    try {
      final result = await _prefs?.remove(key) ?? false;

      if (result && _keyEngineMap[key] == 'prefs') {
        _keyEngineMap.remove(key);
        await _metaBox?.delete(key);
      }

      return result;
    } catch (e) {
      developer.log(
        '从SharedPreferences移除数据失败 [key=$key]: $e',
        name: _logTag,
        error: e,
      );
      return false;
    }
  }

  /// 只从Hive移除
  Future<bool> removeFromHive(String key) async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    try {
      await _box?.delete(key);

      if (_keyEngineMap[key] == 'hive') {
        _keyEngineMap.remove(key);
        await _metaBox?.delete(key);
      }

      return true;
    } catch (e) {
      developer.log('从Hive移除数据失败 [key=$key]: $e', name: _logTag, error: e);
      return false;
    }
  }

  /// 清除所有数据
  @override
  Future<bool> clear() async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    try {
      await clearPrefs();
      await clearHive();
      await _metaBox?.clear();
      _keyEngineMap.clear();

      return true;
    } catch (e) {
      developer.log('清除所有数据失败: $e', name: _logTag, error: e);
      return false;
    }
  }

  /// 只清除SharedPreferences
  Future<bool> clearPrefs() async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    try {
      final result = await _prefs?.clear() ?? false;

      // 更新元数据
      final prefsKeys = _keyEngineMap.entries
          .where((entry) => entry.value == 'prefs')
          .map((entry) => entry.key)
          .toList();

      for (var key in prefsKeys) {
        _keyEngineMap.remove(key);
        await _metaBox?.delete(key);
      }

      return result;
    } catch (e) {
      developer.log('清除SharedPreferences失败: $e', name: _logTag, error: e);
      return false;
    }
  }

  /// 只清除Hive
  Future<bool> clearHive() async {
    // 确保已初始化
    if (!_initialized && !_initializing) {
      await init();
    } else {
      _ensureInitialized();
    }

    try {
      await _box?.clear();

      // 更新元数据
      final hiveKeys = _keyEngineMap.entries
          .where((entry) => entry.value == 'hive')
          .map((entry) => entry.key)
          .toList();

      for (var key in hiveKeys) {
        _keyEngineMap.remove(key);
        await _metaBox?.delete(key);
      }

      return true;
    } catch (e) {
      developer.log('清除Hive失败: $e', name: _logTag, error: e);
      return false;
    }
  }

  /// 释放资源
  @override
  Future<void> dispose() async {
    try {
      await _box?.close();
      await _metaBox?.close();
      _initialized = false;
      developer.log('StorageService资源已释放', name: _logTag);
    } catch (e) {
      developer.log('释放StorageService资源失败: $e', name: _logTag, error: e);
    }
  }
}
