import 'package:course_explorer/identity.dart';
import 'package:course_explorer/main.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_course_data_source.dart';

void main() {
  testWidgets(
    'courses load through the app layers and favorites stay in sync across screens',
    (tester) async {
      await tester.pumpWidget(
        CourseExplorerApp(repository: CourseRepository(FakeCourseDataSource())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pemrograman Mobile'), findsOneWidget);

      await tester.tap(find.text('Courses'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Tambah favorit').first);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Favorit'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(studentId), findsOneWidget);
      expect(find.text('Pemrograman Mobile'), findsOneWidget);

      await tester.tap(find.text('Pemrograman Mobile'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);
      await tester.tap(find.byTooltip('Hapus dari favorit'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Belum ada course favorit.'), findsOneWidget);

      await tester.tap(find.text('Courses'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Tambah favorit').first, findsOneWidget);
    },
  );
}
