import 'package:get/get.dart';
import '../../repository/organizer_repo/organizerdeletespeaker_repository.dart';


class OrganizerDeleteSpeakerViewModel extends GetxController {
  final OrganizerDeleteSpeakerRepository _repository = OrganizerDeleteSpeakerRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<bool> deleteSpeaker(int speakerId) async {
    try {
      isLoading(true);
      errorMessage('');
      successMessage('');

      final response = await _repository.deleteSpeaker(speakerId);

      successMessage(response.message);
      return true;
    } catch (e) {
      errorMessage('Failed to delete speaker: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  void clearMessages() {
    errorMessage('');
    successMessage('');
  }
}