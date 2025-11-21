import 'package:get/get.dart';
import '../../data/request_models/organizer/organizer_session_details_get_model.dart';
import '../../repository/organizer_repo/organizer_session_details_get_repo.dart';
import 'package:flutter/material.dart';

class OrganizerSessionDetailsGetViewModel extends GetxController {
  final _repo = OrganizerSessionDetailsGetRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var sessionDetails = OrganizerSessionDetailsGetModel(
    id: 0,
    title: '',
    description: '',
    startTime: '',
    endTime: '',
    location: '',
    category: '',
    capacity: 0,
    tags: [],
    eventId: 0,
    registrationRequired: false,
    speakers: [],
  ).obs;

  Future<void> getSessionDetails(int sessionId) async {
    try {
      print('🚀 OrganizerSessionDetailsGetViewModel: Starting getSessionDetails for ID: $sessionId');
      isLoading.value = true;
      error.value = '';

      final session = await _repo.getSessionDetails(sessionId);
      sessionDetails.value = session;

      print('✅ OrganizerSessionDetailsGetViewModel: Successfully loaded session details');
      print('🎯 Session ID: ${session.id}');
      print('🎯 Session Title: ${session.title}');

    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerSessionDetailsGetViewModel: Error in getSessionDetails: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        'Failed to load session details: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerSessionDetailsGetViewModel: getSessionDetails completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to load session details')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}