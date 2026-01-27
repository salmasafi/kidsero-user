part of 'ride_cubit.dart';

abstract class RideState extends Equatable {
  const RideState();

  @override
  List<Object> get props => [];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideEmpty extends RideState {}

class RideError extends RideState {
  final String message;
  const RideError(this.message);

  @override
  List<Object> get props => [message];
}

class ChildrenRidesLoaded extends RideState {
  final List<Child> children;
  const ChildrenRidesLoaded(this.children);

  @override
  List<Object> get props => [children];
}


// part of 'ride_cubit.dart';

// abstract class RideState extends Equatable {
//   const RideState();
//   @override
//   List<Object> get props => [];
// }

// class RideInitial extends RideState {}
// class RideLoading extends RideState {}
// class RideEmpty extends RideState {}
// class RideError extends RideState {
//   final String message;
//   const RideError(this.message);
//   @override
//   List<Object> get props => [message];
// }

// // Replaces ChildrenRidesLoaded
// class RideDashboardLoaded extends RideState {
//   final RideDashboardData data;
//   const RideDashboardLoaded(this.data);
//   @override
//   List<Object> get props => [data];
// }