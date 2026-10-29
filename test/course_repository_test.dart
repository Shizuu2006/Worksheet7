import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:course_explorer/services/course_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCourseApiService extends CourseApiService {
  _FakeCourseApiService(this.courses) : super('');

  final List<Course> courses;

  @override
  Future<List<Course>> getCourses() async => courses;
}

void main() {
  test('getCourses delegates to the injected data source', () async {
    const expected = [
      Course(
        code: 'IF101',
        title: 'Pemrograman Mobile',
        credits: 3,
        status: 'Wajib',
      ),
    ];
    final repository = CourseRepository(_FakeCourseApiService(expected));

    final courses = await repository.getCourses();

    expect(courses, expected);
  });
}
