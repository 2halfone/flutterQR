import 'package:flutter/material.dart';
import 'package:qr_code_customizer/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';

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
    if (!mounted) return;

    final firstName = prefs.getString('first_name') ?? '';
    final lastName = prefs.getString('last_name') ?? '';
    final avatarPath = prefs.getString('avatar_path') ?? '';
    
    ImageProvider<Object> avatarImage;
    if (avatarPath.isNotEmpty && File(avatarPath).existsSync()) {
      avatarImage = FileImage(File(avatarPath));
    } else {
      avatarImage = const AssetImage('assets/backgrounds/app_icon.png');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: _buildWelcomeDialogContent(context, firstName, lastName, avatarImage),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Widget _buildWelcomeDialogContent(BuildContext context, String firstName, String lastName, ImageProvider<Object> avatarImage) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blue.shade100.withOpacity(0.5),
              ),
              CircleAvatar(
                radius: 50,
                backgroundImage: avatarImage,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome back!', // Messaggio più accogliente
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$firstName $lastName',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Icon(Icons.verified_user, color: Colors.green, size: 30),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1,1), curve: Curves.easeOutBack);
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