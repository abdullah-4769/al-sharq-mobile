import 'package:get/get.dart';
import '../../repository/organizer_repo/organizer_event_delete_repo.dart';
import 'package:flutter/material.dart';

class OrganizerEventDeleteViewModel extends GetxController {
  final _repo = OrganizerEventDeleteRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  Future<bool> deleteEvent(int eventId) async {
    try {
      print('🚀 OrganizerEventDeleteViewModel: Starting deleteEvent for ID: $eventId');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final bool deleted = await _repo.deleteEvent(eventId);
      success.value = deleted;

      if (deleted) {
        print('✅ OrganizerEventDeleteViewModel: Event deleted successfully');

        Get.snackbar(
          'Success ✅',
          'Event deleted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
          icon: Icon(Icons.check_circle, color: Colors.white),
        );

        // You can also trigger a refresh of the events list here
        // Get.find<YourEventsListViewModel>().refreshEvents();

        return true;
      } else {
        error.value = 'Failed to delete event';
        print('❌ OrganizerEventDeleteViewModel: Delete failed');

        Get.snackbar(
          'Deleted',
          'Event Deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          icon: Icon(Icons.error, color: Colors.white),
        );
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerEventDeleteViewModel: Error in deleteEvent: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error ❌',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.error, color: Colors.white),
      );
      return false;
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerEventDeleteViewModel: deleteEvent completed');
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