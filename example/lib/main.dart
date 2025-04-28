import 'package:flutter/material.dart';
import 'package:kysion_storage/kysion_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化存储服务
  await KysionStorageService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kysion Storage Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const StorageDemo(),
    );
  }
}

class StorageDemo extends StatefulWidget {
  const StorageDemo({Key? key}) : super(key: key);

  @override
  State<StorageDemo> createState() => _StorageDemoState();
}

class _StorageDemoState extends State<StorageDemo> {
  final _storage = KysionStorageService.instance;
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  String _resultText = '';
  bool _isEncrypted = false;
  bool _hasExpiry = false;
  KysionStorageEngine _selectedEngine = KysionStorageEngine.auto;

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    final key = _keyController.text;
    final value = _valueController.text;

    if (key.isEmpty || value.isEmpty) {
      _showMessage('请输入键和值');
      return;
    }

    try {
      final options = KysionStorageOptions(
        engine: _selectedEngine,
        expiresIn: _hasExpiry ? const Duration(minutes: 1) : null,
        securityLevel: _isEncrypted
            ? KysionSecurityLevel.medium
            : KysionSecurityLevel.none,
      );

      await _storage.set(key, value, options);
      _showMessage('数据已保存');
    } catch (e) {
      _showMessage('保存失败: $e');
    }
  }

  Future<void> _loadData() async {
    final key = _keyController.text;

    if (key.isEmpty) {
      _showMessage('请输入键');
      return;
    }

    try {
      final value = await _storage.get<String>(key);
      setState(() {
        _resultText = value ?? '未找到数据';
      });
    } catch (e) {
      _showMessage('读取失败: $e');
    }
  }

  Future<void> _removeData() async {
    final key = _keyController.text;

    if (key.isEmpty) {
      _showMessage('请输入键');
      return;
    }

    try {
      await _storage.remove(key);
      _showMessage('数据已删除');
      setState(() {
        _resultText = '';
      });
    } catch (e) {
      _showMessage('删除失败: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KY Storage Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: '键 (Key)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: '值 (Value)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('存储引擎:'),
                const SizedBox(width: 8),
                DropdownButton<KysionStorageEngine>(
                  value: _selectedEngine,
                  onChanged: (KysionStorageEngine? value) {
                    if (value != null) {
                      setState(() {
                        _selectedEngine = value;
                      });
                    }
                  },
                  items: KysionStorageEngine.values.map((engine) {
                    return DropdownMenuItem<KysionStorageEngine>(
                      value: engine,
                      child: Text(engine.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isEncrypted,
                  onChanged: (value) {
                    setState(() {
                      _isEncrypted = value ?? false;
                    });
                  },
                ),
                const Text('加密数据'),
                const SizedBox(width: 16),
                Checkbox(
                  value: _hasExpiry,
                  onChanged: (value) {
                    setState(() {
                      _hasExpiry = value ?? false;
                    });
                  },
                ),
                const Text('设置过期时间 (1分钟)'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _saveData, child: const Text('保存')),
                ElevatedButton(onPressed: _loadData, child: const Text('读取')),
                ElevatedButton(onPressed: _removeData, child: const Text('删除')),
              ],
            ),
            const SizedBox(height: 32),
            const Text('结果:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_resultText.isEmpty ? '无数据' : _resultText),
            ),
          ],
        ),
      ),
    );
  }
}
