import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_course_data_source.dart';

class _FakeCourseDataSource extends TestCourseDataSource {
  _FakeCourseDataSource(this.courses);

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
    final repository = CourseRepository(_FakeCourseDataSource(expected));

    final courses = await repository.getCourses();

    expect(courses, expected);
  });
}
