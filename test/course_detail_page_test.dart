import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/models/user_profile.dart';
import 'package:course_explorer/providers/course_provider.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:course_explorer/screens/course_detail_page.dart';
import 'package:course_explorer/screens/course_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_course_data_source.dart';

class _CourseDataSource extends TestCourseDataSource {
  _CourseDataSource(this.courses);

  final List<Course> courses;

  @override
  Future<List<Course>> getCourses() async => courses;
}

class _DeletableCourseDataSource extends TestCourseDataSource {
  _DeletableCourseDataSource(this.courses);
  final List<Course> courses;

  @override
  Future<List<Course>> getCourses() async => List.of(courses);

  @override
  Future<void> deleteCourse(int id) async {
    courses.removeWhere((course) => course.id == id);
  }
}

void main() {
  testWidgets('detail shows current provider data and opens edit form', (
    tester,
  ) async {
    const original = Course(
      id: 42,
      code: 'MOB01',
      title: 'Original Course',
      credits: 2,
    );
    const updated = Course(
      id: 42,
      code: 'MOB01',
      title: 'Updated Course',
      credits: 4,
      status: 'active',
    );
    final provider = CourseProvider(
      CourseRepository(_CourseDataSource([updated])),
    );
    await provider.loadCourses();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: CourseDetailPage(
            course: original,
            profile: UserProfile(
              id: 'admin-id',
              email: 'admin@example.com',
              name: 'Admin',
              role: 'admin',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Updated Course'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit course'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Course'), findsOneWidget);
    expect(find.text('Updated Course'), findsOneWidget);
  });

  testWidgets('delete requires confirmation and removes course and favorite', (
    tester,
  ) async {
    const course = Course(
      id: 42,
      code: 'MOB01',
      title: 'Course to delete',
      credits: 2,
    );
    final service = _DeletableCourseDataSource([course]);
    final provider = CourseProvider(CourseRepository(service));
    await provider.loadCourses();
    provider.toggleFavorite(course.code);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: const Text('Course list'),
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const CourseDetailPage(
                      course: course,
                      profile: UserProfile(
                        id: 'admin-id',
                        email: 'admin@example.com',
                        name: 'Admin',
                        role: 'admin',
                      ),
                    ),
                  ),
                ),
                child: const Icon(Icons.open_in_new),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.open_in_new));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus course'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus course?'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(provider.courses, hasLength(1));
    expect(provider.isFavorite(course.code), isTrue);

    await tester.tap(find.byTooltip('Hapus course'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(provider.courses, isEmpty);
    expect(provider.isFavorite(course.code), isFalse);
    expect(find.text('Course list'), findsOneWidget);
    expect(find.text('Course dihapus'), findsOneWidget);
  });

  testWidgets('seeker cannot see course management actions', (tester) async {
    const course = Course(
      id: 7,
      code: 'MOB07',
      title: 'Private Course',
      credits: 2,
      ownerId: 'owner-id',
    );
    final provider = CourseProvider(
      CourseRepository(_CourseDataSource([course])),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: CourseDetailPage(
            course: course,
            profile: UserProfile(
              id: 'seeker-id',
              email: 'seeker@example.com',
              name: 'Seeker',
              role: 'seeker',
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Edit course'), findsNothing);
    expect(find.byTooltip('Hapus course'), findsNothing);
    expect(find.byTooltip('Tambah ke favorit'), findsOneWidget);
  });

  testWidgets('owner can manage only their own course', (tester) async {
    const ownCourse = Course(
      id: 8,
      code: 'MOB08',
      title: 'Owner Course',
      credits: 2,
      ownerId: 'owner-id',
    );
    final provider = CourseProvider(
      CourseRepository(_CourseDataSource([ownCourse])),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: CourseDetailPage(
            course: ownCourse,
            profile: UserProfile(
              id: 'owner-id',
              email: 'owner@example.com',
              name: 'Owner',
              role: 'owner',
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Edit course'), findsOneWidget);
    expect(find.byTooltip('Hapus course'), findsOneWidget);
  });

  testWidgets('owner cannot open a management form for another owner course', (
    tester,
  ) async {
    const foreignCourse = Course(
      id: 9,
      code: 'MOB09',
      title: 'Another Owner Course',
      credits: 2,
      ownerId: 'different-owner-id',
    );
    final provider = CourseProvider(
      CourseRepository(_CourseDataSource([foreignCourse])),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: CourseFormPage(
            course: foreignCourse,
            profile: UserProfile(
              id: 'owner-id',
              email: 'owner@example.com',
              name: 'Owner',
              role: 'owner',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Akses Ditolak'), findsOneWidget);
    expect(
      find.text('Anda tidak berhak mengelola course ini.'),
      findsOneWidget,
    );
    expect(find.text('Simpan'), findsNothing);
  });
}
