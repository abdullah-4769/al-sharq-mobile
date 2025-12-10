import 'package:get/get.dart';
import '../../repository/participants_repository/event_registration_toggle_status_repo.dart';


class EventRegistrationToggleStatusViewModel extends GetxController {
  final EventRegistrationToggleStatusRepository _repository = EventRegistrationToggleStatusRepository();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isRegistered = false.obs;
  bool get isRegistered => _isRegistered.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  Future<void> fetchRegistrationStatus({
    required int eventId,
    required int userId,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _repository.getRegistrationStatus(
        eventId: eventId,
        userId: userId,
      );

      _isRegistered.value = response.isRegistered;

    } catch (e) {
      _errorMessage.value = e.toString();
      print('Error fetching registration status: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _isLoading.close();
    _isRegistered.close();
    _errorMessage.close();
    super.onClose();
  }
}