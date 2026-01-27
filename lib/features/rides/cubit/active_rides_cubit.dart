import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_service.dart';
import '../models/ride_models.dart';

// States
abstract class ActiveRidesState extends Equatable {
  @override
  List<Object> get props => [];
}

class ActiveRidesInitial extends ActiveRidesState {}

class ActiveRidesLoading extends ActiveRidesState {}

class ActiveRidesLoaded extends ActiveRidesState {
  final List<ActiveRide> rides;
  ActiveRidesLoaded(this.rides);
}

class ActiveRidesEmpty extends ActiveRidesState {}

class ActiveRidesError extends ActiveRidesState {
  final String message;
  ActiveRidesError(this.message);
}

// Cubit
class ActiveRidesCubit extends Cubit<ActiveRidesState> {
  final ApiService apiService;
  ActiveRidesCubit(this.apiService) : super(ActiveRidesInitial());

  Future<void> loadActiveRides() async {
    emit(ActiveRidesLoading());
    try {
      final response = await apiService.getActiveRides();
      if (response.activeRides.isEmpty) {
        emit(ActiveRidesEmpty());
      } else {
        emit(ActiveRidesLoaded(response.activeRides));
      }
    } catch (e) {
      emit(ActiveRidesError(e.toString()));
    }
  }
}
