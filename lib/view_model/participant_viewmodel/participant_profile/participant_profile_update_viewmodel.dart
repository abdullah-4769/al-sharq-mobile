import 'package:get/get.dart';
import '../../../repository/participants_repository/participant_profile/participant_profile_update_repo.dart';


class ParticipantProfileUpdateViewModel extends GetxController {
  final ParticipantProfileUpdateRepository _repository = ParticipantProfileUpdateRepository();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _successMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get successMessage => _successMessage.value;

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String organization,
    String? filePath,
  }) async {
    _isLoading.value = true;
    _error.value = '';
    _successMessage.value = '';
    update();

    try {
      final response = await _repository.updateProfile(
        name: name,
        email: email,
        organization: organization,
        filePath: filePath,
      );

      _successMessage.value = response.message;
      _isLoading.value = false;
      update();
      return true;
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      update();
      return false;
    }
  }

  void clearError() {
    _error.value = '';
    update();
  }

  void clearSuccessMessage() {
    _successMessage.value = '';
    update();
  }
}