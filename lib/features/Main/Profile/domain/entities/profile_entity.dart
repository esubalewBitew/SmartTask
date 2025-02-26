class ProfileEntity {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String role;
  final Map<String, dynamic> preferences;
  final DateTime joinDate;
  final List<String> teams;

  ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.role,
    required this.preferences,
    required this.joinDate,
    required this.teams,
  });
}
