// lib/view_model/participant_viewmodel/participant_exhibitor_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_and _exibitors_response_model.dart';
import '../../../repository/participants_repository/participant_spnosor_and_exibitor/participant_sponsor_repo.dart';
import '../../../utils/shared_preference.dart';

class ParticipantExhibitorViewModel extends GetxController {
  final ParticipantExhibitorRepo _repo = ParticipantExhibitorRepo();

  final Rx<ParticipantSponsorExhibitorResponseModel?> _sponsorsExhibitorsData =
  Rx<ParticipantSponsorExhibitorResponseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  List<ParticipantSponsorModel> get allSponsors =>
      _sponsorsExhibitorsData.value?.sponsors ?? [];

  List<ParticipantExhibitorModel> get allExhibitors =>
      _sponsorsExhibitorsData.value?.exhibitors ?? [];

  Future<void> fetchSponsorsAndExhibitors(BuildContext context) async {
    try {
      print('=== Fetching sponsors and exhibitors ===');
      isLoading.value = true;
      errorMessage.value = '';

      final eventId = await SharedPrefsHelper.getLatestEventId();
      if (eventId == null) {
        throw Exception('No event ID found. Please login again.');
      }

      final data = await _repo.getSponsorsAndExhibitors(eventId, context);
      _sponsorsExhibitorsData.value = data;

      print('=== Successfully loaded ${data.sponsors.length} sponsors and ${data.exhibitors.length} exhibitors ===');
    } catch (e) {
      errorMessage.value = 'Failed to load sponsors and exhibitors: $e';
      print('=== Error loading sponsors and exhibitors: $e ===');

      Get.snackbar(
        'Error',
        'Failed to load sponsors and exhibitors: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearData() {
    _sponsorsExhibitorsData.value = null;
    errorMessage.value = '';
  }
}