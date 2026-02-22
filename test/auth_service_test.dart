import 'package:flutter_test/flutter_test.dart';
import 'package:kidsero_parent/core/services/auth_service.dart';
import 'package:kidsero_parent/core/interceptors/auth_interceptor.dart';

void main() {
  group('Auth Service Integration Tests', () {
    test('AuthService should be singleton', () {
      final service1 = AuthService();
      final service2 = AuthService();
      
      expect(identical(service1, service2), true);
    });

    test('AuthInterceptor should create without error', () {
      expect(() => AuthInterceptor(), returnsNormally);
    });

    test('AuthService should initialize without error', () {
      final service = AuthService();
      expect(() => service.initialize(), returnsNormally);
    });
  });
}
