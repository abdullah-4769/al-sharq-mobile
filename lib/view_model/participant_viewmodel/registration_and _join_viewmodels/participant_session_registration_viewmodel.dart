import 'package:get/get.dart';
import '../../../repository/participants_repository/registration_and_join_repo/participant_session_registration_repository.dart';
import '../../../utils/shared_preference.dart';

class ParticipantSessionRegistrationViewModel extends GetxController {
  final ParticipantSessionRegistrationRepository _repo = ParticipantSessionRegistrationRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> registerForSession({
    required int sessionId,
    required String whyJoin,
    required String relevantExperience,
  }) async {
    try {
      print('=== Starting registration process for session: $sessionId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final userId = await SharedPrefsHelper.getUserId();
      final eventId = await SharedPrefsHelper.getLatestEventId();

      if (userId == null || eventId == null) {
        throw Exception('User data not found. Please login again.');
      }

      print('=== Registration data - userId: $userId, eventId: $eventId, sessionId: $sessionId ===');

      final response = await _repo.registerForSession(
        userId: userId,
        eventId: eventId,
        sessionId: sessionId,
        whyJoin: whyJoin,
        relevantExperience: relevantExperience,
      );

      print('=== Registration response - success: ${response.success}, message: ${response.message} ===');
      print('=== Join Code: ${response.joinCode}, Token: ${response.token} ===');

      // Consider it successful if we got a token, even if success is false
      final isSuccessful = response.success || response.token != null;

      if (isSuccessful) {
        // Save the token and join code for later use
        if (response.token != null) {
          print('=== Registration token received: ${response.token} ===');
        }
        if (response.joinCode != null) {
          print('=== Join code received: ${response.joinCode} ===');
        }
      }

      return isSuccessful;
    } catch (e) {
      errorMessage.value = 'Failed to register: $e';
      print('=== Registration error: $e ===');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
  }
}