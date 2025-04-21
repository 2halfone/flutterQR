import 'package:flutter/material.dart';
// Added for debugPrint
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:image_picker/image_picker.dart';
import 'vercel_app_view.dart';  // Import for opening URLs in the webview
import '../scanner_bridge.dart'; // Import for native scanning functionality

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _hasScanned = false;
  final ImagePicker _picker = ImagePicker();
  
  // Animation controllers
  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize the animation controller for the border animation
    _borderAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Create a pulsing animation for the border
    _borderAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _borderAnimationController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _borderAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _borderAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    super.dispose();
  }

  // Function to check if a string is a URL
  bool _isUrl(String text) {
    final RegExp urlRegExp = RegExp(
      r'^(http|https):\/\/[^\s/$.?#].[^\s]*$',
      caseSensitive: false,
    );
    return urlRegExp.hasMatch(text);
  }

  // Function to trigger vibration feedback
  Future<void> _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 200); // Light vibration for 200ms
    }
  }

  // Function to handle the scanned QR code
  void _handleScannedCode(String code) {
    if (!_hasScanned) {
      setState(() {
        _isScanning = false;
        _hasScanned = true;
      });

      // Start border animation
      _borderAnimationController.forward();
      
      // Trigger vibration
      _triggerHapticFeedback();
      
      // Check if the code is a URL
      if (_isUrl(code)) {
        // Open URL in WebView
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VercelAppView(url: code),
            ),
          ).then((_) {
            // Resume scanning when returning from the WebView
            if (mounted) {
              setState(() {
                _isScanning = true;
                _hasScanned = false;
              });
            }
          });
        });
      } else {
        // Show dialog for non-URL content
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('QR Code Detected'),
              content: Text('Content: $code'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        _isScanning = true;
                        _hasScanned = false;
                      });
                    }
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
        });
      }
    }
  }

  // Function to pick image from gallery and scan QR code
  Future<void> _scanFromGallery() async {
    try {
      // Select an image from gallery using image_picker
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Maximum quality to ensure QR code readability
      );
      
      if (pickedFile == null) {
        return; // User canceled selection
      }
      
      // Show a loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analyzing image...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Try using native scanning first
      try {
        debugPrint("Selected image path: ${pickedFile.path}");
        final String qrContent = await ScannerBridge.scanQRFromImage(pickedFile.path);
        
        if (qrContent.isNotEmpty) {
          // QR code detected using native scanner
          _handleScannedCode(qrContent);
          return;
        }
      } catch (e) {
        // If native scanning fails, fall back to mobile_scanner package
        debugPrint('Native scanning failed, falling back to mobile_scanner: $e');
      }

      // Create a new controller for image analysis using mobile_scanner as fallback
      final tempController = MobileScannerController();
      
      try {
        // Flag to track if we've detected a QR code
        bool foundQrCode = false;
        
        // Set up a listener to detect barcodes
        final subscription = tempController.barcodes.listen(
          (capture) {
            // Avoid duplicate processing
            if (foundQrCode) return;
            
            if (capture.barcodes.isNotEmpty) {
              final barcode = capture.barcodes.first;
              final String? code = barcode.rawValue;
              
              if (code != null && code.isNotEmpty) {
                foundQrCode = true;
                
                // Process the detected QR code
                _handleScannedCode(code);
              }
            }
          },
          onError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error during analysis: $error'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        );
        
        // Start image analysis
        final success = await tempController.analyzeImage(pickedFile.path);
        
        if (!success) {
          // Clean up resources if analysis can't start
          subscription.cancel();
          tempController.dispose();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to analyze this image. Make sure it\'s a supported format.'),
                duration: Duration(seconds: 4),
              ),
            );
          }
          return;
        }
        
        // Set a detection timeout
        await Future.delayed(const Duration(seconds: 5));
        
        if (!foundQrCode && mounted) {
          // Clean up resources
          subscription.cancel();
          tempController.dispose();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No QR code found in the image. Try with a clearer image.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during processing: ${e.toString()}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          // Gallery button to scan from photos
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _scanFromGallery,
            tooltip: 'Scan from Gallery',
          ),
          IconButton(
            icon: Icon(_isScanning ? Icons.flash_off : Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => cameraController.switchCamera(),
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scanner
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && _isScanning) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null) {
                        _handleScannedCode(code);
                      }
                    }
                  },
                ),
                
                // Animated border overlay when code is detected
                if (_hasScanned)
                  AnimatedBuilder(
                    animation: _borderAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.8),
                            width: _borderAnimation.value,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                
                // Scanner guide frame (always visible)
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
          // Add a bottom button for gallery access as an alternative
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _scanFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Scan QR from Gallery'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}