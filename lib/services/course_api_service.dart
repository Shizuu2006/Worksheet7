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
}
