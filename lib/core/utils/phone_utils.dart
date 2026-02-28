import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

/// Utility class for phone-related operations
class PhoneUtils {
  /// Launch phone dialer with the given phone number
  /// 
  /// [phoneNumber] - The phone number to call (can include country code)
  /// 
  /// Returns true if the phone app was launched successfully
  static Future<bool> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      dev.log('Phone number is empty', name: 'PhoneUtils');
      return false;
    }

    // Clean the phone number (remove spaces, dashes, etc.)
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Add country code if the number starts with 0 (local Egyptian number)
    if (cleanNumber.startsWith('0') && !cleanNumber.startsWith('+')) {
      cleanNumber = '+20${cleanNumber.substring(1)}';
      dev.log('Added Egypt country code: $cleanNumber', name: 'PhoneUtils');
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    
    try {
      dev.log('Attempting to call: $cleanNumber', name: 'PhoneUtils');
      
      if (await canLaunchUrl(phoneUri)) {
        final launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
        dev.log('Phone app launched: $launched', name: 'PhoneUtils');
        return launched;
      } else {
        dev.log('Cannot launch phone app for: $cleanNumber', name: 'PhoneUtils');
        return false;
      }
    } catch (e) {
      dev.log('Error launching phone app: $e', name: 'PhoneUtils');
      return false;
    }
  }

  /// Format phone number for display
  /// 
  /// Example: +966501234567 -> +966 50 123 4567
  /// Example: +201090264556 -> +20 109 026 4556
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Add country code if the number starts with 0 (local Egyptian number)
    if (cleaned.startsWith('0') && !cleaned.startsWith('+')) {
      cleaned = '+20${cleaned.substring(1)}';
    }
    
    // If it starts with +966 (Saudi Arabia)
    if (cleaned.startsWith('+966')) {
      if (cleaned.length >= 13) {
        return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
      }
    }
    
    // If it starts with +20 (Egypt)
    if (cleaned.startsWith('+20')) {
      if (cleaned.length >= 13) {
        return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
      }
    }
    
    // Default: just return the cleaned number
    return cleaned;
  }
}
