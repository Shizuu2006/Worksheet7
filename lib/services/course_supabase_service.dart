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
      final row = await supabase
          .from('courses')
          .insert(course.toJson())
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
      await supabase.from('courses').update(course.toJson()).eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Gagal memperbarui data: ${e.message}');
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    try {
      await supabase.from('courses').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw Exception('Gagal menghapus data: ${e.message}');
    }
  }
}
