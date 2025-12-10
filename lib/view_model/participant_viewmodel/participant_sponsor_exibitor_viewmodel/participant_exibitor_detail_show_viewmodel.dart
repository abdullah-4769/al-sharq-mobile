// lib/view_model/participant_viewmodel/participant_exhibitor_details_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_exibitor_detail_show_model.dart';
import '../../../repository/participants_repository/participant_spnosor_and_exibitor/participant_exibitor_details_show_repo.dart';

class ParticipantExhibitorDetailsViewModel extends GetxController {
  final ParticipantExhibitorDetailsRepo _repo = ParticipantExhibitorDetailsRepo();

  final Rx<ParticipantExhibitorDetailsModel?> _exhibitorDetails =
  Rx<ParticipantExhibitorDetailsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  ParticipantExhibitorDetailsModel? get exhibitorDetails => _exhibitorDetails.value;

  Future<void> fetchExhibitorDetails(int exhibitorId, BuildContext context) async {
    try {
      print('=== Fetching exhibitor details for ID: $exhibitorId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final details = await _repo.getExhibitorDetails(exhibitorId, context);
      _exhibitorDetails.value = details;

      print('=== Successfully loaded exhibitor details: ${details.name} ===');
    } catch (e) {
      errorMessage.value = 'Failed to load exhibitor details: $e';
      print('=== Error loading exhibitor details: $e ===');

      Get.snackbar(
        'Error',
        'Failed to load exhibitor details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearData() {
    _exhibitorDetails.value = null;
    errorMessage.value = '';
  }
}