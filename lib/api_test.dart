import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Base URL tanpa "/courses"
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
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
