import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/error_handler.dart';
import 'models/note_model.dart';

class NotesRepository {
  final ApiService _apiService;

  NotesRepository(this._apiService);

  Future<UpcomingNotesResponse> getUpcomingNotes({int days = 7}) async {
    try {
      final Response response = await _apiService.dio.get(
        ApiEndpoints.upcomingNotes,
        queryParameters: {'days': days},
      );
      return UpcomingNotesResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (error) {
      throw Exception(ErrorHandler.handle(error));
    }
  }
}
