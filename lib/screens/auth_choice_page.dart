import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pin_verification_screen.dart';
import 'fingerprint_auth_screen.dart';

// Importo dei nuovi servizi modulari
import '../services/auth_profile_service.dart';
import '../services/auth_storage_service.dart';

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
  final _emailController = TextEditingController();
  
  // Istanze dei servizi
  final _profileService = AuthProfileService();
  final _storageService = AuthStorageService();

  // Aggiunto per l'effetto hover sulla Card
  bool _isCardHovered = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final isProfileSaved = await _profileService.isProfileComplete();
    if (isProfileSaved) {
      final avatarPath = await _storageService.loadAvatarPath();
      setState(() {
        _profileSaved = true;
        if (avatarPath != null && avatarPath.isNotEmpty) {
          _avatarPath = avatarPath;
        }
      });
    }
  }

  Future<void> _saveUserProfile() async {
    final success = await _profileService.saveUserProfile(
      firstName: _firstNameController.text,
      email: _emailController.text,
      avatarPath: _avatarPath,
    );
    
    if (success) {
      setState(() => _profileSaved = true);
    }
  }

  Future<void> _pickAvatar() async {
    final pickedPath = await _profileService.pickAvatar();
    if (pickedPath != null) {
      setState(() => _avatarPath = pickedPath);
    }
  }

  Future<void> _selectAuth(String method) async {
    await _profileService.setAuthenticationMethod(method);
    
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
    print('Building AuthChoicePage - _profileSaved: $_profileSaved'); // <-- Debug print
    if (!_profileSaved) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5), // Sfondo pagina elegante
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isCardHovered = true),
              onExit: (_) => setState(() => _isCardHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()..scale(_isCardHovered ? 1.02 : 1.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: _isCardHovered ? 12 : 6,
                    shadowColor: Colors.blueGrey.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Create Your Profile',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic),
                            const SizedBox(height: 30), // Aumentato spazio
                            TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                hintText: 'First Name',
                                prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF0052D4), width: 1.5),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Enter first name' : null,
                            ).animate().fadeIn(delay: 200.ms, duration: 450.ms).slideX(begin: -0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: 18), // Leggermente aumentato
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF0052D4), width: 1.5),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : 'Enter valid email',
                            ).animate().fadeIn(delay: 350.ms, duration: 450.ms).slideX(begin: -0.2, curve: Curves.easeOutCubic),
                            const SizedBox(height: 28), // Aumentato spazio
                            if (_avatarPath?.isNotEmpty ?? false) ...[
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundImage: FileImage(File(_avatarPath!)),
                                ),
                              ).animate().scale(delay: 450.ms, duration: 400.ms, curve: Curves.elasticOut),
                              const SizedBox(height: 18),
                            ],
                            ElevatedButton.icon(
                              onPressed: _pickAvatar,
                              icon: Icon(Icons.add_a_photo_outlined, color: Colors.grey[700]),
                              label: Text(
                                _avatarPath == null ? 'Choose Avatar' : 'Change Avatar',
                                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE9ECEF),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ).animate().fadeIn(delay: 500.ms, duration: 450.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic),
                            const SizedBox(height: 28), // Aumentato spazio
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _saveUserProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0052D4), // Blu elegante
                                minimumSize: const Size(double.infinity, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: const Color(0xFF0052D4).withOpacity(0.4),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ).animate().fadeIn(delay: 650.ms, duration: 450.ms).scale(begin: const Offset(0.9,0.9), end: const Offset(1,1), curve: Curves.elasticOut),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95,0.95), end: const Offset(1,1), curve: Curves.easeOutCubic),
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
            child: ConstrainedBox( // Widget aggiunto per limitare la larghezza
              constraints: const BoxConstraints(maxWidth: 540), // Larghezza massima impostata a 540px
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
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .fadeIn(duration: 700.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 700.ms)
                  .then(delay: 500.ms)
                  .shimmer(delay: 200.ms, duration: 1800.ms, color: Colors.white.withOpacity(0.4))
                  .elevation(begin: 0, end: 12, curve: Curves.easeInOut, duration: 1200.ms),
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
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .fadeIn(duration: 900.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 900.ms)
                  .then(delay: 300.ms)
                  .shimmer(delay: 400.ms, duration: 1800.ms, color: Colors.white.withOpacity(0.5))
                  .elevation(begin: 0, end: 12, curve: Curves.easeInOut, duration: 1400.ms)
                  .blurXY(begin: 0, end: 2, duration: 1500.ms, curve: Curves.easeInOut),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}