import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/course.dart';

// Base URL tanpa "/courses"
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

Future<List<Course>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }
  throw Exception('HTTP ${response.statusCode}');
}

// Fungsi uji sementara
Future<void> testFetchCourses() async {
  try {
    final data = await fetchCourses();
    debugPrint(
      '[I Kadek Agus Mertha Kusuma - 2415051054] Jumlah course: ${data.length}',
    );
  } catch (e) {
    debugPrint('[I Kadek Agus Mertha Kusuma - 2415051054] Error: $e');
  }
}
