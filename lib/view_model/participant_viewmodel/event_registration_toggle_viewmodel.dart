import 'package:get/get.dart';
import '../../repository/participants_repository/event_registration_toggle_repo.dart';
import 'package:flutter/material.dart';

class EventRegistrationToggleViewModel extends GetxController {
  final EventRegistrationToggleRepository _repository = EventRegistrationToggleRepository();

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isRegistered = false.obs;
  bool get isRegistered => _isRegistered.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  Future<void> toggleRegistration({
    required int eventId,
    required int userId,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _repository.toggleRegistration(
        eventId: eventId,
        userId: userId,
      );

      _isRegistered.value = response.isRegistered;

      // Show success message
      Get.snackbar(
        response.isRegistered ? 'Registered!' : 'Unregistered',
        response.isRegistered
            ? 'You have successfully registered for the event'
            : 'You have unregistered from the event',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: response.isRegistered ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );

    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to toggle registration: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void setRegistrationStatus(bool status) {
    _isRegistered.value = status;
  }

  @override
  void onClose() {
    _isLoading.close();
    _isRegistered.close();
    _errorMessage.close();
    super.onClose();
  }
}