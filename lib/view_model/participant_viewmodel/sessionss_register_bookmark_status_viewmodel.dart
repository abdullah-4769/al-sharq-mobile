// lib/view_model/participant_viewmodel/session_register_bookmark_status_viewmodel.dart

import 'package:get/get.dart';
import '../../data/response_models/participant_response_model/session_register_bookmark_status_model.dart';
import '../../repository/participants_repository/session_register_bookmark_status_repository.dart';

class SessionRegisterBookmarkStatusViewModel extends GetxController {
  final SessionRegisterBookmarkStatusRepo _repo = SessionRegisterBookmarkStatusRepo();

  final Rx<SessionRegisterBookmarkStatusModel?> _sessionStatus = Rx<SessionRegisterBookmarkStatusModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  SessionRegisterBookmarkStatusModel? get sessionStatus => _sessionStatus.value;
  bool get isRegistered => _sessionStatus.value?.isRegistered ?? false;
  bool get isBookmarked => _sessionStatus.value?.isBookmarked ?? false;

  Future<void> fetchSessionStatus(int sessionId, int userId) async {
    try {
      print('=== Fetching session status for session: $sessionId, user: $userId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final status = await _repo.getSessionStatus(
        sessionId: sessionId,
        userId: userId,
      );

      _sessionStatus.value = status;
      print('=== Session status fetched successfully: $status ===');
    } catch (e) {
      errorMessage.value = 'Failed to load session status: $e';
      print('=== Error fetching session status: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  void clearStatus() {
    _sessionStatus.value = null;
    errorMessage.value = '';
  }
}