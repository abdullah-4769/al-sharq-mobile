import 'package:get/get.dart';
import '../../data/response_models/speaker_response_models/speaker_sessions_detail_show_model.dart';
import '../../repository/speaker_repository/speaker_sessions_detail_show_repo.dart';
import 'package:flutter/material.dart';

class SpeakerSessionsDetailShowViewModel extends GetxController {
  final SpeakerSessionsDetailShowRepo _repo = SpeakerSessionsDetailShowRepo();

  final Rx<SpeakerSessionsDetailShowResponse?> _speakerSessions = Rx<SpeakerSessionsDetailShowResponse?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  SpeakerSessionsDetailShowResponse? get speakerSessions => _speakerSessions.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  // Stats getters
  int get totalSessions => speakerSessions?.total ?? 0;
  int get ongoingSessions => speakerSessions?.ongoing ?? 0;
  int get scheduledSessions => speakerSessions?.scheduled ?? 0;
  List<SpeakerSessionModel> get sessions => speakerSessions?.sessions ?? [];

  Future<void> fetchSpeakerSessions(int speakerId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final sessions = await _repo.getSpeakerSessions(speakerId);
      _speakerSessions.value = sessions;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load speaker sessions: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }

  // Helper method to get session by ID
  SpeakerSessionModel? getSessionById(int sessionId) {
    return sessions.firstWhereOrNull((session) => session.id == sessionId);
  }

  // Helper method to get sessions by status
  List<SpeakerSessionModel> getSessionsByStatus(String status) {
    return sessions.where((session) => session.status == status).toList();
  }
}