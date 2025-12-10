// lib/notifications/notification_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationDatabase {
  static final NotificationDatabase _instance = NotificationDatabase._internal();
  factory NotificationDatabase() => _instance;
  NotificationDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'notifications.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        notification_id TEXT,
        title TEXT,
        body TEXT,
        data TEXT,
        sender_id INTEGER,
        sender_role TEXT,
        notification_type TEXT,
        read_status INTEGER DEFAULT 0,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        event_id INTEGER,
        event_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_tokens(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        user_role TEXT,
        fcm_token TEXT UNIQUE,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Save notification
  Future<int> saveNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String notificationType,
    int? eventId,
    String? eventName,
    int? senderId,
    String? senderRole,
  }) async {
    final db = await database;

    return await db.insert('notifications', {
      'notification_id': data['notification_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'data': data.toString(),
      'sender_id': senderId,
      'sender_role': senderRole,
      'notification_type': notificationType,
      'event_id': eventId,
      'event_name': eventName,
      'read_status': 0,
    });
  }

  // Mark as read
  Future<void> markAsRead(int notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'read_status': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // Get all notifications
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;
    return await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
    );
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE read_status = 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Save FCM token
  Future<void> saveFcmToken({
    required int userId,
    required String userRole,
    required String token,
  }) async {
    final db = await database;

    await db.insert(
      'user_tokens',
      {
        'user_id': userId,
        'user_role': userRole,
        'fcm_token': token,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get tokens by user role
  Future<List<String>> getTokensByRole(String role) async {
    final db = await database;
    final result = await db.query(
      'user_tokens',
      where: 'user_role = ?',
      whereArgs: [role],
      columns: ['fcm_token'],
    );

    return result.map((map) => map['fcm_token'] as String).toList();
  }

  // Get tokens by user IDs
  Future<List<String>> getTokensByUserIds(List<int> userIds) async {
    if (userIds.isEmpty) return [];

    final db = await database;
    final placeholders = userIds.map((_) => '?').join(',');
    final result = await db.rawQuery(
      'SELECT fcm_token FROM user_tokens WHERE user_id IN ($placeholders)',
      userIds.cast<Object>(),
    );

    return result.map((map) => map['fcm_token'] as String).toList();
  }
}