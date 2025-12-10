import 'package:get/get.dart';
import '../../data/response_models/organizer_response_models/organizer_all_session_details_show_model.dart';
import '../../repository/organizer_repo/organizer_all_session_details_show_repo.dart';
import 'package:flutter/material.dart';

class OrganizerAllSessionDetailsShowViewModel extends GetxController {
  final _repo = OrganizerAllSessionDetailsShowRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var sessionsList = <OrganizerAllSessionDetailsShowModel>[].obs;

  Future<void> getAllSessions() async {
    try {
      print('🚀 OrganizerAllSessionDetailsShowViewModel: Starting getAllSessions...');
      isLoading.value = true;
      error.value = '';

      final sessions = await _repo.getAllSessions();
      sessionsList.value = sessions;

      print('✅ OrganizerAllSessionDetailsShowViewModel: Successfully loaded sessions list');
      print('📊 Total Sessions: ${sessions.length}');

      for (var session in sessions) {
        print('🎯 Session: ${session.title} (ID: ${session.id})');
        print('   - Start: ${session.startTime}');
        print('   - End: ${session.endTime}');
        print('   - Speakers: ${session.speakers.length}');
      }

    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerAllSessionDetailsShowViewModel: Error in getAllSessions: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        'Failed to load sessions: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerAllSessionDetailsShowViewModel: getAllSessions completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to load sessions')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }

  // Get sessions by status
  List<OrganizerAllSessionDetailsShowModel> getSessionsByStatus(String status) {
    return sessionsList.where((session) => session.status == status).toList();
  }

  // Get session counts for stats
  int getTotalSessions() => sessionsList.length;
  int getUpcomingSessions() => getSessionsByStatus('Upcoming').length;
  int getCompletedSessions() => getSessionsByStatus('Completed').length;
}