import 'package:course_explorer/services/course_data_source.dart';
import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/course_data.dart' as course_data;

class TestCourseDataSource implements CourseDataSource {
  @override
  Future<List<Course>> getCourses() async => [];

  @override
  Future<Course> createCourse(Course course) async => course;

  @override
  Future<void> updateCourse(int id, Course course) async {}

  @override
  Future<void> deleteCourse(int id) async {}
}

class FakeCourseDataSource extends TestCourseDataSource {
  FakeCourseDataSource({List<Course>? courses})
    : courses = courses ?? _sampleCourses;

  final List<Course> courses;

  @override
  Future<List<Course>> getCourses() async => courses;
}

final List<Course> _sampleCourses = course_data.courses
    .map(Course.fromJson)
    .toList();
