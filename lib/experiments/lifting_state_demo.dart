import 'package:flutter/material.dart';

import '../models/course.dart';
import '../widgets/course_card.dart';
import '../course_data.dart';
import '../widgets/identity_banner.dart';
import 'value_notifier_demo.dart';

class LiftingStateDemoPage extends StatefulWidget {
  const LiftingStateDemoPage({super.key});

  @override
  State<LiftingStateDemoPage> createState() => _LiftingStateDemoPageState();
}

class _LiftingStateDemoPageState extends State<LiftingStateDemoPage> {
  bool _isFavorite = false;

  void _setFavorite(bool value) {
    setState(() => _isFavorite = value);
  }

  void _toggleFavorite() {
    _setFavorite(!_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final course = Course.fromJson(courses.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 3 - Lifting State Up'),
        actions: [
          IconButton(
            tooltip: 'Demo ValueNotifier',
            icon: const Icon(Icons.speed),
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ValueNotifierDemoPage(),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const IdentityBanner(),
          const SizedBox(height: 16),
          Text(
            'Parent menyimpan satu nilai favorite (Single Source of Truth). '
            'Kartu dan switch menerima nilai itu melalui constructor, lalu '
            'mengirim aksi kembali lewat callback.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          CourseCard(
            course: course,
            isFavorite: _isFavorite,
            onFavoriteTap: _toggleFavorite,
          ),
          const SizedBox(height: 12),
          _FavoriteSwitch(isFavorite: _isFavorite, onChanged: _setFavorite),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _isFavorite
                    ? '${course.title} ditandai sebagai favorite.'
                    : '${course.title} belum ditandai sebagai favorite.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tekan ikon hati pada kartu atau ubah switch. Keduanya harus '
            'selalu menunjukkan nilai yang sama karena tidak menyimpan '
            'salinan state sendiri.',
          ),
        ],
      ),
    );
  }
}

class _FavoriteSwitch extends StatelessWidget {
  final bool isFavorite;
  final ValueChanged<bool> onChanged;

  const _FavoriteSwitch({required this.isFavorite, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: const Text('Favorite course'),
        subtitle: Text(isFavorite ? 'Aktif' : 'Tidak aktif'),
        value: isFavorite,
        onChanged: onChanged,
      ),
    );
  }
}
