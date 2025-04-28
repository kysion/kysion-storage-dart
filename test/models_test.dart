import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kysion_storage/kysion_storage.dart';

void main() {
  group('StorageItem模型测试', () {
    test('创建和序列化StorageItem', () {
      final item = StorageItem<String>(
        data: 'test data',
        expiresInSeconds: 60,
      );

      // 测试转换为Map
      final map = item.toMap();
      expect(map['data'], 'test data');
      expect(map['expiresInSeconds'], 60);
      expect(map['createdAt'], isA<int>());

      // 测试转换为JSON字符串
      final jsonString = item.toJson();
      expect(jsonString, isA<String>());
      expect(jsonDecode(jsonString)['data'], 'test data');
    });

    test('从Map和JSON创建StorageItem', () {
      final now = DateTime.now();
      final map = {
        'data': 'test data',
        'expiresInSeconds': 60,
        'createdAt': now.millisecondsSinceEpoch,
      };

      // 从Map创建
      final itemFromMap = StorageItem<String>.fromMap(map);
      expect(itemFromMap.data, 'test data');
      expect(itemFromMap.expiresInSeconds, 60);
      expect(itemFromMap.createdAt.millisecondsSinceEpoch,
          now.millisecondsSinceEpoch);

      // 从JSON创建
      final jsonString = json.encode(map);
      final itemFromJson = StorageItem<String>.fromJson(jsonString);
      expect(itemFromJson.data, 'test data');
      expect(itemFromJson.expiresInSeconds, 60);
    });

    test('过期检查功能', () {
      // 创建一个已经过期的项目（创建时间在过去）
      final expiredItem = StorageItem<String>(
        data: 'expired data',
        expiresInSeconds: 1,
        createdAt: DateTime.now().subtract(Duration(seconds: 2)),
      );
      expect(expiredItem.isExpired, isTrue);

      // 创建一个未过期的项目
      final validItem = StorageItem<String>(
        data: 'valid data',
        expiresInSeconds: 3600, // 1小时
      );
      expect(validItem.isExpired, isFalse);

      // 创建一个永不过期的项目
      final neverExpiresItem = StorageItem<String>(
        data: 'permanent data',
        expiresInSeconds: null,
      );
      expect(neverExpiresItem.isExpired, isFalse);
    });
  });

  group('StorageRecord模型测试', () {
    test('创建和更新StorageRecord', () {
      final now = DateTime.now();
      final record = StorageRecord(
        engine: 'prefs',
        createdAt: now,
      );

      expect(record.engine, 'prefs');
      expect(record.createdAt, now);
      expect(record.lastAccessed.millisecondsSinceEpoch,
          closeTo(now.millisecondsSinceEpoch, 1000));

      // 更新访问时间
      final beforeUpdate = record.lastAccessed;
      Future.delayed(Duration(milliseconds: 100), () {
        record.updateAccessTime();
        expect(record.lastAccessed.isAfter(beforeUpdate), isTrue);
      });
    });

    test('StorageRecord序列化和反序列化', () {
      final record = StorageRecord(engine: 'hive');
      final map = record.toMap();

      expect(map['engine'], 'hive');
      expect(map['lastAccessed'], isA<int>());
      expect(map['createdAt'], isA<int>());

      final reconstructed = StorageRecord.fromMap(map);
      expect(reconstructed.engine, 'hive');
      expect(reconstructed.lastAccessed.millisecondsSinceEpoch,
          map['lastAccessed']);
      expect(reconstructed.createdAt.millisecondsSinceEpoch, map['createdAt']);
    });
  });

  group('StorageOptions测试', () {
    test('创建默认选项', () {
      final options = KysionStorageOptions();

      expect(options.engine, KysionStorageEngine.auto);
      expect(options.expiresIn, isNull);
      expect(options.securityLevel, KysionSecurityLevel.none);
    });

    test('创建自定义选项', () {
      final options = KysionStorageOptions(
        engine: KysionStorageEngine.hive,
        expiresIn: Duration(hours: 1),
        securityLevel: KysionSecurityLevel.medium,
      );

      expect(options.engine, KysionStorageEngine.hive);
      expect(options.expiresIn?.inHours, 1);
      expect(options.securityLevel, KysionSecurityLevel.medium);
    });

    test('copyWith创建修改后的选项', () {
      final original = KysionStorageOptions(
        engine: KysionStorageEngine.prefs,
        securityLevel: KysionSecurityLevel.low,
      );

      final modified = original.copyWith(
        engine: KysionStorageEngine.hive,
        expiresIn: Duration(days: 1),
      );

      // 检查修改的字段
      expect(modified.engine, KysionStorageEngine.hive);
      expect(modified.expiresIn?.inDays, 1);

      // 未修改的字段应保持原值
      expect(modified.securityLevel, KysionSecurityLevel.low);

      // 原对象应不变
      expect(original.engine, KysionStorageEngine.prefs);
      expect(original.expiresIn, isNull);
    });
  });
}
