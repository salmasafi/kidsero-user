import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:kidsero_driver/core/interceptors/auth_interceptor.dart';
import 'package:kidsero_driver/core/services/auth_service.dart';

import 'auth_interceptor_test.mocks.dart';

@GenerateMocks([AuthService, ErrorInterceptorHandler])
void main() {
  group('AuthInterceptor Tests', () {
    late AuthInterceptor interceptor;
    late MockAuthService mockAuthService;
    late MockErrorInterceptorHandler mockHandler;

    setUp(() {
      mockAuthService = MockAuthService();
      mockHandler = MockErrorInterceptorHandler();
      interceptor = AuthInterceptor(authService: mockAuthService);
    });

    test('should handle 403 Forbidden error', () async {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        ),
      );

      // Act
      interceptor.onError(error, mockHandler);

      // Assert
      verify(mockAuthService.handleForceLogout(
        reason: '403 Forbidden - Token expired or insufficient permissions'
      )).called(1);
    });

    test('should handle 401 Unauthorized error', () async {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      // Act
      interceptor.onError(error, mockHandler);

      // Assert
      verify(mockAuthService.handleForceLogout(
        reason: '401 Unauthorized - Invalid or missing token'
      )).called(1);
    });

    test('should not handle other status codes', () async {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      // Act
      interceptor.onError(error, mockHandler);

      // Assert
      verifyNever(mockAuthService.handleForceLogout(reason: anyNamed('reason')));
    });

    test('should handle errors without response', () async {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      // Act
      interceptor.onError(error, mockHandler);

      // Assert
      verifyNever(mockAuthService.handleForceLogout(reason: anyNamed('reason')));
    });
  });
}
