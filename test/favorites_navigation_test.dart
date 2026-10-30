import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/providers/course_provider.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:course_explorer/responsive_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_course_data_source.dart';

void main() {
  testWidgets('Favorites tab opens on the mobile navigation bar', (
    tester,
  ) async {
    final provider = await _createProviderWithFavorite();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: ResponsiveShell()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('IF101'), findsOneWidget);

    await provider.loadCourses();
    await tester.pumpAndSettle();
    expect(find.text('Pemrograman Mobile'), findsOneWidget);

    await tester.tap(find.text('Courses'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus favorit').first, findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Pemrograman Mobile'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus dari favorit'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada course favorit.'), findsOneWidget);
  });

  testWidgets('Favorites destination opens on the wide navigation rail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = await _createProviderWithFavorite();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: ResponsiveShell()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Mobile'), findsOneWidget);
    expect(find.text('IF101'), findsOneWidget);
  });

  testWidgets('Navigation rail scrolls when vertical space is limited', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = await _createProviderWithFavorite();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: ResponsiveShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<CourseProvider> _createProviderWithFavorite() async {
  final provider = CourseProvider(
    CourseRepository(
      FakeCourseDataSource(
        courses: const [
          Course(
            code: 'IF101',
            title: 'Pemrograman Mobile',
            credits: 3,
            status: 'Wajib',
          ),
        ],
      ),
    ),
  );
  await provider.loadCourses();
  provider.toggleFavorite('IF101');
  return provider;
}
