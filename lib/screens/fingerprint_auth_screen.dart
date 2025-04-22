import 'package:flutter/material.dart';
import 'package:qr_code_customizer/services/auth_service.dart';
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

  Future<void> _startAuth() async {
    final success = await _authService.authenticateBiometric();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
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