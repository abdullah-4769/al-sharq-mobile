import 'package:get/get.dart';
import '../../data/request_models/organizer/organizer_create_event_venue_model.dart';
import '../../notifications/event_notification_service.dart';
import '../../notifications/notification_service.dart';
import '../../repository/organizer_repo/organizer_create_event_venue_repo.dart';
import '../../utils/shared_preference.dart';

// ADD THIS IMPORT

class OrganizerCreateEventVenueViewModel extends GetxController {
  final _repo = OrganizerCreateEventVenueRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;
  var eventData = OrganizerCreateEventVenueModel(
    id: 0,
    title: '',
    description: '',
    location: '',
    googleMapLink: '',
    joinToken: '',
    mapstatus: false,
    sponsors: [],
    exhibitors: [],
  ).obs;

  Future<bool> createEvent(Map<String, dynamic> data) async {
    try {
      print('🚀 Starting createEvent...');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final response = await _repo.createEvent(data);
      eventData.value = response;
      success.value = true;

      print('✅ Event created successfully - ID: ${response.id}');

      // ✅ ADD NOTIFICATION CODE HERE
      await _sendEventCreationNotifications(response);
      // ✅ END OF NOTIFICATION CODE

      return true;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in createEvent: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ ADD THIS HELPER METHOD
  Future<void> _sendEventCreationNotifications(OrganizerCreateEventVenueModel response) async {
    try {
      // Get organizer info from SharedPreferences
      final userId = await SharedPrefsHelper.getUserId();
      final userName = await SharedPrefsHelper.getUserName();

      if (userId != null) {
        await EventNotificationService.notifyEventCreated(
          eventId: response.id,
          eventName: response.title,
          sponsorIds: response.sponsors.map((s) => s.id).toList(),
          exhibitorIds: response.exhibitors.map((e) => e.id).toList(),
          description: response.description,
          organizerId: userId,
          organizerName: userName ?? 'Organizer',
        );
        print('📢 Event creation notifications sent successfully');
      } else {
        print('⚠️ Could not send notifications: User ID not found');
      }
    } catch (e) {
      print('❌ Error sending event creation notifications: $e');
      // Don't throw error - notifications shouldn't break event creation
    }
  }

  Future<bool> updateEvent(int eventId, Map<String, dynamic> data) async {
    try {
      print('🚀 Starting updateEvent for ID: $eventId');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final response = await _repo.updateEvent(eventId, data);
      eventData.value = response;
      success.value = true;

      print('✅ Event updated successfully - ID: ${response.id}');

      // ✅ ADD NOTIFICATION CODE HERE
      await _sendEventUpdateNotifications(response);
      // ✅ END OF NOTIFICATION CODE

      return true;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in updateEvent: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ ADD THIS HELPER METHOD
  Future<void> _sendEventUpdateNotifications(OrganizerCreateEventVenueModel response) async {
    try {
      // Get organizer info
      final userId = await SharedPrefsHelper.getUserId();
      final userName = await SharedPrefsHelper.getUserName();

      if (userId != null) {
        // Get all affected users (sponsors + exhibitors)
        final affectedUserIds = [
          ...response.sponsors.map((s) => s.id),
          ...response.exhibitors.map((e) => e.id),
        ];

        if (affectedUserIds.isNotEmpty) {
          await EventNotificationService.notifyEventUpdated(
            eventId: response.id,
            eventName: response.title,
            affectedUserIds: affectedUserIds,
            changes: 'Event details have been updated',
            organizerId: userId,
            organizerName: userName ?? 'Organizer',
          );
          print('📢 Event update notifications sent to ${affectedUserIds.length} users');
        } else {
          print('ℹ️ No affected users to notify for event update');
        }
      } else {
        print('⚠️ Could not send update notifications: User ID not found');
      }
    } catch (e) {
      print('❌ Error sending event update notifications: $e');
    }
  }

  Future<void> getEvent(int eventId) async {
    try {
      print('🚀 Starting getEvent for ID: $eventId');
      isLoading.value = true;
      error.value = '';

      final response = await _repo.getEvent(eventId);
      eventData.value = response;

      print('✅ Event fetched successfully - ID: ${response.id}');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in getEvent: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up any resources if needed
    super.onClose();
  }
}



// import 'package:get/get.dart';
// import '../../data/request_models/organizer/organizer_create_event_venue_model.dart';
// import '../../notifications/notification_service.dart';
// import '../../repository/organizer_repo/organizer_create_event_venue_repo.dart';
// import 'package:flutter/material.dart';
//
// import '../../utils/shared_preference.dart';
// class OrganizerCreateEventVenueViewModel extends GetxController {
//   final _repo = OrganizerCreateEventVenueRepo();
//
//   var isLoading = false.obs;
//   var error = ''.obs;
//   var success = false.obs;
//   var eventData = OrganizerCreateEventVenueModel(
//     id: 0,
//     title: '',
//     description: '',
//     location: '',
//     googleMapLink: '',
//     joinToken: '',
//     mapstatus: false,
//     sponsors: [],
//     exhibitors: [],
//   ).obs;
// // In OrganizerCreateEventVenueViewModel - after createEvent
//   Future<bool> createEvent(Map<String, dynamic> data) async {
//     try {
//       print('🚀 Starting createEvent...');
//       isLoading.value = true;
//       error.value = '';
//       success.value = false;
//
//       final response = await _repo.createEvent(data);
//       eventData.value = response;
//       success.value = true;
//
//       print('✅ Event created successfully - ID: ${response.id}');
//
//       // SEND NOTIFICATIONS
//       final userId = await SharedPrefsHelper.getUserId();
//       if (userId != null) {
//         await NotificationService.notifyEventCreated(
//           eventId: response.id,
//           eventName: response.title,
//           sponsorIds: response.sponsors.map((s) => s.id).toList(),
//           exhibitorIds: response.exhibitors.map((e) => e.id).toList(),
//           organizerId: userId,
//         );
//       }
//
//       return true;
//     } catch (e) {
//       error.value = e.toString();
//       print('❌ Error in createEvent: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
// // In OrganizerCreateEventVenueViewModel - after updateEvent
//   Future<bool> updateEvent(int eventId, Map<String, dynamic> data) async {
//     try {
//       print('🚀 Starting updateEvent for ID: $eventId');
//       isLoading.value = true;
//       error.value = '';
//       success.value = false;
//
//       final response = await _repo.updateEvent(eventId, data);
//       eventData.value = response;
//       success.value = true;
//
//       print('✅ Event updated successfully - ID: ${response.id}');
//
//       // SEND NOTIFICATIONS
//       final userId = await SharedPrefsHelper.getUserId();
//       if (userId != null) {
//         // Get affected users (sponsors + exhibitors)
//         final affectedUserIds = [
//           ...response.sponsors.map((s) => s.id),
//           ...response.exhibitors.map((e) => e.id),
//         ];
//
//         await NotificationService.notifyEventUpdated(
//           eventId: response.id,
//           eventName: response.title,
//           affectedUserIds: affectedUserIds,
//           organizerId: userId,
//         );
//       }
//
//       return true;
//     } catch (e) {
//       error.value = e.toString();
//       print('❌ Error in updateEvent: $e');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//   Future<void> getEvent(int eventId) async {
//     try {
//       print('🚀 Starting getEvent for ID: $eventId');
//       isLoading.value = true;
//       error.value = '';
//
//       final response = await _repo.getEvent(eventId);
//       eventData.value = response;
//
//       print('✅ Event fetched successfully - ID: ${response.id}');
//     } catch (e) {
//       error.value = e.toString();
//       print('❌ Error in getEvent: $e');
//       rethrow;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   @override
//   void onClose() {
//     // Clean up any resources if needed
//     super.onClose();
//   }
// }