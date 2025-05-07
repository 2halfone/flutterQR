import 'package:shared_preferences/shared_preferences.dart';

/// Servizio per gestire il salvataggio e caricamento delle informazioni utente
class AuthStorageService {
  /// Salva i dati del profilo utente nelle SharedPreferences
  Future<String> saveUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? avatarPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_name', firstName);
    await prefs.setString('last_name', lastName);
    await prefs.setString('email', email);
    final ts = DateTime.now().toIso8601String();
    await prefs.setString('timestamp', ts);
    
    if (avatarPath != null && avatarPath.isNotEmpty) {
      await prefs.setString('avatar_path', avatarPath);
    }
    
    return ts;
  }

  /// Verifica se il profilo è stato salvato
  Future<bool> isProfileSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('first_name');
  }

  /// Carica il percorso dell'avatar
  Future<String?> loadAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatar_path');
  }

  /// Salva il percorso dell'avatar
  Future<void> saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
  }

  /// Salva il metodo di autenticazione scelto
  Future<void> saveAuthMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_method', method);
  }

  /// Carica i dati completi del profilo
  Future<Map<String, String>> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'first_name': prefs.getString('first_name') ?? '',
      'last_name': prefs.getString('last_name') ?? '',
      'email': prefs.getString('email') ?? '',
      'timestamp': prefs.getString('timestamp') ?? '',
      'avatar_path': prefs.getString('avatar_path') ?? '',
    };
  }
}