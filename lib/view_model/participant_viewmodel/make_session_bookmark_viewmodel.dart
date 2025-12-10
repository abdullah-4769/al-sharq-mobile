// lib/view_model/participant_viewmodel/make_session_bookmarked_viewmodel.dart

import 'package:get/get.dart';

import '../../repository/participants_repository/make_session_bookmark_repo.dart';

class MakeSessionBookmarkedViewModel extends GetxController {
  final MakeSessionBookmarkedRepo _repo = MakeSessionBookmarkedRepo();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  Future<bool> bookmarkSession({
    required int userId,
    required int sessionId,
    required int eventId,
  }) async {
    try {
      print('=== Bookmarking session for user: $userId, session: $sessionId, event: $eventId ===');
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final response = await _repo.bookmarkSession(
        userId: userId,
        sessionId: sessionId,
        eventId: eventId,
      );

      successMessage.value = response.message;
      print('=== Session bookmarked successfully: ${response.message} ===');
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to bookmark session: $e';
      print('=== Error bookmarking session: $e ===');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}