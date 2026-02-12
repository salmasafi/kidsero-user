import 'package:dio/dio.dart';
import 'package:kidsero_driver/core/network/api_endpoints.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/error_handler.dart';
import '../../model/child_model.dart';
import 'dart:developer' as dev;

/// Repository for managing children data
/// 
/// This repository provides methods to fetch and manage children profiles
/// linked to a parent account. It abstracts the API layer and provides
/// a clean interface for the business logic layer.
class ChildrenRepository {
  final ApiHelper _apiHelper;

  ChildrenRepository(this._apiHelper);

  /// Fetches all children linked to the current parent account
  /// 
  /// Returns a list of [Child] objects on success
  /// Throws an exception with a user-friendly message on failure
  Future<List<Child>> getChildren() async {
    try {
      dev.log('Fetching children from repository', name: 'ChildrenRepository');
      
      final response = await _apiHelper.get(ApiEndpoints.children);
      final parsed = ChildResponse.fromJson(response.data);
      
      if (parsed.success) {
        dev.log('Successfully fetched ${parsed.data.length} children', name: 'ChildrenRepository');
        return parsed.data;
      } else {
        dev.log('Failed to fetch children: success=false', name: 'ChildrenRepository');
        throw Exception('Failed to load children');
      }
    } on DioException catch (e) {
      dev.log('DioException in getChildren: ${e.type}', name: 'ChildrenRepository', error: e);
      final errorMessage = ErrorHandler.handle(e);
      throw Exception(errorMessage);
    } catch (e) {
      dev.log('Error in getChildren: $e', name: 'ChildrenRepository', error: e);
      // For non-DioException errors, use ErrorHandler to get user-friendly message
      final errorMessage = ErrorHandler.handle(e);
      throw Exception(errorMessage);
    }
  }

  /// Adds a new child to the parent account using a unique child code
  /// 
  /// [code] The unique code provided by the school to link the child
  /// Returns the newly added [Child] object on success
  /// Throws an exception with a user-friendly message on failure (invalid code, already linked, etc.)
  Future<Child> addChild(String code) async {
    try {
      dev.log('Adding child with code: $code', name: 'ChildrenRepository');
      
      final response = await _apiHelper.post(
        ApiEndpoints.addChild,
        data: {'code': code},
      );
      
      final parsed = AddChildResponse.fromJson(response.data);
      
      if (parsed.success && parsed.data != null) {
        dev.log('Successfully added child: ${parsed.data!.name}', name: 'ChildrenRepository');
        return parsed.data!;
      } else {
        final errorMessage = parsed.message.isNotEmpty 
            ? parsed.message 
            : 'Failed to add child';
        dev.log('Failed to add child: $errorMessage', name: 'ChildrenRepository');
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      dev.log('DioException in addChild: ${e.type}', name: 'ChildrenRepository', error: e);
      
      // Try to extract error message from response
      if (e.response?.data != null) {
        try {
          final parsed = AddChildResponse.fromJson(e.response!.data);
          if (parsed.message.isNotEmpty) {
            throw Exception(parsed.message);
          }
        } catch (_) {
          // If parsing fails, fall through to ErrorHandler
        }
      }
      
      // Use ErrorHandler for generic error transformation
      final errorMessage = ErrorHandler.handle(e);
      throw Exception(errorMessage);
    } catch (e) {
      dev.log('Error in addChild: $e', name: 'ChildrenRepository', error: e);
      
      // If it's already an Exception with a message, rethrow it
      if (e is Exception) {
        rethrow;
      }
      
      // For other errors, use ErrorHandler to get user-friendly message
      final errorMessage = ErrorHandler.handle(e);
      throw Exception(errorMessage);
    }
  }
}
