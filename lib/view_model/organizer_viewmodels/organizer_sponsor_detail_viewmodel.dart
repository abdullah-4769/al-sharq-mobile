import 'package:get/get.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_sponsor_detail_model.dart';
import 'package:flutter/material.dart';
import '../../repository/organizer_repo/organizer_sponsor_detail_repo.dart';

class OrganizerSponsorDetailViewModel extends GetxController {
  final _repo = OrganizerSponsorDetailRepo();

  var sponsorDetail = Rx<OrganizerSponsorDetailModel?>(null);
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> fetchSponsorDetail(int sponsorId) async {
    try {
      isLoading.value = true;
      error.value = '';
      sponsorDetail.value = null;

      final data = await _repo.getSponsorDetail(sponsorId);
      sponsorDetail.value = data;

    } catch (e) {
      error.value = e.toString();
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

  bool get hasData => sponsorDetail.value != null;

  @override
  void onInit() {
    super.onInit();
  }
}