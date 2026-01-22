import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/parent_api_helper.dart';
import '../../data/repositories/parent_auth_repository.dart';

import 'auth_state.dart';
import 'package:kidsero_driver/core/utils/app_preferences.dart';
import 'package:kidsero_driver/core/utils/l10n_utils.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';

class AuthCubit extends Cubit<AuthState> {
  final ParentAuthRepository _parentAuthRepository;
  final ParentApiHelper _parentApiHelper = ParentApiHelper();

  AuthCubit(this._parentAuthRepository) : super(AuthInitial());

  Future<void> parentLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _parentAuthRepository.parentLogin(phone, password);
      if (response.success && response.token != null) {
        // Save parent token and user data
        await AppPreferences.setParentToken(response.token!);
        if (response.user != null) {
          await AppPreferences.setUserData(
            userId: response.user!.id,
            userName: response.user!.name,
            userPhone: response.user!.phone,
            userAvatar: response.user!.avatar,
          );
        }
        await _parentApiHelper.setToken(response.token!);
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
    await _parentApiHelper.clearToken();
    emit(AuthInitial());
  }
}
