// lib/view_model/participant_viewmodel/today_session_viewmodel.dart
import 'package:get/get.dart';
import '../../data/response_models/participant_response_model/today_session_model.dart';
import '../../repository/participants_repository/today_session_repository.dart';

class TodaySessionViewModel extends GetxController {
  final TodaySessionRepository _repository = TodaySessionRepository();

  final RxList<TodaySessionModel> allSessions = <TodaySessionModel>[].obs;
  final RxList<TodaySessionModel> registeredSessions = <TodaySessionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> fetchRegisteredSessions(int userId, int eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final sessions = await _repository.getRegisteredSessions(userId, eventId);
      registeredSessions.assignAll(sessions);

      // Also update all sessions with registered sessions
      allSessions.assignAll(sessions);

    } catch (e) {
      errorMessage.value = 'Failed to load registered sessions: $e';
      print('❌ Error fetching registered sessions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllSessions(int eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final sessions = await _repository.getAllSessions(eventId);
      allSessions.assignAll(sessions);

    } catch (e) {
      errorMessage.value = 'Failed to load sessions: $e';
      print('❌ Error fetching all sessions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  void clearSessions() {
    allSessions.clear();
    registeredSessions.clear();
  }
}