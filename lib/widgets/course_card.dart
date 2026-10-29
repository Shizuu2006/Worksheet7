import 'package:flutter/material.dart';

import '../models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onLongPress,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

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
        return const Color(0xFF3B82F6); // Blue
      case 'IF102':
        return const Color(0xFF0D9488); // Teal
      case 'IF103':
        return const Color(0xFFF59E0B); // Amber
      case 'IF104':
        return const Color(0xFF8B5CF6); // Purple
      case 'IF105':
        return const Color(0xFFEC4899); // Pink
      case 'IF106':
        return const Color(0xFF06B6D4); // Cyan
      default:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = course.code;
    final title = course.title;
    final credits = course.credits;
    final status = course.status;
    final description = course.description;
    final accentColor = _getCourseColor(code);
    final isWajib = status.toLowerCase() == 'wajib';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFavorite
              ? Colors.red.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: isFavorite ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFavorite
                ? Colors.red.withValues(alpha: 0.08)
                : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon + Code + Badges + Favorite
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.85),
                            accentColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getCourseIcon(code),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isWajib
                                      ? const Color(0xFFEEF2FF)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    color: isWajib
                                        ? const Color(0xFF4338CA)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$credits SKS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onFavoriteTap != null)
                      IconButton(
                        tooltip: isFavorite
                            ? 'Hapus favorit'
                            : 'Tambah favorit',
                        onPressed: onFavoriteTap,
                        style: IconButton.styleFrom(
                          backgroundColor: isFavorite
                              ? Colors.red.withValues(alpha: 0.1)
                              : const Color(0xFFF8FAFC),
                        ),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? Colors.red
                              : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.25,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
