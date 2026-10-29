import 'package:course_explorer/providers/course_provider.dart';
import 'package:course_explorer/repositories/course_repository.dart';
import 'package:course_explorer/services/course_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('a context above the provider cannot read CourseProvider', (
    tester,
  ) async {
    final provider = CourseProvider(CourseRepository(CourseApiService('')));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final count = context.watch<CourseProvider>().favorites.length;
            return ChangeNotifierProvider.value(
              value: provider,
              child: Text('$count'),
            );
          },
        ),
      ),
    );

    expect(tester.takeException(), isA<ProviderNotFoundException>());
  });

  testWidgets('a descendant context can read CourseProvider', (tester) async {
    final provider = CourseProvider(CourseRepository(CourseApiService('')));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final count = context.watch<CourseProvider>().favorites.length;
              return Text('$count');
            },
          ),
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('watch rebuilds the UI after favorite state changes', (
    tester,
  ) async {
    final provider = CourseProvider(CourseRepository(CourseApiService('')));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Column(
              children: [
                Text(
                  'Favorites: ${context.watch<CourseProvider>().favorites.length}',
                ),
                ElevatedButton(
                  onPressed: () =>
                      context.read<CourseProvider>().toggleFavorite('IF101'),
                  child: const Text('Toggle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Toggle'));
    await tester.pump();

    expect(find.text('Favorites: 1'), findsOneWidget);
  });
}
