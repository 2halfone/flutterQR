import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Import for JSON parsing
import 'vercel_app_view.dart';  // Import per aprire URL nel webview
import '../scanner_bridge.dart'; // Import per funzionalità di scansione native
import 'confirmation_screen.dart'; // Import for the confirmation screen

class DayCareQrScannerPage extends StatefulWidget {
  const DayCareQrScannerPage({Key? key}) : super(key: key);

  @override
  State<DayCareQrScannerPage> createState() => _DayCareQrScannerPageState();
}

class _DayCareQrScannerPageState extends State<DayCareQrScannerPage> with TickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _hasScanned = false;
  bool hasScannedOnce = false; // Flag to prevent multiple valid scans
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

  // Function to check if the QR code contains "type": "member"
  bool _isMemberQRCode(String code) {
    try {
      // Try to decode the QR content as JSON
      Map<String, dynamic> data = jsonDecode(code);
      // Check if the data contains "type": "member"
      return data.containsKey('type') && data['type'] == 'member';
    } catch (e) {
      // If parsing fails, it's not a valid JSON or doesn't have the required format
      return false;
    }
  }

  // Extract member information from QR code
  Map<String, dynamic>? _extractMemberInfo(String code) {
    try {
      Map<String, dynamic> data = jsonDecode(code);
      if (data.containsKey('type') && data['type'] == 'member' &&
          data.containsKey('name') && data.containsKey('surname')) {
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Function to show error dialog for non-member QR codes
  void _showNonMemberErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid QR Code'),
        content: const Text('Please scan a Day Care Member'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanning = true;
                _hasScanned = false;
              });
            },
            child: const Text('Continue Scanning'),
          ),
        ],
      ),
    );
  }

  // Function to trigger vibration feedback
  Future<void> _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 200); // Light vibration for 200ms
    }
  }

  // Function to handle the scanned QR code
  void _handleScannedCode(String code) {
    // Check if we've already processed a valid QR code
    if (hasScannedOnce) {
      // Skip processing if we've already scanned a valid QR code
      return;
    }

    if (!_hasScanned) {
      // Extract member information from QR code
      Map<String, dynamic>? memberData = _extractMemberInfo(code);
      
      // Check if the QR code is a valid member QR code
      if (memberData == null) {
        // Show error dialog and return to scanning
        _triggerHapticFeedback(); // Provide feedback
        _showNonMemberErrorDialog();
        return;
      }

      setState(() {
        _isScanning = false;
        _hasScanned = true;
        hasScannedOnce = true; // Set the flag to prevent further scanning
      });

      // Start border animation
      _borderAnimationController.forward();
      
      // Trigger vibration
      _triggerHapticFeedback();
      
      // Navigate to confirmation screen after a short delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationScreen(
              name: memberData['name'],
              surname: memberData['surname'],
            ),
          ),
        ).then((_) {
          // Resume scanning when returning from the confirmation screen, but don't reset hasScannedOnce
          setState(() {
            _isScanning = true;
            _hasScanned = false;
            // hasScannedOnce remains true
          });
        });
      });
    }
  }

  // Function to pick image from gallery and scan QR code
  Future<void> _scanFromGallery() async {
    // Don't proceed if we've already processed a valid QR code
    if (hasScannedOnce) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A valid QR code has already been scanned. Please restart the scanner to scan again.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
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
        print("Selected image path: ${pickedFile.path}");
        final String qrContent = await ScannerBridge.scanQRFromImage(pickedFile.path);
        
        if (qrContent.isNotEmpty) {
          // QR code detected using native scanner
          _handleScannedCode(qrContent);
          return;
        }
      } catch (e) {
        // If native scanning fails, fall back to mobile_scanner package
        print('Native scanning failed, falling back to mobile_scanner: $e');
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
        title: const Text('Day Care QR Scanner'),
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
          // Reset button to allow scanning again
          if (hasScannedOnce)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  hasScannedOnce = false;
                  _hasScanned = false;
                  _isScanning = true;
                });
              },
              tooltip: 'Reset Scanner',
            ),
        ],
      ),
      body: Column(
        children: [
          if (hasScannedOnce)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.green.shade100,
              child: const Text(
                'QR code has been scanned successfully',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scanner
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    // Don't process if we've already scanned a valid QR code
                    if (hasScannedOnce) return;
                    
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
                            color: Colors.green.withOpacity(0.8),
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
                      color: Colors.white.withOpacity(0.3),
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
              onPressed: hasScannedOnce ? null : _scanFromGallery, // Disable button if already scanned
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