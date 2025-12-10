// lib/view_model/participant_viewmodel/speaker_part_in_participant/session_by_speaker_viewmodel.dart

import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/speaker_part_in_participant/session_byspeaker_repo.dart';
import '../../../data/response_models/participant_response_model/speaker_part_in_participant/session_byspeaker_response.dart';

class SessionBySpeakerViewModel extends GetxController {
  final SessionBySpeakerRepo _repo = SessionBySpeakerRepo();

  final RxList<SessionBySpeaker> _sessions = <SessionBySpeaker>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  List<SessionBySpeaker> get sessions => _sessions;

  Future<void> fetchSessionsBySpeaker(int speakerId) async {
    try {
      print('=== Fetching sessions for speaker ID: $speakerId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final sessions = await _repo.getSessionsBySpeaker(speakerId);
      _sessions.assignAll(sessions);

      print('=== Successfully loaded ${sessions.length} sessions ===');
    } catch (e) {
      errorMessage.value = 'Failed to load sessions: $e';
      print('=== Error loading sessions: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSessions() {
    _sessions.clear();
    errorMessage.value = '';
  }
}