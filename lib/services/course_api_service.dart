import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

class CourseApiService {
  CourseApiService(this.baseUrl, {this.client});

  final String baseUrl;
  final http.Client? client;

  Future<List<Course>> getCourses() async {
    final uri = Uri.parse('$baseUrl/courses');
    final response = await (client?.get(uri) ?? http.get(uri));
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course (HTTP ${response.statusCode})');
    }

    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Course> createCourse(Course course) async {
    final uri = Uri.parse('$baseUrl/courses');
    final response =
        await (client?.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(course.toJson()),
            ) ??
            http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(course.toJson()),
            ));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(_messageFrom(response, 'Gagal membuat course'));
  }

  Future<void> updateCourse(int id, Course course) async {
    final uri = Uri.parse('$baseUrl/courses/$id');
    final response =
        await (client?.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(course.toJson()),
            ) ??
            http.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(course.toJson()),
            ));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_messageFrom(response, 'Gagal memperbarui course'));
    }
  }

  String _messageFrom(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return '${body['error'] ?? fallback} (HTTP ${response.statusCode})';
    } on FormatException {
      return '$fallback (HTTP ${response.statusCode})';
    } on TypeError {
      return '$fallback (HTTP ${response.statusCode})';
    }
  }
}
