import 'package:dio/dio.dart';
import '../utils/l10n_utils.dart';
import 'exceptions.dart';

class ErrorHandler {
  /// Handles any error and returns a user-friendly message
  static String handle(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Exception) {
      return L10nUtils.translateWithGlobalContext('errorGeneric');
    } else {
      return L10nUtils.translateWithGlobalContext('errorGeneric');
    }
  }

  /// Converts errors to appropriate AppException types
  static AppException toAppException(dynamic error) {
    if (error is AppException) {
      return error;
    } else if (error is DioException) {
      return _dioToAppException(error);
    } else {
      return BusinessLogicException(
        L10nUtils.translateWithGlobalContext('errorGeneric'),
        originalError: error,
      );
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return L10nUtils.translateWithGlobalContext('errorNoInternet');
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      
      case DioExceptionType.cancel:
        return L10nUtils.translateWithGlobalContext('errorGeneric');
      
      case DioExceptionType.connectionError:
        return L10nUtils.translateWithGlobalContext('errorNoInternet');
      
      default:
        return L10nUtils.translateWithGlobalContext('errorGeneric');
    }
  }

  static AppException _dioToAppException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          L10nUtils.translateWithGlobalContext('errorNoInternet'),
          originalError: error,
          stackTrace: error.stackTrace,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        
        // Authentication errors
        if (statusCode == 401 || statusCode == 403) {
          return AuthenticationException(
            L10nUtils.translateWithGlobalContext('errorSessionExpired'),
            originalError: error,
            stackTrace: error.stackTrace,
          );
        }
        
        // Not found errors
        if (statusCode == 404) {
          return NotFoundException(
            L10nUtils.translateWithGlobalContext('errorNotFound'),
            originalError: error,
            stackTrace: error.stackTrace,
          );
        }
        
        // Server errors
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            L10nUtils.translateWithGlobalContext('errorServerUnavailable'),
            statusCode: statusCode,
            originalError: error,
            stackTrace: error.stackTrace,
          );
        }
        
        // Try to extract message from response
        final data = error.response?.data;
        String message = L10nUtils.translateWithGlobalContext('errorGeneric');
        
        if (data != null && data is Map) {
          if (data['data'] != null && data['data']['message'] != null) {
            message = data['data']['message'];
          } else if (data['message'] != null) {
            message = data['message'];
          }
        }
        
        return BusinessLogicException(
          message,
          originalError: error,
          stackTrace: error.stackTrace,
        );
      
      case DioExceptionType.cancel:
        return BusinessLogicException(
          L10nUtils.translateWithGlobalContext('errorGeneric'),
          originalError: error,
          stackTrace: error.stackTrace,
        );
      
      default:
        return BusinessLogicException(
          L10nUtils.translateWithGlobalContext('errorGeneric'),
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }
  }

  static String _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    
    // Authentication errors
    if (statusCode == 401 || statusCode == 403) {
      return L10nUtils.translateWithGlobalContext('errorSessionExpired');
    }
    
    // Not found errors
    if (statusCode == 404) {
      return L10nUtils.translateWithGlobalContext('errorNotFound');
    }
    
    // Server errors
    if (statusCode != null && statusCode >= 500) {
      return L10nUtils.translateWithGlobalContext('errorServerUnavailable');
    }
    
    // Try to extract message from response
    final data = error.response?.data;
    if (data != null && data is Map) {
      if (data['data'] != null && data['data']['message'] != null) {
        return data['data']['message'];
      } else if (data['message'] != null) {
        return data['message'];
      }
    }
    
    return L10nUtils.translateWithGlobalContext('errorGeneric');
  }
}
