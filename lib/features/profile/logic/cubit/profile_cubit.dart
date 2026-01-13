import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';
import 'package:kidsero_driver/core/utils/l10n_utils.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.getProfile();
      if (response.success && response.profile != null) {
        emit(ProfileLoaded(response.profile!));
      } else {
        emit(ProfileError(L10nUtils.translateWithGlobalContext('failedToLoadProfile')));
      }
    } catch (e) {
      emit(ProfileError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateProfile(String name, String avatar) async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.updateProfile(name, avatar);
      if (response.success) {
        emit(ProfileUpdateSuccess(response.message ?? L10nUtils.translateWithGlobalContext('profileUpdatedSuccessfully')));
        // Refresh profile after update
        await getProfile();
      } else {
        emit(ProfileError(response.message ?? L10nUtils.translateWithGlobalContext('updateFailed')));
      }
    } catch (e) {
      emit(ProfileError(ErrorHandler.handle(e)));
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.changePassword(oldPassword, newPassword);
      if (response.success) {
        emit(PasswordChangeSuccess(response.message ?? L10nUtils.translateWithGlobalContext('passwordChangedSuccessfully')));
      } else {
        emit(ProfileError(response.message ?? L10nUtils.translateWithGlobalContext('passwordChangeFailed')));
      }
    } catch (e) {
      emit(ProfileError(ErrorHandler.handle(e)));
    }
  }
}
