import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Utility class for handling image operations in the payment system.
/// Provides functionality for picking, encoding, decoding, compressing, and validating images.
class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Maximum image size in bytes (5 MB by default)
  static const int defaultMaxSizeInBytes = 5 * 1024 * 1024;

  /// Pick an image from the specified source (gallery or camera)
  /// 
  /// Returns a [File] object if an image is selected, null otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final image = await ImageUtils.pickImage(ImageSource.gallery);
  /// ```
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return null;
      }

      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      rethrow;
    }
  }

  /// Convert an image file to a base64 encoded string
  /// 
  /// Takes a [File] object and returns a base64 string representation.
  /// This is used for uploading images to the backend API.
  /// 
  /// Example:
  /// ```dart
  /// final base64String = await ImageUtils.imageToBase64(imageFile);
  /// ```
  static Future<String> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Data = base64Encode(bytes);
      final mimeType = _detectMimeType(imageFile.path);

      return 'data:$mimeType;base64,$base64Data';
    } catch (e) {
      debugPrint('Error encoding image to base64: $e');
      rethrow;
    }
  }

  /// Decode a base64 string to image bytes
  /// 
  /// Takes a base64 encoded string and returns [Uint8List] bytes
  /// that can be used to display the image.
  /// 
  /// Example:
  /// ```dart
  /// final imageBytes = ImageUtils.base64ToImage(base64String);
  /// // Use with Image.memory(imageBytes)
  /// ```
  static Uint8List base64ToImage(String base64String) {
    try {
      // Handle URL format base64 strings (e.g., "http://...")
      if (base64String.startsWith('http://') || base64String.startsWith('https://')) {
        // This is a URL, not base64. Return empty bytes to trigger error handling.
        throw FormatException('URL provided instead of base64 string');
      }
      
      // Remove data URL prefix if present
      String cleanBase64 = base64String;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',')[1];
      }
      
      // Handle base64 padding
      while (cleanBase64.length % 4 != 0) {
        cleanBase64 += '=';
      }
      
      return base64Decode(cleanBase64);
    } catch (e) {
      debugPrint('Error decoding base64 to image: $e');
      rethrow;
    }
  }

  /// Compress an image file to reduce its size
  /// 
  /// Takes a [File] object and compresses it with the specified quality (0-100).
  /// Returns a new [File] object with the compressed image.
  /// 
  /// Note: This is a simplified implementation. For production use,
  /// consider using the flutter_image_compress package for better compression.
  /// 
  /// Example:
  /// ```dart
  /// final compressed = await ImageUtils.compressImage(imageFile, quality: 70);
  /// ```
  static Future<File> compressImage(File imageFile, {int quality = 85}) async {
    try {
      // For now, we use the image_picker's built-in compression
      // by re-picking with lower quality settings
      final bytes = await imageFile.readAsBytes();
      
      // If the file is already small enough, return it as-is
      if (bytes.length <= defaultMaxSizeInBytes) {
        return imageFile;
      }

      // Create a temporary file with compressed data
      // In a real implementation, you'd use flutter_image_compress
      // For now, we'll just return the original file
      // This is a placeholder that should be enhanced with actual compression
      debugPrint('Image compression requested but not fully implemented. Consider using flutter_image_compress package.');
      return imageFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      rethrow;
    }
  }

  /// Validate if an image file size is within acceptable limits
  /// 
  /// Returns true if the file size is valid, false otherwise.
  /// Default maximum size is 5 MB.
  /// 
  /// Example:
  /// ```dart
  /// if (ImageUtils.isImageSizeValid(imageFile)) {
  ///   // Proceed with upload
  /// } else {
  ///   // Show error message
  /// }
  /// ```
  static bool isImageSizeValid(
    File imageFile, {
    int maxSizeInBytes = defaultMaxSizeInBytes,
  }) {
    try {
      final fileSize = imageFile.lengthSync();
      return fileSize <= maxSizeInBytes;
    } catch (e) {
      debugPrint('Error validating image size: $e');
      return false;
    }
  }

  /// Get the size of an image file in bytes
  /// 
  /// Returns the file size in bytes, or 0 if an error occurs.
  /// 
  /// Example:
  /// ```dart
  /// final sizeInBytes = ImageUtils.getImageSize(imageFile);
  /// final sizeInMB = sizeInBytes / (1024 * 1024);
  /// ```
  static int getImageSize(File imageFile) {
    try {
      return imageFile.lengthSync();
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0;
    }
  }

  /// Format file size in bytes to a human-readable string
  /// 
  /// Example:
  /// ```dart
  /// final formatted = ImageUtils.formatFileSize(1536000); // "1.46 MB"
  /// ```
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  static String _detectMimeType(String path) {
    if (!path.contains('.')) {
      return 'image/jpeg';
    }

    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg';
    }
  }
}
