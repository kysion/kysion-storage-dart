import 'package:flutter_test/flutter_test.dart';
import 'package:kysion_storage/kysion_storage.dart';

void main() {
  late EncryptionService encryptionService;

  setUp(() {
    encryptionService = EncryptionService.instance;
  });

  group('加密服务测试', () {
    test('无加密级别应直接返回原始数据', () async {
      const testData = 'test data';
      final encrypted =
          await encryptionService.encrypt(testData, KysionSecurityLevel.none);

      // 无加密应该返回原始数据
      expect(encrypted, equals(testData));

      // 解密也应该返回原始数据
      final decrypted =
          await encryptionService.decrypt(encrypted, KysionSecurityLevel.none);
      expect(decrypted, equals(testData));
    });

    test('低级加密应加密和解密数据', () async {
      const testData = 'sensitive information';
      final encrypted =
          await encryptionService.encrypt(testData, KysionSecurityLevel.low);

      // 加密后的数据不应与原始数据相同
      expect(encrypted, isNot(equals(testData)));

      // 解密后应得到原始数据
      final decrypted =
          await encryptionService.decrypt(encrypted, KysionSecurityLevel.low);
      expect(decrypted, equals(testData));
    });

    test('中级加密应加密和解密数据', () async {
      const testData = 'more sensitive information';
      final encrypted =
          await encryptionService.encrypt(testData, KysionSecurityLevel.medium);

      // 加密后的数据不应与原始数据相同
      expect(encrypted, isNot(equals(testData)));

      // 解密后应得到原始数据
      final decrypted = await encryptionService.decrypt(
          encrypted, KysionSecurityLevel.medium);
      expect(decrypted, equals(testData));
    });

    test('不同加密级别的数据应互不兼容', () async {
      const testData = 'incompatible data';

      final lowEncrypted =
          await encryptionService.encrypt(testData, KysionSecurityLevel.low);
      final mediumEncrypted =
          await encryptionService.encrypt(testData, KysionSecurityLevel.medium);

      // 加密结果应该不同
      expect(lowEncrypted, isNot(equals(mediumEncrypted)));

      // 使用错误的解密级别应该失败或产生错误数据
      try {
        final result = await encryptionService.decrypt(
            lowEncrypted, KysionSecurityLevel.medium);
        // 如果没有抛出异常，验证结果不等于原始数据
        expect(result, isNot(equals(testData)));
      } catch (e) {
        // 如果抛出异常，确认是期望的异常类型
        expect(e, isA<EncryptionException>());
      }

      try {
        final result = await encryptionService.decrypt(
            mediumEncrypted, KysionSecurityLevel.low);
        // 如果没有抛出异常，验证结果不等于原始数据
        expect(result, isNot(equals(testData)));
      } catch (e) {
        // 如果抛出异常，确认是期望的异常类型
        expect(e, isA<EncryptionException>());
      }
    });

    test('平台支持级别检测', () {
      final maxLevel = encryptionService.getMaxSupportedLevel();

      // 至少应该支持medium级别
      expect(maxLevel.index,
          greaterThanOrEqualTo(KysionSecurityLevel.medium.index));
    });
  });
}
