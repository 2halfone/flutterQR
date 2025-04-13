import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PreviewScreen extends StatefulWidget {
  final bool isStatic;
  final bool useTemplate;

  const PreviewScreen({
    Key? key, 
    required this.isStatic, 
    this.useTemplate = false
  }) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String qrData = 'https://example.com';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isStatic ? 'Static QR Code' : 'Dynamic QR Code',
          style: const TextStyle(fontSize: 16),
        ),
        toolbarHeight: 50,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Funzionalità rimossa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'La funzionalità di personalizzazione QR Code è stata rimossa',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}