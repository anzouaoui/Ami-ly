import 'dart:io';

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_service.dart';

/// Gère l'enregistrement du token FCM, les messages foreground/background,
/// et la navigation au tap sur une notification push.
class PushNotificationService {
  PushNotificationService({
    required FirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  final FirebaseService _firebaseService;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Callback appelé quand l'utilisateur tape sur une notification push.
  /// Le parent (shell) fournit cette closure pour naviguer.
  static void Function(Map<String, dynamic> data)? onNotificationTap;

  // ── Initialisation ──────────────────────────────────────────────────────────

  /// Appeler après FirebaseService.initialize() et l'authentification.
  Future<void> initialize(String uid) async {
    await _initLocalNotifications();
    await _requestPermission();
    await _registerToken(uid);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _listenForeground();
    _listenBackground();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && onNotificationTap != null) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            onNotificationTap!(data);
          } catch (e) {
            debugPrint('[PushNotif] Error decoding payload: $e');
          }
        }
      },
    );
  }

  /// Demande de permission (iOS principalement, Android l'accorde par défaut).
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[PushNotif] Permission: ${settings.authorizationStatus}');
  }

  /// Enregistre le token FCM dans le document utilisateur.
  Future<void> _registerToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToFirestore(uid, token);
    }

    // Renouvellement automatique du token.
    _messaging.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(uid, newToken);
    });
  }

  Future<void> _saveTokenToFirestore(String uid, String token) async {
    await _firebaseService.firestore.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'platform': Platform.operatingSystem,
    });
  }

  /// Supprime le token quand l'utilisateur se déconnecte.
  Future<void> removeToken(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _firebaseService.firestore.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
  }

  // ── Écoute des messages ─────────────────────────────────────────────────────

  /// Messages reçus quand l'app est au premier plan.
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[PushNotif] Foreground: ${message.messageId}');
      _showLocalNotification(message);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'amily_high_importance_channel', // id
      'Ami-ly Notifications', // title
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  /// Messages reçus quand l'app est en arrière-plan et est ouverte via le tap.
  void _listenBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[PushNotif] Background tap: ${message.messageId}');
      _handleMessageTap(message);
    });
  }

  /// Gère la navigation quand l'utilisateur tape sur une notification push.
  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;
    if (onNotificationTap != null && data.isNotEmpty) {
      onNotificationTap!(data);
    }
  }

  // ── Utilitaires ─────────────────────────────────────────────────────────────

  /// Récupère le token actuel (utile pour le debug).
  Future<String?> getToken() => _messaging.getToken();
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return PushNotificationService(
    firebaseService: firebaseService,
  );
});
