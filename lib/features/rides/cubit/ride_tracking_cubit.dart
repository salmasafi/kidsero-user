import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as dev;
import '../../../core/network/error_handler.dart';
import '../data/rides_repository.dart';
import '../models/api_models.dart';

// ============================================================
// STATES
// ============================================================

abstract class RideTrackingState extends Equatable {
  const RideTrackingState();

  @override
  List<Object?> get props => [];
}

class RideTrackingInitial extends RideTrackingState {}

class RideTrackingLoading extends RideTrackingState {}

class RideTrackingLoaded extends RideTrackingState {
  final RideTrackingData trackingData;

  const RideTrackingLoaded({required this.trackingData});

  @override
  List<Object?> get props => [trackingData];
}

class RideTrackingError extends RideTrackingState {
  final String message;

  const RideTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// CUBIT
// ============================================================

class RideTrackingCubit extends Cubit<RideTrackingState> {
  final RidesRepository _repository;
  final String _childId;
  Timer? _refreshTimer;

  RideTrackingCubit({
    required RidesRepository repository,
    required String childId,
  })  : _repository = repository,
        _childId = childId,
        super(RideTrackingInitial());

  /// Load tracking data for the child's active ride
  Future<void> loadTracking() async {
    emit(RideTrackingLoading());
    try {
      dev.log('Loading tracking data for child: $_childId', name: 'RideTrackingCubit');
      
      final trackingData = await _repository.getRideTracking(_childId);
      
      if (trackingData != null) {
        dev.log('Loaded tracking data for child $_childId', name: 'RideTrackingCubit');
        emit(RideTrackingLoaded(trackingData: trackingData));
      } else {
        dev.log('No active ride tracking for child $_childId', name: 'RideTrackingCubit');
        emit(const RideTrackingError('No active ride found'));
      }
    } catch (e, stackTrace) {
      dev.log('Error loading tracking data', 
              name: 'RideTrackingCubit', 
              error: e, 
              stackTrace: stackTrace);
      final errorMessage = ErrorHandler.handle(e);
      emit(RideTrackingError(errorMessage));
    }
  }

  /// Start auto-refresh timer to update tracking data every 10 seconds
  void startAutoRefresh() {
    // Cancel any existing timer
    stopAutoRefresh();
    
    dev.log('Starting auto-refresh for child $_childId', name: 'RideTrackingCubit');
    
    // Create a periodic timer that refreshes every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      // Only refresh if we're in a loaded state
      if (state is RideTrackingLoaded) {
        try {
          dev.log('Auto-refreshing tracking data for child $_childId', 
                  name: 'RideTrackingCubit');
          
          final trackingData = await _repository.getRideTracking(_childId);
          
          if (trackingData != null) {
            emit(RideTrackingLoaded(trackingData: trackingData));
          } else {
            // Ride has ended or is no longer active
            dev.log('Ride no longer active for child $_childId', 
                    name: 'RideTrackingCubit');
            stopAutoRefresh();
            emit(const RideTrackingError('Ride is no longer active'));
          }
        } catch (e) {
          dev.log('Error during auto-refresh', 
                  name: 'RideTrackingCubit', 
                  error: e);
          // Don't emit error state during auto-refresh, keep current state
        }
      }
    });
  }

  /// Stop auto-refresh timer
  void stopAutoRefresh() {
    if (_refreshTimer != null) {
      dev.log('Stopping auto-refresh for child $_childId', name: 'RideTrackingCubit');
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
