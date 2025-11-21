import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/response_models/speaker_response_models/speaker_dashboard_show_model.dart';
import '../../repository/speaker_repository/speaker_dashboard_show_repo.dart';

class SpeakerDashboardShowViewModel extends GetxController {
  final SpeakerDashboardShowRepo _repo = SpeakerDashboardShowRepo();

  final Rx<SpeakerDashboardShowModel?> _speakerProfile = Rx<SpeakerDashboardShowModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  SpeakerDashboardShowModel? get speakerProfile => _speakerProfile.value;
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
      // Get.snackbar(
      //   'Error',
      //   'Failed to load speaker profile: $e',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchSpeakerProfileByUserId(int userId) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final profile = await _repo.getSpeakerProfileByUserId(userId);
      _speakerProfile.value = profile;
    } catch (e) {
      _error.value = e.toString();
      // Get.snackbar(
      //   'Error',
      //   'Failed to load speaker profile: $e',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _error.value = '';
  }

  // Helper methods to check if fields are available
  bool get hasWebsite => speakerProfile?.website != null && speakerProfile!.website!.isNotEmpty;
  bool get hasLinkedIn => speakerProfile?.linkedin != null && speakerProfile!.linkedin!.isNotEmpty;
  bool get hasTwitter => speakerProfile?.twitter != null && speakerProfile!.twitter!.isNotEmpty;
  bool get hasYouTube => speakerProfile?.youtube != null && speakerProfile!.youtube!.isNotEmpty;
  bool get hasFacebook => speakerProfile?.facebook != null && speakerProfile!.facebook!.isNotEmpty;
  bool get hasDesignations => speakerProfile?.designations.isNotEmpty ?? false;
  bool get hasExpertise => speakerProfile?.expertise.isNotEmpty ?? false;
  bool get hasTags => speakerProfile?.tags.isNotEmpty ?? false;
  bool get hasUserImage => speakerProfile?.user.file != null && speakerProfile!.user.file!.isNotEmpty;
}