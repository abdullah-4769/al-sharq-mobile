import 'package:get/get.dart';

import '../../data/response_models/registration_team_model/event_registration_check_model.dart';
import '../../repository/registration_team_repo/event_registration_repository.dart';

class EventRegistrationViewModel extends GetxController {
  final EventRegistrationRepository _repository =
  EventRegistrationRepository();

  // Reactive states
  final Rx<EventRegistrationCheckModel?> _registrationCheck =
  Rx<EventRegistrationCheckModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  // Getters
  EventRegistrationCheckModel? get registrationCheck => _registrationCheck.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  // Check registration requirement
  Future<void> checkRegistrationRequirement(
      String eventId, String userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final result =
      await _repository.checkFirstRegistration(eventId, userId);

      _registrationCheck.value = result;
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      _error.value = e.toString();
      print('Error checking registration: $e');
    }
  }

  // Reset state
  void reset() {
    _registrationCheck.value = null;
    _error.value = '';
    _isLoading.value = false;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}