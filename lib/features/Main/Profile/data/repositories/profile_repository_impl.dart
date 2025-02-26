import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    await remoteDataSource.updateProfile(profile);
  }

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {
    await remoteDataSource.updateProfilePhoto(photoUrl);
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await remoteDataSource.updatePreferences(preferences);
  }
}
