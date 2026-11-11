import 'package:course_explorer/pages/login_page.dart';
import 'package:course_explorer/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('register shows required email, password and confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Konfirmasi password'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    expect(find.text('Konfirmasi password wajib diisi'), findsOneWidget);
  });

  testWidgets('register rejects a confirmation that does not match', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.enterText(fields.at(2), 'different123');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi password tidak sama'), findsOneWidget);
  });

  testWidgets('register offers seeker and owner roles only', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Seeker - melihat course'), findsWidgets);
    expect(find.text('Owner - mengelola course'), findsOneWidget);
    expect(find.text('Admin'), findsNothing);
  });

  testWidgets('login validates email and password before authentication', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });
}
