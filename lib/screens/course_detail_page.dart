import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import 'course_form_page.dart';

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus course?'),
        content: Text('${course.code} - ${course.title} akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await context.read<CourseProvider>().deleteCourse(course);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error ?? 'Course dihapus')));
    if (error == null && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  IconData _getCourseIcon(String code) {
    switch (code) {
      case 'IF101':
        return Icons.phone_android_rounded;
      case 'IF102':
        return Icons.storage_rounded;
      case 'IF103':
        return Icons.palette_rounded;
      case 'IF104':
        return Icons.hub_rounded;
      case 'IF105':
        return Icons.psychology_rounded;
      case 'IF106':
        return Icons.security_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _getCourseColor(String code) {
    switch (code) {
      case 'IF101':
        return const Color(0xFF3B82F6);
      case 'IF102':
        return const Color(0xFF0D9488);
      case 'IF103':
        return const Color(0xFFF59E0B);
      case 'IF104':
        return const Color(0xFF8B5CF6);
      case 'IF105':
        return const Color(0xFFEC4899);
      case 'IF106':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final provider = context.watch<CourseProvider>();
    final current = provider.courses.firstWhere(
      (item) => item.code == course.code,
      orElse: () => course,
    );
    final code = current.code;
    final title = current.title;
    final credits = current.credits;
    final status = current.status;
    final description = current.description;
    final accentColor = _getCourseColor(code);
    final isFav = provider.isFavorite(code);

    return Scaffold(
      appBar: AppBar(
        title: Text(code),
        actions: [
          IconButton(
            tooltip: 'Edit course',
            icon: const Icon(Icons.edit),
            onPressed: current.id == null
                ? null
                : () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CourseFormPage(course: current),
                    ),
                  ),
          ),
          IconButton(
            tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? Colors.red : null,
            ),
            onPressed: () {
              provider.toggleFavorite(code);
            },
          ),
          IconButton(
            tooltip: 'Hapus course',
            icon: const Icon(Icons.delete_outline),
            onPressed: current.id == null || provider.isSaving
                ? null
                : () => _confirmDelete(context, current),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Hero Banner
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCourseIcon(code),
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$credits Satuan Kredit Semester (SKS)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deskripsi
                  Text(
                    'Deskripsi Mata Kuliah',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Detail Informasi Spesifikasi
                  Text(
                    'Informasi Akademik',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          Icons.tag_rounded,
                          'Kode Kurikulum',
                          code,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildInfoTile(
                          Icons.timer_outlined,
                          'Beban SKS',
                          '$credits SKS',
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildInfoTile(
                          Icons.verified_outlined,
                          'Sifat Mata Kuliah',
                          '$status Jurusan',
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildInfoTile(
                          Icons.calendar_today_rounded,
                          'Semester Pelaksanaan',
                          'Ganjil / Genap',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Identity Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.primary, width: 1.5),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              studentPhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => CircleAvatar(
                                backgroundColor: cs.primary,
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'NIM: $studentId • $studentClass',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          icon: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            isFav
                                ? 'Tersimpan di Favorit'
                                : 'Pilih sebagai Favorite',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: isFav ? Colors.red.shade600 : null,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Kembali'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
