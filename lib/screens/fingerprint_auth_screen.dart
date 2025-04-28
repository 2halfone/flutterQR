import 'package:flutter/material.dart';
import 'package:qr_code_customizer/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'dart:io';

class FingerprintAuthScreen extends StatefulWidget {
  const FingerprintAuthScreen({Key? key}) : super(key: key);

  @override
  _FingerprintAuthScreenState createState() => _FingerprintAuthScreenState();
}

class _FingerprintAuthScreenState extends State<FingerprintAuthScreen> {
  bool _isAuthenticating = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startAuth();
  }

  Future<void> _showWelcomeDialogAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('first_name') ?? '';
    final lastName = prefs.getString('last_name') ?? '';
    final avatarPath = prefs.getString('avatar_path') ?? '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: (avatarPath.isNotEmpty
                    ? FileImage(File(avatarPath))
                    : const AssetImage('assets/images/avatar.png')) as ImageProvider<Object>?,
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome back,',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 16),
              Text(
                '$firstName $lastName',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 4));
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Future<void> _startAuth() async {
    final success = await _authService.authenticateBiometric();
    if (!mounted) return;
    if (success) {
      _showWelcomeDialogAndNavigate();
    } else {
      setState(() => _isAuthenticating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fingerprint Authentication')),
      body: Center(
        child: _isAuthenticating
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _startAuth,
                child: const Text('Retry Authentication'),
              ),
      ),
    );
  }
}