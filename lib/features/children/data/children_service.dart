import 'package:dio/dio.dart';
import '../model/child_model.dart';
import 'dart:developer' as dev;

class ChildrenService {
  final Dio dio;

  ChildrenService({required this.dio});

  /// GET /api/users/children/
  Future<List<Child>> getChildren() async {
    try {
      dev.log('GET /api/users/children/', name: 'ChildrenService');
      final response = await dio.get('/api/users/children/');
      final parsed = ChildResponse.fromJson(response.data);
      if (parsed.success) {
        return parsed.data;
      } else {
        throw Exception('Failed to load children');
      }
    } catch (e) {
      dev.log('Error fetching children: $e', name: 'ChildrenService');
      rethrow;
    }
  }

  /// POST /api/users/children/add
  Future<Child> addChild(String code) async {
    try {
      dev.log(
        'POST /api/users/children/add with code: $code',
        name: 'ChildrenService',
      );

      final response = await dio.post(
        '/api/users/children/add',
        data: {'code': code},
      );

      final parsed = AddChildResponse.fromJson(response.data);
      if (parsed.success && parsed.data != null) {
        return parsed.data!;
      } else {
        throw Exception(
          parsed.message.isNotEmpty ? parsed.message : 'Failed to add child',
        );
      }
    } catch (e) {
      dev.log('Error adding child: $e', name: 'ChildrenService');
      rethrow;
    }
  }
}
