import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'widgets/identity_banner.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'responsive_shell.dart';
import 'services/course_api_service.dart';

void main() => runApp(const CourseExplorerApp());

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key, this.repository});

  final CourseRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseProvider(
        repository:
            repository ??
            CourseRepository(
              CourseApiService('https://course-api-pearl.vercel.app'),
            ),
      )..loadCourses(),
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
