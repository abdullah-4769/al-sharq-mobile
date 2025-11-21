
import 'package:get/get.dart';
import '../../data/response_models/speaker_response_models/speaker_profile_show_on_dashboard_model.dart';
import '../../repository/speaker_repository/speaker_profile_show_on_dashboard_repo.dart';
import 'package:flutter/material.dart';
class SpeakerProfileShowOnDashboardViewModel extends GetxController {
  final SpeakerProfileShowOnDashboardRepo _repo = SpeakerProfileShowOnDashboardRepo();

  final Rx<SpeakerProfileShowOnDashboardModel?> _speakerProfile = Rx<SpeakerProfileShowOnDashboardModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  SpeakerProfileShowOnDashboardModel? get speakerProfile => _speakerProfile.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  Future<void> fetchSpeakerProfile(int speakerId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final profile = await _repo.getSpeakerProfile(speakerId);
      _speakerProfile.value = profile;
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load speaker profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }
}