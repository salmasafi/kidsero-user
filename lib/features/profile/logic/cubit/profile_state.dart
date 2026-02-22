import 'package:equatable/equatable.dart';
import 'package:kidsero_parent/features/auth/data/models/user_model.dart';
import '../../data/models/children_response_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordChangeSuccess extends ProfileState {
  final String message;

  const PasswordChangeSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChildrenLoading extends ProfileState {}

class ChildrenLoaded extends ProfileState {
  final List<ChildModel> children;

  const ChildrenLoaded(this.children);

  @override
  List<Object?> get props => [children];
}

class ChildrenError extends ProfileState {
  final String message;

  const ChildrenError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddChildLoading extends ProfileState {}

class AddChildSuccess extends ProfileState {
  final String message;

  const AddChildSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AddChildError extends ProfileState {
  final String message;

  const AddChildError(this.message);

  @override
  List<Object?> get props => [message];
}
