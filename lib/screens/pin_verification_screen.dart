import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_page.dart';
import 'set_pin_screen.dart';

class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({Key? key}) : super(key: key);

  @override
  PinVerificationScreenState createState() => PinVerificationScreenState();
}

class PinVerificationScreenState extends State<PinVerificationScreen> {
  String _pin = '';
  final int _pinLength = 4;
  String _correctPin = '';

  @override
  void initState() {
    super.initState();
    _loadOrRedirect();
  }

  Future<void> _loadOrRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final stored = prefs.getString('user_pin');
    if (stored == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetPinScreen()),
      );
    } else {
      setState(() => _correctPin = stored);
    }
  }

  void _onKeyTap(String value) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += value;
        if (_pin.length == _pinLength) {
          _validatePin();
        }
      });
    }
  }

  Future<void> _showWelcomeDialogAndNavigate() async {
    // Pre-caricamento dei dati prima di mostrare il dialogo
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    
    final firstName = prefs.getString('first_name') ?? '';
    final lastName = prefs.getString('last_name') ?? '';
    final avatarPath = prefs.getString('avatar_path') ?? ''; // Carica l'avatarPath anche qui
    
    ImageProvider<Object> avatarImage;
    if (avatarPath.isNotEmpty && File(avatarPath).existsSync()) {
      avatarImage = FileImage(File(avatarPath));
    } else {
      avatarImage = const AssetImage('assets/backgrounds/app_icon.png'); // Fallback all'icona dell'app
    }
    
    // Mostra il dialogo con l'icona dell'app fissa
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Angoli più arrotondati
        elevation: 8,
        backgroundColor: Colors.transparent, // Sfondo trasparente per il contenuto personalizzato
        child: _buildWelcomeDialogContent(context, firstName, lastName, avatarImage),
      ),
    );
    
    // Riduzione del tempo di attesa da 3 a 1 secondo
    await Future.delayed(const Duration(seconds: 2)); // Aumentato leggermente per dare tempo di leggere
    
    if (!mounted) return;
    Navigator.of(context).pop(); // Chiude il dialogo
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
            style: TextStyle( // Potresti usare GoogleFonts.lato o simile qui
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$firstName $lastName',
            style: TextStyle( // Potresti usare GoogleFonts.lato o simile qui
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

  void _validatePin() {
    if (_correctPin.isNotEmpty && _pin == _correctPin) {
      _showWelcomeDialogAndNavigate();
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN')),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _pin = '';
        });
      });
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (index) {
              bool filled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.circle,
                  size: 16,
                  color: filled ? Colors.black : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 530),
        child: Column(
          children: [
            for (var row in [ ['1','2','3'], ['4','5','6'], ['7','8','9'], ['','0',''] ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((value) {
                    if (value == '') {
                      int pos = row.indexOf(value);
                      if (pos == 0) {
                        return _buildActionButton('C', _onClear);
                      } else {
                        return _buildActionButton('', _onBackspace, icon: Icons.backspace);
                      }
                    } else {
                      return _buildNumberButton(value);
                    }
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () => _onKeyTap(number),
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      child: Text(number, style: const TextStyle(fontSize: 24)),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {IconData? icon}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
      child: icon != null ? Icon(icon) : Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}