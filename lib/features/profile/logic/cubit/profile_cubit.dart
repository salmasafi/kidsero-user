import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';
import 'package:kidsero_driver/core/utils/l10n_utils.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';
import 'package:kidsero_driver/core/network/parent_api_helper.dart';
import 'package:kidsero_driver/core/network/driver_api_helper.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(
    ParentApiHelper parentApiHelper,
    DriverApiHelper driverApiHelper,
  ) : _profileRepository = ProfileRepository(parentApiHelper, driverApiHelper),
       super(ProfileInitial());

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

  Future<void> updateProfile({required String name, String? imagePath}) async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.updateProfile(name: name, imagePath: imagePath);
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

  Future<void> getChildren() async {
    emit(ChildrenLoading());
    try {
      final response = await _profileRepository.getChildren();
      if (response.success) {
        emit(ChildrenLoaded(response.data.children));
      } else {
        emit(ChildrenError(L10nUtils.translateWithGlobalContext('failedToLoadChildren')));
      }
    } catch (e) {
      emit(ChildrenError(ErrorHandler.handle(e)));
    }
  }
}
