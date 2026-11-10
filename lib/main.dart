import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'app_theme.dart';
import 'app_keys.dart';
import 'pages/auth_gate.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';
import 'widgets/identity_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);

  final CourseDataSource dataSource = CourseSupabaseService();
  final repository = CourseRepository(dataSource);
  runApp(CourseExplorerApp(repository: repository));
}

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key, required this.repository, this.home});

  final CourseRepository repository;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseProvider(repository),
      child: MaterialApp(
        title: 'Course Explorer',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: messengerKey,
        home: home ?? const AuthGate(),
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
