import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/courses_page.dart';
import 'screens/course_form_page.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'providers/course_provider.dart';

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final favCount = context.watch<CourseProvider>().favorites.length;

    final List<Widget> pages = [
      HomePage(onNavigateToCourses: () => _select(1)),
      const CoursesPage(),
      const FavoritesPage(),
      const ProfilePage(),
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
          floatingActionButton: _index == 1
              ? FloatingActionButton(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const CourseFormPage(),
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
