import 'dart:async';

import 'package:course_explorer/screens/courses_page.dart';
import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/providers/course_provider.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:course_explorer/services/course_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _CompleterCourseApiService extends CourseApiService {
  _CompleterCourseApiService(this.result) : super('');

  final Future<List<Course>> result;

  @override
  Future<List<Course>> getCourses() => result;
}

class _FailingCourseApiService extends CourseApiService {
  _FailingCourseApiService() : super('');

  @override
  Future<List<Course>> getCourses() async {
    throw Exception('Asset tidak dapat dibaca');
  }
}

class _CreatingCourseApiService extends CourseApiService {
  _CreatingCourseApiService() : super('');

  int getCalls = 0;

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
}

void main() {
  testWidgets('CoursesPage shows loading then the loaded course list', (
    tester,
  ) async {
    final result = Completer<List<Course>>();
    final provider = CourseProvider(
      CourseRepository(_CompleterCourseApiService(result.future)),
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
      CourseRepository(_FailingCourseApiService()),
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
      CourseRepository(_CompleterCourseApiService(Future.value([]))),
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
    final service = _CreatingCourseApiService();
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
}
