import 'package:course_explorer/course_data.dart' as course_data;
import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/services/course_api_service.dart';

class FakeCourseApiService extends CourseApiService {
  FakeCourseApiService({List<Course>? courses})
    : courses = courses ?? _sampleCourses,
      super('');

  final List<Course> courses;

  @override
  Future<List<Course>> getCourses() async => courses;
}

final List<Course> _sampleCourses = course_data.courses
    .map(Course.fromJson)
    .toList();
