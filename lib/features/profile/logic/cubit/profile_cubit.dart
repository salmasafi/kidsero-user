import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_helper.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';
import 'package:kidsero_driver/core/utils/l10n_utils.dart';
import 'package:kidsero_driver/core/network/error_handler.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(ApiHelper apiHelper)
    : _profileRepository = ProfileRepository(apiHelper),
      super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.getProfile();
      if (response.success && response.profile != null) {
        emit(ProfileLoaded(response.profile!));
      } else {
        emit(
          ProfileError(
            L10nUtils.translateWithGlobalContext('failedToLoadProfile'),
          ),
        );
      }
    } catch (e) {
      emit(ProfileError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateProfile({required String name, String? imagePath}) async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.updateProfile(
        name: name,
        imagePath: imagePath,
      );
      if (response.success) {
        emit(
          ProfileUpdateSuccess(
            response.message ??
                L10nUtils.translateWithGlobalContext(
                  'profileUpdatedSuccessfully',
                ),
          ),
        );
        // Refresh profile after update
        await getProfile();
      } else {
        emit(
          ProfileError(
            response.message ??
                L10nUtils.translateWithGlobalContext('updateFailed'),
          ),
        );
      }
    } catch (e) {
      emit(ProfileError(ErrorHandler.handle(e)));
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.changePassword(
        oldPassword,
        newPassword,
      );
      if (response.success) {
        emit(
          PasswordChangeSuccess(
            response.message ??
                L10nUtils.translateWithGlobalContext(
                  'passwordChangedSuccessfully',
                ),
          ),
        );
      } else {
        emit(
          ProfileError(
            response.message ??
                L10nUtils.translateWithGlobalContext('passwordChangeFailed'),
          ),
        );
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
        emit(
          ChildrenError(
            L10nUtils.translateWithGlobalContext('failedToLoadChildren'),
          ),
        );
      }
    } catch (e) {
      emit(ChildrenError(ErrorHandler.handle(e)));
    }
  }

  Future<void> addChild(String code) async {
    emit(AddChildLoading());
    try {
      final response = await _profileRepository.addChild(code);
      if (response.success) {
        emit(
          AddChildSuccess(
            response.message ??
                L10nUtils.translateWithGlobalContext('childAddedSuccessfully'),
          ),
        );
        // Refresh children list after adding
        await getChildren();
      } else {
        emit(
          AddChildError(
            response.message ??
                L10nUtils.translateWithGlobalContext('failedToAddChild'),
          ),
        );
      }
    } catch (e) {
      emit(AddChildError(ErrorHandler.handle(e)));
    }
  }
}
