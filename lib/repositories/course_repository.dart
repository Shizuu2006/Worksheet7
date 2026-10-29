import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;
  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.getCourses();
  }
}
