import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'auth_storage_service.dart';
import 'auth_api_service.dart';

/// Servizio per gestire le operazioni relative al profilo utente
class AuthProfileService {
  final AuthStorageService _storageService = AuthStorageService();
  final AuthApiService _apiService = AuthApiService();
  final ImagePicker _picker = ImagePicker();

  /// Carica l'avatar dell'utente dalla galleria
  Future<String?> pickAvatar() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await _storageService.saveAvatarPath(file.path);
      return file.path;
    }
    return null;
  }

  /// Salva e sincronizza il profilo utente
  Future<bool> saveUserProfile({
    required String firstName, 
    required String email,
    String? avatarPath,
  }) async {
    try {
      // Salva il profilo localmente e ottieni il timestamp
      final timestamp = await _storageService.saveUserProfile(
        firstName: firstName,
        email: email,
        avatarPath: avatarPath,
      );
      
      // Invia il profilo al server usando lo stesso timestamp
      await _apiService.sendUserProfileToSheets(
        firstName: firstName,
        email: email,
        timestamp: timestamp,
      );
      
      return true;
    } catch (e) {
      debugPrint('[AuthProfileService] Error saving profile: $e');
      return false;
    }
  }

  /// Verifica se il profilo è stato salvato
  Future<bool> isProfileComplete() async {
    return await _storageService.isProfileSaved();
  }

  /// Imposta il metodo di autenticazione scelto dall'utente
  Future<void> setAuthenticationMethod(String method) async {
    await _storageService.saveAuthMethod(method);
  }
}