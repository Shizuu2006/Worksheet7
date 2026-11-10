import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_keys.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  debugPrint('[BACKGROUND] ${message.notification?.title}');
  debugPrint('[BACKGROUND] ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenSubscription;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'FCM Web membutuhkan konfigurasi FirebaseOptions dari FlutterFire.',
      );
    }
    if (_isInitialized) return;

    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus.name}');

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _messageSubscription = FirebaseMessaging.onMessage.listen(_handleMessage);
    // getToken/onTokenRefresh provide the FCM registration token used by Firebase Console.
    // ignore: deprecated_member_use
    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (token) => unawaited(_saveToken(token)),
      onError: (Object error) {
        debugPrint('Gagal menerima pembaruan token FCM: $error');
      },
    );

    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      await _saveToken(token);
    }
    _isInitialized = true;
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _tokenSubscription?.cancel();
    _messageSubscription = null;
    _tokenSubscription = null;
    _isInitialized = false;
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('[FOREGROUND] Notification received');
    debugPrint('title: ${message.notification?.title}');
    debugPrint('body: ${message.notification?.body}');
    debugPrint('data: ${message.data}');

    final title = message.notification?.title ?? 'Notifikasi';
    final body = message.notification?.body ?? '';
    messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('$title\n$body')),
    );
  }

  Future<void> _saveToken(String token) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      debugPrint('Token FCM belum disimpan karena pengguna belum login.');
      return;
    }

    try {
      await client.from('device_tokens').upsert({
        'token': token,
        'user_id': user.id,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on PostgrestException catch (error) {
      debugPrint('Gagal menyimpan token FCM: ${error.message}');
      messengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Token FCM didapat, tetapi tabel device_tokens belum siap. '
            'Jalankan skrip SQL Worksheet 9.',
          ),
        ),
      );
    }
  }
}
