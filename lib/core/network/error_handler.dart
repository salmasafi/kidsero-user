import 'package:dio/dio.dart';
import '../utils/l10n_utils.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Exception) {
      return L10nUtils.translateWithGlobalContext('somethingWentWrong');
    } else {
      return L10nUtils.translateWithGlobalContext('somethingWentWrong');
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return L10nUtils.translateWithGlobalContext('somethingWentWrong'); // Or a specific timeout key
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data != null && data is Map && data['data'] != null && data['data']['message'] != null) {
          return data['data']['message'];
        }
        return L10nUtils.translateWithGlobalContext('somethingWentWrong');
      case DioExceptionType.cancel:
        return L10nUtils.translateWithGlobalContext('somethingWentWrong');
      case DioExceptionType.connectionError:
        return L10nUtils.translateWithGlobalContext('somethingWentWrong');
      default:
        return L10nUtils.translateWithGlobalContext('somethingWentWrong');
    }
  }
}
