import 'package:get/get.dart';
import '../../notifications/event_notification_service.dart';
import '../../repository/organizer_repo/organizer_event_delete_repo.dart';
import 'package:flutter/material.dart';
import '../../utils/shared_preference.dart';

// ADD THIS IMPORT

class OrganizerEventDeleteViewModel extends GetxController {
  final _repo = OrganizerEventDeleteRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  // UPDATE THIS METHOD SIGNATURE
  Future<bool> deleteEvent({
    required int eventId,
    required String eventName,
    required List<int> affectedUserIds,
    String? reason,
  }) async {
    try {
      print('🚀 Starting deleteEvent for ID: $eventId');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final bool deleted = await _repo.deleteEvent(eventId);
      success.value = deleted;

      if (deleted) {
        print('✅ OrganizerEventDeleteViewModel: Event deleted successfully');

        // ✅ ADD NOTIFICATION CODE HERE
        await _sendEventDeletionNotifications(
          eventName: eventName,
          affectedUserIds: affectedUserIds,
          reason: reason,
        );
        // ✅ END OF NOTIFICATION CODE

        return true;
      } else {
        error.value = 'Failed to delete event';
        print('❌ OrganizerEventDeleteViewModel: Delete failed');
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerEventDeleteViewModel: Error in deleteEvent: $e');
      return false;
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerEventDeleteViewModel: deleteEvent completed');
    }
  }

  // ✅ ADD THIS HELPER METHOD
  Future<void> _sendEventDeletionNotifications({
    required String eventName,
    required List<int> affectedUserIds,
    String? reason,
  }) async {
    try {
      // Get organizer info
      final userId = await SharedPrefsHelper.getUserId();
      final userName = await SharedPrefsHelper.getUserName();

      if (userId != null) {
        if (affectedUserIds.isNotEmpty) {
          await EventNotificationService.notifyEventDeleted(
            eventName: eventName,
            affectedUserIds: affectedUserIds,
            reason: reason,
            organizerId: userId,
            organizerName: userName ?? 'Organizer',
          );
          print('📢 Event deletion notifications sent to ${affectedUserIds.length} users');
        } else {
          print('ℹ️ No affected users to notify for event deletion');
        }
      } else {
        print('⚠️ Could not send deletion notifications: User ID not found');
      }
    } catch (e) {
      print('❌ Error sending event deletion notifications: $e');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Failed to delete event')) {
      // Extract the actual error message from the exception
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}


// import 'package:get/get.dart';
// import '../../repository/organizer_repo/organizer_event_delete_repo.dart';
// import 'package:flutter/material.dart';
//
// import '../../utils/shared_preference.dart';
//
// class OrganizerEventDeleteViewModel extends GetxController {
//   final _repo = OrganizerEventDeleteRepo();
//
//   var isLoading = false.obs;
//   var error = ''.obs;
//   var success = false.obs;
//
//   //In OrganizerEventDeleteViewModel - after deleteEvent
//   Future<bool> deleteEvent(int eventId) async {
//     try {
//       print('🚀 OrganizerEventDeleteViewModel: Starting deleteEvent for ID: $eventId');
//       isLoading.value = true;
//       error.value = '';
//       success.value = false;
//
//       // First get event details to know affected users
//       // You might need to fetch event data first or pass it as parameter
//
//       final bool deleted = await _repo.deleteEvent(eventId);
//       success.value = deleted;
//
//       if (deleted) {
//         print('✅ OrganizerEventDeleteViewModel: Event deleted successfully');
//
//         // SEND NOTIFICATIONS
//         // Note: You'll need event name and affected user IDs
//         // This requires additional data - you might need to:
//         // 1. Pass event data to delete function
//         // 2. Fetch event before deleting
//         // 3. Store event info in a way that's accessible here
//
//         final userId = await SharedPrefsHelper.getUserId();
//         if (userId != null) {
//           // Example - you'll need to implement getting affected users
//           // await NotificationService.notifyEventDeleted(...);
//         }
//
//         return true;
//       } else {
//         error.value = 'Failed to delete event';
//         print('❌ OrganizerEventDeleteViewModel: Delete failed');
//         return false;
//       }
//     } catch (e) {
//       error.value = e.toString();
//       print('❌ OrganizerEventDeleteViewModel: Error in deleteEvent: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//       print('🏁 OrganizerEventDeleteViewModel: deleteEvent completed');
//     }
//   }
//
//   String _getErrorMessage(dynamic error) {
//     String errorString = error.toString();
//     if (errorString.contains('Network error')) {
//       return 'Please check your internet connection and try again.';
//     } else if (errorString.contains('Failed to delete event')) {
//       // Extract the actual error message from the exception
//       return errorString.replaceAll('Exception: ', '');
//     }
//     return 'An unexpected error occurred. Please try again.';
//   }
// }