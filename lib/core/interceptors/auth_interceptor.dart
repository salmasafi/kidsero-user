import 'package:dio/dio.dart';
import '../services/auth_service.dart';

/// Interceptor to handle authentication errors and token expiration
/// Automatically redirects to login screen on 401/403 responses
class AuthInterceptor extends Interceptor {
  final AuthService _authService;

  AuthInterceptor({AuthService? authService}) 
      : _authService = authService ?? AuthService();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check for authentication-related errors
    final statusCode = err.response?.statusCode;
    
    if (statusCode == 403) {
      // Forbidden - token may be expired or insufficient permissions
      _handleAuthError('403 Forbidden - Token expired or insufficient permissions');
    } else if (statusCode == 401) {
      // Unauthorized - token is invalid or missing
      _handleAuthError('401 Unauthorized - Invalid or missing token');
    }
    
    // Continue with the error handling
    super.onError(err, handler);
  }

  void _handleAuthError(String reason) {
    // Handle the auth error asynchronously to avoid blocking the error chain
    Future.microtask(() async {
      try {
        await _authService.handleForceLogout(reason: reason);
      } catch (e) {
        // Log error but don't throw to avoid breaking the error chain
        print('Error in auth interceptor: $e');
      }
    });
  }
}
