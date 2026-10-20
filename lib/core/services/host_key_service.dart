import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/router/app_router.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/app_logger.dart';

/// Callback invoked on first-time host key presentation (TOFU) to verify user approval.
typedef HostKeyConfirmationCallback =
    Future<bool> Function(String serverId, String formattedFingerprint);

/// Thrown when the host key presented by the remote server does not match
/// the fingerprint pinned during the Trust-On-First-Use (TOFU) exchange.
class HostKeyMismatchException implements Exception {
  final String serverId;
  final String keyType;
  final String expectedFingerprint;
  final String actualFingerprint;

  HostKeyMismatchException({
    required this.serverId,
    required this.keyType,
    required this.expectedFingerprint,
    required this.actualFingerprint,
  });

  @override
  String toString() =>
      'HostKeyMismatchException: Host key verification failed for server $serverId ($keyType). '
      'Expected: $expectedFingerprint, Received: $actualFingerprint. '
      'Possible Man-in-the-Middle (MITM) attack!';
}

/// Service providing Trust-On-First-Use (TOFU) host key verification for SSH and SFTP.
class HostKeyService {
  final SecureStorageService _secureStorage;
  final HostKeyConfirmationCallback? _defaultConfirmationCallback;

  /// Deduplication map per [serverId] to prevent duplicate confirmation dialogs
  /// from opening during concurrent operations (e.g. background polling and terminal connect).
  final Map<String, Completer<bool>> _pendingConfirmations = {};

  HostKeyService(this._secureStorage, [this._defaultConfirmationCallback]);

  /// Default interactive TOFU confirmation dialog using the root navigator context [SEC-001].
  static Future<bool> showInteractiveTofuDialog(
    String serverId,
    String formattedFingerprint,
  ) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      AppLogger.warning(
        'SSH TOFU: No Navigator context available to prompt for host key confirmation for $serverId',
      );
      return false;
    }

    // Extract key type from formattedFingerprint (e.g. "ssh-ed25519 SHA256:..." or "ssh-rsa:...")
    String keyType = 'Unknown';
    if (formattedFingerprint.contains(' ')) {
      keyType = formattedFingerprint.split(' ').first;
    } else if (formattedFingerprint.contains(':')) {
      keyType = formattedFingerprint.split(':').first;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF18181B), // Zinc 900
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF27272A)), // Zinc 800
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.shieldAlert,
                color: AppTheme.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Trust Remote Host Key?',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The authenticity of host "$serverId" cannot be established. '
                'Are you sure you want to trust this host key and continue connecting?',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF09090B), // Zinc 950
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF27272A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Server: ',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            serverId,
                            style: GoogleFonts.firaCode(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Key Type: ',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          keyType,
                          style: GoogleFonts.firaCode(
                            color: AppTheme.terminalMint,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fingerprint:',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      formattedFingerprint,
                      style: GoogleFonts.firaCode(
                        color: const Color(0xFFE4E4E7),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA1A1AA),
            ),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Trust & Pin Key',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  /// Converts a key fingerprint buffer into a standardized readable format [SEC-013].
  ///
  /// - If the buffer is ASCII and starts with `SHA256:` or `MD5:`, returns `$type $asciiString`.
  /// - If the buffer is 32 raw bytes (raw SHA-256 digest), Base64-encodes it without `=` as `$type SHA256:$b64`.
  /// - Otherwise, formats as colon-separated hex bytes `$type:$hex`.
  static String formatFingerprint(String type, Uint8List fingerprint) {
    try {
      final asciiString = ascii.decode(fingerprint);
      if (asciiString.startsWith('SHA256:') || asciiString.startsWith('MD5:')) {
        return '$type $asciiString';
      }
    } catch (_) {
      // Not ASCII encoded, proceed to binary formats
    }

    if (fingerprint.length == 32) {
      final b64 = base64.encode(fingerprint).replaceAll('=', '');
      return '$type SHA256:$b64';
    }

    final hex = fingerprint
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':');
    return '$type:$hex';
  }

  /// Verifies the remote host key against the stored fingerprint for [serverId] [SEC-004, SEC-001].
  ///
  /// - Validates that [serverId] is non-empty.
  /// - On the first connection, surfaces the host key to [onConfirm] (or default callback).
  /// - If no confirmation callback is available, fails closed (returns false).
  /// - On user approval, pins and persists the fingerprint in secure storage.
  /// - On subsequent connections, incoming fingerprint must strictly match the pinned fingerprint.
  /// - If the fingerprint does not match, throws [HostKeyMismatchException].
  Future<bool> verifyHostKey(
    String serverId,
    String type,
    Uint8List fingerprint, {
    HostKeyConfirmationCallback? onConfirm,
  }) async {
    final cleanId = serverId.trim();
    if (cleanId.isEmpty) {
      throw ArgumentError('serverId cannot be empty for host key verification');
    }

    final currentFp = formatFingerprint(type, fingerprint);
    final storedFp = await _secureStorage.readHostKeyFingerprint(cleanId);

    if (storedFp == null) {
      // Deduplication: if a confirmation is already pending for this serverId,
      // await the pending completer future.
      if (_pendingConfirmations.containsKey(cleanId)) {
        AppLogger.info(
          'SSH TOFU: Waiting on existing confirmation for server $cleanId',
        );
        final confirmed = await _pendingConfirmations[cleanId]!.future;
        if (!confirmed) {
          throw HostKeyMismatchException(
            serverId: cleanId,
            keyType: type,
            expectedFingerprint: 'User-approved key',
            actualFingerprint: currentFp,
          );
        }
        return true;
      }

      final completer = Completer<bool>();
      _pendingConfirmations[cleanId] = completer;

      try {
        final callback = onConfirm ?? _defaultConfirmationCallback;
        if (callback == null) {
          AppLogger.warning(
            'SSH TOFU: No confirmation callback provided for server $cleanId: $currentFp (failing closed)',
          );
          completer.complete(false);
          return false;
        }

        final confirmed = await callback(cleanId, currentFp);

        if (!confirmed) {
          AppLogger.warning(
            'SSH TOFU: User rejected host key for server $cleanId: $currentFp',
          );
          completer.complete(false);
          throw HostKeyMismatchException(
            serverId: cleanId,
            keyType: type,
            expectedFingerprint: 'User-approved key',
            actualFingerprint: currentFp,
          );
        }

        AppLogger.info(
          'SSH TOFU: Pinning host key for server $cleanId: $currentFp',
        );
        await _secureStorage.saveHostKeyFingerprint(cleanId, currentFp);
        completer.complete(true);
        return true;
      } catch (e, s) {
        if (!completer.isCompleted) {
          completer.completeError(e, s);
        }
        rethrow;
      } finally {
        _pendingConfirmations.remove(cleanId);
      }
    }

    if (storedFp == currentFp || _digestsMatch(storedFp, currentFp)) {
      if (storedFp != currentFp) {
        AppLogger.info(
          'SSH TOFU: Migrating host key format for server $cleanId from "$storedFp" to "$currentFp"',
        );
        await _secureStorage.saveHostKeyFingerprint(cleanId, currentFp);
      }
      AppLogger.debug(
        'SSH TOFU: Host key verified for server $cleanId ($type)',
      );
      return true;
    }

    AppLogger.warning(
      'SSH TOFU: HOST KEY MISMATCH for server $cleanId! '
      'Expected: $storedFp, Received: $currentFp',
    );

    throw HostKeyMismatchException(
      serverId: cleanId,
      keyType: type,
      expectedFingerprint: storedFp,
      actualFingerprint: currentFp,
    );
  }

  /// Compares two fingerprints flexibly to accommodate algorithm prefix migrations
  /// and legacy colon-hex encoded ASCII string formats [SEC-013].
  static bool _digestsMatch(String fp1, String fp2) {
    final norm1 = _normalizeFingerprintString(fp1);
    final norm2 = _normalizeFingerprintString(fp2);
    if (norm1.toLowerCase() == norm2.toLowerCase()) return true;

    final raw1 = norm1.startsWith('SHA256:') ? norm1.substring(7) : norm1;
    final raw2 = norm2.startsWith('SHA256:') ? norm2.substring(7) : norm2;
    return raw1.toLowerCase() == raw2.toLowerCase();
  }

  static String _normalizeFingerprintString(String fp) {
    var s = fp.trim();

    // 1. Strip type prefix if separated by space: "ssh-ed25519 SHA256:..." -> "SHA256:..."
    if (s.contains(' ')) {
      s = s.split(' ').last.trim();
    }

    // 2. Strip type prefix if separated by first colon: "ssh-ed25519:53:48:..." -> "53:48:..."
    if (s.contains(':') && !s.startsWith('SHA256:') && !s.startsWith('MD5:')) {
      final firstColon = s.indexOf(':');
      final remainder = s.substring(firstColon + 1);
      if (remainder.contains(':')) {
        s = remainder;
      }
    }

    // 3. Detect colon-separated hex bytes that represent ASCII text (legacy formatting)
    if (s.contains(':') && !s.startsWith('SHA256:') && !s.startsWith('MD5:')) {
      final hexParts = s.split(':');
      final isHex =
          hexParts.isNotEmpty &&
          hexParts.every(
            (p) => p.length == 2 && int.tryParse(p, radix: 16) != null,
          );
      if (isHex) {
        try {
          final bytes = Uint8List.fromList(
            hexParts.map((p) => int.parse(p, radix: 16)).toList(),
          );
          final decoded = ascii.decode(bytes);
          if (decoded.startsWith('SHA256:') || decoded.startsWith('MD5:')) {
            return decoded.trim();
          }
        } catch (_) {
          // Keep s as is
        }
      }
    }

    return s.trim();
  }

  /// Clears the pinned host key fingerprint for [serverId].
  Future<void> resetHostKey(String serverId) async {
    final cleanId = serverId.trim();
    if (cleanId.isNotEmpty) {
      await _secureStorage.deleteHostKeyFingerprint(cleanId);
    }
  }
}

/// Global provider for [HostKeyService].
final hostKeyServiceProvider = Provider<HostKeyService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return HostKeyService(
    secureStorage,
    HostKeyService.showInteractiveTofuDialog,
  );
});
