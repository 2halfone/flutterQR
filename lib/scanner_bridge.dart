import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';  // Import for debugPrint
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;

/// A bridge to access native QR code scanning functionality
class ScannerBridge {
  /// The method channel used to communicate with the native platform
  static const MethodChannel _channel = MethodChannel('scan_image');
  
  // For Kotlin path validation
  static const MethodChannel _validationChannel = MethodChannel('path_validation');

  /// Scans a QR code from an image file path using the native platform APIs
  /// 
  /// [imagePath] is the path to the image file to scan
  /// Returns the content of the QR code if found, or an empty string if not found
  /// Throws a [PlatformException] if the platform call fails or file doesn't exist
  static Future<String> scanQRFromImage(String imagePath) async {
    try {
      // Check if the file exists before sending to Kotlin
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw PlatformException(
          code: 'FILE_NOT_FOUND',
          message: 'Image file does not exist at path: $imagePath',
          details: null,
        );
      }

      debugPrint('File exists, sending to Kotlin: $imagePath');
      debugPrint('File size: ${file.lengthSync()} bytes');
      
      final String? result = await _channel.invokeMethod('scanFromImage', {
        'imagePath': imagePath,
      });
      return result ?? '';
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to scan QR code: ${e.message}',
        details: e.details,
      );
    } catch (e) {
      throw PlatformException(
        code: 'UNEXPECTED_ERROR',
        message: 'Failed to scan QR code: ${e.toString()}',
        details: null,
      );
    }
  }
  
  /// Opens the gallery to pick an image and returns the file path
  /// 
  /// Returns the path to the selected image, or null if no image was selected
  /// Prints the file path to the console and checks if it's valid for Kotlin
  static Future<String?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      if (pickedFile != null) {
        final String filePath = pickedFile.path;
        debugPrint('Selected image path: $filePath');
        
        // Check if the file exists
        final bool fileExists = File(filePath).existsSync();
        debugPrint('File exists: $fileExists');
        
        // Print path details relevant for Kotlin
        debugPrint('Path for Kotlin usage:');
        debugPrint('- Raw path: $filePath');
        debugPrint('- Path with escaped backslashes: ${filePath.replaceAll(r'\', r'\\')}');
        debugPrint('- URI format: file://${filePath.replaceAll(r'\', '/')}');
        
        try {
          // Try to invoke a method on the Kotlin side to validate the path
          // This requires implementing the method in the Kotlin code
          final bool? isValid = await _validationChannel.invokeMethod<bool>(
            'isValidFilePath', 
            {'path': filePath}
          );
          debugPrint('Path validation from Kotlin: ${isValid ?? 'Not implemented'}');
        } catch (e) {
          debugPrint('Path validation method not implemented in Kotlin: $e');
        }
        
        return filePath;
      } else {
        debugPrint('No image selected');
        return null;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
}