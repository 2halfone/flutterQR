import 'package:flutter/material.dart';

class PinEntryPage extends StatelessWidget {
  const PinEntryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: const Center(
        child: Text('PIN entry screen placeholder'),
      ),
    );
  }
}