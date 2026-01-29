import 'package:dio/dio.dart';

import '../../features/children/model/child_model.dart' as childModel;
import '../../features/plans/model/plans_model.dart';
import '../../features/rides/models/ride_models.dart';
import '../../features/plans/model/payment_model.dart';
import '../../features/plans/model/parent_subscription_model.dart';
import '../../features/plans/model/org_service_model.dart';
import '../../features/plans/model/student_subscription_model.dart';
import '../../features/plans/model/payment_method_model.dart';
import 'api_endpoints.dart';
import '../utils/app_preferences.dart';
import '../utils/app_strings.dart';
import 'cache_helper.dart';

class ApiService {
  static const String baseUrl = 'https://Bcknd.Kidsero.com';

  final Dio dio;
  String? _token;

  ApiService()
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    _initializeToken();
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always get the latest token from storage before each request
          if (_token == null) {
            _token = await AppPreferences.getToken();
          }
          
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

  Future<ChildrenRidesResponse> getChildrenRides() async {
    final response = await dio.get('/api/users/rides/children');
    return ChildrenRidesResponse.fromJson(response.data);
  }

  Future<ActiveRidesResponse> getActiveRides() async {
    try {
      final response = await dio.get('/api/users/rides/active');
      return ActiveRidesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UpcomingRidesResponse> getUpcomingRides() async {
    try {
      final response = await dio.get('/api/users/rides/upcoming');
      return UpcomingRidesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRideTracking(String rideId) async {
    try {
      final response = await dio.get('/api/users/rides/tracking/$rideId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get child-specific ride schedule with today, upcoming, and history rides
  Future<ChildScheduleResponse> getChildSchedule(String childId) async {
    try {
      final response = await dio.get(
        '/api/users/rides/children/$childId/schedule',
      );
      return ChildScheduleResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlanModel>> getPlans() async {
    try {
      final response = await dio.get('/api/users/parentplans');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> plansList = response.data['data']['parentPlans'];
        return plansList.map((json) => PlanModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<childModel.Child>> getChildren() async {
    try {
      final response = await dio.get('/api/users/children');

      if (response.data['success'] == true) {
        final model = childModel.ChildResponse.fromJson(response.data);
        return model.children;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addChild(String childCode) async {
    try {
      await dio.post('/api/users/children/add', data: {'code': childCode});
    } catch (e) {
      rethrow;
    }
  }

  // --- PAYMENTS SECTION ---

  Future<PaymentResponse> getPayments() async {
    try {
      final response = await dio.get(ApiEndpoints.parentPayments);
      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentMethodResponse> getPaymentMethods() async {
    try {
      final response = await dio.get('/api/users/paymentmethods');
      return PaymentMethodResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentResponse> getPaymentById(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.parentPaymentDetail(id));
      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentResponse> createPayment(CreatePaymentRequest request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.parentPayments,
        data: request.toJson(),
      );
      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentResponse> createServicePayment(
    CreateServicePaymentRequest request,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.parentPaymentsOrgService,
        data: request.toJson(),
      );
      return PaymentResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // --- SUBSCRIPTIONS & SERVICES ---

  Future<ParentSubscriptionResponse> getParentSubscriptions() async {
    try {
      final response = await dio.get(ApiEndpoints.parentSubscriptions);
      return ParentSubscriptionResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<OrgServiceResponse> getOrgServices(String studentId) async {
    try {
      final response = await dio.get(ApiEndpoints.orgServices(studentId));
      return OrgServiceResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentServiceResponse> getStudentSubscriptions(
    String studentId,
  ) async {
    try {
      final response = await dio.get(
        ApiEndpoints.studentActiveServices(studentId),
      );
      return StudentServiceResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
