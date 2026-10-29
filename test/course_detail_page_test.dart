import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/providers/course_provider.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:course_explorer/screens/course_detail_page.dart';
import 'package:course_explorer/services/course_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _CourseApiService extends CourseApiService {
  _CourseApiService(this.courses) : super('');

  final List<Course> courses;

  @override
  Future<List<Course>> getCourses() async => courses;
}

class _DeletableCourseApiService extends CourseApiService {
  _DeletableCourseApiService(this.courses) : super('');

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
      CourseRepository(_CourseApiService([updated])),
    );
    await provider.loadCourses();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: CourseDetailPage(course: original)),
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
    final service = _DeletableCourseApiService([course]);
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
                    builder: (_) => const CourseDetailPage(course: course),
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
}
