import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/features/plans/model/plans_model.dart'; // Import your api helper
// import your PlanModel

// --- STATES ---
abstract class PlansState {}
class PlansInitial extends PlansState {}
class PlansLoading extends PlansState {}
class PlansLoaded extends PlansState {
  final List<PlanModel> plans;
  PlansLoaded(this.plans);
}
class PlansError extends PlansState {
  final String message;
  PlansError(this.message);
}

// --- CUBIT ---
class PlansCubit extends Cubit<PlansState> {
  final ApiService apiService;

  PlansCubit(this.apiService) : super(PlansInitial());

  Future<void> fetchPlans() async {
    emit(PlansLoading());
    try {
      final plans = await apiService.getPlans();
      emit(PlansLoaded(plans));
    } catch (e) {
      emit(PlansError(e.toString()));
    }
  }
}
