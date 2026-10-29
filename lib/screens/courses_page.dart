import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../widgets/course_card.dart';
import '../widgets/identity_banner.dart';
import 'course_detail_page.dart';
import '../identity.dart';
import '../providers/course_provider.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua'; // 'Semua', 'Wajib', 'Pilihan', 'Favorit'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _columnsFor(double width) {
    if (width < 640) return 1;
    if (width < 960) return 2;
    return 3;
  }

  double _cardExtentFor(double width) {
    if (width < 640) return 170;
    return 175;
  }

  Future<void> _openDetail(BuildContext context, Course course) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
    );

    if (result == true && context.mounted) {
      final provider = context.read<CourseProvider>();
      final code = course.code;
      if (!provider.isFavorite(code)) {
        provider.toggleFavorite(code);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0xFF1E293B),
          content: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('${course.title} ditambahkan ke favorit!')),
            ],
          ),
        ),
      );
    }
  }

  void _showQuickInfo(BuildContext context, Course course) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(ctx).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${course.credits} SKS • ${course.status}'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course.description,
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$studentId - $studentName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openDetail(context, course);
                    },
                    child: const Text('Buka Detail'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    // Filtering logic
    final filtered = provider.courses.where((course) {
      final code = course.code;
      final title = course.title.toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesSearch = title.contains(q) || code.toLowerCase().contains(q);

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'Wajib':
          return course.status.toLowerCase() == 'wajib';
        case 'Pilihan':
          return course.status.toLowerCase() == 'pilihan';
        case 'Favorit':
          return provider.isFavorite(code);
        default:
          return true;
      }
    }).toList();

    return Column(
      children: [
        const IdentityBanner(compact: true),
        // Search & Filters Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Search Field
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari mata kuliah atau kode...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in [
                      'Semua',
                      'Wajib',
                      'Pilihan',
                      'Favorit',
                    ]) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          avatar: filter == 'Favorit'
                              ? Icon(
                                  Icons.favorite_rounded,
                                  size: 16,
                                  color: _selectedFilter == 'Favorit'
                                      ? Colors.white
                                      : Colors.red,
                                )
                              : null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = filter);
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Courses Grid / Empty State
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat mata kuliah:\n${provider.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              context.read<CourseProvider>().loadCourses(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Colors.indigo.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Mata kuliah tidak ditemukan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coba ubah kata kunci atau filter pencarian Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedFilter = 'Semua';
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reset Pencarian'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columnsFor(constraints.maxWidth),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: _cardExtentFor(constraints.maxWidth),
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final course = filtered[index];
                  final code = course.code;
                  final isFav = provider.isFavorite(code);

                  return CourseCard(
                    course: course,
                    isFavorite: isFav,
                    onTap: () => _openDetail(context, course),
                    onLongPress: () => _showQuickInfo(context, course),
                    onFavoriteTap: () {
                      provider.toggleFavorite(code);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          content: Text(
                            isFav
                                ? '${course.title} dihapus dari favorit'
                                : '${course.title} ditambahkan ke favorit',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
