import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_keys.dart';
import 'models/user_profile.dart';
import 'screens/courses_page.dart';
import 'screens/course_form_page.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'providers/course_provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key, this.profile});

  final UserProfile? profile;

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _index = 0;
  bool _notificationsStarted = false;

  void _select(int i) => setState(() => _index = i);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CourseProvider>().loadCourses();
      if (widget.profile != null) _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    if (_notificationsStarted) return;
    _notificationsStarted = true;
    try {
      await NotificationService.instance.initialize();
    } on FirebaseException catch (error) {
      debugPrint('FCM belum siap: ${error.message}');
      _showNotificationSetupMessage();
    } on PlatformException catch (error) {
      debugPrint('FCM belum siap: ${error.message}');
      _showNotificationSetupMessage();
    } on MissingPluginException catch (error) {
      debugPrint('FCM tidak tersedia pada platform ini: ${error.message}');
      _showNotificationSetupMessage();
    } on UnsupportedError catch (error) {
      debugPrint('FCM belum siap: $error');
      _showNotificationSetupMessage();
    }
  }

  void _showNotificationSetupMessage() {
    if (!mounted) return;
    messengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('FCM perlu dikonfigurasi untuk project Firebase ini.'),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthService.instance.logout();
      await NotificationService.instance.dispose();
    } on AuthException catch (error) {
      if (!mounted) return;
      messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Logout gagal: ${error.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final favCount = context.watch<CourseProvider>().favorites.length;

    final List<Widget> pages = [
      HomePage(onNavigateToCourses: () => _select(1)),
      CoursesPage(profile: widget.profile),
      FavoritesPage(profile: widget.profile),
      ProfilePage(profile: widget.profile),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final expanded = c.maxWidth >= 840;
        final content = IndexedStack(index: _index, children: pages);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Explorer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      expanded
                          ? 'Expanded Mode (Rail)'
                          : 'Adaptive Mobile Mode',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: _logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: expanded
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      onDestinationSelected: _select,
                      scrollable: true,
                      labelType: NavigationRailLabelType.all,
                      backgroundColor: Colors.white,
                      indicatorColor: cs.primaryContainer,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: cs.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.explore_rounded,
                            color: cs.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      destinations: [
                        const NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: const Icon(Icons.school_outlined),
                          selectedIcon: const Icon(Icons.school_rounded),
                          label: const Text('Courses'),
                        ),
                        NavigationRailDestination(
                          icon: Badge(
                            isLabelVisible: favCount > 0,
                            label: Text('$favCount'),
                            child: const Icon(Icons.favorite_border_rounded),
                          ),
                          selectedIcon: Badge(
                            isLabelVisible: favCount > 0,
                            label: Text('$favCount'),
                            child: const Icon(Icons.favorite_rounded),
                          ),
                          label: const Text('Favorit'),
                        ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.person_outline_rounded),
                          selectedIcon: Icon(Icons.person_rounded),
                          label: Text('Profile'),
                        ),
                      ],
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                    Expanded(child: content),
                  ],
                )
              : content,
          floatingActionButton:
              _index == 1 && widget.profile?.canManageCourses == true
              ? FloatingActionButton(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CourseFormPage(profile: widget.profile!),
                    ),
                  ),
                  child: const Icon(Icons.add),
                )
              : null,
          bottomNavigationBar: expanded
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  elevation: 2,
                  backgroundColor: Colors.white,
                  indicatorColor: cs.primaryContainer,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.school_outlined),
                      selectedIcon: const Icon(Icons.school_rounded),
                      label: 'Courses',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: favCount > 0,
                        label: Text('$favCount'),
                        child: const Icon(Icons.favorite_border_rounded),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: favCount > 0,
                        label: Text('$favCount'),
                        child: const Icon(Icons.favorite_rounded),
                      ),
                      label: 'Favorit',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
