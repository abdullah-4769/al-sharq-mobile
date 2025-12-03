// lib/view_model/event_sessions_view_model.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/response/api_response.dart';
import '../../data/response_models/participant_response_model/event_session_response_model.dart';
import '../../data/response_models/participant_response_model/session_model.dart';
import '../../repository/participants_repository/event_session_repository.dart';
import '../../utils/shared_preference.dart';


class EventSessionsViewModel extends GetxController {
  final _repo = EventSessionsRepository();

  // Reactive variables for state management
  var sessionsResponse = ApiResponse<EventSessionsResponseModel>().obs;
  var isLoading = false.obs;

  // Getter for easy access to data
  List<SessionModel> get liveSessions =>
      sessionsResponse.value.data?.liveSessions ?? [];

  List<SessionModel> get allSessions =>
      sessionsResponse.value.data?.allSessions ?? [];

  Future<void> fetchEventSessions(BuildContext context) async { // Add context parameter
    try {
      isLoading.value = true;
      sessionsResponse.value = ApiResponse.loading();

      // Get event ID from shared preferences (saved during login)
      final eventId = await SharedPrefsHelper.getLatestEventId();

      if (eventId == null) {
        throw Exception('No event ID found. Please login again.');
      }

      final result = await _repo.getEventSessions(eventId, context); // Pass context
      sessionsResponse.value = ApiResponse.completed(result);

    } catch (e) {
      sessionsResponse.value = ApiResponse.error();
      sessionsResponse.value.message = e.toString();

      Get.snackbar(
        'Error',
        'Failed to load sessions: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get specific session by ID
  SessionModel? getSessionById(int sessionId) {
    try {
      return allSessions.firstWhere(
            (session) => session.sessionId == sessionId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get live sessions count
  int get liveSessionsCount => liveSessions.length;

  // Get upcoming sessions (not live but with timeToStart)
  List<SessionModel> get upcomingSessions {
    return allSessions.where((session) => session.isUpcoming).toList();
  }

  // Refresh data
  Future<void> refreshSessions(BuildContext context) async { // Add context parameter
    await fetchEventSessions(context);
  }
}