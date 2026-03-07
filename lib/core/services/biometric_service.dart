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
  ///
  /// local_auth 3.x: The `options` parameter was removed. Authentication
  /// options are now passed as direct named parameters to `authenticate()`.
  Future<bool> authenticate(
      {String reason = 'Authenticate to continue'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // Allow PIN as fallback
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
