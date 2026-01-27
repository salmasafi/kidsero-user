import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_service.dart';
import '../models/ride_models.dart';

// States
abstract class UpcomingRidesState extends Equatable {
  @override
  List<Object> get props => [];
}

class UpcomingRidesInitial extends UpcomingRidesState {}

class UpcomingRidesLoading extends UpcomingRidesState {}

class UpcomingRidesLoaded extends UpcomingRidesState {
  final List<UpcomingDay> days;
  UpcomingRidesLoaded(this.days);
}

class UpcomingRidesEmpty extends UpcomingRidesState {}

class UpcomingRidesError extends UpcomingRidesState {
  final String message;
  UpcomingRidesError(this.message);
}

// Cubit
class UpcomingRidesCubit extends Cubit<UpcomingRidesState> {
  final ApiService apiService;
  UpcomingRidesCubit(this.apiService) : super(UpcomingRidesInitial());

  Future<void> loadUpcomingRides() async {
    emit(UpcomingRidesLoading());
    try {
      final response = await apiService.getUpcomingRides();
      if (response.upcomingDays.isEmpty) {
        emit(UpcomingRidesEmpty());
      } else {
        emit(UpcomingRidesLoaded(response.upcomingDays));
      }
    } catch (e) {
      emit(UpcomingRidesError(e.toString()));
    }
  }
}
