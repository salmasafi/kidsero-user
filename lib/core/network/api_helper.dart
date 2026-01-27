import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import '../utils/app_strings.dart';
import '../utils/app_preferences.dart';
import 'cache_helper.dart';

class ApiHelper {
  final Dio _dio;
  String? _token;

  ApiHelper({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    _initializeToken();
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers[AppStrings.authorization] =
                '${AppStrings.bearer} $_token';
          }
          // Add Accept-Language header
          final lang = CacheHelper.getData(key: AppStrings.language) ?? 'en';
          options.headers['Accept-Language'] = lang;

          return handler.next(options);
        },
      ),
    );
  }

  Future<void> _initializeToken() async {
    _token = await AppPreferences.getToken();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await AppPreferences.setToken(token);
  }

  Future<void> clearToken() async {
    _token = null;
    await AppPreferences.clearTokens();
  }

  Future<void> refreshToken() async {
    _token = await AppPreferences.getToken();
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException {
      rethrow;
    }
  }
}
