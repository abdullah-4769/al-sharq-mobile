import 'package:get/get.dart';
import '../notifications/notification_service.dart';

class EventNotificationService {
  // Send notification when event is created
  static Future<void> notifyEventCreated({
    required int eventId,
    required String eventName,
    required List<int> sponsorIds,
    required List<int> exhibitorIds,
    String? description,
    required int organizerId,
    String? organizerName,
  }) async {
    try {
      print('🎉 Sending event creation notifications for "$eventName"');

      // 1. Notify sponsors
      if (sponsorIds.isNotEmpty) {
        await NotificationService.sendNotificationToUsers(
          title: '🎉 New Event Sponsorship',
          body: 'You have been added as a sponsor for "$eventName"',
          type: NotificationService.TYPE_SPONSOR_ADDED,
          userIds: sponsorIds,
          data: {
            'type': NotificationService.TYPE_SPONSOR_ADDED,
            'event_id': eventId.toString(),
            'event_name': eventName,
            'sender_id': organizerId.toString(),
            'sender_name': organizerName ?? 'Organizer',
            'action': 'view_event',
            'timestamp': DateTime.now().toIso8601String(),
            'priority': 'high',
          },
        );
      }

      // 2. Notify exhibitors
      if (exhibitorIds.isNotEmpty) {
        await NotificationService.sendNotificationToUsers(
          title: '🏪 New Exhibition Opportunity',
          body: 'You have been added as an exhibitor for "$eventName"',
          type: NotificationService.TYPE_EXHIBITOR_ADDED,
          userIds: exhibitorIds,
          data: {
            'type': NotificationService.TYPE_EXHIBITOR_ADDED,
            'event_id': eventId.toString(),
            'event_name': eventName,
            'sender_id': organizerId.toString(),
            'sender_name': organizerName ?? 'Organizer',
            'action': 'view_event',
            'timestamp': DateTime.now().toIso8601String(),
            'priority': 'high',
          },
        );
      }

      // 3. Notify all participants about new event
      await NotificationService.sendNotificationToRole(
        title: '📅 New Event: $eventName',
        body: description?.isNotEmpty == true
            ? description!
            : 'A new event has been created. Check it out!',
        type: NotificationService.TYPE_EVENT_CREATED,
        role: 'participant',
        data: {
          'type': NotificationService.TYPE_EVENT_CREATED,
          'event_id': eventId.toString(),
          'event_name': eventName,
          'description': description,
          'sender_id': organizerId.toString(),
          'sender_name': organizerName ?? 'Organizer',
          'action': 'view_event',
          'timestamp': DateTime.now().toIso8601String(),
          'priority': 'normal',
        },
      );

      print('✅ Event creation notifications sent successfully');
    } catch (e) {
      print('❌ Error sending event creation notifications: $e');
      // Don't throw, just log the error
    }
  }

  // Send notification when event is updated
  static Future<void> notifyEventUpdated({
    required int eventId,
    required String eventName,
    required List<int> affectedUserIds,
    String? changes,
    required int organizerId,
    String? organizerName,
    bool notifyAllParticipants = false,
  }) async {
    try {
      print('✏️ Sending event update notifications for "$eventName"');

      // Notify affected users
      if (affectedUserIds.isNotEmpty) {
        await NotificationService.sendNotificationToUsers(
          title: '✏️ Event Updated: $eventName',
          body: changes != null && changes.isNotEmpty
              ? 'Changes: $changes'
              : 'The event has been updated',
          type: NotificationService.TYPE_EVENT_UPDATED,
          userIds: affectedUserIds,
          data: {
            'type': NotificationService.TYPE_EVENT_UPDATED,
            'event_id': eventId.toString(),
            'event_name': eventName,
            'sender_id': organizerId.toString(),
            'sender_name': organizerName ?? 'Organizer',
            'changes': changes,
            'action': 'view_event',
            'timestamp': DateTime.now().toIso8601String(),
            'priority': 'high',
          },
        );
      }

      // Optionally notify all participants
      if (notifyAllParticipants) {
        await NotificationService.sendNotificationToRole(
          title: '🔄 Event Updated: $eventName',
          body: 'Check out the latest updates',
          type: NotificationService.TYPE_EVENT_UPDATED,
          role: 'participant',
          data: {
            'type': NotificationService.TYPE_EVENT_UPDATED,
            'event_id': eventId.toString(),
            'event_name': eventName,
            'action': 'view_event',
            'timestamp': DateTime.now().toIso8601String(),
            'priority': 'normal',
          },
        );
      }

      print('✅ Event update notifications sent successfully');
    } catch (e) {
      print('❌ Error sending event update notifications: $e');
    }
  }

  // Send notification when event is deleted
  static Future<void> notifyEventDeleted({
    required String eventName,
    required List<int> affectedUserIds,
    String? reason,
    required int organizerId,
    String? organizerName,
  }) async {
    try {
      print('🗑️ Sending event deletion notifications for "$eventName"');

      if (affectedUserIds.isNotEmpty) {
        await NotificationService.sendNotificationToUsers(
          title: '🗑️ Event Cancelled: $eventName',
          body: reason != null && reason.isNotEmpty
              ? 'Reason: $reason'
              : 'The event has been cancelled',
          type: NotificationService.TYPE_EVENT_DELETED,
          userIds: affectedUserIds,
          data: {
            'type': NotificationService.TYPE_EVENT_DELETED,
            'event_name': eventName,
            'sender_id': organizerId.toString(),
            'sender_name': organizerName ?? 'Organizer',
            'reason': reason,
            'action': 'view_events',
            'timestamp': DateTime.now().toIso8601String(),
            'priority': 'high',
          },
        );
      }

      print('✅ Event deletion notifications sent successfully');
    } catch (e) {
      print('❌ Error sending event deletion notifications: $e');
    }
  }

  // Send announcement to event participants
  static Future<void> sendEventAnnouncement({
    required int eventId,
    required String eventName,
    required String title,
    required String message,
    required List<int> participantIds,
    required int senderId,
    String? senderName,
    String? senderRole,
  }) async {
    try {
      print('📢 Sending event announcement for "$eventName"');

      if (participantIds.isNotEmpty) {
        await NotificationService.sendNotificationToUsers(
          title: title,
          body: message,
          type: NotificationService.TYPE_ANNOUNCEMENT,
          userIds: participantIds,
          data: {
            'type': NotificationService.TYPE_ANNOUNCEMENT,
            'event_id': eventId.toString(),
            'event_name': eventName,
            'sender_id': senderId.toString(),
            'sender_name': senderName ?? 'Event Organizer',
            'sender_role': senderRole,
            'action': 'view_event',
            'timestamp': DateTime.now().toIso8601String(),
            'priority': 'normal',
          },
        );
      }

      print('✅ Event announcement sent successfully');
    } catch (e) {
      print('❌ Error sending event announcement: $e');
    }
  }

  // Send reminder notification
  static Future<void> sendEventReminder({
    required int eventId,
    required String eventName,
    required DateTime eventDate,
    required List<int> participantIds,
    String? location,
  }) async {
    try {
      print('⏰ Sending event reminder for "$eventName"');

      final timeUntilEvent = eventDate.difference(DateTime.now());
      final daysUntil = timeUntilEvent.inDays;
      final hoursUntil = timeUntilEvent.inHours;

      String timeText;
      if (daysUntil > 0) {
        timeText = '$daysUntil day${daysUntil > 1 ? 's' : ''}';
      } else if (hoursUntil > 0) {
        timeText = '$hoursUntil hour${hoursUntil > 1 ? 's' : ''}';
      } else {
        timeText = 'soon';
      }

      if (participantIds.isNotEmpty) {
        await NotificationService.sendNotificationToUsers(
          title: '⏰ Reminder: $eventName',
          body: 'Event starts in $timeText${location != null ? ' at $location' : ''}',
          type: NotificationService.TYPE_PERSONAL,
          userIds: participantIds,
          data: {
            'type': NotificationService.TYPE_PERSONAL,
            'event_id': eventId.toString(),
            'event_name': eventName,
            'event_date': eventDate.toIso8601String(),
            'location': location,
            'action': 'view_event',
            'timestamp': DateTime.now().toIso8601String(),
            'priority': 'normal',
          },
        );
      }

      print('✅ Event reminder sent successfully');
    } catch (e) {
      print('❌ Error sending event reminder: $e');
    }
  }
}