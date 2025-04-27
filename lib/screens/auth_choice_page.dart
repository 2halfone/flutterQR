import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'pin_verification_screen.dart';
import 'fingerprint_auth_screen.dart';

class AuthChoicePage extends StatefulWidget {
  const AuthChoicePage({Key? key}) : super(key: key);
  @override
  _AuthChoicePageState createState() => _AuthChoicePageState();
}

class _AuthChoicePageState extends State<AuthChoicePage> {
  final _formKey = GlobalKey<FormState>();
  bool _profileSaved = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('first_name')) {
      setState(() => _profileSaved = true);
    }
  }

  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_name', _firstNameController.text);
    await prefs.setString('last_name', _lastNameController.text);
    await prefs.setString('email', _emailController.text);
    final ts = DateTime.now().toIso8601String();
    await prefs.setString('timestamp', ts);
    setState(() => _profileSaved = true);
    // send to Google Sheets (fire-and-forget)
    _sendUserProfileToSheets(
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      ts,
    );
  }

  Future<void> _sendUserProfileToSheets(
    String firstName,
    String lastName,
    String email,
    String timestamp,
  ) async {
    final url = Uri.parse('https://script.google.com/macros/s/AKfycbxK4e-0HgV_znvMCQJiiae6bUr7o4q78lWVm3Xl27logMER_JfufCmReghjCD1RWbWB/exec');
    final body = jsonEncode({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'timestamp': timestamp,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode != 200) {
        print('sendUserProfileToSheets failed: ${response.statusCode}');
      }
    } catch (e) {
      print('sendUserProfileToSheets error: $e');
    }
  }

  Future<void> _selectAuth(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_method', method);
    if (method == 'pin') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PinVerificationScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FingerprintAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_profileSaved) {
      return Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter first name' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter last name' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveUserProfile();
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Authentication Method',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: const Icon(Icons.lock, size: 40),
                  label: const Text('Use PIN', style: TextStyle(fontSize: 22)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () => _selectAuth('pin'),
                )
                .animate()
                .fadeIn(duration: 700.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 700.ms),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint, size: 40),
                  label: const Text('Use Fingerprint', style: TextStyle(fontSize: 22)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 70),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () => _selectAuth('fingerprint'),
                )
                .animate()
                .fadeIn(duration: 900.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}