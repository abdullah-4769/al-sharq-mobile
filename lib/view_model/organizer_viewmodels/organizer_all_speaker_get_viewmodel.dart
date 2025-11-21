import 'package:get/get.dart';
import '../../data/response_models/organizer_response_models/organizer_all_speaker_get_model.dart';
import '../../repository/organizer_repo/organizer_all_speaker_get_repo.dart';
import 'package:flutter/material.dart';

class OrganizerAllSpeakerGetViewModel extends GetxController {
  final _repo = OrganizerAllSpeakerGetRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var speakersList = <OrganizerAllSpeakerGetModel>[].obs;

  Future<void> getAllSpeakers() async {
    try {
      print('🚀 OrganizerAllSpeakerGetViewModel: Starting getAllSpeakers...');
      isLoading.value = true;
      error.value = '';

      final speakers = await _repo.getAllSpeakers();
      speakersList.value = speakers;

      print('✅ OrganizerAllSpeakerGetViewModel: Successfully loaded speakers list');
      print('📊 Total Speakers: ${speakers.length}');

      for (var speaker in speakers) {
        print('🎤 Speaker: ${speaker.displayName} (ID: ${speaker.speakerId})');
      }

    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerAllSpeakerGetViewModel: Error in getAllSpeakers: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        'Failed to load speakers: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerAllSpeakerGetViewModel: getAllSpeakers completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to load speakers')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}