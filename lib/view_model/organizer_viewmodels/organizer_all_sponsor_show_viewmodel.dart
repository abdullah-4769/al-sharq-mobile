import 'package:get/get.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_all_sponsor_show_model.dart';
import 'package:flutter/material.dart';
import '../../repository/organizer_repo/organizer_all_sponsor_show_repo.dart';

class OrganizerAllSponsorShowViewModel extends GetxController {
  final _repo = OrganizerAllSponsorShowRepo();

  var sponsorsData = Rx<OrganizerAllSponsorShowModel?>(null);
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> fetchSponsors() async {
    try {
      isLoading.value = true;
      error.value = '';

      final data = await _repo.getSponsors();
      sponsorsData.value = data;

    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load sponsors: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods
  bool get hasData => sponsorsData.value != null;

  List<OrganizerAllSponsorShowSponsor> get sponsors =>
      sponsorsData.value?.sponsors ?? [];

  List<OrganizerAllSponsorShowSponsor> get goldSponsors =>
      sponsors.where((sponsor) => sponsor.category.toLowerCase() == 'gold').toList();

  List<OrganizerAllSponsorShowSponsor> get silverSponsors =>
      sponsors.where((sponsor) => sponsor.category.toLowerCase() == 'silver').toList();

  List<OrganizerAllSponsorShowSponsor> get otherSponsors =>
      sponsors.where((sponsor) =>
      sponsor.category.toLowerCase() != 'gold' &&
          sponsor.category.toLowerCase() != 'silver'
      ).toList();

  int get goldCount => goldSponsors.length;
  int get silverCount => silverSponsors.length;
  int get otherCount => otherSponsors.length;

  @override
  void onInit() {
    super.onInit();
    fetchSponsors();
  }
}