import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  /// Saves a credential string associated with a server and key suffix.
  Future<void> saveCredential(
    String serverId,
    String keySuffix,
    String value,
  ) async {
    final key = '${serverId}_$keySuffix';
    await _storage.write(key: key, value: value);
  }

  /// Reads a credential string.
  Future<String?> readCredential(String serverId, String keySuffix) async {
    final key = '${serverId}_$keySuffix';
    final value = await _storage.read(key: key);
    return (value != null && value.trim().isNotEmpty) ? value : null;
  }

  /// Deletes all credentials associated with a specific server.
  Future<void> deleteCredentials(String serverId) async {
    await _storage.delete(key: '${serverId}_password');
    await _storage.delete(key: '${serverId}_privateKey');
  }

  /// Saves the global master PIN.
  Future<void> saveMasterPin(String pin) async {
    await _storage.write(key: 'global_master_pin', value: pin);
  }

  /// Reads the global master PIN.
  Future<String?> readMasterPin() async {
    final value = await _storage.read(key: 'global_master_pin');
    return (value != null && value.trim().isNotEmpty) ? value : null;
  }

  // ── Brute-force metrics (Persistence) ──────────────────────────────────

  Future<void> saveFailedAttempts(int count) async {
    await _storage.write(key: 'auth_failed_attempts', value: count.toString());
  }

  Future<int> readFailedAttempts() async {
    final val = await _storage.read(key: 'auth_failed_attempts');
    return int.tryParse(val ?? '0') ?? 0;
  }

  Future<void> saveLockoutTime(DateTime? time) async {
    if (time == null) {
      await _storage.delete(key: 'auth_lockout_time');
    } else {
      await _storage.write(
        key: 'auth_lockout_time',
        value: time.toIso8601String(),
      );
    }
  }

  Future<DateTime?> readLockoutTime() async {
    final val = await _storage.read(key: 'auth_lockout_time');
    if (val == null || val.isEmpty) return null;
    return DateTime.tryParse(val);
  }
}

// Global provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
