import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pin_verification_screen.dart';
import 'fingerprint_auth_screen.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({Key? key}) : super(key: key);

  Future<void> _selectAuth(BuildContext context, String method) async {
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
                  onPressed: () => _selectAuth(context, 'pin'),
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
                  onPressed: () => _selectAuth(context, 'fingerprint'),
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