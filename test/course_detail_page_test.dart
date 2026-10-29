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
}
