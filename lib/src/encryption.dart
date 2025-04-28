import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import 'options.dart';
import 'exceptions.dart';

/// 加密服务接口
abstract class IEncryptionService {
  /// 加密数据
  Future<String> encrypt(String data, KysionSecurityLevel level);

  /// 解密数据
  Future<String> decrypt(String encryptedData, KysionSecurityLevel level);

  /// 获取平台支持的最高安全级别
  KysionSecurityLevel getMaxSupportedLevel();
}

/// 默认加密服务实现
class EncryptionService implements IEncryptionService {
  /// 单例实例
  static EncryptionService? _instance;

  /// 加密密钥
  late final String _securityKey;

  /// 获取单例
  static EncryptionService get instance {
    _instance ??= EncryptionService._();
    return _instance!;
  }

  /// 私有构造函数
  EncryptionService._() {
    // 实际应用中应该使用更安全的密钥管理
    _securityKey = _generateDefaultKey();
  }

  /// 生成默认密钥
  String _generateDefaultKey() {
    final random = math.Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  @override
  Future<String> encrypt(String data, KysionSecurityLevel level) async {
    // 确认请求的安全级别不超过平台支持的最高级别
    final effectiveLevel = _getEffectiveSecurityLevel(level);

    try {
      switch (effectiveLevel) {
        case KysionSecurityLevel.none:
          return data;
        case KysionSecurityLevel.low:
          return _simpleEncrypt(data);
        case KysionSecurityLevel.medium:
          return await _aesEncrypt(data);
        case KysionSecurityLevel.high:
          return await _platformSecureEncrypt(data);
      }
    } catch (e) {
      throw EncryptionException('加密失败', e);
    }
  }

  @override
  Future<String> decrypt(
      String encryptedData, KysionSecurityLevel level) async {
    final effectiveLevel = _getEffectiveSecurityLevel(level);

    try {
      switch (effectiveLevel) {
        case KysionSecurityLevel.none:
          return encryptedData;
        case KysionSecurityLevel.low:
          return _simpleDecrypt(encryptedData);
        case KysionSecurityLevel.medium:
          return await _aesDecrypt(encryptedData);
        case KysionSecurityLevel.high:
          return await _platformSecureDecrypt(encryptedData);
      }
    } catch (e) {
      throw EncryptionException('解密失败', e);
    }
  }

  @override
  KysionSecurityLevel getMaxSupportedLevel() {
    // Web平台不支持高级安全存储
    if (kIsWeb) {
      return KysionSecurityLevel.medium;
    }

    // 移动平台支持所有安全级别
    if (Platform.isAndroid || Platform.isIOS) {
      return KysionSecurityLevel.high;
    }

    // 桌面平台有限支持
    if (Platform.isWindows || Platform.isMacOS) {
      return KysionSecurityLevel.high;
    }

    if (Platform.isLinux) {
      return KysionSecurityLevel.medium;
    }

    // 其他平台默认中等级别
    return KysionSecurityLevel.medium;
  }

  /// 获取当前平台有效的安全级别（不超过平台支持的最高级别）
  KysionSecurityLevel _getEffectiveSecurityLevel(
      KysionSecurityLevel requested) {
    final maxLevel = getMaxSupportedLevel();
    if (requested.index > maxLevel.index) {
      // 自动降级到平台支持的最高级别
      return maxLevel;
    }
    return requested;
  }

  /// 简单加密（适用于低安全级别）
  String _simpleEncrypt(String data) {
    final bytes = utf8.encode(data);
    final key = utf8.encode(_securityKey.substring(0, 8));

    final result = List<int>.filled(bytes.length, 0);
    for (var i = 0; i < bytes.length; i++) {
      result[i] = bytes[i] ^ key[i % key.length];
    }

    return base64Encode(result);
  }

  /// 简单解密
  String _simpleDecrypt(String data) {
    final bytes = base64Decode(data);
    final key = utf8.encode(_securityKey.substring(0, 8));

    final result = List<int>.filled(bytes.length, 0);
    for (var i = 0; i < bytes.length; i++) {
      result[i] = bytes[i] ^ key[i % key.length];
    }

    return utf8.decode(result);
  }

  /// AES加密（实际实现应使用如encrypt包）
  Future<String> _aesEncrypt(String data) async {
    // 此处应使用如encrypt包的AES实现
    // 示例实现，实际应用中替换为真实的AES加密
    return base64Encode(utf8.encode('aes:$data'));
  }

  /// AES解密
  Future<String> _aesDecrypt(String data) async {
    // 示例实现，实际应用中替换为真实的AES解密
    final decoded = utf8.decode(base64Decode(data));
    if (decoded.startsWith('aes:')) {
      return decoded.substring(4);
    }
    throw EncryptionException('无效的AES加密数据');
  }

  /// 平台安全加密（实际实现应使用flutter_secure_storage等）
  Future<String> _platformSecureEncrypt(String data) async {
    if (kIsWeb) {
      throw UnsupportedPlatformException('平台安全存储', 'Web');
    }

    // 示例实现，实际应用中替换为真实的平台安全加密
    return base64Encode(utf8.encode('secure:$data'));
  }

  /// 平台安全解密
  Future<String> _platformSecureDecrypt(String data) async {
    if (kIsWeb) {
      throw UnsupportedPlatformException('平台安全存储', 'Web');
    }

    // 示例实现，实际应用中替换为真实的平台安全解密
    final decoded = utf8.decode(base64Decode(data));
    if (decoded.startsWith('secure:')) {
      return decoded.substring(7);
    }
    throw EncryptionException('无效的平台加密数据');
  }
}
