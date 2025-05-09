/// Kysion Storage Library
///
/// 一个强大、灵活且类型安全的本地存储解决方案，支持多种存储引擎和多级安全加密。
/// 详细文档请参见 README.md
library kysion_storage;

export 'src/interfaces.dart';
export 'src/storage_service.dart';
export 'src/options.dart';
export 'src/exceptions.dart';
export 'src/models.dart';
export 'src/builders.dart';
export 'src/encryption.dart';

// 重导出常用类型，方便使用
export 'src/storage_service.dart' show KysionStorageService;
export 'src/options.dart'
    show KysionStorageEngine, KysionSecurityLevel, KysionStorageOptions;
export 'src/interfaces.dart'
    show
        IKysionStorageService,
        IKysionStorageBuilder,
        IStorageSerializable,
        FromJson;
