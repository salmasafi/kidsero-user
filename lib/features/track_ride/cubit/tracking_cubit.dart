// lib/features/track_ride/cubit/tracking_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart'; // Adjust path
import 'package:kidsero_driver/features/track_ride/models/tracking_models.dart';

// States
abstract class TrackingState {}
class TrackingInitial extends TrackingState {}
class TrackingLoading extends TrackingState {}
class TrackingLoaded extends TrackingState {
  final TrackingData data;
  TrackingLoaded(this.data);
}
class TrackingError extends TrackingState {
  final String message;
  TrackingError(this.message);
}

// Cubit
class TrackingCubit extends Cubit<TrackingState> {
  final ApiService apiService;
  final String rideId; // The ID required for the URL

  TrackingCubit({required this.apiService, required this.rideId}) : super(TrackingInitial());

  Future<void> loadTrackingData() async {
    emit(TrackingLoading());
    try {
  final response = await apiService.getRideTracking(rideId);

  final trackingResponse = TrackingResponse.fromJson(response);
  
  if (trackingResponse.success) {
    emit(TrackingLoaded(trackingResponse.data));
  } else {
    emit(TrackingError("Failed to load tracking data"));
  }
} catch (e) {
  emit(TrackingError(e.toString()));
}
  }
}
