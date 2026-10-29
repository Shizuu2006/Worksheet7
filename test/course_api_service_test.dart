import 'dart:convert';

import 'package:course_explorer/services/course_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('getCourses parses API responses into Course models', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://example.com/courses');
      return http.Response(
        jsonEncode([
          {
            'id': 42,
            'code': 'MOB01',
            'title': 'Git & GitHub',
            'credits': 2,
            'status': 'done',
            'created_at': 'ignored',
          },
        ]),
        200,
      );
    });
    final courses = await CourseApiService(
      'https://example.com',
      client: client,
    ).getCourses();

    expect(courses, hasLength(1));
    expect(courses.single.code, 'MOB01');
    expect(courses.single.id, 42);
    expect(courses.single.status, 'done');
  });

  test('getCourses reports non-200 responses', () async {
    final client = MockClient((_) async => http.Response('not found', 404));

    await expectLater(
      CourseApiService('https://example.com', client: client).getCourses(),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('HTTP 404'),
        ),
      ),
    );
  });
}
