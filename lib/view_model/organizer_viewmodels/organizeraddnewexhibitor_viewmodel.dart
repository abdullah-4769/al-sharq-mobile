import 'package:get/get.dart';
import '../../data/request_models/organizer/organizeraddnewexhibitor_model.dart';
import '../../repository/organizer_repo/organizeraddnewexhibitor_repository.dart';

class OrganizerAddNewExhibitorViewModel extends GetxController {
  final OrganizerAddNewExhibitorRepository _repository = OrganizerAddNewExhibitorRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<bool> addNewExhibitor({
    required String name,
    required String picUrl,
    required String description,
    required String location,
    required String website,
    required String email,
    required String phone,
    required String linkedin,
    required String twitter,
    required String youtube,
    required String password,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      successMessage('');

      final exhibitorData = OrganizerAddNewExhibitorRequestModel(
        name: name,
        picUrl: picUrl,
        description: description,
        location: location,
        website: website,
        email: email,
        phone: phone,
        linkedin: linkedin,
        twitter: twitter,
        youtube: youtube,
        password: password,
      );

      final response = await _repository.addNewExhibitor(exhibitorData);

      successMessage('Exhibitor added successfully!');
      return true;
    } catch (e) {
      errorMessage('Failed to add exhibitor: $e');
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