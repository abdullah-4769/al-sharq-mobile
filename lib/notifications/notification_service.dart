import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../utils/shared_preference.dart';
import 'notification_controller.dart';
import 'notification_database.dart';
import 'notification_screen.dart';

class NotificationService {
  static final NotificationDatabase _db = NotificationDatabase();
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final NotificationController _controller = Get.find<NotificationController>();

  // Notification channels
  static const String highImportanceChannelId = 'high_importance_channel';
  static const String highImportanceChannelName = 'High Importance Notifications';
  static const String highImportanceChannelDescription = 'Important notifications like event updates';

  static const String defaultChannelId = 'default_channel';
  static const String defaultChannelName = 'Notifications';
  static const String defaultChannelDescription = 'General notifications';

  // Notification types
  static const String TYPE_EVENT_CREATED = 'event_created';
  static const String TYPE_EVENT_UPDATED = 'event_updated';
  static const String TYPE_EVENT_DELETED = 'event_deleted';
  static const String TYPE_SPONSOR_ADDED = 'sponsor_added';
  static const String TYPE_EXHIBITOR_ADDED = 'exhibitor_added';
  static const String TYPE_SYSTEM = 'system';
  static const String TYPE_PERSONAL = 'personal';
  static const String TYPE_ANNOUNCEMENT = 'announcement';

  static Future<void> initialize() async {
    print('🔔 [NotificationService] Initializing...');

    try {
      // Initialize local notifications
      await _initLocalNotifications();

      // Request FCM permissions
      await _requestPermissions();

      // Get and save FCM token
      await _controller.getFCMToken();

      // Set up message handlers
      await _setupMessageHandlers();

      // Load stored notifications
      await _loadStoredNotifications();

      print('✅ NotificationService initialization complete');
    } catch (e) {
      print('❌ Error during NotificationService initialization: $e');
    }
  }

  static Future<void> _initLocalNotifications() async {
    try {
      // Android notification channels
      const AndroidNotificationChannel highImportanceChannel = AndroidNotificationChannel(
        highImportanceChannelId,
        highImportanceChannelName,
        description: highImportanceChannelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
        defaultChannelId,
        defaultChannelName,
        description: defaultChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Initialize settings
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // CORRECTED iOS Settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        // 'onDidReceiveLocalNotification' was removed in newer versions
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('🎯 Notification tapped: ${details.payload}');
          _handleNotificationTap(details.payload);
        },
      );

      // Create notification channels (Android 8.0+)
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(highImportanceChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(defaultChannel);

      print('✅ Local notifications initialized');
    } catch (e) {
      print('❌ Error initializing local notifications: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      // Use FirebaseMessaging.instance directly (static access)
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('📱 Notification permission status: ${settings.authorizationStatus}');

      // For iOS, set foreground presentation options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
    }
  }

  static Future<void> _setupMessageHandlers() async {
    try {
      // Foreground message handler - use static access
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📥 Foreground message received: ${message.messageId}');
        _handleIncomingMessage(message, fromBackground: false);
      });

      // When app is opened from terminated state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('🔓 App opened from terminated state');
        _handleIncomingMessage(message, fromBackground: true);
        _handleNotificationTap(json.encode(message.data));
      });

      // Get initial message if app was opened from notification
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print('🚀 Initial message found (app opened from notification)');
        _handleIncomingMessage(initialMessage, fromBackground: true);
        _handleNotificationTap(json.encode(initialMessage.data));
      }

      print('✅ Message handlers setup complete');
    } catch (e) {
      print('❌ Error setting up message handlers: $e');
    }
  }

  static Future<void> _loadStoredNotifications() async {
    try {
      final notifications = await _db.getAllNotifications();
      _controller.notifications.clear();

      // Convert stored notifications to RemoteMessage format
      for (var notification in notifications) {
        try {
          final data = json.decode(notification['data'] as String);
          final remoteMessage = RemoteMessage(
            data: data,
            notification: RemoteNotification(
              title: notification['title'] as String?,
              body: notification['body'] as String?,
            ),
          );
          _controller.notifications.add(remoteMessage);
        } catch (e) {
          print('❌ Error parsing stored notification: $e');
        }
      }

      print('✅ Loaded ${notifications.length} stored notifications');
    } catch (e) {
      print('❌ Error loading stored notifications: $e');
    }
  }

  // Background handler (called from main.dart)
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('📥 [Background] Processing message: ${message.messageId}');

    // Initialize Firebase in background (already done in main.dart)

    // Handle the message
    await _handleIncomingMessage(message, fromBackground: true);

    // Show notification even in background
    await _showLocalNotification(message);
  }

  static Future<void> _handleIncomingMessage(
      RemoteMessage message,
      {required bool fromBackground}
      ) async {
    try {
      print('📨 Handling incoming message: ${message.notification?.title}');

      // Extract data
      final data = message.data;
      final title = message.notification?.title ?? 'Al Sharq Conference';
      final body = message.notification?.body ?? 'New notification';
      final type = data['type'] ?? TYPE_SYSTEM;

      // Save to local database
      await _db.saveNotification(
        title: title,
        body: body,
        data: data,
        notificationType: type,
        eventId: data['event_id'] != null ? int.tryParse(data['event_id']) : null,
        eventName: data['event_name'],
        senderId: data['sender_id'] != null ? int.tryParse(data['sender_id']) : null,
        senderRole: data['sender_role'],
      );

      // Add to controller
      _controller.addNotification(message);

      // Show local notification if app is in foreground
      if (!fromBackground) {
        await _showLocalNotification(message);
      }

      print('✅ Message processed successfully');

    } catch (e) {
      print('❌ Error handling incoming message: $e');
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;
      final type = data['type'] ?? TYPE_SYSTEM;

      if (notification != null) {
        // Determine channel based on type
        String channelId = defaultChannelId;
        Importance importance = Importance.high;

        if (type == TYPE_EVENT_CREATED ||
            type == TYPE_EVENT_UPDATED ||
            type == TYPE_EVENT_DELETED) {
          channelId = highImportanceChannelId;
          importance = Importance.max;
        }

        // FIXED: Use LongList instead of Int64List for vibration pattern
        final vibrationPattern = <int>[0, 500, 200, 500];

        await _flutterLocalNotificationsPlugin.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          notification.title ?? 'Al Sharq Conference',
          notification.body ?? '',
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelId == highImportanceChannelId
                  ? highImportanceChannelName
                  : defaultChannelName,
              channelDescription: channelId == highImportanceChannelId
                  ? highImportanceChannelDescription
                  : defaultChannelDescription,
              importance: importance,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
             // vibrationPattern: vibrationPattern,
              color: const Color(0xFF2196F3),
              icon: '@mipmap/ic_launcher',
              // REMOVED: largeIcon parameter causing issues
              styleInformation: BigTextStyleInformation(
                notification.body ?? '',
                htmlFormatBigText: true,
                contentTitle: notification.title ?? '',
                htmlFormatContentTitle: true,
              ),
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: json.encode(data),
        );

        print('📱 Local notification shown');
      }
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  static void _handleNotificationTap(String? payload) {
    try {
      if (payload != null) {
        final data = json.decode(payload);
        final type = data['type'] ?? '';
        final eventId = data['event_id'];

        print('🎯 Notification tapped: $type');

        switch (type) {
          case TYPE_EVENT_CREATED:
          case TYPE_EVENT_UPDATED:
            if (eventId != null) {
              // Navigate to event details
              Get.toNamed('/event/$eventId');
            } else {
              Get.to(() => NotificationScreen());
            }
            break;
          case TYPE_SPONSOR_ADDED:
          case TYPE_EXHIBITOR_ADDED:
            Get.toNamed('/my-participations');
            break;
          case TYPE_ANNOUNCEMENT:
          // Show announcement details
            showDialog(
              context: Get.context!,
              builder: (context) => AlertDialog(
                title: Text(data['title']?.toString() ?? 'Announcement'),
                content: Text(data['body']?.toString() ?? ''),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            break;
          default:
            Get.to(() => NotificationScreen());
        }
      } else {
        Get.to(() => NotificationScreen());
      }
    } catch (e) {
      print('❌ Error handling notification tap: $e');
      Get.to(() => NotificationScreen());
    }
  }

  // ========== NOTIFICATION SENDING METHODS ==========
  // These will be implemented when Firestore is enabled
  static Future<void> sendNotificationToUsers({
    required String title,
    required String body,
    required String type,
    required List<int> userIds,
    Map<String, dynamic>? data,
  }) async {
    print('📢 [MOCK] Would send notification to ${userIds.length} users');
    print('   Title: $title');
    print('   Body: $body');
    print('   Type: $type');

    // This will be implemented when Firestore is enabled
  }

  static Future<void> sendNotificationToRole({
    required String title,
    required String body,
    required String type,
    required String role,
    Map<String, dynamic>? data,
  }) async {
    print('📢 [MOCK] Would send notification to role: $role');
    print('   Title: $title');
    print('   Body: $body');

    // This will be implemented when Firestore is enabled
  }

  static Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    print('📢 [MOCK] Would send broadcast notification');
    print('   Title: $title');
    print('   Body: $body');

    // This will be implemented when Firestore is enabled
  }
}