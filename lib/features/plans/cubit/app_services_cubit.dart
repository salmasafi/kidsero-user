import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/features/plans/model/parent_subscription_model.dart';
import 'package:kidsero_driver/features/plans/model/plans_model.dart';

// State
abstract class AppServicesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppServicesInitial extends AppServicesState {}

class AppServicesLoading extends AppServicesState {}

class AppServicesLoaded extends AppServicesState {
  final List<ParentSubscription> activeSubscriptions;
  final List<PlanModel> availablePlans;

  AppServicesLoaded({
    required this.activeSubscriptions,
    required this.availablePlans,
  });

  @override
  List<Object?> get props => [activeSubscriptions, availablePlans];
}

class AppServicesError extends AppServicesState {
  final String message;

  AppServicesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class AppServicesCubit extends Cubit<AppServicesState> {
  final ApiService _apiService;

  AppServicesCubit(this._apiService) : super(AppServicesInitial());

  Future<void> loadAppServices() async {
    emit(AppServicesLoading());
    try {
      // Fetch data in parallel
      final results = await Future.wait([
        _apiService.getParentSubscriptions(),
        _apiService.getPlans(),
      ]);

      final subscriptionResponse = results[0] as ParentSubscriptionResponse;
      final plans = results[1] as List<PlanModel>;

      if (subscriptionResponse.success) {
        emit(
          AppServicesLoaded(
            activeSubscriptions: subscriptionResponse.subscriptions,
            availablePlans: plans,
          ),
        );
      } else {
        emit(AppServicesError(subscriptionResponse.message));
      }
    } catch (e) {
      emit(AppServicesError(e.toString()));
    }
  }
}
