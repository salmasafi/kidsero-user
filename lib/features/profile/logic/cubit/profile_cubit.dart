import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

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
        emit(ProfileError('Failed to load profile'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile(String name, String avatar) async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.updateProfile(name, avatar);
      if (response.success) {
        emit(ProfileUpdateSuccess(response.message ?? 'Profile updated successfully'));
        // Refresh profile after update
        await getProfile();
      } else {
        emit(ProfileError(response.message ?? 'Update failed'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(ProfileLoading());
    try {
      final response = await _profileRepository.changePassword(oldPassword, newPassword);
      if (response.success) {
        emit(PasswordChangeSuccess(response.message ?? 'Password changed successfully'));
      } else {
        emit(ProfileError(response.message ?? 'Password change failed'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
