import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class ProfileService {
  ProfileService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<UserProfile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select('id, email, name, role')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromMap(data);
  }
}
