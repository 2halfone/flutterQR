import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Servizio per gestire le comunicazioni API relative all'autenticazione
class AuthApiService {
  static const String _sheetsApiUrl = 'https://script.google.com/macros/s/AKfycbxK4e-0HgV_znvMCQJiiae6bUr7o4q78lWVm3Xl27logMER_JfufCmReghjCD1RWbWB/exec';

  /// Invia i dati del profilo utente a Google Sheets
  Future<bool> sendUserProfileToSheets({
    required String firstName,
    required String lastName,
    required String email,
    required String timestamp,
  }) async {
    final url = Uri.parse(_sheetsApiUrl);
    final body = jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'timestamp': timestamp,
    });
    
    debugPrint('[AuthApiService] Sending profile to $url');
    debugPrint('[AuthApiService] Payload: $body');
    
    try {
      debugPrint('[AuthApiService] HTTP POST in progress...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      debugPrint('[AuthApiService] Response status: ${response.statusCode}');
      debugPrint('[AuthApiService] Response body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[AuthApiService] Error: $e');
      return false;
    }
  }
}