// lib/view_model/organizer_viewmodels/event_details_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/response/api_response.dart';
import '../../data/response_models/organizer_response_models/event_details_model.dart';
import '../../repository/organizer_repo/event_details_repository.dart';

class EventDetailsViewModel extends GetxController {
  final _repo = EventDetailsRepository();

  final Rx<ApiResponse<EventDetailsModel>> eventDetails =
      ApiResponse<EventDetailsModel>.loading().obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> fetchEventDetails(BuildContext context, int eventId) async {
    try {
      isLoading.value = true;
      error.value = '';
      eventDetails.value = ApiResponse<EventDetailsModel>.loading();

      final result = await _repo.getEventDetails(context, eventId);
      eventDetails.value = ApiResponse<EventDetailsModel>.completed(result);

    } catch (e) {
      error.value = e.toString();
      eventDetails.value = ApiResponse<EventDetailsModel>.error();

      Get.snackbar(
        'Error',
        'Failed to load event details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshData(BuildContext context, int eventId) {
    fetchEventDetails(context, eventId);
  }
}