import 'package:flutter/material.dart';
import 'package:qr_code_customizer/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome back,',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '$firstName $lastName',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
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