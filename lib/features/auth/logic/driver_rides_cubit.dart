import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kidsero_driver/features/auth/data/models/driver_rides_today_model.dart';
import 'package:kidsero_driver/features/auth/data/models/start_ride_model.dart';
import 'package:kidsero_driver/features/auth/data/repositories/driver_rides_repository.dart';

// Events
abstract class DriverRidesEvent extends Equatable {
  const DriverRidesEvent();

  @override
  List<Object> get props => [];
}

class GetRidesTodayEvent extends DriverRidesEvent {
  const GetRidesTodayEvent();

  @override
  List<Object> get props => [];
}

class StartRideEvent extends DriverRidesEvent {
  final String occurrenceId;
  final String lat;
  final String lng;

  const StartRideEvent({
    required this.occurrenceId,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object> get props => [occurrenceId, lat, lng];
}

// States
abstract class DriverRidesState extends Equatable {
  const DriverRidesState();

  @override
  List<Object> get props => [];
}

class DriverRidesInitial extends DriverRidesState {
  const DriverRidesInitial();
}

class DriverRidesLoading extends DriverRidesState {
  const DriverRidesLoading();
}

class DriverRidesLoaded extends DriverRidesState {
  final DriverRidesTodayData ridesData;

  const DriverRidesLoaded(this.ridesData);

  @override
  List<Object> get props => [ridesData];
}

class DriverRidesError extends DriverRidesState {
  final String message;

  const DriverRidesError(this.message);

  @override
  List<Object> get props => [message];
}

class StartRideLoading extends DriverRidesState {
  const StartRideLoading();
}

class StartRideSuccess extends DriverRidesState {
  final StartRideData startRideData;

  const StartRideSuccess(this.startRideData);

  @override
  List<Object> get props => [startRideData];
}

class StartRideFailed extends DriverRidesState {
  final String message;

  const StartRideFailed(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class DriverRidesCubit extends Cubit<DriverRidesState> {
  final DriverRidesRepository _repository;

  DriverRidesCubit(this._repository) : super(const DriverRidesInitial());

  Future<void> getRidesToday() async {
    emit(const DriverRidesLoading());
    try {
      final response = await _repository.getRidesToday();
      emit(DriverRidesLoaded(response.data));
    } catch (e) {
      emit(DriverRidesError(e.toString()));
    }
  }

  Future<void> startRide({
    required String occurrenceId,
    required String lat,
    required String lng,
  }) async {
    emit(const StartRideLoading());
    try {
      final response = await _repository.startRide(
        occurrenceId: occurrenceId,
        lat: lat,
        lng: lng,
      );
      emit(StartRideSuccess(response.data));
    } catch (e) {
      emit(StartRideFailed(e.toString()));
    }
  }
}
