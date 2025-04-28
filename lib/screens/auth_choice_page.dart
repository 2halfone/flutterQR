import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'pin_verification_screen.dart';
import 'fingerprint_auth_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthChoicePage extends StatefulWidget {
  const AuthChoicePage({Key? key}) : super(key: key);
  @override
  _AuthChoicePageState createState() => _AuthChoicePageState();
}

class _AuthChoicePageState extends State<AuthChoicePage> {
  final _formKey = GlobalKey<FormState>();
  bool _profileSaved = false;
  String? _avatarPath;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('first_name')) {
      setState(() {
        _profileSaved = true;
        final savedAvatar = prefs.getString('avatar_path');
        if (savedAvatar != null && savedAvatar.isNotEmpty) {
          _avatarPath = savedAvatar;
        }
      });
    }
  }

  Future<void> _saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('first_name', _firstNameController.text);
    await prefs.setString('last_name', _lastNameController.text);
    await prefs.setString('email', _emailController.text);
    final ts = DateTime.now().toIso8601String();
    await prefs.setString('timestamp', ts);
    _sendUserProfileToSheets(
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      ts,
    );
    setState(() => _profileSaved = true);
  }

  Future<void> _pickAvatar() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', file.path);
      setState(() => _avatarPath = file.path);
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
    debugPrint('[_sendUserProfileToSheets] Sending to $url');
    debugPrint('[_sendUserProfileToSheets] Payload: $body');
    try {
      debugPrint('[_sendUserProfileToSheets] HTTP POST in progress...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      debugPrint('[_sendUserProfileToSheets] Response status: ${response.statusCode}');
      debugPrint('[_sendUserProfileToSheets] Response body: ${response.body}');
      if (response.statusCode != 200) {
        debugPrint('[_sendUserProfileToSheets] Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[_sendUserProfileToSheets] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_profileSaved) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF81D4FA), Color(0xFF80DEEA)],
            ),
          ),
          child: SingleChildScrollView(
            // full-height box to enable vertical centering
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                hintText: 'First Name',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF42A5F5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF26C6DA)),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter first name' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                hintText: 'Last Name',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF42A5F5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF26C6DA)),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter last name' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF42A5F5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF26C6DA)),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : 'Enter valid email',
                            ),
                            const SizedBox(height: 24),
                            if (_avatarPath?.isNotEmpty ?? false) ...[
                              // avatar with shadow for relief
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: FileImage(File(_avatarPath!)),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            ElevatedButton.icon(
                              onPressed: _pickAvatar,
                              icon: const Icon(Icons.image),
                              label: const Text('Choose Avatar'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _saveUserProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF26C6DA),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    // else, show authentication choice UI
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
                  textAlign: TextAlign.center,
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