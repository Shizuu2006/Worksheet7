import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormPage extends StatefulWidget {
  const CourseFormPage({super.key, this.course});

  final Course? course;

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _title;
  late final TextEditingController _credits;
  late String _status;

  bool get _isEdit => widget.course != null;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _code = TextEditingController(text: course?.code ?? '');
    _title = TextEditingController(text: course?.title ?? '');
    _credits = TextEditingController(text: course?.credits.toString() ?? '');
    _status = course?.status ?? 'planned';
  }

  @override
  void dispose() {
    _code.dispose();
    _title.dispose();
    _credits.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur edit belum tersedia')),
      );
      return;
    }

    final course = Course(
      code: _code.text.trim(),
      title: _title.text.trim(),
      credits: int.parse(_credits.text.trim()),
      status: _status,
    );
    final error = await context.read<CourseProvider>().createCourse(course);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error ?? 'Course ditambahkan')));
    if (error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CourseProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Course' : 'Tambah Course')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _code,
              readOnly: _isEdit,
              decoration: const InputDecoration(labelText: 'Code'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Code wajib diisi'
                  : null,
            ),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Title wajib diisi'
                  : null,
            ),
            TextFormField(
              controller: _credits,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Credits'),
              validator: (value) => int.tryParse(value?.trim() ?? '') == null
                  ? 'Credits harus angka'
                  : null,
            ),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const ['planned', 'active', 'done']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _status = value ?? 'planned'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : _submit,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
