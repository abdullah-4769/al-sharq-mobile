import 'package:get/get.dart';
import '../../data/request_models/organizer/organizeraddnewsponsor_model.dart';
import '../../repository/organizer_repo/organizeraddnewsponsor_repository.dart';

class OrganizerAddNewSponsorViewModel extends GetxController {
  final OrganizerAddNewSponsorRepository _repository = OrganizerAddNewSponsorRepository();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<bool> addNewSponsor({
    required String name,
    required String description,
    required String category,
    required String picUrl,
    required String linkedin,
    required String twitter,
    required String youtube,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      isLoading(true);
      errorMessage('');
      successMessage('');

      final sponsorData = OrganizerAddNewSponsorRequestModel(
        name: name,
        description: description,
        category: category,
        picUrl: picUrl,
        linkedin: linkedin,
        twitter: twitter,
        youtube: youtube,
        email: email,
        phone: phone,
        password: password,
      );

      final response = await _repository.addNewSponsor(sponsorData);

      successMessage('Sponsor added successfully!');
      return true;
    } catch (e) {
      errorMessage('Failed to add sponsor: $e');
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