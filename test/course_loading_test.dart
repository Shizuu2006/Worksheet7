import 'dart:async';

import 'package:course_explorer/screens/courses_page.dart';
import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/providers/course_provider.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_course_data_source.dart';

class _CompleterCourseDataSource extends TestCourseDataSource {
  _CompleterCourseDataSource(this.result);

  final Future<List<Course>> result;

  @override
  Future<List<Course>> getCourses() => result;
}

class _FailingCourseDataSource extends TestCourseDataSource {
  @override
  Future<List<Course>> getCourses() async {
    throw Exception('Asset tidak dapat dibaca');
  }
}

class _CreatingCourseDataSource extends TestCourseDataSource {
  int getCalls = 0;
  int? updatedId;
  int? deletedId;
  Object? deleteError;

  @override
  Future<List<Course>> getCourses() async {
    getCalls++;
    return getCalls == 1
        ? const [Course(code: 'OLD01', title: 'Old Course', credits: 2)]
        : const [
            Course(code: 'NEW01', title: 'New Course', credits: 3),
            Course(code: 'NEW02', title: 'Another Course', credits: 2),
          ];
  }

  @override
  Future<Course> createCourse(Course course) async => course;

  @override
  Future<void> updateCourse(int id, Course course) async {
    updatedId = id;
  }

  @override
  Future<void> deleteCourse(int id) async {
    if (deleteError != null) throw deleteError!;
    deletedId = id;
  }
}

void main() {
  testWidgets('CoursesPage shows loading then the loaded course list', (
    tester,
  ) async {
    final result = Completer<List<Course>>();
    final provider = CourseProvider(
      CourseRepository(_CompleterCourseDataSource(result.future)),
    );
    final loading = provider.loadCourses();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: CoursesPage())),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    result.complete(const [
      Course(
        code: 'IF101',
        title: 'Pemrograman Mobile',
        credits: 3,
        status: 'Wajib',
        description: 'Belajar Flutter.',
      ),
    ]);
    await loading;
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('CoursesPage shows an error and retry action on failure', (
    tester,
  ) async {
    final provider = CourseProvider(
      CourseRepository(_FailingCourseDataSource()),
    );
    await provider.loadCourses();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: CoursesPage())),
      ),
    );

    expect(find.textContaining('Asset tidak dapat dibaca'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('CoursesPage shows an explicit empty state', (tester) async {
    final provider = CourseProvider(
      CourseRepository(_CompleterCourseDataSource(Future.value([]))),
    );
    await provider.loadCourses();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: CoursesPage())),
      ),
    );

    expect(find.text('Data course belum tersedia'), findsOneWidget);
  });

  test('createCourse refreshes the course list after creation', () async {
    final service = _CreatingCourseDataSource();
    final provider = CourseProvider(CourseRepository(service));

    await provider.loadCourses();
    expect(provider.courses.single.code, 'OLD01');

    final error = await provider.createCourse(
      const Course(code: 'NEW01', title: 'New Course', credits: 3),
    );

    expect(error, isNull);
    expect(service.getCalls, 2);
    expect(provider.courses.map((course) => course.code), ['NEW01', 'NEW02']);
    expect(provider.isSaving, isFalse);
  });

  test('updateCourse sends the id and refreshes the course list', () async {
    final service = _CreatingCourseDataSource();
    final provider = CourseProvider(CourseRepository(service));

    await provider.loadCourses();
    final error = await provider.updateCourse(
      const Course(
        id: 42,
        code: 'OLD01',
        title: 'Updated Course',
        credits: 4,
        status: 'active',
      ),
    );

    expect(error, isNull);
    expect(service.updatedId, 42);
    expect(service.getCalls, 2);
    expect(provider.courses.map((course) => course.code), ['NEW01', 'NEW02']);
    expect(provider.isSaving, isFalse);
  });

  test('updateCourse rejects a course without an id', () async {
    final provider = CourseProvider(
      CourseRepository(_CreatingCourseDataSource()),
    );

    final error = await provider.updateCourse(
      const Course(code: 'OLD01', title: 'Missing ID', credits: 2),
    );

    expect(error, 'Course tidak memiliki id');
    expect(provider.isSaving, isFalse);
  });

  test('deleteCourse removes favorite and refreshes the course list', () async {
    final service = _CreatingCourseDataSource();
    final provider = CourseProvider(CourseRepository(service));
    const course = Course(
      id: 42,
      code: 'OLD01',
      title: 'Old Course',
      credits: 2,
    );

    await provider.loadCourses();
    provider.toggleFavorite(course.code);

    final error = await provider.deleteCourse(course);

    expect(error, isNull);
    expect(service.deletedId, 42);
    expect(service.getCalls, 2);
    expect(provider.courses.map((item) => item.code), ['NEW01', 'NEW02']);
    expect(provider.isFavorite(course.code), isFalse);
  });

  test(
    'deleteCourse leaves favorite unchanged when API deletion fails',
    () async {
      final service = _CreatingCourseDataSource()
        ..deleteError = Exception('Gagal menghapus course (HTTP 409)');
      final provider = CourseProvider(CourseRepository(service));
      const course = Course(
        id: 42,
        code: 'OLD01',
        title: 'Old Course',
        credits: 2,
      );

      provider.toggleFavorite(course.code);
      final error = await provider.deleteCourse(course);

      expect(error, 'Gagal menghapus course (HTTP 409)');
      expect(provider.isFavorite(course.code), isTrue);
      expect(service.getCalls, 0);
    },
  );
}
