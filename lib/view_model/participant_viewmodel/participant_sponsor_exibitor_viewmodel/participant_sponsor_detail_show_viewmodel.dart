// lib/view_model/participant_viewmodel/participant_sponsor_details_show_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_sponsor_detail_showmodel.dart';
import '../../../repository/participants_repository/participant_spnosor_and_exibitor/participant_sponsor_details_show_repo.dart';

class ParticipantSponsorDetailsShowViewModel extends GetxController {
  final ParticipantSponsorDetailsShowRepo _repo = ParticipantSponsorDetailsShowRepo();

  final Rx<ParticipantSponsorDetailsShowModel?> _sponsorDetails =
  Rx<ParticipantSponsorDetailsShowModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  ParticipantSponsorDetailsShowModel? get sponsorDetails => _sponsorDetails.value;

  Future<void> fetchSponsorDetails(int sponsorId, BuildContext context) async {
    try {
      print('=== Fetching sponsor details for ID: $sponsorId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final details = await _repo.getSponsorDetails(sponsorId, context);
      _sponsorDetails.value = details;

      print('=== Successfully loaded sponsor details: ${details.name} ===');
    } catch (e) {
      errorMessage.value = 'Failed to load sponsor details: $e';
      print('=== Error loading sponsor details: $e ===');

      Get.snackbar(
        'Error',
        'Failed to load sponsor details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearData() {
    _sponsorDetails.value = null;
    errorMessage.value = '';
  }
}