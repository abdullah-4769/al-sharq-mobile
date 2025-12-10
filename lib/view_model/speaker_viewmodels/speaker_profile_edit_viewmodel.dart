import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import '../../data/request_models/speaker_request_models/speaker_profile_edit_model.dart';
import '../../repository/speaker_repository/speaker_profile_edit_repo.dart';
import '../../utils/shared_preference.dart';

class SpeakerProfileEditViewModel extends GetxController {
  final SpeakerProfileEditRepo _repo = SpeakerProfileEditRepo();
  var isLoading = false.obs;

  Future<void> updateSpeakerProfile(SpeakerProfileEditRequestModel data) async {
    try {
      isLoading.value = true;

      // Get speaker ID and auth token from shared preferences
      final speakerId = await SharedPrefsHelper.getSpeakerId();
      final authToken = await SharedPrefsHelper.getAuthToken();

      if (speakerId == null) {
        throw Exception('Speaker ID not found');
      }

      if (authToken == null || authToken.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Call the repository with auth token
      final updatedProfile = await _repo.updateSpeakerProfile(
        speakerId: speakerId,
        data: data,
        authToken: authToken,
      );

      // Show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // You might want to update your local state here

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}