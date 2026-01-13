import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';
import '../../../../core/network/api_helper.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ApiHelper _apiHelper;

  AuthCubit(this._authRepository, this._apiHelper) : super(AuthInitial());

  Future<void> parentLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.parentLogin(phone, password);
      if (response.success && response.token != null) {
        await CacheHelper.saveData(key: 'token', value: response.token!);
        _apiHelper.setToken(response.token!);
        emit(AuthSuccess(response));
      } else {
        emit(AuthError(response.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> driverLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.driverLogin(phone, password);
      if (response.success && response.token != null) {
        await CacheHelper.saveData(key: 'token', value: response.token!);
        _apiHelper.setToken(response.token!);
        emit(AuthSuccess(response));
      } else {
        emit(AuthError(response.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await CacheHelper.removeData(key: 'token');
    _apiHelper.clearToken();
    emit(AuthInitial());
  }
}
