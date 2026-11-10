import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    try {
      final data = await supabase.from('courses').select().order('id');
      return (data as List)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Gagal membaca database: ${e.message}');
    }
  }

  @override
  Future<Course> createCourse(Course course) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw StateError('Login diperlukan untuk menambah course');
      }
      final row = await supabase
          .from('courses')
          .insert({...course.toJson(), 'owner_id': user.id})
          .select()
          .single();
      return Course.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Kode course sudah dipakai');
      }
      throw Exception('Gagal menambah data: ${e.message}');
    }
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    try {
      final rows = await supabase
          .from('courses')
          .update(course.toJson())
          .eq('id', id)
          .select('id');
      if (rows.isEmpty) {
        throw StateError('Perubahan ditolak oleh policy RLS atau data tidak ada');
      }
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui data: ${e.message}');
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    try {
      final rows = await supabase
          .from('courses')
          .delete()
          .eq('id', id)
          .select('id');
      if (rows.isEmpty) {
        throw StateError('Penghapusan ditolak oleh policy RLS atau data tidak ada');
      }
    } on PostgrestException catch (e) {
      throw Exception('Gagal menghapus data: ${e.message}');
    }
  }
}
