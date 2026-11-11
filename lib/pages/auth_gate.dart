import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../responsive_shell.dart';
import '../services/profile_service.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Session? _session;
  late final StreamSubscription<AuthState> _authSubscription;
  final ProfileService _profileService = ProfileService();
  UserProfile? _profile;
  Object? _profileError;
  bool _isLoadingProfile = false;
  int _profileRequestId = 0;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (state) => _handleSessionChange(state.session),
    );
    if (_session != null) unawaited(_loadProfile(_session!));
  }

  void _handleSessionChange(Session? session) {
    if (!mounted) return;
    _profileRequestId++;
    setState(() {
      _session = session;
      _profile = null;
      _profileError = null;
      _isLoadingProfile = session != null;
    });
    if (session != null) unawaited(_loadProfile(session));
  }

  Future<void> _loadProfile(Session session) async {
    final requestId = ++_profileRequestId;
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await _profileService.getProfile(session.user.id);
      if (!mounted || requestId != _profileRequestId) return;
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    } on Exception catch (error) {
      if (!mounted || requestId != _profileRequestId) return;
      setState(() {
        _profileError = error;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout gagal: ${error.message}')),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout gagal: $error')));
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) return const LoginPage();
    if (_isLoadingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profileError != null || _profile == null) {
      return _ProfileLoadFailure(
        error: _profileError,
        onRetry: () => unawaited(_loadProfile(_session!)),
        onLogout: _logout,
      );
    }
    return ResponsiveShell(profile: _profile);
  }
}

class _ProfileLoadFailure extends StatelessWidget {
  const _ProfileLoadFailure({
    required this.error,
    required this.onRetry,
    required this.onLogout,
  });

  final Object? error;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final message = error == null
        ? 'Profil pengguna belum ditemukan. Pastikan skrip Worksheet 9 sudah dijalankan di Supabase.'
        : 'Gagal memuat profil: $error';

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_outlined, size: 48),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: onRetry,
                      child: const Text('Coba lagi'),
                    ),
                    TextButton(
                      onPressed: onLogout,
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
