import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userAvatarKey = 'user_avatar';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // Token Management
  static Future<void> setToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  // User Data Management
  static Future<void> setUserData({
    required String userId,
    required String userName,
    required String userPhone,
    String? userAvatar,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userPhoneKey, userPhone);
    if (userAvatar != null) {
      await prefs.setString(_userAvatarKey, userAvatar);
    }
  }

  static Future<Map<String, String?>> getUserData() async {
    final prefs = await _prefs;
    return {
      'userId': prefs.getString(_userIdKey),
      'userName': prefs.getString(_userNameKey),
      'userPhone': prefs.getString(_userPhoneKey),
      'userAvatar': prefs.getString(_userAvatarKey),
    };
  }

  static Future<void> clearUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userAvatarKey);
  }

  // Clear All Data
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
