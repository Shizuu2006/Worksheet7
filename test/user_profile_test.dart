import 'package:course_explorer/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile roles expose the expected course permissions', () {
    final seeker = UserProfile.fromMap({
      'id': 'user-1',
      'email': 'seeker@example.com',
      'name': 'Seeker',
      'role': 'seeker',
    });
    final owner = UserProfile.fromMap({
      'id': 'user-2',
      'email': 'owner@example.com',
      'name': 'Owner',
      'role': 'owner',
    });
    final admin = UserProfile.fromMap({
      'id': 'user-3',
      'email': 'admin@example.com',
      'name': 'Admin',
      'role': 'admin',
    });

    expect(seeker.canManageCourses, isFalse);
    expect(owner.canManageCourses, isTrue);
    expect(admin.canManageCourses, isTrue);
  });

  test('profile rejects an unknown role', () {
    expect(
      () => UserProfile.fromMap({
        'id': 'user-1',
        'email': 'user@example.com',
        'name': '',
        'role': 'unknown',
      }),
      throwsFormatException,
    );
  });
}
