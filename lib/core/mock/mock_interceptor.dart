import 'dart:developer' as dev;

import 'package:dio/dio.dart';

import 'mock_api_service.dart';
import 'mock_config.dart';

/// Dio interceptor that intercepts requests and returns mock data
/// 
/// Add this interceptor to your Dio instance when [MockConfig.enableMockData] is true.
/// 
/// Example:
/// ```dart
/// final dio = Dio();
/// if (MockConfig.enableMockData) {
///   dio.interceptors.add(MockInterceptor());
/// }
/// ```
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!MockConfig.enableMockData) {
      return handler.next(options);
    }

    dev.log('MockInterceptor: Intercepting ${options.method} ${options.path}', name: 'MockInterceptor');

    try {
      Response? mockResponse;

      switch (options.method.toUpperCase()) {
        case 'GET':
          mockResponse = await MockApiService.handleGet(
            options.path,
            queryParameters: options.queryParameters,
          );
          break;
        case 'POST':
          mockResponse = await MockApiService.handlePost(
            options.path,
            options.data,
          );
          break;
        case 'PUT':
          mockResponse = await MockApiService.handlePut(
            options.path,
            options.data,
          );
          break;
        case 'DELETE':
          mockResponse = await MockApiService.handleDelete(options.path);
          break;
        default:
          return handler.next(options);
      }

      // Create a proper response that matches Dio's expectations
      final response = Response(
        requestOptions: options,
        data: mockResponse.data,
        statusCode: mockResponse.statusCode ?? 200,
        statusMessage: mockResponse.statusCode == 200 ? 'OK' : 'Error',
        headers: Headers.fromMap({
          'content-type': ['application/json'],
        }),
        extra: options.extra,
      );

      dev.log('MockInterceptor: Returning mock response for ${options.path}', name: 'MockInterceptor');
      return handler.resolve(response);
    } catch (e) {
      dev.log('MockInterceptor: Error handling request - $e', name: 'MockInterceptor');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Mock service error: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Pass through real responses when not using mock
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Pass through errors
    return handler.next(err);
  }
}
