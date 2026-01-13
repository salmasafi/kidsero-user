import 'package:equatable/equatable.dart';
import '../../../../core/models/auth_response_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponseModel authResponse;

  const AuthSuccess(this.authResponse);

  @override
  List<Object?> get props => [authResponse];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
