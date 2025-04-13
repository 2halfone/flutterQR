import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.flash_off : Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && _isScanning) {
                  setState(() {
                    _isScanning = false;
                  });
                  
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('QR Code Detected'),
                        content: Text('Content: $code'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                _isScanning = true;
                              });
                            },
                            child: const Text('Continue Scanning'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context, code);
                            },
                            child: const Text('Use This Code'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}