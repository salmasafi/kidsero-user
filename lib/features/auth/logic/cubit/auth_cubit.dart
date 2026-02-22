import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_helper.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';
import 'package:kidsero_parent/core/utils/app_preferences.dart';
import 'package:kidsero_parent/core/utils/l10n_utils.dart';
import 'package:kidsero_parent/core/network/error_handler.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ApiHelper _apiHelper;
  final ApiService? _apiService;

  AuthCubit(
    this._authRepository, {
    ApiHelper? apiHelper,
    ApiService? apiService,
  })  : _apiHelper = apiHelper ?? ApiHelper(),
        _apiService = apiService,
        super(AuthInitial());

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
        
        // Update tokens in both ApiHelper and ApiService
        await _apiHelper.setToken(response.token!);
        if (_apiService != null) {
          await _apiService!.setToken(response.token!);
        }
        
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
    if (_apiService != null) {
      await _apiService!.clearToken();
    }
    
    // Also use AuthService for consistent logout handling
    await AuthService().handleForceLogout(reason: 'Manual logout');
    
    emit(AuthInitial());
  }

  /// Handle forced logout from API errors (401/403)
  Future<void> handleForceLogout({String? reason}) async {
    await AuthService().handleForceLogout(reason: reason);
    emit(AuthInitial());
  }
}
