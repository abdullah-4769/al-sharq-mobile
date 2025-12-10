import 'package:get/get.dart';
import '../../data/response_models/organizer_response_models/organizer_show_list_sponsors_model.dart';
import '../../repository/organizer_repo/organizer_show_list_sponsors_repo.dart';
import 'package:flutter/material.dart';

class OrganizerShowListSponsorsViewModel extends GetxController {
  final _repo = OrganizerShowListSponsorsRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var sponsorsList = <OrganizerShowListSponsorsModel>[].obs;

  Future<void> getSponsorsList() async {
    try {
      print('🚀 OrganizerShowListSponsorsViewModel: Starting getSponsorsList...');
      isLoading.value = true;
      error.value = '';

      final sponsors = await _repo.getSponsorsList();
      sponsorsList.value = sponsors;

      print('✅ OrganizerShowListSponsorsViewModel: Successfully loaded sponsors list');
      print('📊 Total Sponsors: ${sponsors.length}');

      for (var sponsor in sponsors) {
        print('🏢 Sponsor: ${sponsor.name} (ID: ${sponsor.id})');
        print('   - Email: ${sponsor.email}');
        print('   - Photo URL: ${sponsor.picUrl}');
      }

      // Get.snackbar(
      //   'Success',
      //   'Sponsors list loaded successfully!',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 3),
      // );

    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerShowListSponsorsViewModel: Error in getSponsorsList: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        'Failed to load sponsors list: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerShowListSponsorsViewModel: getSponsorsList completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to load sponsors')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}