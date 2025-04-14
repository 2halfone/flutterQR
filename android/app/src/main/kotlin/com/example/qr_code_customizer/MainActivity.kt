package com.example.qr_code_customizer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.util.Log
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import java.io.File
import android.net.Uri
import android.content.ContentResolver
import java.io.FileInputStream
import java.io.IOException
import android.provider.MediaStore
import android.database.Cursor

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.qr_code_customizer/native"
    private val SCAN_CHANNEL = "scan_image"
    private val VALIDATION_CHANNEL = "path_validation"
    private val TAG = "QRCodeCustomizer" // Tag for logging

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Original channel for device info or other native features if needed
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            // Log the received method call
            Log.d("MainActivity", "Method called: ${call.method}")
            
            // Handle other method calls here
            result.notImplemented()
        }
        
        // Channel specifically for image scanning
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCAN_CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "Scan channel method called: ${call.method}")
            
            when (call.method) {
                "scanFromImage" -> {
                    // Extract the image path from the call arguments
                    val imagePath = call.argument<String>("imagePath")
                    
                    if (imagePath == null) {
                        Log.e(TAG, "Error: Image path is null")
                        result.error("INVALID_ARGUMENT", "Image path is required", null)
                        return@setMethodCallHandler
                    }
                    
                    // Log detailed information about the received path
                    logImagePathDetails(imagePath)
                    
                    // Process the image in a background thread to avoid blocking the UI
                    Thread {
                        try {
                            val qrContent = scanQRFromImage(imagePath)
                            // Return the result on the main thread
                            activity.runOnUiThread {
                                if (qrContent.isNotEmpty()) {
                                    result.success(qrContent)
                                } else {
                                    result.error("NO_QR_FOUND", "No QR code found in the image", null)
                                }
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "Error scanning image: ${e.message}", e)
                            activity.runOnUiThread {
                                result.error("SCAN_ERROR", "Error scanning image: ${e.message}", null)
                            }
                        }
                    }.start()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Channel for validating file paths for Kotlin usage
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VALIDATION_CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "Path validation method called: ${call.method}")
            
            when (call.method) {
                "isValidFilePath" -> {
                    val path = call.argument<String>("path")
                    
                    if (path == null) {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                        return@setMethodCallHandler
                    }
                    
                    // Log the path details
                    logImagePathDetails(path)
                    
                    // Validate the file path and return detailed information
                    val validationResult = validateFilePath(path)
                    Log.d("PATH_VALIDATION", validationResult.toString())
                    
                    // Return the validation result
                    result.success(validationResult["isValid"] as Boolean)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Log detailed information about the image path for debugging
     * 
     * @param imagePath The path to log
     */
    private fun logImagePathDetails(imagePath: String) {
        Log.i(TAG, "==== IMAGE PATH DETAILS START ====")
        Log.i(TAG, "Raw path received: $imagePath")
        
        // Check if it's a content URI
        if (imagePath.startsWith("content://")) {
            Log.i(TAG, "Path type: Content URI")
            try {
                val uri = Uri.parse(imagePath)
                Log.i(TAG, "URI scheme: ${uri.scheme}")
                Log.i(TAG, "URI authority: ${uri.authority}")
                Log.i(TAG, "URI path: ${uri.path}")
                
                // Try to get file details from content URI
                try {
                    val contentResolver: ContentResolver = context.contentResolver
                    val mimeType = contentResolver.getType(uri)
                    Log.i(TAG, "MIME type: $mimeType")
                    
                    // Try to get file size
                    contentResolver.openInputStream(uri)?.use { input ->
                        Log.i(TAG, "Size: ${input.available()} bytes")
                    }
                    
                    // Try to get file name
                    val cursor = contentResolver.query(uri, null, null, null, null)
                    cursor?.use {
                        if (it.moveToFirst()) {
                            val displayNameIndex = it.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
                            if (displayNameIndex >= 0) {
                                val displayName = it.getString(displayNameIndex)
                                Log.i(TAG, "Display name: $displayName")
                            }
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error getting content URI details: ${e.message}")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error parsing content URI: ${e.message}")
            }
        } else {
            Log.i(TAG, "Path type: File path")
            
            // Log file details
            val file = File(imagePath)
            Log.i(TAG, "Exists: ${file.exists()}")
            Log.i(TAG, "Is file: ${file.isFile}")
            Log.i(TAG, "Can read: ${file.canRead()}")
            Log.i(TAG, "Absolute path: ${file.absolutePath}")
            
            if (file.exists() && file.isFile) {
                Log.i(TAG, "Size: ${file.length()} bytes")
                Log.i(TAG, "Last modified: ${file.lastModified()}")
                
                // Try to get file extension and guess mime type
                val fileName = file.name
                val extension = fileName.substringAfterLast('.', "")
                Log.i(TAG, "File name: $fileName")
                Log.i(TAG, "Extension: $extension")
                
                // Try to verify if it's a valid image by attempting to decode dimensions
                try {
                    val options = BitmapFactory.Options().apply {
                        inJustDecodeBounds = true // This avoids loading the bitmap into memory
                    }
                    BitmapFactory.decodeFile(imagePath, options)
                    
                    if (options.outWidth > 0 && options.outHeight > 0) {
                        Log.i(TAG, "Image dimensions: ${options.outWidth}x${options.outHeight}")
                        Log.i(TAG, "Image format: ${options.outMimeType}")
                        Log.i(TAG, "Is valid image: true")
                    } else {
                        Log.i(TAG, "Is valid image: false (couldn't determine dimensions)")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error verifying image: ${e.message}")
                    Log.i(TAG, "Is valid image: false (exception occurred)")
                }
            }
        }
        Log.i(TAG, "==== IMAGE PATH DETAILS END ====")
    }
    
    /**
     * Scans an image file for QR codes using Google ML Kit
     * 
     * @param imagePath The path to the image file or content URI
     * @return The content of the QR code as a string, or an empty string if no QR code is found
     */
    private fun scanQRFromImage(imagePath: String): String {
        Log.d(TAG, "Scanning image from path: $imagePath")
        
        var bitmap: Bitmap? = null
        
        try {
            // Check if the path is a content URI (starts with "content://")
            if (imagePath.startsWith("content://")) {
                val uri = Uri.parse(imagePath)
                bitmap = getBitmapFromContentUri(uri)
                
                if (bitmap == null) {
                    Log.e(TAG, "Could not decode bitmap from content URI: $imagePath")
                    throw IllegalArgumentException("Could not decode image from content URI: $imagePath")
                }
                
                Log.d(TAG, "Successfully decoded bitmap from content URI: ${bitmap.width}x${bitmap.height}")
            } else {
                // Handle as a file path
                val imageFile = File(imagePath)
                
                // Explicit check for file existence before attempting to decode
                val fileExists = imageFile.exists()
                val isFile = imageFile.isFile()
                val canRead = imageFile.canRead()
                
                Log.d(TAG, "Pre-decode file check - Exists: $fileExists, Is file: $isFile, Can read: $canRead")
                
                if (!fileExists) {
                    Log.e(TAG, "File does not exist at path: $imagePath")
                    throw IllegalArgumentException("Image file does not exist: $imagePath")
                }
                
                if (!isFile) {
                    Log.e(TAG, "Path exists but is not a file: $imagePath")
                    throw IllegalArgumentException("Path exists but is not a file: $imagePath")
                }
                
                if (!canRead) {
                    Log.e(TAG, "File exists but cannot be read: $imagePath")
                    throw IllegalArgumentException("File exists but cannot be read: $imagePath")
                }
                
                Log.d(TAG, "File validated. Path: ${imageFile.absolutePath}, size: ${imageFile.length()} bytes")
                
                // Load the bitmap from the file path
                Log.d(TAG, "Attempting to decode bitmap from file...")
                try {
                    bitmap = BitmapFactory.decodeFile(imagePath)
                    
                    if (bitmap == null) {
                        Log.e(TAG, "Could not decode bitmap from path despite file existing: $imagePath")
                        Log.e(TAG, "Image format is not supported or file is corrupted")
                        throw IllegalArgumentException("Could not decode image (unsupported format or corrupted file): $imagePath")
                    }
                    
                    Log.d(TAG, "Successfully decoded bitmap: ${bitmap.width}x${bitmap.height}")
                } catch (e: OutOfMemoryError) {
                    Log.e(TAG, "OutOfMemoryError when decoding image: $imagePath", e)
                    Log.e(TAG, "Image is too large to be processed")
                    throw IllegalArgumentException("Image is too large to be processed: $imagePath")
                } catch (e: Exception) {
                    Log.e(TAG, "Exception when decoding image: $imagePath", e)
                    Log.e(TAG, "Image format is not supported or file is corrupted")
                    throw IllegalArgumentException("Could not decode image (unsupported format): $imagePath", e)
                }
            }
            
            // Create ML Kit InputImage
            val inputImage = InputImage.fromBitmap(bitmap, 0)
            
            // Configure barcode scanner to focus on QR codes
            val options = BarcodeScannerOptions.Builder()
                .setBarcodeFormats(
                    Barcode.FORMAT_QR_CODE,
                    Barcode.FORMAT_AZTEC,
                    Barcode.FORMAT_DATA_MATRIX
                )
                .build()
            
            val scanner = BarcodeScanning.getClient(options)
            
            // Use synchronized blocking to make the asynchronous ML Kit API behave synchronously
            val lock = Object()
            var result = ""
            var exception: Exception? = null
            var processCompleted = false
            
            // Process the image with ML Kit
            scanner.process(inputImage)
                .addOnSuccessListener { barcodes ->
                    synchronized(lock) {
                        if (barcodes.isNotEmpty()) {
                            // Get the first barcode detected
                            val barcode = barcodes.firstOrNull { it.rawValue != null }
                            result = barcode?.rawValue ?: ""
                        }
                        processCompleted = true
                        lock.notify()
                    }
                }
                .addOnFailureListener { e ->
                    synchronized(lock) {
                        exception = e
                        processCompleted = true
                        lock.notify()
                    }
                }
            
            // Wait for processing to complete
            synchronized(lock) {
                if (!processCompleted) {
                    try {
                        // Wait with a timeout to avoid hanging indefinitely
                        lock.wait(10000)
                    } catch (e: InterruptedException) {
                        Thread.currentThread().interrupt()
                    }
                }
            }
            
            // Clean up resources
            scanner.close()
            bitmap.recycle()
            
            // Check if there was an exception during processing
            if (exception != null) {
                throw exception as Exception
            }
            
            return result
        } catch (e: Exception) {
            // If an error occurred but we created a bitmap, clean it up
            bitmap?.recycle()
            throw e
        }
    }
    
    /**
     * Converts a content URI to a Bitmap
     */
    private fun getBitmapFromContentUri(uri: Uri): Bitmap? {
        try {
            val contentResolver: ContentResolver = context.contentResolver
            return contentResolver.openInputStream(uri)?.use { inputStream ->
                BitmapFactory.decodeStream(inputStream)
            }
        } catch (e: IOException) {
            Log.e("MainActivity", "Error reading from content URI: ${e.message}", e)
            return null
        }
    }
    
    /**
     * Validates if a file path is valid for use in Kotlin/Android
     * 
     * @param path The file path to validate
     * @return A map containing validation details
     */
    private fun validateFilePath(path: String): Map<String, Any> {
        val result = mutableMapOf<String, Any>()
        
        try {
            Log.d("PATH_VALIDATION", "Validating path: $path")
            
            // Check if the path is a content URI
            val isContentUri = path.startsWith("content://")
            result["isContentUri"] = isContentUri
            
            if (isContentUri) {
                // Validate content URI
                try {
                    val uri = Uri.parse(path)
                    val contentResolver: ContentResolver = context.contentResolver
                    
                    // Try to query the URI
                    var cursor: Cursor? = null
                    try {
                        cursor = contentResolver.query(uri, null, null, null, null)
                        result["isValid"] = cursor != null
                        result["message"] = if (cursor != null) "Content URI is valid" else "Content URI could not be queried"
                        
                        // Try to get mime type
                        val mimeType = contentResolver.getType(uri)
                        result["mimeType"] = mimeType ?: "unknown"
                    } catch (e: Exception) {
                        result["isValid"] = false
                        result["error"] = "Error querying content URI: ${e.message}"
                    } finally {
                        cursor?.close()
                    }
                } catch (e: Exception) {
                    result["isValid"] = false
                    result["error"] = "Invalid content URI format: ${e.message}"
                }
            } else {
                // Validate file path
                val file = File(path)
                val exists = file.exists()
                val isFile = file.isFile
                val canRead = file.canRead()
                
                result["exists"] = exists
                result["isFile"] = isFile
                result["canRead"] = canRead
                result["absolutePath"] = file.absolutePath
                result["isValid"] = exists && isFile && canRead
                
                // Additional debug info
                if (exists && isFile) {
                    result["size"] = file.length()
                    result["message"] = "File is valid and readable"
                    
                    // Try to identify file type
                    val mimeType = getMimeType(path)
                    result["mimeType"] = mimeType ?: "unknown"
                    
                    // Specifically check if it's an image file
                    result["isImageFile"] = mimeType?.startsWith("image/") ?: false
                    
                    // Check if the file can be decoded as a bitmap
                    val canDecodeBitmap = try {
                        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                        BitmapFactory.decodeFile(path, options)
                        options.outWidth > 0 && options.outHeight > 0
                    } catch (e: Exception) {
                        false
                    }
                    result["canDecodeBitmap"] = canDecodeBitmap
                } else {
                    result["message"] = when {
                        !exists -> "File does not exist"
                        !isFile -> "Path exists but is not a file"
                        !canRead -> "File exists but cannot be read"
                        else -> "Unknown file issue"
                    }
                }
            }
        } catch (e: Exception) {
            result["isValid"] = false
            result["error"] = "Error validating path: ${e.message}"
        }
        
        return result
    }
    
    /**
     * Get MIME type of a file
     */
    private fun getMimeType(path: String): String? {
        return try {
            val fileExtension = path.substringAfterLast('.', "")
            when (fileExtension.lowercase()) {
                "jpg", "jpeg" -> "image/jpeg"
                "png" -> "image/png"
                "gif" -> "image/gif"
                "webp" -> "image/webp"
                "bmp" -> "image/bmp"
                "pdf" -> "application/pdf"
                else -> null
            }
        } catch (e: Exception) {
            null
        }
    }
}
