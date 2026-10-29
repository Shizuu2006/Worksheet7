import 'package:course_explorer/models/course.dart';
import 'package:course_explorer/providers/course_provider.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:course_explorer/responsive_shell.dart';
import 'package:course_explorer/services/course_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Favorites tab opens on the mobile navigation bar', (
    tester,
  ) async {
    final provider = _createProviderWithFavorite();
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

    final provider = _createProviderWithFavorite();
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
}

CourseProvider _createProviderWithFavorite() {
  final provider =
      CourseProvider(repository: CourseRepository(CourseApiService('')))
        ..courses = [
          const Course(
            code: 'IF101',
            title: 'Pemrograman Mobile',
            credits: 3,
            status: 'Wajib',
          ),
        ];
  provider.toggleFavorite('IF101');
  return provider;
}
