import 'package:local_auth/local_auth.dart';

/// Thin wrapper around local_auth for biometric operations.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if the device supports and has enrolled biometrics.
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isDeviceSupported) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Prompts the user with a biometric challenge.
  /// Returns true on successful authentication.
  Future<bool> authenticate(
      {String reason = 'Authenticate to continue'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN as fallback
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
