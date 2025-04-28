/// 存储服务模块导出文件
///
/// 提供全功能的本地存储服务，支持多存储引擎、数据过期、多级安全加密和跨平台适配。
/// 详细文档和使用示例请查看 [README.md](./README.md)
library storage;

export 'interfaces.dart';
export 'storage_service.dart';
export 'options.dart';
export 'exceptions.dart';
export 'models.dart';
export 'builders.dart';
export 'encryption.dart';

// 重导出关键类型，方便使用
export 'storage_service.dart' show KysionStorageService;
export 'options.dart'
    show KysionStorageEngine, KysionSecurityLevel, KysionStorageOptions;
export 'interfaces.dart'
    show
        IKysionStorageService,
        IKysionStorageBuilder,
        IKysionSerializable,
        FromJson;
