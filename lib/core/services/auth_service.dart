import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/api_helper.dart';
import '../network/api_service.dart';
import '../utils/app_preferences.dart';
import '../routing/routes.dart';
import '../routing/app_router.dart';
import '../../main.dart';

/// Global service to handle authentication-related operations
/// including forced logout due to token expiration or 403 errors
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  ApiHelper? _apiHelper;
  ApiService? _apiService;

  /// Initialize the service with API instances
  void initialize({ApiHelper? apiHelper, ApiService? apiService}) {
    _apiHelper = apiHelper;
    _apiService = apiService;
  }

  /// Handle forced logout due to token expiration or 403 error
  /// This will clear all cached data and redirect to login screen
  Future<void> handleForceLogout({String? reason}) async {
    debugPrint('Force logout triggered: ${reason ?? 'Token expired or unauthorized'}');
    
    try {
      // Clear all cached tokens and user data
      await AppPreferences.clearTokens();
      await AppPreferences.clearUserData();
      
      // Clear tokens in API services
      if (_apiHelper != null) {
        await _apiHelper!.clearToken();
      }
      if (_apiService != null) {
        await _apiService!.clearToken();
      }
      
      // Navigate to login screen
      _navigateToLogin();
      
    } catch (e) {
      debugPrint('Error during force logout: $e');
      // Even if there's an error, try to navigate to login
      _navigateToLogin();
    }
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      // Clear all navigation stack and go to login
      GoRouter.of(context).go(Routes.login);
    } else {
      // Fallback - use the global router
      AppRouter.router.go(Routes.login);
    }
  }

  /// Check if current user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await AppPreferences.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Handle 403 Forbidden response
  Future<void> handleForbiddenResponse() async {
    await handleForceLogout(reason: 'Access forbidden - token may be expired');
  }

  /// Handle 401 Unauthorized response  
  Future<void> handleUnauthorizedResponse() async {
    await handleForceLogout(reason: 'Unauthorized - token may be invalid');
  }
}
