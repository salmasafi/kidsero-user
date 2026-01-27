import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_helper.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:kidsero_driver/core/utils/app_preferences.dart';
import 'package:kidsero_driver/core/utils/l10n_utils.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ApiHelper _apiHelper = ApiHelper();

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> parentLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(phone, password);
      if (response.success && response.token != null) {
        // Save parent token and user data
        await AppPreferences.setToken(response.token!);
        if (response.user != null) {
          await AppPreferences.setUserData(
            userId: response.user!.id,
            userName: response.user!.name,
            userPhone: response.user!.phone,
            userAvatar: response.user!.avatar,
          );
        }
        await _apiHelper.setToken(response.token!);
        emit(AuthSuccess(response));
      } else {
        emit(
          AuthError(
            response.message ??
                L10nUtils.translateWithGlobalContext('loginFailed'),
          ),
        );
      }
    } catch (e) {
      emit(AuthError(ErrorHandler.handle(e)));
    }
  }

  Future<void> logout() async {
    await AppPreferences.clearTokens();
    await AppPreferences.clearUserData();
    await _apiHelper.clearToken();
    emit(AuthInitial());
  }
}
