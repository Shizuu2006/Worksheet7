import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api_test.dart';
import 'app_theme.dart';
import 'widgets/identity_banner.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'responsive_shell.dart';
import 'services/course_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await testFetchCourses();
  runApp(const CourseExplorerApp());
}

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CourseProvider(repository: CourseRepository(CourseService()))
            ..loadCourses(),
      child: MaterialApp(
        title: 'Course Explorer',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const ResponsiveShell(),
        routes: {'/stage0': (_) => const Stage0()},
      ),
    );
  }
}

/// Tahap 0 - Review Environment screen (tetap dipertahankan untuk worksheet)
class Stage0 extends StatelessWidget {
  const Stage0({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 0 - Environment')),
      body: const Column(
        children: [
          IdentityBanner(),
          Expanded(
            child: Center(
              child: Text(
                'Project siap dijalankan.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
