class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final String id;
  final String email;
  final String name;
  final String role;

  bool get isSeeker => role == 'seeker';
  bool get isOwner => role == 'owner';
  bool get isAdmin => role == 'admin';
  bool get canManageCourses => isOwner || isAdmin;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final role = map['role'] as String? ?? 'seeker';
    if (!const {'seeker', 'owner', 'admin'}.contains(role)) {
      throw FormatException('Role pengguna tidak dikenal: $role');
    }

    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: role,
    );
  }
}
