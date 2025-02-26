import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> updateProfilePhoto(String photoUrl);
  Future<void> updatePreferences(Map<String, dynamic> preferences);
}
