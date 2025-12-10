// lib/notifications/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'notification_controller.dart';
import 'notification_database.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find<NotificationController>();
  final NotificationDatabase _db = NotificationDatabase();
  List<Map<String, dynamic>> _storedNotifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _storedNotifications = await _db.getAllNotifications();
    _unreadCount = await _db.getUnreadCount();
    setState(() {});
  }

  Future<void> _markAsRead(int id) async {
    await _db.markAsRead(id);
    await _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    final db = await _db.database;
    await db.update('notifications', {'read_status': 1});
    await _loadNotifications();
  }

  Future<void> _deleteNotification(int id) async {
    final db = await _db.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
    await _loadNotifications();
    controller.notifications.removeWhere((msg) {
      final data = json.encode(msg.data);
      return data.contains('"id":$id');
    });
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'event_created':
        return '🎉';
      case 'event_updated':
        return '✏️';
      case 'event_deleted':
        return '🗑️';
      case 'sponsor_added':
        return '🏢';
      case 'exhibitor_added':
        return '🎪';
      case 'personal':
        return '👤';
      default:
        return '📢';
    }
  }

  String _getNotificationTypeText(String type) {
    switch (type) {
      case 'event_created':
        return 'New Event';
      case 'event_updated':
        return 'Event Updated';
      case 'event_deleted':
        return 'Event Cancelled';
      case 'sponsor_added':
        return 'Sponsor Added';
      case 'exhibitor_added':
        return 'Exhibitor Added';
      default:
        return 'Notification';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 12,
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                controller.clearNotifications();
                _clearAllNotifications();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear all notifications'),
              ),
            ],
          ),
        ],
      ),
      body: _storedNotifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Notifications will appear here',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _storedNotifications.length,
        itemBuilder: (context, index) {
          final notification = _storedNotifications[index];
          final isRead = notification['read_status'] == 1;
          final type = notification['notification_type'] as String? ?? 'system';

          return Dismissible(
            key: Key(notification['id'].toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _deleteNotification(notification['id']);
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: isRead ? Colors.white : Colors.blue[50],
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isRead ? Colors.grey[200] : Colors.blue[100],
                  child: Text(
                    _getNotificationIcon(type),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] as String? ?? 'Notification',
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getNotificationTypeText(type),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  notification['body'] as String? ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(notification['timestamp'] as String?),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  if (!isRead) {
                    _markAsRead(notification['id']);
                  }

                  // Parse data and handle tap
                  try {
                    final data = json.decode(notification['data'] as String? ?? '{}');
                    _handleNotificationTap(data);
                  } catch (e) {
                    // Show notification details
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(notification['title'] as String? ?? 'Notification'),
                        content: Text(notification['body'] as String? ?? ''),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Notification Options'),
                      content: const Text('What would you like to do?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteNotification(notification['id']);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _clearAllNotifications() async {
    final db = await _db.database;
    await db.delete('notifications');
    await _loadNotifications();
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    final eventId = data['event_id'];

    switch (type) {
      case 'event_created':
      case 'event_updated':
        if (eventId != null) {
          Get.toNamed('/event/$eventId');
        }
        break;
      case 'sponsor_added':
      case 'exhibitor_added':
        Get.toNamed('/my-participations');
        break;
      default:
      // Show details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(data['title']?.toString() ?? 'Notification'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['body']?.toString() ?? ''),
                const SizedBox(height: 16),
                if (data['event_name'] != null)
                  Text('Event: ${data['event_name']}'),
                if (data['sender_role'] != null)
                  Text('From: ${data['sender_role']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';

      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return timestamp;
    }
  }
}






// // lib/notifications/notification_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'notification_controller.dart';
//
// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // IMPORTANT: Use Get.find() to get existing instance, not Get.put()
//     final NotificationController controller = Get.find<NotificationController>();
//
//     print('📱 [NotificationScreen] Built - Current notifications: ${controller.notifications.length}');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         backgroundColor: Colors.blue,
//         elevation: 0,
//         actions: [
//           // Delete button
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () {
//               controller.clearNotifications();
//               Get.back();
//             },
//           ),
//         ],
//       ),
//       body: Obx(() {
//         print('🔄 [NotificationScreen] Rebuilding - Notifications: ${controller.notifications.length}');
//
//         if (controller.notifications.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 const Text('No notifications yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () => Get.back(),
//                   child: const Text('Go Back'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return ListView.separated(
//           itemCount: controller.notifications.length,
//           separatorBuilder: (_, __) => const Divider(),
//           itemBuilder: (context, index) {
//             RemoteMessage msg = controller.notifications[index];
//             return ListTile(
//               leading: const Icon(Icons.notifications, color: Colors.blue),
//               title: Text(
//                 msg.notification?.title ?? 'No Title',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(msg.notification?.body ?? 'No Body'),
//               trailing: const Icon(Icons.chevron_right),
//               onTap: () {
//                 // Show notification details
//                 Get.snackbar(
//                   msg.notification?.title ?? 'Notification',
//                   msg.notification?.body ?? '',
//                   duration: const Duration(seconds: 3),
//                 );
//               },
//             );
//           },
//         );
//       }),
//     );
//   }
// }