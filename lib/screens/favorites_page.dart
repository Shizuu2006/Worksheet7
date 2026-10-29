import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/identity_banner.dart';
import 'course_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final favoriteCourses = provider.courses
        .where((course) => provider.isFavorite(course.code))
        .toList();

    return Column(
      children: [
        const IdentityBanner(),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Gagal memuat mata kuliah: ${provider.error}'),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: provider.loadCourses,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                )
              : favoriteCourses.isEmpty
              ? const Center(child: Text('Belum ada course favorit.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteCourses.length,
                  itemBuilder: (context, index) {
                    final course = favoriteCourses[index];

                    return Card(
                      child: ListTile(
                        title: Text(course.title),
                        subtitle: Text(course.code),
                        trailing: IconButton(
                          tooltip: 'Hapus dari favorit',
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => provider.toggleFavorite(course.code),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CourseDetailPage(course: course),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
