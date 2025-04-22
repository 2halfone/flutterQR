import 'package:local_auth/local_auth.dart';

class AuthService {
  static final LocalAuthentication auth = LocalAuthentication();

  /// Prompts for biometric authentication with strict options
  Future<bool> authenticateBiometric() async {
    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return isAuthenticated;
    } catch (_) {
      return false;
    }
  }
}