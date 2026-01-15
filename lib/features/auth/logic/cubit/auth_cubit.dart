import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidsero_driver/core/network/driver_api_helper.dart';
import 'package:kidsero_driver/core/network/parent_api_helper.dart';
import '../../data/repositories/parent_auth_repository.dart';
import '../../data/repositories/driver_auth_repository.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/driver_login_response_model.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';
import 'package:kidsero_driver/core/utils/app_preferences.dart';
import 'package:kidsero_driver/core/utils/l10n_utils.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';

class AuthCubit extends Cubit<AuthState> {
  final ParentAuthRepository _parentAuthRepository;
  final DriverAuthRepository _driverAuthRepository;
  final ParentApiHelper _parentApiHelper = ParentApiHelper();
  final DriverApiHelper _driverApiHelper = DriverApiHelper();

  AuthCubit(
    this._parentAuthRepository,
    this._driverAuthRepository,
  ) : super(AuthInitial());

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

  Future<void> driverLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await _driverAuthRepository.driverLogin(phone, password);
      if (response.success) {
        // Save driver token and user data
        await AppPreferences.setDriverToken(response.data.token);
        await AppPreferences.setUserData(
          userId: response.data.user.id,
          userName: response.data.user.name,
          userPhone: response.data.user.phone,
          userAvatar: response.data.user.avatar,
        );
        await _driverApiHelper.setToken(response.data.token);
        emit(AuthSuccess(AuthResponseModel(
          success: response.success,
          message: response.data.message,
          token: response.data.token,
          user: UserModel(
            id: response.data.user.id,
            name: response.data.user.name,
            phone: response.data.user.phone,
            avatar: response.data.user.avatar,
            role: response.data.user.role,
          ),
        )));
      } else {
        emit(
          AuthError(
            response.data.message ??
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
    await _driverApiHelper.clearToken();
    emit(AuthInitial());
  }
}
