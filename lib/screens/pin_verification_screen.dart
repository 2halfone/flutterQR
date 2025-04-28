import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
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
    return Column(
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