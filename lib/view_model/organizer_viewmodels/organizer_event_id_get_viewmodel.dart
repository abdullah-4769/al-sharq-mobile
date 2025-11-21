import 'package:get/get.dart';
import '../../data/response_models/organizer_response_models/organizer_event_id_get_model.dart';
import '../../repository/organizer_repo/organizer_event_id_get_repo.dart';
import 'package:flutter/material.dart';

class OrganizerEventIdGetViewModel extends GetxController {
  final _repo = OrganizerEventIdGetRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var eventsList = <OrganizerEventIdGetModel>[].obs;

  // Update the logging in the getEventsShortInfo method:
  Future<void> getEventsShortInfo() async {
    try {
      print('🚀 OrganizerEventIdGetViewModel: Starting getEventsShortInfo...');
      isLoading.value = true;
      error.value = '';

      final events = await _repo.getEventsShortInfo();
      eventsList.value = events;

      print('✅ OrganizerEventIdGetViewModel: Successfully loaded events list');
      print('📊 Total Events: ${events.length}');

      for (var event in events) {
        print('🎯 Event: ${event.title} (ID: ${event.eventId})'); // Updated to eventId
      }

    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerEventIdGetViewModel: Error in getEventsShortInfo: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        'Failed to load events: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerEventIdGetViewModel: getEventsShortInfo completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to load events')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}