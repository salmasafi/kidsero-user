import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/network/api_service.dart';
import '../models/ride_models.dart';

part 'ride_state.dart';

class RideCubit extends Cubit<RideState> {
  final ApiService apiService;

  RideCubit({required this.apiService}) : super(RideInitial());

  /// Fetches the children and their rides from /api/users/rides/children
  Future<void> loadChildrenRides() async {
    emit(RideLoading());
    try {
      // Ensure your ApiService returns ChildrenRidesResponse
      final response = await apiService.getChildrenRides();

      if (response.data.children.isEmpty) {
        emit(RideEmpty());
      } else {
        emit(ChildrenRidesLoaded(response.data.children.cast<Child>()));
      }
    } catch (e) {
      emit(RideError(e.toString()));
    }
  }
}
