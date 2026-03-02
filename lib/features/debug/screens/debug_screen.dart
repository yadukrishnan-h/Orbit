import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import 'package:orbit/core/services/ssh_service.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/debug/models/debug_server.dart';
import 'package:path_provider/path_provider.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Isar? _isar;
  final _storage = const FlutterSecureStorage();
  final _sshService = SshService();

  // SSH Form
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '22');
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String _sshOutput = '';
  Color _sshOutputColor = AppTheme.textSecondary;
  bool _isConnecting = false;

  // Logs
  String _isarLog = '';
  String _secureStorageLog = '';

  @override
  void initState() {
    super.initState();
    _initIsar();
  }

  Future<void> _initIsar() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [DebugServerSchema],
        directory: dir.path,
        name:
            'debug_instance_${DateTime.now().millisecondsSinceEpoch}', // Unique name to avoid locks during debug
      );
      setState(() => _isarLog = 'Isar initialized.');
    } catch (e) {
      setState(() => _isarLog = 'Isar Init Failed: $e');
    }
  }

  @override
  void dispose() {
    _isar?.close();
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 1 Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Pillar 1: Theme & Responsiveness'),
            const SizedBox(height: 16),
            const DebugResponsivenessWidget(),
            const SizedBox(height: 32),
            _buildSectionHeader('Pillar 2: Secure Storage & Database'),
            const SizedBox(height: 16),
            _buildDatabaseSection(),
            const SizedBox(height: 32),
            _buildSectionHeader('Pillar 3: SSH Connectivity'),
            const SizedBox(height: 16),
            _buildSshSection(),
            const SizedBox(height: 32),
            _buildSectionHeader('Pillar 4: Dashboard Mockup'),
            const SizedBox(height: 16),
            _buildDashboardMockup(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  // Pillar 2
  Widget _buildDatabaseSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addTestServer,
                    child: const Text('Add Test Server'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    onPressed: _readServers,
                    child: const Text('Read Servers'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isarLog.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                color: Colors.black12,
                child: Text(_isarLog,
                    style: const TextStyle(fontFamily: 'monospace')),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testEncryption,
              child: const Text('Test Encryption'),
            ),
            if (_secureStorageLog.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _secureStorageLog,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _secureStorageLog.contains('Success')
                      ? AppTheme.success
                      : AppTheme.critical,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addTestServer() async {
    if (_isar == null) return;
    final server = DebugServer()
      ..name = 'Test Server ${DateTime.now().second}'
      ..hostname = '192.168.1.100'
      ..port = 22
      ..username = 'admin';

    await _isar!.writeTxn(() async {
      await _isar!.debugServers.put(server);
    });
    setState(() => _isarLog = 'Saved server: ${server.name}');
  }

  Future<void> _readServers() async {
    if (_isar == null) return;
    final servers = await _isar!.debugServers.where().findAll();
    setState(() => _isarLog =
        'Servers in Isar:\n${servers.map((s) => '- ${s.name}').join('\n')}');
  }

  Future<void> _testEncryption() async {
    try {
      const key = 'debug_secret';
      const value = 'SuperSecretPa\$\$word';
      await _storage.write(key: key, value: value);
      final readBack = await _storage.read(key: key);

      if (readBack == value) {
        setState(() => _secureStorageLog =
            'Success: Data encrypted and retrieved correctly.');
      } else {
        setState(() => _secureStorageLog = 'Failure: Data mismatch.');
      }
    } catch (e) {
      setState(() => _secureStorageLog = 'Failure: $e');
    }
  }

  // Pillar 3
  Widget _buildSshSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _hostController,
                decoration: const InputDecoration(labelText: 'Host')),
            const SizedBox(height: 8),
            TextField(
                controller: _portController,
                decoration: const InputDecoration(labelText: 'Port')),
            const SizedBox(height: 8),
            TextField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 8),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isConnecting ? null : _testConnection,
              child: _isConnecting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Connect'),
            ),
            const SizedBox(height: 16),
            if (_sshOutput.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: _sshOutputColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _sshOutput,
                  style: TextStyle(
                      color: _sshOutputColor, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isConnecting = true;
      _sshOutput = 'Connecting...';
      _sshOutputColor = AppTheme.textSecondary;
    });

    try {
      final result = await _sshService.connectAndExecute(
        _hostController.text,
        int.tryParse(_portController.text) ?? 22,
        _userController.text,
        _passController.text,
        'whoami',
      );
      if (mounted) {
        setState(() {
          _sshOutput = 'Success: $result'.trim();
          _sshOutputColor = AppTheme.success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sshOutput = 'Error: $e';
          _sshOutputColor = AppTheme.critical;
        });
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  // Pillar 4
  Widget _buildDashboardMockup() {
    return const Center(child: Text('Dashboard Mockup Disabled'));
  }
}

class DebugResponsivenessWidget extends StatelessWidget {
  const DebugResponsivenessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    String mode = 'Mobile';
    if (width >= 1100) {
      mode = 'Desktop';
    } else if (width >= 600) {
      mode = 'Tablet';
    }

    return Card(
      // Theme handles color and border
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                'Screen Size: ${size.width.toStringAsFixed(1)} x ${size.height.toStringAsFixed(1)}'),
            const SizedBox(height: 8),
            Text(
              'Mode: $mode',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
