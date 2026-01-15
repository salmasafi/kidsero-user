import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _parentTokenKey = 'parent_token';
  static const String _driverTokenKey = 'driver_token';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userAvatarKey = 'user_avatar';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // Token Management
  static Future<void> setParentToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_parentTokenKey, token);
    await prefs.setString(_userRoleKey, 'parent');
  }

  static Future<String?> getParentToken() async {
    final prefs = await _prefs;
    return prefs.getString(_parentTokenKey);
  }

  static Future<void> setDriverToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_driverTokenKey, token);
    await prefs.setString(_userRoleKey, 'driver');
  }

  static Future<String?> getDriverToken() async {
    final prefs = await _prefs;
    return prefs.getString(_driverTokenKey);
  }

  static Future<String?> getCurrentToken() async {
    final prefs = await _prefs;
    final role = prefs.getString(_userRoleKey);
    
    if (role == 'parent') {
      return prefs.getString(_parentTokenKey);
    } else if (role == 'driver') {
      return prefs.getString(_driverTokenKey);
    }
    return null;
  }

  static Future<void> clearTokens() async {
    final prefs = await _prefs;
    await prefs.remove(_parentTokenKey);
    await prefs.remove(_driverTokenKey);
    await prefs.remove(_userRoleKey);
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

  // Role Management
  static Future<String?> getUserRole() async {
    final prefs = await _prefs;
    return prefs.getString(_userRoleKey);
  }

  static Future<bool> isParent() async {
    final role = await getUserRole();
    return role == 'parent';
  }

  static Future<bool> isDriver() async {
    final role = await getUserRole();
    return role == 'driver';
  }

  // Clear All Data
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
