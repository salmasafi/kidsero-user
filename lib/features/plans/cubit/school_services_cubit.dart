import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kidsero_driver/core/network/api_service.dart';
import 'package:kidsero_driver/features/children/model/child_model.dart';
import 'package:kidsero_driver/features/plans/model/org_service_model.dart';
import 'package:kidsero_driver/features/plans/model/student_subscription_model.dart';

// State
abstract class SchoolServicesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SchoolServicesInitial extends SchoolServicesState {}

class SchoolServicesLoading extends SchoolServicesState {}

class SchoolServicesLoaded extends SchoolServicesState {
  final List<Child> children;
  final Child? selectedChild;
  final List<StudentServiceSubscription> activeSubscriptions;
  final List<OrgService> availableServices;

  SchoolServicesLoaded({
    required this.children,
    this.selectedChild,
    required this.activeSubscriptions,
    required this.availableServices,
  });

  SchoolServicesLoaded copyWith({
    List<Child>? children,
    Child? selectedChild,
    List<StudentServiceSubscription>? activeSubscriptions,
    List<OrgService>? availableServices,
  }) {
    return SchoolServicesLoaded(
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      availableServices: availableServices ?? this.availableServices,
    );
  }

  @override
  List<Object?> get props => [
    children,
    selectedChild,
    activeSubscriptions,
    availableServices,
  ];
}

class SchoolServicesError extends SchoolServicesState {
  final String message;

  SchoolServicesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SchoolServicesCubit extends Cubit<SchoolServicesState> {
  final ApiService _apiService;

  SchoolServicesCubit(this._apiService) : super(SchoolServicesInitial());

  Future<void> loadChildren() async {
    emit(SchoolServicesLoading());
    try {
      final children = await _apiService.getChildren();
      if (children.isEmpty) {
        emit(
          SchoolServicesLoaded(
            children: [],
            activeSubscriptions: [],
            availableServices: [],
          ),
        );
        return;
      }

      // Automatically select the first child and load their services
      final selectedChild = children.first;
      await loadServicesForChild(children, selectedChild);
    } catch (e) {
      emit(SchoolServicesError(e.toString()));
    }
  }

  Future<void> selectChild(Child child) async {
    final currentState = state;
    if (currentState is SchoolServicesLoaded) {
      if (currentState.selectedChild?.id == child.id) return;
      emit(SchoolServicesLoading()); // Show loading while switching
      await loadServicesForChild(currentState.children, child);
    }
  }

  Future<void> loadServicesForChild(List<Child> children, Child child) async {
    try {
      final results = await Future.wait([
        _apiService.getStudentSubscriptions(child.id),
        _apiService.getOrgServices(child.id),
      ]);

      final subscriptionResponse = results[0] as StudentServiceResponse;
      final servicesResponse = results[1] as OrgServiceResponse;

      if (subscriptionResponse.success && servicesResponse.success) {
        emit(
          SchoolServicesLoaded(
            children: children,
            selectedChild: child,
            activeSubscriptions: subscriptionResponse.subscriptions,
            availableServices: servicesResponse.services,
          ),
        );
      } else {
        emit(
          SchoolServicesError(
            subscriptionResponse.success
                ? servicesResponse.message
                : subscriptionResponse.message,
          ),
        );
      }
    } catch (e) {
      emit(SchoolServicesError(e.toString()));
    }
  }
}
