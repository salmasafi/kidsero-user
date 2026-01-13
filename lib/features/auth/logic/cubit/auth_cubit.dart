import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:kidsero_driver/core/network/api_helper.dart';
import 'package:kidsero_driver/core/network/cache_helper.dart';
import 'package:kidsero_driver/core/utils/app_strings.dart';
import 'package:kidsero_driver/core/utils/l10n_utils.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ApiHelper _apiHelper;

  AuthCubit(this._authRepository, this._apiHelper) : super(AuthInitial());

  Future<void> parentLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.parentLogin(phone, password);
      if (response.success && response.token != null) {
        await CacheHelper.saveData(key: AppStrings.token, value: response.token!);
        _apiHelper.setToken(response.token!);
        emit(AuthSuccess(response));
      } else {
        emit(AuthError(response.message ?? L10nUtils.translateWithGlobalContext('loginFailed')));
      }
    } catch (e) {
      emit(AuthError(ErrorHandler.handle(e)));
    }
  }

  Future<void> driverLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.driverLogin(phone, password);
      if (response.success && response.token != null) {
        await CacheHelper.saveData(key: AppStrings.token, value: response.token!);
        _apiHelper.setToken(response.token!);
        emit(AuthSuccess(response));
      } else {
        emit(AuthError(response.message ?? L10nUtils.translateWithGlobalContext('loginFailed')));
      }
    } catch (e) {
      emit(AuthError(ErrorHandler.handle(e)));
    }
  }

  Future<void> logout() async {
    await CacheHelper.removeData(key: AppStrings.token);
    _apiHelper.clearToken();
    emit(AuthInitial());
  }
}
