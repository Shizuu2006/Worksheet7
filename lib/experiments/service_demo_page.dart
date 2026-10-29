import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/course_api_service.dart';
import '../widgets/identity_banner.dart';

class ServiceDemoPage extends StatefulWidget {
  const ServiceDemoPage({super.key});

  @override
  State<ServiceDemoPage> createState() => _ServiceDemoPageState();
}

class _ServiceDemoPageState extends State<ServiceDemoPage> {
  final CourseApiService _service = CourseApiService(
    'https://course-api-pearl.vercel.app',
  );
  List<Course>? _courses;
  bool _loading = false;
  String? _message;

  Future<void> _testService() async {
    setState(() {
      _loading = true;
      _message = 'Memuat data dari API...';
    });

    try {
      final list = await _service.getCourses();
      if (!mounted) return;
      debugPrint('=== [Tahap 9] UJI SERVICE VIA DEBUGPRINT ===');
      debugPrint('Berhasil memuat ${list.length} courses:');
      for (final c in list) {
        debugPrint(
          '- [${c.code}] ${c.title} (${c.credits} SKS) - status: ${c.status}',
        );
      }
      debugPrint('============================================');

      setState(() {
        _courses = list;
        _loading = false;
        _message = 'Berhasil memuat ${list.length} courses dari Service!';
      });
    } catch (e) {
      debugPrint('Error saat memuat service: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Gagal memuat data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 9 - Service / Data Source')),
      body: Column(
        children: [
          const IdentityBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Uji CourseApiService (HTTP + JSON)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Klik tombol di bawah untuk memanggil CourseApiService().getCourses(). Data akan dicetak ke debugPrint konsol dan ditampilkan di bawah.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _testService,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(
                        _loading ? 'Memuat...' : 'Jalankan Uji Service',
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _courses != null
                              ? Colors.green.shade800
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_courses != null)
            Expanded(
              child: ListView.builder(
                itemCount: _courses!.length,
                itemBuilder: (context, index) {
                  final course = _courses![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${course.credits}')),
                      title: Text(course.title),
                      subtitle: Text('${course.code} • ${course.credits} SKS'),
                      trailing: Chip(
                        label: Text(
                          course.status,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
