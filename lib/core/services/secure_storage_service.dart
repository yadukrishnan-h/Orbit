import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ── Storage key constants ──────────────────────────────────────────────────
const _kMasterPin = 'global_master_pin';
const _kHiveKey = 'hive_encryption_key';
const _kFailedAttempts = 'auth_failed_attempts';
const _kLockoutTime = 'auth_lockout_time';
const _kLastFailed = 'auth_last_failed_attempt';
const _kRemainingLockoutSeconds = 'auth_remaining_lockout_seconds';

// ── PBKDF2 parameters ─────────────────────────────────────────────────────
const int _kSaltBytes = 16;
const int _kDkBytes = 32;
const int _kIterations = 100000;

class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const AndroidOptions _defaultAndroidOptions = AndroidOptions(
    resetOnError: false,
    migrateOnAlgorithmChange: true,
  );

  static const IOSOptions _defaultIosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: _defaultAndroidOptions,
            iOptions: _defaultIosOptions,
          );

  /// Helper to read from secure storage and preserve errors for fail-closed handling.
  Future<String?> _read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
      return null;
    } catch (e) {
      debugPrint('SecureStorage: Error reading key "$key": $e');
      rethrow;
    }
  }

  // ── Internal PBKDF2 helpers ──────────────────────────────────────────────

  /// Generates a cryptographically random salt.
  Uint8List _randomSalt() {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_kSaltBytes, (_) => rng.nextInt(256)),
    );
  }

  /// Derives a key from [pin] + [salt] using PBKDF2-HMAC-SHA256.
  Future<Uint8List> _deriveKey(String pin, Uint8List salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _kIterations,
      bits: _kDkBytes * 8,
    );
    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
    return Uint8List.fromList(await secretKey.extractBytes());
  }

  /// Encodes salt + derived key as `<hex-salt>:<hex-dk>`.
  String _encode(Uint8List salt, Uint8List dk) =>
      '${_toHex(salt)}:${_toHex(dk)}';

  /// Constant-time comparison of two equally-sized byte arrays.
  /// Returns true only if every byte matches.
  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  String _toHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  Uint8List _fromHex(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  // ── Master PIN API ────────────────────────────────────────────────────────

  /// Returns true if a master PIN hash is stored (PIN has been set up).
  Future<bool> hasMasterPin() async {
    final value = await _read(_kMasterPin);
    return value != null && value.isNotEmpty && value != 'null';
  }

  /// Hashes [pin] with a fresh random salt and persists `<salt>:<dk>`.
  Future<void> saveMasterPin(String pin) async {
    final salt = _randomSalt();
    final dk = await _deriveKey(pin, salt);
    await _storage.write(key: _kMasterPin, value: _encode(salt, dk));
    await recordSuccessfulAuth();
  }

  /// Verifies [pin] against the stored hash using constant-time comparison.
  ///
  /// Handles transparent migration from legacy plaintext storage: if the
  /// stored value does not contain ':' it is treated as a plaintext PIN,
  /// compared directly, and immediately re-hashed on success.
  Future<bool> verifyMasterPin(String pin) async {
    final stored = await _read(_kMasterPin);
    if (stored == null || stored.isEmpty || stored == 'null') return false;

    // ── Legacy plaintext migration ──────────────────────────────────────────
    if (!stored.contains(':')) {
      debugPrint('Security: migrating plaintext PIN to PBKDF2 hash.');
      // Constant-time string comparison is not critical here because we
      // immediately re-hash on success; the plaintext path is one-time.
      if (pin == stored) {
        await saveMasterPin(pin); // re-hash and persist
        return true;
      }
      return false;
    }

    // ── Normal PBKDF2 verify ───────────────────────────────────────────────
    final parts = stored.split(':');
    if (parts.length != 2) return false;

    final salt = _fromHex(parts[0]);
    final storedDk = _fromHex(parts[1]);
    final candidateDk = await _deriveKey(pin, salt);

    return _constantTimeEquals(candidateDk, storedDk);
  }

  // ── Server credentials ────────────────────────────────────────────────────

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
    final value = await _read(key);
    return (value != null && value.trim().isNotEmpty) ? value : null;
  }

  /// Deletes all credentials associated with a specific server.
  Future<void> deleteCredentials(String serverId) async {
    await _storage.delete(key: '${serverId}_password');
    await _storage.delete(key: '${serverId}_privateKey');
    // Also clear any pinned host key for this server
    await _storage.delete(key: 'hostkey_$serverId');
  }

  // ── SSH Host Key (TOFU) ───────────────────────────────────────────────────

  /// Persists the hex SHA-256 fingerprint for [serverId].
  Future<void> saveHostKeyFingerprint(
    String serverId,
    String hexFingerprint,
  ) async {
    await _storage.write(
      key: 'hostkey_$serverId',
      value: hexFingerprint.trim(),
    );
  }

  /// Returns the stored fingerprint for [serverId], or null if none.
  Future<String?> readHostKeyFingerprint(String serverId) async {
    final val = await _read('hostkey_$serverId');
    return (val != null && val.trim().isNotEmpty) ? val.trim() : null;
  }

  /// Deletes the pinned host key fingerprint for [serverId].
  Future<void> deleteHostKeyFingerprint(String serverId) async {
    await _storage.delete(key: 'hostkey_$serverId');
  }

  // ── Progressive Lockout & Brute-force Metrics ─────────────────────────────

  /// Calculates progressive lockout duration based on total [failedAttempts]:
  /// - < 5 attempts: 0s (no lockout)
  /// - 5 attempts: 30s
  /// - 6-7 attempts: 2m (120s)
  /// - 8-9 attempts: 10m (600s)
  /// - 10+ attempts: 30m (1800s)
  static int getLockoutDurationSeconds(int failedAttempts) {
    if (failedAttempts < 5) return 0;
    if (failedAttempts == 5) return 30;
    if (failedAttempts <= 7) return 120;
    if (failedAttempts <= 9) return 600;
    return 1800;
  }

  Future<void> saveFailedAttempts(int count) async {
    await _storage.write(key: _kFailedAttempts, value: count.toString());
  }

  Future<int> readFailedAttempts() async {
    final val = await _read(_kFailedAttempts);
    return int.tryParse(val ?? '0') ?? 0;
  }

  Future<void> saveLockoutTime(DateTime? time) async {
    if (time == null) {
      await _storage.delete(key: _kLockoutTime);
    } else {
      await _storage.write(key: _kLockoutTime, value: time.toIso8601String());
    }
  }

  Future<DateTime?> readLockoutTime() async {
    final val = await _read(_kLockoutTime);
    if (val == null || val.isEmpty) return null;
    return DateTime.tryParse(val);
  }

  Future<void> saveRemainingLockoutSeconds(int seconds) async {
    await _storage.write(
      key: _kRemainingLockoutSeconds,
      value: seconds.toString(),
    );
  }

  Future<int> readRemainingLockoutSeconds() async {
    final val = await _read(_kRemainingLockoutSeconds);
    return int.tryParse(val ?? '0') ?? 0;
  }

  /// Records a successful PIN unlock: resets failed attempts and clears lockout.
  Future<void> recordSuccessfulAuth() async {
    await saveFailedAttempts(0);
    await saveRemainingLockoutSeconds(0);
    await saveLockoutTime(null);
  }

  /// Records a failed PIN attempt.
  /// Increments failed attempts counter, determines if progressive lockout
  /// is triggered, and updates remaining lockout seconds and timestamp.
  /// Returns the lockout duration in seconds (0 if not locked out).
  Future<int> recordFailedAttempt() async {
    final now = DateTime.now();
    await saveLastFailedAttempt(now);

    final currentAttempts = await readFailedAttempts();
    final newAttempts = currentAttempts + 1;
    await saveFailedAttempts(newAttempts);

    final lockoutDuration = getLockoutDurationSeconds(newAttempts);
    if (lockoutDuration > 0) {
      await saveRemainingLockoutSeconds(lockoutDuration);
      await saveLockoutTime(now.add(Duration(seconds: lockoutDuration)));
    }
    return lockoutDuration;
  }

  /// Clears only the lockout timer (when duration expires),
  /// keeping the failedAttempts counter intact so future failures
  /// escalate progressively.
  Future<void> clearLockoutTimer() async {
    await saveRemainingLockoutSeconds(0);
    await saveLockoutTime(null);
  }

  // ── Anti-Tamper (Time-travel detection) ──────────────────────────────────

  Future<void> saveLastFailedAttempt(DateTime time) async {
    await _storage.write(key: _kLastFailed, value: time.toIso8601String());
  }

  Future<DateTime?> readLastFailedAttempt() async {
    final val = await _read(_kLastFailed);
    if (val == null || val.isEmpty) return null;
    return DateTime.tryParse(val);
  }

  // ── Hive Encryption Key ───────────────────────────────────────────────────

  Future<void> saveHiveKey(List<int> key) async {
    await _storage.write(key: _kHiveKey, value: base64Encode(key));
  }

  Future<List<int>?> readHiveKey() async {
    final val = await _read(_kHiveKey);
    if (val == null || val.isEmpty) return null;
    return base64Decode(val);
  }
}

// Global provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
