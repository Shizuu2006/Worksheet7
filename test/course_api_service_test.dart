import 'dart:convert';

import 'package:course_explorer/models/course.dart';
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

  test(
    'createCourse posts course data and parses the created course',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://example.com/courses');
        expect(request.headers['Content-Type'], 'application/json');
        expect(jsonDecode(request.body), {
          'code': 'NEW01',
          'title': 'New Course',
          'credits': 3,
          'status': 'planned',
        });
        return http.Response(
          jsonEncode({
            'id': 8,
            'code': 'NEW01',
            'title': 'New Course',
            'credits': 3,
            'status': 'planned',
          }),
          201,
        );
      });

      final course =
          await CourseApiService(
            'https://example.com',
            client: client,
          ).createCourse(
            const Course(code: 'NEW01', title: 'New Course', credits: 3),
          );

      expect(course.id, 8);
      expect(course.code, 'NEW01');
    },
  );

  test('createCourse shows the API message for duplicate codes', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({'error': 'Code already exists', 'status': 409}),
        409,
      ),
    );

    await expectLater(
      CourseApiService('https://example.com', client: client).createCourse(
        const Course(code: 'DUP01', title: 'Duplicate', credits: 2),
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Code already exists (HTTP 409)'),
        ),
      ),
    );
  });

  test('updateCourse sends a PUT request with complete course data', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(request.url.toString(), 'https://example.com/courses/42');
      expect(request.headers['Content-Type'], 'application/json');
      expect(jsonDecode(request.body), {
        'code': 'MOB01',
        'title': 'Updated Course',
        'credits': 4,
        'status': 'active',
      });
      return http.Response('', 204);
    });

    await CourseApiService('https://example.com', client: client).updateCourse(
      42,
      const Course(
        id: 42,
        code: 'MOB01',
        title: 'Updated Course',
        credits: 4,
        status: 'active',
      ),
    );
  });

  test('updateCourse shows the API message on failure', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({'error': 'Course not found', 'status': 404}),
        404,
      ),
    );

    await expectLater(
      CourseApiService('https://example.com', client: client).updateCourse(
        999,
        const Course(code: 'MOB99', title: 'Missing', credits: 2),
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Course not found (HTTP 404)'),
        ),
      ),
    );
  });

  test('deleteCourse sends DELETE and accepts an empty 204 response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'DELETE');
      expect(request.url.toString(), 'https://example.com/courses/42');
      return http.Response('', 204);
    });

    await CourseApiService(
      'https://example.com',
      client: client,
    ).deleteCourse(42);
  });

  test('deleteCourse shows the API message on failure', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({'error': 'Course cannot be deleted', 'status': 409}),
        409,
      ),
    );

    await expectLater(
      CourseApiService('https://example.com', client: client).deleteCourse(42),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Course cannot be deleted (HTTP 409)'),
        ),
      ),
    );
  });
}
