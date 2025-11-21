import 'package:get/get.dart';
import '../../data/request_models/organizer/organizeraddnewspeaker_model.dart';
import '../../repository/organizer_repo/organizeraddnewspeaker_repository.dart';

class OrganizerAddNewSpeakerViewModel extends GetxController {
  final OrganizerAddNewSpeakerRepository _repository = OrganizerAddNewSpeakerRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<bool> addNewSpeaker({
    required int userId,
    required List<String> designations,
    required String bio,
    required List<String> expertise,
    required List<String> tags,
    required String country,
    String? website,
    String? facebook,
    String? linkedin,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      successMessage('');

      final speakerData = OrganizerAddNewSpeakerRequestModel(
        userId: userId,
        designations: designations,
        bio: bio,
        expertise: expertise,
        tags: tags,
        country: country,
        website: website,
        facebook: facebook,
        linkedin: linkedin,
      );

      final response = await _repository.addNewSpeaker(speakerData);

      successMessage('Speaker created successfully!');
      return true;
    } catch (e) {
      errorMessage('Failed to create speaker: $e');
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